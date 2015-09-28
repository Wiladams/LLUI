--libc.lua
local ffi = require("ffi")
local bit = require("bit")
local band, bor = bit.band, bit.bor
local lshift, rshift = bit.lshift, bit.rshift



-- useful types
ffi.cdef[[
typedef uint32_t __useconds_t;
typedef __useconds_t useconds_t;
typedef long suseconds_t;
typedef long time_t;

typedef int64_t off_t;
typedef uint16_t      mode_t;


struct timeval { time_t tv_sec; suseconds_t tv_usec; };
]]

-- ioctl related
-- very x86_64 specific
local IOC = {
  DIRSHIFT = 30;
  TYPESHIFT = 8;
  NRSHIFT = 0;
  SIZESHIFT = 16;
}

local function ioc(dir, ch, nr, size)
  if type(ch) == "string" then ch = ch:byte() end

  return bor(lshift(dir, IOC.DIRSHIFT), 
       lshift(ch, IOC.TYPESHIFT), 
       lshift(nr, IOC.NRSHIFT), 
       lshift(size, IOC.SIZESHIFT))
end

local function _IOC(a,b,c,d) 
  return ioc(a,b,c,d);
end

local _IOC_NONE  = 0;
local _IOC_WRITE = 1;
local _IOC_READ  = 2;

local function _IO(a,b) return _IOC(_IOC_NONE,a,b,0) end
local function _IOW(a,b,c) return _IOC(_IOC_WRITE,a,b,ffi.sizeof(c)) end
local function _IOR(a,b,c) return _IOC(_IOC_READ,a,b,ffi.sizeof(c)) end
local function _IOWR(a,b,c) return _IOC(bor(_IOC_READ,_IOC_WRITE),a,b,ffi.sizeof(c)) end


ffi.cdef[[
int ioctl (int, int, ...);
]]


--[[
	Memory Management
--]]
ffi.cdef[[
void *calloc(size_t nitems, size_t size);
void free(void *);
void * malloc(const size_t size);

void *memcpy (void *__dest, const void * __src, size_t __n) ;
void *memset (void *__s, int __c, size_t __n) ;
	
void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset);
int munmap (void *, size_t);

int mprotect (void *, size_t, int);
int msync (void *, size_t, int);
]]

-- StringZ
--
ffi.cdef[[
char *strcpy(char *dest, const char *src);
size_t strlen(const char *);
]]

--[[
	File Management
--]]
ffi.cdef[[
	int open (const char *__file, int __oflag, ...);
	int close(int fd);

]]

--[[
	Stream Management
--]]

ffi.cdef[[
// Files
typedef struct _IO_FILE FILE;

FILE *fopen(const char *__restrict, const char *__restrict);
int fclose(FILE *);
int ferror(FILE *stream);
int fflush(FILE *stream);

int fprintf(FILE *__restrict, const char *__restrict, ...);
size_t fread(void *__restrict, size_t, size_t, FILE *__restrict);
size_t fwrite(const void *__restrict, size_t, size_t, FILE *__restrict);

]]

--[[
	Random Numbers
--]]
ffi.cdef[[
	int rand (void);
	void srand (unsigned int __seed);
]]

--[[
	Time Handling
--]]
ffi.cdef[[
	int usleep (__useconds_t __useconds);
	time_t time(time_t *t);
	unsigned int sleep(unsigned int);
]]


local function printf(fmt, ...)
    io.write(string.format(fmt, ...));
end

local function fprintf(f, fmt, ...)
	f:write(string.format(fmt, ...));
end

local function stringvalue(str, default)
	if str == nil then
		return default;
	end

	return ffi.string(str)
end


local errnos = {
	-- Constants
	-- errno-base
	EPERM		= 1	; -- Operation not permitted 
	ENOENT		= 2	; -- No such file or directory 
	ESRCH		= 3	; -- No such process 
	EINTR		= 4	; -- Interrupted system call 
	EIO		= 5	; -- I/O error 
	ENXIO		= 6	; -- No such device or address 
	E2BIG		= 7	; -- Argument list too long 
	ENOEXEC		= 8	; -- Exec format error 
	EBADF		= 9	; -- Bad file number 
	ECHILD		=10	; -- No child processes 
	EAGAIN		=11	; -- Try again 
	ENOMEM		=12	; -- Out of memory 
	EACCES		=13	; -- Permission denied 
	EFAULT		=14	; -- Bad address 
	ENOTBLK		=15	; -- Block device required 
	EBUSY		=16	; -- Device or resource busy 
	EEXIST		=17	; -- File exists 
	EXDEV		=18	; -- Cross-device link 
	ENODEV		=19	; -- No such device 
	ENOTDIR		=20	; -- Not a directory 
	EISDIR		=21	; -- Is a directory 
	EINVAL		=22	; -- Invalid argument 
	ENFILE		=23	; -- File table overflow 
	EMFILE		=24	; -- Too many open files 
	ENOTTY		=25	; -- Not a typewriter 
	ETXTBSY		=26	; -- Text file busy 
	EFBIG		=27	; -- File too large 
	ENOSPC		=28	; -- No space left on device 
	ESPIPE		=29	; -- Illegal seek 
	EROFS		=30	; -- Read-only file system 
	EMLINK		=31	; -- Too many links 
	EPIPE		=32	; -- Broken pipe 
	EDOM		=33	; -- Math argument out of domain of func 
	ERANGE		=34	; -- Math result not representable 

	-- errno
	EOPNOTSUPP	= 95;	-- Operation not supported on transport endpoint
	
}

-- reverse dictionary lookup
local function getNameOfValue(value, tbl)
	for k,v in pairs(tbl) do
		if v == value 
			then return k
		end
	end

	return string.format("UNKNOWN VALUE: %d", value);
end 

local function strerror(num)
	num = num or ffi.errno();
	return getNameOfValue(errnos, num)
end

local function octal(val)
	return tonumber(val,8);
end

local exports = {

	-- fcntl
	O_RDONLY	= octal('00000000');
	O_WRONLY	= octal('00000001');
	O_RDWR		= octal('00000002');
	O_NONBLOCK	= octal('00004000');
	O_CLOEXEC	= octal('02000000');	-- set close_on_exec

	-- ioctl
	ioctl = ffi.C.ioctl;
	
	_IOC_NONE = _IOC_NONE;
	_IOC_READ = _IOC_READ;
	_IOC_WRITE = _IOC_WRITE;

	_IOC = _IOC;
	_IO = _IO;
	_IOR = _IOR;
	_IOW = _IOW;
	_IOWR = _IOWR;


	-- mmap
	MAP_FAILED  = ffi.cast("void *", -1);

	PROT_NONE   =   0;
	PROT_READ   =   1;
	PROT_WRITE  =   2;
	PROT_EXEC   =   4;

	MAP_SHARED  =   0x01;
	MAP_PRIVATE =   0x02;
	MAP_FIXED   =   0x10;


	-- local functions
	fprintf = fprintf;
	printf = printf;
	strerror = strerror;
	stringvalue = stringvalue;
	safeffistring = stringvalue;

	-- Memory Management
	free = ffi.C.free;
	malloc = ffi.C.malloc;
	memcpy = ffi.C.memcpy;
	memset = ffi.C.memset;
	mmap = ffi.C.mmap;
	munmap = ffi.C.munmap;

	-- File manipulation
	fopen = ffi.C.fopen;
	fclose = ffi.C.fclose;
	fprintf = ffi.C.fprintf;
	fwrite = ffi.C.fwrite;

	open = ffi.C.open;
	close = ffi.C.close;

	-- Random numbers
	rand = ffi.C.rand;
	srand = ffi.C.srand;

	sleep = ffi.C.sleep;
	usleep = ffi.C.usleep;
	time = ffi.C.time;
}




setmetatable(exports, {
	__call = function(self, tbl)
		tbl = tbl or _G;
		for k,v in pairs(self) do
			tbl[k] = v;
		end;

		for k,v in pairs(errnos) do
			tbl[k] =  v;
		end

		return self;
	end,
})

return exports
