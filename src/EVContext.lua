--EVContext.lua
local ffi = require("ffi")
local evdev = require("evdev")
local EVDevice = require("EVDevice")


EVContext = {}
function EVContext.newDevice(self)
	local dev = evdev.libevdev_new();
	ffi.gc(dev, evdev.libevdev_free);

	return EVDevice:init(dev);
end

function EVContext.setLogFunction(self, logfunc, data)
	evdev.libevdev_set_log_function(logfunc, data);

	return true;
end

function EVContext.logPriority(self, priority)
	if not priority then
		return tonumber(evdev.libevdev_get_log_priority());
	end

	evdev.libevdev_set_log_priority(priority);
end

function EVContext.devices(self, type, code)
	local function dev_iter(param, idx)
		-- create device
		local devname = "/dev/input/event"..tostring(idx);
		local dev, err = EVDevice(devname)

		if not dev then
			return nil; 
		end

		return idx+1, dev
	end

	return dev_iter, self, 0
end

function EVContext.getDevice(self, predicate)
	for _, dev in self:devices() do
		if predicate then
			if predicate(dev) then
				return dev
			end
		else
			return dev
		end
	end

	return nil;
end

function EVContext.getMouse(self, predicate)
	local function isMouse(dev)
		if dev:isLikeMouse() then
			if predicate then
				return predicate(dev);
			end
			
			return true;
		end

		return false;
	end

	return self:getDevice(isMouse);
end


function EVContext.getTrackPad(self)
	for _, dev in self:devices() do
		if dev:isLikeTablet() then
			return dev;
		end
	end

	return nil;
end

function EVContext.getKeyboard(self, predicate)
	local function isKeyboard(dev)
		if dev:isLikeKeyboard() then
			if predicate then
				return predicate(dev);
			end

			return true;
		end

		return false;
	end

	return self:getDevice(isKeyboard)
end

return EVContext;
