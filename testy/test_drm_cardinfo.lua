--test_drm_cardinfo.lua
--[[
	Test raw ioctl calls instead of using library calls
--]]
package.path = package.path..";../src/?.lua"

local ffi = require("ffi")

local libc = require("libc")
local DRMCard = require("DRMCard")
local drm = require("drm")

local card = DRMCard();



local function printVersion(ver)
	if not ver then 
		return false;
	end

	print(string.format([[
    Version: %d.%d.%d
       Name: %s
       Date: %s 
Description: %s
]],
	ver.Major,
	ver.Minor,
	ver.Patch,
	ver.Name, 
	ver.Date,
	ver.Description));
end

local ver = card:getDriverVersion();
print("== Card Version ==")
printVersion(ver)


local ver = card:getLibVersion()
print("lib version: ", ver.version_major, ver.version_minor, ver.version_patchlevel)

