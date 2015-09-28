
local ffi = require("ffi")
local libudev = require("libudev_ffi")

local UDVListIterator = require("UDVListIterator")


local UDVHwdb = {}
setmetatable(UDVHwdb, {
	__call = function(self, ...)
		return self:new(...)
	end,
})

local UDVHwdb_mt = {
	__index = UDVHwdb;
}

function UDVHwdb.init(self, handle)
	local obj = {
		Handle = handle;
	}
	setmetatable(obj, UDVHwdb_mt);

	return obj;
end


function UDVHwdb.new(self, ctxt)
	if not ctxt then
		ctxt = libudev.udev_new()
		ffi.gc(ctxt, libudev.udev_unref)
	end

	local handle = libudev.udev_hwdb_new(ctxt);
	if handle == nil then
		return false, "hwdb_new failed"
	end
	ffi.gc(handle, libudev.udev_hwdb_unref);

	return self:init(handle);
end



function UDVHwdb.entries(self, modalias, flags)
	flags = flags or 0;

	local listEntry = libudev.udev_hwdb_get_properties_list_entry(self.Handle, modalias, flags);

	return UDVListIterator(listEntry);
end

return UDVHwdb
