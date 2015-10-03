-- predicate to determine if a device is of the input subsystem
return function(dev)
	if dev.IsInitialized and dev:getProperty("subsystem") == "input" then
		return true;
	end

	return false;
end