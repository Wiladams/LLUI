-- UDVContext.lua
local ffi = require("ffi")
local libudev = require("libudev_ffi")
local UDVListIterator = require("UDVListIterator")
local UDVListEntry = require("UDVListEntry")
local UDVDevice = require("UDVDevice")
local UDVMonitor = require("UDVMonitor")


local UDVContext = {}
setmetatable(UDVContext, {
	__call = function(self, ...)
		return self:new(...);
	end,

})

local UDVContext_mt = {
	__index = UDVContext;
}


function UDVContext.init(self, handle)
	local obj = {
		Handle = handle;
	}
	setmetatable(obj, UDVContext_mt);
	
	return obj;
end

function UDVContext.new(self)
	local udev = libudev.udev_new();
	if udev == nil then
		return nil, "error with udev_new()"
	end

	ffi.gc(udev, libudev.udev_unref);
	
	return self:init(udev)
end

function UDVContext.newFromHandle(self, handle)
	ffi.gc(handle, libudev.udev_unref)

	return self:init(handle);
end

function UDVContext.createMonitor(self)
	return UDVMonitor(self);
end

function UDVContext.deviceFromSysPath(self, syspath)
	return UDVDevice(self.Handle, syspath);
end

-- Iterators

--[[
	When you scan_devices, the Name field contains the system
	path of the device.  This value can be used in a subsequent 
	call to get the actual device: 
		udev_device_new_from_syspath(udev, syspath)

--]]
-- gen, param, state
local function UDVDeviceIterator(ctxt, currentEntry)
	--print("UDVListIterator: ", currentEntry, handle)
	if currentEntry == nil then
		return nil;
	end
	
	local entry = UDVListEntry(currentEntry)
	-- if we have an entry, but for some reason the name == nil
	-- then just return nil
	if entry.Name == nil then
		return nil;
	end
	
	-- get the next entry before returning
	local nextEntry = libudev.udev_list_entry_get_next(currentEntry)
	--print("nextEntry: ", nextEntry)
	
	-- return nextState, currentState
	return nextEntry, ctxt:deviceFromSysPath(entry.Name);
end

function UDVContext.devices(self)
	-- create the query object
	local enumerate = libudev.udev_enumerate_new(self.Handle);
	--ffi.gc(enumerate, libudev.udev_enumerate_unref);

	-- fill it with results
	local res = libudev.udev_enumerate_scan_devices(enumerate);

	-- get the results
	local listEntry = libudev.udev_enumerate_get_list_entry(enumerate);

	return UDVDeviceIterator, self, listEntry 
end 

function UDVContext.subsystems(self)
	local enumerate = libudev.udev_enumerate_new(self.Handle);
	ffi.gc(enumerate, libudev.udev_enumerate_unref);

	local res = libudev.udev_enumerate_scan_subsystems(enumerate);

	local listEntry = libudev.udev_enumerate_get_list_entry(enumerate);
	
	return  UDVListIterator, listEntry, listEntry
end 

return UDVContext
