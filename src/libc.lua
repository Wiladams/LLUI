--libc.lua
local ffi = require("ffi")
local bit = require("bit")
local band, bor = bit.band, bit.bor
local lshift, rshift = bit.lshift, bit.rshift

local C = {}	-- Constants
local F = {}	-- Functions
local Types = {} -- Types

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
typedef int32_t       clockid_t;

typedef int64_t off_t;
typedef uint16_t      mode_t;
typedef long ssize_t;

struct timeval { time_t tv_sec; suseconds_t tv_usec; };
struct timespec { time_t tv_sec; long tv_nsec; };

int clock_getres(clockid_t clk_id, struct timespec *res);
int clock_gettime(clockid_t clk_id, struct timespec *tp);
int clock_settime(clockid_t clk_id, const struct timespec *tp);
int clock_nanosleep(clockid_t clock_id, int flags, const struct timespec *request, struct timespec *remain);

static const int CLOCK_REALTIME         = 0;
static const int CLOCK_MONOTONIC            = 1;
static const int CLOCK_PROCESS_CPUTIME_ID   = 2;
static const int CLOCK_THREAD_CPUTIME_ID    = 3;
static const int CLOCK_MONOTONIC_RAW        = 4;
static const int CLOCK_REALTIME_COARSE      = 5;
static const int CLOCK_MONOTONIC_COARSE = 6;
static const int CLOCK_BOOTTIME         = 7;
static const int CLOCK_REALTIME_ALARM       = 8;
static const int CLOCK_BOOTTIME_ALARM       = 9;
static const int CLOCK_SGI_CYCLE            = 10;   // Hardware specific 
static const int CLOCK_TAI                  = 11;
]]



Types.timespec = ffi.typeof("struct timespec")
local timespec_mt = {
	__add = function(lhs, rhs)
		local newspec = timespec(lhs.tv_sec+rhs.tv_sec, lhs.tv_nsec+rhs.tv_nsec);
		return newspec;
	end;

	__sub = function(lhs, rhs)
		local newspec = timespec(lhs.tv_sec-rhs.tv_sec, lhs.tv_nsec-rhs.tv_nsec);
		return newspec;
	end;	

	__tostring = function(self)
		return string.format("%d.%d", tonumber(self.tv_sec), tonumber(self.tv_nsec));
	end;

	__index = {
		gettime = function(self, clockid)
			clockid = clockid or ffi.C.CLOCK_REALTIME;
			local res = ffi.C.clock_gettime(clockid, self)
			return res;
		end;
		
		getresolution = function(self, clockid)
			clockid = clockid or ffi.C.CLOCK_REALTIME;
			local res = ffi.C.clock_getres(clockid, self);
			return res;
		end;

		setFromSeconds = function(self, seconds)
			-- the seconds without fraction can become tv_sec
			local secs, frac = math.modf(seconds)
			local nsecs = frac * 1000000000;
			self.tv_sec = secs;
			self.tv_nsec = nsecs;

			return true;
		end;

		seconds = function(self)
			return tonumber(self.tv_sec) + (tonumber(self.tv_nsec) / 1000000000);	-- one billion'th of a second
		end;

	};
}
ffi.metatype(Types.timespec, timespec_mt)


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

C._IOC_NONE  = 0;
C._IOC_WRITE = 1;
C._IOC_READ  = 2;

function F._IO(a,b) return _IOC(C._IOC_NONE,a,b,0) end
function F._IOW(a,b,c) return _IOC(C._IOC_WRITE,a,b,ffi.sizeof(c)) end
function F._IOR(a,b,c) return _IOC(C._IOC_READ,a,b,ffi.sizeof(c)) end
function F._IOWR(a,b,c) return _IOC(bor(C._IOC_READ,C._IOC_WRITE),a,b,ffi.sizeof(c)) end


ffi.cdef[[
int ioctl (int, int, ...);
]]

function F.xioctl(fd, request, param)
    local r;

    repeat 
        r = libc.ioctl(fd, request, param);
    until (-1 ~= r or (libc.errnos.EINTR ~= ffi.errno()));

    return r;
end


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


	C.S_IFMT   = F.octal('00170000');
	C.S_IFSOCK = F.octal('0140000');
	C.S_IFLNK  = F.octal('0120000');
	C.S_IFREG  = F.octal('0100000');
	C.S_IFBLK  = F.octal('0060000');
	C.S_IFDIR  = F.octal('0040000');
	C.S_IFCHR  = F.octal('0020000');
	C.S_IFIFO  = F.octal('0010000');
	C.S_ISUID  = F.octal('0004000');
	C.S_ISGID  = F.octal('0002000');
	C.S_ISVTX  = F.octal('0001000');


	C.S_IRWXU = F.octal('00700');
	C.S_IRUSR = F.octal('00400');
	C.S_IWUSR = F.octal('00200');
	C.S_IXUSR = F.octal('00100');

	C.S_IRWXG = F.octal('00070');
	C.S_IRGRP = F.octal('00040');
	C.S_IWGRP = F.octal('00020');
	C.S_IXGRP = F.octal('00010');

	C.S_IRWXO = F.octal('00007');
	C.S_IROTH = F.octal('00004');
	C.S_IWOTH = F.octal('00002');
	C.S_IXOTH = F.octal('00001');

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

-- the iodesc type gives an easy place to hang things
-- related to a file descriptor.  Primarily it keeps the 
-- basic file descriptor.  
-- It also performs the async read/write operations

ffi.cdef[[
struct iodesc {
  int fd;
};

struct ioevent {
  struct iodesc desc;
  int eventKind;
};
]]

C.IO_READ = 1;
C.IO_WRITE = 2;
C.IO_CONNECT = 3;
C.STDIN_FILENO = 0;
C.STDOUT_FILENO = 1;
C.STDERR_FILENO = 2;

local iodesc = ffi.typeof("struct iodesc")
local iodesc_mt = {
    __new = function(ct, fd)
        local obj = ffi.new(ct, fd);

        return obj;
    end;

    __gc = function(self)
        if self.fd > -1 then
            self:close();
        end
    end;

    __index = {
        close = function(self)
            ffi.C.close(self.fd);
            self.fd = -1; -- make it invalid
        end,

        read = function(self, buff, bufflen)
            local bytes = tonumber(ffi.C.read(self.fd, buff, bufflen));

            if bytes > 0 then
                return bytes;
            end

            if bytes == 0 then
              return 0;
            end

            return false, ffi.errno();
        end,

        write = function(self, buff, bufflen)
            local bytes = tonumber(ffi.C.write(self.fd, buff, bufflen));

            if bytes > 0 then
                return bytes;
            end

            if bytes == 0 then
              return 0;
            end

            return false, ffi.errno();
        end,

        setNonBlocking = function(self)
            local feature_on = ffi.new("int[1]",1)
            local ret = ffi.C.ioctl(self.fd, C.FIONBIO, feature_on)
	    print("setNonBlocking: ", ret, ffi.errno())

            return ret == 0;

        end,

    };
}
ffi.metatype(iodesc, iodesc_mt);
Types.iodesc = iodesc;


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
function F.printf(fmt, ...)
    io.write(string.format(fmt, ...));
end

function F.fprintf(f, fmt, ...)
	f:write(string.format(fmt, ...));
end


-- ffi helpers
function F.stringvalue(str, default)
	if str == nil then
		return default;
	end

	return ffi.string(str)
end

F.safeffistring = F.stringvalue;

--[[
	Things related to epoll
--]]

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


C.EPOLL_CLOEXEC = F.octal('02000000');
C.EPOLLIN 	= 0x0001;
C.EPOLLPRI 	= 0x0002;
C.EPOLLOUT 	= 0x0004;
C.EPOLLRDNORM = 0x0040;			-- SAME AS EPOLLIN
C.EPOLLRDBAND = 0x0080;
C.EPOLLWRNORM = 0x0100;			-- SAME AS EPOLLOUT
C.EPOLLWRBAND = 0x0200;
C.EPOLLMSG	= 0x0400;			-- NOT USED
C.EPOLLERR 	= 0x0008;
C.EPOLLHUP 	= 0x0010;
C.EPOLLRDHUP 	= 0x2000;
C.EPOLLWAKEUP = lshift(1,29);
C.EPOLLONESHOT = lshift(1,30);
C.EPOLLET 	= lshift(1,31);

-- Valid opcodes ( "op" parameter ) to issue to epoll_ctl().
C.EPOLL_CTL_ADD =1;	-- Add a file descriptor to the interface.
C.EPOLL_CTL_DEL =2;	-- Remove a file descriptor from the interface.
C.EPOLL_CTL_MOD =3;	-- Change file descriptor epoll_event structure.

ffi.cdef[[
struct epollset {
	int epfd;		// epoll file descriptor
} ;
]]

local epollset = ffi.typeof("struct epollset")
local epollset_mt = {
	__new = function(ct, epfd)
		if not epfd then
			epfd = ffi.C.epoll_create1(0);
			print("epollset.__new(): ", epfd)
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
			local ret = ffi.C.epoll_ctl(self.epfd, C.EPOLL_CTL_ADD, fd, event)
print("epollset.add(), fd,  event, ret: ", fd, event, ret, F.strerror());
			if ret > -1 then
				return ret;
			end

			return false, ffi.errno();
		end,

		delete = function(self, fd, event)
			local ret = ffi.C.epoll_ctl(self.epfd, C.EPOLL_CTL_DEL, fd, event)

			if ret > -1 then
				return ret;
			end

			return false, ffi.errno();
		end,

		modify = function(self, fd, event)
			local ret = ffi.C.epoll_ctl(self.epfd, C.EPOLL_CTL_MOD, fd, event)
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
Types.epollset = epollset;


local errnos = {
	-- Constants
	-- errno-base
	EPERM		= 1	; -- Operation not permitted 
	ENOENT		= 2	; -- No such file or directory 
	ESRCH		= 3	; -- No such process 
	EINTR		= 4	; -- Interrupted system call 
	EIO			= 5	; -- I/O error 
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

    EDEADLK 	= 35;  -- Resource deadlock would occur 
    EDEADLOCK  	= 35; 	-- EDEADLK;

    ENAMETOOLONG = 36;  -- File name too long 
    ENOLCK 		= 37;  -- No record locks available 
    ENOSYS 		= 38;  -- Function not implemented 
    ENOTEMPTY 	= 39;  -- Directory not empty 
    ELOOP 		= 40;  -- Too many symbolic links encountered 
    EWOULDBLOCK = 11;	-- EAGAIN;  -- Operation would block 
    ENOMSG 		= 42;  -- No message of desired type 
    EIDRM 		= 43;  -- Identifier removed 
    ECHRNG 		= 44;  -- Channel number out of range 
    EL2NSYNC 	= 45;  -- Level 2 not synchronized 
    EL3HLT 		= 46;  -- Level 3 halted 
    EL3RST 		= 47;  -- Level 3 reset 
    ELNRNG 		= 48;  -- Link number out of range 
    EUNATCH 	= 49;  -- Protocol driver not attached 
    ENOCSI 		= 50;  -- No CSI structure available 
    EL2HLT 		= 51;  -- Level 2 halted 
    EBADE 		= 52;  -- Invalid exchange 
    EBADR 		= 53;  -- Invalid request descriptor 
    EXFULL 		= 54;  -- Exchange full 
    ENOANO 		= 55;  -- No anode 
    EBADRQC 	= 56;  -- Invalid request code 
    EBADSLT 	= 57;  -- Invalid slot 


    EBFONT 		= 59;  -- Bad font file format 
    ENOSTR 		= 60;  -- Device not a stream 
    ENODATA 	= 61;  -- No data available 
    ETIME 		= 62;  -- Timer expired 
    ENOSR 		= 63;  -- Out of streams resources 
    ENONET 		= 64;  -- Machine is not on the network 
    ENOPKG 		= 65;  -- Package not installed 
    EREMOTE 	= 66;  -- Object is remote 
    ENOLINK 	= 67;  -- Link has been severed 
    EADV 		= 68;  -- Advertise error 
    ESRMNT 		= 69;  -- Srmount error 
    ECOMM 		= 70;  -- Communication error on send 
    EPROTO 		= 71;  -- Protocol error 
    EMULTIHOP 	= 72;  -- Multihop attempted 
    EDOTDOT 	= 73;  -- RFS specific error 
    EBADMSG 	= 74;  -- Not a data message 
    EOVERFLOW 	= 75;  -- Value too large for defined data type 
    ENOTUNIQ 	= 76;  -- Name not unique on network 
    EBADFD 		= 77;  -- File descriptor in bad state 
    EREMCHG 	= 78;  -- Remote address changed 
    ELIBACC 	= 79;  -- Can not access a needed shared library 
    ELIBBAD 	= 80;  -- Accessing a corrupted shared library 
    ELIBSCN 	= 81;  -- .lib section in a.out corrupted 
    ELIBMAX 	= 82;  -- Attempting to link in too many shared libraries 
    ELIBEXEC 	= 83;  -- Cannot exec a shared library directly 
    EILSEQ 		= 84;  -- Illegal byte sequence 
    ERESTART 	= 85;  -- Interrupted system call should be restarted 
    ESTRPIPE 	= 86;  -- Streams pipe error 
    EUSERS 		= 87;  -- Too many users 
    
    ENOTSOCK 	= 88;  -- Socket operation on non-socket 
    EDESTADDRREQ = 89;  -- Destination address required 
    EMSGSIZE 	= 90;  -- Message too long 
    EPROTOTYPE 	= 91;  -- Protocol wrong type for socket 
    ENOPROTOOPT = 92;  -- Protocol not available 
    EPROTONOSUPPORT = 93;  -- Protocol not supported 
    ESOCKTNOSUPPORT = 94;  -- Socket type not supported 
    EOPNOTSUPP 		= 95;  -- Operation not supported on transport endpoint 
    EPFNOSUPPORT 	= 96;  -- Protocol family not supported 
    EAFNOSUPPORT 	= 97;  -- Address family not supported by protocol 
    EADDRINUSE 		= 98;  -- Address already in use 
    EADDRNOTAVAIL 	= 99;  -- Cannot assign requested address 
    ENETDOWN 		= 100;  -- Network is down 
    ENETUNREACH 	= 101;  -- Network is unreachable 
    ENETRESET 		= 102;  -- Network dropped connection because of reset 
    ECONNABORTED 	= 103;  -- Software caused connection abort 
    ECONNRESET 		= 104;  -- Connection reset by peer 
    ENOBUFS = 105;  -- No buffer space available 
    EISCONN = 106;  -- Transport endpoint is already connected 
    ENOTCONN = 107;  -- Transport endpoint is not connected 
    ESHUTDOWN = 108;  -- Cannot send after transport endpoint shutdown 
    ETOOMANYREFS = 109;  -- Too many references: cannot splice 
    ETIMEDOUT = 110;  -- Connection timed out 
    ECONNREFUSED = 111;  -- Connection refused 
    EHOSTDOWN = 112;  -- Host is down 
    EHOSTUNREACH = 113;  -- No route to host 
    EALREADY = 114;  -- Operation already in progress 
    EINPROGRESS = 115;  -- Operation now in progress 
    ESTALE = 116;  -- Stale file handle 
    EUCLEAN = 117;  -- Structure needs cleaning 
    ENOTNAM = 118;  -- Not a XENIX named type file 
    ENAVAIL = 119;  -- No XENIX semaphores available 
    EISNAM = 120;  -- Is a named type file 
    EREMOTEIO = 121;  -- Remote I/O error 
    EDQUOT = 122;  -- Quota exceeded 

    ENOMEDIUM = 123;  -- No medium found 
    EMEDIUMTYPE = 124;  -- Wrong medium type 
    ECANCELED = 125;  -- Operation Canceled 
    ENOKEY = 126;  -- Required key not available 
    EKEYEXPIRED = 127;  -- Key has expired 
    EKEYREVOKED = 128;  -- Key has been revoked 
    EKEYREJECTED = 129;  -- Key was rejected by service 

	-- for robust mutexes 
    EOWNERDEAD 		= 130;  -- Owner died 
    ENOTRECOVERABLE = 131;  -- State not recoverable 
    ERFKILL 		= 132;  -- Operation not possible due to RF-kill 
    EHWPOISON 		= 133;  -- Memory page has hardware error 
}
C.errnos = errnos;


-- non-blocking IO
C.FIONBIO        = F._IOW('f', 126, "int");		-- FIONBIO = 0x5421 

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




function F.strerror(num)
	num = num or ffi.errno();
	return F.getNameOfValue(num, errnos)
end


local exports = {	
--[[
	_IOC_NONE = _IOC_NONE;
	_IOC_READ = _IOC_READ;
	_IOC_WRITE = _IOC_WRITE;


	-- local functions
	_IOC = _IOC;
	_IO = _IO;
	_IOR = _IOR;
	_IOW = _IOW;
	_IOWR = _IOWR;


	fprintf = fprintf;
	printf = printf;
	strerror = strerror;
	stringvalue = stringvalue;
	safeffistring = stringvalue;
	getValueName = getNameOfValue;
--]]

--[[
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
--]]

	-- epoll related
--	epollset = epollset;
}




setmetatable(exports, {
	__call = function(self, tbl)
		tbl = tbl or _G;

		for k,v in pairs(self) do
			tbl[k] = v;
		end;

		for k,v in pairs(C) do
			if type(v) == "table" then
				for key, value in pairs(v) do 
					tbl[key] = value;
				end
			else
				tbl[k] = v;
			end
		end;

		return self;
	end,

	__index = function(self, key)

		-- look for the key in the local functions
		local value = F[key]
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

		-- try looking in the types
		value = Types[key]
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
