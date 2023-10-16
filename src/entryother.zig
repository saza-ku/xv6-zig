export fn start() callconv(.Naked) noreturn {
    asm volatile (
        \\.code16
        \\jmp start
    );
}
