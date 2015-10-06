local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor
local band = bit.band

local xf86drm = require("xf86drm_ffi")()
local xf86drmMode = require("xf86drmMode_ffi")()
local libc = require("libc")()
local ctxt, err = require("UDVContext")()
local fun = require("fun")
local DRMCard = require("DRMCard")



local function isDrmCard(dev)
	return dev.IsInitialized and
		dev:getProperty("SUBSYSTEM") == 'drm' and
		dev:getProperty("MAJOR") == '226' and
		dev.SysName:find("card")
		
end

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

--[[
	An iterator that returns DRMCards for all the libudev reported
	devices that look like /dev/dri/cardxxx
--]]
function DRMEnvironment.cards(self)
	local function deviceToDrmCard(dev)
		print(dev.SysName)
		return DRMCard(dev.DevNode)
	end

	return fun.map(deviceToDrmCard,  fun.filter(isDrmCard, ctxt:devices()))
end

return DRMEnvironment
