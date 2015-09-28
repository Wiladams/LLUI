--[[
	For easy composition, UDVListEntry function simply turns a
	struct udev_list_entry into a table with two named fields.
	If either of the fields is NULL on the C side, it will not
	show up within the table.

	safeffistring is used to ensure we don't crash in case a 
	NULL value is present.  Instead it will simply return 'nil'
	otherwise, it will use ffi.string to turn the value into 
	a lua string.
--]]
local ffi = require("ffi")
local libudev = require("libudev_ffi")



local function UDVListEntry(entry)
	return {
		Name = libudev.safeffistring(libudev.udev_list_entry_get_name(entry));
		Value = libudev.safeffistring(libudev.udev_list_entry_get_value(entry));
	}
end

return UDVListEntry
