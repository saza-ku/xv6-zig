// Memoty layout

pub const EXTMEM: usize = 0x100000; // Start of extended memmory
pub const PHYSTOP: usize = 0xE000000; // Top physical memory
pub const DEVSPACE: usize = 0xFE000000; // Other devices are at high addresses

// Key addresses for address space layout (see kemap in vm.zig for layout)
pub const KERNBASE: usize = 0x80000000; // First Kernel virtual address
pub const KERNLINK: usize = KERNBASE + EXTMEM; // Address where kernel is linked

pub fn v2p(v: usize) usize {
    return v - KERNBASE;
}

pub fn p2v(p: usize) usize {
    return p + KERNBASE;
}
