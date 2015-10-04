local ffi = require("ffi")
local libc = require("libc")

ffi.cdef[[
struct libv4l_dev_ops {
    void * (*init)(int fd);
    void (*close)(void *dev_ops_priv);
    int (*ioctl)(void *dev_ops_priv, int fd, unsigned long int request, void *arg);
    ssize_t (*read)(void *dev_ops_priv, int fd, void *buffer, size_t n);
    ssize_t (*write)(void *dev_ops_priv, int fd, const void *buffer, size_t n);

    /* For future plugin API extension, plugins implementing the current API
       must set these all to NULL, as future versions may check for these */
    void (*reserved1)(void);
    void (*reserved2)(void);
    void (*reserved3)(void);
    void (*reserved4)(void);
    void (*reserved5)(void);
    void (*reserved6)(void);
    void (*reserved7)(void);
};
]]
