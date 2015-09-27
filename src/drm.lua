local ffi = require("ffi")
local bit = require("bit")
local band, bor = bit.band, bit.bor
local lshift, rshift = bit.lshift, bit.rshift

local Lib_drm = require("drm_ffi")
local libc = require("libc")


local	DRM_IOCTL_BASE	= 'd'
local function DRM_IO(nr)	return libc._IO(DRM_IOCTL_BASE,nr) end
local function DRM_IOR(nr,type) return 	libc._IOR(DRM_IOCTL_BASE,nr,type) end
local function DRM_IOW(nr,type)	return	libc._IOW(DRM_IOCTL_BASE,nr,type) end
local function DRM_IOWR(nr,type) return libc._IOWR(DRM_IOCTL_BASE,nr,type) end

local T = ffi.typeof




local	_DRM_LOCK_HELD	=0x80000000; --*< Hardware lock is held 
local	_DRM_LOCK_CONT	=0x40000000; --*< Hardware lock is contended 

local exports = {
	Lib_drm = Lib_drm;

--	drm_mode = drm_mode;
	
	DRM_NAME		= "drm";	--*< Name in kernel, /dev, and /proc 
	DRM_MIN_ORDER	= 5;	  	--*< At least 2^5 bytes = 32 bytes 
	DRM_MAX_ORDER	= 22;	  	--*< Up to 2^22 bytes = 4MB 
	DRM_RAM_PERCENT = 10;  		--*< How much system ram can we lock? 

	_DRM_LOCK_IS_HELD	   = function(lock) return band(lock, _DRM_LOCK_HELD) end;
	_DRM_LOCK_IS_CONT	   = function(lock) return band(lock, _DRM_LOCK_CONT) end;
	_DRM_LOCKING_CONTEXT   = function(lock) return band(lock, bnot(bor(_DRM_LOCK_HELD,_DRM_LOCK_CONT))) end;

	DRM_EVENT_VBLANK = 0x01;
	DRM_EVENT_FLIP_COMPLETE = 0x02;

	_DRM_VBLANK_HIGH_CRTC_SHIFT = 1;

	_DRM_VBLANK_TYPES_MASK = bor(ffi.C._DRM_VBLANK_ABSOLUTE, ffi.C._DRM_VBLANK_RELATIVE);
	_DRM_VBLANK_FLAGS_MASK = bor(ffi.C._DRM_VBLANK_EVENT, ffi.C._DRM_VBLANK_SIGNAL, ffi.C._DRM_VBLANK_SECONDARY, ffi.C._DRM_VBLANK_NEXTONMISS);

	_DRM_PRE_MODESET  = 1;
	_DRM_POST_MODESET = 2;


	-- Capabilities
	DRM_CAP_DUMB_BUFFER		= 0x1;
	DRM_CAP_VBLANK_HIGH_CRTC	= 0x2;
	DRM_CAP_DUMB_PREFERRED_DEPTH	= 0x3;
	DRM_CAP_DUMB_PREFER_SHADOW	= 0x4;
	DRM_CAP_PRIME			= 0x5;
	DRM_PRIME_CAP_IMPORT		= 0x1;
	DRM_PRIME_CAP_EXPORT		= 0x2;
	DRM_CAP_TIMESTAMP_MONOTONIC	= 0x6;
	DRM_CAP_ASYNC_PAGE_FLIP		= 0x7;

	DRM_CAP_CURSOR_WIDTH		= 0x8;
	DRM_CAP_CURSOR_HEIGHT		= 0x9;
	DRM_CAP_ADDFB2_MODIFIERS	= 0x10;
	DRM_CLIENT_CAP_STEREO_3D	= 1;
	DRM_CLIENT_CAP_UNIVERSAL_PLANES  = 2;
	DRM_CLIENT_CAP_ATOMIC	= 3;

	DRM_CLOEXEC = libc.O_CLOEXEC;

	-- IOCTL
	DRM_IOCTL_VERSION		= DRM_IOWR(0x00, T'struct drm_version');
	DRM_IOCTL_GET_UNIQUE	= DRM_IOWR(0x01, T'struct drm_unique');
	DRM_IOCTL_GET_MAGIC		= DRM_IOR( 0x02, T'struct drm_auth');
	DRM_IOCTL_IRQ_BUSID		= DRM_IOWR(0x03, T'struct drm_irq_busid');
	DRM_IOCTL_GET_MAP       = DRM_IOWR(0x04, T'struct drm_map');
	DRM_IOCTL_GET_CLIENT    = DRM_IOWR(0x05, T'struct drm_client');
	DRM_IOCTL_GET_STATS     = DRM_IOR( 0x06, T'struct drm_stats');
	DRM_IOCTL_SET_VERSION	= DRM_IOWR(0x07, T'struct drm_set_version');
	DRM_IOCTL_MODESET_CTL   = DRM_IOW(0x08, T'struct drm_modeset_ctl');
	DRM_IOCTL_GEM_CLOSE		= DRM_IOW (0x09, T'struct drm_gem_close');
	DRM_IOCTL_GEM_FLINK		= DRM_IOWR(0x0a, T'struct drm_gem_flink');
	DRM_IOCTL_GEM_OPEN		= DRM_IOWR(0x0b, T'struct drm_gem_open');
	DRM_IOCTL_GET_CAP		= DRM_IOWR(0x0c, T'struct drm_get_cap');
	DRM_IOCTL_SET_CLIENT_CAP= DRM_IOW( 0x0d, T'struct drm_set_client_cap');

	DRM_IOCTL_SET_UNIQUE	= DRM_IOW( 0x10, T'struct drm_unique');
	DRM_IOCTL_AUTH_MAGIC	= DRM_IOW( 0x11, T'struct drm_auth');
	DRM_IOCTL_BLOCK			= DRM_IOWR(0x12, T'struct drm_block');
	DRM_IOCTL_UNBLOCK		= DRM_IOWR(0x13, T'struct drm_block');
	DRM_IOCTL_CONTROL		= DRM_IOW( 0x14, T'struct drm_control');
	DRM_IOCTL_ADD_MAP		= DRM_IOWR(0x15, T'struct drm_map');
	DRM_IOCTL_ADD_BUFS		= DRM_IOWR(0x16, T'struct drm_buf_desc');
	DRM_IOCTL_MARK_BUFS		= DRM_IOW( 0x17, T'struct drm_buf_desc');
	DRM_IOCTL_INFO_BUFS		= DRM_IOWR(0x18, T'struct drm_buf_info');
	DRM_IOCTL_MAP_BUFS		= DRM_IOWR(0x19, T'struct drm_buf_map');
	DRM_IOCTL_FREE_BUFS		= DRM_IOW( 0x1a, T'struct drm_buf_free');

	DRM_IOCTL_RM_MAP		= DRM_IOW( 0x1b, T'struct drm_map');

	DRM_IOCTL_SET_SAREA_CTX	=	DRM_IOW( 0x1c, T'struct drm_ctx_priv_map');
	DRM_IOCTL_GET_SAREA_CTX =	DRM_IOWR(0x1d, T'struct drm_ctx_priv_map');

	DRM_IOCTL_SET_MASTER    =        DRM_IO(0x1e);
	DRM_IOCTL_DROP_MASTER   =        DRM_IO(0x1f);

	DRM_IOCTL_ADD_CTX		=DRM_IOWR(0x20, T'struct drm_ctx');
	DRM_IOCTL_RM_CTX		=DRM_IOWR(0x21, T'struct drm_ctx');
	DRM_IOCTL_MOD_CTX		=DRM_IOW( 0x22, T'struct drm_ctx');
	DRM_IOCTL_GET_CTX		=DRM_IOWR(0x23, T'struct drm_ctx');
	DRM_IOCTL_SWITCH_CTX	=DRM_IOW( 0x24, T'struct drm_ctx');
	DRM_IOCTL_NEW_CTX		=DRM_IOW( 0x25, T'struct drm_ctx');
	DRM_IOCTL_RES_CTX		=DRM_IOWR(0x26, T'struct drm_ctx_res');
	DRM_IOCTL_ADD_DRAW		=DRM_IOWR(0x27, T'struct drm_draw');
	DRM_IOCTL_RM_DRAW		=DRM_IOWR(0x28, T'struct drm_draw');
	DRM_IOCTL_DMA			=DRM_IOWR(0x29, T'struct drm_dma');
	DRM_IOCTL_LOCK			=DRM_IOW( 0x2a, T'struct drm_lock');
	DRM_IOCTL_UNLOCK		=DRM_IOW( 0x2b, T'struct drm_lock');
	DRM_IOCTL_FINISH		=DRM_IOW( 0x2c, T'struct drm_lock');

	DRM_IOCTL_PRIME_HANDLE_TO_FD =   DRM_IOWR(0x2d, T'struct drm_prime_handle');
	DRM_IOCTL_PRIME_FD_TO_HANDLE =   DRM_IOWR(0x2e, T'struct drm_prime_handle');

	DRM_IOCTL_AGP_ACQUIRE	=	DRM_IO(  0x30);
	DRM_IOCTL_AGP_RELEASE	=	DRM_IO(  0x31);
	DRM_IOCTL_AGP_ENABLE	=	DRM_IOW( 0x32, T'struct drm_agp_mode');
	DRM_IOCTL_AGP_INFO		=DRM_IOR( 0x33, T'struct drm_agp_info');
	DRM_IOCTL_AGP_ALLOC		=DRM_IOWR(0x34, T'struct drm_agp_buffer');
	DRM_IOCTL_AGP_FREE		=DRM_IOW( 0x35, T'struct drm_agp_buffer');
	DRM_IOCTL_AGP_BIND		=DRM_IOW( 0x36, T'struct drm_agp_binding');
	DRM_IOCTL_AGP_UNBIND	=	DRM_IOW( 0x37, T'struct drm_agp_binding');

	DRM_IOCTL_SG_ALLOC		=DRM_IOWR(0x38, T'struct drm_scatter_gather');
	DRM_IOCTL_SG_FREE		=DRM_IOW( 0x39, T'struct drm_scatter_gather');

	DRM_IOCTL_WAIT_VBLANK	=	DRM_IOWR(0x3a, T'union drm_wait_vblank');

	DRM_IOCTL_UPDATE_DRAW	=	DRM_IOW(0x3f, T'struct drm_update_draw');

	DRM_IOCTL_MODE_GETRESOURCES	=DRM_IOWR(0xA0, T'struct drm_mode_card_res');
	DRM_IOCTL_MODE_GETCRTC		=DRM_IOWR(0xA1, T'struct drm_mode_crtc');
	DRM_IOCTL_MODE_SETCRTC		=DRM_IOWR(0xA2, T'struct drm_mode_crtc');
	DRM_IOCTL_MODE_CURSOR		=DRM_IOWR(0xA3, T'struct drm_mode_cursor');
	DRM_IOCTL_MODE_GETGAMMA		=DRM_IOWR(0xA4, T'struct drm_mode_crtc_lut');
	DRM_IOCTL_MODE_SETGAMMA		=DRM_IOWR(0xA5, T'struct drm_mode_crtc_lut');
	DRM_IOCTL_MODE_GETENCODER	=DRM_IOWR(0xA6, T'struct drm_mode_get_encoder');
	DRM_IOCTL_MODE_GETCONNECTOR	=DRM_IOWR(0xA7, T'struct drm_mode_get_connector');

	DRM_IOCTL_MODE_GETPROPERTY	=DRM_IOWR(0xAA, T'struct drm_mode_get_property');
	DRM_IOCTL_MODE_SETPROPERTY	=DRM_IOWR(0xAB, T'struct drm_mode_connector_set_property');
	DRM_IOCTL_MODE_GETPROPBLOB	=DRM_IOWR(0xAC, T'struct drm_mode_get_blob');
	DRM_IOCTL_MODE_GETFB		=DRM_IOWR(0xAD, T'struct drm_mode_fb_cmd');
	DRM_IOCTL_MODE_ADDFB		=DRM_IOWR(0xAE, T'struct drm_mode_fb_cmd');
	DRM_IOCTL_MODE_RMFB		=DRM_IOWR(0xAF, T'unsigned int');
	DRM_IOCTL_MODE_PAGE_FLIP	=DRM_IOWR(0xB0, T'struct drm_mode_crtc_page_flip');
	DRM_IOCTL_MODE_DIRTYFB		=DRM_IOWR(0xB1, T'struct drm_mode_fb_dirty_cmd');

	DRM_IOCTL_MODE_CREATE_DUMB =DRM_IOWR(0xB2, T'struct drm_mode_create_dumb');
	DRM_IOCTL_MODE_MAP_DUMB    =DRM_IOWR(0xB3, T'struct drm_mode_map_dumb');
	DRM_IOCTL_MODE_DESTROY_DUMB    =DRM_IOWR(0xB4, T'struct drm_mode_destroy_dumb');
	DRM_IOCTL_MODE_GETPLANERESOURCES =DRM_IOWR(0xB5, T'struct drm_mode_get_plane_res');
	DRM_IOCTL_MODE_GETPLANE	=DRM_IOWR(0xB6, T'struct drm_mode_get_plane');
	DRM_IOCTL_MODE_SETPLANE	=DRM_IOWR(0xB7, T'struct drm_mode_set_plane');
	DRM_IOCTL_MODE_ADDFB2	=	DRM_IOWR(0xB8, T'struct drm_mode_fb_cmd2');
	DRM_IOCTL_MODE_OBJ_GETPROPERTIES	=DRM_IOWR(0xB9, T'struct drm_mode_obj_get_properties');
	DRM_IOCTL_MODE_OBJ_SETPROPERTY	=DRM_IOWR(0xBA, T'struct drm_mode_obj_set_property');
	DRM_IOCTL_MODE_CURSOR2		=DRM_IOWR(0xBB, T'struct drm_mode_cursor2');
	DRM_IOCTL_MODE_ATOMIC		=DRM_IOWR(0xBC, T'struct drm_mode_atomic');
}

setmetatable(exports, {
  __call = function(self, ...)
    for k,v in pairs(self) do
      _G[k] = v;
    end

    return self;
  end,
})

return exports