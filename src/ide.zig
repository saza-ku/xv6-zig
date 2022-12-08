// Simple PIO-based (non-DMA) IDE driver code.

const bio = @import("bio.zig");
const ioapic = @import("ioapic.zig");
const mp = @import("mp.zig");
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
var idequeue = bio.buf;

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
    idewait(false) orelse return;

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
