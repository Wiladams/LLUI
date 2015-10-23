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

    obj.fdesc:setNonBlocking(true);

    obj.WatchdogEvent = ffi.new("struct epoll_event")
    obj.WatchdogEvent.data.ptr = obj.fdesc;
    obj.WatchdogEvent.events = bor(libc.EPOLLOUT,libc.EPOLLIN, libc.EPOLLRDHUP, libc.EPOLLERR, libc.EPOLLET);

    -- assumes kernel is already running
    -- tell the system we're interested in 
    -- monitoring this file descriptor
    print("cio.init() ", watchForIOEvents(obj.fdesc, obj.WatchdogEvent));


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
print("cio.open() - ", fd);
    return self:init(fd);
end

--[[
function cio.setSocketOption(self, optname, on, level)
    local feature_on = ffi.new("int[1]")
    if on then feature_on[0] = 1; end
    level = level or linux.SOL_SOCKET 

    local ret = ffi.C.setsockopt(self.fdesc.fd, level, optname, feature_on, ffi.sizeof("int"))
    return ret == 0;
end

function AsyncSocket.setNonBlocking(self, on)
    return self.fdesc:setNonBlocking(on);
end

function AsyncSocket.setUseKeepAlive(self, on)
    return self:setSocketOption(linux.SO_KEEPALIVE, on);
end

function AsyncSocket.setReuseAddress(self, on)
    return self:setSocketOption(linux.SO_REUSEADDR, on);
end

function AsyncSocket.getLastError(self)
    local retVal = ffi.new("int[1]")
    local retValLen = ffi.new("int[1]", ffi.sizeof("int"))

    local ret = self:getSocketOption(linux.SO_ERROR, retVal, retValLen)

    return retVal[0];
end

function AsyncSocket.connect(self, servername, port)
    local sa, size = lookupsite(servername);
    if not sa then 
        return false, size;
    end
    ffi.cast("struct sockaddr_in *", sa):setPort(port);

    local ret = tonumber(ffi.C.connect(self.fdesc.fd, sa, size));

    local err = ffi.errno();
    if ret ~= 0 then
        if  err ~= errnos.EINPROGRESS then
            return false, err;
        end
    end


    -- now wait for the socket to be writable
    local success, err = asyncio:waitForIOEvent(self.fdesc, self.ConnectEvent);

    return success, err;
end
--]]

function cio.read(self, buff, bufflen)
    
    local success, err = waitForIOEvent(self.fdesc, self.ReadEvent);
    
    --print(string.format("AsyncSocket.read(), after wait: 0x%x %s", success, tostring(err)))

   if not success then
        print("cio.read(), FAILED WAITING: ", string.format("0x%x",err))
        return false, err;
    end

    local bytesRead = 0;

    if band(success, epoll.EPOLLIN) > 0 then
        bytesRead, err = self.fdesc:read(buff, bufflen);
        --print("async_read(), bytes read: ", bytesRead, err)
    end
    
    return bytesRead, err;
end

function cio.write(self, buff, bufflen)

  local success, err = waitForIOEvent(self.fdesc, self.WriteEvent);
  --print(string.format("async_write, after wait: 0x%x %s", success, tostring(err)))
  if not success then
    return false, err;
  end
  
  local bytes = 0;

  if band(success, epoll.EPOLLOUT) > 0 then
    bytes, err = self.fdesc:write(buff, bufflen);
    --print("async_write(), bytes: ", bytes, err)
  end

  return bytes, err;
end

function cio.close(self)
    self.fdesc:close();
end

return cio
