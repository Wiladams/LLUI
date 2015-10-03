#!/usr/bin/env luajit

-- devices_where.lua
-- print devices in the system, filtered by a supplied predicate
-- generates output which is a valid lua table
package.path = package.path..";../src/?.lua"

local fun = require("fun")()
local utils = require("udev_utils")

local ctxt, err = require("UDVContext")()
assert(ctxt ~= nil, "Error creating context")

-- the predicate
local function isCamera(dev)
	if not dev.IsInitialized then
		return false;
	end

	if not dev:getProperty("subsystem") == "video4linux" then
		return false;
	end

	local caps = dev:getProperty("ID_V4L_CAPABILITIES")
	if not caps or not caps:find(":capture:") then
		return false;
	end

	-- could add dev:getProperty("colord_kind") == "camera"

	return true;

end

local function printCamera(dev)
	print(string.format("{devnode='%s',\t'model'='%s'},",dev:getProperty("devname"), dev:getProperty("ID_MODEL")))
end

print("{")	
each(printCamera, filter(isCamera, ctxt:devices()))
print("}")
