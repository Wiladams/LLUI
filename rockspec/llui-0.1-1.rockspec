 package = "LLUI"
 version = "0.1-1"
 source = {
    url = "https://github.com/wiladams/LLUI/archive/v0.1-1.tar.gz",
    dir = "LLUI-0.1-1",
 }
 description = {
    summary = "Lua Linux User Interface",
    detailed = [[
       This collection of modules supports the creation of various
       types of UI elements, from frame buffers, to input devices to windows
       and renderers.
    ]],
    homepage = "http://github.com/wiladams/LLUI",
    license = "MIT/X11"
 }
 dependencies = {
    "lua ~> 5.1"
 }
 build = {
    type = "builtin",

    modules = {
      -- general programming goodness
      ["LLUI.fun"] = "src/fun.lua",
      ["LLUI.kernel"] = "src/kernel.lua",
      
      -- libc specifics
      ["LLUI.libc"] = "src/libc.lua",
      ["LLUI.stat"] = "src/stat.lua",

      -- libdrm
      ["LLUI.DRM"] = "src/DRM.lua",
      ["LLUI.DRMCard"] = "src/DRMCard.lua",
      ["LLUI.DRMCardConnector"] = "src/DRMCardConnector.lua",
      ["LLUI.DRMCardMode"] = "src/DRMCardMode.lua",
      ["LLUI.DRMCrtController"] = "src/DRMCrtController.lua",
      ["LLUI.DRMEncoder"] = "src/DRMEncoder.lua",
      ["LLUI.DRMFrameBuffer"] = "src/DRMFrameBuffer.lua",
      ["LLUI.drm"] = "src/drm.lua",
      ["LLUI.drm_ffi"] = "src/drm_ffi.lua",
      ["LLUI.drm_mode"] = "src/drm_mode.lua",
      ["LLUI.xf86drmMode_ffi"] = "src/xf86drmMode_ffi.lua",
      ["LLUI.xf86drm_ffi"] = "src/xf86drm_ffi.lua",

      -- libevdev
      ["LLUI.EVContext"] = "src/EVContext.lua",
      ["LLUI.EVDevice"] = "src/EVDevice.lua",
      ["LLUI.EVEvent"] = "src/EVEvent.lua",
      ["LLUI.evdev"] = "src/evdev.lua",
      ["LLUI.evdev_ffi"] = "src/evdev_ffi.lua",
      ["LLUI.linux_input"] = "src/linux_input.lua",
      ["LLUI.uinput"] = "src/uinput.lua",

      -- libudev
      ["LLUI.UDVContext"] = "src/UDVContext.lua",
      ["LLUI.UDVDevice"] = "src/UDVDevice.lua",
      ["LLUI.UDVHwdb"] = "src/UDVHwdb.lua",
      ["LLUI.UDVListEntry"] = "src/UDVListEntry.lua",
      ["LLUI.UDVListIterator"] = "src/UDVListIterator.lua",
      ["LLUI.libudev_ffi"] = "src/libudev_ffi.lua",
    
      -- lz4
      ["LLUI.lz4_ffi"] = "src/lz4_ffi.lua",
      ["LLUI.lz4frame_ffi"] = "src/lz4frame_ffi.lua",
      ["LLUI.lz4hc_ffi"] = "src/lz4hc_ffi.lua",
      ["LLUI.xxhash"] = "src/xxhash.lua",
      ["LLUI.xxhash_ffi"] = "src/xxhash_ffi.lua",

      -- pixman
      ["LLUI.pixman"] = "src/pixman.lua",
      ["LLUI.pixman_ffi"] = "src/pixman_ffi.lua",

    },

 }
