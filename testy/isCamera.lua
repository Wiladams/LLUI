-- predicate to determine if a device is a DRM device and it's active
return function(dev)
	if dev.IsInitialized and 
		dev:getProperty("subsystem") == "video4linux" and
		dev:getProperty("COLORD_KIND") == "camera" then
		return true;
	end

	return false;
end

