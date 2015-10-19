-- Returns true if the subsystem is 'block'
-- and the devtype is 'disk'
-- This will catch all the RAM disks, loops, and others
--

local function isBlockDevice(dev)
	if dev.IsInitialized and dev:getProperty("subsystem") == "block" then
		return true;
	end

	return false;
end

return isBlockDevice
