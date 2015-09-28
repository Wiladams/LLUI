-- EVEvent.lua

local ffi = require("ffi")
local bit = require("bit")
local band, bor = bit.band, bit.bor;

--local evdev = require("evdev")
local libc = require("libc")
local input = require("linux_input")



local EVEvent = {}
setmetatable(EVEvent, {
	__call = function(self, ...)
		return self:new(...);
	end,
})
local EVEvent_mt = {
	__index = EVEvent;
}

function EVEvent.init(self, handle)
	local obj = {
		Handle = handle;
	}
	setmetatable(obj, EVEvent_mt);

	return obj;
end

function EVEvent.new(self, handle)
	return self:init(handle);
end

function EVEvent.typeName(self, aname)
	return input.getValueName(self.Handle.type, input.EventTypes)
end

function EVEvent.codeName(self, aname)
	return input.getTypeCodeName(self.Handle.type, self.Handle.code)
end

function EVEvent.code(self, code)
	return tonumber(self.Handle.code);
end

function EVEvent.value(self, value)
	return tonumber(self.Handle.value);
end

return EVEvent;
