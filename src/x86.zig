pub fn in(comptime Type: type, port: u16) Type {
    return switch (Type) {
        u8 => asm volatile ("inb %[port], %[result]"
            : [result] "={al}" (-> Type),
            : [port] "N{dx}" (port),
        ),
        u16 => asm volatile ("inw %[port], %[result]"
            : [result] "={ax}" (-> Type),
            : [port] "N{dx}" (port),
        ),
        u32 => asm volatile ("inl %[port], %[result]"
            : [result] "={eax}" (-> Type),
            : [port] "N{dx}" (port),
        ),
        else => @compileError("Invalid data type. Only u8, u16 or u32, found: " ++ @typeName(Type)),
    };
}

pub fn insl(port: u16, addr: usize, cnt: u32) void {
    asm volatile ("cld; rep insl"
        : [a] "=D" (addr),
          [b] "=c" (cnt),
        : [c] "d" (port),
          [d] "0" (addr),
          [e] "1" (cnt),
        : "memory", "cc"
    );
}

pub fn out(port: u16, data: anytype) void {
    switch (@TypeOf(data)) {
        u8 => asm volatile ("outb %[data], %[port]"
            :
            : [port] "{dx}" (port),
              [data] "{al}" (data),
        ),
        u16 => asm volatile ("outw %[data], %[port]"
            :
            : [port] "{dx}" (port),
              [data] "{ax}" (data),
        ),
        u32 => asm volatile ("outl %[data], %[port]"
            :
            : [port] "{dx}" (port),
              [data] "{eax}" (data),
        ),
        else => @compileError("Invalid data type. Only u8, u16 or u32, found: " ++ @typeName(@TypeOf(data))),
    }
}

pub fn outsl(port: u16, addr: usize, cnt: u32) void {
    asm volatile ("cld; rep outsl"
        : [a] "=S" (addr),
          [b] "=c" (cnt),
        : [c] "d" (port),
          [d] "0" (addr),
          [f] "1" (cnt),
        : "cc"
    );
}

pub fn lgdt(p: usize, size: u16) void {
    const pd = [3]u16{
        size - 1, @as(u16, @intCast(p & 0xffff)), @as(u16, @intCast(p >> 16)),
    };

    asm volatile ("lgdt (%%eax)"
        :
        : [pd] "{eax}" (@intFromPtr(&pd)),
    );
}

pub fn lidt(p: usize, size: u16) void {
    const pd = [3]u16{
        size - 1,
        @as(u16, @intCast(p & 0xffff)),
        @as(u16, @intCast(p >> 16)),
    };

    asm volatile ("lidt (%%eax)"
        :
        : [pd] "{eax}" (@intFromPtr(&pd)),
    );
}

pub fn lcr3(addr: usize) void {
    asm volatile ("movl %[addr], %%cr3"
        :
        : [addr] "{eax}" (addr),
    );
}

pub fn ltr(sel: u16) void {
    asm volatile ("ltr %[sel]"
        :
        : [sel] "r" (sel),
    );
}

pub fn readeflags() u32 {
    return asm volatile ("pushfl; popl %[eflags]"
        : [eflags] "={eax}" (-> u32),
    );
}

pub fn cli() void {
    asm volatile ("cli");
}

pub fn sti() void {
    asm volatile ("sti");
}

pub fn xchg(addr: *u32, newval: u32) u32 {
    return asm volatile ("lock; xchgl (%[addr]), %[newval]"
        : [result] "={eax}" (-> u32),
        : [addr] "r" (addr),
          [newval] "{eax}" (newval),
        : "memory"
    );
}

// Layout of the trap frame built on the stack by the
// hardware and by trapasm.S, and passed to trap().
pub const trapframe = packed struct {
    edi: u32,
    esi: u32,
    ebp: u32,
    oesp: u32, // useless & ignored
    ebx: u32,
    edx: u32,
    ecx: u32,
    eax: u32,

    // rest of trap frame
    gs: u16,
    padding1: u16,
    fs: u16,
    padding2: u16,
    es: u16,
    padding3: u16,
    ds: u16,
    padding4: u16,
    trapno: u32,

    // below here defined by x86 hardware
    err: u32,
    eip: u32,
    cs: u16,
    padding5: u16,
    eflags: u32,

    // below here only when crossing rings, such as from user to kernel
    esp: u32,
    ss: u16,
    padding6: u16,
};
