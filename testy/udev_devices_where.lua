#!/usr/bin/env luajit

-- devices_where.lua
-- print devices in the system, filtered by a supplied predicate
-- generates output which is a valid lua table
package.path = package.path..";../src/?.lua"

local fun = require("fun")()
local utils = require("udev_utils")

local ctxt, err = require("UDVContext")()
assert(ctxt ~= nil, "Error creating context")

if #arg < 1 then
	error("you must specify a predicate")
end

local predicate = require(arg[1])

print("{")
	
each(utils.printDevice, filter(predicate, ctxt:devices()))

print("}")
