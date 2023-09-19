const std = @import("std");
const mmu = @import("mmu.zig");
const spinlock = @import("spinlock.zig");

extern const end: *u8;

pub const run = struct {
    next: ?*run,
};

pub var kmem = struct {
    lock: spinlock.spinlock,
    use_lock: bool,
    freelist: ?*run,
}{
    .lock = spinlock.spinlock.init("kmem"),
    .use_lock = false,
    .freelist = null,
};

pub fn kinit1(vstart: usize, vend: usize) void {
    freerange(vstart, vend);
}

pub fn kinit2(vstart: usize, vend: usize) void {
    freerange(vstart, vend);
    kmem.use_lock = true;
}

fn freerange(vstart: usize, vend: usize) void {
    var p = mmu.pgroundup(vstart);
    while (p + mmu.PGSIZE <= vend) : (p += mmu.PGSIZE) {
        kfree(p);
    }
}

// Free the page of physical memory pointed at by v,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
// TODO: implement lacked logic
fn kfree(v: usize) void {
    var r: *run = undefined;

    //if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
    //panic("kfree");

    // Fill with junk to catch dangling refs.
    for (@as([*]u8, @ptrFromInt(v))[0..mmu.PGSIZE]) |*b| {
        b.* = 1;
    }

    //if(kmem.use_lock)
    //    acquire(&kmem.lock);
    r = @as(*run, @ptrFromInt(v));
    r.*.next = kmem.freelist;
    kmem.freelist = r;

    //if(kmem.use_lock)
    //    release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// TODO: lock
pub fn kalloc() ?usize {
    var x = kmem.freelist;
    var len: u32 = 0;
    while (true) {
        if (x) |y| {
            x = y.next;
            len += 1;
        } else {
            break;
        }
    }
    //if(kmem.use_lock)
    //    acquire(&kmem.lock);
    var opt = kmem.freelist;
    if (opt) |r| {
        kmem.freelist = r.next;
        return @intFromPtr(r);
    }

    return null;
}
