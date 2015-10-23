--[[
References:
    https://www.safaribooksonline.com/library/view/linux-system-programming/9781449341527/ch04.html
--]]

local ffi = require("ffi")
local bit = require("bit")
local band, bor, lshift, rshift = bit.band, bit.bor, bit.lshift, bit.rshift
local libc = require("libc")


local cio = {}
setmetatable(cio, {
    __call = function(self, ...)
        return self:new(...);
    end,
})

local cio_mt = {
    __index = cio;
}

function cio.init(self, fd)
    local obj = {
        fdesc = libc.iodesc(fd);
    }
    setmetatable(obj, cio_mt);

print("cio.init(), obj.fdesc(fd): ", obj.fdesc.fd)

    --obj.fdesc:setNonBlocking(true);

    obj.WatchdogEvent = ffi.new("struct epoll_event")
    obj.WatchdogEvent.data.ptr = obj.fdesc;
    obj.WatchdogEvent.events = bor(libc.EPOLLERR, libc.EPOLLET, libc.EPOLLRDHUP, libc.EPOLLOUT,libc.EPOLLIN);

    -- assumes kernel is already running
    -- tell the system we're interested in 
    -- monitoring this file descriptor
    obj.supportsEpoll = watchForIOEvents(obj.fdesc, obj.WatchdogEvent);


    -- create a couple more event kinds so that we can 
    -- use them for watching reads and writes explicitly
    obj.ReadEvent = ffi.new("struct epoll_event")
    obj.ReadEvent.data.ptr = obj.fdesc;
    obj.ReadEvent.events = bor(libc.EPOLLIN, libc.EPOLLERR); 

    obj.WriteEvent = ffi.new("struct epoll_event")
    obj.WriteEvent.data.ptr = obj.fdesc;
    obj.WriteEvent.events = bor(libc.EPOLLOUT, libc.EPOLLERR); 

    return obj;
end

function cio.new(self, kind, flags, family)
    kind = kind or linux.SOCK_STREAM;
    family = family or linux.AF_INET
    flags = flags or 0;
    local s = ffi.C.socket(family, kind, flags);
    if s < 0 then
        return nil, ffi.errno();
    end

    return self:init(s);
end

local int = ffi.typeof("int")

function cio.open(self, filename, flags, extra)
    extra = extra or int(0);
    local fd = libc.open(filename, flags, extra);
--print("cio.open() - ", fd);
    return self:init(fd);
end

function cio.read(self, buff, bufflen)
    
    local success = true;
    local bytesRead = 0;
    local err = nil;

    if self.supportsEpoll then
        local success, err = waitForIOEvent(self.fdesc, self.ReadEvent);
    
        --print(string.format("AsyncSocket.read(), after wait: 0x%x %s", success, tostring(err)))

        if not success then
            print("cio.read(), FAILED WAITING: ", string.format("0x%x",err))
            return false, err;
        end

        if band(success, epoll.EPOLLIN) > 0 then
            bytesRead, err = self.fdesc:read(buff, bufflen);
            --print("async_read(), bytes read: ", bytesRead, err)
        end
    else
        bytesRead, err = self.fdesc:read(buff, bufflen);
        --print("cio.read(NO EPOLL), bytes read: ", bytesRead, err)
    end
    
    return bytesRead, err;
end

function cio.write(self, buff, bufflen)
    local success = false;
    local err = nil;
    local bytesTransferred = 0;

    if self.supportsEpoll then
        local success, err = waitForIOEvent(self.fdesc, self.WriteEvent);
        --print(string.format("async_write, after wait: 0x%x %s", success, tostring(err)))
        if not success then
            return false, err;
        end
  
        if band(success, epoll.EPOLLOUT) > 0 then
            bytesTransferred, err = self.fdesc:write(buff, bufflen);
            --print("async_write(), bytes: ", bytes, err)
        end
    else
        bytesTransferred, err = self.fdesc:write(buff, bufflen);
    end

    return bytesTransferred, err;
end

function cio.close(self)
    self.fdesc:close();
end

return cio
