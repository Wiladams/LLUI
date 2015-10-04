package.path = package.path..";../src/?.lua"

local libc = require("libc")
local fun = require("fun")()
local V4LCamera = require("V4LCamera")

-- get device context so we can query
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

local function getFirstCameraDevname()
	local camdev = head(filter(isCamera, ctxt:devices()))
	if not camdev then
		return nil;
	end

	return camdev:getProperty("devname");
end

local function main(argc, argv)
	local dev_name = getFirstCameraDevname()
	assert(dev_name, "could not find camera")

	local cam = V4LCamera(dev_name)
	assert(cam, "could not create camera")

	cam:capabilities();
	--cam:close();
end

--[[
local ffi = require("ffi")
local bit = require("bit")
local band, bor, lshift, rshift = bit.band, bit.bor, bit.lshift, bit.rshift

local T = ffi.typeof;

local IOC = {
  DIRSHIFT = 30;
  TYPESHIFT = 8;
  NRSHIFT = 0;
  SIZESHIFT = 16;
}

local function ioc(dir, ch, nr, size)
  if type(ch) == "string" then ch = ch:byte() end

print("ioc: ", dir, ch, nr, size)

	local dirpart =tonumber(ffi.cast("uint32_t",lshift(dir, IOC.DIRSHIFT)))
	local chpart = lshift(ch, IOC.TYPESHIFT) 
	local nrpart =  lshift(nr, IOC.NRSHIFT)
	local szpart = lshift(size, IOC.SIZESHIFT);

	print(dirpart, chpart, nrpart, szpart)
	local wholepart = tonumber(ffi.cast("uint32_t ", bor(dirpart, chpart, nrpart, szpart)))
  return wholepart
end

local function _IOC(a,b,c,d) 
print("_IOC: ", a, b, c, d)
  return ioc(a,b,c,d);
end

local _IOC_NONE  = 0;
local _IOC_WRITE = 1;
local _IOC_READ  = 2;

local function _IOWR(a,b,c) return _IOC(bor(_IOC_READ,_IOC_WRITE),a,b,ffi.sizeof(c)) end

local VIDIOC_IOCTL_BASE	= 'V';
local VIDIOC_ENUM_FMT = _IOWR(VIDIOC_IOCTL_BASE,2,T'struct v4l2_fmtdesc')
print(string.format("VIDIOC_ENUM_FMT: %#x", VIDIOC_ENUM_FMT))
--]]

main(#arg, arg)
