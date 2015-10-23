package.path =package.path..";../src/?.lua"

local ffi = require("ffi")
local bit = require("bit")
local bor, band = bit.bor, bit.band

local libc = require("libc")
local kernel = require("kernel")


local function main()
    local fd = libc.open("devices.txt", bor(libc.O_NONBLOCK, libc.O_RDONLY))
 print("libc.open - ", fd, ffi.errno());
    local buff = ffi.new("char[255]");
    local bytesRead=0;
    local stdout = libc.STDOUT_FILENO;

    repeat
        bytesRead = libc.read(fd, buff, 255);
	    print("BytesRead: ",bytesRead);
	    if bytesRead > 0 then
            libc.write(stdout, buff, bytesRead);
            print("BytesRead: ", bytesRead);
        end
    until bytesRead == 0 or bytesRead == -1
    libc.close(fd);

    halt();
end

run(main)


