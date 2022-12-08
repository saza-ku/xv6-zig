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
const sleeplock = @import("sleeplock.zig");

pub const buf = struct {
    flags: u32,
    dev: u32,
    blockno: u32,
    lock: sleeplock.sleeplock,
    refcnt: u32,
    prev: *buf, // LRU cache list
    next: *buf,
    qnext: *buf, // disk queue
    data: [fs.BSIZE]u8,
};

const B_VALID = 0x2; // buffer has been read from disk
const B_DIRTY = 0x4; // buffer needs to be written to disk
