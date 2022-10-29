const console = @import("console.zig");

const MultibootHeader = packed struct {
    magic: u32, // Must be equal to header magic number.
    flags: u32, // Feature flags.
    checksum: u32, // Above fields plus this one must equal 0 mod 2^32.
};

export const multiboot_header align(4) linksection(".multiboot") = multiboot: {
    const MAGIC: u32 = 0x1BADB002;
    const ALIGN: u32 = 1 << 0;
    const MEMINFO: u32 = 1 << 1;
    const FLAGS: u32 = ALIGN | MEMINFO;

    break :multiboot MultibootHeader{
        .magic = MAGIC,
        .flags = FLAGS,
        .checksum = ~(MAGIC +% FLAGS) +% 1,
    };
};

export var stack_bytes: [16 * 1024]u8 align(16) linksection(".bss") = undefined;
const stack_bytes_slice = stack_bytes[0..];

export fn _start() callconv(.Naked) noreturn {
    @call(.{ .stack = stack_bytes_slice }, kmain, .{});

    while (true) {}
}

fn kmain() void {
    console.initialize();
    console.puts("Hello world!");
}
