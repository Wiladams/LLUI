#!/usr/bin/env luajit

-- devices.lua
-- print all devices in the system
-- generates output which is a valid lua table

package.path = package.path..";../src/?.lua"

local libc = require("libc")
local utils = require("udev_utils")
local udev = require("libudev_ffi")

local ctxt, err = require("UDVContext")()
assert(ctxt ~= nil, "Error creating context")
local UDVDevice = require("UDVDevice")


local function main()
	local monitor = ctxt:createMonitor();

	while(true) do
		local dev = monitor:receiveDevice();
		if dev ~= nil then
			print(dev)
			--print(dev, dev:action());
			--local device = UDVDevice:newFromHandle(dev);
		end
	end
end

main()