local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor
local band = bit.band

local xf86drm = require("xf86drm_ffi")()
local xf86drmMode = require("xf86drmMode_ffi")()
local libc = require("libc")()


local DRMEnvironment = {}
function DRMEnvironment.available(self)
	return drmAvailable() == 1;
end

function DRMEnvironment.open(self, nodename)
	nodename = nodename or "/dev/dri/card0";
	local flags = bor(libc.O_RDWR, libc.O_CLOEXEC);
	local fd = libc.open(nodename, flags)
	if fd < 0 then 
		return false, libc.strerror(ffi.errno());
	end

	return fd;
end


return DRM
