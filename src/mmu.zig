// This file contains definitions for the
// x86 memory management unit (MMU).

// Eflags register
pub const FL_IF = 0x00000200; // Interrupt Enable

// Control Register flags
pub const CR0_PE: usize = 0x00000001; // Protection Enable
pub const CR0_WP: usize = 0x00010000; // Write Protect
pub const CR0_PG: usize = 0x80000000; // Paging

pub const CR4_PSE: usize = 0x00000010; // Page size extension

// various segment selectors.
pub const SEG_KCODE: u8 = 1; // kernel code
pub const SEG_KDATA: u8 = 2; // kernel data+stack
pub const SEG_UCODE = 3; // user code
pub const SEG_UDATA = 4; // user data+stack
pub const SEG_TSS = 5; // this process's task state

// cpu->gdt[NSEGS] holds the above segments.
pub const NSEGS = 6;

// Segment Descriptor
pub const segdesc = packed struct {
    lim_15_0: u16, // Low bits of segment limit
    base15_0: u16, // Low bits of segment base address
    base_23_16: u8, // Middle bits of segment base address
    typ: u4, // Segment type (see STS_ constants)
    s: u1, // 0 = system, 1 = application
    dpl: u2, // Descriptor Privilege Level
    p: u1, // Present
    lim_19_16: u4, // High bits of segment limit
    avl: u1, // Unused (available for software use)
    rsv1: u1, // Reserved
    db: u1, // 0 = 16-bit segment, 1 = 32-bit segment
    g: u1, // Granularity: limit scaled by 4K when set
    base_31_24: u8, // High bits of segment base address

    const Self = @This();

    pub fn new(typ: u4, base: u32, lim: u32, dpl: u2) Self {
        return Self{
            .lim_15_0 = @intCast(u16, (lim >> 12) & 0xffff),
            .base15_0 = @intCast(u16, base & 0xffff),
            .base_23_16 = @intCast(u8, (base >> 16) & 0xff),
            .typ = typ,
            .s = 1,
            .dpl = dpl,
            .p = 1,
            .lim_19_16 = @intCast(u4, (lim >> 28)),
            .avl = 0,
            .rsv1 = 0,
            .db = 1,
            .g = 1,
            .base_31_24 = @intCast(u8, base >> 24),
        };
    }
};

pub const DPL_KERNEL = 0x0; // Kernel DPL
pub const DPL_USER = 0x3; // User DPL

// Application segment type bits
pub const STA_X: u4 = 0x8; // Executable segment
pub const STA_W: u4 = 0x2; // Writeable (non-executable segments)
pub const STA_R: u4 = 0x2; // Readable (executable segments)

// System segment type bits
pub const STS_T32A = 0x9; // Available 32-bit TSS
pub const STS_IG32 = 0xE; // 32-bit Interrupt Gate
pub const STS_TG32 = 0xF; // 32-bit Trap Gate

// A virtual address 'la' has a three-part structure as follows:
//
// +--------10------+-------10-------+---------12----------+
// | Page Directory |   Page Table   | Offset within Page  |
// |      Index     |      Index     |                     |
// +----------------+----------------+---------------------+
//  \--- PDX(va) --/ \--- PTX(va) --/

// page directory index
pub fn pdx(va: usize) usize {
    return (va >> PDXSHIFT) & 0x3FF;
}

// page table index
pub fn ptx(va: usize) usize {
    return (va >> PTXSHIFT) & 0x3FF;
}

// Page directory and page table pub constants.
pub const NPDENTRIES = 1024; // # directory entries per page directory
pub const NPTENTRIES = 1024; // # PTEs per page table
pub const PGSIZE: usize = 4096; // bytes mapped by a page

pub const PTXSHIFT = 12; // offset of PTX in a linear address
pub const PDXSHIFT = 22; // offset of PDX in a linear address

pub fn pgroundup(sz: usize) usize {
    return ((sz) + PGSIZE - 1) & ~(PGSIZE - 1);
}

pub fn pgrounddown(sz: usize) usize {
    return (sz) & ~(PGSIZE - 1);
}

// Address in page table or page directory entry
pub fn pteAddr(pte: usize) usize {
    return pte & ~@as(usize, 0xFFF);
}

pub fn pteFlags(pte: usize) usize {
    return pte & @as(usize, 0xFFF);
}

// Page table/directory entry flags.
pub const PTE_P = 0x001; // Present
pub const PTE_W = 0x002; // Writeable
pub const PTE_U = 0x004; // User
pub const PTE_PS = 0x080; // Page Size

pub const pte_t = usize;
pub const pde_t = usize;

pub const taskstate = struct {
    link: u32, // Old ts selector
    esp0: u32, // Stack pointers and segment selectors
    ss0: u16, // after an increase in privilege level
    padding1: u16,
    // TODO
};

pub const gatedesc = packed struct {
    off_15_0: u16, // low 16 bits of offset in segment
    cs: u16, // code segment selector
    args: u5, // # args, 0 for interrupt/trap gates
    rsv1: u3, // reserved (should be zero I guess)
    typ: u4, // type (STS_{IG32, TG32})
    s: u1, // must be 0 (system)
    dpl: u2, // descriptor (meaning new) privilege level
    p: u1, // Present
    off_31_16: u16, // high bits of offset in segment

    const Self = @This();

    pub fn new(isTrap: bool, sel: u16, off: u32, d: u2) Self {
        return Self{
            .off_15_0 = @intCast(u16, off & 0xffff),
            .cs = sel,
            .args = 0,
            .rsv1 = 0,
            .typ = if (isTrap) STS_TG32 else STS_IG32,
            .s = 0,
            .dpl = d,
            .p = 1,
            .off_31_16 = @intCast(u16, off >> 16),
        };
    }
};
