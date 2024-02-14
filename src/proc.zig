const console = @import("console.zig");
const file = @import("file.zig");
const kalloc = @import("kalloc.zig");
const lapic = @import("lapic.zig");
const memlayout = @import("memlayout.zig");
const mmu = @import("mmu.zig");
const mp = @import("mp.zig");
const param = @import("param.zig");
const spinlock = @import("spinlock.zig");
const util = @import("util.zig");
const vm = @import("vm.zig");
const x86 = @import("x86.zig");

extern fn trapret() void;

extern const _binary_zig_out_bin_initcode_start: u8;
// Note: This value of a symbol is its address,
// and the address is the size of initcode.
extern const _binary_zig_out_bin_initcode_size: u8;

var initproc: *proc = undefined;

// Per-CPU state
pub const cpu = struct {
    apicid: u16, // Local APIC ID
    scheduler: *context, // swtch() here to enter scheduler
    ts: mmu.taskstate, // Used by x86 to find stack for interrupt
    gdt: [mmu.NSEGS]mmu.segdesc, // x86 global descripter table
    started: bool, // Has the CPU started?
    ncli: u32, // Depth of pushcli nesting.
    intena: bool, // Were interrupts enabled before pushcli?
    proc: ?*proc,
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
pub const context = extern struct {
    edi: u32 = 0,
    esi: u32 = 0,
    ebx: u32 = 0,
    ebp: u32 = 0,
    eip: u32 = 0,
};

// Per-process state
pub const proc = struct {
    sz: usize, // Size of process memory (bytes)
    pgdir: [*]mmu.pde_t, // Page table
    kstack: usize, // Bottom of kernel stack for this process
    state: procstate, // Process state
    pid: u32, // Process ID
    parent: ?*proc, // Parent process
    tf: *x86.trapframe, // Trap frame for current syscall
    context: *context, // swtch() here to run process
    chan: usize, // If non-zero, sleeping on chan
    killed: bool, // Whether it's been killed
    ofile: *[param.NOFILE]file.file, // Open files
    cwd: ?*file.inode, // Current directory
    name: [16]u8, // Process name (debugging)
};

var ptable = struct {
    lock: spinlock.spinlock,
    proc: [param.NPROC]proc,
}{
    .lock = spinlock.spinlock.init("ptable"),
    .proc = undefined, // TODO: initialize
};

var nextpid: usize = 1;

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

// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return null.
pub fn allocproc() ?*proc {
    ptable.lock.acquire();

    for (&ptable.proc) |*p| {
        if (p.state == procstate.UNUSED) {
            p.*.state = procstate.EMBRYO;
            p.*.pid = nextpid;
            nextpid += 1;
            ptable.lock.release();

            // Allocate kernel stack.
            p.*.kstack = kalloc.kalloc() orelse {
                p.*.state = procstate.UNUSED;
                return null;
            };
            var sp = p.kstack + param.KSTACKSIZE;

            // Leave room for trap frame.
            sp -= @sizeOf(x86.trapframe);
            p.*.tf = @as(*x86.trapframe, @ptrFromInt(sp));

            // Set up new context to start executing at forkret, which returns to trapret.
            sp -= 4;
            const trapret_pointer = @as(**const fn () callconv(.C) void, @ptrFromInt(sp));
            trapret_pointer.* = trapret;

            sp -= @sizeOf(context);
            p.*.context = @as(*context, @ptrFromInt(sp));
            p.*.context.* = context{};
            p.*.context.eip = @intFromPtr(&forkret);
            return p;
        }
    }

    ptable.lock.release();
    return null;
}

pub fn userinit() void {
    const p = allocproc() orelse unreachable;

    initproc = p;
    p.*.pgdir = vm.setupkvm() orelse @panic("usetinit: out of memory?");

    vm.inituvm(p.pgdir, @as([*]u8, @ptrCast(&_binary_zig_out_bin_initcode_start)), @intFromPtr(&_binary_zig_out_bin_initcode_size));
    p.*.sz = mmu.PGSIZE;
    @memset(@as([*]u8, @ptrCast(p.*.tf))[0..@sizeOf(x86.trapframe)], 0);
    p.*.tf.cs = (mmu.SEG_UCODE << 3) | mmu.DPL_USER;
    p.*.tf.ds = (mmu.SEG_UDATA << 3) | mmu.DPL_USER;
    p.*.tf.es = p.*.tf.ds;
    p.*.tf.ss = p.*.tf.ds;
    p.*.tf.eflags = mmu.FL_IF;
    p.*.tf.esp = mmu.PGSIZE;
    p.*.tf.eip = 0; // beginning of initcode.S

    util.safestrcpy(&p.*.name, "initcode");
    // p.*.cwd = namei("/");

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    ptable.lock.acquire();

    p.*.state = procstate.RUNNABLE;

    ptable.lock.release();
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

fn forkret() callconv(.C) void {
    const S = struct {
        var first: bool = true;
    };

    // Still holding ptable.lock from scheduler.
    ptable.lock.release();

    if (S.first) {
        S.first = false;
        // TOOD: iinit, initlog
    }

    // Return to "caller", actually trapret (see allocproc).
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

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
pub fn scheduler() void {
    const c = mycpu();
    c.proc = null;

    const S = struct {
        var first: bool = true;
    };
    if (S.first) {
        console.printf("Process Scheduling\n", .{});
        S.first = false;
    }

    while (true) {
        x86.sti();

        ptable.lock.acquire();
        for (&ptable.proc) |*p| {
            if (p.state != procstate.RUNNABLE) {
                continue;
            }

            // Switch to chosen process. It is the process's job
            // to release ptable.lock and then reacquire it
            // before jumping back to us.
            c.proc = p;
            vm.switchuvm(p);
            p.*.state = procstate.RUNNING;
            x86.swtch(&c.scheduler, p.context);
            vm.switchkvm();

            // Process is done running for now.
            // It should have changed its p->state before coming back.
            c.proc = null;
        }
        ptable.lock.release();
    }
}
