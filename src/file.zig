pub const file = struct {
    typ: enum { FD_NONE, FD_PIPE, FD_INODE },
    ref: u32, // reference count,
    readable: bool,
    writable: bool,
    // pipe: pipe,
    // ip: inode,
    // off: u32,
};

pub const inode = struct {
    dev: u32,
    inum: u32,
    ref: u32,
    //lock: , sleeplock
    valid: u32,
    typ: u16,
    major: u16,
    minor: u16,
    nlink: u16,
    size: u32,
    addrs: [13]u32,
};
