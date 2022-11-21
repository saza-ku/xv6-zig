const x86 = @import("x86.zig");

const IO_PIC1 = 0x20; // Master (IRQs 0-7)
const IO_PIC2 = 0xA0; // Slave (IRQs 8-15)

pub fn picinit() void {
    x86.out(IO_PIC1, @as(u8, 0xff));
    x86.out(IO_PIC2, @as(u8, 0xff));
}
