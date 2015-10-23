package.path =package.path..";../src/?.lua"

local ffi = require("ffi")
local libc = require("libc")

local kernel = require("kernel")
local cio = require("cio")


local function main()
    local fd,err = cio:open("devices.txt", libc.O_RDONLY);
print("cio:open - ", fd, err);
    local bytesRead=0;
    local buff = ffi.new("char[255]");

    repeat
        bytesRead,err = fd:read(buff, 255);
	print("BytesRead: ",bytesRead,err);
	if bytesRead and bytesRead > 0 then
            print("BytesRead: ", bytesRead);
        end
    until not bytesRead or bytesRead == 0
    fd:close();

    halt();
end

run(main)


