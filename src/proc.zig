const file = @import("file.zig");
const lapic = @import("lapic.zig");
const mmu = @import("mmu.zig");
const mp = @import("mp.zig");
const param = @import("param.zig");
const spinlock = @import("spinlock.zig");
const x86 = @import("x86.zig");

// Per-CPU state
pub const cpu = struct {
    apicid: u16, // Local APIC ID
    scheduler: ?*context, // swtch() here to enter scheduler
    ts: mmu.taskstate, // Used by x86 to find stack for interrupt
    gdt: [mmu.NSEGS]mmu.segdesc, // x86 global descripter table
    started: bool, // Has the CPU started?
    ncli: u32, // Depth of pushcli nesting.
    intena: bool, // Were interrupts enabled before pushcli?
    proc: *proc,
};

pub const procstate = enum {
    UNUSED,
    EMBRYO,
    SLEEPING,
    RUNNABLE,
    RUNNING,
    ZOMBIE,
};

// Saved registers for kernel context switches.
// Don't need to save all the segment registers (%cs, etc),
// because they are constant across kernel contexts.
// Don't need to save %eax, %ecx, %edx, because the
// x86 convention is that the caller has saved them.
// Contexts are stored at the bottom of the stack they
// describe; the stack pointer is the address of the context.
// The layout of the context matches the layout of the stack in swtch.zig
// at the "Switch stacks" comment. Switch doesn't save eip explicitly,
// but it is on the stack and allocproc() manipulates it.
pub const context = struct {
    edi: u32,
    esi: u32,
    ebx: u32,
    ebp: u32,
    eip: u32,
};

// Per-process state
pub const proc = struct {
    sz: usize, // Size of process memory (bytes)
    pgdir: *mmu.pde_t, // Page table
    kstack: usize, // Bottom of kernel stack for this process
    state: procstate, // Process state
    pid: u32, // Process ID
    parent: ?*proc, // Parent process
    tf: ?*x86.trapframe, // Trap frame for current syscall
    context: ?*context, // swtch() here to run process
    chan: usize, // If non-zero, sleeping on chan
    killed: bool, // Whether it's been killed
    ofile: *[param.NOFILE]file.file, // Open files
    cwd: ?*file.inode, // Current directory
    name: []const u8, // Process name (debugging)
};

var ptable = struct {
    lock: spinlock.spinlock,
    proc: [param.NPROC]proc,
}{
    .lock = spinlock.spinlock.init("ptable"),
    .proc = undefined,
};

// Process memory is laid out contiguously, low addresses first:
//   text
//   original data and bss
//   fixed-size stack
//   expandable heap

pub fn cpuid() u32 {
    return (@intFromPtr(&mp.cpus) - @intFromPtr(mycpu())) / @sizeOf(cpu);
}

pub fn mycpu() *cpu {
    if (x86.readeflags() & mmu.FL_IF != 0) {
        asm volatile ("1: jmp 1b"); // TODO: handle error
    }
    const apicid = lapic.lapicid();
    // APIC IDs are not guaranteed to be contiguous. Maybe we should have
    // a reverse map, or reserve a register to store &cpus[i].
    for (&mp.cpus) |*c| {
        if (c.apicid == apicid) {
            return c;
        }
    }
    asm volatile ("1: jmp 1b"); // TODO: handle error
    unreachable;
}

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
pub fn myproc() *proc {
    spinlock.pushcli();
    const c = mycpu();
    const p = c.proc;
    spinlock.popcli();
    return p;
}

pub fn sleep(chan: usize, lk: *spinlock.spinlock) void {
    const p = myproc();

    // Must acquire ptable.lock in order to
    // change p->state and then call sched.
    // Once we hold ptable.lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup runs with ptable.lock locked),
    // so it's okay to release lk.
    if (lk != &ptable.lock) {
        ptable.lock.acquire();
        lk.release();
    }
    // Go to sleep.
    p.*.chan = chan;
    p.*.state = procstate.SLEEPING;

    // TODO: sched();

    // Tidy up
    p.*.chan = 0;

    // Reacquire original lock.
    if (lk != &ptable.lock) {
        ptable.lock.release();
        lk.acquire();
    }
}

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
fn wakeup1(chan: usize) void {
    for (&ptable.proc) |*p| {
        if (p.state == procstate.SLEEPING and p.chan == chan) {
            p.*.state = procstate.RUNNABLE;
        }
    }
}

// Wake up all processes sleeping on chan.
pub fn wakeup(chan: usize) void {
    ptable.lock.acquire();
    wakeup1(chan);
    ptable.lock.release();
}
