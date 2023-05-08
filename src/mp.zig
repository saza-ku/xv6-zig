const lapic = @import("lapic.zig");
const memlayout = @import("memlayout.zig");
const mmu = @import("mmu.zig");
const param = @import("param.zig");
const proc = @import("proc.zig");
const x86 = @import("x86.zig");

pub var cpus: [param.NCPU]proc.cpu = undefined; // TODO: properly initialize
pub var ncpu: u8 = 0;
pub var ioapicid: u8 = 0;

const mp = packed struct {
    signature1: u8 = 0, // "_"
    signature2: u8 = 0, // "M"
    signature3: u8 = 0, // "P"
    signature4: u8 = 0, // "_"
    physaddr: u32 = 0, // phys addr of MP config table
    length: u8 = 0, // 1
    specrev: u8 = 0, // [14]
    checksum: u8 = 0, // all bytes must add up to 0
    typ: u8 = 0, // MP system config type
    imcrp: u8 = 0,
    reserved: u24 = 0,

    const Self = @This();

    fn isValid(self: *Self) bool {
        // check signature
        if (self.signature1 != '_' or
            self.signature2 != 'M' or
            self.signature3 != 'P' or
            self.signature4 != '_')
        {
            return false;
        }

        // checksum
        var bytes = @ptrCast([*]const u8, self)[0..@sizeOf(Self)];
        var sum: u8 = 0;
        for (bytes) |*b| {
            sum = sum +% b.*;
        }

        return sum == 0;
    }
};

const mpconf = packed struct {
    signature1: u8,
    signature2: u8,
    signature3: u8,
    signature4: u8,
    length: u16,
    version: u8,
    checksum: u8,
    product: u160,
    oemtable: *u32,
    oemlength: u16,
    entry: u16,
    lapicaddr: [*]u32,
    xlength: u16,
    xchecksum: u8,
    reserved: u8,

    const Self = @This();

    fn isValid(self: *Self) bool {
        if (self.signature1 != 'P' or
            self.signature2 != 'C' or
            self.signature3 != 'M' or
            self.signature4 != 'P')
        {
            return false;
        }

        if (self.version != 1 and self.version != 4) {
            return false;
        }

        // checksum
        var bytes = @ptrCast([*]const u8, self)[0..self.length];
        var sum: u8 = 0;
        for (bytes) |*b| {
            sum = sum +% b.*;
        }

        return sum == 0;
    }
};

// processor table entry
const mpproc = packed struct {
    typ: entry, // entry type (0)
    apicid: u8, // local APIC id
    version: u8, // local APIC version
    flags: u8, // CPU flags
    signature: u32, // CPU signature
    feature: u32, // feature flags from CPUID instruction
    reserved: u64,
};

// I/O APIC table entry
const mpioapic = packed struct {
    typ: entry, // entry type (2)
    apicno: u8, // I/O APIC id
    version: u8, // I/O APIC version
    flags: u8, // I/O APIC flags
    addr: *u32, // I/O APIC address
};

// Non-exhaustive enum may be better
const entry = enum(u8) {
    MPPROC = 0x00,
    MPBUS = 0x01,
    MPIOAPIC = 0x02,
    MPIOINTR = 0x03,
    MPLINTR = 0x04,
};

// Look for an MP structure in the len bytes at addr
fn mpsearch1(a: usize, len: usize) ?*mp {
    var addr = memlayout.p2v(a);
    var slice = @intToPtr([*]mp, addr)[0 .. len / @sizeOf(mp)];
    for (slice) |*p| {
        if (p.isValid()) {
            return p;
        }
    }

    return null;
}

// Search for the MP Floating Pointer Structure, which according to the
// spec is in one of the following three locations:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
fn mpsearch() ?*mp {
    var bda = @intToPtr([*]u8, memlayout.p2v(0x400));

    var p: usize = ((@intCast(usize, bda[0x0F]) << 8) | @intCast(usize, bda[0x0E])) << 4;
    var result = mpsearch1(p, 1024);
    if (result) |m| {
        return m;
    }

    p = ((@intCast(usize, bda[0x14]) << 8) | @intCast(usize, bda[0x13])) * 1024;
    result = mpsearch1(p - 1024, 1024);
    if (result) |m| {
        return m;
    }

    return mpsearch1(0xF0000, 0x10000);
}

// Search for an MP configuration table.  For now,
// don't accept the default configurations (physaddr == 0).
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
fn mpconfig(p: **mp) ?*mpconf {
    var pmp = mpsearch() orelse return null;
    if (pmp.physaddr == 0) {
        return null;
    }

    var conf = @intToPtr(*mpconf, memlayout.p2v(pmp.physaddr));
    if (!conf.isValid()) {
        return null;
    }

    var ppmp = p;
    ppmp.* = pmp;

    return conf;
}

// TODO: we cannot recognize ap except for qemu on Ubuntu 18.04
pub fn mpinit() void {
    var pmp: *mp = undefined;
    var conf = mpconfig(&pmp) orelse return; // TODO: panic if null

    lapic.lapic = conf.lapicaddr;

    var p = @ptrToInt(conf) + @sizeOf(mpconf);
    const e = @ptrToInt(conf) + conf.length;
    while (p < e) {
        const typ = @intToEnum(entry, @intToPtr(*u8, p).*);
        switch (typ) {
            .MPPROC => {
                var proc_entry = @intToPtr(*mpproc, p);
                if (ncpu < param.NCPU) {
                    cpus[ncpu].apicid = proc_entry.apicid;
                    ncpu += 1;
                }
                p += @sizeOf(mpproc);
            },
            .MPIOAPIC => {
                var ioapic_entry = @intToPtr(*mpioapic, p);
                ioapicid = ioapic_entry.apicno;
                p += @sizeOf(mpioapic);
            },
            .MPBUS, .MPIOINTR, .MPLINTR => {
                p += 8;
            },
        }
    }

    if (pmp.imcrp != 0) {
        // Bochs doesn't support IMCR, so this doesn't run on Bochs.
        // But it would on real hardware.
        x86.out(0x22, @as(u8, 0x70)); // Select IMCR
        x86.out(0x23, x86.in(u8, 0x23) | 1); // Mask external interrupts
    }
}
