--DRMEncoder.lua
local ffi = require("ffi")
local xf86drmMode_ffi = require("xf86drmMode_ffi")
local DRMCrtController = require("DRMCrtController")

local EncoderType = {
	[0] = "NONE";
	[1] = "DAC";
	[2] = "TMDS";
	[3] = "LVDS";
	[4] = "TVDAC";
	[5] = "VIRTUAL";
	[6] = "DSI";
	[7] = "DPMST";
}

local DRMEncoder = {}
setmetatable(DRMEncoder, {
	__call = function(self, ...)
		return self:new(...);
	end,
})

local DRMEncoder_mt = {
	__index = DRMEncoder;
	__tostring = function(self)
		return self:toString();
	end;
}

--[[
ffi.cdef[[
typedef struct _drmModeEncoder {
  uint32_t encoder_id;
  uint32_t encoder_type;
  uint32_t crtc_id;
  uint32_t possible_crtcs;
  uint32_t possible_clones;
} drmModeEncoder, *drmModeEncoderPtr;
]]
--]]
function DRMEncoder.init(self, fd, handle)
	local obj = {
		CardFd = fd;

		RawInfo = handle;	-- drmModeEncoderPtr

		Id = handle.encoder_id;
		Type = handle.encoder_type;
		CrtcId = handle.crtc_id;
		PossibleCrtcs = handle.possible_crtcs;
		PossibleClones = handle.possible_clones;
	}
	setmetatable(obj, DRMEncoder_mt);

	obj.CrtController = DRMCrtController(fd, handle.crtc_id);

	return obj;
end

function DRMEncoder.new(self, fd, id)
	local enc = xf86drmMode_ffi.drmModeGetEncoder(fd, id);
	
	if enc == nil then return false, "could not create encoder" end
	
	ffi.gc(enc, xf86drmMode_ffi.drmModeFreeEncoder);

	return DRMEncoder:init(fd, enc);
end

function DRMEncoder.toString(self)
	return string.format([[
             Id: %s
           Type: %s
         CrtcId: %d 
  PossibleCrtcs: %d 
]],
	self.Id,
	EncoderType[self.Type],
	self.CrtcId,
	self.PossibleCrtcs)

end

function DRMEncoder.print(self)
	print("---- DRMEncoder ----")
	print(tostring(self));
	if self.CrtController then
		self.CrtController:print();
	end
end

-- if crtc_id specified, it is a setter
-- if not specified, it is a getter
function DRMEncoder.crtc(self, crtc_id)
end

return DRMEncoder;
