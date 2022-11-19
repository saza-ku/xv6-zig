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

pub fn lcr3(addr: usize) void {
    asm volatile (
        "movl %[addr], %%cr3"
        :
        : [addr] "{eax}" (addr),
    );
}

// Layout of the trap frame built on the stack by the
// hardware and by trapasm.S, and passed to trap().
pub const trapframe = struct {
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
