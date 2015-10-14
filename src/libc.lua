--libc.lua
local ffi = require("ffi")
local bit = require("bit")
local band, bor = bit.band, bit.bor
local lshift, rshift = bit.lshift, bit.rshift

local C = {}
local F = {}

-- utility functions
function F.octal(val)
	return tonumber(val,8);
end

-- reverse dictionary lookup
-- given a value, return the key or nil
function F.getNameOfValue(value, tbl)
	for k,v in pairs(tbl) do
		if v == value 
			then return k
		end
	end

	return string.format("UNKNOWN VALUE: %d", value);
end 


-- useful types
ffi.cdef[[
typedef unsigned int mode_t;
typedef unsigned int nlink_t;
typedef int64_t off_t;
typedef uint64_t ino_t;
typedef uint64_t dev_t;
typedef long blksize_t;
typedef int64_t blkcnt_t;
typedef uint64_t fsblkcnt_t;
typedef uint64_t fsfilcnt_t;
]]



ffi.cdef[[
typedef int pid_t;
typedef unsigned int id_t;
typedef unsigned int uid_t;
typedef unsigned int gid_t;
typedef int key_t;

typedef uint32_t __useconds_t;
typedef __useconds_t useconds_t;
typedef long suseconds_t;
typedef long time_t;

typedef int64_t off_t;
typedef uint16_t      mode_t;
typedef long ssize_t;

struct timeval { time_t tv_sec; suseconds_t tv_usec; };
struct timespec { time_t tv_sec; long tv_nsec; };

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
	stat() related
--]]

ffi.cdef[[
typedef struct stat {
	dev_t st_dev;
	ino_t st_ino;
	nlink_t st_nlink;

	mode_t st_mode;
	uid_t st_uid;
	gid_t st_gid;
	unsigned int    __pad0;
	dev_t st_rdev;
	off_t st_size;
	blksize_t st_blksize;
	blkcnt_t st_blocks;

	struct timespec st_atim;
	struct timespec st_mtim;
	struct timespec st_ctim;
	long __unused[3];
} stat_t;
]]


ffi.cdef[[
int __fxstat(int ver, int fd, struct stat *buf);
int __fxstatat(int ver, int fd, const char *path, struct stat *buf, int flag);
int __lxstat(int ver, const char *path, struct stat *buf);
int __xstat(int ver, const char *path, struct stat *buf);
]]

ffi.cdef[[
int stat(const char *__restrict, struct stat *__restrict);
int fstat(int, struct stat *);
int lstat(const char *__restrict, struct stat *__restrict);
int fstatat(int, const char *__restrict, struct stat *__restrict, int);
int chmod(const char *, mode_t);
int fchmod(int, mode_t);
int fchmodat(int, const char *, mode_t, int);
mode_t umask(mode_t);
int mkdir(const char *, mode_t);
int mknod(const char *, mode_t, dev_t);
int mkfifo(const char *, mode_t);
int mkdirat(int, const char *, mode_t);
int mknodat(int, const char *, mode_t, dev_t);
int mkfifoat(int, const char *, mode_t);

int futimens(int, const struct timespec [2]);
int utimensat(int, const char *, const struct timespec [2], int);
]]


	C.S_IFMT   = F.octal(00170000);
	C.S_IFSOCK = F.octal(0140000);
	C.S_IFLNK  = F.octal(0120000);
	C.S_IFREG  = F.octal(0100000);
	C.S_IFBLK  = F.octal(0060000);
	C.S_IFDIR  = F.octal(0040000);
	C.S_IFCHR  = F.octal(0020000);
	C.S_IFIFO  = F.octal(0010000);
	C.S_ISUID  = F.octal(0004000);
	C.S_ISGID  = F.octal(0002000);
	C.S_ISVTX  = F.octal(0001000);


	C.S_IRWXU = F.octal(00700);
	C.S_IRUSR = F.octal(00400);
	C.S_IWUSR = F.octal(00200);
	C.S_IXUSR = F.octal(00100);

	C.S_IRWXG = F.octal(00070);
	C.S_IRGRP = F.octal(00040);
	C.S_IWGRP = F.octal(00020);
	C.S_IXGRP = F.octal(00010);

	C.S_IRWXO = F.octal(00007);
	C.S_IROTH = F.octal(00004);
	C.S_IWOTH = F.octal(00002);
	C.S_IXOTH = F.octal(00001);

local _STAT_VER_KERNEL	= 0;
local _STAT_VER_LINUX	= 1;

C._STAT_VER	= _STAT_VER_LINUX;


function F.S_ISLNK(m) return (band((m), C.S_IFMT) == C.S_IFLNK) end
function F.S_ISREG(m) return (band((m), C.S_IFMT) == C.S_IFREG) end
function F.S_ISDIR(m) return (band((m), C.S_IFMT) == C.S_IFDIR) end
function F.S_ISCHR(m) return (band((m), C.S_IFMT) == C.S_IFCHR) end
function F.S_ISBLK(m) return (band((m), C.S_IFMT) == C.S_IFBLK) end
function F.S_ISFIFO(m) return (band((m), C.S_IFMT) == C.S_IFIFO) end
function F.S_ISSOCK(m) return (band((m), C.S_IFMT) == C.S_IFSOCK) end

function F.stat(path, buf) return ffi.C.__xstat(C._STAT_VER, path, buf) end
function F.lstat(path, buf) return ffi.C.__lxstat(C._STAT_VER, path, buf) end


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
	int read(int fd, char *buffer, unsigned int length); 
	int write(int fd, char *buffer, unsigned int length);
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

int remove(const char *);
int rename(const char *, const char *);

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

--[[
	unistd.h
--]]

ffi.cdef[[
uid_t geteuid(void);
int chown(const char *, uid_t, gid_t);

]]


-- local versions of classics
local function printf(fmt, ...)
    io.write(string.format(fmt, ...));
end

local function fprintf(f, fmt, ...)
	f:write(string.format(fmt, ...));
end


-- ffi helpers
local function stringvalue(str, default)
	if str == nil then
		return default;
	end

	return ffi.string(str)
end

--[[
	Things related to epoll
--]]
ffi.cdef[[
struct filedesc {
  int fd;
};

typedef struct async_ioevent {
  struct filedesc fdesc;
  int eventKind;
} async_ioevent_t;
]]


ffi.cdef[[
typedef union epoll_data {
  void *ptr;
  int fd;
  uint32_t u32;
  uint64_t u64;
} epoll_data_t;
]]


ffi.cdef([[
struct epoll_event {
int32_t events;
epoll_data_t data;
}]]..(ffi.arch == "x64" and [[__attribute__((__packed__));]] or [[;]]))



ffi.cdef[[
int epoll_create (int __size) ;
int epoll_create1 (int __flags) ;
int epoll_ctl (int __epfd, int __op, int __fd, struct epoll_event *__event) ;
int epoll_wait (int __epfd, struct epoll_event *__events, int __maxevents, int __timeout);

//int epoll_pwait (int __epfd, struct epoll_event *__events,
//          int __maxevents, int __timeout,
//          const __sigset_t *__ss);
]]


local EpollConstants = {
    EPOLL_CLOEXEC = F.octal('02000000');
	EPOLLIN 	= 0x0001;
	EPOLLPRI 	= 0x0002;
	EPOLLOUT 	= 0x0004;
	EPOLLRDNORM = 0x0040;			-- SAME AS EPOLLIN
	EPOLLRDBAND = 0x0080;
	EPOLLWRNORM = 0x0100;			-- SAME AS EPOLLOUT
	EPOLLWRBAND = 0x0200;
	EPOLLMSG	= 0x0400;			-- NOT USED
	EPOLLERR 	= 0x0008;
	EPOLLHUP 	= 0x0010;
	EPOLLRDHUP 	= 0x2000;
	EPOLLWAKEUP = lshift(1,29);
	EPOLLONESHOT = lshift(1,30);
	EPOLLET 	= lshift(1,31);




-- Valid opcodes ( "op" parameter ) to issue to epoll_ctl().
	EPOLL_CTL_ADD =1;	-- Add a file descriptor to the interface.
	EPOLL_CTL_DEL =2;	-- Remove a file descriptor from the interface.
	EPOLL_CTL_MOD =3;	-- Change file descriptor epoll_event structure.
}


ffi.cdef[[
typedef struct _epollset {
	int epfd;		// epoll file descriptor
} epollset;
]]

local epollset = ffi.typeof("epollset")
local epollset_mt = {
	__new = function(ct, epfd)
		if not epfd then
			epfd = ffi.C.epoll_create1(0);
		end

		if epfd < 0 then
			return nil;
		end

		return ffi.new(ct, epfd)
	end,

	__gc = function(self)
		-- ffi.C.close(self.epfd);
	end;

	__index = {
		add = function(self, fd, event)
			local ret = ffi.C.epoll_ctl(self.epfd, EpollConstants.EPOLL_CTL_ADD, fd, event)

			if ret > -1 then
				return ret;
			end

			return false, ffi.errno();
		end,

		delete = function(self, fd, event)
			local ret = ffi.C.epoll_ctl(self.epfd, EpollConstants.EPOLL_CTL_DEL, fd, event)

			if ret > -1 then
				return ret;
			end

			return false, ffi.errno();
		end,

		modify = function(self, fd, event)
			local ret = ffi.C.epoll_ctl(self.epfd, EpollConstants.EPOLL_CTL_MOD, fd, event)
			if ret > -1 then
				return ret;
			end

			return false, ffi.errno();
		end,

		-- struct epoll_event *__events
		wait = function(self, events, maxevents, timeout)
			maxevents = maxevents or 1
			timeout = timeout or -1

			-- gets either number of ready events
			-- or -1 indicating an error
			local ret = ffi.C.epoll_wait (self.epfd, events, maxevents, timeout);
			if ret == -1 then
				return false, ffi.errno();
			end

			return ret;
		end,
	};
}
ffi.metatype(epollset, epollset_mt);



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



-- non-blocking IO
C.FIONBIO        = _IOW('f', 126, "int");		-- FIONBIO = 0x5421 

-- mmap
C.MAP_FAILED  = ffi.cast("void *", -1);

C.PROT_NONE   =   0;
C.PROT_READ   =   1;
C.PROT_WRITE  =   2;
C.PROT_EXEC   =   4;

C.MAP_SHARED  =   0x01;
C.MAP_PRIVATE =   0x02;
C.MAP_FIXED   =   0x10;

-- fcntl
C.O_RDONLY	= F.octal('00000000');
C.O_WRONLY	= F.octal('00000001');
C.O_RDWR		= F.octal('00000002');
C.O_NONBLOCK	= F.octal('00004000');
C.O_CLOEXEC	= F.octal('02000000');	-- set close_on_exec




local function strerror(num)
	num = num or ffi.errno();
	return getNameOfValue(num, errnos)
end


local exports = {
	errnos = errnos;


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

	-- local functions
	fprintf = fprintf;
	printf = printf;
	strerror = strerror;
	stringvalue = stringvalue;
	safeffistring = stringvalue;
	getValueName = getNameOfValue;
	
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
	read = ffi.C.read;
	write = ffi.C.write;

	-- Random numbers
	rand = ffi.C.rand;
	srand = ffi.C.srand;

	sleep = ffi.C.sleep;
	usleep = ffi.C.usleep;
	time = ffi.C.time;

	-- epoll related
	epollset = epollset;
	EpollConstants = EpollConstants;
}




setmetatable(exports, {
	__call = function(self, tbl)
		tbl = tbl or _G;

		for k,v in pairs(self) do
			tbl[k] = v;
		end;

		for k,v in pairs(C) do
			tbl[k] = v;
		end;

		for k,v in pairs(errnos) do
			tbl[k] =  v;
		end

		for k,v in pairs(EpollConstants) do
			tbl[k] = v;
		end

		return self;
	end,

	__index = function(self, key)
		local value = F[key]

		-- look for the key in functions
		if value then
			rawset(self, key, value);
			return value;
		end

		-- try the constants
		value = C[key];
		if value then
			rawset(self, key, value);
			return value;
		end

		-- try looking in the libc library
		local success, value = pcall(function() return ffi.C[key] end)
		if success then
			rawset(self, key, value);
			return value;
		end

		return nil;
	end,

})

return exports
