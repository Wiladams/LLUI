--V4LCamera.lua
local ffi = require("ffi")
local bit = require("bit")
local bor, band, lshift, rshift = bit.bor, bit.band, bit.lshift, bit.rshift

local libc = require("libc")
local vd2 = require("videodev2")


local function xioctl(fd, request, param)
    local r;

    repeat 
        r = libc.ioctl(fd, request, param);
    until (-1 ~= r or (libc.errnos.EINTR ~= ffi.errno()));

    return r;
end


local V4LCamera = {}
setmetatable(V4LCamera, {
	__call = function(self, ...)
		return self:new(...);
	end,
})

local V4LCamera_mt = {
	__index = V4LCamera;
}

function V4LCamera.init(self, fd, dev_name)
	local obj = {
		Handle = fd;
		DevNode = dev_name;
	}
	setmetatable(obj, V4LCamera_mt)

	return obj;
end

function V4LCamera.new(self, dev_name)
	-- open the specified device name
	local fd = libc.open(dev_name, libc.O_RDWR);

	if fd == -1 then return nil; end

	-- if successful, initialize and return
	return self:init(fd, dev_name);
end

--[[
struct v4l2_capability {
	uint8_t	driver[16];
	uint8_t	card[32];
	uint8_t	bus_info[32];
	uint32_t   version;
	uint32_t	capabilities;
	uint32_t	device_caps;
	uint32_t	reserved[3];
};
--]]
function V4LCamera.capabilities(self)
    local cap = ffi.new("struct v4l2_capability");
    local cropcap = ffi.new("struct v4l2_cropcap");
    local crop = ffi.new("struct v4l2_crop");
    local fmt = ffi.new("struct v4l2_format");
    
    if (-1 == xioctl(self.Handle, vd2.Constants.VIDIOC_QUERYCAP, cap)) then
        if (libc.errnos.EINVAL == ffi.errno() or (libc.errnos.ENOTTY == ffi.errno())) then
            io.stderr:write(string.format("%s is no V4L2 device\n", self.DevNode));
            error();
        else
        	return false,"VIDIOC_QUERYCAP" 
        end
    end

    print("      driver: ", ffi.string(cap.driver));
    print("        card: ", ffi.string(cap.card));
    print("         bus: ", ffi.string(cap.bus_info));
    print("capabilities: ", string.format("%#x", cap.capabilities));
end

-- enumerate the available formats
function V4LCamera.formats(self)

	local function gen(param, state)
		local fmtdesc = ffi.new("struct v4l2_fmtdesc")
		fmtdesc.type = videodev2.Enums.v4l2_buf_type.V4L2_BUF_TYPE_VIDEO_CAPTURE;
print("fmtdesc.type: ", fmtdesc.type)
--print("fd: ", param)
--print(string.format("VIDIOC_ENUM_FMT: %x (%s)", videodev2.Constants.VIDIOC_ENUM_FMT, type(videodev2.Constants.VIDIOC_ENUM_FMT)))
		local res = libc.ioctl(param, videodev2.Constants.VIDIOC_ENUM_FMT, fmtdesc)
		if res == -1 then
			print("ERROR: ", res, libc.strerror())
			return nil;
		end

		return state + 1, fmtdesc;
	end

	return gen, self.Handle, 0
end

return V4LCamera
