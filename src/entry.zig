const mmu = @import("mmu.zig");
const param = @import("param.zig");

comptime {
    asm (
        \\.align 4
        \\.section ".multiboot"
        \\multiboot_header:
        \\  .long 0x1badb002
        \\  .long 0
        \\  .long (0 - 0x1badb002)
    );
}

comptime {
    asm (
        \\.globl _start
        \\_start = start - 0x80000000
        \\.comm stack, 4096 // KSTACKSIZE
    );
}

export fn start() align(16) callconv(.Naked) noreturn {
    asm volatile (
    // Turn on page size extension for 4Mbyte pages
        \\movl %%cr4, %%eax
        \\orl %[cr4_pse], %%eax
        \\movl %%eax, %%cr4
        :
        : [cr4_pse] "{ecx}" (mmu.CR4_PSE),
    );
    asm volatile (
    // Set page directory
        \\movl $(entrypgdir - 0x80000000), %%eax
        \\movl %%eax, %%cr3
    );
    asm volatile (
    // Turn on paging
        \\movl %%cr0, %%eax
        \\orl %[cr0_bits], %%eax
        \\movl %%eax, %%cr0
        :
        : [cr0_bits] "{ecx}" (mmu.CR0_PG | mmu.CR0_WP),
    );
    asm volatile (
    // Set up the stack pointer
        \\movl $stack, %%eax
        \\addl %[kstacksize], %%eax
        \\movl %%eax, %%esp

        // Jump to main(), and switch to executing at
        // high addresses. The indirect call is needed because
        // the assembler produces a PC-relative instruction
        // for a direct jump.
        \\mov $main, %%eax
        \\jmp *%%eax
        :
        : [kstacksize] "{ecx}" (param.KSTACKSIZE),
    );
    while (true) {}
}



pub fn entry_others() linksection(".text.others") callconv(.Naked) noreturn {
    asm volatile (
        \\  cli

        \\  # Zero data segment registers DS, ES, and SS.
        \\  xorw    %%ax,%%ax
        \\  movw    %%ax,%%ds
        \\  movw    %%ax,%%es
        \\  movw    %%ax,%%ss
        \\
        \\  # Switch from real to protected mode.  Use a bootstrap GDT that makes
        \\  # virtual addresses map directly to physical addresses so that the
        \\  # effective memory map doesn't change during the transition.
        //\\  lgdt    gdtdesc
        \\  movl    %%cr0, %%eax
        \\  orl     %[cr0_pe], %%eax
        \\  movl    %%eax, %%cr0
        \\
        \\  # Complete the transition to 32-bit protected mode by using a long jmp
        \\  # to reload %%cs and %%eip.  The segment descriptors are set up with no
        \\  # translation, so that the mapping is still the identity mapping.
        \\  ljmpl    %[kcode], $0x7000
        \\
        :
        : [cr0_pe] "i" (mmu.CR0_PE),
          [kcode] "i" (mmu.SEG_KCODE << 3),
          [kdata] "i" (mmu.SEG_KDATA << 3),
          [cr4_pse] "i" (mmu.CR4_PSE),
          [cr0] "i" (mmu.CR0_PE | mmu.CR0_PG | mmu.CR0_WP),
          [gdt_size] "i" (@sizeOf(@TypeOf(entry_gdt))),
          //[gdt] "i" (@ptrToInt(&entry_gdt)),
    );

    unreachable;
}

const entry_gdt = [3]mmu.segdesc {
    undefined,
    mmu.segdesc {
        .lim_15_0 = 0,
        .base15_0 = 0xffff,
        .base_23_16 = 0,
        .typ = mmu.STA_X | mmu.STA_R,
        .s = 1,
        .dpl = 0,
        .p = 1,
        .lim_19_16 = 0xf,
        .avl = 0,
        .rsv1 = 0,
        .db = 1,
        .g = 1,
        .base_31_24 = 0,
    },
    mmu.segdesc {
        .lim_15_0 = 0,
        .base15_0 = 0xffff,
        .base_23_16 = 0,
        .typ = mmu.STA_W,
        .s = 1,
        .dpl = 0,
        .p = 1,
        .lim_19_16 = 0xf,
        .avl = 0,
        .rsv1 = 0,
        .db = 1,
        .g = 1,
        .base_31_24 = 0,
    },
};
