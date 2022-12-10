.section ".text.others"
start_hoge:
  cli
  xorw    %ax,%ax
  movw    %ax,%ds
  movw    %ax,%es
  movw    %ax,%ss
  lgdt    gdtdesc
  movl    %cr0, %eax
  orl     $1, %eax
  movl    %eax, %cr0
  ljmpl   $8, $(start32)
.code32
start32:
  jmp spin
spin:
  jmp     spin

.section ".rodata.others"
.p2align 2
gdt:
  .word 0, 0
  .byte 0, 0, 0, 0
  .word 0xffff, 0
  .byte 0, 0x9a, 0xcf, 0
  .word 0xffff, 0
  .byte 0, 0x92, 0xcf, 0


gdtdesc:
  .word   (gdtdesc - gdt - 1)
  .long   gdt
