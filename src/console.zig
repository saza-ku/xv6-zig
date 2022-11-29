const std = @import("std");
const ioapic = @import("ioapic.zig");
const file = @import("file.zig");
const proc = @import("proc.zig");
const spinlock = @import("spinlock.zig");
const traps = @import("traps.zig");
const uart = @import("uart.zig");
const x86 = @import("x86.zig");
const fmt = @import("std").fmt;
const mem = @import("std").mem;
const Writer = @import("std").io.Writer;
const memlayout = @import("memlayout.zig");

var panicked: bool = false;

pub var cons = struct {
    lock: spinlock.spinlock,
    locking: bool,
} {
    .lock = spinlock.spinlock.init("console"),
    .locking = false,
};

const BACKSPACE = std.ascii.control_code.BS;
const CRTPORT = 0x3d4;
var crt = @intToPtr([*]u16, memlayout.p2v(0xb8000)); // CGA memory

fn cgaputc(c: u32) void {
    x86.out(CRTPORT, @as(u8, 14));
    var pos = @intCast(u16, x86.in(u8, CRTPORT + 1)) << 8;
    x86.out(CRTPORT, @as(u8, 15));
    pos |= @intCast(u16, x86.in(u8, CRTPORT + 1));

    if (c == '\n') {
        pos += 80 - pos % 80;
    } else if (c == BACKSPACE) {
        if (pos > 0) {
            pos -= 1;
        }
    } else {
        pos += 1;
        crt[pos] = (@intCast(u16, c & 0xff)) | 0x0700; // black on white
    }

    if (pos < 0 or pos > 25 * 80) {
        asm volatile ("1: jmp 1b"); // TODO: handle error
    }

    if (pos / 80 >= 24) { // Scroll up.
        for (crt[80..24 * 80]) |b, i| {
            crt[i] = b;
        }
        pos -= 80;
        for (crt[pos..pos + 24 * 80 - pos]) |*b| {
            b.* = 0;
        }
    }

    x86.out(CRTPORT, @as(u8, 14));
    x86.out(CRTPORT+1,@intCast(u8, pos >> 8));
    x86.out(CRTPORT, @as(u8, 15));
    x86.out(CRTPORT+1,@intCast(u8, pos & 0xff));
    crt[pos] = ' ' | 0x0700;
}

fn consputc(c: u8) void {
    if (panicked) {
        x86.cli();
        while(true) {}
    }

    if (c == BACKSPACE) {
        uart.putc(BACKSPACE);
        uart.putc(' ');
        uart.putc(BACKSPACE);
    } else {
        uart.putc(@intCast(u8, c & 0xff));
    }
    cgaputc(c);
}

const INPUT_BUF = 128;
var input = struct {
    buf: [INPUT_BUF]u8,
    r: usize, // Read index
    w: usize, // Write index
    e: usize, // Edit index
} {
    .buf = undefined,
    .r = 0,
    .w = 0,
    .e = 0,
};

fn ctrl(x: u8) u8 {
    return x - '@';
}

pub fn consoleread(ip: *file.inode, dst: [*]u8, n: u32) ?u32 {
    var read_size: u32 = 0;
    ip.unlock();
    cons.lock.acquire();
    defer {
        ip.lock();
        cons.lock.release();
    }

    while (read_size < n) {
        while (input.r == input.w) {
            if (proc.myproc().killed) {
                return null;
            }
            proc.sleep(@ptrToInt(&input.r), &cons.lock);
        }
        input.r = (input.r + 1) % INPUT_BUF;
        const c = input.buf[input.r];
        if (c == ctrl('D')) {
            if (read_size > 0) {
                // Save ^D for next time, to make sure
                // caller gets a 0-byte result.
                input.r = (input.r - 1 + INPUT_BUF) % INPUT_BUF;
            }
            break;
        }
        dst[read_size] = c;
        read_size += 1;
        if (c == '\n') {
            break;
        }
    }
    return read_size;
}

pub fn consoleinit() void {
    cons.locking = true;

    ioapic.ioapicenable(traps.IRQ_KBD, 0);
}

pub fn consolewrite(ip: *file.inode, buf: []const u8, n: u32) u32 {
    ip.unlock();
    cons.lock.acquire();

    var i: u32 = 0;
    while (i < n) : (i += 1) {
        consputc(buf[i]);
    }
    cons.lock.release();
    ip.lock();

    return n;
}

const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;
const VGA_SIZE = VGA_WIDTH * VGA_HEIGHT;

pub const ConsoleColors = enum(u8) {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGray = 7,
    DarkGray = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    LightBrown = 14,
    White = 15,
};

var row: usize = 0;
var column: usize = 0;
var color = vgaEntryColor(ConsoleColors.LightGray, ConsoleColors.Black);
var buffer = @intToPtr([*]u16, memlayout.p2v(0xB8000));

fn vgaEntryColor(fg: ConsoleColors, bg: ConsoleColors) u8 {
    return @enumToInt(fg) | (@enumToInt(bg) << 4);
}

fn vgaEntry(uc: u8, new_color: u8) u16 {
    var c: u16 = new_color;

    return uc | (c << 8);
}

pub fn initialize() void {
    clear();
}

pub fn setColor(new_color: u8) void {
    color = new_color;
}

pub fn clear() void {
    mem.set(u16, buffer[0..VGA_SIZE], vgaEntry(' ', color));
}

pub fn putCharAt(c: u8, new_color: u8, x: usize, y: usize) void {
    const index = y * VGA_WIDTH + x;
    buffer[index] = vgaEntry(c, new_color);
}

pub fn putChar(c: u8) void {
    putCharAt(c, color, column, row);
    column += 1;
    if (column == VGA_WIDTH) {
        column = 0;
        row += 1;
        if (row == VGA_HEIGHT)
            row = 0;
    }
}

pub fn puts(data: []const u8) void {
    for (data) |c| {
        putChar(c);}
}

pub const writer = Writer(void, error{}, callback){ .context = {} };

fn callback(_: void, string: []const u8) error{}!usize {
    puts(string);
    return string.len;
}

pub fn printf(comptime format: []const u8, args: anytype) void {
    var buf: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(buf[0..1024]);
    const allocator = fba.allocator();
    const s = fmt.allocPrint(allocator, format, args) catch "error";
    puts(s);
}
