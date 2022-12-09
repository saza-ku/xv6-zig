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

comptime {
    asm (
        \\.code16
        \\.global entry_others;
        \\.type entry_others, @function;
        \\entry_others:
        \\  cli
        \\  jmp spin
        \\
        \\spin:
        \\  jmp     spin
        \\
        \\.p2align 2
        //\\gdt:
        //\\  SEG_NULLASM
        //\\  SEG_ASM(STA_X|STA_R, 0, 0xffffffff)
        //\\  SEG_ASM(STA_W, 0, 0xffffffff)
        //\\
        //\\
        //\\gdtdesc:
        //\\  .word   (gdtdesc - gdt - 1)
        //\\  .long   gdt

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

pub extern fn entry_others() callconv(.Naked) noreturn;
