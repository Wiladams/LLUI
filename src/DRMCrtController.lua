local ffi = require("ffi")
local xf86drmMode = require("xf86drmMode_ffi")
local DRMCardMode = require("DRMCardMode")
local DRMFrameBuffer = require("DRMFrameBuffer")


local DRMCrtController = {}
setmetatable(DRMCrtController, {
	__call = function(self, ...)
		return self:new(...);
	end,
})

local DRMCrtController_mt = {
	__index = DRMCrtController;
	__tostring = function(self)
		return self:toString();
	end;
}

--[[
ffi.cdef[[
typedef struct _drmModeCrtc {
  uint32_t crtc_id;
  uint32_t buffer_id; /**< FB id to connect to 0 = disconnect */

  uint32_t x, y; /**< Position on the framebuffer */
  uint32_t width, height;
  int mode_valid;
  drmModeModeInfo mode;

  int gamma_size; /**< Number of gamma stops */

} drmModeCrtc, *drmModeCrtcPtr;
]]
--]]


function DRMCrtController.init(self, fd, crtcptr)
	local obj = {
		Fd = fd;
		Handle = crtcptr;

		Id = crtcptr.crtc_id;

		-- Frame buffer id to connect to, 0 == disconnect
		FrameBufferId = crtcptr.buffer_id;

		-- Position on frame buffer
		PositionX = crtcptr.x;
		PositionY = crtcptr.y;

		Width = crtcptr.width;
		Height = crtcptr.height;

		ValidMode = crtcptr.mode_valid;

		Mode = DRMCardMode(crtcptr.mode);

		-- number of gamma stops
		GammaStops = crtcptr.gamma_size;
	}
	setmetatable(obj, DRMCrtController_mt);

	obj.FrameBuffer = DRMFrameBuffer(fd, crtcptr.buffer_id)

	return obj;
end

function DRMCrtController.new(self, fd, crtc_id)
	local crtcptr = xf86drmMode.drmModeGetCrtc(fd, crtc_id);
	if crtcptr == nil then
		return nil, "could not create crtcptr"
	end
	ffi.gc(crtcptr, xf86drmMode.drmModeFreeCrtc);

	return self:init(fd, crtcptr);
end

function DRMCrtController.toString(self)
	return string.format([[
             Id: %d
Frame Buffer Id: %d 

       Position: %dx%d 
           Size: %dx%d 
      ValidMode: %d 
    Gamma Stops: %d 
]],
	self.Id,
	self.FrameBufferId,
	self.PositionX,
	self.PositionY,
	self.Width,
	self.Height,
	self.ValidMode,
	self.GammaStops);
end

function DRMCrtController.print(self)
	print("---- CRT Controller ----")
	print(tostring(self));
	print("---- CRT Controller Mode ----")
	print(self.Mode);
	print("---- CRT Frame Buffer ----")
	print(self.FrameBuffer);
end

return DRMCrtController
