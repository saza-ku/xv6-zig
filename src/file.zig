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

};
