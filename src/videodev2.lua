-- videodev2.lua
local bit = require("bit")
local band, bor, lshift, rshift = bit.band, bit.bor, bit.lshift, bit.rshift

local Lib_v4l2 = require("v4l2_ffi")

local v4l2_fourcc = require("v4l2_fourcc")




local Enums = {
	v4l2_field = {
		V4L2_FIELD_ANY           = 0,
		V4L2_FIELD_NONE          = 1,
		V4L2_FIELD_TOP           = 2, 
		V4L2_FIELD_BOTTOM        = 3, 
		V4L2_FIELD_INTERLACED    = 4, 
		V4L2_FIELD_SEQ_TB        = 5, 
		V4L2_FIELD_SEQ_BT        = 6, 
		V4L2_FIELD_ALTERNATE     = 7, 
		V4L2_FIELD_INTERLACED_TB = 8, 
		V4L2_FIELD_INTERLACED_BT = 9, 
	};


	v4l2_buf_type = {
		V4L2_BUF_TYPE_VIDEO_CAPTURE        = 1,
		V4L2_BUF_TYPE_VIDEO_OUTPUT         = 2,
		V4L2_BUF_TYPE_VIDEO_OVERLAY        = 3,
		V4L2_BUF_TYPE_VBI_CAPTURE          = 4,
		V4L2_BUF_TYPE_VBI_OUTPUT           = 5,
		V4L2_BUF_TYPE_SLICED_VBI_CAPTURE   = 6,
		V4L2_BUF_TYPE_SLICED_VBI_OUTPUT    = 7,
		V4L2_BUF_TYPE_VIDEO_OUTPUT_OVERLAY = 8,
		V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE = 9,
		V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE  = 10,
	};

	v4l2_tuner_type = {
		V4L2_TUNER_RADIO	     	= 1,
		V4L2_TUNER_ANALOG_TV	    = 2,
		V4L2_TUNER_DIGITAL_TV	    = 3,
	};

	v4l2_memory = {
		V4L2_MEMORY_MMAP             = 1,
		V4L2_MEMORY_USERPTR          = 2,
		V4L2_MEMORY_OVERLAY          = 3,
		V4L2_MEMORY_DMABUF           = 4,
	};

	-- see also http://vektor.theorem.ca/graphics/ycbcr/ */
	v4l2_colorspace = {
		V4L2_COLORSPACE_SMPTE170M     = 1,	-- ITU-R 601 -- broadcast NTSC/PAL 
		V4L2_COLORSPACE_SMPTE240M     = 2,	-- 1125-Line (US) HDTV 
		V4L2_COLORSPACE_REC709        = 3,	-- HD and modern captures. 
		V4L2_COLORSPACE_BT878         = 4,	-- broken BT878 extents (601, luma range 16-253 instead of 16-235)
		V4L2_COLORSPACE_470_SYSTEM_M  = 5,
		V4L2_COLORSPACE_470_SYSTEM_BG = 6,
		V4L2_COLORSPACE_JPEG          = 7,
		V4L2_COLORSPACE_SRGB          = 8,
	};

	v4l2_priority = {
		V4L2_PRIORITY_UNSET       = 0,  -- not initialized
		V4L2_PRIORITY_BACKGROUND  = 1,
		V4L2_PRIORITY_INTERACTIVE = 2,
		V4L2_PRIORITY_RECORD      = 3,
		V4L2_PRIORITY_DEFAULT     = 2,	-- V4L2_PRIORITY_INTERACTIVE,
	};
}


local Constants = {
	-- from v4l2_common
	V4L2_SEL_TGT_CROP			= 0x0000;		-- Current cropping area
	V4L2_SEL_TGT_CROP_DEFAULT	= 0x0001;		-- Default cropping area
	V4L2_SEL_TGT_CROP_BOUNDS	= 0x0002;		-- Cropping bounds
	V4L2_SEL_TGT_COMPOSE		= 0x0100;		-- Current composing area
	V4L2_SEL_TGT_COMPOSE_DEFAULT= 0x0101;	-- Default composing area
	V4L2_SEL_TGT_COMPOSE_BOUNDS	= 0x0102;	-- Composing bounds
	V4L2_SEL_TGT_COMPOSE_PADDED	= 0x0103;	-- Current composing area plus all padding pixels

	-- Selection flags */
	V4L2_SEL_FLAG_GE			= lshift(1, 0);
	V4L2_SEL_FLAG_LE			= lshift(1, 1);
	V4L2_SEL_FLAG_KEEP_CONFIG	= lshift(1, 2);


	-- Values for 'capabilities' field
	V4L2_CAP_VIDEO_CAPTURE		= 0x00000001 ; -- Is a video capture device */
	V4L2_CAP_VIDEO_OUTPUT		= 0x00000002; -- Is a video output device */
	V4L2_CAP_VIDEO_OVERLAY		= 0x00000004; -- Can do video overlay */
	V4L2_CAP_VBI_CAPTURE		= 0x00000010; -- Is a raw VBI capture device */
	V4L2_CAP_VBI_OUTPUT			= 0x00000020; -- Is a raw VBI output device */
	V4L2_CAP_SLICED_VBI_CAPTURE	= 0x00000040; -- Is a sliced VBI capture device */
	V4L2_CAP_SLICED_VBI_OUTPUT	= 0x00000080; -- Is a sliced VBI output device */
	V4L2_CAP_RDS_CAPTURE		= 0x00000100; -- RDS data capture */
	V4L2_CAP_VIDEO_OUTPUT_OVERLAY	= 0x00000200; -- Can do video output overlay */
	V4L2_CAP_HW_FREQ_SEEK		= 0x00000400; -- Can do hardware frequency seek  */
	V4L2_CAP_RDS_OUTPUT			= 0x00000800; -- Is an RDS encoder */

	V4L2_CAP_VIDEO_CAPTURE_MPLANE	= 0x00001000;
	V4L2_CAP_VIDEO_OUTPUT_MPLANE	= 0x00002000;
	V4L2_CAP_VIDEO_M2M_MPLANE		= 0x00004000;
	V4L2_CAP_VIDEO_M2M				= 0x00008000;

	V4L2_CAP_TUNER			= 0x00010000; -- has a tuner */
	V4L2_CAP_AUDIO			= 0x00020000; -- has audio support */
	V4L2_CAP_RADIO			= 0x00040000; -- is a radio device */
	V4L2_CAP_MODULATOR		= 0x00080000; -- has a modulator */

	V4L2_CAP_READWRITE              = 0x01000000; -- read/write systemcalls */
	V4L2_CAP_ASYNCIO                = 0x02000000; -- async I/O */
	V4L2_CAP_STREAMING              = 0x04000000; -- streaming I/O ioctls */

	V4L2_CAP_DEVICE_CAPS            = 0x80000000; -- sets device capabilities field */

	VIDEO_MAX_FRAME              = 32;
	VIDEO_MAX_PLANES              = 8;
}



local v42l_field = Enums.v4l2_field;
local v4l2_buf_type = Enums.v4l2_buf_type;

local function V4L2_FIELD_HAS_TOP(field)	
	return ((field) == v4l2_field.V4L2_FIELD_TOP 	or
	 (field) == v4l2_field.V4L2_FIELD_INTERLACED or
	 (field) == v4l2_field.V4L2_FIELD_INTERLACED_TB or
	 (field) == v4l2_field.V4L2_FIELD_INTERLACED_BT or
	 (field) == v4l2_field.V4L2_FIELD_SEQ_TB	or
	 (field) == v4l2_field.V4L2_FIELD_SEQ_BT)
end 

local function V4L2_FIELD_HAS_BOTTOM(field)	
	return ((field) == v4l2_field.V4L2_FIELD_BOTTOM 	or
	 (field) == v4l2_field.V4L2_FIELD_INTERLACED or
	 (field) == v4l2_field.V4L2_FIELD_INTERLACED_TB or
	 (field) == v4l2_field.V4L2_FIELD_INTERLACED_BT or
	 (field) == v4l2_field.V4L2_FIELD_SEQ_TB	or
	 (field) == v4l2_field.V4L2_FIELD_SEQ_BT)
end

local function V4L2_FIELD_HAS_BOTH(field)	
	return ((field) == v4l2_field.V4L2_FIELD_INTERLACED or
	 (field) == v4l2_field.V4L2_FIELD_INTERLACED_TB or
	 (field) == v4l2_field.V4L2_FIELD_INTERLACED_BT or
	 (field) == v4l2_field.V4L2_FIELD_SEQ_TB or
	 (field) == v4l2_field.V4L2_FIELD_SEQ_BT)
end

local function V4L2_TYPE_IS_MULTIPLANAR(atype)			
	return ((atype) == v4l2_buf_type.V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE	or 
		(atype) == v4l2_buf_type.V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE)
end

local function V4L2_TYPE_IS_OUTPUT(atype)
	return ((atype) == v4l2_buf_type.V4L2_BUF_TYPE_VIDEO_OUTPUT
	 or (atype) == v4l2_buf_type.V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE
	 or (atype) == v4l2_buf_type.V4L2_BUF_TYPE_VIDEO_OVERLAY		
	 or (atype) == v4l2_buf_type.V4L2_BUF_TYPE_VIDEO_OUTPUT_OVERLAY	
	 or (atype) == v4l2_buf_type.V4L2_BUF_TYPE_VBI_OUTPUT			
	 or (atype) == v4l2_buf_type.V4L2_BUF_TYPE_SLICED_VBI_OUTPUT)
end


local Functions = {
	V4L2_FIELD_HAS_TOP = V4L2_FIELD_HAS_TOP;
	V4L2_FIELD_HAS_BOTTOM = V4L2_FIELD_HAS_BOTTOM;
	V4L2_FIELD_HAS_BOTH = V4L2_FIELD_HAS_BOTH;
	V4L2_TYPE_IS_MULTIPLANAR = V4L2_TYPE_IS_MULTIPLANAR;
	V4L2_TYPE_IS_OUTPUT = V4L2_TYPE_IS_OUTPUT;
}

local exports = {
	Constants = Constants;
	Enums = Enums;
	Functions = Functions;
}


