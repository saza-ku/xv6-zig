// This file contains definitions for the
// x86 memory management unit (MMU).

// Control Register flags
pub const CR0_PE: usize = 0x00000001; // Protection Enable
pub const CR0_WP: usize = 0x00010000; // Write Protect
pub const CR0_PG: usize = 0x80000000; // Paging

pub const CR4_PSE: usize = 0x00000010; // Page size extension

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
