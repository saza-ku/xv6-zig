const console = @import("console.zig");
const sleeplock = @import("sleeplock.zig");
const spinlock = @import("spinlock.zig");
const param = @import("param.zig");

pub const file = struct {
    typ: enum { FD_NONE, FD_PIPE, FD_INODE },
    ref: u32, // reference count,
    readable: bool,
    writable: bool,
    // pipe: pipe,
    // ip: inode,
    // off: u32,
};

// in-memory copy of an inode
pub const inode = struct {
    dev: u32, // Device number
    inum: u32, // // Inode number
    ref: u32, // Reference count
    lk: sleeplock.sleeplock, // protects everything below here
    valid: u32, // inode has been read from disk?

    typ: u16, // copy of disk inode
    major: u16,
    minor: u16,
    nlink: u16,
    size: u32,
    addrs: [13]u32,

    const Self = @This();

    pub fn lock(self: *Self) void {
        _ = self;
        // TODO: implement
    }

    pub fn unlock(self: *Self) void {
        _ = self;
        // TODO: implement
    }
};

pub const devsw_t = struct {
    read: *const fn (ip: *inode, dst: [*]u8, n: u32) ?u32,
    write: *const fn (ip: *inode, buf: []const u8, n: u32) u32,
};

pub var devsw: [param.NDEV]devsw_t = init: {
    var initial_value: [param.NDEV]devsw_t = undefined;
    for (initial_value, 0..) |*pt, i| {
        if (i == CONSOLE) {
            pt.* = devsw_t{
                .read = console.consoleread,
                .write = console.consolewrite,
            };
        } else {
            pt.* = undefined;
        }
    }
    break :init initial_value;
};

var ftable = struct {
    lock: spinlock.spinlock,
    file: [param.NFILE]file,
}{
    .lock = spinlock.spinlock.init("file"),
    .file = undefined,
};

pub const CONSOLE = 1;
