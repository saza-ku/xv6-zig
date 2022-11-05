const console = @import("console.zig");
const memlayout = @import("memlayout.zig");
const mmu = @import("mmu.zig");

export fn main() callconv(.Naked) noreturn {
    console.initialize();
    console.puts("Hello world!");

    while (true) {}
}

// The boot page table used in entry.S and entryother.S.
// Page directories (and page tables) must start on page boundaries,
// hence the __aligned__ attribute.
// PTE_PS in a page directory entry enables 4Mbyte pages.
export var entrypgdir: [mmu.NPDENTRIES]u32 align(mmu.PGSIZE) = init: {
    var dir: [mmu.NPDENTRIES]u32 = undefined;
    // Map VA's [0, 4MB) to PA's [0, 4MB)
    dir[0] = (0) | mmu.PTE_P | mmu.PTE_W | mmu.PTE_PS;
    // Map VA's [KERNBASE, KERNBASE+4MB) to PA's [0, 4MB)
    dir[memlayout.KERNBASE >> mmu.PDXSHIFT] = (0) | mmu.PTE_P | mmu.PTE_W | mmu.PTE_PS;
    break :init dir;
};
