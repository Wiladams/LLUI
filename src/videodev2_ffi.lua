--[[
	This file is concerned primarily with the data
	structures that are used to make the various
	ioctl calls to the v4l2 drivers
	Contained here are the data structures and various
	constants of interest to make those calls.

--]]

local ffi = require("ffi")
local bit = require("bit")
local lshift, rshift, band, bor = bit.lshift, bit.rshift, bit.band, bit.bor

local libc = require("libc")

local Constants = {}
local C = Constants;
local T = ffi.typeof;

ffi.cdef[[typedef uint64_t v4l2_std_id]];



ffi.cdef[[
struct v4l2_rect {
	int32_t   left;
	int32_t   top;
	int32_t   width;
	int32_t   height;
};

struct v4l2_fract {
	uint32_t   numerator;
	uint32_t   denominator;
};

struct v4l2_capability {
	uint8_t	driver[16];
	uint8_t	card[32];
	uint8_t	bus_info[32];
	uint32_t   version;
	uint32_t	capabilities;
	uint32_t	device_caps;
	uint32_t	reserved[3];
};
]]



ffi.cdef[[
/*
 *	V I D E O   I M A G E   F O R M A T
 */
struct v4l2_pix_format {
	uint32_t         	width;
	uint32_t			height;
	uint32_t			pixelformat;
	uint32_t			field;		/* enum v4l2_field */
	uint32_t           bytesperline;	/* for padding, zero if unused */
	uint32_t          	sizeimage;
	uint32_t			colorspace;	/* enum v4l2_colorspace */
	uint32_t			priv;		/* private data, depends on pixelformat */
};
]]

ffi.cdef[[
/*
 *	F O R M A T   E N U M E R A T I O N
 */
struct v4l2_fmtdesc {
	uint32_t		    index;             /* Format number      */
	uint32_t		    type;              /* enum v4l2_buf_type */
	uint32_t           flags;
	uint8_t		    description[32];   /* Description string */
	uint32_t		    pixelformat;       /* Format fourcc      */
	uint32_t		    reserved[4];
};
]]



ffi.cdef[[
/*
 *	F R A M E   S I Z E   E N U M E R A T I O N
 */


struct v4l2_frmsize_discrete {
	uint32_t			width;		/* Frame width [pixel] */
	uint32_t			height;		/* Frame height [pixel] */
};

struct v4l2_frmsize_stepwise {
	uint32_t			min_width;	/* Minimum frame width [pixel] */
	uint32_t			max_width;	/* Maximum frame width [pixel] */
	uint32_t			step_width;	/* Frame width step size [pixel] */
	uint32_t			min_height;	/* Minimum frame height [pixel] */
	uint32_t			max_height;	/* Maximum frame height [pixel] */
	uint32_t			step_height;	/* Frame height step size [pixel] */
};

struct v4l2_frmsizeenum {
	uint32_t			index;		/* Frame size number */
	uint32_t			pixel_format;	/* Pixel format */
	uint32_t			type;		/* Frame size type the device supports. */

	union {					/* Frame size */
		struct v4l2_frmsize_discrete	discrete;
		struct v4l2_frmsize_stepwise	stepwise;
	};

	uint32_t   reserved[2];			/* Reserved space for future use */
};
]]

ffi.cdef[[
/*
 *	F R A M E   R A T E   E N U M E R A T I O N
 */


struct v4l2_frmival_stepwise {
	struct v4l2_fract	min;		/* Minimum frame interval [s] */
	struct v4l2_fract	max;		/* Maximum frame interval [s] */
	struct v4l2_fract	step;		/* Frame interval step size [s] */
};

struct v4l2_frmivalenum {
	uint32_t			index;		/* Frame format index */
	uint32_t			pixel_format;	/* Pixel format */
	uint32_t			width;		/* Frame width */
	uint32_t			height;		/* Frame height */
	uint32_t			type;		/* Frame interval type the device supports. */

	union {					/* Frame interval */
		struct v4l2_fract		discrete;
		struct v4l2_frmival_stepwise	stepwise;
	};

	uint32_t	reserved[2];			/* Reserved space for future use */
};

]]

ffi.cdef[[
/*
 *	T I M E C O D E
 */
struct v4l2_timecode {
	uint32_t	type;
	uint32_t	flags;
	uint8_t	frames;
	uint8_t	seconds;
	uint8_t	minutes;
	uint8_t	hours;
	uint8_t	userbits[4];
};
]]


ffi.cdef[[
struct v4l2_jpegcompression {
	int quality;

	int  APPn;              /* Number of APP segment to be written,
				 * must be 0..15 */
	int  APP_len;           /* Length of data in JPEG APPn segment */
	char APP_data[60];      /* Data in the JPEG APPn segment. */

	int  COM_len;           /* Length of data in JPEG COM segment */
	char COM_data[60];      /* Data in JPEG COM segment */

	uint32_t jpeg_markers;     /* Which markers should go into the JPEG
				 * output. Unless you exactly know what
				 * you do, leave them untouched.
				 * Including less markers will make the
				 * resulting code smaller, but there will
				 * be fewer applications which can read it.
				 * The presence of the APP and COM marker
				 * is influenced by APP_len and COM_len
				 * ONLY, not by this property! */

};
]]




ffi.cdef[[
/*
 *	M E M O R Y - M A P P I N G   B U F F E R S
 */
struct v4l2_requestbuffers {
	uint32_t			count;
	uint32_t			type;		/* enum v4l2_buf_type */
	uint32_t			memory;		/* enum v4l2_memory */
	uint32_t			reserved[2];
};
]]

ffi.cdef[[

struct v4l2_plane {
	uint32_t			bytesused;
	uint32_t			length;
	union {
		uint32_t		mem_offset;
		unsigned long	userptr;
		int32_t		fd;
	} m;
	uint32_t			data_offset;
	uint32_t			reserved[11];
};
]]

ffi.cdef[[

struct v4l2_buffer {
	uint32_t			index;
	uint32_t			type;
	uint32_t			bytesused;
	uint32_t			flags;
	uint32_t			field;
	struct timeval		timestamp;
	struct v4l2_timecode	timecode;
	uint32_t			sequence;

	/* memory location */
	uint32_t			memory;
	union {
		uint32_t           offset;
		unsigned long   userptr;
		struct v4l2_plane *planes;
		int32_t		fd;
	} m;
	uint32_t			length;
	uint32_t			reserved2;
	uint32_t			reserved;
};
]]




ffi.cdef[[

struct v4l2_exportbuffer {
	uint32_t		type; /* enum v4l2_buf_type */
	uint32_t		index;
	uint32_t		plane;
	uint32_t		flags;
	int32_t		fd;
	uint32_t		reserved[11];
};
]]

ffi.cdef[[
struct v4l2_framebuffer {
	uint32_t			capability;
	uint32_t			flags;
	void                    *base;
	struct v4l2_pix_format	fmt;
};
]]



ffi.cdef[[
struct v4l2_clip {
	struct v4l2_rect        c;
	struct v4l2_clip	*next;
};

struct v4l2_window {
	struct v4l2_rect        w;
	uint32_t			field;	 /* enum v4l2_field */
	uint32_t			chromakey;
	struct v4l2_clip	*clips;
	uint32_t			clipcount;
	void			*bitmap;
	uint8_t                    global_alpha;
};
]]


ffi.cdef[[
/*
 *	C A P T U R E   P A R A M E T E R S
 */
struct v4l2_captureparm {
	uint32_t		   capability;	  /*  Supported modes */
	uint32_t		   capturemode;	  /*  Current mode */
	struct v4l2_fract  timeperframe;  /*  Time per frame in seconds */
	uint32_t		   extendedmode;  /*  Driver-specific extensions */
	uint32_t              readbuffers;   /*  # of buffers for read */
	uint32_t		   reserved[4];
};
]]



ffi.cdef[[
struct v4l2_outputparm {
	uint32_t		   capability;	 /*  Supported modes */
	uint32_t		   outputmode;	 /*  Current mode */
	struct v4l2_fract  timeperframe; /*  Time per frame in seconds */
	uint32_t		   extendedmode; /*  Driver-specific extensions */
	uint32_t              writebuffers; /*  # of buffers for write */
	uint32_t		   reserved[4];
};
]]

ffi.cdef[[
/*
 *	I N P U T   I M A G E   C R O P P I N G
 */
struct v4l2_cropcap {
	uint32_t			type;	/* enum v4l2_buf_type */
	struct v4l2_rect        bounds;
	struct v4l2_rect        defrect;
	struct v4l2_fract       pixelaspect;
};

struct v4l2_crop {
	uint32_t			type;	/* enum v4l2_buf_type */
	struct v4l2_rect        c;
};

struct v4l2_selection {
	uint32_t			type;
	uint32_t			target;
	uint32_t                   flags;
	struct v4l2_rect        r;
	uint32_t                   reserved[9];
};
]]


--[[
/*
 *      A N A L O G   V I D E O   S T A N D A R D
 */
--]]



ffi.cdef[[
struct v4l2_standard {
	uint32_t		     index;
	v4l2_std_id          id;
	uint8_t		     name[24];
	struct v4l2_fract    frameperiod; /* Frames, not fields */
	uint32_t		     framelines;
	uint32_t		     reserved[4];
};
]]

ffi.cdef[[
/*
 *	D V 	B T	T I M I N G S
 */

struct v4l2_bt_timings {
	uint32_t	width;
	uint32_t	height;
	uint32_t	interlaced;
	uint32_t	polarities;
	uint64_t	pixelclock;
	uint32_t	hfrontporch;
	uint32_t	hsync;
	uint32_t	hbackporch;
	uint32_t	vfrontporch;
	uint32_t	vsync;
	uint32_t	vbackporch;
	uint32_t	il_vfrontporch;
	uint32_t	il_vsync;
	uint32_t	il_vbackporch;
	uint32_t	standards;
	uint32_t	flags;
	uint32_t	reserved[14];
} __attribute__ ((packed));
]]





ffi.cdef[[
/** struct v4l2_dv_timings - DV timings
 * @type:	the type of the timings
 * @bt:	BT656/1120 timings
 */
struct v4l2_dv_timings {
	uint32_t type;
	union {
		struct v4l2_bt_timings	bt;
		uint32_t	reserved[32];
	};
} __attribute__ ((packed));
]]


ffi.cdef[[
struct v4l2_enum_dv_timings {
	uint32_t index;
	uint32_t reserved[3];
	struct v4l2_dv_timings timings;
};
]]

ffi.cdef[[
struct v4l2_bt_timings_cap {
	uint32_t	min_width;
	uint32_t	max_width;
	uint32_t	min_height;
	uint32_t	max_height;
	uint64_t	min_pixelclock;
	uint64_t	max_pixelclock;
	uint32_t	standards;
	uint32_t	capabilities;
	uint32_t	reserved[16];
} __attribute__ ((packed));
]]


ffi.cdef[[
struct v4l2_dv_timings_cap {
	uint32_t type;
	uint32_t reserved[3];
	union {
		struct v4l2_bt_timings_cap bt;
		uint32_t raw_data[32];
	};
};
]]

--[[
 *	V I D E O   I N P U T S
--]]
ffi.cdef[[
struct v4l2_input {
	uint32_t	     index;		/*  Which input */
	uint8_t	     name[32];		/*  Label */
	uint32_t	     type;		/*  Type of input */
	uint32_t	     audioset;		/*  Associated audios (bitfield) */
	uint32_t        tuner;             /*  enum v4l2_tuner_type */
	v4l2_std_id  std;
	uint32_t	     status;
	uint32_t	     capabilities;
	uint32_t	     reserved[3];
};
]]


--[[
	V I D E O   O U T P U T S
--]]
ffi.cdef[[
struct v4l2_output {
	uint32_t	     index;		/*  Which output */
	uint8_t	     name[32];		/*  Label */
	uint32_t	     type;		/*  Type of output */
	uint32_t	     audioset;		/*  Associated audios (bitfield) */
	uint32_t	     modulator;         /*  Associated modulator */
	v4l2_std_id  std;
	uint32_t	     capabilities;
	uint32_t	     reserved[3];
};
]]


--[[
 *	C O N T R O L S
 */
--]]
ffi.cdef[[
struct v4l2_control {
	uint32_t		     id;
	int32_t		     value;
};

struct v4l2_ext_control {
	uint32_t id;
	uint32_t size;
	uint32_t reserved2[1];
	union {
		int32_t value;
		int64_t value64;
		char *string;
	};
} __attribute__ ((packed));

struct v4l2_ext_controls {
	uint32_t ctrl_class;
	uint32_t count;
	uint32_t error_idx;
	uint32_t reserved[2];
	struct v4l2_ext_control *controls;
};
]]

ffi.cdef[[
/*  Used in the VIDIOC_QUERYCTRL ioctl for querying controls */
struct v4l2_queryctrl {
	uint32_t		     id;
	uint32_t		     type;	/* enum v4l2_ctrl_type */
	uint8_t		     name[32];	/* Whatever */
	int32_t		     minimum;	/* Note signedness */
	int32_t		     maximum;
	int32_t		     step;
	int32_t		     default_value;
	uint32_t                flags;
	uint32_t		     reserved[2];
};
]]

ffi.cdef[[
/*  Used in the VIDIOC_QUERYMENU ioctl for querying menu items */
struct v4l2_querymenu {
	uint32_t		id;
	uint32_t		index;
	union {
		uint8_t	name[32];	/* Whatever */
		int64_t	value;
	};
	uint32_t		reserved;
} __attribute__ ((packed));
]]



ffi.cdef[[
/*
 *	T U N I N G
 */
struct v4l2_tuner {
	uint32_t                   index;
	uint8_t			name[32];
	uint32_t			type;	/* enum v4l2_tuner_type */
	uint32_t			capability;
	uint32_t			rangelow;
	uint32_t			rangehigh;
	uint32_t			rxsubchans;
	uint32_t			audmode;
	int32_t			signal;
	int32_t			afc;
	uint32_t			reserved[4];
};
]]

ffi.cdef[[
struct v4l2_modulator {
	uint32_t			index;
	uint8_t			name[32];
	uint32_t			capability;
	uint32_t			rangelow;
	uint32_t			rangehigh;
	uint32_t			txsubchans;
	uint32_t			reserved[4];
};
]]




ffi.cdef[[
struct v4l2_frequency {
	uint32_t	tuner;
	uint32_t	type;	/* enum v4l2_tuner_type */
	uint32_t	frequency;
	uint32_t	reserved[8];
};
]]


ffi.cdef[[
struct v4l2_frequency_band {
	uint32_t	tuner;
	uint32_t	type;	/* enum v4l2_tuner_type */
	uint32_t	index;
	uint32_t	capability;
	uint32_t	rangelow;
	uint32_t	rangehigh;
	uint32_t	modulation;
	uint32_t	reserved[9];
};

struct v4l2_hw_freq_seek {
	uint32_t	tuner;
	uint32_t	type;	/* enum v4l2_tuner_type */
	uint32_t	seek_upward;
	uint32_t	wrap_around;
	uint32_t	spacing;
	uint32_t	rangelow;
	uint32_t	rangehigh;
	uint32_t	reserved[5];
};
]]

ffi.cdef[[
/*
 *	R D S
 */

struct v4l2_rds_data {
	uint8_t 	lsb;
	uint8_t 	msb;
	uint8_t 	block;
} __attribute__ ((packed));
]]


ffi.cdef[[
/*
 *	A U D I O
 */
struct v4l2_audio {
	uint32_t	index;
	uint8_t	name[32];
	uint32_t	capability;
	uint32_t	mode;
	uint32_t	reserved[2];
};
]]


ffi.cdef[[
struct v4l2_audioout {
	uint32_t	index;
	uint8_t	name[32];
	uint32_t	capability;
	uint32_t	mode;
	uint32_t	reserved[2];
};
]]


--[[
 *	M P E G   S E R V I C E S
 *
 *	NOTE: EXPERIMENTAL API
--]]

ffi.cdef[[
struct v4l2_enc_idx_entry {
	uint64_t offset;
	uint64_t pts;
	uint32_t length;
	uint32_t flags;
	uint32_t reserved[2];
};
]]


ffi.cdef[[
static const int V4L2_ENC_IDX_ENTRIES = (64);

struct v4l2_enc_idx {
	uint32_t entries;
	uint32_t entries_cap;
	uint32_t reserved[4];
	struct v4l2_enc_idx_entry entry[V4L2_ENC_IDX_ENTRIES];
};
]]


ffi.cdef[[
struct v4l2_encoder_cmd {
	uint32_t cmd;
	uint32_t flags;
	union {
		struct {
			uint32_t data[8];
		} raw;
	};
};
]]


ffi.cdef[[
/* The structure must be zeroed before use by the application
   This ensures it can be extended safely in the future. */
struct v4l2_decoder_cmd {
	uint32_t cmd;
	uint32_t flags;
	union {
		struct {
			uint64_t pts;
		} stop;

		struct {
			/* 0 or 1000 specifies normal speed,
			   1 specifies forward single stepping,
			   -1 specifies backward single stepping,
			   >1: playback at speed/1000 of the normal speed,
			   <-1: reverse playback at (-speed/1000) of the normal speed. */
			int32_t speed;
			uint32_t format;
		} start;

		struct {
			uint32_t data[16];
		} raw;
	};
};
]]

ffi.cdef[[
/*
 *	D A T A   S E R V I C E S   ( V B I )
 *
 *	Data services API by Michael Schimek
 */

/* Raw VBI */
struct v4l2_vbi_format {
	uint32_t	sampling_rate;		/* in 1 Hz */
	uint32_t	offset;
	uint32_t	samples_per_line;
	uint32_t	sample_format;		/* V4L2_PIX_FMT_* */
	int32_t	start[2];
	uint32_t	count[2];
	uint32_t	flags;			/* V4L2_VBI_* */
	uint32_t	reserved[2];		/* must be zero */
};
]]


ffi.cdef[[
/* Sliced VBI
 *
 *    This implements is a proposal V4L2 API to allow SLICED VBI
 * required for some hardware encoders. It should change without
 * notice in the definitive implementation.
 */

struct v4l2_sliced_vbi_format {
	uint16_t   service_set;
	/* service_lines[0][...] specifies lines 0-23 (1-23 used) of the first field
	   service_lines[1][...] specifies lines 0-23 (1-23 used) of the second field
				 (equals frame lines 313-336 for 625 line video
				  standards, 263-286 for 525 line standards) */
	uint16_t   service_lines[2][24];
	uint32_t   io_size;
	uint32_t   reserved[2];            /* must be zero */
};
]]


ffi.cdef[[
struct v4l2_sliced_vbi_cap {
	uint16_t   service_set;
	/* service_lines[0][...] specifies lines 0-23 (1-23 used) of the first field
	   service_lines[1][...] specifies lines 0-23 (1-23 used) of the second field
				 (equals frame lines 313-336 for 625 line video
				  standards, 263-286 for 525 line standards) */
	uint16_t   service_lines[2][24];
	uint32_t	type;		/* enum v4l2_buf_type */
	uint32_t   reserved[3];    /* must be 0 */
};

struct v4l2_sliced_vbi_data {
	uint32_t   id;
	uint32_t   field;          /* 0: first field, 1: second field */
	uint32_t   line;           /* 1-23 */
	uint32_t   reserved;       /* must be 0 */
	uint8_t    data[48];
};
]]



ffi.cdef[[
struct v4l2_mpeg_vbi_itv0_line {
	uint8_t id;	/* One of V4L2_MPEG_VBI_IVTV_* above */
	uint8_t data[42];	/* Sliced VBI data for the line */
} __attribute__ ((packed));

struct v4l2_mpeg_vbi_itv0 {
	uint32_t linemask[2]; /* __le32 - Bitmasks of VBI service lines present */
	struct v4l2_mpeg_vbi_itv0_line line[35];
} __attribute__ ((packed));

struct v4l2_mpeg_vbi_ITV0 {
	struct v4l2_mpeg_vbi_itv0_line line[36];
} __attribute__ ((packed));
]]



ffi.cdef[[
struct v4l2_mpeg_vbi_fmt_ivtv {
	uint8_t magic[4];
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

struct v4l2_plane_pix_format {
	uint32_t		sizeimage;
	uint16_t		bytesperline;
	uint16_t		reserved[7];
} __attribute__ ((packed));
]]

ffi.cdef[[
static const int	VIDEO_MAX_PLANES = 8;

struct v4l2_pix_format_mplane {
	uint32_t				width;
	uint32_t				height;
	uint32_t				pixelformat;
	uint32_t				field;
	uint32_t				colorspace;

	struct v4l2_plane_pix_format	plane_fmt[VIDEO_MAX_PLANES];
	uint8_t				num_planes;
	uint8_t				reserved[11];
} __attribute__ ((packed));
]]


ffi.cdef[[

struct v4l2_format {
	uint32_t	 type;
	union {
		struct v4l2_pix_format		pix;     /* V4L2_BUF_TYPE_VIDEO_CAPTURE */
		struct v4l2_pix_format_mplane	pix_mp;  /* V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE */
		struct v4l2_window		win;     /* V4L2_BUF_TYPE_VIDEO_OVERLAY */
		struct v4l2_vbi_format		vbi;     /* V4L2_BUF_TYPE_VBI_CAPTURE */
		struct v4l2_sliced_vbi_format	sliced;  /* V4L2_BUF_TYPE_SLICED_VBI_CAPTURE */
		uint8_t	raw_data[200];                   /* user-defined */
	} fmt;
};
]]

ffi.cdef[[

struct v4l2_streamparm {
	uint32_t	 type;			/* enum v4l2_buf_type */
	union {
		struct v4l2_captureparm	capture;
		struct v4l2_outputparm	output;
		uint8_t	raw_data[200];  /* user-defined */
	} parm;
};
]]


--	E V E N T S



ffi.cdef[[
/* Payload for V4L2_EVENT_VSYNC */
struct v4l2_event_vsync {
	/* Can be V4L2_FIELD_ANY, _NONE, _TOP or _BOTTOM */
	uint8_t field;
} __attribute__ ((packed));
]]


ffi.cdef[[
struct v4l2_event_ctrl {
	uint32_t changes;
	uint32_t type;
	union {
		int32_t value;
		int64_t value64;
	};
	uint32_t flags;
	int32_t minimum;
	int32_t maximum;
	int32_t step;
	int32_t default_value;
};

struct v4l2_event_frame_sync {
	uint32_t frame_sequence;
};

struct v4l2_event {
	uint32_t				type;
	union {
		struct v4l2_event_vsync		vsync;
		struct v4l2_event_ctrl		ctrl;
		struct v4l2_event_frame_sync	frame_sync;
		uint8_t				data[64];
	} u;
	uint32_t				pending;
	uint32_t				sequence;
	struct timespec			timestamp;
	uint32_t				id;
	uint32_t				reserved[8];
};
]]


ffi.cdef[[
struct v4l2_event_subscription {
	uint32_t				type;
	uint32_t				id;
	uint32_t				flags;
	uint32_t				reserved[5];
};
]]


ffi.cdef[[
struct v4l2_dbg_match {
	uint32_t type; /* Match type */
	union {     /* Match this chip, meaning determined by type */
		uint32_t addr;
		char name[32];
	};
} __attribute__ ((packed));

struct v4l2_dbg_register {
	struct v4l2_dbg_match match;
	uint32_t size;	/* register size in bytes */
	uint64_t reg;
	uint64_t val;
} __attribute__ ((packed));
]]




ffi.cdef[[
/* VIDIOC_DBG_G_CHIP_INFO */
struct v4l2_dbg_chip_info {
	struct v4l2_dbg_match match;
	char name[32];
	uint32_t flags;
	uint32_t reserved[32];
} __attribute__ ((packed));


struct v4l2_create_buffers {
	uint32_t			index;
	uint32_t			count;
	uint32_t			memory;
	struct v4l2_format	format;
	uint32_t			reserved[8];
};
]]

