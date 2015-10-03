--
-- also /usr/include/libv4l2.h
--
local ffi = require("ffi")
local libc = require("libc")

ffi.cdef[[
extern FILE *v4l2_log_file;

int v4l2_open(const char *file, int oflag, ...);
int v4l2_close(int fd);
int v4l2_dup(int fd);
int v4l2_ioctl(int fd, unsigned long int request, ...);

ssize_t v4l2_read(int fd, void *buffer, size_t n);
ssize_t v4l2_write(int fd, const void *buffer, size_t n);

void *v4l2_mmap(void *start, size_t length, int prot, int flags,
		int fd, int64_t offset);

int v4l2_munmap(void *_start, size_t length);
int v4l2_set_control(int fd, int cid, int value);
int v4l2_get_control(int fd, int cid);
int v4l2_fd_open(int fd, int v4l2_flags);
]]

V4L2_DISABLE_CONVERSION = 0x01;

local lib = ffi.load("v4l2")

return lib;
