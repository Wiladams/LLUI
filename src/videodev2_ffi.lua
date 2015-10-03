local ffi = require("ffi")

require("v4l2_controls")
local libc = require("libc")


ffi.cdef[[
struct v4l2_rect {
	__s32   left;
	__s32   top;
	__s32   width;
	__s32   height;
};

struct v4l2_fract {
	__u32   numerator;
	__u32   denominator;
};

struct v4l2_capability {
	__u8	driver[16];
	__u8	card[32];
	__u8	bus_info[32];
	__u32   version;
	__u32	capabilities;
	__u32	device_caps;
	__u32	reserved[3];
};
]]



ffi.cdef[[
/*
 *	V I D E O   I M A G E   F O R M A T
 */
struct v4l2_pix_format {
	__u32         	width;
	__u32			height;
	__u32			pixelformat;
	__u32			field;		/* enum v4l2_field */
	__u32           bytesperline;	/* for padding, zero if unused */
	__u32          	sizeimage;
	__u32			colorspace;	/* enum v4l2_colorspace */
	__u32			priv;		/* private data, depends on pixelformat */
};
]]

ffi.cdef[[
/*
 *	F O R M A T   E N U M E R A T I O N
 */
struct v4l2_fmtdesc {
	__u32		    index;             /* Format number      */
	__u32		    type;              /* enum v4l2_buf_type */
	__u32           flags;
	__u8		    description[32];   /* Description string */
	__u32		    pixelformat;       /* Format fourcc      */
	__u32		    reserved[4];
};
]]


#define V4L2_FMT_FLAG_COMPRESSED 0x0001
#define V4L2_FMT_FLAG_EMULATED   0x0002


ffi.cdef[[
	/* Experimental Frame Size and frame rate enumeration */
/*
 *	F R A M E   S I Z E   E N U M E R A T I O N
 */
enum v4l2_frmsizetypes {
	V4L2_FRMSIZE_TYPE_DISCRETE	= 1,
	V4L2_FRMSIZE_TYPE_CONTINUOUS	= 2,
	V4L2_FRMSIZE_TYPE_STEPWISE	= 3,
};

struct v4l2_frmsize_discrete {
	__u32			width;		/* Frame width [pixel] */
	__u32			height;		/* Frame height [pixel] */
};

struct v4l2_frmsize_stepwise {
	__u32			min_width;	/* Minimum frame width [pixel] */
	__u32			max_width;	/* Maximum frame width [pixel] */
	__u32			step_width;	/* Frame width step size [pixel] */
	__u32			min_height;	/* Minimum frame height [pixel] */
	__u32			max_height;	/* Maximum frame height [pixel] */
	__u32			step_height;	/* Frame height step size [pixel] */
};

struct v4l2_frmsizeenum {
	__u32			index;		/* Frame size number */
	__u32			pixel_format;	/* Pixel format */
	__u32			type;		/* Frame size type the device supports. */

	union {					/* Frame size */
		struct v4l2_frmsize_discrete	discrete;
		struct v4l2_frmsize_stepwise	stepwise;
	};

	__u32   reserved[2];			/* Reserved space for future use */
};
]]

ffi.cdef[[
/*
 *	F R A M E   R A T E   E N U M E R A T I O N
 */
enum v4l2_frmivaltypes {
	V4L2_FRMIVAL_TYPE_DISCRETE	= 1,
	V4L2_FRMIVAL_TYPE_CONTINUOUS	= 2,
	V4L2_FRMIVAL_TYPE_STEPWISE	= 3,
};

struct v4l2_frmival_stepwise {
	struct v4l2_fract	min;		/* Minimum frame interval [s] */
	struct v4l2_fract	max;		/* Maximum frame interval [s] */
	struct v4l2_fract	step;		/* Frame interval step size [s] */
};

struct v4l2_frmivalenum {
	__u32			index;		/* Frame format index */
	__u32			pixel_format;	/* Pixel format */
	__u32			width;		/* Frame width */
	__u32			height;		/* Frame height */
	__u32			type;		/* Frame interval type the device supports. */

	union {					/* Frame interval */
		struct v4l2_fract		discrete;
		struct v4l2_frmival_stepwise	stepwise;
	};

	__u32	reserved[2];			/* Reserved space for future use */
};

]]

ffi.cdef[[
/*
 *	T I M E C O D E
 */
struct v4l2_timecode {
	__u32	type;
	__u32	flags;
	__u8	frames;
	__u8	seconds;
	__u8	minutes;
	__u8	hours;
	__u8	userbits[4];
};
]]

/*  Type  */
#define V4L2_TC_TYPE_24FPS		1
#define V4L2_TC_TYPE_25FPS		2
#define V4L2_TC_TYPE_30FPS		3
#define V4L2_TC_TYPE_50FPS		4
#define V4L2_TC_TYPE_60FPS		5

/*  Flags  */
#define V4L2_TC_FLAG_DROPFRAME		0x0001 /* "drop-frame" mode */
#define V4L2_TC_FLAG_COLORFRAME		0x0002
#define V4L2_TC_USERBITS_field		0x000C
#define V4L2_TC_USERBITS_USERDEFINED	0x0000
#define V4L2_TC_USERBITS_8BITCHARS	0x0008
/* The above is based on SMPTE timecodes */

ffi.cdef[[
struct v4l2_jpegcompression {
	int quality;

	int  APPn;              /* Number of APP segment to be written,
				 * must be 0..15 */
	int  APP_len;           /* Length of data in JPEG APPn segment */
	char APP_data[60];      /* Data in the JPEG APPn segment. */

	int  COM_len;           /* Length of data in JPEG COM segment */
	char COM_data[60];      /* Data in JPEG COM segment */

	__u32 jpeg_markers;     /* Which markers should go into the JPEG
				 * output. Unless you exactly know what
				 * you do, leave them untouched.
				 * Including less markers will make the
				 * resulting code smaller, but there will
				 * be fewer applications which can read it.
				 * The presence of the APP and COM marker
				 * is influenced by APP_len and COM_len
				 * ONLY, not by this property! */

#define V4L2_JPEG_MARKER_DHT (1<<3)    /* Define Huffman Tables */
#define V4L2_JPEG_MARKER_DQT (1<<4)    /* Define Quantization Tables */
#define V4L2_JPEG_MARKER_DRI (1<<5)    /* Define Restart Interval */
#define V4L2_JPEG_MARKER_COM (1<<6)    /* Comment segment */
#define V4L2_JPEG_MARKER_APP (1<<7)    /* App segment, driver will
					* always use APP0 */
};
]]

ffi.cdef[[
/*
 *	M E M O R Y - M A P P I N G   B U F F E R S
 */
struct v4l2_requestbuffers {
	__u32			count;
	__u32			type;		/* enum v4l2_buf_type */
	__u32			memory;		/* enum v4l2_memory */
	__u32			reserved[2];
};
]]

ffi.cdef[[

struct v4l2_plane {
	__u32			bytesused;
	__u32			length;
	union {
		__u32		mem_offset;
		unsigned long	userptr;
		__s32		fd;
	} m;
	__u32			data_offset;
	__u32			reserved[11];
};
]]

ffi.cdef[[

struct v4l2_buffer {
	__u32			index;
	__u32			type;
	__u32			bytesused;
	__u32			flags;
	__u32			field;
	struct timeval		timestamp;
	struct v4l2_timecode	timecode;
	__u32			sequence;

	/* memory location */
	__u32			memory;
	union {
		__u32           offset;
		unsigned long   userptr;
		struct v4l2_plane *planes;
		__s32		fd;
	} m;
	__u32			length;
	__u32			reserved2;
	__u32			reserved;
};
]]


/*  Flags for 'flags' field */
#define V4L2_BUF_FLAG_MAPPED	0x0001  /* Buffer is mapped (flag) */
#define V4L2_BUF_FLAG_QUEUED	0x0002	/* Buffer is queued for processing */
#define V4L2_BUF_FLAG_DONE	0x0004	/* Buffer is ready */
#define V4L2_BUF_FLAG_KEYFRAME	0x0008	/* Image is a keyframe (I-frame) */
#define V4L2_BUF_FLAG_PFRAME	0x0010	/* Image is a P-frame */
#define V4L2_BUF_FLAG_BFRAME	0x0020	/* Image is a B-frame */
/* Buffer is ready, but the data contained within is corrupted. */
#define V4L2_BUF_FLAG_ERROR	0x0040
#define V4L2_BUF_FLAG_TIMECODE	0x0100	/* timecode field is valid */
#define V4L2_BUF_FLAG_PREPARED	0x0400	/* Buffer is prepared for queuing */
/* Cache handling flags */
#define V4L2_BUF_FLAG_NO_CACHE_INVALIDATE	0x0800
#define V4L2_BUF_FLAG_NO_CACHE_CLEAN		0x1000
/* Timestamp type */
#define V4L2_BUF_FLAG_TIMESTAMP_MASK		0xe000
#define V4L2_BUF_FLAG_TIMESTAMP_UNKNOWN		0x0000
#define V4L2_BUF_FLAG_TIMESTAMP_MONOTONIC	0x2000
#define V4L2_BUF_FLAG_TIMESTAMP_COPY		0x4000


ffi.cdef[[

struct v4l2_exportbuffer {
	__u32		type; /* enum v4l2_buf_type */
	__u32		index;
	__u32		plane;
	__u32		flags;
	__s32		fd;
	__u32		reserved[11];
};
]]

ffi.cdef[[
\
struct v4l2_framebuffer {
	__u32			capability;
	__u32			flags;
/* FIXME: in theory we should pass something like PCI device + memory
 * region + offset instead of some physical address */
	void                    *base;
	struct v4l2_pix_format	fmt;
};
]]



/*  Flags for the 'capability' field (v4l2_framebuffer). Read only */
#define V4L2_FBUF_CAP_EXTERNOVERLAY	0x0001
#define V4L2_FBUF_CAP_CHROMAKEY		0x0002
#define V4L2_FBUF_CAP_LIST_CLIPPING     0x0004
#define V4L2_FBUF_CAP_BITMAP_CLIPPING	0x0008
#define V4L2_FBUF_CAP_LOCAL_ALPHA	0x0010
#define V4L2_FBUF_CAP_GLOBAL_ALPHA	0x0020
#define V4L2_FBUF_CAP_LOCAL_INV_ALPHA	0x0040
#define V4L2_FBUF_CAP_SRC_CHROMAKEY	0x0080
/*  Flags for the 'flags' field. */
#define V4L2_FBUF_FLAG_PRIMARY		0x0001
#define V4L2_FBUF_FLAG_OVERLAY		0x0002
#define V4L2_FBUF_FLAG_CHROMAKEY	0x0004
#define V4L2_FBUF_FLAG_LOCAL_ALPHA	0x0008
#define V4L2_FBUF_FLAG_GLOBAL_ALPHA	0x0010
#define V4L2_FBUF_FLAG_LOCAL_INV_ALPHA	0x0020
#define V4L2_FBUF_FLAG_SRC_CHROMAKEY	0x0040

ffi.cdef[[
struct v4l2_clip {
	struct v4l2_rect        c;
	struct v4l2_clip	*next;
};

struct v4l2_window {
	struct v4l2_rect        w;
	__u32			field;	 /* enum v4l2_field */
	__u32			chromakey;
	struct v4l2_clip	*clips;
	__u32			clipcount;
	void			*bitmap;
	__u8                    global_alpha;
};
]]


ffi.cdef[[
/*
 *	C A P T U R E   P A R A M E T E R S
 */
struct v4l2_captureparm {
	__u32		   capability;	  /*  Supported modes */
	__u32		   capturemode;	  /*  Current mode */
	struct v4l2_fract  timeperframe;  /*  Time per frame in seconds */
	__u32		   extendedmode;  /*  Driver-specific extensions */
	__u32              readbuffers;   /*  # of buffers for read */
	__u32		   reserved[4];
};
]]


/*  Flags for 'capability' and 'capturemode' fields */
#define V4L2_MODE_HIGHQUALITY	0x0001	/*  High quality imaging mode */
#define V4L2_CAP_TIMEPERFRAME	0x1000	/*  timeperframe field is supported */

ffi.cdef[[
struct v4l2_outputparm {
	__u32		   capability;	 /*  Supported modes */
	__u32		   outputmode;	 /*  Current mode */
	struct v4l2_fract  timeperframe; /*  Time per frame in seconds */
	__u32		   extendedmode; /*  Driver-specific extensions */
	__u32              writebuffers; /*  # of buffers for write */
	__u32		   reserved[4];
};
]]

ffi.cdef[[
/*
 *	I N P U T   I M A G E   C R O P P I N G
 */
struct v4l2_cropcap {
	__u32			type;	/* enum v4l2_buf_type */
	struct v4l2_rect        bounds;
	struct v4l2_rect        defrect;
	struct v4l2_fract       pixelaspect;
};

struct v4l2_crop {
	__u32			type;	/* enum v4l2_buf_type */
	struct v4l2_rect        c;
};

struct v4l2_selection {
	__u32			type;
	__u32			target;
	__u32                   flags;
	struct v4l2_rect        r;
	__u32                   reserved[9];
};
]]


--[[
/*
 *      A N A L O G   V I D E O   S T A N D A R D
 */
--]]

--typedef __u64 v4l2_std_id;
--local function v42l_std_id(x) return tonumber(x) end
-- WAA - these constants should move into videodev2.lua
-- one bit for each */
	V4L2_STD_PAL_B           = 0x00000001;
	V4L2_STD_PAL_B1          = 0x00000002;
	V4L2_STD_PAL_G           = 0x00000004;
	V4L2_STD_PAL_H           = 0x00000008;
	V4L2_STD_PAL_I           = 0x00000010;
	V4L2_STD_PAL_D           = 0x00000020;
	V4L2_STD_PAL_D1          = 0x00000040;
	V4L2_STD_PAL_K           = 0x00000080;

	V4L2_STD_PAL_M           = 0x00000100;
	V4L2_STD_PAL_N           = 0x00000200;
	V4L2_STD_PAL_Nc          = 0x00000400;
	V4L2_STD_PAL_60          = 0x00000800;

	V4L2_STD_NTSC_M          = 0x00001000;	-- BTSC
	V4L2_STD_NTSC_M_JP       = 0x00002000;	-- EIA-J
	V4L2_STD_NTSC_443        = 0x00004000;
	V4L2_STD_NTSC_M_KR       = 0x00008000;	-- FM A2

	V4L2_STD_SECAM_B         = 0x00010000;
	V4L2_STD_SECAM_D         = 0x00020000;
	V4L2_STD_SECAM_G         = 0x00040000;
	V4L2_STD_SECAM_H         = 0x00080000;
	V4L2_STD_SECAM_K         = 0x00100000;
	V4L2_STD_SECAM_K1        = 0x00200000;
	V4L2_STD_SECAM_L         = 0x00400000;
	V4L2_STD_SECAM_LC        = 0x00800000;

-- ATSC/HDTV 
	V4L2_STD_ATSC_8_VSB      = 0x01000000;
	V4L2_STD_ATSC_16_VSB     = 0x02000000;




-- NTSC Macros
V4L2_STD_NTSC =          bor(V4L2_STD_NTSC_M, V4L2_STD_NTSC_M_JP, V4L2_STD_NTSC_M_KR);

-- Secam macros
V4L2_STD_SECAM_DK =     bor(V4L2_STD_SECAM_D, V4L2_STD_SECAM_K, V4L2_STD_SECAM_K1);

-- All Secam Standards
V4L2_STD_SECAM	=	bor(V4L2_STD_SECAM_B,
				 V4L2_STD_SECAM_G,
				 V4L2_STD_SECAM_H,
				 V4L2_STD_SECAM_DK,
				 V4L2_STD_SECAM_L,
				 V4L2_STD_SECAM_LC)

-- PAL macros 
V4L2_STD_PAL_BG	=	bor(V4L2_STD_PAL_B,
				 V4L2_STD_PAL_B1,
				 V4L2_STD_PAL_G)
V4L2_STD_PAL_DK		bor(V4L2_STD_PAL_D,
				 V4L2_STD_PAL_D1,
				 V4L2_STD_PAL_K)
--[[
 * "Common" PAL - This macro is there to be compatible with the old
 * V4L1 concept of "PAL": /BGDKHI.
 * Several PAL standards are missing here: /M, /N and /Nc
--]]
#define V4L2_STD_PAL		(V4L2_STD_PAL_BG	|
				 V4L2_STD_PAL_DK	|
				 V4L2_STD_PAL_H		|
				 V4L2_STD_PAL_I)

-- Chroma "agnostic" standards
#define V4L2_STD_B		bor(V4L2_STD_PAL_B		|
				 V4L2_STD_PAL_B1	|
				 V4L2_STD_SECAM_B);
#define V4L2_STD_G		bor(V4L2_STD_PAL_G		|
				 V4L2_STD_SECAM_G);
#define V4L2_STD_H		bor(V4L2_STD_PAL_H		|
				 V4L2_STD_SECAM_H);
#define V4L2_STD_L		bor(V4L2_STD_SECAM_L	|
				 V4L2_STD_SECAM_LC);
#define V4L2_STD_GH		bor(V4L2_STD_G		|
				 V4L2_STD_H);
#define V4L2_STD_DK		bor(V4L2_STD_PAL_DK	|
				 V4L2_STD_SECAM_DK);
#define V4L2_STD_BG		bor(V4L2_STD_B		|
				 V4L2_STD_G);
#define V4L2_STD_MN		bor(V4L2_STD_PAL_M		|
				 V4L2_STD_PAL_N		|
				 V4L2_STD_PAL_Nc	|
				 V4L2_STD_NTSC);

/* Standards where MTS/BTSC stereo could be found */
#define V4L2_STD_MTS		(V4L2_STD_NTSC_M	|\
				 V4L2_STD_PAL_M		|\
				 V4L2_STD_PAL_N		|\
				 V4L2_STD_PAL_Nc)

/* Standards for Countries with 60Hz Line frequency */
#define V4L2_STD_525_60		(V4L2_STD_PAL_M		|\
				 V4L2_STD_PAL_60	|\
				 V4L2_STD_NTSC		|\
				 V4L2_STD_NTSC_443)
/* Standards for Countries with 50Hz Line frequency */
#define V4L2_STD_625_50		(V4L2_STD_PAL		|\
				 V4L2_STD_PAL_N		|\
				 V4L2_STD_PAL_Nc	|\
				 V4L2_STD_SECAM)

#define V4L2_STD_ATSC           (V4L2_STD_ATSC_8_VSB    |\
				 V4L2_STD_ATSC_16_VSB)
/* Macros with none and all analog standards */
#define V4L2_STD_UNKNOWN        0
#define V4L2_STD_ALL            (V4L2_STD_525_60	|\
				 V4L2_STD_625_50)

ffi.cdef[[
struct v4l2_standard {
	__u32		     index;
	v4l2_std_id          id;
	__u8		     name[24];
	struct v4l2_fract    frameperiod; /* Frames, not fields */
	__u32		     framelines;
	__u32		     reserved[4];
};
]]

ffi.cdef[[
/*
 *	D V 	B T	T I M I N G S
 */

/** struct v4l2_bt_timings - BT.656/BT.1120 timing data
 * @width:	total width of the active video in pixels
 * @height:	total height of the active video in lines
 * @interlaced:	Interlaced or progressive
 * @polarities:	Positive or negative polarities
 * @pixelclock:	Pixel clock in HZ. Ex. 74.25MHz->74250000
 * @hfrontporch:Horizontal front porch in pixels
 * @hsync:	Horizontal Sync length in pixels
 * @hbackporch:	Horizontal back porch in pixels
 * @vfrontporch:Vertical front porch in lines
 * @vsync:	Vertical Sync length in lines
 * @vbackporch:	Vertical back porch in lines
 * @il_vfrontporch:Vertical front porch for the even field
 *		(aka field 2) of interlaced field formats
 * @il_vsync:	Vertical Sync length for the even field
 *		(aka field 2) of interlaced field formats
 * @il_vbackporch:Vertical back porch for the even field
 *		(aka field 2) of interlaced field formats
 * @standards:	Standards the timing belongs to
 * @flags:	Flags
 * @reserved:	Reserved fields, must be zeroed.
 *
 * A note regarding vertical interlaced timings: height refers to the total
 * height of the active video frame (= two fields). The blanking timings refer
 * to the blanking of each field. So the height of the total frame is
 * calculated as follows:
 *
 * tot_height = height + vfrontporch + vsync + vbackporch +
 *                       il_vfrontporch + il_vsync + il_vbackporch
 *
 * The active height of each field is height / 2.
 */
struct v4l2_bt_timings {
	__u32	width;
	__u32	height;
	__u32	interlaced;
	__u32	polarities;
	__u64	pixelclock;
	__u32	hfrontporch;
	__u32	hsync;
	__u32	hbackporch;
	__u32	vfrontporch;
	__u32	vsync;
	__u32	vbackporch;
	__u32	il_vfrontporch;
	__u32	il_vsync;
	__u32	il_vbackporch;
	__u32	standards;
	__u32	flags;
	__u32	reserved[14];
} __attribute__ ((packed));
]]

/* Interlaced or progressive format */
#define	V4L2_DV_PROGRESSIVE	0
#define	V4L2_DV_INTERLACED	1

/* Polarities. If bit is not set, it is assumed to be negative polarity */
#define V4L2_DV_VSYNC_POS_POL	0x00000001
#define V4L2_DV_HSYNC_POS_POL	0x00000002

/* Timings standards */
#define V4L2_DV_BT_STD_CEA861	(1 << 0)  /* CEA-861 Digital TV Profile */
#define V4L2_DV_BT_STD_DMT	(1 << 1)  /* VESA Discrete Monitor Timings */
#define V4L2_DV_BT_STD_CVT	(1 << 2)  /* VESA Coordinated Video Timings */
#define V4L2_DV_BT_STD_GTF	(1 << 3)  /* VESA Generalized Timings Formula */

/* Flags */
#define V4L2_DV_FL_REDUCED_BLANKING		(1 << 0)

#define V4L2_DV_FL_CAN_REDUCE_FPS		(1 << 1)

#define V4L2_DV_FL_REDUCED_FPS			(1 << 2)
/* Specific to interlaced formats: if set, then field 1 is really one half-line
   longer and field 2 is really one half-line shorter, so each field has
   exactly the same number of half-lines. Whether half-lines can be detected
   or used depends on the hardware. */
#define V4L2_DV_FL_HALF_LINE			(1 << 3)

-- A few useful defines to calculate the total blanking and frame sizes
local function V4L2_DV_BT_BLANKING_WIDTH(bt)
	return (bt->hfrontporch + bt->hsync + bt->hbackporch)
end

local function V4L2_DV_BT_FRAME_WIDTH(bt) 
	return (bt->width + V4L2_DV_BT_BLANKING_WIDTH(bt))
end

local function V4L2_DV_BT_BLANKING_HEIGHT(bt) \
	return (bt->vfrontporch + bt->vsync + bt->vbackporch + 
	 bt->il_vfrontporch + bt->il_vsync + bt->il_vbackporch)
end

local function V4L2_DV_BT_FRAME_HEIGHT(bt) \
	return (bt->height + V4L2_DV_BT_BLANKING_HEIGHT(bt))
end

ffi.cdef[[
/** struct v4l2_dv_timings - DV timings
 * @type:	the type of the timings
 * @bt:	BT656/1120 timings
 */
struct v4l2_dv_timings {
	__u32 type;
	union {
		struct v4l2_bt_timings	bt;
		__u32	reserved[32];
	};
} __attribute__ ((packed));
]]

-- Values for the type field
	V4L2_DV_BT_656_1120	 = 0;	-- BT.656/1120 timing type

ffi.cdef[[
struct v4l2_enum_dv_timings {
	__u32 index;
	__u32 reserved[3];
	struct v4l2_dv_timings timings;
};
]]

ffi.cdef[[
struct v4l2_bt_timings_cap {
	__u32	min_width;
	__u32	max_width;
	__u32	min_height;
	__u32	max_height;
	__u64	min_pixelclock;
	__u64	max_pixelclock;
	__u32	standards;
	__u32	capabilities;
	__u32	reserved[16];
} __attribute__ ((packed));
]]

#define V4L2_DV_BT_CAP_INTERLACED	(1 << 0)
#define V4L2_DV_BT_CAP_PROGRESSIVE	(1 << 1)
#define V4L2_DV_BT_CAP_REDUCED_BLANKING	(1 << 2)
#define V4L2_DV_BT_CAP_CUSTOM		(1 << 3)

ffi.cdef[[
struct v4l2_dv_timings_cap {
	__u32 type;
	__u32 reserved[3];
	union {
		struct v4l2_bt_timings_cap bt;
		__u32 raw_data[32];
	};
};
]]

--[[
 *	V I D E O   I N P U T S
--]]
ffi.cdef[[
struct v4l2_input {
	__u32	     index;		/*  Which input */
	__u8	     name[32];		/*  Label */
	__u32	     type;		/*  Type of input */
	__u32	     audioset;		/*  Associated audios (bitfield) */
	__u32        tuner;             /*  enum v4l2_tuner_type */
	v4l2_std_id  std;
	__u32	     status;
	__u32	     capabilities;
	__u32	     reserved[3];
};
]]

--  Values for the 'type' field */
#define V4L2_INPUT_TYPE_TUNER		1
#define V4L2_INPUT_TYPE_CAMERA		2

-- field 'status' - general */
#define V4L2_IN_ST_NO_POWER    0x00000001  /* Attached device is off */
#define V4L2_IN_ST_NO_SIGNAL   0x00000002
#define V4L2_IN_ST_NO_COLOR    0x00000004

-- field 'status' - sensor orientation
-- If sensor is mounted upside down set both bits
#define V4L2_IN_ST_HFLIP       0x00000010 /* Frames are flipped horizontally */
#define V4L2_IN_ST_VFLIP       0x00000020 /* Frames are flipped vertically */

/* field 'status' - analog */
#define V4L2_IN_ST_NO_H_LOCK   0x00000100  /* No horizontal sync lock */
#define V4L2_IN_ST_COLOR_KILL  0x00000200  /* Color killer is active */

/* field 'status' - digital */
#define V4L2_IN_ST_NO_SYNC     0x00010000  /* No synchronization lock */
#define V4L2_IN_ST_NO_EQU      0x00020000  /* No equalizer lock */
#define V4L2_IN_ST_NO_CARRIER  0x00040000  /* Carrier recovery failed */

/* field 'status' - VCR and set-top box */
#define V4L2_IN_ST_MACROVISION 0x01000000  /* Macrovision detected */
#define V4L2_IN_ST_NO_ACCESS   0x02000000  /* Conditional access denied */
#define V4L2_IN_ST_VTR         0x04000000  /* VTR time constant */

/* capabilities flags */
#define V4L2_IN_CAP_DV_TIMINGS		0x00000002 /* Supports S_DV_TIMINGS */
#define V4L2_IN_CAP_CUSTOM_TIMINGS	V4L2_IN_CAP_DV_TIMINGS /* For compatibility */
#define V4L2_IN_CAP_STD			0x00000004 /* Supports S_STD */

--[[
	V I D E O   O U T P U T S
--]]
ffi.cdef[[
struct v4l2_output {
	__u32	     index;		/*  Which output */
	__u8	     name[32];		/*  Label */
	__u32	     type;		/*  Type of output */
	__u32	     audioset;		/*  Associated audios (bitfield) */
	__u32	     modulator;         /*  Associated modulator */
	v4l2_std_id  std;
	__u32	     capabilities;
	__u32	     reserved[3];
};
]]

/*  Values for the 'type' field */
#define V4L2_OUTPUT_TYPE_MODULATOR		1
#define V4L2_OUTPUT_TYPE_ANALOG			2
#define V4L2_OUTPUT_TYPE_ANALOGVGAOVERLAY	3

/* capabilities flags */
#define V4L2_OUT_CAP_DV_TIMINGS		0x00000002 /* Supports S_DV_TIMINGS */
#define V4L2_OUT_CAP_CUSTOM_TIMINGS	V4L2_OUT_CAP_DV_TIMINGS /* For compatibility */
#define V4L2_OUT_CAP_STD		0x00000004 /* Supports S_STD */

--[[
 *	C O N T R O L S
 */
--]]
ffi.cdef[[
struct v4l2_control {
	__u32		     id;
	__s32		     value;
};

struct v4l2_ext_control {
	__u32 id;
	__u32 size;
	__u32 reserved2[1];
	union {
		__s32 value;
		__s64 value64;
		char *string;
	};
} __attribute__ ((packed));

struct v4l2_ext_controls {
	__u32 ctrl_class;
	__u32 count;
	__u32 error_idx;
	__u32 reserved[2];
	struct v4l2_ext_control *controls;
};
]]

#define V4L2_CTRL_ID_MASK      	  (0x0fffffff)
#define V4L2_CTRL_ID2CLASS(id)    ((id) & 0x0fff0000UL)
#define V4L2_CTRL_DRIVER_PRIV(id) (((id) & 0xffff) >= 0x1000)

enum v4l2_ctrl_type {
	V4L2_CTRL_TYPE_INTEGER	     = 1,
	V4L2_CTRL_TYPE_BOOLEAN	     = 2,
	V4L2_CTRL_TYPE_MENU	     = 3,
	V4L2_CTRL_TYPE_BUTTON	     = 4,
	V4L2_CTRL_TYPE_INTEGER64     = 5,
	V4L2_CTRL_TYPE_CTRL_CLASS    = 6,
	V4L2_CTRL_TYPE_STRING        = 7,
	V4L2_CTRL_TYPE_BITMASK       = 8,
	V4L2_CTRL_TYPE_INTEGER_MENU = 9,
};

/*  Used in the VIDIOC_QUERYCTRL ioctl for querying controls */
struct v4l2_queryctrl {
	__u32		     id;
	__u32		     type;	/* enum v4l2_ctrl_type */
	__u8		     name[32];	/* Whatever */
	__s32		     minimum;	/* Note signedness */
	__s32		     maximum;
	__s32		     step;
	__s32		     default_value;
	__u32                flags;
	__u32		     reserved[2];
};

/*  Used in the VIDIOC_QUERYMENU ioctl for querying menu items */
struct v4l2_querymenu {
	__u32		id;
	__u32		index;
	union {
		__u8	name[32];	/* Whatever */
		__s64	value;
	};
	__u32		reserved;
} __attribute__ ((packed));

/*  Control flags  */
#define V4L2_CTRL_FLAG_DISABLED		0x0001
#define V4L2_CTRL_FLAG_GRABBED		0x0002
#define V4L2_CTRL_FLAG_READ_ONLY 	0x0004
#define V4L2_CTRL_FLAG_UPDATE 		0x0008
#define V4L2_CTRL_FLAG_INACTIVE 	0x0010
#define V4L2_CTRL_FLAG_SLIDER 		0x0020
#define V4L2_CTRL_FLAG_WRITE_ONLY 	0x0040
#define V4L2_CTRL_FLAG_VOLATILE		0x0080

/*  Query flag, to be ORed with the control ID */
#define V4L2_CTRL_FLAG_NEXT_CTRL	0x80000000

/*  User-class control IDs defined by V4L2 */
#define V4L2_CID_MAX_CTRLS		1024
/*  IDs reserved for driver specific controls */
#define V4L2_CID_PRIVATE_BASE		0x08000000


/*
 *	T U N I N G
 */
struct v4l2_tuner {
	__u32                   index;
	__u8			name[32];
	__u32			type;	/* enum v4l2_tuner_type */
	__u32			capability;
	__u32			rangelow;
	__u32			rangehigh;
	__u32			rxsubchans;
	__u32			audmode;
	__s32			signal;
	__s32			afc;
	__u32			reserved[4];
};

struct v4l2_modulator {
	__u32			index;
	__u8			name[32];
	__u32			capability;
	__u32			rangelow;
	__u32			rangehigh;
	__u32			txsubchans;
	__u32			reserved[4];
};

/*  Flags for the 'capability' field */
#define V4L2_TUNER_CAP_LOW		0x0001
#define V4L2_TUNER_CAP_NORM		0x0002
#define V4L2_TUNER_CAP_HWSEEK_BOUNDED	0x0004
#define V4L2_TUNER_CAP_HWSEEK_WRAP	0x0008
#define V4L2_TUNER_CAP_STEREO		0x0010
#define V4L2_TUNER_CAP_LANG2		0x0020
#define V4L2_TUNER_CAP_SAP		0x0020
#define V4L2_TUNER_CAP_LANG1		0x0040
#define V4L2_TUNER_CAP_RDS		0x0080
#define V4L2_TUNER_CAP_RDS_BLOCK_IO	0x0100
#define V4L2_TUNER_CAP_RDS_CONTROLS	0x0200
#define V4L2_TUNER_CAP_FREQ_BANDS	0x0400
#define V4L2_TUNER_CAP_HWSEEK_PROG_LIM	0x0800

/*  Flags for the 'rxsubchans' field */
#define V4L2_TUNER_SUB_MONO		0x0001
#define V4L2_TUNER_SUB_STEREO		0x0002
#define V4L2_TUNER_SUB_LANG2		0x0004
#define V4L2_TUNER_SUB_SAP		0x0004
#define V4L2_TUNER_SUB_LANG1		0x0008
#define V4L2_TUNER_SUB_RDS		0x0010

/*  Values for the 'audmode' field */
#define V4L2_TUNER_MODE_MONO		0x0000
#define V4L2_TUNER_MODE_STEREO		0x0001
#define V4L2_TUNER_MODE_LANG2		0x0002
#define V4L2_TUNER_MODE_SAP		0x0002
#define V4L2_TUNER_MODE_LANG1		0x0003
#define V4L2_TUNER_MODE_LANG1_LANG2	0x0004

struct v4l2_frequency {
	__u32	tuner;
	__u32	type;	/* enum v4l2_tuner_type */
	__u32	frequency;
	__u32	reserved[8];
};

#define V4L2_BAND_MODULATION_VSB	(1 << 1)
#define V4L2_BAND_MODULATION_FM		(1 << 2)
#define V4L2_BAND_MODULATION_AM		(1 << 3)

struct v4l2_frequency_band {
	__u32	tuner;
	__u32	type;	/* enum v4l2_tuner_type */
	__u32	index;
	__u32	capability;
	__u32	rangelow;
	__u32	rangehigh;
	__u32	modulation;
	__u32	reserved[9];
};

struct v4l2_hw_freq_seek {
	__u32	tuner;
	__u32	type;	/* enum v4l2_tuner_type */
	__u32	seek_upward;
	__u32	wrap_around;
	__u32	spacing;
	__u32	rangelow;
	__u32	rangehigh;
	__u32	reserved[5];
};

/*
 *	R D S
 */

struct v4l2_rds_data {
	__u8 	lsb;
	__u8 	msb;
	__u8 	block;
} __attribute__ ((packed));

#define V4L2_RDS_BLOCK_MSK 	 0x7
#define V4L2_RDS_BLOCK_A 	 0
#define V4L2_RDS_BLOCK_B 	 1
#define V4L2_RDS_BLOCK_C 	 2
#define V4L2_RDS_BLOCK_D 	 3
#define V4L2_RDS_BLOCK_C_ALT 	 4
#define V4L2_RDS_BLOCK_INVALID 	 7

#define V4L2_RDS_BLOCK_CORRECTED 0x40
#define V4L2_RDS_BLOCK_ERROR 	 0x80

/*
 *	A U D I O
 */
struct v4l2_audio {
	__u32	index;
	__u8	name[32];
	__u32	capability;
	__u32	mode;
	__u32	reserved[2];
};

/*  Flags for the 'capability' field */
#define V4L2_AUDCAP_STEREO		0x00001
#define V4L2_AUDCAP_AVL			0x00002

/*  Flags for the 'mode' field */
#define V4L2_AUDMODE_AVL		0x00001

struct v4l2_audioout {
	__u32	index;
	__u8	name[32];
	__u32	capability;
	__u32	mode;
	__u32	reserved[2];
};

/*
 *	M P E G   S E R V I C E S
 *
 *	NOTE: EXPERIMENTAL API
 */
#if 1
#define V4L2_ENC_IDX_FRAME_I    (0)
#define V4L2_ENC_IDX_FRAME_P    (1)
#define V4L2_ENC_IDX_FRAME_B    (2)
#define V4L2_ENC_IDX_FRAME_MASK (0xf)

struct v4l2_enc_idx_entry {
	__u64 offset;
	__u64 pts;
	__u32 length;
	__u32 flags;
	__u32 reserved[2];
};

#define V4L2_ENC_IDX_ENTRIES (64)
struct v4l2_enc_idx {
	__u32 entries;
	__u32 entries_cap;
	__u32 reserved[4];
	struct v4l2_enc_idx_entry entry[V4L2_ENC_IDX_ENTRIES];
};


#define V4L2_ENC_CMD_START      (0)
#define V4L2_ENC_CMD_STOP       (1)
#define V4L2_ENC_CMD_PAUSE      (2)
#define V4L2_ENC_CMD_RESUME     (3)

/* Flags for V4L2_ENC_CMD_STOP */
#define V4L2_ENC_CMD_STOP_AT_GOP_END    (1 << 0)

struct v4l2_encoder_cmd {
	__u32 cmd;
	__u32 flags;
	union {
		struct {
			__u32 data[8];
		} raw;
	};
};

/* Decoder commands */
#define V4L2_DEC_CMD_START       (0)
#define V4L2_DEC_CMD_STOP        (1)
#define V4L2_DEC_CMD_PAUSE       (2)
#define V4L2_DEC_CMD_RESUME      (3)

/* Flags for V4L2_DEC_CMD_START */
#define V4L2_DEC_CMD_START_MUTE_AUDIO	(1 << 0)

/* Flags for V4L2_DEC_CMD_PAUSE */
#define V4L2_DEC_CMD_PAUSE_TO_BLACK	(1 << 0)

/* Flags for V4L2_DEC_CMD_STOP */
#define V4L2_DEC_CMD_STOP_TO_BLACK	(1 << 0)
#define V4L2_DEC_CMD_STOP_IMMEDIATELY	(1 << 1)

/* Play format requirements (returned by the driver): */

/* The decoder has no special format requirements */
#define V4L2_DEC_START_FMT_NONE		(0)
/* The decoder requires full GOPs */
#define V4L2_DEC_START_FMT_GOP		(1)

/* The structure must be zeroed before use by the application
   This ensures it can be extended safely in the future. */
struct v4l2_decoder_cmd {
	__u32 cmd;
	__u32 flags;
	union {
		struct {
			__u64 pts;
		} stop;

		struct {
			/* 0 or 1000 specifies normal speed,
			   1 specifies forward single stepping,
			   -1 specifies backward single stepping,
			   >1: playback at speed/1000 of the normal speed,
			   <-1: reverse playback at (-speed/1000) of the normal speed. */
			__s32 speed;
			__u32 format;
		} start;

		struct {
			__u32 data[16];
		} raw;
	};
};
#endif


/*
 *	D A T A   S E R V I C E S   ( V B I )
 *
 *	Data services API by Michael Schimek
 */

/* Raw VBI */
struct v4l2_vbi_format {
	__u32	sampling_rate;		/* in 1 Hz */
	__u32	offset;
	__u32	samples_per_line;
	__u32	sample_format;		/* V4L2_PIX_FMT_* */
	__s32	start[2];
	__u32	count[2];
	__u32	flags;			/* V4L2_VBI_* */
	__u32	reserved[2];		/* must be zero */
};

/*  VBI flags  */
#define V4L2_VBI_UNSYNC		(1 << 0)
#define V4L2_VBI_INTERLACED	(1 << 1)

ffi.cdef[[
/* Sliced VBI
 *
 *    This implements is a proposal V4L2 API to allow SLICED VBI
 * required for some hardware encoders. It should change without
 * notice in the definitive implementation.
 */

struct v4l2_sliced_vbi_format {
	__u16   service_set;
	/* service_lines[0][...] specifies lines 0-23 (1-23 used) of the first field
	   service_lines[1][...] specifies lines 0-23 (1-23 used) of the second field
				 (equals frame lines 313-336 for 625 line video
				  standards, 263-286 for 525 line standards) */
	__u16   service_lines[2][24];
	__u32   io_size;
	__u32   reserved[2];            /* must be zero */
};
]]

/* Teletext World System Teletext
   (WST), defined on ITU-R BT.653-2 */
#define V4L2_SLICED_TELETEXT_B          (0x0001)
/* Video Program System, defined on ETS 300 231*/
#define V4L2_SLICED_VPS                 (0x0400)
/* Closed Caption, defined on EIA-608 */
#define V4L2_SLICED_CAPTION_525         (0x1000)
/* Wide Screen System, defined on ITU-R BT1119.1 */
#define V4L2_SLICED_WSS_625             (0x4000)

#define V4L2_SLICED_VBI_525             (V4L2_SLICED_CAPTION_525)
#define V4L2_SLICED_VBI_625             (V4L2_SLICED_TELETEXT_B | V4L2_SLICED_VPS | V4L2_SLICED_WSS_625)

ffi.cdef[[
struct v4l2_sliced_vbi_cap {
	__u16   service_set;
	/* service_lines[0][...] specifies lines 0-23 (1-23 used) of the first field
	   service_lines[1][...] specifies lines 0-23 (1-23 used) of the second field
				 (equals frame lines 313-336 for 625 line video
				  standards, 263-286 for 525 line standards) */
	__u16   service_lines[2][24];
	__u32	type;		/* enum v4l2_buf_type */
	__u32   reserved[3];    /* must be 0 */
};

struct v4l2_sliced_vbi_data {
	__u32   id;
	__u32   field;          /* 0: first field, 1: second field */
	__u32   line;           /* 1-23 */
	__u32   reserved;       /* must be 0 */
	__u8    data[48];
};
]]

/*
 * Sliced VBI data inserted into MPEG Streams
 */

/*
 * V4L2_MPEG_STREAM_VBI_FMT_IVTV:
 *
 * Structure of payload contained in an MPEG 2 Private Stream 1 PES Packet in an
 * MPEG-2 Program Pack that contains V4L2_MPEG_STREAM_VBI_FMT_IVTV Sliced VBI
 * data
 *
 * Note, the MPEG-2 Program Pack and Private Stream 1 PES packet header
 * definitions are not included here.  See the MPEG-2 specifications for details
 * on these headers.
 */

/* Line type IDs */
#define V4L2_MPEG_VBI_IVTV_TELETEXT_B     (1)
#define V4L2_MPEG_VBI_IVTV_CAPTION_525    (4)
#define V4L2_MPEG_VBI_IVTV_WSS_625        (5)
#define V4L2_MPEG_VBI_IVTV_VPS            (7)

ffi.cdef[[
struct v4l2_mpeg_vbi_itv0_line {
	__u8 id;	/* One of V4L2_MPEG_VBI_IVTV_* above */
	__u8 data[42];	/* Sliced VBI data for the line */
} __attribute__ ((packed));

struct v4l2_mpeg_vbi_itv0 {
	__le32 linemask[2]; /* Bitmasks of VBI service lines present */
	struct v4l2_mpeg_vbi_itv0_line line[35];
} __attribute__ ((packed));

struct v4l2_mpeg_vbi_ITV0 {
	struct v4l2_mpeg_vbi_itv0_line line[36];
} __attribute__ ((packed));
]]

#define V4L2_MPEG_VBI_IVTV_MAGIC0	"itv0"
#define V4L2_MPEG_VBI_IVTV_MAGIC1	"ITV0"

ffi.cdef[[
struct v4l2_mpeg_vbi_fmt_ivtv {
	__u8 magic[4];
	union {
		struct v4l2_mpeg_vbi_itv0 itv0;
		struct v4l2_mpeg_vbi_ITV0 ITV0;
	};
} __attribute__ ((packed));
]]


ffi.cdef[[
/*
 *	A G G R E G A T E   S T R U C T U R E S
 */

/**
 * struct v4l2_plane_pix_format - additional, per-plane format definition
 * @sizeimage:		maximum size in bytes required for data, for which
 *			this plane will be used
 * @bytesperline:	distance in bytes between the leftmost pixels in two
 *			adjacent lines
 */
struct v4l2_plane_pix_format {
	__u32		sizeimage;
	__u16		bytesperline;
	__u16		reserved[7];
} __attribute__ ((packed));
]]

ffi.cdef[[
/**
 * struct v4l2_pix_format_mplane - multiplanar format definition
 * @width:		image width in pixels
 * @height:		image height in pixels
 * @pixelformat:	little endian four character code (fourcc)
 * @field:		enum v4l2_field; field order (for interlaced video)
 * @colorspace:		enum v4l2_colorspace; supplemental to pixelformat
 * @plane_fmt:		per-plane information
 * @num_planes:		number of planes for this format
 */
struct v4l2_pix_format_mplane {
	__u32				width;
	__u32				height;
	__u32				pixelformat;
	__u32				field;
	__u32				colorspace;

	struct v4l2_plane_pix_format	plane_fmt[VIDEO_MAX_PLANES];
	__u8				num_planes;
	__u8				reserved[11];
} __attribute__ ((packed));
]]


ffi.cdef[[

struct v4l2_format {
	__u32	 type;
	union {
		struct v4l2_pix_format		pix;     /* V4L2_BUF_TYPE_VIDEO_CAPTURE */
		struct v4l2_pix_format_mplane	pix_mp;  /* V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE */
		struct v4l2_window		win;     /* V4L2_BUF_TYPE_VIDEO_OVERLAY */
		struct v4l2_vbi_format		vbi;     /* V4L2_BUF_TYPE_VBI_CAPTURE */
		struct v4l2_sliced_vbi_format	sliced;  /* V4L2_BUF_TYPE_SLICED_VBI_CAPTURE */
		__u8	raw_data[200];                   /* user-defined */
	} fmt;
};
]]

ffi.cdef[[

struct v4l2_streamparm {
	__u32	 type;			/* enum v4l2_buf_type */
	union {
		struct v4l2_captureparm	capture;
		struct v4l2_outputparm	output;
		__u8	raw_data[200];  /* user-defined */
	} parm;
};
]]

/*
 *	E V E N T S
 */

#define V4L2_EVENT_ALL				0
#define V4L2_EVENT_VSYNC			1
#define V4L2_EVENT_EOS				2
#define V4L2_EVENT_CTRL				3
#define V4L2_EVENT_FRAME_SYNC			4
#define V4L2_EVENT_PRIVATE_START		0x08000000

ffi.cdef[[
/* Payload for V4L2_EVENT_VSYNC */
struct v4l2_event_vsync {
	/* Can be V4L2_FIELD_ANY, _NONE, _TOP or _BOTTOM */
	__u8 field;
} __attribute__ ((packed));
]]

/* Payload for V4L2_EVENT_CTRL */
#define V4L2_EVENT_CTRL_CH_VALUE		(1 << 0)
#define V4L2_EVENT_CTRL_CH_FLAGS		(1 << 1)
#define V4L2_EVENT_CTRL_CH_RANGE		(1 << 2)

ffi.cdef[[
struct v4l2_event_ctrl {
	__u32 changes;
	__u32 type;
	union {
		__s32 value;
		__s64 value64;
	};
	__u32 flags;
	__s32 minimum;
	__s32 maximum;
	__s32 step;
	__s32 default_value;
};

struct v4l2_event_frame_sync {
	__u32 frame_sequence;
};

struct v4l2_event {
	__u32				type;
	union {
		struct v4l2_event_vsync		vsync;
		struct v4l2_event_ctrl		ctrl;
		struct v4l2_event_frame_sync	frame_sync;
		__u8				data[64];
	} u;
	__u32				pending;
	__u32				sequence;
	struct timespec			timestamp;
	__u32				id;
	__u32				reserved[8];
};
]]

#define V4L2_EVENT_SUB_FL_SEND_INITIAL		(1 << 0)
#define V4L2_EVENT_SUB_FL_ALLOW_FEEDBACK	(1 << 1)

ffi.cdef[[
struct v4l2_event_subscription {
	__u32				type;
	__u32				id;
	__u32				flags;
	__u32				reserved[5];
};
]]

/*
 *	A D V A N C E D   D E B U G G I N G
 *
 *	NOTE: EXPERIMENTAL API, NEVER RELY ON THIS IN APPLICATIONS!
 *	FOR DEBUGGING, TESTING AND INTERNAL USE ONLY!
 */

/* VIDIOC_DBG_G_REGISTER and VIDIOC_DBG_S_REGISTER */

#define V4L2_CHIP_MATCH_BRIDGE      0  /* Match against chip ID on the bridge (0 for the bridge) */
#define V4L2_CHIP_MATCH_SUBDEV      4  /* Match against subdev index */

/* The following four defines are no longer in use */
#define V4L2_CHIP_MATCH_HOST V4L2_CHIP_MATCH_BRIDGE
#define V4L2_CHIP_MATCH_I2C_DRIVER  1  /* Match against I2C driver name */
#define V4L2_CHIP_MATCH_I2C_ADDR    2  /* Match against I2C 7-bit address */
#define V4L2_CHIP_MATCH_AC97        3  /* Match against ancillary AC97 chip */

ffi.cdef[[
struct v4l2_dbg_match {
	__u32 type; /* Match type */
	union {     /* Match this chip, meaning determined by type */
		__u32 addr;
		char name[32];
	};
} __attribute__ ((packed));

struct v4l2_dbg_register {
	struct v4l2_dbg_match match;
	__u32 size;	/* register size in bytes */
	__u64 reg;
	__u64 val;
} __attribute__ ((packed));
]]

#define V4L2_CHIP_FL_READABLE (1 << 0)
#define V4L2_CHIP_FL_WRITABLE (1 << 1)

ffi.cdef[[
/* VIDIOC_DBG_G_CHIP_INFO */
struct v4l2_dbg_chip_info {
	struct v4l2_dbg_match match;
	char name[32];
	__u32 flags;
	__u32 reserved[32];
} __attribute__ ((packed));


struct v4l2_create_buffers {
	__u32			index;
	__u32			count;
	__u32			memory;
	struct v4l2_format	format;
	__u32			reserved[8];
};
]]

--[[
/*
 *	I O C T L   C O D E S   F O R   V I D E O   D E V I C E S
 *
--]]
local T = ffi.typeof;
local VIDIOC_IOCTL_BASE	= 'V';

local function VIDIOC_IO(nr)	return libc._IO(DRM_IOCTL_BASE,nr) end
local function VIDIOC_IOR(nr,type) return 	libc._IOR(DRM_IOCTL_BASE,nr,type) end
local function VIDIOC_IOW(nr,type)	return	libc._IOW(DRM_IOCTL_BASE,nr,type) end
local function VIDIOC_IOWR(nr,type) return libc._IOWR(DRM_IOCTL_BASE,nr,type) end

#define VIDIOC_QUERYCAP		 _IOR('V',  0, struct v4l2_capability)
#define VIDIOC_RESERVED		  _IO('V',  1)
#define VIDIOC_ENUM_FMT         _IOWR('V',  2, struct v4l2_fmtdesc)
#define VIDIOC_G_FMT		_IOWR('V',  4, struct v4l2_format)
#define VIDIOC_S_FMT		_IOWR('V',  5, struct v4l2_format)
#define VIDIOC_REQBUFS		_IOWR('V',  8, struct v4l2_requestbuffers)
#define VIDIOC_QUERYBUF		_IOWR('V',  9, struct v4l2_buffer)
#define VIDIOC_G_FBUF		 _IOR('V', 10, struct v4l2_framebuffer)
#define VIDIOC_S_FBUF		 _IOW('V', 11, struct v4l2_framebuffer)
#define VIDIOC_OVERLAY		 _IOW('V', 14, int)
#define VIDIOC_QBUF		_IOWR('V', 15, struct v4l2_buffer)
#define VIDIOC_EXPBUF		_IOWR('V', 16, struct v4l2_exportbuffer)
#define VIDIOC_DQBUF		_IOWR('V', 17, struct v4l2_buffer)
#define VIDIOC_STREAMON		 _IOW('V', 18, int)
#define VIDIOC_STREAMOFF	 _IOW('V', 19, int)
#define VIDIOC_G_PARM		_IOWR('V', 21, struct v4l2_streamparm)
#define VIDIOC_S_PARM		_IOWR('V', 22, struct v4l2_streamparm)
#define VIDIOC_G_STD		 _IOR('V', 23, v4l2_std_id)
#define VIDIOC_S_STD		 _IOW('V', 24, v4l2_std_id)
#define VIDIOC_ENUMSTD		_IOWR('V', 25, struct v4l2_standard)
#define VIDIOC_ENUMINPUT	_IOWR('V', 26, struct v4l2_input)
#define VIDIOC_G_CTRL		_IOWR('V', 27, struct v4l2_control)
#define VIDIOC_S_CTRL		_IOWR('V', 28, struct v4l2_control)
#define VIDIOC_G_TUNER		_IOWR('V', 29, struct v4l2_tuner)
#define VIDIOC_S_TUNER		 _IOW('V', 30, struct v4l2_tuner)
#define VIDIOC_G_AUDIO		 _IOR('V', 33, struct v4l2_audio)
#define VIDIOC_S_AUDIO		 _IOW('V', 34, struct v4l2_audio)
#define VIDIOC_QUERYCTRL	_IOWR('V', 36, struct v4l2_queryctrl)
#define VIDIOC_QUERYMENU	_IOWR('V', 37, struct v4l2_querymenu)
#define VIDIOC_G_INPUT		 _IOR('V', 38, int)
#define VIDIOC_S_INPUT		_IOWR('V', 39, int)
#define VIDIOC_G_OUTPUT		 _IOR('V', 46, int)
#define VIDIOC_S_OUTPUT		_IOWR('V', 47, int)
#define VIDIOC_ENUMOUTPUT	_IOWR('V', 48, struct v4l2_output)
#define VIDIOC_G_AUDOUT		 _IOR('V', 49, struct v4l2_audioout)
#define VIDIOC_S_AUDOUT		 _IOW('V', 50, struct v4l2_audioout)
#define VIDIOC_G_MODULATOR	_IOWR('V', 54, struct v4l2_modulator)
#define VIDIOC_S_MODULATOR	 _IOW('V', 55, struct v4l2_modulator)
#define VIDIOC_G_FREQUENCY	_IOWR('V', 56, struct v4l2_frequency)
#define VIDIOC_S_FREQUENCY	 _IOW('V', 57, struct v4l2_frequency)
#define VIDIOC_CROPCAP		_IOWR('V', 58, struct v4l2_cropcap)
#define VIDIOC_G_CROP		_IOWR('V', 59, struct v4l2_crop)
#define VIDIOC_S_CROP		 _IOW('V', 60, struct v4l2_crop)
#define VIDIOC_G_JPEGCOMP	 _IOR('V', 61, struct v4l2_jpegcompression)
#define VIDIOC_S_JPEGCOMP	 _IOW('V', 62, struct v4l2_jpegcompression)
#define VIDIOC_QUERYSTD      	 _IOR('V', 63, v4l2_std_id)
#define VIDIOC_TRY_FMT      	_IOWR('V', 64, struct v4l2_format)
#define VIDIOC_ENUMAUDIO	_IOWR('V', 65, struct v4l2_audio)
#define VIDIOC_ENUMAUDOUT	_IOWR('V', 66, struct v4l2_audioout)
#define VIDIOC_G_PRIORITY	 _IOR('V', 67, __u32) /* enum v4l2_priority */
#define VIDIOC_S_PRIORITY	 _IOW('V', 68, __u32) /* enum v4l2_priority */
#define VIDIOC_G_SLICED_VBI_CAP _IOWR('V', 69, struct v4l2_sliced_vbi_cap)
#define VIDIOC_LOG_STATUS         _IO('V', 70)
#define VIDIOC_G_EXT_CTRLS	_IOWR('V', 71, struct v4l2_ext_controls)
#define VIDIOC_S_EXT_CTRLS	_IOWR('V', 72, struct v4l2_ext_controls)
#define VIDIOC_TRY_EXT_CTRLS	_IOWR('V', 73, struct v4l2_ext_controls)
#define VIDIOC_ENUM_FRAMESIZES	_IOWR('V', 74, struct v4l2_frmsizeenum)
#define VIDIOC_ENUM_FRAMEINTERVALS _IOWR('V', 75, struct v4l2_frmivalenum)
#define VIDIOC_G_ENC_INDEX       _IOR('V', 76, struct v4l2_enc_idx)
#define VIDIOC_ENCODER_CMD      _IOWR('V', 77, struct v4l2_encoder_cmd)
#define VIDIOC_TRY_ENCODER_CMD  _IOWR('V', 78, struct v4l2_encoder_cmd)

/* Experimental, meant for debugging, testing and internal use.
   Only implemented if CONFIG_VIDEO_ADV_DEBUG is defined.
   You must be root to use these ioctls. Never use these in applications! */
#define	VIDIOC_DBG_S_REGISTER 	 _IOW('V', 79, struct v4l2_dbg_register)
#define	VIDIOC_DBG_G_REGISTER 	_IOWR('V', 80, struct v4l2_dbg_register)

#define VIDIOC_S_HW_FREQ_SEEK	 _IOW('V', 82, struct v4l2_hw_freq_seek)

#define	VIDIOC_S_DV_TIMINGS	_IOWR('V', 87, struct v4l2_dv_timings)
#define	VIDIOC_G_DV_TIMINGS	_IOWR('V', 88, struct v4l2_dv_timings)
#define	VIDIOC_DQEVENT		 _IOR('V', 89, struct v4l2_event)
#define	VIDIOC_SUBSCRIBE_EVENT	 _IOW('V', 90, struct v4l2_event_subscription)
#define	VIDIOC_UNSUBSCRIBE_EVENT _IOW('V', 91, struct v4l2_event_subscription)

/* Experimental, the below two ioctls may change over the next couple of kernel
   versions */
#define VIDIOC_CREATE_BUFS	_IOWR('V', 92, struct v4l2_create_buffers)
#define VIDIOC_PREPARE_BUF	_IOWR('V', 93, struct v4l2_buffer)

/* Experimental selection API */
#define VIDIOC_G_SELECTION	_IOWR('V', 94, struct v4l2_selection)
#define VIDIOC_S_SELECTION	_IOWR('V', 95, struct v4l2_selection)

/* Experimental, these two ioctls may change over the next couple of kernel
   versions. */
#define VIDIOC_DECODER_CMD	_IOWR('V', 96, struct v4l2_decoder_cmd)
#define VIDIOC_TRY_DECODER_CMD	_IOWR('V', 97, struct v4l2_decoder_cmd)

/* Experimental, these three ioctls may change over the next couple of kernel
   versions. */
#define VIDIOC_ENUM_DV_TIMINGS  _IOWR('V', 98, struct v4l2_enum_dv_timings)
#define VIDIOC_QUERY_DV_TIMINGS  _IOR('V', 99, struct v4l2_dv_timings)
#define VIDIOC_DV_TIMINGS_CAP   _IOWR('V', 100, struct v4l2_dv_timings_cap)

/* Experimental, this ioctl may change over the next couple of kernel
   versions. */
#define VIDIOC_ENUM_FREQ_BANDS	_IOWR('V', 101, struct v4l2_frequency_band)

/* Experimental, meant for debugging, testing and internal use.
   Never use these in applications! */
#define VIDIOC_DBG_G_CHIP_INFO  _IOWR('V', 102, struct v4l2_dbg_chip_info)

/* Reminder: when adding new ioctls please add support for them to
   drivers/media/video/v4l2-compat-ioctl32.c as well! */

#define BASE_VIDIOC_PRIVATE	192		/* 192-255 are private */

#endif /* __LINUX_VIDEODEV2_H */
