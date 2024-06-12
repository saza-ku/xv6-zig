#!/bin/bash

mkdir -p zig-out/bin
zig cc -c -target x86-freestanding-eabi -o zig-out/bin/initcode.o src/initcode.S
ld.lld -m elf_i386 -N -e start -Ttext 0 -o zig-out/bin/initcode.out zig-out/bin/initcode.o
llvm-objcopy -S -Obinary zig-out/bin/initcode.out zig-out/bin/initcode
llvm-objcopy -Ibinary -Oelf32-i386 zig-out/bin/initcode zig-out/bin/initcode.o
