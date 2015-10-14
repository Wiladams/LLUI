package.path = package.path..";../src/?.lua";

local ljdrm = require('ljdrm');

local res, err = ljdrm.drmOpenDevice(0,0);
print("RESULT: ", res, err)