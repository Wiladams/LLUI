-- ltfl - Lua Tools For Linux (light fall)
--
-- Returns true if the subsystem is 'block'
-- and the devtype is 'disk'
-- and it has a ID_BUS that is not NULL
-- and the ID_TYPE is 'disk'
--
-- This will also catch those usb thumb drives

local function isPhysicalDisk(dev)
	if dev.IsInitialized and dev:getProperty("subsystem") == "block" and
		dev:getProperty("DEVTYPE") == "disk" and
		dev:getProperty("ID_BUS") ~= nil and
		dev:getProperty("ID_TYPE") == "disk" then
		return true;
	end

	return false;
end

return isPhysicalDisk
