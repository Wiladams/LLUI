#!/usr/bin/env luajit

-- devices.lua
-- print all devices in the system
-- generates output which is a valid lua table

package.path = package.path..";../src/?.lua"

local libc = require("libc")
local utils = require("udev_utils")
local fun = require("fun")()
local udev = require("libudev_ffi")

local ctxt, err = require("UDVContext")()
assert(ctxt ~= nil, "Error creating context")
local UDVDevice = require("UDVDevice")

local function printEvent(dev)
io.write(string.format([[
== Hotplug Event ==
 Action: %s
SysName: %s
DevType: %s
DevNode: %s
]],
	dev:action(),
	dev.SysName,
	dev.DevType,
	dev.DevNode
	))
end

local function isUsbDevice(dev)
	return dev.DevType == "usb_device"
end


local function main()
	local monitor, err = ctxt:createMonitor();
	assert(monitor, err)
	monitor:start();

	--each(printEvent, monitor:events())
	each(printEvent, filter(isUsbDevice, monitor:events()))
end

main()
