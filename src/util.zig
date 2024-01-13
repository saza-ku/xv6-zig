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
    const len = @min(src.len, dst.len - 1);
    @memcpy(dst[0..len], src[0..len]);
    dst[len + 1] = 0;
}
