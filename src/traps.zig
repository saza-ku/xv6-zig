// x86 trap and interrupt constants.

// Processor-defined
pub const T_DIVIDE = 0;
pub const T_DEBUG = 1;
pub const T_NMI = 2;
pub const T_BRKPT = 3;
pub const T_OFLOW = 4;
pub const T_BOUND = 5;
pub const T_ILLOP = 6;
pub const T_DEVICE = 7;
pub const T_DBLFLT = 8;
pub const T_TSS = 10;
pub const T_SEGNP = 11;
pub const T_STACK = 12;
pub const T_GPFLT = 13;
pub const T_PGFLT = 14;
pub const T_FPERR = 16;
pub const T_ALIGN = 17;
pub const T_MCHK = 18;
pub const T_SIMDERR = 19;
pub const T_SYSCALL = 64;
pub const T_DEFAULT = 500;
pub const T_IRQ0 = 32;
pub const IRQ_TIMER = 0;
pub const IRQ_KBD = 1;
pub const IRQ_COM1 = 4;
pub const IRQ_IDE = 14;
pub const IRQ_ERROR = 19;
pub const IRQ_SPURIOUS = 31;
