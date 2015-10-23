package.path =package.path..";../src/?.lua"

local ffi = require("ffi")
local bit = require("bit")
local bor, band = bit.bor, bit.band

local libc = require("libc")

local kernel = require("kernel")
local cio = require("cio")
local stdout = libc.STDOUT_FILENO;


local function main()
    local fd,err = cio:open("devices.txt", bor(libc.O_NONBLOCK, libc.O_RDONLY));
--print("cio:open - ", fd, err);
    local bytesRead=0;
    local buff = ffi.new("char[255]");

    repeat
        bytesRead,err = fd:read(buff, 255);
	   print("\nBytesRead: ",bytesRead,err);
        
        if bytesRead and bytesRead > 0 then
            libc.write(stdout, buff, bytesRead);
            --print("BytesRead: ", bytesRead);
        end
    until not bytesRead or bytesRead == 0
    fd:close();

    halt();
end

run(main)


