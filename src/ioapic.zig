// The I/O APIC manages hardware interrupts for an SMP system.
// http://www.intel.com/design/chipsets/datashts/29056601.pdf
// See also picirq.c.

const mp = @import("mp.zig");
const trap = @import("trap.zig");

const IOAPIC = 0xFEC00000; // Default physical address of IO APIC

const REG_ID = 0x00; // Register index: ID
const REG_VER = 0x01; // Register index: version
const REG_TABLE = 0x10; // Redirection table base

// The redirection table starts at REG_TABLE and uses
// two registers to configure each interrupt.
// The first (low) register in a pair contains configuration bits.
// The second (high) register contains a bitmask telling which
const INT_DISABLED = 0x00010000; // Interrupt disabled
const INT_LEVEL = 0x00008000; // Level-triggered (vs edge-)
const INT_ACTIVELOW = 0x00002000; // Active low (vs high)
const INT_LOGICAL = 0x00000800; // Destination is CPU id (vs APIC ID)

var ioapic: *ioapic_t = undefined;

const ioapic_t = packed struct {
    reg: u32,
    pad: u96,
    data: u32,

    const Self = @This();

    fn read(self: *Self, reg: u32) u32 {
        self.*.reg = reg;
        return self.*.data;
    }

    fn write(self: *Self, reg: u32, data: u32) void {
        self.*.reg = reg;
        self.*.data = data;
    }
};

pub fn ioapicinit() void {
    ioapic = @as(*ioapic_t, @ptrFromInt(IOAPIC));
    const maxintr = (ioapic.read(REG_VER) >> 16) & 0xff;
    const id = ioapic.read(REG_ID) >> 24;
    if (id != mp.ioapicid) {
        asm volatile ("1: jmp 1b");
    }

    // Mark all interrupts edge-triggered, active high, disabled,
    // and not routed to any CPUs.
    var i: u32 = 0;
    while (i <= maxintr) : (i += 1) {
        ioapic.write(REG_TABLE + 2 * i, INT_DISABLED | (trap.T_IRQ0 + i));
        ioapic.write(REG_TABLE + 2 * i + 1, 0);
    }
}

pub fn ioapicenable(irq: u32, cpunum: u8) void {
    // Mark interrupt edge-triggered, active high,
    // enabled, and routed to the given cpunum,
    // which happens to be that cpu's APIC ID.
    ioapic.write(REG_TABLE + 2 * irq, trap.T_IRQ0 + irq);
    ioapic.write(REG_TABLE + 2 * irq + 1, @as(u32, @intCast(cpunum)) << 24);
}
