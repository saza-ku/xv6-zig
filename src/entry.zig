const std = @import("std");
const mmu = @import("mmu.zig");
const param = @import("param.zig");
const memlayout = @import("memlayout.zig");

comptime {
    _ = @import("main.zig");
}

pub fn panic(msg: []const u8, _: ?*std.builtin.StackTrace, _: ?usize) noreturn {
    // VGA text mode buffer
    const vga = @as([*]volatile u16, @ptrFromInt(0xb8000 + 0x80000000)); // p2v(0xb8000)
    const UART_PORT = 0x3f8;

    // Disable interrupts
    asm volatile ("cli");

    // Clear screen and write panic message directly to VGA
    const color: u16 = 0x4f00; // White on red background
    var i: usize = 0;
    while (i < 80 * 25) : (i += 1) {
        vga[i] = color | ' ';
    }

    // Write panic message
    const panic_msg = "\n*** KERNEL PANIC ***\n";
    i = 0;
    for (panic_msg) |c| {
        vga[i] = color | c;
        i += 1;
        // Also send to UART
        while ((asm volatile ("inb %[port], %[result]"
            : [result] "={al}" (-> u8),
            : [port] "{dx}" (@as(u16, UART_PORT + 5)),
        ) & 0x20) == 0) {}
        asm volatile ("outb %[data], %[port]"
            :
            : [port] "{dx}" (@as(u16, UART_PORT)),
              [data] "{al}" (c),
        );
    }

    // Write error message
    const error_prefix = "Error: ";
    for (error_prefix) |c| {
        vga[i] = color | c;
        i += 1;
        while ((asm volatile ("inb %[port], %[result]"
            : [result] "={al}" (-> u8),
            : [port] "{dx}" (@as(u16, UART_PORT + 5)),
        ) & 0x20) == 0) {}
        asm volatile ("outb %[data], %[port]"
            :
            : [port] "{dx}" (@as(u16, UART_PORT)),
              [data] "{al}" (c),
        );
    }

    for (msg) |c| {
        vga[i] = color | c;
        i += 1;
        while ((asm volatile ("inb %[port], %[result]"
            : [result] "={al}" (-> u8),
            : [port] "{dx}" (@as(u16, UART_PORT + 5)),
        ) & 0x20) == 0) {}
        asm volatile ("outb %[data], %[port]"
            :
            : [port] "{dx}" (@as(u16, UART_PORT)),
              [data] "{al}" (c),
        );
    }

    // Halt
    while (true) {
        asm volatile ("hlt");
    }
}

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
        \\.globl start
        \\.align 16
        \\start:
        \\  # Turn on page size extension for 4Mbyte pages
        \\  movl %cr4, %eax
        \\  orl $0x00000010, %eax
        \\  movl %eax, %cr4
        \\  # Set page directory
        \\  movl $(entrypgdir - 0x80000000), %eax
        \\  movl %eax, %cr3
        \\  # Turn on paging
        \\  movl %cr0, %eax
        \\  orl $0x80010000, %eax
        \\  movl %eax, %cr0
        \\  # Set up the stack pointer
        \\  movl $stack, %eax
        \\  addl $4096, %eax
        \\  movl %eax, %esp
        \\  # Jump to main()
        \\  mov $main, %eax
        \\  jmp *%eax
    );
}
