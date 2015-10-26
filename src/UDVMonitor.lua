--UDVMonitor.lua
local ffi = require("ffi")
local udev = require("libudev_ffi")
local UDVDevice = require("UDVDevice")


local UDVMonitor = {}
setmetatable(UDVMonitor, {
	__call = function(self, ...)
		return self:new(...);
	end,
})

local UDVMonitor_mt = {
	__index = UDVMonitor;
}


function UDVMonitor.init(self, mon)
	local obj = {
		Handle = mon;
		FileDescriptor = udev.udev_monitor_get_fd(mon);
	}
	setmetatable(obj, UDVMonitor_mt);

	-- add whatever filters
	--udev.udev_monitor_filter_remove(mon);

	-- turn on receiving
	--obj:enableReceiving();

	return obj;
end

function UDVMonitor.new(self, ctxt)
	local mon = udev.udev_monitor_new_from_netlink(ctxt.Handle, "udev")
	if mon == nil then
		return nil, "could not construct monitor"
	end

	ffi.gc(mon, udev.udev_monitor_unref);

	return self:init(mon);
end

function UDVMonitor.start(self)
	local res = udev.udev_monitor_enable_receiving(self.Handle);
	return res == 0;
end

-- Blocking call waiting for something to happen to a device
function UDVMonitor.receiveDevice(self)
	local dev_handle = nil;

	repeat
		dev_handle = udev.udev_monitor_receive_device(self.Handle)
	until dev_handle ~= nil;

	--print("UDVMonitor.receiveDevice: ", dev_handle)

	local dev = UDVDevice:newFromHandle(dev_handle);

	return dev;
end

-- An iterator over the events 
function UDVMonitor.events(self)
	local function event_gen(param, state)
		local dev_handle = nil;
		repeat 
			-- wait for activity on file descriptor
			-- then receive_device
			dev_handle = udev.udev_monitor_receive_device(param.Handle)
		until dev_handle ~= nil;

		return state, UDVDevice:newFromHandle(dev_handle)
	end

	return event_gen, self, self
end

return UDVMonitor
