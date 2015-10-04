package.path = package.path..";../src/?.lua"

local fun = require("fun")()
local V4LCamera = require("V4LCamera"
	)
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

	--cam:close();
end

main(#arg, arg)
