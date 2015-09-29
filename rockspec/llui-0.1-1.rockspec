 package = "LLUI"
 version = "0.1-1"
 source = {
    url = "http://github.com/wiladams/LLUI",
    tag = "v0.1-1",
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
      ["LLUI.fun"] = "src/fun.lua",
      ["LLUI.kernel"] = "src/kernel.lua",
      ["LLUI.libc"] = "src/libc.lua",
    },

    platforms = {
      linux = {
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

      },
    },
 }
