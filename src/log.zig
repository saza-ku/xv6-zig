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
