package.path = package.path..";../src/?.lua"

local media_utils = require("media_utils")

local fourcc_encode = media_utils.fourcc_encode;
local fourcc_decode = media_utils.fourcc_decode;

local encoded = fourcc_encode('R','G','B','3')
print(string.format("FOURCC ENCODE('R','G','B','3') [%#x]",encoded)) 
print("FOURCC DECODE('R','G','B','3') ",fourcc_decode(encoded))
