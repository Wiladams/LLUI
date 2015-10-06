local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor
local band = bit.band

local xf86drm = require("xf86drm_ffi")()
local xf86drmMode = require("xf86drmMode_ffi")
local libc = require("libc")()

local DRMCardConnector = require("DRMCardConnector")





local function openDRMCard(nodename)
	nodename = nodename or "/dev/dri/card0";
	local flags = bor(O_RDWR, O_CLOEXEC);
	local fd = libc.open(nodename, flags)
	if fd < 0 then 
		return false, libc.strerror(ffi.errno());
	end

	return fd;
end


local DRMCard = {}
setmetatable(DRMCard, {
	__call = function(self, ...)
		return self:new(...)
	end,
})

local DRMCard_mt = {
	__index = DRMCard;
}

function DRMCard.init(self, fd)
	local obj = {
		Handle = fd;
		Connectors = {};
	}
	setmetatable(obj, DRMCard_mt)

	obj:prepare();

	return obj;
end

function DRMCard.new(self, cardname)
	local fd, err = openDRMCard(cardname);

	if not fd then
		return false, err;
	end

	return self:init(fd);
end

function DRMCard.getBusId(self)
	local id = drmGetBusid(self.Handle);
	if id == nil then
		return "UNKNOWN"
	end

	return ffi.string(id);
end

function DRMCard.getVersion(self)
	local ver =  drmGetVersion(self.Handle); -- drmVersionPtr
	ffi.gc(ver, drmFreeVersion);

	return ver;
end

function DRMCard.getLibVersion(self)
	local ver =  drmGetLibVersion(self.Handle); -- drmVersionPtr
	ffi.gc(ver, drmFreeVersion);

	return ver;
end




function DRMCard.getStats(self)
	local stats = ffi.new("drmStatsT");
	local res = drmGetStats(self.Handle, stats);
	if res ~= 0 then
		return false;
	end

--print("DRMCard:getStats, count: ", tonumber(stats.count));

	local tbl = {}
	local counter = tonumber(stats.count)
	while counter > 0 do
		local idx = counter - 1;
		local entry = {
			Value = stats.data[idx].value;

			LongFormat = stringvalue(stats.data[idx].long_format);
			LongName = stringvalue(stats.data[idx].long_format);
			RateFormat = stringvalue(stats.data[idx].long_format);
			RateName = stringvalue(stats.data[idx].long_format);
			MultiplierName = stringvalue(stats.data[idx].long_format);
			MultiplierValue = stats.data[idx].mult;
			IsValue = stats.data[idx].isvalue;
			Verbose = stats.data[idx].verbose;
		}

		table.insert(tbl, entry);

		counter = counter - 1;
	end

	return tbl
end

function DRMCard.hasDumbBuffer(self)
	local has_dumb_p = ffi.new("uint64_t[1]");
	local res = drmGetCap(self.Handle, DRM_CAP_DUMB_BUFFER, has_dumb_p)

	if res ~= 0 then
		return false, "EOPNOTSUPP"
	end

	return has_dumb_p[0] ~= 0;
end

function DRMCard.getConnector(self, id)
	return DRMCardConnector(self.Handle, id)
end


function DRMCard.prepare(self)

--	struct modeset_dev *dev;

	-- retrieve resources */
	local res = xf86drmMode.drmModeGetResources(self.Handle);
	if (res == nil) then
		return false, strerror();
	end
	
	ffi.gc(res, xf86drmMode.drmModeFreeResources)

	self.Resources = {}


	-- iterate all the connectors
	local count = res.count_connectors;
	while (count > 0 ) do
		local idx = count-1;

		local conn, err = self:getConnector(res.connectors[idx])
		if conn ~= nil then
			table.insert(self.Connectors, conn);
		end

		count = count - 1;
	end

	return true;
end

-- iterate through the various connectors, returning
-- the ones that are actually connected.
function DRMCard.connections(self)
	local function iter(param, idx)
		local connection = nil;

		if idx > #self.Connectors then 
			return connection;
		end

		while idx <= #self.Connectors do
			if self.Connectors[idx].Connection == ffi.C.DRM_MODE_CONNECTED and
				self.Connectors[idx].ModeCount > 0 then
				break;
			end
			idx = idx + 1;
		end

		if idx > #self.Connectors then
			return nil;
		end

		return idx+1, self.Connectors[idx];
	end

	return iter, self, 1
end

function DRMCard.getDefaultConnection(self)
	for _, connection in self:connections() do
		return connection;
	end

	return nil;
end

function DRMCard.getDefaultFrameBuffer(self)
	local connection = self:getDefaultConnection();
	assert(connection, "DRMCard.getDefaultConnection")

	return connection.Encoder.CrtController.FrameBuffer;
end

function DRMCard.getEncoder(self, id)
	local enc = drmModeGetEncoder(self.Handle, id);
	
	if enc == nil then return false, "could not create encoder" end
	
	ffi.gc(enc, drmModeFreeEncoder);

	return DRMEncoder:init(enc);
end

function DRMCard.print(self)
	print("Supports Mode Setting: ", self:supportsModeSetting())
	for _, connector in ipairs(self.Connectors) do
		print("---- Connector ----")
		connector:print();
	end

end

function DRMCard.supportsModeSetting(self)
	local res = xf86drmMode.drmCheckModesettingSupported(self:getBusId());
	return res == 1;
end

return DRMCard
