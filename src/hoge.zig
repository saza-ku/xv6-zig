pub const __builtin_bswap16 = @import("std").zig.c_builtins.__builtin_bswap16;
pub const __builtin_bswap32 = @import("std").zig.c_builtins.__builtin_bswap32;
pub const __builtin_bswap64 = @import("std").zig.c_builtins.__builtin_bswap64;
pub const __builtin_signbit = @import("std").zig.c_builtins.__builtin_signbit;
pub const __builtin_signbitf = @import("std").zig.c_builtins.__builtin_signbitf;
pub const __builtin_popcount = @import("std").zig.c_builtins.__builtin_popcount;
pub const __builtin_ctz = @import("std").zig.c_builtins.__builtin_ctz;
pub const __builtin_clz = @import("std").zig.c_builtins.__builtin_clz;
pub const __builtin_sqrt = @import("std").zig.c_builtins.__builtin_sqrt;
pub const __builtin_sqrtf = @import("std").zig.c_builtins.__builtin_sqrtf;
pub const __builtin_sin = @import("std").zig.c_builtins.__builtin_sin;
pub const __builtin_sinf = @import("std").zig.c_builtins.__builtin_sinf;
pub const __builtin_cos = @import("std").zig.c_builtins.__builtin_cos;
pub const __builtin_cosf = @import("std").zig.c_builtins.__builtin_cosf;
pub const __builtin_exp = @import("std").zig.c_builtins.__builtin_exp;
pub const __builtin_expf = @import("std").zig.c_builtins.__builtin_expf;
pub const __builtin_exp2 = @import("std").zig.c_builtins.__builtin_exp2;
pub const __builtin_exp2f = @import("std").zig.c_builtins.__builtin_exp2f;
pub const __builtin_log = @import("std").zig.c_builtins.__builtin_log;
pub const __builtin_logf = @import("std").zig.c_builtins.__builtin_logf;
pub const __builtin_log2 = @import("std").zig.c_builtins.__builtin_log2;
pub const __builtin_log2f = @import("std").zig.c_builtins.__builtin_log2f;
pub const __builtin_log10 = @import("std").zig.c_builtins.__builtin_log10;
pub const __builtin_log10f = @import("std").zig.c_builtins.__builtin_log10f;
pub const __builtin_abs = @import("std").zig.c_builtins.__builtin_abs;
pub const __builtin_fabs = @import("std").zig.c_builtins.__builtin_fabs;
pub const __builtin_fabsf = @import("std").zig.c_builtins.__builtin_fabsf;
pub const __builtin_floor = @import("std").zig.c_builtins.__builtin_floor;
pub const __builtin_floorf = @import("std").zig.c_builtins.__builtin_floorf;
pub const __builtin_ceil = @import("std").zig.c_builtins.__builtin_ceil;
pub const __builtin_ceilf = @import("std").zig.c_builtins.__builtin_ceilf;
pub const __builtin_trunc = @import("std").zig.c_builtins.__builtin_trunc;
pub const __builtin_truncf = @import("std").zig.c_builtins.__builtin_truncf;
pub const __builtin_round = @import("std").zig.c_builtins.__builtin_round;
pub const __builtin_roundf = @import("std").zig.c_builtins.__builtin_roundf;
pub const __builtin_strlen = @import("std").zig.c_builtins.__builtin_strlen;
pub const __builtin_strcmp = @import("std").zig.c_builtins.__builtin_strcmp;
pub const __builtin_object_size = @import("std").zig.c_builtins.__builtin_object_size;
pub const __builtin___memset_chk = @import("std").zig.c_builtins.__builtin___memset_chk;
pub const __builtin_memset = @import("std").zig.c_builtins.__builtin_memset;
pub const __builtin___memcpy_chk = @import("std").zig.c_builtins.__builtin___memcpy_chk;
pub const __builtin_memcpy = @import("std").zig.c_builtins.__builtin_memcpy;
pub const __builtin_expect = @import("std").zig.c_builtins.__builtin_expect;
pub const __builtin_nanf = @import("std").zig.c_builtins.__builtin_nanf;
pub const __builtin_huge_valf = @import("std").zig.c_builtins.__builtin_huge_valf;
pub const __builtin_inff = @import("std").zig.c_builtins.__builtin_inff;
pub const __builtin_isnan = @import("std").zig.c_builtins.__builtin_isnan;
pub const __builtin_isinf = @import("std").zig.c_builtins.__builtin_isinf;
pub const __builtin_isinf_sign = @import("std").zig.c_builtins.__builtin_isinf_sign;
pub const __has_builtin = @import("std").zig.c_builtins.__has_builtin;
pub const __builtin_assume = @import("std").zig.c_builtins.__builtin_assume;
pub const __builtin_unreachable = @import("std").zig.c_builtins.__builtin_unreachable;
pub const __builtin_constant_p = @import("std").zig.c_builtins.__builtin_constant_p;
pub const __builtin_mul_overflow = @import("std").zig.c_builtins.__builtin_mul_overflow;
pub const uint = c_uint;
pub const ushort = c_ushort;
pub const uchar = u8;
pub const pde_t = uint;
pub const struct_buf = opaque {};
pub const struct_context = opaque {};
pub const FD_NONE: c_int = 0;
pub const FD_PIPE: c_int = 1;
pub const FD_INODE: c_int = 2;
const enum_unnamed_1 = c_uint;
pub const struct_pipe = opaque {};
pub const struct_cpu = opaque {};
pub const struct_spinlock = extern struct {
    locked: uint,
    name: [*c]u8,
    cpu: ?*struct_cpu,
    pcs: [10]uint,
};
pub const struct_sleeplock = extern struct {
    locked: uint,
    lk: struct_spinlock,
    name: [*c]u8,
    pid: c_int,
};
pub const struct_inode = extern struct {
    dev: uint,
    inum: uint,
    ref: c_int,
    lock: struct_sleeplock,
    valid: c_int,
    type: c_short,
    major: c_short,
    minor: c_short,
    nlink: c_short,
    size: uint,
    addrs: [13]uint,
};
pub const struct_file = extern struct {
    type: enum_unnamed_1,
    ref: c_int,
    readable: u8,
    writable: u8,
    pipe: ?*struct_pipe,
    ip: [*c]struct_inode,
    off: uint,
};
pub const struct_proc = opaque {};
pub const struct_rtcdate = opaque {};
pub const struct_stat = opaque {};
pub const struct_superblock = extern struct {
    size: uint,
    nblocks: uint,
    ninodes: uint,
    nlog: uint,
    logstart: uint,
    inodestart: uint,
    bmapstart: uint,
};
pub extern fn binit() void;
pub extern fn bread(uint, uint) ?*struct_buf;
pub extern fn brelse(?*struct_buf) void;
pub extern fn bwrite(?*struct_buf) void;
pub extern fn consoleinit() void;
pub extern fn cprintf([*c]u8, ...) void;
pub extern fn consoleintr(?*const fn () callconv(.C) c_int) void;
pub extern fn panic([*c]u8) noreturn;
pub extern fn exec([*c]u8, [*c][*c]u8) c_int;
pub export fn filealloc() [*c]struct_file {
    var f: [*c]struct_file = undefined;
    acquire(&ftable.lock);
    {
        f = @ptrCast([*c]struct_file, @alignCast(@import("std").meta.alignment([*c]struct_file), &ftable.file));
        while (f < (@ptrCast([*c]struct_file, @alignCast(@import("std").meta.alignment([*c]struct_file), &ftable.file)) + @bitCast(usize, @intCast(isize, @as(c_int, 100))))) : (f += 1) {
            if (f.*.ref == @as(c_int, 0)) {
                f.*.ref = 1;
                release(&ftable.lock);
                return f;
            }
        }
    }
    release(&ftable.lock);
    return null;
}
pub export fn fileclose(arg_f: [*c]struct_file) void {
    var f = arg_f;
    var ff: struct_file = undefined;
    acquire(&ftable.lock);
    if (f.*.ref < @as(c_int, 1)) {
        panic(@intToPtr([*c]u8, @ptrToInt("fileclose")));
    }
    if ((blk: {
        const ref = &f.*.ref;
        ref.* -= 1;
        break :blk ref.*;
    }) > @as(c_int, 0)) {
        release(&ftable.lock);
        return;
    }
    ff = f.*;
    f.*.ref = 0;
    f.*.type = @bitCast(c_uint, FD_NONE);
    release(&ftable.lock);
    if (ff.type == @bitCast(c_uint, FD_PIPE)) {
        pipeclose(ff.pipe, @bitCast(c_int, @as(c_uint, ff.writable)));
    } else if (ff.type == @bitCast(c_uint, FD_INODE)) {
        begin_op();
        iput(ff.ip);
        end_op();
    }
}
pub export fn filedup(arg_f: [*c]struct_file) [*c]struct_file {
    var f = arg_f;
    acquire(&ftable.lock);
    if (f.*.ref < @as(c_int, 1)) {
        panic(@intToPtr([*c]u8, @ptrToInt("filedup")));
    }
    f.*.ref += 1;
    release(&ftable.lock);
    return f;
}
pub export fn fileinit() void {
    initlock(&ftable.lock, @intToPtr([*c]u8, @ptrToInt("ftable")));
}
pub export fn fileread(arg_f: [*c]struct_file, arg_addr: [*c]u8, arg_n: c_int) c_int {
    var f = arg_f;
    var addr = arg_addr;
    var n = arg_n;
    var r: c_int = undefined;
    if (@bitCast(c_int, @as(c_uint, f.*.readable)) == @as(c_int, 0)) return -@as(c_int, 1);
    if (f.*.type == @bitCast(c_uint, FD_PIPE)) return piperead(f.*.pipe, addr, n);
    if (f.*.type == @bitCast(c_uint, FD_INODE)) {
        ilock(f.*.ip);
        if ((blk: {
            const tmp = readi(f.*.ip, addr, f.*.off, @bitCast(uint, n));
            r = tmp;
            break :blk tmp;
        }) > @as(c_int, 0)) {
            f.*.off +%= @bitCast(c_uint, r);
        }
        iunlock(f.*.ip);
        return r;
    }
    panic(@intToPtr([*c]u8, @ptrToInt("fileread")));
    return 0;
}
pub export fn filestat(arg_f: [*c]struct_file, arg_st: ?*struct_stat) c_int {
    var f = arg_f;
    var st = arg_st;
    if (f.*.type == @bitCast(c_uint, FD_INODE)) {
        ilock(f.*.ip);
        stati(f.*.ip, st);
        iunlock(f.*.ip);
        return 0;
    }
    return -@as(c_int, 1);
}
pub export fn filewrite(arg_f: [*c]struct_file, arg_addr: [*c]u8, arg_n: c_int) c_int {
    var f = arg_f;
    var addr = arg_addr;
    var n = arg_n;
    var r: c_int = undefined;
    if (@bitCast(c_int, @as(c_uint, f.*.writable)) == @as(c_int, 0)) return -@as(c_int, 1);
    if (f.*.type == @bitCast(c_uint, FD_PIPE)) return pipewrite(f.*.pipe, addr, n);
    if (f.*.type == @bitCast(c_uint, FD_INODE)) {
        var max: c_int = @divTrunc(((@as(c_int, 10) - @as(c_int, 1)) - @as(c_int, 1)) - @as(c_int, 2), @as(c_int, 2)) * @as(c_int, 512);
        var i: c_int = 0;
        while (i < n) {
            var n1: c_int = n - i;
            if (n1 > max) {
                n1 = max;
            }
            begin_op();
            ilock(f.*.ip);
            if ((blk: {
                const tmp = writei(f.*.ip, addr + @bitCast(usize, @intCast(isize, i)), f.*.off, @bitCast(uint, n1));
                r = tmp;
                break :blk tmp;
            }) > @as(c_int, 0)) {
                f.*.off +%= @bitCast(c_uint, r);
            }
            iunlock(f.*.ip);
            end_op();
            if (r < @as(c_int, 0)) break;
            if (r != n1) {
                panic(@intToPtr([*c]u8, @ptrToInt("short filewrite")));
            }
            i += r;
        }
        return if (i == n) n else -@as(c_int, 1);
    }
    panic(@intToPtr([*c]u8, @ptrToInt("filewrite")));
    return 0;
}
pub extern fn readsb(dev: c_int, sb: [*c]struct_superblock) void;
pub extern fn dirlink([*c]struct_inode, [*c]u8, uint) c_int;
pub extern fn dirlookup([*c]struct_inode, [*c]u8, [*c]uint) [*c]struct_inode;
pub extern fn ialloc(uint, c_short) [*c]struct_inode;
pub extern fn idup([*c]struct_inode) [*c]struct_inode;
pub extern fn iinit(dev: c_int) void;
pub extern fn ilock([*c]struct_inode) void;
pub extern fn iput([*c]struct_inode) void;
pub extern fn iunlock([*c]struct_inode) void;
pub extern fn iunlockput([*c]struct_inode) void;
pub extern fn iupdate([*c]struct_inode) void;
pub extern fn namecmp([*c]const u8, [*c]const u8) c_int;
pub extern fn namei([*c]u8) [*c]struct_inode;
pub extern fn nameiparent([*c]u8, [*c]u8) [*c]struct_inode;
pub extern fn readi([*c]struct_inode, [*c]u8, uint, uint) c_int;
pub extern fn stati([*c]struct_inode, ?*struct_stat) void;
pub extern fn writei([*c]struct_inode, [*c]u8, uint, uint) c_int;
pub extern fn ideinit() void;
pub extern fn ideintr() void;
pub extern fn iderw(?*struct_buf) void;
pub extern fn ioapicenable(irq: c_int, cpu: c_int) void;
pub extern var ioapicid: uchar;
pub extern fn ioapicinit() void;
pub extern fn kalloc() [*c]u8;
pub extern fn kfree([*c]u8) void;
pub extern fn kinit1(?*anyopaque, ?*anyopaque) void;
pub extern fn kinit2(?*anyopaque, ?*anyopaque) void;
pub extern fn kbdintr() void;
pub extern fn cmostime(r: ?*struct_rtcdate) void;
pub extern fn lapicid() c_int;
pub extern var lapic: [*c]volatile uint;
pub extern fn lapiceoi() void;
pub extern fn lapicinit() void;
pub extern fn lapicstartap(uchar, uint) void;
pub extern fn microdelay(c_int) void;
pub extern fn initlog(dev: c_int) void;
pub extern fn log_write(?*struct_buf) void;
pub extern fn begin_op(...) void;
pub extern fn end_op(...) void;
pub extern var ismp: c_int;
pub extern fn mpinit() void;
pub extern fn picenable(c_int) void;
pub extern fn picinit() void;
pub extern fn pipealloc([*c][*c]struct_file, [*c][*c]struct_file) c_int;
pub extern fn pipeclose(?*struct_pipe, c_int) void;
pub extern fn piperead(?*struct_pipe, [*c]u8, c_int) c_int;
pub extern fn pipewrite(?*struct_pipe, [*c]u8, c_int) c_int;
pub extern fn cpuid() c_int;
pub extern fn exit() noreturn;
pub extern fn fork() c_int;
pub extern fn growproc(c_int) c_int;
pub extern fn kill(c_int) c_int;
pub extern fn mycpu() ?*struct_cpu;
pub extern fn myproc(...) ?*struct_proc;
pub extern fn pinit() void;
pub extern fn procdump() void;
pub extern fn scheduler() noreturn;
pub extern fn sched() void;
pub extern fn setproc(?*struct_proc) void;
pub extern fn sleep(?*anyopaque, [*c]struct_spinlock) void;
pub extern fn userinit() void;
pub extern fn wait() c_int;
pub extern fn wakeup(?*anyopaque) void;
pub extern fn yield() void;
pub extern fn swtch([*c]?*struct_context, ?*struct_context) void;
pub extern fn acquire([*c]struct_spinlock) void;
pub extern fn getcallerpcs(?*anyopaque, [*c]uint) void;
pub extern fn holding([*c]struct_spinlock) c_int;
pub extern fn initlock([*c]struct_spinlock, [*c]u8) void;
pub extern fn release([*c]struct_spinlock) void;
pub extern fn pushcli() void;
pub extern fn popcli() void;
pub extern fn acquiresleep([*c]struct_sleeplock) void;
pub extern fn releasesleep([*c]struct_sleeplock) void;
pub extern fn holdingsleep([*c]struct_sleeplock) c_int;
pub extern fn initsleeplock([*c]struct_sleeplock, [*c]u8) void;
pub extern fn memcmp(?*const anyopaque, ?*const anyopaque, uint) c_int;
pub extern fn memmove(?*anyopaque, ?*const anyopaque, uint) ?*anyopaque;
pub extern fn memset(?*anyopaque, c_int, uint) ?*anyopaque;
pub extern fn safestrcpy([*c]u8, [*c]const u8, c_int) [*c]u8;
pub extern fn strlen([*c]const u8) c_int;
pub extern fn strncmp([*c]const u8, [*c]const u8, uint) c_int;
pub extern fn strncpy([*c]u8, [*c]const u8, c_int) [*c]u8;
pub extern fn argint(c_int, [*c]c_int) c_int;
pub extern fn argptr(c_int, [*c][*c]u8, c_int) c_int;
pub extern fn argstr(c_int, [*c][*c]u8) c_int;
pub extern fn fetchint(uint, [*c]c_int) c_int;
pub extern fn fetchstr(uint, [*c][*c]u8) c_int;
pub extern fn syscall() void;
pub extern fn timerinit() void;
pub extern fn idtinit() void;
pub extern var ticks: uint;
pub extern fn tvinit() void;
pub extern var tickslock: struct_spinlock;
pub extern fn uartinit() void;
pub extern fn uartintr() void;
pub extern fn uartputc(c_int) void;
pub extern fn seginit() void;
pub extern fn kvmalloc() void;
pub extern fn setupkvm() [*c]pde_t;
pub extern fn uva2ka([*c]pde_t, [*c]u8) [*c]u8;
pub extern fn allocuvm([*c]pde_t, uint, uint) c_int;
pub extern fn deallocuvm([*c]pde_t, uint, uint) c_int;
pub extern fn freevm([*c]pde_t) void;
pub extern fn inituvm([*c]pde_t, [*c]u8, uint) void;
pub extern fn loaduvm([*c]pde_t, [*c]u8, [*c]struct_inode, uint, uint) c_int;
pub extern fn copyuvm([*c]pde_t, uint) [*c]pde_t;
pub extern fn switchuvm(?*struct_proc) void;
pub extern fn switchkvm() void;
pub extern fn copyout([*c]pde_t, uint, ?*anyopaque, uint) c_int;
pub extern fn clearpteu(pgdir: [*c]pde_t, uva: [*c]u8) void;
pub const struct_dinode = extern struct {
    type: c_short,
    major: c_short,
    minor: c_short,
    nlink: c_short,
    size: uint,
    addrs: [13]uint,
};
pub const struct_dirent = extern struct {
    inum: ushort,
    name: [14]u8,
};
pub const struct_devsw = extern struct {
    read: ?*const fn ([*c]struct_inode, [*c]u8, c_int) callconv(.C) c_int,
    write: ?*const fn ([*c]struct_inode, [*c]u8, c_int) callconv(.C) c_int,
};
pub extern var devsw: [*c]struct_devsw;
const struct_unnamed_2 = extern struct {
    lock: struct_spinlock,
    file: [100]struct_file,
};
pub export var ftable: struct_unnamed_2 = @import("std").mem.zeroes(struct_unnamed_2);
pub const __INTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `L`"); // (no file):80:9
pub const __UINTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `UL`"); // (no file):86:9
pub const __FLT16_DENORM_MIN__ = @compileError("unable to translate C expr: unexpected token 'IntegerLiteral'"); // (no file):109:9
pub const __FLT16_EPSILON__ = @compileError("unable to translate C expr: unexpected token 'IntegerLiteral'"); // (no file):113:9
pub const __FLT16_MAX__ = @compileError("unable to translate C expr: unexpected token 'IntegerLiteral'"); // (no file):119:9
pub const __FLT16_MIN__ = @compileError("unable to translate C expr: unexpected token 'IntegerLiteral'"); // (no file):122:9
pub const __INT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `L`"); // (no file):183:9
pub const __UINT32_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `U`"); // (no file):205:9
pub const __UINT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `UL`"); // (no file):213:9
pub const __seg_gs = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // (no file):343:9
pub const __seg_fs = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // (no file):344:9
pub const NELEM = @compileError("unable to translate C expr: unexpected token '('"); // ../xv6-public/defs.h:190:9
pub const __llvm__ = @as(c_int, 1);
pub const __clang__ = @as(c_int, 1);
pub const __clang_major__ = @as(c_int, 15);
pub const __clang_minor__ = @as(c_int, 0);
pub const __clang_patchlevel__ = @as(c_int, 3);
pub const __clang_version__ = "15.0.3 (git@github.com:ziglang/zig-bootstrap.git 0ce789d0f7a4d89fdc4d9571209b6874d3e260c9)";
pub const __GNUC__ = @as(c_int, 4);
pub const __GNUC_MINOR__ = @as(c_int, 2);
pub const __GNUC_PATCHLEVEL__ = @as(c_int, 1);
pub const __GXX_ABI_VERSION = @as(c_int, 1002);
pub const __ATOMIC_RELAXED = @as(c_int, 0);
pub const __ATOMIC_CONSUME = @as(c_int, 1);
pub const __ATOMIC_ACQUIRE = @as(c_int, 2);
pub const __ATOMIC_RELEASE = @as(c_int, 3);
pub const __ATOMIC_ACQ_REL = @as(c_int, 4);
pub const __ATOMIC_SEQ_CST = @as(c_int, 5);
pub const __OPENCL_MEMORY_SCOPE_WORK_ITEM = @as(c_int, 0);
pub const __OPENCL_MEMORY_SCOPE_WORK_GROUP = @as(c_int, 1);
pub const __OPENCL_MEMORY_SCOPE_DEVICE = @as(c_int, 2);
pub const __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES = @as(c_int, 3);
pub const __OPENCL_MEMORY_SCOPE_SUB_GROUP = @as(c_int, 4);
pub const __PRAGMA_REDEFINE_EXTNAME = @as(c_int, 1);
pub const __VERSION__ = "Clang 15.0.3 (git@github.com:ziglang/zig-bootstrap.git 0ce789d0f7a4d89fdc4d9571209b6874d3e260c9)";
pub const __OBJC_BOOL_IS_BOOL = @as(c_int, 0);
pub const __CONSTANT_CFSTRINGS__ = @as(c_int, 1);
pub const __clang_literal_encoding__ = "UTF-8";
pub const __clang_wide_literal_encoding__ = "UTF-32";
pub const __ORDER_LITTLE_ENDIAN__ = @as(c_int, 1234);
pub const __ORDER_BIG_ENDIAN__ = @as(c_int, 4321);
pub const __ORDER_PDP_ENDIAN__ = @as(c_int, 3412);
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub const __LITTLE_ENDIAN__ = @as(c_int, 1);
pub const _LP64 = @as(c_int, 1);
pub const __LP64__ = @as(c_int, 1);
pub const __CHAR_BIT__ = @as(c_int, 8);
pub const __BOOL_WIDTH__ = @as(c_int, 8);
pub const __SHRT_WIDTH__ = @as(c_int, 16);
pub const __INT_WIDTH__ = @as(c_int, 32);
pub const __LONG_WIDTH__ = @as(c_int, 64);
pub const __LLONG_WIDTH__ = @as(c_int, 64);
pub const __BITINT_MAXWIDTH__ = @as(c_int, 128);
pub const __SCHAR_MAX__ = @as(c_int, 127);
pub const __SHRT_MAX__ = @as(c_int, 32767);
pub const __INT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __LONG_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __WCHAR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __WCHAR_WIDTH__ = @as(c_int, 32);
pub const __WINT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __WINT_WIDTH__ = @as(c_int, 32);
pub const __INTMAX_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INTMAX_WIDTH__ = @as(c_int, 64);
pub const __SIZE_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __SIZE_WIDTH__ = @as(c_int, 64);
pub const __UINTMAX_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINTMAX_WIDTH__ = @as(c_int, 64);
pub const __PTRDIFF_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __PTRDIFF_WIDTH__ = @as(c_int, 64);
pub const __INTPTR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INTPTR_WIDTH__ = @as(c_int, 64);
pub const __UINTPTR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINTPTR_WIDTH__ = @as(c_int, 64);
pub const __SIZEOF_DOUBLE__ = @as(c_int, 8);
pub const __SIZEOF_FLOAT__ = @as(c_int, 4);
pub const __SIZEOF_INT__ = @as(c_int, 4);
pub const __SIZEOF_LONG__ = @as(c_int, 8);
pub const __SIZEOF_LONG_DOUBLE__ = @as(c_int, 16);
pub const __SIZEOF_LONG_LONG__ = @as(c_int, 8);
pub const __SIZEOF_POINTER__ = @as(c_int, 8);
pub const __SIZEOF_SHORT__ = @as(c_int, 2);
pub const __SIZEOF_PTRDIFF_T__ = @as(c_int, 8);
pub const __SIZEOF_SIZE_T__ = @as(c_int, 8);
pub const __SIZEOF_WCHAR_T__ = @as(c_int, 4);
pub const __SIZEOF_WINT_T__ = @as(c_int, 4);
pub const __SIZEOF_INT128__ = @as(c_int, 16);
pub const __INTMAX_TYPE__ = c_long;
pub const __INTMAX_FMTd__ = "ld";
pub const __INTMAX_FMTi__ = "li";
pub const __UINTMAX_TYPE__ = c_ulong;
pub const __UINTMAX_FMTo__ = "lo";
pub const __UINTMAX_FMTu__ = "lu";
pub const __UINTMAX_FMTx__ = "lx";
pub const __UINTMAX_FMTX__ = "lX";
pub const __PTRDIFF_TYPE__ = c_long;
pub const __PTRDIFF_FMTd__ = "ld";
pub const __PTRDIFF_FMTi__ = "li";
pub const __INTPTR_TYPE__ = c_long;
pub const __INTPTR_FMTd__ = "ld";
pub const __INTPTR_FMTi__ = "li";
pub const __SIZE_TYPE__ = c_ulong;
pub const __SIZE_FMTo__ = "lo";
pub const __SIZE_FMTu__ = "lu";
pub const __SIZE_FMTx__ = "lx";
pub const __SIZE_FMTX__ = "lX";
pub const __WCHAR_TYPE__ = c_int;
pub const __WINT_TYPE__ = c_uint;
pub const __SIG_ATOMIC_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __SIG_ATOMIC_WIDTH__ = @as(c_int, 32);
pub const __CHAR16_TYPE__ = c_ushort;
pub const __CHAR32_TYPE__ = c_uint;
pub const __UINTPTR_TYPE__ = c_ulong;
pub const __UINTPTR_FMTo__ = "lo";
pub const __UINTPTR_FMTu__ = "lu";
pub const __UINTPTR_FMTx__ = "lx";
pub const __UINTPTR_FMTX__ = "lX";
pub const __FLT16_HAS_DENORM__ = @as(c_int, 1);
pub const __FLT16_DIG__ = @as(c_int, 3);
pub const __FLT16_DECIMAL_DIG__ = @as(c_int, 5);
pub const __FLT16_HAS_INFINITY__ = @as(c_int, 1);
pub const __FLT16_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __FLT16_MANT_DIG__ = @as(c_int, 11);
pub const __FLT16_MAX_10_EXP__ = @as(c_int, 4);
pub const __FLT16_MAX_EXP__ = @as(c_int, 16);
pub const __FLT16_MIN_10_EXP__ = -@as(c_int, 4);
pub const __FLT16_MIN_EXP__ = -@as(c_int, 13);
pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
pub const __FLT_HAS_DENORM__ = @as(c_int, 1);
pub const __FLT_DIG__ = @as(c_int, 6);
pub const __FLT_DECIMAL_DIG__ = @as(c_int, 9);
pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
pub const __FLT_HAS_INFINITY__ = @as(c_int, 1);
pub const __FLT_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __FLT_MANT_DIG__ = @as(c_int, 24);
pub const __FLT_MAX_10_EXP__ = @as(c_int, 38);
pub const __FLT_MAX_EXP__ = @as(c_int, 128);
pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
pub const __FLT_MIN_10_EXP__ = -@as(c_int, 37);
pub const __FLT_MIN_EXP__ = -@as(c_int, 125);
pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
pub const __DBL_DENORM_MIN__ = 4.9406564584124654e-324;
pub const __DBL_HAS_DENORM__ = @as(c_int, 1);
pub const __DBL_DIG__ = @as(c_int, 15);
pub const __DBL_DECIMAL_DIG__ = @as(c_int, 17);
pub const __DBL_EPSILON__ = 2.2204460492503131e-16;
pub const __DBL_HAS_INFINITY__ = @as(c_int, 1);
pub const __DBL_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __DBL_MANT_DIG__ = @as(c_int, 53);
pub const __DBL_MAX_10_EXP__ = @as(c_int, 308);
pub const __DBL_MAX_EXP__ = @as(c_int, 1024);
pub const __DBL_MAX__ = 1.7976931348623157e+308;
pub const __DBL_MIN_10_EXP__ = -@as(c_int, 307);
pub const __DBL_MIN_EXP__ = -@as(c_int, 1021);
pub const __DBL_MIN__ = 2.2250738585072014e-308;
pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 3.64519953188247460253e-4951);
pub const __LDBL_HAS_DENORM__ = @as(c_int, 1);
pub const __LDBL_DIG__ = @as(c_int, 18);
pub const __LDBL_DECIMAL_DIG__ = @as(c_int, 21);
pub const __LDBL_EPSILON__ = @as(c_longdouble, 1.08420217248550443401e-19);
pub const __LDBL_HAS_INFINITY__ = @as(c_int, 1);
pub const __LDBL_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __LDBL_MANT_DIG__ = @as(c_int, 64);
pub const __LDBL_MAX_10_EXP__ = @as(c_int, 4932);
pub const __LDBL_MAX_EXP__ = @as(c_int, 16384);
pub const __LDBL_MAX__ = @as(c_longdouble, 1.18973149535723176502e+4932);
pub const __LDBL_MIN_10_EXP__ = -@as(c_int, 4931);
pub const __LDBL_MIN_EXP__ = -@as(c_int, 16381);
pub const __LDBL_MIN__ = @as(c_longdouble, 3.36210314311209350626e-4932);
pub const __POINTER_WIDTH__ = @as(c_int, 64);
pub const __BIGGEST_ALIGNMENT__ = @as(c_int, 16);
pub const __WINT_UNSIGNED__ = @as(c_int, 1);
pub const __INT8_TYPE__ = i8;
pub const __INT8_FMTd__ = "hhd";
pub const __INT8_FMTi__ = "hhi";
pub const __INT8_C_SUFFIX__ = "";
pub const __INT16_TYPE__ = c_short;
pub const __INT16_FMTd__ = "hd";
pub const __INT16_FMTi__ = "hi";
pub const __INT16_C_SUFFIX__ = "";
pub const __INT32_TYPE__ = c_int;
pub const __INT32_FMTd__ = "d";
pub const __INT32_FMTi__ = "i";
pub const __INT32_C_SUFFIX__ = "";
pub const __INT64_TYPE__ = c_long;
pub const __INT64_FMTd__ = "ld";
pub const __INT64_FMTi__ = "li";
pub const __UINT8_TYPE__ = u8;
pub const __UINT8_FMTo__ = "hho";
pub const __UINT8_FMTu__ = "hhu";
pub const __UINT8_FMTx__ = "hhx";
pub const __UINT8_FMTX__ = "hhX";
pub const __UINT8_C_SUFFIX__ = "";
pub const __UINT8_MAX__ = @as(c_int, 255);
pub const __INT8_MAX__ = @as(c_int, 127);
pub const __UINT16_TYPE__ = c_ushort;
pub const __UINT16_FMTo__ = "ho";
pub const __UINT16_FMTu__ = "hu";
pub const __UINT16_FMTx__ = "hx";
pub const __UINT16_FMTX__ = "hX";
pub const __UINT16_C_SUFFIX__ = "";
pub const __UINT16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __INT16_MAX__ = @as(c_int, 32767);
pub const __UINT32_TYPE__ = c_uint;
pub const __UINT32_FMTo__ = "o";
pub const __UINT32_FMTu__ = "u";
pub const __UINT32_FMTx__ = "x";
pub const __UINT32_FMTX__ = "X";
pub const __UINT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __INT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __UINT64_TYPE__ = c_ulong;
pub const __UINT64_FMTo__ = "lo";
pub const __UINT64_FMTu__ = "lu";
pub const __UINT64_FMTx__ = "lx";
pub const __UINT64_FMTX__ = "lX";
pub const __UINT64_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __INT64_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_LEAST8_TYPE__ = i8;
pub const __INT_LEAST8_MAX__ = @as(c_int, 127);
pub const __INT_LEAST8_WIDTH__ = @as(c_int, 8);
pub const __INT_LEAST8_FMTd__ = "hhd";
pub const __INT_LEAST8_FMTi__ = "hhi";
pub const __UINT_LEAST8_TYPE__ = u8;
pub const __UINT_LEAST8_MAX__ = @as(c_int, 255);
pub const __UINT_LEAST8_FMTo__ = "hho";
pub const __UINT_LEAST8_FMTu__ = "hhu";
pub const __UINT_LEAST8_FMTx__ = "hhx";
pub const __UINT_LEAST8_FMTX__ = "hhX";
pub const __INT_LEAST16_TYPE__ = c_short;
pub const __INT_LEAST16_MAX__ = @as(c_int, 32767);
pub const __INT_LEAST16_WIDTH__ = @as(c_int, 16);
pub const __INT_LEAST16_FMTd__ = "hd";
pub const __INT_LEAST16_FMTi__ = "hi";
pub const __UINT_LEAST16_TYPE__ = c_ushort;
pub const __UINT_LEAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __UINT_LEAST16_FMTo__ = "ho";
pub const __UINT_LEAST16_FMTu__ = "hu";
pub const __UINT_LEAST16_FMTx__ = "hx";
pub const __UINT_LEAST16_FMTX__ = "hX";
pub const __INT_LEAST32_TYPE__ = c_int;
pub const __INT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_LEAST32_WIDTH__ = @as(c_int, 32);
pub const __INT_LEAST32_FMTd__ = "d";
pub const __INT_LEAST32_FMTi__ = "i";
pub const __UINT_LEAST32_TYPE__ = c_uint;
pub const __UINT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __UINT_LEAST32_FMTo__ = "o";
pub const __UINT_LEAST32_FMTu__ = "u";
pub const __UINT_LEAST32_FMTx__ = "x";
pub const __UINT_LEAST32_FMTX__ = "X";
pub const __INT_LEAST64_TYPE__ = c_long;
pub const __INT_LEAST64_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_LEAST64_WIDTH__ = @as(c_int, 64);
pub const __INT_LEAST64_FMTd__ = "ld";
pub const __INT_LEAST64_FMTi__ = "li";
pub const __UINT_LEAST64_TYPE__ = c_ulong;
pub const __UINT_LEAST64_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINT_LEAST64_FMTo__ = "lo";
pub const __UINT_LEAST64_FMTu__ = "lu";
pub const __UINT_LEAST64_FMTx__ = "lx";
pub const __UINT_LEAST64_FMTX__ = "lX";
pub const __INT_FAST8_TYPE__ = i8;
pub const __INT_FAST8_MAX__ = @as(c_int, 127);
pub const __INT_FAST8_WIDTH__ = @as(c_int, 8);
pub const __INT_FAST8_FMTd__ = "hhd";
pub const __INT_FAST8_FMTi__ = "hhi";
pub const __UINT_FAST8_TYPE__ = u8;
pub const __UINT_FAST8_MAX__ = @as(c_int, 255);
pub const __UINT_FAST8_FMTo__ = "hho";
pub const __UINT_FAST8_FMTu__ = "hhu";
pub const __UINT_FAST8_FMTx__ = "hhx";
pub const __UINT_FAST8_FMTX__ = "hhX";
pub const __INT_FAST16_TYPE__ = c_short;
pub const __INT_FAST16_MAX__ = @as(c_int, 32767);
pub const __INT_FAST16_WIDTH__ = @as(c_int, 16);
pub const __INT_FAST16_FMTd__ = "hd";
pub const __INT_FAST16_FMTi__ = "hi";
pub const __UINT_FAST16_TYPE__ = c_ushort;
pub const __UINT_FAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __UINT_FAST16_FMTo__ = "ho";
pub const __UINT_FAST16_FMTu__ = "hu";
pub const __UINT_FAST16_FMTx__ = "hx";
pub const __UINT_FAST16_FMTX__ = "hX";
pub const __INT_FAST32_TYPE__ = c_int;
pub const __INT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_FAST32_WIDTH__ = @as(c_int, 32);
pub const __INT_FAST32_FMTd__ = "d";
pub const __INT_FAST32_FMTi__ = "i";
pub const __UINT_FAST32_TYPE__ = c_uint;
pub const __UINT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __UINT_FAST32_FMTo__ = "o";
pub const __UINT_FAST32_FMTu__ = "u";
pub const __UINT_FAST32_FMTx__ = "x";
pub const __UINT_FAST32_FMTX__ = "X";
pub const __INT_FAST64_TYPE__ = c_long;
pub const __INT_FAST64_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_FAST64_WIDTH__ = @as(c_int, 64);
pub const __INT_FAST64_FMTd__ = "ld";
pub const __INT_FAST64_FMTi__ = "li";
pub const __UINT_FAST64_TYPE__ = c_ulong;
pub const __UINT_FAST64_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINT_FAST64_FMTo__ = "lo";
pub const __UINT_FAST64_FMTu__ = "lu";
pub const __UINT_FAST64_FMTx__ = "lx";
pub const __UINT_FAST64_FMTX__ = "lX";
pub const __USER_LABEL_PREFIX__ = "";
pub const __FINITE_MATH_ONLY__ = @as(c_int, 0);
pub const __GNUC_STDC_INLINE__ = @as(c_int, 1);
pub const __GCC_ATOMIC_TEST_AND_SET_TRUEVAL = @as(c_int, 1);
pub const __CLANG_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
pub const __NO_INLINE__ = @as(c_int, 1);
pub const __PIC__ = @as(c_int, 2);
pub const __pic__ = @as(c_int, 2);
pub const __PIE__ = @as(c_int, 2);
pub const __pie__ = @as(c_int, 2);
pub const __FLT_RADIX__ = @as(c_int, 2);
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const __GCC_ASM_FLAG_OUTPUTS__ = @as(c_int, 1);
pub const __code_model_small__ = @as(c_int, 1);
pub const __amd64__ = @as(c_int, 1);
pub const __amd64 = @as(c_int, 1);
pub const __x86_64 = @as(c_int, 1);
pub const __x86_64__ = @as(c_int, 1);
pub const __SEG_GS = @as(c_int, 1);
pub const __SEG_FS = @as(c_int, 1);
pub const __k8 = @as(c_int, 1);
pub const __k8__ = @as(c_int, 1);
pub const __tune_k8__ = @as(c_int, 1);
pub const __REGISTER_PREFIX__ = "";
pub const __NO_MATH_INLINES = @as(c_int, 1);
pub const __AES__ = @as(c_int, 1);
pub const __VAES__ = @as(c_int, 1);
pub const __PCLMUL__ = @as(c_int, 1);
pub const __VPCLMULQDQ__ = @as(c_int, 1);
pub const __LAHF_SAHF__ = @as(c_int, 1);
pub const __LZCNT__ = @as(c_int, 1);
pub const __RDRND__ = @as(c_int, 1);
pub const __FSGSBASE__ = @as(c_int, 1);
pub const __BMI__ = @as(c_int, 1);
pub const __BMI2__ = @as(c_int, 1);
pub const __POPCNT__ = @as(c_int, 1);
pub const __PRFCHW__ = @as(c_int, 1);
pub const __RDSEED__ = @as(c_int, 1);
pub const __ADX__ = @as(c_int, 1);
pub const __MOVBE__ = @as(c_int, 1);
pub const __FMA__ = @as(c_int, 1);
pub const __F16C__ = @as(c_int, 1);
pub const __GFNI__ = @as(c_int, 1);
pub const __AVX512CD__ = @as(c_int, 1);
pub const __AVX512VPOPCNTDQ__ = @as(c_int, 1);
pub const __AVX512VNNI__ = @as(c_int, 1);
pub const __AVX512DQ__ = @as(c_int, 1);
pub const __AVX512BITALG__ = @as(c_int, 1);
pub const __AVX512BW__ = @as(c_int, 1);
pub const __AVX512VL__ = @as(c_int, 1);
pub const __AVX512VBMI__ = @as(c_int, 1);
pub const __AVX512VBMI2__ = @as(c_int, 1);
pub const __AVX512IFMA__ = @as(c_int, 1);
pub const __SHA__ = @as(c_int, 1);
pub const __FXSR__ = @as(c_int, 1);
pub const __XSAVE__ = @as(c_int, 1);
pub const __XSAVEOPT__ = @as(c_int, 1);
pub const __XSAVEC__ = @as(c_int, 1);
pub const __XSAVES__ = @as(c_int, 1);
pub const __PKU__ = @as(c_int, 1);
pub const __CLFLUSHOPT__ = @as(c_int, 1);
pub const __RDPID__ = @as(c_int, 1);
pub const __INVPCID__ = @as(c_int, 1);
pub const __AVX512F__ = @as(c_int, 1);
pub const __AVX2__ = @as(c_int, 1);
pub const __AVX__ = @as(c_int, 1);
pub const __SSE4_2__ = @as(c_int, 1);
pub const __SSE4_1__ = @as(c_int, 1);
pub const __SSSE3__ = @as(c_int, 1);
pub const __SSE3__ = @as(c_int, 1);
pub const __SSE2__ = @as(c_int, 1);
pub const __SSE2_MATH__ = @as(c_int, 1);
pub const __SSE__ = @as(c_int, 1);
pub const __SSE_MATH__ = @as(c_int, 1);
pub const __MMX__ = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_16 = @as(c_int, 1);
pub const __SIZEOF_FLOAT128__ = @as(c_int, 16);
pub const unix = @as(c_int, 1);
pub const __unix = @as(c_int, 1);
pub const __unix__ = @as(c_int, 1);
pub const linux = @as(c_int, 1);
pub const __linux = @as(c_int, 1);
pub const __linux__ = @as(c_int, 1);
pub const __ELF__ = @as(c_int, 1);
pub const __gnu_linux__ = @as(c_int, 1);
pub const __FLOAT128__ = @as(c_int, 1);
pub const __STDC__ = @as(c_int, 1);
pub const __STDC_HOSTED__ = @as(c_int, 1);
pub const __STDC_VERSION__ = @as(c_long, 201710);
pub const __STDC_UTF_16__ = @as(c_int, 1);
pub const __STDC_UTF_32__ = @as(c_int, 1);
pub const _DEBUG = @as(c_int, 1);
pub const __GCC_HAVE_DWARF2_CFI_ASM = @as(c_int, 1);
pub const NPROC = @as(c_int, 64);
pub const KSTACKSIZE = @as(c_int, 4096);
pub const NCPU = @as(c_int, 8);
pub const NOFILE = @as(c_int, 16);
pub const NFILE = @as(c_int, 100);
pub const NINODE = @as(c_int, 50);
pub const NDEV = @as(c_int, 10);
pub const ROOTDEV = @as(c_int, 1);
pub const MAXARG = @as(c_int, 32);
pub const MAXOPBLOCKS = @as(c_int, 10);
pub const LOGSIZE = MAXOPBLOCKS * @as(c_int, 3);
pub const NBUF = MAXOPBLOCKS * @as(c_int, 3);
pub const FSSIZE = @as(c_int, 1000);
pub const ROOTINO = @as(c_int, 1);
pub const BSIZE = @as(c_int, 512);
pub const NDIRECT = @as(c_int, 12);
pub const NINDIRECT = @import("std").zig.c_translation.MacroArithmetic.div(BSIZE, @import("std").zig.c_translation.sizeof(uint));
pub const MAXFILE = NDIRECT + NINDIRECT;
pub const IPB = @import("std").zig.c_translation.MacroArithmetic.div(BSIZE, @import("std").zig.c_translation.sizeof(struct_dinode));
pub inline fn IBLOCK(i: anytype, sb: anytype) @TypeOf(@import("std").zig.c_translation.MacroArithmetic.div(i, IPB) + sb.inodestart) {
    return @import("std").zig.c_translation.MacroArithmetic.div(i, IPB) + sb.inodestart;
}
pub const BPB = BSIZE * @as(c_int, 8);
pub inline fn BBLOCK(b: anytype, sb: anytype) @TypeOf(@import("std").zig.c_translation.MacroArithmetic.div(b, BPB) + sb.bmapstart) {
    return @import("std").zig.c_translation.MacroArithmetic.div(b, BPB) + sb.bmapstart;
}
pub const DIRSIZ = @as(c_int, 14);
pub const CONSOLE = @as(c_int, 1);
pub const buf = struct_buf;
pub const context = struct_context;
pub const pipe = struct_pipe;
pub const cpu = struct_cpu;
pub const spinlock = struct_spinlock;
pub const sleeplock = struct_sleeplock;
pub const inode = struct_inode;
pub const file = struct_file;
pub const proc = struct_proc;
pub const rtcdate = struct_rtcdate;
pub const stat = struct_stat;
pub const superblock = struct_superblock;
pub const dinode = struct_dinode;
pub const dirent = struct_dirent;
