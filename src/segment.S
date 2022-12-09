.global set_segreg
.type set_segreg, @function
set_segreg:
  movl $0x10, %eax
  movw %ax, %es
  movw %ax, %ss
  movw %ax, %ds
  movw %ax, %fs
  movw %ax, %gs
  movl $0x08, %eax
  movl $.next, %ecx
  pushw %ax
  pushl %ecx
  lret
.next:
  movl %ebp, %esp
  popl %ebp
  ret
