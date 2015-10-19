-- Returns true if the subsystem is 'block'
-- and the devtype is 'disk'
-- and it has a ID_BUS that is not NULL
--

local function isPhysicalBlockDevice(dev)
	if dev.IsInitialized and dev:getProperty("subsystem") == "block" and
		dev:getProperty("devtype") == "disk" and
		dev:getProperty("ID_BUS") ~= nil then
		return true;
	end

	return false;
end

return isPhysicalBlockDevice
