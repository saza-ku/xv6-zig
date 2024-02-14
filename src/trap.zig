// x86 trap and interrupt constants.

const console = @import("console.zig");
const kbd = @import("kbd.zig");
const lapic = @import("lapic.zig");
const mmu = @import("mmu.zig");
const proc = @import("proc.zig");
const spinlock = @import("spinlock.zig");
const uart = @import("uart.zig");
const x86 = @import("x86.zig");

// Processor-defined
pub const T_DIVIDE = 0;
pub const T_DEBUG = 1;
pub const T_NMI = 2;
pub const T_BRKPT = 3;
pub const T_OFLOW = 4;
pub const T_BOUND = 5;
pub const T_ILLOP = 6;
pub const T_DEVICE = 7;
pub const T_DBLFLT = 8;
pub const T_TSS = 10;
pub const T_SEGNP = 11;
pub const T_STACK = 12;
pub const T_GPFLT = 13;
pub const T_PGFLT = 14;
pub const T_FPERR = 16;
pub const T_ALIGN = 17;
pub const T_MCHK = 18;
pub const T_SIMDERR = 19;
pub const T_SYSCALL = 64;
pub const T_DEFAULT = 500;
pub const T_IRQ0 = 32;
pub const IRQ_TIMER = 0;
pub const IRQ_KBD = 1;
pub const IRQ_COM1 = 4;
pub const IRQ_IDE = 14;
pub const IRQ_ERROR = 19;
pub const IRQ_SPURIOUS = 31;

var idt: [256]mmu.gatedesc = undefined;
extern const vectors: u32;
var tickslock = spinlock.spinlock.init("time");
pub var ticks: u32 = 0;

pub fn tvinit() void {
    const v = @as([*]u32, @ptrCast(&vectors));

    var i: u32 = 0;
    while (i < 256) : (i += 1) {
        idt[i] = mmu.gatedesc.new(false, mmu.SEG_KCODE << 3, v[i], 0);
    }
    idt[T_SYSCALL] = mmu.gatedesc.new(true, mmu.SEG_KCODE << 3, v[T_SYSCALL], mmu.DPL_USER);
}

pub fn idtinit() void {
    x86.lidt(@intFromPtr(&idt), @as(u16, @intCast(@sizeOf(@TypeOf(idt)))));
}

export fn trap(tf: *x86.trapframe) void {
    if (tf.trapno == T_SYSCALL) {
        // TODO: system call
        console.printf("syscall\n", .{});
    }

    switch (tf.trapno) {
        T_IRQ0 + IRQ_TIMER => {
            tickslock.acquire();
            ticks += 1;
            if (ticks == 10) {
                console.printf("ticks = {}", .{ticks});
            }
            proc.wakeup(@intFromPtr(&ticks));
            tickslock.release();
            lapic.lapiceoi();
        },
        T_IRQ0 + IRQ_IDE => {
            // TODO: implement
        },
        T_IRQ0 + IRQ_IDE + 1 => {
            // Bochs generates spurious IDE1 interrupts.
        },
        T_IRQ0 + IRQ_KBD => {
            kbd.kbdintr();
            lapic.lapiceoi();
            // TODO: implement
        },
        T_IRQ0 + IRQ_COM1 => {
            uart.uartintr();
            lapic.lapiceoi();
            // TODO: implement
        },
        else => {
            asm volatile ("movl %[eip], %%eax"
                :
                : [eip] "r" (tf.eip),
            );
            asm volatile ("1: jmp 1b");
        },
    }

    // TODO: implement
}

fn panicHandler(tf: *x86.trapframe) void {
    const base = tf.ebp;
    const message = @as([*]u8, @ptrFromInt(base + 8))[0..1000];
    console.printf("hogehoge", .{});

    for (message) |c| {
        if (c == 0) {
            break;
        }
        console.putChar(c);
    }
    console.putChar('\n');
}
