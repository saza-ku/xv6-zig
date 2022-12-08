const proc = @import("proc.zig");
const spinlock = @import("spinlock.zig");

// Long-term locks for processes
pub const sleeplock = struct {
    locked: bool, // Is the lock held?
    lk: spinlock.spinlock, // spinlock protecting this sleep lock

    // For debugging:
    name: []const u8, // Name of lock
    pid: u32, // Process hoding lock

    const Self = @This();

    pub fn init(name: []const u8) Self {
        return Self {
            .locked = false,
            .lk = spinlock.spinlock.init("sleep lock"),
            .name = name,
            .pid = 0,
        };
    }

    pub fn acquire(self: *Self) void {
        self.lk.acquire();
        defer self.lk.release();
        while (self.locked) {
            proc.sleep(self.locked, &self.lk);
        }
        self.locked = true;
        self.pid = proc.myproc().pid;
    }

    pub fn release(self: *Self) void {
        self.lk.acquire();
        defer self.lk.release();
        self.locked = false;
        self.pid = 0;
        proc.wakeup(@ptrToInt(self));
    }

    pub fn holding(self: *Self) bool {
        self.lk.acquire();
        defer self.lk.release();
        const r = self.locked and (self.pid == proc.myproc().pid);
        return r;
    }
};
