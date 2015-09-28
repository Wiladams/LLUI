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