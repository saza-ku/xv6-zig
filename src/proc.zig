const file = @import("file.zig");
const mmu = @import("mmu.zig");
const param = @import("param.zig");
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
    proc: ?*proc,
};

pub const procstate = enum {
    UNUSED, EMBRYO, SLEEPING, RUNNABLE, RUNNING, ZOMBIE,
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

// Process memory is laid out contiguously, low addresses first:
//   text
//   original data and bss
//   fixed-size stack
//   expandable heap
