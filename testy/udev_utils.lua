
package.path = package.path..";../?.lua"


local fun = require("fun")()
local ctxt, err = require("UDVContext")()
assert(ctxt ~= nil, "Error creating context")

local function printField(name, value)
	if value ~= nil then
		print(string.format("\t\t%s = '%s';", name, value));
	end
end

local function printBoolField(name, value)
	print(string.format("\t\t%s = %s;", name, value));
end

local function printDeviceProperties(dev)
	--  print device properties
	local firstone = true
	for _, prop in dev:properties() do
		if firstone then
			print(string.format("\t\tproperties = {"))
			firstone = not firstone;
		end

		print(string.format("\t\t\t['%s'] = '%s',", prop.Name, prop.Value))
	end
	if not firstone then
		print(string.format("\t\t},"))
	end
end

local function printDeviceTags(dev)
	-- print tags if any
	local firstone = true;
	for _, tag in dev:tags() do
		if firstone then
			print(string.format("\t\ttags = {"))
			firstone = not firstone
		end

		print(string.format("\t\t\t'%s',", tag.Name))
	end
	if not firstone then
		print(string.format("\t\t},"))
	end
end


local function printDevice(dev)
	print(string.format("\t['%s'] = {",dev.SysName));

	printField("SysPath", dev.SysPath);
	printField("SysName", dev.SysName);
	printField("SysNum", dev.SysNum);
	printField("DevNode", dev.DevNode);
	printField("Action", dev.Action);
	printBoolField("IsInitialized", dev.IsInitialized);

	printDeviceProperties(dev);
	printDeviceTags(dev);
	print(string.format("\t},"))
end


local exports = {
	printDevice = printDevice;
}

return exports


