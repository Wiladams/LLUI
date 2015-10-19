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
	obj:enableReceiving();

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

function UDVMonitor.enableReceiving(self)
	local res = udev.udev_monitor_enable_receiving(self.Handle);
	return res == 0;
end

-- Blocking call waiting for something to happen to a device
function UDVMonitor.receiveDevice(self)
	return UDVDevice:newFromHandle(udev.udev_monitor_receive_device(self.Handle));
end


return UDVMonitor
