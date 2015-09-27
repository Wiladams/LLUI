local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor
local lshift = bit.lshift
local band = bit.band


ffi.cdef[[
static const int DRM_DISPLAY_MODE_LEN	= 32;
static const int DRM_PROP_NAME_LEN	= 32;

struct drm_mode_modeinfo {
	uint32_t clock;
	uint16_t hdisplay, hsync_start, hsync_end, htotal, hskew;
	uint16_t vdisplay, vsync_start, vsync_end, vtotal, vscan;

	uint32_t vrefresh;

	uint32_t flags;
	uint32_t type;
	char name[DRM_DISPLAY_MODE_LEN];
};
]]

ffi.cdef[[
struct drm_mode_card_res {
	uint64_t fb_id_ptr;
	uint64_t crtc_id_ptr;
	uint64_t connector_id_ptr;
	uint64_t encoder_id_ptr;
	uint32_t count_fbs;
	uint32_t count_crtcs;
	uint32_t count_connectors;
	uint32_t count_encoders;
	uint32_t min_width, max_width;
	uint32_t min_height, max_height;
};

struct drm_mode_crtc {
	uint64_t set_connectors_ptr;
	uint32_t count_connectors;

	uint32_t crtc_id; /**< Id */
	uint32_t fb_id; /**< Id of framebuffer */

	uint32_t x, y; /**< Position on the frameuffer */

	uint32_t gamma_size;
	uint32_t mode_valid;
	struct drm_mode_modeinfo mode;
};
]]


ffi.cdef[[
/* Planes blend with or override other bits on the CRTC */
struct drm_mode_set_plane {
	uint32_t plane_id;
	uint32_t crtc_id;
	uint32_t fb_id; /* fb object contains surface format type */
	uint32_t flags; /* see above flags */

	/* Signed dest location allows it to be partially off screen */
	int32_t crtc_x, crtc_y;
	uint32_t crtc_w, crtc_h;

	/* Source values are 16.16 fixed point */
	uint32_t src_x, src_y;
	uint32_t src_h, src_w;
};

struct drm_mode_get_plane {
	uint32_t plane_id;

	uint32_t crtc_id;
	uint32_t fb_id;

	uint32_t possible_crtcs;
	uint32_t gamma_size;

	uint32_t count_format_types;
	uint64_t format_type_ptr;
};

struct drm_mode_get_plane_res {
	uint64_t plane_id_ptr;
	uint32_t count_planes;
};
]]




ffi.cdef[[
struct drm_mode_get_encoder {
	uint32_t encoder_id;
	uint32_t encoder_type;

	uint32_t crtc_id; /**< Id of crtc */

	uint32_t possible_crtcs;
	uint32_t possible_clones;
};
]]


ffi.cdef[[
struct drm_mode_get_connector {

	uint64_t encoders_ptr;
	uint64_t modes_ptr;
	uint64_t props_ptr;
	uint64_t prop_values_ptr;

	uint32_t count_modes;
	uint32_t count_props;
	uint32_t count_encoders;

	uint32_t encoder_id; /**< Current Encoder */
	uint32_t connector_id; /**< Id */
	uint32_t connector_type;
	uint32_t connector_type_id;

	uint32_t connection;
	uint32_t mm_width, mm_height; /**< HxW in millimeters */
	uint32_t subpixel;

	uint32_t pad;
};
]]



ffi.cdef[[
struct drm_mode_property_enum {
	uint64_t value;
	char name[DRM_PROP_NAME_LEN];
};

struct drm_mode_get_property {
	uint64_t values_ptr; /* values and blob lengths */
	uint64_t enum_blob_ptr; /* enum and blob id ptrs */

	uint32_t prop_id;
	uint32_t flags;
	char name[DRM_PROP_NAME_LEN];

	uint32_t count_values;
	/* This is only used to count enum values, not blobs. The _blobs is
	 * simply because of a historical reason, i.e. backwards compat. */
	uint32_t count_enum_blobs;
};

struct drm_mode_connector_set_property {
	uint64_t value;
	uint32_t prop_id;
	uint32_t connector_id;
};

struct drm_mode_obj_get_properties {
	uint64_t props_ptr;
	uint64_t prop_values_ptr;
	uint32_t count_props;
	uint32_t obj_id;
	uint32_t obj_type;
};

struct drm_mode_obj_set_property {
	uint64_t value;
	uint32_t prop_id;
	uint32_t obj_id;
	uint32_t obj_type;
};

struct drm_mode_get_blob {
	uint32_t blob_id;
	uint32_t length;
	uint64_t data;
};
]]

ffi.cdef[[
struct drm_mode_fb_cmd {
	uint32_t fb_id;
	uint32_t width, height;
	uint32_t pitch;
	uint32_t bpp;
	uint32_t depth;
	/* driver specific handle */
	uint32_t handle;
};
]]



ffi.cdef[[
struct drm_mode_fb_cmd2 {
	uint32_t fb_id;
	uint32_t width, height;
	uint32_t pixel_format; /* fourcc code from drm_fourcc.h */
	uint32_t flags; /* see above flags */
	uint32_t handles[4];
	uint32_t pitches[4]; /* pitch for each plane */
	uint32_t offsets[4]; /* offset of each plane */
	uint64_t modifier[4]; /* ie, tiling, compressed (per plane) */
};
]]


ffi.cdef[[
struct drm_mode_fb_dirty_cmd {
	uint32_t fb_id;
	uint32_t flags;
	uint32_t color;
	uint32_t num_clips;
	uint64_t clips_ptr;
};

struct drm_mode_mode_cmd {
	uint32_t connector_id;
	struct drm_mode_modeinfo mode;
};
]]


ffi.cdef[[
struct drm_mode_cursor {
	uint32_t flags;
	uint32_t crtc_id;
	int32_t x;
	int32_t y;
	uint32_t width;
	uint32_t height;
	/* driver specific handle */
	uint32_t handle;
};

struct drm_mode_cursor2 {
	uint32_t flags;
	uint32_t crtc_id;
	int32_t x;
	int32_t y;
	uint32_t width;
	uint32_t height;
	/* driver specific handle */
	uint32_t handle;
	int32_t hot_x;
	int32_t hot_y;
};

struct drm_mode_crtc_lut {
	uint32_t crtc_id;
	uint32_t gamma_size;

	/* pointers to arrays */
	uint64_t red;
	uint64_t green;
	uint64_t blue;
};
]]


ffi.cdef[[

struct drm_mode_crtc_page_flip {
	uint32_t crtc_id;
	uint32_t fb_id;
	uint32_t flags;
	uint32_t reserved;
	uint64_t user_data;
};

/* create a dumb scanout buffer */
struct drm_mode_create_dumb {
	uint32_t height;
	uint32_t width;
	uint32_t bpp;
	uint32_t flags;
	/* handle, pitch, size will be returned */
	uint32_t handle;
	uint32_t pitch;
	uint64_t size;
};

/* set up for mmap of a dumb scanout buffer */
struct drm_mode_map_dumb {
	/** Handle for the object being mapped. */
	uint32_t handle;
	uint32_t pad;
	uint64_t offset;
};

struct drm_mode_destroy_dumb {
	uint32_t handle;
};
]]



ffi.cdef[[
struct drm_mode_atomic {
	uint32_t flags;
	uint32_t count_objs;
	uint64_t objs_ptr;
	uint64_t count_props_ptr;
	uint64_t props_ptr;
	uint64_t prop_values_ptr;
	uint64_t reserved;
	uint64_t user_data;
};
]]

local DRM_MODE_TYPE_BUILTIN	= lshift(1,0);

local DRM_MODE_PROP_TYPE = function(n) return lshift(n, 6) end;

local	DRM_MODE_PAGE_FLIP_EVENT =0x01;
local	DRM_MODE_PAGE_FLIP_ASYNC =0x02;
local	DRM_MODE_ATOMIC_TEST_ONLY =0x0100;
local	DRM_MODE_ATOMIC_NONBLOCK  =0x0200;
local	DRM_MODE_ATOMIC_ALLOW_MODESET = 0x0400;

local	DRM_MODE_PROP_PENDING	= lshift(1,0);
local	DRM_MODE_PROP_RANGE	= lshift(1,1);
local	DRM_MODE_PROP_IMMUTABLE	= lshift(1,2);
local	DRM_MODE_PROP_ENUM	= lshift(1,3); -- enumerated type with text strings */
local	DRM_MODE_PROP_BLOB	= lshift(1,4);
local	DRM_MODE_PROP_BITMASK	= lshift(1,5); -- bitmask of enumerated types */

local Constants = {
	DRM_DISPLAY_INFO_LEN	= 32;
	DRM_CONNECTOR_NAME_LEN	= 32;
	DRM_PROP_NAME_LEN	= ffi.C.DRM_PROP_NAME_LEN;

	DRM_MODE_TYPE_BUILTIN	= DRM_MODE_TYPE_BUILTIN;
	DRM_MODE_TYPE_CLOCK_C	=  bor(lshift(1,1) , DRM_MODE_TYPE_BUILTIN);
	DRM_MODE_TYPE_CRTC_C	=  bor(lshift(1,2) , DRM_MODE_TYPE_BUILTIN);
	DRM_MODE_TYPE_PREFERRED	=  lshift(1,3);
	DRM_MODE_TYPE_DEFAULT	=  lshift(1,4);
	DRM_MODE_TYPE_USERDEF	=  lshift(1,5);
	DRM_MODE_TYPE_DRIVER	=  lshift(1,6);

-- Video mode flags */
-- bit compatible with the xorg definitions. */
	DRM_MODE_FLAG_PHSYNC			= lshift(1,0);
	DRM_MODE_FLAG_NHSYNC			= lshift(1,1);
	DRM_MODE_FLAG_PVSYNC			= lshift(1,2);
	DRM_MODE_FLAG_NVSYNC			= lshift(1,3);
	DRM_MODE_FLAG_INTERLACE			= lshift(1,4);
	DRM_MODE_FLAG_DBLSCAN			= lshift(1,5);
	DRM_MODE_FLAG_CSYNC			= lshift(1,6);
	DRM_MODE_FLAG_PCSYNC			= lshift(1,7);
	DRM_MODE_FLAG_NCSYNC			= lshift(1,8);
	DRM_MODE_FLAG_HSKEW			= lshift(1,9);
	DRM_MODE_FLAG_BCAST			= lshift(1,10);
	DRM_MODE_FLAG_PIXMUX			= lshift(1,11);
	DRM_MODE_FLAG_DBLCLK			= lshift(1,12);
	DRM_MODE_FLAG_CLKDIV2			= lshift(1,13);


	DRM_MODE_FLAG_3D_MASK			= lshift(0x1f,14);
	 DRM_MODE_FLAG_3D_NONE			= lshift(0,14);
	 DRM_MODE_FLAG_3D_FRAME_PACKING		= lshift(1,14);
	 DRM_MODE_FLAG_3D_FIELD_ALTERNATIVE	= lshift(2,14);
	 DRM_MODE_FLAG_3D_LINE_ALTERNATIVE	= lshift(3,14);
	 DRM_MODE_FLAG_3D_SIDE_BY_SIDE_FULL	= lshift(4,14);
	 DRM_MODE_FLAG_3D_L_DEPTH		= lshift(5,14);
	 DRM_MODE_FLAG_3D_L_DEPTH_GFX_GFX_DEPTH	= lshift(6,14);
	 DRM_MODE_FLAG_3D_TOP_AND_BOTTOM	= lshift(7,14);
	 DRM_MODE_FLAG_3D_SIDE_BY_SIDE_HALF	= lshift(8,14);


-- DPMS flags */
-- bit compatible with the xorg definitions. */
	DRM_MODE_DPMS_ON	= 0;
	DRM_MODE_DPMS_STANDBY	= 1;
	DRM_MODE_DPMS_SUSPEND	= 2;
	DRM_MODE_DPMS_OFF	= 3;

-- Scaling mode options */
	DRM_MODE_SCALE_NONE		= 0; -- Unmodified timing (display or
					     --software can still scale) */
	DRM_MODE_SCALE_FULLSCREEN	= 1; -- Full screen, ignore aspect */
	DRM_MODE_SCALE_CENTER		= 2; -- Centered, no scaling */
	DRM_MODE_SCALE_ASPECT		= 3; -- Full screen, preserve aspect */

-- Picture aspect ratio options */
	DRM_MODE_PICTURE_ASPECT_NONE	= 0;
	DRM_MODE_PICTURE_ASPECT_4_3	= 1;
	DRM_MODE_PICTURE_ASPECT_16_9	= 2;

-- Dithering mode options */
	DRM_MODE_DITHERING_OFF	= 0;
	DRM_MODE_DITHERING_ON	= 1;
	DRM_MODE_DITHERING_AUTO = 2;

-- Dirty info options */
	DRM_MODE_DIRTY_OFF      = 0;
	DRM_MODE_DIRTY_ON       = 1;
	DRM_MODE_DIRTY_ANNOTATE = 2;

	DRM_MODE_PRESENT_TOP_FIELD	= lshift(1,0);
	DRM_MODE_PRESENT_BOTTOM_FIELD	= lshift(1,1);


	DRM_MODE_ENCODER_NONE	=0;
	DRM_MODE_ENCODER_DAC	=1;
	DRM_MODE_ENCODER_TMDS	=2;
	DRM_MODE_ENCODER_LVDS	=3;
	DRM_MODE_ENCODER_TVDAC	=4;
	DRM_MODE_ENCODER_VIRTUAL= 5;
	DRM_MODE_ENCODER_DSI	=6;
	DRM_MODE_ENCODER_DPMST	=7;


-- This is for connectors with multiple signal types. */
-- Try to match DRM_MODE_CONNECTOR_X as closely as possible. */
	DRM_MODE_SUBCONNECTOR_Automatic	=0;
	DRM_MODE_SUBCONNECTOR_Unknown	=0;
	DRM_MODE_SUBCONNECTOR_DVID	=3;
	DRM_MODE_SUBCONNECTOR_DVIA	=4;
	DRM_MODE_SUBCONNECTOR_Composite	=5;
	DRM_MODE_SUBCONNECTOR_SVIDEO	=6;
	DRM_MODE_SUBCONNECTOR_Component	=8;
	DRM_MODE_SUBCONNECTOR_SCART	=9;

	DRM_MODE_CONNECTOR_Unknown	=0;
	DRM_MODE_CONNECTOR_VGA		=1;
	DRM_MODE_CONNECTOR_DVII		=2;
	DRM_MODE_CONNECTOR_DVID		=3;
	DRM_MODE_CONNECTOR_DVIA		=4;
	DRM_MODE_CONNECTOR_Composite	=5;
	DRM_MODE_CONNECTOR_SVIDEO	=6;
	DRM_MODE_CONNECTOR_LVDS		=7;
	DRM_MODE_CONNECTOR_Component	=8;
	DRM_MODE_CONNECTOR_9PinDIN	=9;
	DRM_MODE_CONNECTOR_DisplayPort	=10;
	DRM_MODE_CONNECTOR_HDMIA	=11;
	DRM_MODE_CONNECTOR_HDMIB	=12;
	DRM_MODE_CONNECTOR_TV		=13;
	DRM_MODE_CONNECTOR_eDP		=14;
	DRM_MODE_CONNECTOR_VIRTUAL  =    15;
	DRM_MODE_CONNECTOR_DSI		=16;


	DRM_MODE_PROP_PENDING	= DRM_MODE_PROP_PENDING;
	DRM_MODE_PROP_RANGE	= DRM_MODE_PROP_RANGE;
	DRM_MODE_PROP_IMMUTABLE	= DRM_MODE_PROP_IMMUTABLE;
	DRM_MODE_PROP_ENUM	= DRM_MODE_PROP_ENUM; -- enumerated type with text strings */
	DRM_MODE_PROP_BLOB	= DRM_MODE_PROP_BLOB;
	DRM_MODE_PROP_BITMASK	= DRM_MODE_PROP_BITMASK; -- bitmask of enumerated types */

-- non-extended types: legacy bitmask, one bit per type: */
	DRM_MODE_PROP_LEGACY_TYPE  = bor(
		DRM_MODE_PROP_RANGE ,
		DRM_MODE_PROP_ENUM ,
		DRM_MODE_PROP_BLOB ,
		DRM_MODE_PROP_BITMASK);


	DRM_MODE_PROP_EXTENDED_TYPE	=0x0000ffc0;

	DRM_MODE_PROP_TYPE = DRM_MODE_PROP_TYPE;
	DRM_MODE_PROP_OBJECT		=DRM_MODE_PROP_TYPE(1);
	DRM_MODE_PROP_SIGNED_RANGE	=DRM_MODE_PROP_TYPE(2);


	DRM_MODE_PROP_ATOMIC     =   0x80000000;

	DRM_MODE_FB_INTERLACED	= lshift(1,0); -- for interlaced framebuffers */
	DRM_MODE_FB_MODIFIERS	= lshift(1,1); -- enables ->modifer[] */

	DRM_MODE_FB_DIRTY_ANNOTATE_COPY= 0x01;
	DRM_MODE_FB_DIRTY_ANNOTATE_FILL= 0x02;
	DRM_MODE_FB_DIRTY_FLAGS        = 0x03;

	DRM_MODE_FB_DIRTY_MAX_CLIPS    = 256;

	DRM_MODE_CURSOR_BO		=0x01;
	DRM_MODE_CURSOR_MOVE	=0x02;
	DRM_MODE_CURSOR_FLAGS	=0x03;

	DRM_MODE_PAGE_FLIP_EVENT = DRM_MODE_PAGE_FLIP_EVENT;
	DRM_MODE_PAGE_FLIP_ASYNC = DRM_MODE_PAGE_FLIP_ASYNC;
	DRM_MODE_PAGE_FLIP_FLAGS = bor(DRM_MODE_PAGE_FLIP_EVENT,DRM_MODE_PAGE_FLIP_ASYNC);

-- page-flip flags are valid, plus: */
	DRM_MODE_ATOMIC_TEST_ONLY =DRM_MODE_ATOMIC_TEST_ONLY;
	DRM_MODE_ATOMIC_NONBLOCK  =DRM_MODE_ATOMIC_NONBLOCK;
	DRM_MODE_ATOMIC_ALLOW_MODESET = DRM_MODE_ATOMIC_ALLOW_MODESET;

	DRM_MODE_ATOMIC_FLAGS = bor(DRM_MODE_PAGE_FLIP_EVENT,DRM_MODE_PAGE_FLIP_ASYNC,DRM_MODE_ATOMIC_TEST_ONLY, DRM_MODE_ATOMIC_NONBLOCK,DRM_MODE_ATOMIC_ALLOW_MODESET);
}

local exports = {
	Constants = Constants;
}
setmetatable(exports, {
	__call = function(self, ...)
		for k,v in pairs(self.Constants) do
			_G[k] = v;
		end

		return self;
	end,
})

return exports
