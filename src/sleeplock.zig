const spinlock = @import("spinlock.zig");

// Long-term locks for processes
pub const sleeplock = struct {
    locked: bool, // Is the lock held?
    lk: spinlock.spinlock, // spinlock protecting this sleep lock

    // For debugging:
    name: []*const u8, // Name of lock
    pid: u32, // Process hoding lock
};
