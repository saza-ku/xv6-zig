// Simple PIO-based (non-DMA) IDE driver code.

const bio = @import("bio.zig");
const fs = @import("fs.zig");
const ioapic = @import("ioapic.zig");
const mp = @import("mp.zig");
const param = @import("param.zig");
const proc = @import("proc.zig");
const spinlock = @import("spinlock.zig");
const trap = @import("trap.zig");
const x86 = @import("x86.zig");

const SECTOR_SIZE = 512;
const IDE_BSY = 0x80;
const IDE_DRDY = 0x40;
const IDE_DF = 0x20;
const IDE_ERR = 0x01;

const IDE_CMD_READ = 0x20;
const IDE_CMD_WRITE = 0x30;
const IDE_CMD_RDMUL = 0xc4;
const IDE_CMD_WRMUL = 0xc5;

var idelock = spinlock.spinlock.init("ide");
var idequeue: ?*bio.buf = undefined;

var havedisk1: bool = false;

fn idewait(checkerr: bool) ?void {
    var r: u8 = undefined;
    while (true) {
        r = x86.in(u8, 0x1f7);
        if ((r & (IDE_BSY | IDE_DRDY)) == IDE_DRDY) {
            break;
        }
    }

    if (checkerr and (r & (IDE_DF | IDE_ERR)) != 0) {
        return null;
    }
}

pub fn ideinit() void {
    ioapic.ioapicenable(trap.IRQ_IDE, mp.ncpu);
    idewait(false) orelse unreachable;

    // Check if disk 1 is present
    x86.out(0x1f6, @as(u8, 0xe0 | @as(u8, 1 << 4)));
    var i: u32 = 0;
    while (i < 1000) : (i += 1) {
        if (x86.in(u8, 0x1f7) != 0) {
            havedisk1 = true;
            break;
        }
    }

    // Switch back to disk 0.
    x86.out(0x1f6, @as(u8, 0xe0 | @as(u8, 0 << 4)));
}

// Start request for b. Caller must hold idelock.
fn idestart(b: *bio.buf) void {
    if (b.blockno >= param.FSSIZE) {
        asm volatile ("1: jmp 1b"); // TODO: error handling
    }

    const sector_per_block: u8 = fs.BSIZE / fs.SECTOR_SIZE;
    const sector = b.blockno * sector_per_block;
    const readcmd: u8 = if (sector_per_block == 1) IDE_CMD_READ else IDE_CMD_RDMUL;
    const writecmd: u8 = if (sector_per_block == 1) IDE_CMD_WRITE else IDE_CMD_WRMUL;

    if (sector_per_block > 7) {
        asm volatile ("1: jmp 1b");
    }

    idewait(false) orelse unreachable;
    x86.out(0x3f6, @as(u8, 0)); // generate interrupt
    x86.out(0x1f2, sector_per_block); // number of sectors
    x86.out(0x1f3, @as(u8, sector & 0xff));
    x86.out(0x1f4, @as(u8, (sector >> 8) & 0xff));
    x86.out(0x1f5, @as(u8, (sector >> 16) & 0xff));
    x86.out(0x1f6, @as(u8, 0xe0) | @as(u8, (b.dev & 1) << 4) | @as(u8, (sector >> 24) & 0x0f));
    if (b.flags & bio.B_DIRTY != 0) {
        x86.out(0x1f7, writecmd);
        x86.outsl(0x1f0, @ptrToInt(&b.data), fs.BSIZE / 4);
    } else {
        x86.out(0x1f7, readcmd);
    }
}

pub fn ideintr() void {
    idelock.acquire();
    defer idelock.release();

    const b = idequeue orelse return;
    idequeue = b.qnext;

    // Read data if needed
    if ((b.flags & bio.B_DIRTY) == 0 and idewait(true)) {
        x86.insl(0x1f0, @ptrToInt(&b.data), fs.BSIZE / 4);
    }

    b.*.flags |= bio.B_VALID;
    b.*.flags &= ~bio.B_DIRTY;
    proc.wakeup(@ptrToInt(b));

    if (idequeue != null) {
        idestart(idequeue);
    }
}

pub fn iderw(b_arg: *bio.buf) void {
    var b = b_arg;
    // TODO: error handling
    if (!b.lock.hoding()) {
        asm volatile ("1: jmp 1b");
    }
    if ((b.flags & (bio.B_VALID | bio.B_DIRTY)) == bio.B_VALID) {
        asm volatile ("1: jmp 1b");
    }
    if (b.dev != 0 and !havedisk1) {
        asm volatile ("1: jmp 1b");
    }

    // Append b to idequeue.
    b.qnext = null;
    var pp: **bio.buf = &idequeue;
    while (*pp) {
        pp = &pp.*.*.qnext;
    }

    pp.* = b;

    if (idequeue == b) {
        idestart(b);
    }

    while ((b.flags & (bio.B_VALID | bio.B_DIRTY)) != bio.B_VALID) {
        proc.sleep(@ptrToInt(b), &idelock);
    }
}
