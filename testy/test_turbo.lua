local turbo = require("turbo")

local HelloWorldHandler = class("HelloWorldHandler", turbo.web.RequestHandler)

function HelloWorldHandler:get()
    self:write("Hello World!")
end

local app = turbo.web.Application:new({
    {"/hello", HelloWorldHandler}
})

app:listen(8888)
turbo.ioloop.instance():start()

