-- UDVDevice.lua
local libudev = require("libudev_ffi")
local UDVListIterator = require("UDVListIterator")

local UDVDevice = {}
setmetatable(UDVDevice, {
	__call = function(self, ...)
		return UDVDevice:new(...)
	end,
})
local UDVDevice_mt = {
	__index = UDVDevice;
}



function UDVDevice.init(self, ctxt, handle, syspath)
	local obj = {
		Context = ctxt;
		Handle = handle;

		Name = syspath;
		DevPath = libudev.safeffistring(libudev.udev_device_get_devpath(handle));		
		Subsystem = libudev.safeffistring(libudev.udev_device_get_subsystem(handle));		
		DevType = libudev.safeffistring(libudev.udev_device_get_devtype(handle));		
		SysPath = libudev.safeffistring(libudev.udev_device_get_syspath(handle));		
		SysName = libudev.safeffistring(libudev.udev_device_get_sysname(handle));		
		SysNum = libudev.safeffistring(libudev.udev_device_get_sysnum(handle));		
		DevNode = libudev.safeffistring(libudev.udev_device_get_devnode(handle));		
		Driver = libudev.safeffistring(libudev.udev_device_get_driver(handle));
		Action = libudev.safeffistring(libudev.udev_device_get_action(handle));
		
		IsInitialized = libudev.udev_device_get_is_initialized(handle)==1;
	}
	setmetatable(obj, UDVDevice_mt)

	return obj;
end

function UDVDevice.new(self, ctxt, syspath)
	local dev = libudev.udev_device_new_from_syspath(ctxt.Handle, syspath)
	if dev == nil then
		return nil;
	end

	return self:init(ctx, handle, syspath)
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
