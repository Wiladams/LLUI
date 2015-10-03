package.path = package.path..";../src/?.lua"

local libc = require("libc")
local fourcc = require("fourcc")
local fourcc_encode = fourcc.fourcc_encode;
local fourcc_decode = fourcc.fourcc_decode;
local v4l2_fourcc = require("v4l2_fourcc")


local encoded = fourcc_encode('R','G','B','3')
print(string.format("FOURCC ENCODE('R','G','B','3') [%#x]",encoded)) 
print("FOURCC DECODE('R','G','B','3') ",fourcc_decode(encoded))


print(string.format("fourcc: %x Name: %s", encoded, libc.getValueName(encoded, v4l2_fourcc)))

print("==== ALL FOURCC ====")
for k,v in pairs(v4l2_fourcc) do 
	print(string.format("%s, %#x ==> %s ['%s' '%s' '%s' '%s']", k, v, libc.getValueName(v, v4l2_fourcc), fourcc_decode(v)))
end