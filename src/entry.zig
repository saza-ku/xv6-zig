const mmu = @import("mmu.zig");
const param = @import("param.zig");

const MultibootHeader = packed struct {
    magic: u32, // Must be equal to header magic number.
    flags: u32, // Feature flags.
    checksum: u32, // Above fields plus this one must equal 0 mod 2^32.
};

export const multiboot_header align(4) linksection(".multiboot") = multiboot: {
    const MAGIC: u32 = 0x1BADB002;
    const ALIGN: u32 = 1 << 0;
    const MEMINFO: u32 = 1 << 1;
    const FLAGS: u32 = ALIGN | MEMINFO;

    break :multiboot MultibootHeader{
        .magic = MAGIC,
        .flags = FLAGS,
        .checksum = ~(MAGIC +% FLAGS) +% 1,
    };
};

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
        : [cr4_pse] "ecx" (mmu.CR4_PSE),
    );
    asm volatile(
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
        : [cr0_bits] "ecs" (mmu.CR0_PG | mmu.CR0_WP),
    );
    asm volatile(
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
        : [kstacksize] "ecx" (param.KSTACKSIZE),
    );
    while (true) {}
}
