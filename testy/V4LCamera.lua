--V4LCamera.lua
local bit = require("bit")
local bor, band, lshift, rshift = bit.bor, bit.band, bit.lshift, bit.rshift

local libc = require("libc")


local V4LCamera = {}
setmetatable(V4LCamera, {
	__call = function(self, ...)
		return self:new(...);
	end,
})

local V4LCamera_mt = {
	__index = V4LCamera;
}

function V4LCamera.init(self, fd)
	local obj = {
		Handle = fd;
	}
	setmetatable(obj, V4LCamera_mt)

	return obj;
end

function V4LCamera.new(self, dev_name)
	-- open the specified device name
	local fd = libc.open(dev_name, bor(libc.O_RDWR));

	if fd == -1 then return nil; end

	-- if successful, initialize and return
	return self:init(fd);
end

return V4LCamera
