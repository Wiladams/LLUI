-- UDVDevice.lua
local libudev = require("libudev_ffi")

local UDVListIterator = require("UDVListIterator")
local libc = require("libc")


local UDVDevice = {}
setmetatable(UDVDevice, {
	__call = function(self, ...)
		return UDVDevice:new(...)
	end,
})
local UDVDevice_mt = {
	__index = UDVDevice;
}



function UDVDevice.init(self, handle)
	--local ctxt = UDVContext(libudev.udev_device_get_udev(handle))
	--print("UDVDevice.init: ", handle)

	local obj = {
		Handle = handle;

		DevPath = libc.safeffistring(libudev.udev_device_get_devpath(handle));		
		Subsystem = libc.safeffistring(libudev.udev_device_get_subsystem(handle));		
		DevType = libc.safeffistring(libudev.udev_device_get_devtype(handle));		
		SysPath = libc.safeffistring(libudev.udev_device_get_syspath(handle));		
		SysName = libc.safeffistring(libudev.udev_device_get_sysname(handle));		
		SysNum = libc.safeffistring(libudev.udev_device_get_sysnum(handle));		
		DevNode = libc.safeffistring(libudev.udev_device_get_devnode(handle));		
		Driver = libc.safeffistring(libudev.udev_device_get_driver(handle));
		Action = libc.safeffistring(libudev.udev_device_get_action(handle));
		
		IsInitialized = libudev.udev_device_get_is_initialized(handle)==1;
	}
	obj.Name = obj.SysPath;

	setmetatable(obj, UDVDevice_mt)

	return obj;
end

function UDVDevice.new(self, ctxt, syspath)
	local dev = libudev.udev_device_new_from_syspath(ctxt, syspath)
	if dev == nil then
		return nil;
	end

	return self:init(dev)
end

function UDVDevice.newFromHandle(self, device_handle)
	return self:init(device_handle);
end

function UDVDevice.action(self)
	return libc.safeffistring(libudev.udev_device_get_action(self.Handle));
end

-- iterate over all the properties of the device
function UDVDevice.properties(self)
	local listEntry = libudev.udev_device_get_properties_list_entry(self.Handle);

	return UDVListIterator, listEntry, listEntry;
end

-- retrieve the value of a single property
function UDVDevice.getProperty(self, name)
	name = name:lower()
	for _, prop in self:properties() do 
		if name == prop.Name:lower() then
			return prop.Value;
		end
	end

	return nil;
end

-- iterate over all the tags for the device
-- tags are nothing more than the 'TAGS' property broken out
-- into a convenient API
function UDVDevice.tags(self)
	local listEntry = libudev.udev_device_get_tags_list_entry(self.Handle);

	return UDVListIterator, listEntry, listEntry;
end

return UDVDevice
