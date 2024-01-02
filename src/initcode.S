# Initial process execs /init.
# This code runs in user space.


# exec(init, argv)
.globl start
start:
  pushl $argv
  pushl $init
  pushl $0  // where caller pc would be
  movl $7, %eax // SYS_exec = 7
  int $64 // T_SYSCALL = 64

# for(;;) exit();
exit:
  movl $2, %eax // SYS_exit = 2
  int $64 // T_SYSCALL = 64
  jmp exit

# char init[] = "/init\0";
init:
  .string "/init\0"

# char *argv[] = { init, 0 };
.p2align 2
argv:
  .long init
  .long 0

