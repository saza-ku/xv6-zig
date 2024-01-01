pub fn memmov(dst: [*]u8, src: [*]const u8, n: usize) void {
    const s = src;
    var d = dst;
    const sAddr = @intFromPtr(s);
    const dAddr = @intFromPtr(d);
    if (sAddr < dAddr and sAddr + n > dAddr) {
        while (n > 0) : (n -= 1) {
            d[n] = s[n];
        }
    } else {
        var i = 0;
        while (i < n) : (i += 1) {
            d[i] = s[i];
        }
    }
}
