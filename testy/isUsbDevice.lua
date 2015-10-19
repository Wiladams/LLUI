-- Returns true if the subsystem is 'usb'
-- and the devtype is 'usb_device'
--

local function isUsbDevice(dev)
	if dev.IsInitialized and dev:getProperty("subsystem") == "usb" and
		dev:getProperty("devtype") == "usb_device" then
		return true;
	end

	return false;
end

return isUsbDevice
