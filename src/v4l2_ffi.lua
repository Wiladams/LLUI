local ffi = require("ffi")
local libc = require("libc")

ffi.cdef[[
extern FILE *v4l2_log_file;

/* Just like your regular open/close/etc, except that format conversion is
   done if necessary when capturing. That is if you (try to) set a capture
   format which is not supported by the cam, but is supported by libv4lconvert,
   then the try_fmt / set_fmt will succeed as if the cam supports the format
   and on dqbuf / read the data will be converted for you and returned in
   the request format. enum_fmt will also report support for the formats to
   which conversion is possible.

   Another difference is that you can make v4l2_read() calls even on devices
   which do not support the regular read() method.

   Note the device name passed to v4l2_open must be of a video4linux2 device,
   if it is anything else (including a video4linux1 device), v4l2_open will
   fail.

   Note that the argument to v4l2_ioctl after the request must be a valid
   memory address of structure of the appropriate type for the request (for
   v4l2 requests which expect a structure address). Passing in NULL or an
   invalid memory address will not lead to failure with errno being EFAULT,
   as it would with a real ioctl, but will cause libv4l2 to break, and you
   get to keep both pieces.
*/

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
