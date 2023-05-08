const memlayout = @import("memlayout.zig");
const mmu = @import("mmu.zig");
const param = @import("param.zig");
const proc = @import("proc.zig");
const x86 = @import("x86.zig");

// Mutual exclusion lock.
pub const spinlock = struct {
    locked: u32, // Is the lock held?

    // For debugging:
    name: []const u8,
    cpu: ?*proc.cpu,
    pcs: [10]usize, // The call stack (an aray of program counters) that locked the lock.

    const Self = @This();

    pub fn init(name: []const u8) Self {
        return Self{
            .name = name,
            .locked = 0,
            .cpu = null,
            .pcs = [10]usize{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        };
    }

    // Acquire the lock.
    // Loops (spins) until the lock is acquired.
    // Holding a lock for a long time may cause
    // other CPUs to waste time spinning to acquire it.
    pub fn acquire(self: *Self) void {
        pushcli(); // disable interrupts to avoid deadlock
        if (self.hoding()) {
            asm volatile ("1: jmp 1b"); // TODO: handle error
        }

        // The xchg is atomic
        // TODO: is locked value correctly changed?
        while (x86.xchg(&self.locked, 1) != 0) {}

        self.cpu = proc.mycpu();
        self.getcallerpcs();
    }

    pub fn release(self: *Self) void {
        if (!self.hoding()) {
            asm volatile ("1: jmp 1b"); // TODO: handle error
        }

        self.pcs[0] = 0;
        self.cpu = null;

        asm volatile ("movl $0, (%[addr])"
            :
            : [addr] "r" (&self.locked),
            : "memory"
        );

        popcli();
    }

    // Check whether this cpu is holding the lock.
    pub fn hoding(self: *Self) bool {
        var r: bool = undefined;
        pushcli();
        r = self.locked != 0 and self.cpu == proc.mycpu();
        popcli();
        return r;
    }

    // TODO: This function might be broken.
    // When file.devsw is set in consoleinit,
    // this function causes fault.
    fn getcallerpcs(self: *Self) void {
        var ebp_addr = asm ("mov %%ebp, %%eax"
            : [ret] "={eax}" (-> usize),
        );
        var i: u32 = 0;
        while (i < 10) : (i += 1) {
            if (ebp_addr == 0 or ebp_addr < memlayout.KERNBASE or ebp_addr == 0xffffffff) {
                break;
            }
            const ebp = @intToPtr([*]usize, ebp_addr); // fault here
            self.*.pcs[i] = ebp[1]; // saved %eip
            ebp_addr = ebp[0]; // saved %ebp
        }
        while (i < 10) : (i += 1) {
            self.*.pcs[i] = 0;
        }
    }
};

pub fn pushcli() void {
    const eflags = x86.readeflags();
    x86.cli();
    const mycpu = proc.mycpu();
    if (mycpu.ncli == 0) {
        mycpu.*.intena = eflags & mmu.FL_IF != 0;
    }
    mycpu.*.ncli += 1;
}

pub fn popcli() void {
    if (x86.readeflags() & mmu.FL_IF != 0) {
        asm volatile ("1: jmp 1b"); // TODO: handle error
    }
    const mycpu = proc.mycpu();
    mycpu.*.ncli -= 1;
    if (mycpu.ncli < 0) {
        asm volatile ("1: jmp 1b"); // TODO: handle error
    }
    if (mycpu.ncli == 0 and mycpu.intena) {
        x86.sti();
    }
}
