pub fn memmov(dst: [*]u8, src: [*]const u8, n: usize) void {
    const s = src;
    var d = dst;

    const sAddr = @intFromPtr(s);
    const dAddr = @intFromPtr(d);
    if (sAddr < dAddr and sAddr + n > dAddr) {
        var i = n;
        while (i > 0) : (i -= 1) {
            d[i] = s[i];
        }
    } else {
        var i: usize = 0;
        while (i < n) : (i += 1) {
            d[i] = s[i];
        }
    }
}

pub fn safestrcpy(dst: *[16]u8, src: []const u8) void {
    @memcpy(dst, src[0 .. src.len + 1]);
    dst[15] = 0;
}
