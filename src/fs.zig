// File system implementation.  Five layers:
//   + Blocks: allocator for raw disk blocks.
//   + Log: crash recovery for multi-step updates.
//   + Files: inode allocator, reading, writing, metadata.
//   + Directories: inode with special contents (list of other inodes!)
//   + Names: paths like /usr/rtm/xv6/fs.c for convenient naming.
//
// This file contains the low-level file system manipulation
// routines.  The (higher-level) system call implementations
// are in sysfile.c.

const bio = @import("bio.zig");
const file = @import("file.zig");
const param = @import("param.zig");
const sleeplock = @import("sleeplock.zig");
const spinlock = @import("spinlock.zig");
const util = @import("util.zig");

const inode = file.inode;

pub const BSIZE = 512;

pub const superblock = struct {
    size: u32 = 0, // Size of file system image (blocks)
    nblocks: u32 = 0, // Number of data blocks
    ninodes: u32 = 0, // Number of inodes.
    nlog: u32 = 0, // Number of log blocks
    logstart: u32 = 0, // Block number of first log block
    inodestart: u32 = 0, // Block number of first inode block
    bmapstart: u32 = 0, // Block number of first free map block
};

pub var sb: superblock = undefined;

pub const NDIRECT = 12;
pub const NINDIRECT = (BSIZE / @sizeOf(u32));
pub const MAXFILE = NDIRECT + NINDIRECT;

// On-disk inode structure
const dinode = struct {
    typ: u16, // File type
    major: u16, // Major device number (T_DEV only)
    minor: u16, // Minor device number (T_DEV only)
    nlink: u16, // Number of links to inode in file system
    size: u32, // Size of file (bytes)
    addrs: [NDIRECT + 1]u32,
};

// Inodes per block.
pub const IPB = (BSIZE / @sizeOf(dinode));

// Bitmap bites per block
pub const BPB = BSIZE * 8;

// Directory is a file containing a sequence of dirent structures.
const DIRSIZ = 14;

pub const dirent = struct {
    inum: u16,
    name: [DIRSIZ]u8,
};

// Block containing inode i
pub fn iblock(i: u32, s: superblock) void {
    return i / IPB + s.inodestart;
}

// Block of free map containing bit for block b
pub fn bblock(b: u32, s: *superblock) u32 {
    return b / BPB + s.bmapstart;
}

// Read the super block.
pub fn readsb(dev: u32, s: *superblock) void {
    var bp = bio.buf.read(dev, 1);
    defer bp.release();
    util.memmov(@as([*]u8, @ptrCast(&s)), @as([*]u8, @ptrCast(&bp.data)), @sizeOf(superblock));
}

// Zero a block.
fn bzero(dev: u32, bno: u32) void {
    var bp = bio.buf.read(dev, bno);
    defer bp.release();
    @memset(@as([*]u8, @ptrCast(&bp.data))[0..BSIZE], 0);
    // TODO: log_write();
}

// Blocks.

// Allocate a zeroed disk block
fn balloc(dev: u32) u32 {
    var bp: *bio.buf = undefined;
    var b: u32 = 0;
    while (b < sb.size) : (b += BPB) {
        bp = bio.buf.read(dev, bblock(b, sb));
        var bi: u32 = 0;
        while (bi < BPB and b + bi < sb.size) : (bi += 1) {
            const m: u32 = 1 << (bi % 8);
            if ((bp.data[bi / 8] & m) == 0) { // Is block free?
                bp.*.data[bi / 8] |= m; // Mark block in use.
                // TODO: log_write
                bp.release();
                bzero(dev, b + bi);
                return b + bi;
            }
        }
        bp.release();
    }
    asm volatile ("1: jmp 1b"); // TODO: error handling
}

fn bfree(dev: u32, b: u32) void {
    var bp = bio.buf.read(dev, bblock(b, sb));
    defer bp.release();
    const bi: u32 = b % BPB;
    const m = 1 << (bi % 8);
    if ((bp.data[bi / 8] & m) == 0) {
        asm volatile ("1: jmp 1b"); // TODO: error handling
    }
    bp.*.data[bi / 8] &= ~m;
    // TODO: log_write
}

// Inodes.
//
// An inode describes a single unnamed file.
// The inode disk structure holds metadata: the file's type,
// its size, the number of links referring to it, and the
// list of blocks holding the file's content.
//
// The inodes are laid out sequentially on disk at
// sb.startinode. Each inode has a number, indicating its
// position on the disk.
//
// The kernel keeps a cache of in-use inodes in memory
// to provide a place for synchronizing access
// to inodes used by multiple processes. The cached
// inodes include book-keeping information that is
// not stored on disk: ip->ref and ip->valid.
//
// An inode and its in-memory representation go through a
// sequence of states before they can be used by the
// rest of the file system code.
//
// * Allocation: an inode is allocated if its type (on disk)
//   is non-zero. ialloc() allocates, and iput() frees if
//   the reference and link counts have fallen to zero.
//
// * Referencing in cache: an entry in the inode cache
//   is free if ip->ref is zero. Otherwise ip->ref tracks
//   the number of in-memory pointers to the entry (open
//   files and current directories). iget() finds or
//   creates a cache entry and increments its ref; iput()
//   decrements ref.
//
// * Valid: the information (type, size, &c) in an inode
//   cache entry is only correct when ip->valid is 1.
//   ilock() reads the inode from
//   the disk and sets ip->valid, while iput() clears
//   ip->valid if ip->ref has fallen to zero.
//
// * Locked: file system code may only examine and modify
//   the information in an inode and its content if it
//   has first locked the inode.
//
// Thus a typical sequence is:
//   ip = iget(dev, inum)
//   ilock(ip)
//   ... examine and modify ip->xxx ...
//   iunlock(ip)
//   iput(ip)
//
// ilock() is separate from iget() so that system calls can
// get a long-term reference to an inode (as for an open file)
// and only lock it for short periods (e.g., in read()).
// The separation also helps avoid deadlock and races during
// pathname lookup. iget() increments ip->ref so that the inode
// stays cached and pointers to it remain valid.
//
// Many internal file system functions expect the caller to
// have locked the inodes involved; this lets callers create
// multi-step atomic operations.
//
// The icache.lock spin-lock protects the allocation of icache
// entries. Since ip->ref indicates whether an entry is free,
// and ip->dev and ip->inum indicate which i-node an entry
// holds, one must hold icache.lock while using any of those fields.
//
// An ip->lock sleep-lock protects all ip-> fields other than ref,
// dev, and inum.  One must hold ip->lock in order to
// read or write that inode's ip->valid, ip->size, ip->type, &c.

var icache = struct {
    lock: spinlock.spinlock,
    inode: [param.INODE]inode,
}{
    .lock = spinlock.spinlock.init("icache"),
    .inode = init: {
        const initial_value: [param.INODE]inode = undefined;
        for (initial_value) |*i| {
            i.lock = sleeplock.sleeplock.init("inode");
        }
        break :init initial_value;
    },
};

// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
fn ialloc(dev: u32, typ: u16) *inode {
    var inum: u32 = 1;
    while (inum < sb.ninodes) : (inum += 1) {
        var bp = bio.buf.read(dev, iblock(inum, sb));
        var dip = @as([*]dinode, @ptrCast(&bp.data))[inum % IPB];
        if (dip.typ == 0) { // a free inode
            @memset(@as([*]u8, @ptrCast(&dip))[0..@sizeOf(dinode)], 0);
            dip.typ = typ;
            // TODO: log_write()
            bp.release();
            // TODO: return iget
        }
        bp.release();
    }
    asm volatile ("1: jmp 1b"); // TODO: error handling
}

fn iget(dev: u32, inum: u32) *inode {
    icache.lock.acquire();
    defer icache.lock.release();

    var ip: *inode = undefined;
    for (icache.inode) |*i| {
        if (i.ref > 0 and i.dev == dev and i.inum == inum) {
            i.ref += 1;
            return i;
        }
        if (i.ref == 0) {
            ip = i;
        }
    }

    if (ip == undefined) {
        asm volatile ("1: jmp 1b"); // TODO: error handling
    }

    ip.dev = dev;
    ip.inum = inum;
    ip.ref = 1;
    ip.valid = false;

    return ip;
}
