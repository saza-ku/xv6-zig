const std = @import("std");
const console = @import("console.zig");
const ioapic = @import("ioapic.zig");
const kalloc = @import("kalloc.zig");
const lapic = @import("lapic.zig");
const memlayout = @import("memlayout.zig");
const mmu = @import("mmu.zig");
const mp = @import("mp.zig");
const picirq = @import("picirq.zig");
const spinlock = @import("spinlock.zig");
const trap = @import("trap.zig");
const uart = @import("uart.zig");
const vm = @import("vm.zig");
const x86 = @import("x86.zig");

extern const end: u8;

export fn main() callconv(.Naked) noreturn {
    const end_addr = @ptrToInt(&end);
    kalloc.kinit1(end_addr, memlayout.p2v(4 * 1024 * 1024));

    //vm.kvmalloc() orelse asm volatile ("1: jmp 1b");
    //mp.mpinit();
    //lapic.lapicinit();
    //vm.seginit();
    //picirq.picinit();
    //ioapic.ioapicinit();
    //console.consoleinit();
//
    //uart.uartinit();
    trap.tvinit();
    trap.idtinit();

    console.initialize();

    //locktest();

    console.printf("Hello, {x}", .{ end_addr } );

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


fn locktest() void {
    var l = spinlock.spinlock.init("hoge");

    l.acquire();
    l.release();
    l.acquire();
    l.release();
    l.acquire();
    l.release();
}
