local ffi = require("ffi")

--[[
	uinput is the event simulation interface.  Using these calls, you can 
	inject events into the deve stream of events.
--]]
ffi.cdef[[
struct libevdev_uinput;
enum libevdev_uinput_open_mode {
 LIBEVDEV_UINPUT_OPEN_MANAGED = -2
};

int libevdev_uinput_create_from_device(const struct libevdev *dev,
           int uinput_fd,
           struct libevdev_uinput **uinput_dev);
void libevdev_uinput_destroy(struct libevdev_uinput *uinput_dev);
int libevdev_uinput_get_fd(const struct libevdev_uinput *uinput_dev);
const char* libevdev_uinput_get_syspath(struct libevdev_uinput *uinput_dev);
const char* libevdev_uinput_get_devnode(struct libevdev_uinput *uinput_dev);
int libevdev_uinput_write_event(const struct libevdev_uinput *uinput_dev,
    unsigned int type,
    unsigned int code,
    int value);
]]

local LIB_libevdev = ffi.load("evdev")

local exports = {
	LIB_libevdev = LIB_libevdev;

	libevdev_uinput_create_from_device = LIB_libevdev.libevdev_uinput_create_from_device;
	libevdev_uinput_destroy = LIB_libevdev.libevdev_uinput_destroy;
	libevdev_uinput_get_fd = LIB_libevdev.libevdev_uinput_get_fd;
	libevdev_uinput_get_syspath = LIB_libevdev.libevdev_uinput_get_syspath;
	libevdev_uinput_get_devnode = LIB_libevdev.libevdev_uinput_get_devnode;
	libevdev_uinput_write_event = LIB_libevdev.libevdev_uinput_write_event;
}

setmetatable(exports, {
	__call = function(self, tbl)
		for k,v in pairs(self) do
			tbl[k] = v;
		end

		return self;
	end,
})

return exports