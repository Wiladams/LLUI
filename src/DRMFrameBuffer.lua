local ffi = require("ffi")
local bit = require("bit")
local bor, band, lshift, rshift = bit.bor, bit.band, bit.lshift, bit.rshift

local xf86drmMode = require("xf86drmMode_ffi")
local xf86drm = require("xf86drm_ffi")
local drm = require("drm")
local libc = require("libc")


-- just a little mmap helper

local function emmap(addr, len, prot, flag, fd, offset)
	local mapPtr = libc.mmap(addr, len, prot, flag, fd, offset);

	local fp = ffi.cast("uint32_t *", mapPtr);
	if (fp == libc.MAP_FAILED) then
		error("mmap");
	end
	--ffi.gc(fp, libc.munmap);

	return fp;
end



local DRMFrameBuffer = {}
setmetatable(DRMFrameBuffer, {
	__call = function(self, ...)
		return self:new(...);
	end,
})
local DRMFrameBuffer_mt = {
	__index = DRMFrameBuffer;
	__tostring = function(self)
		return self:toString();
	end;
}

--[[
typedef struct _drmModeFB {
  uint32_t fb_id;
  uint32_t width, height;
  uint32_t pitch;
  uint32_t bpp;
  uint32_t depth;
  /* driver specific handle */
  uint32_t handle;
} drmModeFB, *drmModeFBPtr;
--]]


function DRMFrameBuffer.init(self, fd, rawInfo, dataPtr)
	local obj = {
		CardFd = fd;
		RawInfo = rawInfo;
		DataPtr = dataPtr;

		Id = rawInfo.fb_id;
		Width = rawInfo.width;
		Height = rawInfo.height;
		Pitch = rawInfo.pitch;
		BitsPerPixel = rawInfo.bpp;
		Depth = rawInfo.depth;

		DriverHandle = rawInfo.handle;
	}	
	setmetatable(obj, DRMFrameBuffer_mt)

	return obj;
end

function DRMFrameBuffer.new(self, fd, bufferId, dataPtr)
	local rawInfo =  xf86drmMode.drmModeGetFB(fd, bufferId);
	if rawInfo == nil then return nil, "could not get FB" end

	ffi.gc(rawInfo, xf86drmMode.drmModeFreeFB);

	return self:init(fd, rawInfo, dataPtr);
end

--[[
/* create a dumb scanout buffer */
struct drm_mode_create_dumb {
	uint32_t height;
	uint32_t width;
	uint32_t bpp;
	uint32_t flags;
	/* handle, pitch, size will be returned */
	uint32_t handle;
	uint32_t pitch;
	uint64_t size;
};
--]]
function DRMFrameBuffer.newScanoutBuffer(self, card, width, height, bpp, depth)
	bpp = bpp or 32
	depth = depth or 24

	local fd = card.Handle;
	local creq = ffi.new("struct drm_mode_create_dumb");

	-- We need to make a drmIoctl call passing in a partially filled
	-- in data structure.  We need to find out the handle, pitch and size
	-- fields, for the given width and height
	creq.width = width;
	creq.height = height;
	creq.bpp = bpp;
	creq.flags = 0;

	if (xf86drm.drmIoctl(fd, drm.DRM_IOCTL_MODE_CREATE_DUMB, creq) < 0) then
		return nil, "drmIoctl DRM_IOCTL_MODE_CREATE_DUMB failed";
	end



	-- Now that we have the pitch and size stuff filled out, 
	-- we need to allocate the frame buffer, and get the
	-- new ID that is associated with it.
	local buf_idp = ffi.new("uint32_t[1]");
	if (xf86drmMode.drmModeAddFB(fd, width, height,
		depth, bpp, creq.pitch, creq.handle, buf_idp) ~= 0) then
		error("drmModeAddFB failed");
	end
	local buf_id = tonumber(buf_idp[0]);

--print("buf_id: ", buf_id)

	-- With the framebuffer in hand, we now can allocate memory and 
	-- map it, and 
	local mreq = ffi.new("struct drm_mode_map_dumb");
	mreq.handle = creq.handle;
	if (xf86drm.drmIoctl(fd, drm.DRM_IOCTL_MODE_MAP_DUMB, mreq) ~= 0) then
		error("drmIoctl DRM_IOCTL_MODE_MAP_DUMB failed");
	end

--print(string.format("mreq [handle, pad, offset]: %d %d %p", mreq.handle, mreq.pad, ffi.cast("intptr_t",mreq.offset)))

	local dataPtr = emmap(nil, creq.size, bor(libc.PROT_READ, libc.PROT_WRITE), libc.MAP_SHARED, fd, mreq.offset);
--print("dataPtr: ", dataPtr)

	return DRMFrameBuffer(card.Handle, buf_id, dataPtr);
end

function DRMFrameBuffer.getDataPtr(self)
	local fd = self.CardFd;
	local fbcmd = ffi.new("struct drm_mode_fb_cmd");
	fbcmd.fb_id = self.Id;


	local res = xf86drm.drmIoctl(fd, drm.DRM_IOCTL_MODE_GETFB, fbcmd)
	if res < 0 then
		return nil, "drmIoctl DRM_IOCTL_MODE_CREATE_DUMB failed";
	end

--	print("DRMFrameBuffer.getDataPtr(), [width, height, pitch, handle]: ", fbcmd.width, fbcmd.height, fbcmd.pitch, fbcmd.handle);

	local mreq = ffi.new("struct drm_mode_map_dumb");
	mreq.handle = fbcmd.handle;
	if (xf86drm.drmIoctl(self.CardFd, drm.DRM_IOCTL_MODE_MAP_DUMB, mreq) ~= 0) then
		error("drmIoctl DRM_IOCTL_MODE_MAP_DUMB failed");
	end

--print(string.format("mreq [handle, pad, offset]: %d %d %p", mreq.handle, mreq.pad, ffi.cast("intptr_t",mreq.offset)))

	local size = fbcmd.pitch*fbcmd.height;
	local dataPtr = emmap(nil, size, bor(libc.PROT_READ, libc.PROT_WRITE), libc.MAP_SHARED, fd, mreq.offset);

	return dataPtr
end

function DRMFrameBuffer.toString(self)
	return string.format([[
           Id: %d 
         Size: %d X %d 
        Pitch: %d 
 BitsPerPixel: %d 
        Depth: %d 
Driver Handle: %s
Data: %p
]],
	self.Id,
	self.Width, self.Height,
	self.Pitch,
	self.BitsPerPixel,
	self.Depth,
	self.DriverHandle,
	self.DataPtr);
end


return DRMFrameBuffer
