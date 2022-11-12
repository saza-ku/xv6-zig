pub fn lcr3(addr: usize) void {
    asm volatile (
        "movl %[addr], %%cr3"
        :
        : [addr] "{eax}" (addr),
    );
}
