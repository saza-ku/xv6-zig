// Mutual exclusion lock.
pub const spinlock = struct {
    locked: bool, // Is the lock held?

    // For debugging:
    name: []const u8,
    // cpu: *cpu,
    pcs: [10]u32, // The call stack (an aray of program counters) that locked the lock.
};
