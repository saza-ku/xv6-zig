const console = @import("console.zig");

pub fn panic(s: []const u8) noreturn {
    console.puts(s);
    while (true) {}
}
