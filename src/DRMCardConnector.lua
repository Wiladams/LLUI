local ffi = require("ffi")
local xf86drmMode = require("xf86drmMode_ffi")

local DRMCardMode = require("DRMCardMode")
local DRMEncoder = require("DRMEncoder")

-- list of types of connectors
local ConnectorType = {
	 [0] = "Unknown";
	 [1] = "VGA";
	 [2] = "DVII";
	 [3] = "DVID";
	 [4] = "DVIA";
	 [5] = "Composite";
	 [6] = "SVIDEO";
	 [7] = "LVDS";
	 [8] = "Component";
	 [9] = "9PinDIN";
	[10] = "DisplayPort";
	[11] = "HDMIA";
	[12] = "HDMIB";
	[13] = "TV";
	[14] = "eDP";
	[15] = "VIRTUAL";
	[16] = "DSI";
}

--[[
typedef struct _drmModeConnector {
  uint32_t connector_id;
  uint32_t encoder_id; /**< Encoder currently connected to */
  uint32_t connector_type;
  uint32_t connector_type_id;
  drmModeConnection connection;
  uint32_t mmWidth, mmHeight; /**< HxW in millimeters */
  drmModeSubPixel subpixel;

  int count_modes;
  drmModeModeInfoPtr modes;

  int count_props;
  uint32_t *props; /**< List of property ids */
  uint64_t *prop_values; /**< List of property values */

  int count_encoders;
  uint32_t *encoders; /**< List of encoder ids */
} drmModeConnector, *drmModeConnectorPtr;
--]]
local DRMCardConnector = {}
setmetatable(DRMCardConnector, {
	__call = function(self, ...)
		return self:new(...)
	end,
})

local DRMCardConnector_mt = {
	__index = DRMCardConnector;

	__tostring = function(self)
		return string.format([[
        ID: %d
Encoder ID: %d
      Type: %s
   Type ID: %d
Connection: %d

 Size (mm): %dx%d

     Modes: %d
     Props: %d
  Encoders: %d
]],
	self.Id,
	self.EncoderId,
	ConnectorType[self.Type],
	self.TypeId,
	self.Connection,
	self.MMWidth,
	self.MMHeight,
	self.ModeCount,
	self.PropsCount,
	#self.EncoderIds)
	end;
}

function DRMCardConnector.init(self, fd, conn)
	local obj = {
		CardFd = fd;

		Id = conn.connector_id;
		EncoderId = conn.encoder_id;
		Type = tonumber(conn.connector_type);
		TypeId = conn.connector_type_id;
		Connection = tonumber(conn.connection);		-- state of the connection; CONNECTED, DISCONNECTED, UNKNOWN
		MMWidth = conn.mmWidth;
		MMHeight = conn.mmHeight;

		Modes = {};
		Props = {};
		EncoderIds = {};

		ModeCount = conn.count_modes;
		PropsCount = conn.count_props;
--		EncoderCount = conn.count_encoders;
	}
	setmetatable(obj, DRMCardConnector_mt);

	-- get the modes
	local idx = 0;
	while (idx < tonumber(conn.count_modes) ) do
		local mode = DRMCardMode(conn.modes[idx])

		table.insert(obj.Modes, mode);

		idx = idx + 1;
	end

	-- Get the current encoder
	obj.Encoder = DRMEncoder(fd, conn.encoder_id);
	
	-- get the encoder ids
	idx = 0;
	while (idx < conn.count_encoders) do
		table.insert(obj.EncoderIds, tonumber(conn.encoders[idx]))
		idx = idx + 1;
	end


	return obj;
end


function DRMCardConnector.new(self, fd, connector_id)
	local conn = xf86drmMode.drmModeGetConnector(fd, connector_id);
	if conn == nil then
		return false, strerror();
	end
	ffi.gc(conn, xf86drmMode.drmModeFreeConnector);

	return self:init(fd, conn);
end

function DRMCardConnector.isConnected(self)
	return self.Connection == ffi.C.DRM_MODE_CONNECTED;
end

-- set and get current mode
-- if called without a value, it is a getter
-- if called with a value, it is a setter
function DRMCardConnector.mode(self, value)

end

-- iterator over the encoders
function DRMCardConnector.encoders(self)
	local function encoder_gen(param, idx)
		if idx > #param.EncoderIds then
			return nil;
		end

		return idx + 1, DRMEncoder(param.CardFd, param.EncoderIds[idx])
	end

	return encoder_gen, self, 1;
end

function DRMCardConnector.print(self)
	print(tostring(self))
	
	-- Modes
	for _, mode in ipairs(self.Modes) do
		print("---- mode ----")
		print(mode)
	end

	-- Encoders
	for _, encoder in self:encoders() do
		encoder:print()
	end
end

return DRMCardConnector;
