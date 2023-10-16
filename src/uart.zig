const console = @import("console.zig");
const ioapic = @import("ioapic.zig");
const lapic = @import("lapic.zig");
const trap = @import("trap.zig");
const x86 = @import("x86.zig");

const COM1 = 0x3f8;

var uart: bool = false;

pub fn uartinit() void {
    // Turn off the FIFO
    x86.out(COM1 + 2, @as(u8, 0));

    // 9600 baud, 8 data bits, 1 stop bit, parity off.
    x86.out(COM1 + 3, @as(u8, 0x80)); // Unlock divisor
    x86.out(COM1 + 0, @as(u8, 115200 / 9600));
    x86.out(COM1 + 1, @as(u8, 0));
    x86.out(COM1 + 3, @as(u8, 0x03)); // Lock divisor, 8 data bits.
    x86.out(COM1 + 4, @as(u8, 0));
    x86.out(COM1 + 1, @as(u8, 0x01)); // Enable receive interrupts.

    // If status if 0xFF, no serial port.
    if (x86.in(u8, COM1 + 5) == 0xff) {
        return;
    }
    uart = true;

    // Acknowledge pre-existing interrupt conditions;
    // enable interrupts.
    _ = x86.in(u8, COM1 + 2);
    _ = x86.in(u8, COM1 + 0);
    ioapic.ioapicenable(trap.IRQ_COM1, 0);

    // Announce that we're here.
    const str = "xv6...";
    for (str) |c| {
        putc(c);
    }
}

pub fn putc(c: u8) void {
    if (!uart) {
        return;
    }
    var i: u32 = 0;
    while (i < 128 and (x86.in(u8, COM1 + 5)) & 0x20 == 0) : (i += 1) {
        lapic.microdelay(10);
    }
    x86.out(COM1 + 0, @as(u8, c));
}

fn getc() ?u8 {
    if (!uart) {
        return null;
    }
    if ((x86.in(u8, COM1 + 5)) & 0x01 == 0) {
        return null;
    }
    return x86.in(u8, COM1 + 0);
}

pub fn uartintr() void {
    console.consoleintr(getc);
}
