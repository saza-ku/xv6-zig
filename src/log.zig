const bio = @import("bio.zig");
const fs = @import("fs.zig");
const param = @import("param.zig");
const proc = @import("proc.zig");
const spinlock = @import("spinlock.zig");

// Simple logging that allows concurrent FS system calls.
//
// A log transaction contains the updates of multiple FS system
// calls. The logging system only commits when there are
// no FS system calls active. Thus there is never
// any reasoning required about whether a commit might
// write an uncommitted system call's updates to disk.
//
// A system call should call begin_op()/end_op() to mark
// its start and end. Usually begin_op() just increments
// the count of in-progress FS system calls and returns.
// But if it thinks the log is close to running out, it
// sleeps until the last outstanding end_op() commits.
//
// The log is a physical re-do log containing disk blocks.
// The on-disk log format:
//   header block, containing block #s for block A, B, C, ...
//   block A
//   block B
//   block C
//   ...
// Log appends are synchronous.

const LogHeader = struct {
    n: i32, // number of blocks
    block: [param.LOGSIZE]i32, // disk block numbers
};

const Log = struct {
    lock: spinlock.spinlock,
    start: i32, // block number of first log block
    size: i32, // number of log blocks
    outstanding: i32, // how many FS sys calls are executing.
    committing: bool = false, // in commit(), please wait.
    dev: i32,
    lh: LogHeader,
};

var log: Log = undefined;

pub fn initlog(dev: i32) void {
    if (@sizeOf(LogHeader) >= fs.BSIZE) {
        bio.panic("initlog: too big log");
    }

    var sb = fs.superblock{};
    log.lock = spinlock.init("log");
    fs.readsb(dev, &sb);
    log.start = sb.logstart;
    log.size = sb.nlog;
    log.dev = dev;

    // recover_from_log();
}

// Copy committed blocks from log to their home location
fn install_trans() void {
    for (0..log.lh.n) |tail| {
        const log_buf = bio.buf.read(log.dev, log.start + tail + 1);
        var dst_buf = bio.buf.read(log.dev, log.lh.block[tail]);
        @memcpy(dst_buf.data, log_buf.data);
        dst_buf.write();
        dst_buf.release();
        log_buf.release();
    }
}

// Read the log header from disk into the in-memory log header
fn read_head() void {
    var buf = bio.buf.read(log.dev, log.start);
    var lh = @as(*LogHeader, @ptrCast(&buf.data));
    log.lh.n = lh.n;
    for (&log.lh.block, 0..) |*b, i| {
        b.* = lh.block[i];
    }
    buf.release();
}

// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
fn write_head() void {
    var buf = bio.buf.read(log.dev, log.start);
    var hb = @as(*LogHeader, @ptrCast(&buf.data));
    hb.n = log.lh.n;
    for (&hb.block, 0..) |*b, i| {
        b.* = log.lh.block[i];
    }
    buf.write();
    buf.release();
}

pub fn recover_from_log() void {
    read_head();
    install_trans(); // if commited, copy from log to disk
    log.lh.n = 0;
    write_head(); // clear the log
}

// called at the start of each FS system call.
pub fn begin_op() void {
    log.lock.acquire();
    while (true) {
        if (log.committing) {
            proc.sleep(@intFromPtr(log), &log.lock);
        } else if (log.lh.n + (log.outstanding + 1) * param.MAXOPBLOCKS > param.LOGSIZE) {
            // this op might exhaust log space; wait for commit.
            proc.sleep(@intFromPtr(log), &log.lock);
        } else {
            log.outstanding += 1;
            log.lock.release();
            break;
        }
    }
}

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
pub fn end_op() void {
    var do_commit = false;
    log.lock.acquire();
    if (log.committing) {
        @panic("log.commiting");
    }
    if (log.outstanding == 0) {
        do_commit = true;
        log.committing = true;
    } else {
        proc.wakeup(@intFromPtr(&log));
    }
    log.lock.release();

    if (do_commit) {
        // commit()
        log.lock.acquire();
        log.committing = false;
        proc.wakeup(@intFromPtr(&log));
        log.lock.release();
    }
}

// Copy modified blocks from cache to log.
fn write_log() void {
    for (0..log.lh.n) |tail| {
        var to = bio.buf.read(log.dev, log.start + tail + 1); // log block
        var from = bio.buf.read(log.dev, log.lh.block[tail]); // cache block
        @memcpy(to.data, from.data);
        to.write();
        to.release();
        from.release();
    }
}

fn commit() void {
    if (log.lh.n > 0) {
        write_log();
        write_head();
        install_trans();
        log.lh.n = 0;
        write_head();
    }
}

// Caller has modified b->data and is done with the buffer.
// Record the block number and pin in the cache with B_DIRTY.
// commit()/write_log() will do the disk write.
//
// log_write() replaces bwrite(); a typical use is:
//   bp = bread(...)
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
pub fn log_write(b: *bio.buf) void {
    if (log.lh.n >= param.LOGSIZE or log.lh.n >= log.size - 1) {
        @panic("too big transaction");
    }
    if (log.outstanding < 1) {
        @panic("log_write outside of trans");
    }

    log.lock.acquire();
    defer log.lock.release();
    var idx: usize = 0;
    while (idx < log.lh.n) : (idx += 1) {
        if (log.lh.block[idx] == b.blockno) {
            break;
        }
    }

    log.lh.block[idx] = b.blockno;
    if (idx == log.lh.n) {
        log.lh.n += 1;
    }

    b.flags |= bio.B_DIRTY;
}
