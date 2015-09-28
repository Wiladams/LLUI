-- UDVListIterator.lua
local ffi = require("ffi")
local libudev = require("libudev_ffi")
local UDVListEntry = require("UDVListEntry")

-- gen, param, state
local function UDVListIterator(listHead, currentEntry)
	--print("UDVListIterator: ", currentEntry, handle)
	if currentEntry == nil then
		return nil;
	end
	
	local entry = UDVListEntry(currentEntry)
	-- if we have an entry, but for some reason the name == nil
	-- then just return nil
	if entry.Name == nil then
		return nil;
	end
	
	-- get the next entry before returning
	local nextEntry = libudev.udev_list_entry_get_next(currentEntry)
	--print("nextEntry: ", nextEntry)
	
	-- return nextState, currentState
	return nextEntry, entry;
end

return UDVListIterator;
