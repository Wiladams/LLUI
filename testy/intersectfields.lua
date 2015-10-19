--[[
	The purpose of this file is to list the intersection of property
	names that are found amongst a collection of devices.  The predicate
	determines which devices are of interest, and the collectFields
	call is made for each device, selecting only the fields which are
	the same.
--]]
package.path = package.path..";../src/?.lua"

local fun = require("fun")()
local utils = require("udev_utils")

local ctxt, err = require("UDVContext")()
assert(ctxt ~= nil, "Error creating context")

-- the predicate
local function isBlockDevice(dev)
	if dev.IsInitialized and dev:getProperty("subsystem") == "block" and
		dev:getProperty("devtype") == "disk" then
		return true;
	end

	return false;
end

local UniversalFields = {}
local first = true;

local function collectFields(dev)
	local devprops = {}
	for _, property in dev:properties() do 
		devprops[property.Name] = true;
	end

	if first then
		first = false;
		for k,v in pairs(devprops) do
			UniversalFields[k] = v;
		end
		return ;
	end

	-- a new table is used each time, otherwise we
	-- run into trouble modifying the table that we
	-- are iterating over.
	local newUniversal = {}
	for k,v in pairs(UniversalFields) do 
		if devprops[k] then
			newUniversal[k] = true;
		end
	end

	UniversalFields = newUniversal
end

-- enumerate, filter, collect
each(collectFields, filter(isBlockDevice, ctxt:devices()))

-- print out the field names
each(print, UniversalFields)
