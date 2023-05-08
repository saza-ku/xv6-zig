// Buffer cache.
//
// The buffer cache is a linked list of buf structures holding
// cached copies of disk block contents.  Caching disk blocks
// in memory reduces the number of disk reads and also provides
// a synchronization point for disk blocks used by multiple processes.
//
// Interface:
// * To get a buffer for a particular disk block, call bread.
// * After changing buffer data, call bwrite to write it to disk.
// * When done with the buffer, call brelse.
// * Do not use the buffer after calling brelse.
// * Only one process at a time can use a buffer,
//     so do not keep them longer than necessary.
//
// The implementation uses two state flags internally:
// * B_VALID: the buffer data has been read from the disk.
// * B_DIRTY: the buffer data has been modified
//     and needs to be written to disk.

const fs = @import("fs.zig");
const ide = @import("ide.zig");
const param = @import("param.zig");
const sleeplock = @import("sleeplock.zig");
const spinlock = @import("spinlock.zig");

pub const buf = struct {
    flags: u32,
    dev: u32,
    blockno: u32,
    lock: sleeplock.sleeplock,
    refcnt: u32,
    prev: *buf, // LRU cache list
    next: *buf,
    qnext: ?*buf, // disk queue
    data: [fs.BSIZE]u8,

    const Self = @This();

    fn is_used(self: *Self) bool {
        return self.refcnt != 0 or (self.flags & B_DIRTY) != 0;
    }

    pub fn read(dev: u32, blockno: u32) *Self {
        const b = bget(dev, blockno);
        if ((b.flags & B_VALID) == 0) {
            ide.iderw(b);
        }
        return b;
    }

    pub fn write(self: *Self) void {
        if (!self.lock.holding()) {
            asm volatile ("1: jmp 1b"); // TODO: error handling
        }
        self.flags |= B_DIRTY;
        ide.iderw(self);
    }
};

pub const B_VALID = 0x2; // buffer has been read from disk
pub const B_DIRTY = 0x4; // buffer needs to be written to disk

var bcache = struct {
    lock: spinlock.spinlock,
    buf: [param.NBUF]buf,
    head: buf,
}{
    .lock = spinlock.spinlock.init("bcache"),
    .buf = undefined,
    .head = undefined,
};

pub fn binit() void {
    //Create list of buffers
    bcache.head.prev = &bcache.head;
    bcache.head.next = &bcache.head;
    for (bcache.buf) |*b| {
        b.*.next = bcache.head.next;
        b.*.prev = &bcache.head;
        b.*.lock = sleeplock.sleeplock.init("buffer");
        bcache.head.next.*.prev = b;
        bcache.head.next = b;
    }
}

// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
fn bget(dev: u32, blockno: u32) *buf {
    bcache.lock.acquire();
    defer bcache.lock.release();

    // Is the block already cached?
    var b = bcache.head.next;
    while (b != &bcache.head) {
        if (b.dev == dev and b.blockno == blockno) {
            b.*.refcnt += 1;
            return b;
        }
        b = b.next;
    }

    // Not cached; recycle an unused buffer.
    // Even if refcnt==0, B_DIRTY indicates a buffer is in use
    // because log.c has modified it but not yet committed it.
    b = bcache.head.prev;
    while (b != &bcache.head) {
        if (!b.is_used()) {
            b.*.dev = dev;
            b.*.blockno = blockno;
            b.*.flags = 0;
            b.*.refcnt = 1;
            b.lock.acquire();
            return b;
        }
    }

    asm volatile ("1: jmp 1b"); // TODO: error handling
    unreachable;
}
