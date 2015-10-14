# LLUI
LuaJIT Linux User Interface (LLUI, pronounced 'You Eye')

This repository is a conglomeration of several projects related to UI on Linux.
The intention is that with a single project, you could create anything from a framebuffer direct kiosk app, to a nicely behaved
windowing app that leverages OpenGL.

Included Modules
* libdrm - low level graphics card interaction
* libevdev - low level event handling
* libudev - low level device discovery
* libpixman - low level pixel rendering
* lz4 - for very tight compression

In some cases, you will need to install a package on your given platform.  For example, in order to user libevdev, on Ubuntu, you need to do $apt-get install libevdev.  Check your distribution to determine which items need to be installed.  Over time, if some of these get replaced with direct ioctl calls, or Lua implementations, this need will diminish.

There is also partial support for 
* libc - ffi.cdef wrappers for most used routines

And thrown in for ease of programming
* fun - functional programming module
* kernel - lightweight cooperative multi-tasking

A note on the rockspec
By default, if you do 
```bash
$ sudo luarocks install llui-0.1-1.rockspec
```

The files will likely end up in /usr/local/share/lua/5.1/LLUI
but, it depends on how you've configured things.

Now, within your code, you should be able to simply do:

```lua
local libc = require("LLUI.libc")
local pixman = require("LLUI.pixman")
```

To get at the various modules you want.

Things that need to be installed on your machine.  As much of this library depends on the existance of functions already on the machine, you must ensure several other libraries are already installed.  In most cases, the libraries will already be a part of the linux distributions, but on some cases, you'll need to install them if they're not already there.

* libudev
* libevdev
* lz4
* libpixman
* libdrm
* libjpeg
* libuvc
* libv4l2
