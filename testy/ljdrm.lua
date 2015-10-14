local ffi = require("ffi")
local bit = require("bit")
local band, bor, lshift, rshift = bit.band, bit.bor, bit.lshift, bit.rshift

local drm = require("drm")
local libc = require("libc")



local C = {
    -- constants
    DRM_MAX_MINOR  = 16;

    -- Defaults, if nothing set in xf86config
	  DRM_DEV_UID  =0;
	  DRM_DEV_GID  =0;

    -- Default /dev/dri directory permissions 0755
	  DRM_DEV_DIRMODE  = bor(libc.S_IRUSR,libc.S_IWUSR,libc.S_IXUSR,libc.S_IRGRP,libc.S_IXGRP,libc.S_IROTH,libc.S_IXOTH);
	  DRM_DEV_MODE     = bor(libc.S_IRUSR,libc.S_IWUSR,libc.S_IRGRP,libc.S_IWGRP,libc.S_IROTH,libc.S_IWOTH);

	  DRM_DIR_NAME  ="/dev/dri";
	  DRM_DEV_NAME  ="%s/card%d";
	  DRM_CONTROL_DEV_NAME  ="%s/controlD%d";
	  DRM_RENDER_DEV_NAME  ="%s/renderD%d";
	  -- DRM_PROC_NAME "/proc/dri/" -- For backward Linux compatibility

	  DRM_ERR_NO_DEVICE  = -1001;
	  DRM_ERR_NO_ACCESS  = -1002;
	  DRM_ERR_NOT_ROOT   = -1003;
	  DRM_ERR_INVALID    = -1004;
	  DRM_ERR_NO_FD      = -1005;

	  DRM_AGP_NO_HANDLE =0;

    DRM_VBLANK_HIGH_CRTC_SHIFT = 1;

    DRM_NODE_PRIMARY = 0;
    DRM_NODE_CONTROL = 1;
    DRM_NODE_RENDER  = 2;

    DRM_EVENT_CONTEXT_VERSION = 2;
}




local function defined(x)
  return x
end

local F = {}

local function drmMsg(fmt, ...)
  io.write(string.format(fmt, ...);
end

local function F.drmMalloc(size)
    return libc.calloc(1, size);
end

local function F.drmFree(pt)
    libc.free(pt);
end

-- Call ioctl, restarting if it is interrupted
local function F.drmIoctl(fd, request, arg)
    local ret = nil;

    do 
        ret = libc.ioctl(fd, request, arg);
    while (ret == -1 and (ffi.errno() == libc.EINTR or ffi.errno() == libc.EAGAIN));
    
    return ret;
end

function F.drmOpenDevice 	(dev, minor) 	
    local devmode = C.DRM_DEV_MODE;
    local isroot  = libc.geteuid() == 0;

print("isroot: ", isroot)

if defined(XFree86Server) then
    local user    = C.DRM_DEV_UID;
    local group   = C.DRM_DEV_GID;
end

    local buf = string.format(C.DRM_DEV_NAME, C.DRM_DIR_NAME, minor);
    drmMsg("drmOpenDevice: node name is %s\n", buf);

if defined(XFree86Server) then
    --devmode  = xf86ConfigDRI.mode ? xf86ConfigDRI.mode : DRM_DEV_MODE;
    --devmode &= ~(S_IXUSR|S_IXGRP|S_IXOTH);
    --group = (xf86ConfigDRI.group >= 0) ? xf86ConfigDRI.group : DRM_DEV_GID;
end

    local st = ffi.new("stat_t")
    if (libc.stat(C.DRM_DIR_NAME, st)) then
      if (not isroot) then
        return C.DRM_ERR_NOT_ROOT;
      end

      libc.mkdir(C.DRM_DIR_NAME, C.DRM_DEV_DIRMODE);
      libc.chown(C.DRM_DIR_NAME, 0, 0); -- root:root 
      libc.chmod(C.DRM_DIR_NAME, C.DRM_DEV_DIRMODE);
    end

    -- Check if the device node exists and create it if necessary.
    if (libc.stat(buf, st) ~= 0) then
      if (not isroot) then
        return DRM_ERR_NOT_ROOT 
      end;

      libc.remove(buf);
      libc.mknod(buf, bor(libc.S_IFCHR, devmode), dev);
    end
if defined(XFree86Server) then
    chown(buf, user, group);
    chmod(buf, devmode);
end

    local fd = libc.open(buf, libc.O_RDWR, 0);
    --drmMsg("drmOpenDevice: open result is %d, (%s)\n",
    --        fd, fd < 0 ? libc.strerror(errno) : "OK");
    if (fd >= 0) then
      return fd;
    end

    --[[
     Check if the device node is not what we expect it to be, and recreate it
     * and try again if so.
    --]]
    if (st.st_rdev ~= dev) then
      if (not isroot) then
        return C.DRM_ERR_NOT_ROOT;
      end

      libc.remove(buf);
      libc.mknod(buf, bor(libc.S_IFCHR, devmode), dev);
if defined(XFree86Server) then
      libc.chown(buf, user, group);
      libc.chmod(buf, devmode);
end
    end
    fd = libc.open(buf, libc.O_RDWR, 0);
    --drmMsg("drmOpenDevice: open result is %d, (%s)\n",
    --        fd, fd < 0 ? libc.strerror(errno) : "OK");
    
    if (fd >= 0) then
      return fd;
    end

    drmMsg("drmOpenDevice: Open failed\n");
    libc.remove(buf);
    
    return -ffi.errno();
end


local exports = {
	
}
setmetatable(exports, {

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

    return nil;
  end,

})


return exports
