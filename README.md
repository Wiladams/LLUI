# LLUI
LuaJIT Linux User Interface (LLUI, pronounced 'You Eye')

This repository is a comglomeration of several projects related to UI on Linux.
The intention is that with a single project, you could create anything from a framebuffer direct kiosk app, to a nicely behaved
windowing app that leverages OpenGL.

Included Modules
* libdrm - low level graphics card interaction
* libevdev - low level event handling
* libudev - low level device discovery
* libpixman - low level pixel rendering

There is also partial support for 
* libc - ffi.cdef wrappers for most used routines

And thrown in for ease of programming
* fun - functional programming module
* kernel - lightweight cooperative multi-tasking scheduler