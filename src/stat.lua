local ffi = require("ffi")
local bit = require("bit")
local band = bit.band;

--[=[
ffi.cdef[[
struct stat {
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
};
]]
--]=]

ffi.cdef[[
int stat(const char *__restrict, struct stat *__restrict);
]]

local function octal(val)
	return tonumber(val,8);
end

local Constants = {
	S_IFMT   = octal(00170000);
	S_IFSOCK = octal(0140000);
	S_IFLNK	 = octal(0120000);
	S_IFREG  = octal(0100000);
	S_IFBLK  = octal(0060000);
	S_IFDIR  = octal(0040000);
	S_IFCHR  = octal(0020000);
	S_IFIFO  = octal(0010000);
	S_ISUID  = octal(0004000);
	S_ISGID  = octal(0002000);
	S_ISVTX  = octal(0001000);


	S_IRWXU = octal(00700);
	S_IRUSR = octal(00400);
	S_IWUSR = octal(00200);
	S_IXUSR = octal(00100);

	S_IRWXG = octal(00070);
	S_IRGRP = octal(00040);
	S_IWGRP = octal(00020);
	S_IXGRP = octal(00010);

	S_IRWXO = octal(00007);
	S_IROTH = octal(00004);
	S_IWOTH = octal(00002);
	S_IXOTH = octal(00001);
}

local Macros = {
	S_ISLNK	= function(m) return (band((m), Constants.S_IFMT) == Constants.S_IFLNK) end;
	S_ISREG	= function(m) return (band((m), Constants.S_IFMT) == Constants.S_IFREG) end;
	S_ISDIR	= function(m) return (band((m), Constants.S_IFMT) == Constants.S_IFDIR) end;
	S_ISCHR	= function(m) return (band((m), Constants.S_IFMT) == Constants.S_IFCHR) end;
	S_ISBLK	= function(m) return (band((m), Constants.S_IFMT) == Constants.S_IFBLK) end;
	S_ISFIFO	= function(m) return (band((m), Constants.S_IFMT) == Constants.S_IFIFO) end;
	S_ISSOCK	= function(m) return (band((m), Constants.S_IFMT) == Constants.S_IFSOCK) end;
}

local exports = {
	Constants = Constants;
	Macros = Macros;

	--stat = ffi.C.stat;
}

setmetatable(exports, {
	__call = function(self, tbl)
		tbl = tbl or _G
		for k,v in pairs(Constants) do
			tbl[k]=v;
		end

		for k,v in pairs(Macros) do
			tbl[k]=v;
		end

		return self;
	end,

})

return exports
