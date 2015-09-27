local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor
local band = bit.band

local drm = require("drm")
--local drm_mode = drm.drm_mode();


ffi.cdef[[
typedef struct _drmModeRes {

  int count_fbs;
  uint32_t *fbs;

  int count_crtcs;
  uint32_t *crtcs;

  int count_connectors;
  uint32_t *connectors;

  int count_encoders;
  uint32_t *encoders;

  uint32_t min_width, max_width;
  uint32_t min_height, max_height;
} drmModeRes, *drmModeResPtr;

typedef struct _drmModeModeInfo {
  uint32_t clock;
  uint16_t hdisplay, hsync_start, hsync_end, htotal, hskew;
  uint16_t vdisplay, vsync_start, vsync_end, vtotal, vscan;

  uint32_t vrefresh;

  uint32_t flags;
  uint32_t type;
  char name[DRM_DISPLAY_MODE_LEN];
} drmModeModeInfo, *drmModeModeInfoPtr;

typedef struct _drmModeFB {
  uint32_t fb_id;
  uint32_t width, height;
  uint32_t pitch;
  uint32_t bpp;
  uint32_t depth;
  /* driver specific handle */
  uint32_t handle;
} drmModeFB, *drmModeFBPtr;

typedef struct drm_clip_rect drmModeClip, *drmModeClipPtr;

typedef struct _drmModePropertyBlob {
  uint32_t id;
  uint32_t length;
  void *data;
} drmModePropertyBlobRes, *drmModePropertyBlobPtr;

typedef struct _drmModeProperty {
  uint32_t prop_id;
  uint32_t flags;
  char name[DRM_PROP_NAME_LEN];
  int count_values;
  uint64_t *values; /* store the blob lengths */
  int count_enums;
  struct drm_mode_property_enum *enums;
  int count_blobs;
  uint32_t *blob_ids; /* store the blob IDs */
} drmModePropertyRes, *drmModePropertyPtr;
]]



ffi.cdef[[
typedef struct _drmModeCrtc {
  uint32_t crtc_id;
  uint32_t buffer_id; /**< FB id to connect to 0 = disconnect */

  uint32_t x, y; /**< Position on the framebuffer */
  uint32_t width, height;
  int mode_valid;
  drmModeModeInfo mode;

  int gamma_size; /**< Number of gamma stops */

} drmModeCrtc, *drmModeCrtcPtr;
]]

ffi.cdef[[
typedef struct _drmModeEncoder {
  uint32_t encoder_id;
  uint32_t encoder_type;
  uint32_t crtc_id;
  uint32_t possible_crtcs;
  uint32_t possible_clones;
} drmModeEncoder, *drmModeEncoderPtr;
]]

ffi.cdef[[
typedef enum {
  DRM_MODE_CONNECTED         = 1,
  DRM_MODE_DISCONNECTED      = 2,
  DRM_MODE_UNKNOWNCONNECTION = 3
} drmModeConnection;

typedef enum {
  DRM_MODE_SUBPIXEL_UNKNOWN        = 1,
  DRM_MODE_SUBPIXEL_HORIZONTAL_RGB = 2,
  DRM_MODE_SUBPIXEL_HORIZONTAL_BGR = 3,
  DRM_MODE_SUBPIXEL_VERTICAL_RGB   = 4,
  DRM_MODE_SUBPIXEL_VERTICAL_BGR   = 5,
  DRM_MODE_SUBPIXEL_NONE           = 6
} drmModeSubPixel;
]]

ffi.cdef[[
typedef struct _drmModeConnector {
  uint32_t connector_id;
  uint32_t encoder_id; /**< Encoder currently connected to */
  uint32_t connector_type;
  uint32_t connector_type_id;
  drmModeConnection connection;
  uint32_t mmWidth, mmHeight; /**< HxW in millimeters */
  drmModeSubPixel subpixel;

  int count_modes;
  drmModeModeInfoPtr modes;

  int count_props;
  uint32_t *props; /**< List of property ids */
  uint64_t *prop_values; /**< List of property values */

  int count_encoders;
  uint32_t *encoders; /**< List of encoder ids */
} drmModeConnector, *drmModeConnectorPtr;
]]



ffi.cdef[[
typedef struct _drmModeObjectProperties {
  uint32_t count_props;
  uint32_t *props;
  uint64_t *prop_values;
} drmModeObjectProperties, *drmModeObjectPropertiesPtr;

typedef struct _drmModePlane {
  uint32_t count_formats;
  uint32_t *formats;
  uint32_t plane_id;

  uint32_t crtc_id;
  uint32_t fb_id;

  uint32_t crtc_x, crtc_y;
  uint32_t x, y;

  uint32_t possible_crtcs;
  uint32_t gamma_size;
} drmModePlane, *drmModePlanePtr;

typedef struct _drmModePlaneRes {
  uint32_t count_planes;
  uint32_t *planes;
} drmModePlaneRes, *drmModePlaneResPtr;
]]

ffi.cdef[[
extern void drmModeFreeModeInfo( drmModeModeInfoPtr ptr );
extern void drmModeFreeResources( drmModeResPtr ptr );
extern void drmModeFreeFB( drmModeFBPtr ptr );
extern void drmModeFreeCrtc( drmModeCrtcPtr ptr );
extern void drmModeFreeConnector( drmModeConnectorPtr ptr );
extern void drmModeFreeEncoder( drmModeEncoderPtr ptr );
extern void drmModeFreePlane( drmModePlanePtr ptr );
extern void drmModeFreePlaneResources(drmModePlaneResPtr ptr);
]]

ffi.cdef[[
/**
 * Retrives all of the resources associated with a card.
 */
extern drmModeResPtr drmModeGetResources(int fd);
]]

ffi.cdef[[
/*
 * FrameBuffer manipulation.
 */

/**
 * Retrive information about framebuffer bufferId
 */
extern drmModeFBPtr drmModeGetFB(int fd, uint32_t bufferId);

/**
 * Creates a new framebuffer with an buffer object as its scanout buffer.
 */
extern int drmModeAddFB(int fd, uint32_t width, uint32_t height, uint8_t depth,
      uint8_t bpp, uint32_t pitch, uint32_t bo_handle,
      uint32_t *buf_id);
/* ...with a specific pixel format */
extern int drmModeAddFB2(int fd, uint32_t width, uint32_t height,
       uint32_t pixel_format, uint32_t bo_handles[4],
       uint32_t pitches[4], uint32_t offsets[4],
       uint32_t *buf_id, uint32_t flags);
/**
 * Destroys the given framebuffer.
 */
extern int drmModeRmFB(int fd, uint32_t bufferId);

/**
 * Mark a region of a framebuffer as dirty.
 */
extern int drmModeDirtyFB(int fd, uint32_t bufferId,
        drmModeClipPtr clips, uint32_t num_clips);
]]


ffi.cdef[[
/*
 * Crtc functions
 */

/**
 * Retrive information about the ctrt crtcId
 */
extern drmModeCrtcPtr drmModeGetCrtc(int fd, uint32_t crtcId);

/**
 * Set the mode on a crtc crtcId with the given mode modeId.
 */
int drmModeSetCrtc(int fd, uint32_t crtcId, uint32_t bufferId,
                   uint32_t x, uint32_t y, uint32_t *connectors, int count,
       drmModeModeInfoPtr mode);
]]

ffi.cdef[[
/*
 * Cursor functions
 */

/**
 * Set the cursor on crtc
 */
int drmModeSetCursor(int fd, uint32_t crtcId, uint32_t bo_handle, uint32_t width, uint32_t height);

int drmModeSetCursor2(int fd, uint32_t crtcId, uint32_t bo_handle, uint32_t width, uint32_t height, int32_t hot_x, int32_t hot_y);
/**
 * Move the cursor on crtc
 */
int drmModeMoveCursor(int fd, uint32_t crtcId, int x, int y);
]]

ffi.cdef[[
/**
 * Encoder functions
 */
drmModeEncoderPtr drmModeGetEncoder(int fd, uint32_t encoder_id);
]]

ffi.cdef[[
/*
 * Connector manipulation
 */

/**
 * Retrive information about the connector connectorId.
 */
extern drmModeConnectorPtr drmModeGetConnector(int fd,
    uint32_t connectorId);

/**
 * Attaches the given mode to an connector.
 */
extern int drmModeAttachMode(int fd, uint32_t connectorId, drmModeModeInfoPtr mode_info);

/**
 * Detaches a mode from the connector
 * must be unused, by the given mode.
 */
extern int drmModeDetachMode(int fd, uint32_t connectorId, drmModeModeInfoPtr mode_info);

extern drmModePropertyPtr drmModeGetProperty(int fd, uint32_t propertyId);
extern void drmModeFreeProperty(drmModePropertyPtr ptr);

extern drmModePropertyBlobPtr drmModeGetPropertyBlob(int fd, uint32_t blob_id);
extern void drmModeFreePropertyBlob(drmModePropertyBlobPtr ptr);
extern int drmModeConnectorSetProperty(int fd, uint32_t connector_id, uint32_t property_id,
            uint64_t value);
extern int drmCheckModesettingSupported(const char *busid);

extern int drmModeCrtcSetGamma(int fd, uint32_t crtc_id, uint32_t size,
             uint16_t *red, uint16_t *green, uint16_t *blue);
extern int drmModeCrtcGetGamma(int fd, uint32_t crtc_id, uint32_t size,
             uint16_t *red, uint16_t *green, uint16_t *blue);
extern int drmModePageFlip(int fd, uint32_t crtc_id, uint32_t fb_id,
         uint32_t flags, void *user_data);

extern drmModePlaneResPtr drmModeGetPlaneResources(int fd);
extern drmModePlanePtr drmModeGetPlane(int fd, uint32_t plane_id);
extern int drmModeSetPlane(int fd, uint32_t plane_id, uint32_t crtc_id,
         uint32_t fb_id, uint32_t flags,
         int32_t crtc_x, int32_t crtc_y,
         uint32_t crtc_w, uint32_t crtc_h,
         uint32_t src_x, uint32_t src_y,
         uint32_t src_w, uint32_t src_h);

extern drmModeObjectPropertiesPtr drmModeObjectGetProperties(int fd,
              uint32_t object_id,
              uint32_t object_type);
extern void drmModeFreeObjectProperties(drmModeObjectPropertiesPtr ptr);
extern int drmModeObjectSetProperty(int fd, uint32_t object_id,
            uint32_t object_type, uint32_t property_id,
            uint64_t value);
]]

local function drm_property_type_is(property, atype)

  -- instanceof for props.. handles extended type vs original types:
  if band(property.flags, DRM_MODE_PROP_EXTENDED_TYPE) ~= 0 then
    return band(property.flags, DRM_MODE_PROP_EXTENDED_TYPE) == atype;
  end

  return band(property.flags, atype);
end

--[[
local Constants = {
    -- Constants
  DRM_MODE_FEATURE_KMS   = 1;
  DRM_MODE_FEATURE_DIRTYFB = 1;
  DRM_PLANE_TYPE_OVERLAY =0;
  DRM_PLANE_TYPE_PRIMARY =1;
  DRM_PLANE_TYPE_CURSOR  =2;
}
--]]

--[[
local Macros = {
  -- local functions/macros
  drm_property_type_is = drm_property_type_is;  
}
--]]

local Lib_drm = ffi.load("drm")
--[[
local Functions = {
    drmModeGetConnector = Lib_drm.drmModeGetConnector;
    drmModeGetResources = Lib_drm.drmModeGetResources;
    drmModeFreeConnector = Lib_drm.drmModeFreeConnector;
    drmModeFreeResources = Lib_drm.drmModeFreeResources;
}
--]]

local exports = {
    Lib_drm = Lib_drm;


    -- Constants
    DRM_MODE_FEATURE_KMS   = 1;
    DRM_MODE_FEATURE_DIRTYFB = 1;
    DRM_PLANE_TYPE_OVERLAY =0;
    DRM_PLANE_TYPE_PRIMARY =1;
    DRM_PLANE_TYPE_CURSOR  =2;

    -- Macros
    drm_property_type_is = drm_property_type_is;  

    -- library functions
    drmCheckModesettingSupported = Lib_drm.drmCheckModesettingSupported;
    drmModeAddFB = Lib_drm.drmModeAddFB;
    
    drmModeGetConnector = Lib_drm.drmModeGetConnector;
    drmModeGetCrtc = Lib_drm.drmModeGetCrtc;
    drmModeGetEncoder = Lib_drm.drmModeGetEncoder;
    drmModeGetFB = Lib_drm.drmModeGetFB;
    drmModeGetResources = Lib_drm.drmModeGetResources;
    
    drmModeFreeConnector = Lib_drm.drmModeFreeConnector;
    drmModeFreeCrtc = Lib_drm.drmModeFreeCrtc;
    drmModeFreeEncoder = Lib_drm.drmModeFreeEncoder;
    drmModeFreeFB = Lib_drm.drmModeFreeFB;
    drmModeFreeResources = Lib_drm.drmModeFreeResources;

    drmModeSetCrtc = Lib_drm.drmModeSetCrtc;
}


setmetatable(exports, {
  __call = function(self, tbl)
    tbl = tbl or _G;

    for k,v in pairs(self) do
      tbl[k] = v;
    end
--[[
    for k,v in pairs(self.Constants) do
      _G[k] = v;
    end

    for k,v in pairs(self.Macros) do
      _G[k] = v;
    end

    for k,v in pairs(self.Functions) do
      _G[k] = v;
    end
--]]
    return self;
  end,
})

return exports
