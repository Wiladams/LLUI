-- videodev2.lua
local ffi = require("ffi")
local bit = require("bit")
local band, bor, lshift, rshift = bit.band, bit.bor, bit.lshift, bit.rshift

local Lib_v4l2 = require("v4l2_ffi")
local videodev2_ffi = require("videodev2_ffi")
local v4l2_fourcc = require("v4l2_fourcc")
--local v4l2_controls = require("v4l2_controls")
local libc = require("libc")


local T = ffi.typeof;






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




	VIDEO_MAX_FRAME              = 32;
}


local C = Constants;




-- v4l2_fmtdesc.flags
Constants.V4L2_FMT_FLAG_COMPRESSED = 0x0001;
Constants.V4L2_FMT_FLAG_EMULATED   = 0x0002;

--  v4l2_timecode.Type
Constants.V4L2_TC_TYPE_24FPS		=1;
Constants.V4L2_TC_TYPE_25FPS		=2;
Constants.V4L2_TC_TYPE_30FPS		=3;
Constants.V4L2_TC_TYPE_50FPS		=4;
Constants.V4L2_TC_TYPE_60FPS		=5;

--  v4l2_timecode.Flags
Constants.V4L2_TC_FLAG_DROPFRAME		=0x0001; -- "drop-frame" mode
Constants.V4L2_TC_FLAG_COLORFRAME		=0x0002;
Constants.V4L2_TC_USERBITS_field		=0x000C;
Constants.V4L2_TC_USERBITS_USERDEFINED	=0x0000;
Constants.V4L2_TC_USERBITS_8BITCHARS	=0x0008;
-- The above is based on SMPTE timecodes

-- v4l2_jpegcompression
Constants.V4L2_JPEG_MARKER_DHT = lshift(1,3);    -- Define Huffman Tables 
Constants.V4L2_JPEG_MARKER_DQT = lshift(1,4);    -- Define Quantization Tables 
Constants.V4L2_JPEG_MARKER_DRI = lshift(1,5);    -- Define Restart Interval 
Constants.V4L2_JPEG_MARKER_COM = lshift(1,6);    -- Comment segment 
Constants.V4L2_JPEG_MARKER_APP = lshift(1,7);    -- App segment, driver will always use APP0 


--  Flags for 'v4l2_buffer.flags' field 
Constants.V4L2_BUF_FLAG_MAPPED	= 0x0001;  -- Buffer is mapped (flag) 
Constants.V4L2_BUF_FLAG_QUEUED	= 0x0002;	-- Buffer is queued for processing 
Constants.V4L2_BUF_FLAG_DONE	= 0x0004;	-- Buffer is ready 
Constants.V4L2_BUF_FLAG_KEYFRAME	= 0x0008;	-- Image is a keyframe (I-frame) 
Constants.V4L2_BUF_FLAG_PFRAME	= 0x0010;	-- Image is a P-frame 
Constants.V4L2_BUF_FLAG_BFRAME	= 0x0020;	-- Image is a B-frame 
-- Buffer is ready, but the data contained within is corrupted. 
Constants.V4L2_BUF_FLAG_ERROR	= 0x0040;
Constants.V4L2_BUF_FLAG_TIMECODE	= 0x0100;	-- timecode field is valid 
Constants.V4L2_BUF_FLAG_PREPARED	= 0x0400;	-- Buffer is prepared for queuing 
-- Cache handling flags 
Constants.V4L2_BUF_FLAG_NO_CACHE_INVALIDATE	= 0x0800;
Constants.V4L2_BUF_FLAG_NO_CACHE_CLEAN		= 0x1000;
-- Timestamp type 
Constants.V4L2_BUF_FLAG_TIMESTAMP_MASK		= 0xe000;
Constants.V4L2_BUF_FLAG_TIMESTAMP_UNKNOWN		= 0x0000;
Constants.V4L2_BUF_FLAG_TIMESTAMP_MONOTONIC	= 0x2000;
Constants.V4L2_BUF_FLAG_TIMESTAMP_COPY		= 0x4000;


--  Flags for the 'v4l2_framebuffer.capability' field (v4l2_framebuffer). Read only
Constants.V4L2_FBUF_CAP_EXTERNOVERLAY	= 0x0001;
Constants.V4L2_FBUF_CAP_CHROMAKEY		= 0x0002;
Constants.V4L2_FBUF_CAP_LIST_CLIPPING     = 0x0004;
Constants.V4L2_FBUF_CAP_BITMAP_CLIPPING	= 0x0008;
Constants.V4L2_FBUF_CAP_LOCAL_ALPHA	= 0x0010;
Constants.V4L2_FBUF_CAP_GLOBAL_ALPHA	= 0x0020;
Constants.V4L2_FBUF_CAP_LOCAL_INV_ALPHA	= 0x0040;
Constants.V4L2_FBUF_CAP_SRC_CHROMAKEY	= 0x0080;
--  Flags for the 'v4l2_framebuffer.flags' field. 
Constants.V4L2_FBUF_FLAG_PRIMARY		= 0x0001;
Constants.V4L2_FBUF_FLAG_OVERLAY		= 0x0002;
Constants.V4L2_FBUF_FLAG_CHROMAKEY	= 0x0004;
Constants.V4L2_FBUF_FLAG_LOCAL_ALPHA	= 0x0008;
Constants.V4L2_FBUF_FLAG_GLOBAL_ALPHA	= 0x0010;
Constants.V4L2_FBUF_FLAG_LOCAL_INV_ALPHA	= 0x0020;
Constants.V4L2_FBUF_FLAG_SRC_CHROMAKEY	= 0x0040;

--  Flags for 'v4l2_captureparm.capability' and 'capturemode' fields 
Constants.V4L2_MODE_HIGHQUALITY	= 0x0001;	--  High quality imaging mode 
Constants.V4L2_CAP_TIMEPERFRAME	= 0x1000;	--  timeperframe field is supported 



-- one bit for each
Constants.V4L2_STD_PAL_B           = 0x00000001;
Constants.V4L2_STD_PAL_B1          = 0x00000002;
Constants.V4L2_STD_PAL_G           = 0x00000004;
Constants.V4L2_STD_PAL_H           = 0x00000008;
Constants.V4L2_STD_PAL_I           = 0x00000010;
Constants.V4L2_STD_PAL_D           = 0x00000020;
Constants.V4L2_STD_PAL_D1          = 0x00000040;
Constants.V4L2_STD_PAL_K           = 0x00000080;

Constants.V4L2_STD_PAL_M           = 0x00000100;
Constants.V4L2_STD_PAL_N           = 0x00000200;
Constants.V4L2_STD_PAL_Nc          = 0x00000400;
Constants.V4L2_STD_PAL_60          = 0x00000800;

Constants.V4L2_STD_NTSC_M          = 0x00001000;
Constants.V4L2_STD_NTSC_M_JP       = 0x00002000;
Constants.V4L2_STD_NTSC_443        = 0x00004000;
Constants.V4L2_STD_NTSC_M_KR       = 0x00008000;

Constants.V4L2_STD_SECAM_B         = 0x00010000;
Constants.V4L2_STD_SECAM_D         = 0x00020000;
Constants.V4L2_STD_SECAM_G         = 0x00040000;
Constants.V4L2_STD_SECAM_H         = 0x00080000;
Constants.V4L2_STD_SECAM_K         = 0x00100000;
Constants.V4L2_STD_SECAM_K1        = 0x00200000;
Constants.V4L2_STD_SECAM_L         = 0x00400000;
Constants.V4L2_STD_SECAM_LC        = 0x00800000;

-- ATSC/HDTV 
Constants.V4L2_STD_ATSC_8_VSB      = 0x01000000;
Constants.V4L2_STD_ATSC_16_VSB     = 0x02000000;




-- NTSC Macros
C.V4L2_STD_NTSC =          bor(C.V4L2_STD_NTSC_M, C.V4L2_STD_NTSC_M_JP, C.V4L2_STD_NTSC_M_KR);

-- Secam macros
C.V4L2_STD_SECAM_DK =     bor(C.V4L2_STD_SECAM_D, C.V4L2_STD_SECAM_K, C.V4L2_STD_SECAM_K1);

-- All Secam Standards
C.V4L2_STD_SECAM	=	bor(C.V4L2_STD_SECAM_B,
				 C.V4L2_STD_SECAM_G,
				 C.V4L2_STD_SECAM_H,
				 C.V4L2_STD_SECAM_DK,
				 C.V4L2_STD_SECAM_L,
				 C.V4L2_STD_SECAM_LC);

-- PAL macros 
C.V4L2_STD_PAL_BG	=	bor(C.V4L2_STD_PAL_B,
				 C.V4L2_STD_PAL_B1,
				 C.V4L2_STD_PAL_G)
C.V4L2_STD_PAL_DK	=	bor(C.V4L2_STD_PAL_D,
				 C.V4L2_STD_PAL_D1,
				 C.V4L2_STD_PAL_K)

Constants.V4L2_STD_PAL		= bor(C.V4L2_STD_PAL_BG	,
				 C.V4L2_STD_PAL_DK	,
				 C.V4L2_STD_PAL_H		,
				 C.V4L2_STD_PAL_I)

-- Chroma "agnostic" standards
Constants.V4L2_STD_B		= bor(C.V4L2_STD_PAL_B		,
				 C.V4L2_STD_PAL_B1	,
				 C.V4L2_STD_SECAM_B);
Constants.V4L2_STD_G		= bor(C.V4L2_STD_PAL_G		,
				 C.V4L2_STD_SECAM_G);
Constants.V4L2_STD_H		= bor(C.V4L2_STD_PAL_H		,
				 C.V4L2_STD_SECAM_H);
Constants.V4L2_STD_L		= bor(C.V4L2_STD_SECAM_L	,
				 C.V4L2_STD_SECAM_LC);
Constants.V4L2_STD_GH		= bor(C.V4L2_STD_G		,
				 C.V4L2_STD_H);
Constants.V4L2_STD_DK		= bor(C.V4L2_STD_PAL_DK	,
				 C.V4L2_STD_SECAM_DK);
Constants.V4L2_STD_BG		= bor(C.V4L2_STD_B		,
				 C.V4L2_STD_G);
Constants.V4L2_STD_MN		= bor(C.V4L2_STD_PAL_M		,
				 C.V4L2_STD_PAL_N		,
				 C.V4L2_STD_PAL_Nc	,
				 C.V4L2_STD_NTSC);

-- Standards where MTS/BTSC stereo could be found 
Constants.V4L2_STD_MTS		= bor(C.V4L2_STD_NTSC_M	,
				 C.V4L2_STD_PAL_M		,
				 C.V4L2_STD_PAL_N		,
				 C.V4L2_STD_PAL_Nc)

-- Standards for Countries with 60Hz Line frequency 
Constants.V4L2_STD_525_60		= bor(C.V4L2_STD_PAL_M		,
				 C.V4L2_STD_PAL_60	,
				 C.V4L2_STD_NTSC		,
				 C.V4L2_STD_NTSC_443)
-- Standards for Countries with 50Hz Line frequency 
Constants.V4L2_STD_625_50		= bor(C.V4L2_STD_PAL		,
				 C.V4L2_STD_PAL_N		,
				 C.V4L2_STD_PAL_Nc	,
				 C.V4L2_STD_SECAM)

Constants.V4L2_STD_ATSC           = bor(C.V4L2_STD_ATSC_8_VSB, C.V4L2_STD_ATSC_16_VSB)
-- Macros with none and all analog standards 
Constants.V4L2_STD_UNKNOWN        = 0;
Constants.V4L2_STD_ALL            = bor(C.V4L2_STD_525_60	,C.V4L2_STD_625_50);

--[[
-- v4l2_bt_timings
-- Interlaced or progressive format 
#define	V4L2_DV_PROGRESSIVE	0
#define	V4L2_DV_INTERLACED	1

-- Polarities. If bit is not set, it is assumed to be negative polarity 
Constants.V4L2_DV_VSYNC_POS_POL	0x00000001
Constants.V4L2_DV_HSYNC_POS_POL	0x00000002

-- Timings standards 
Constants.V4L2_DV_BT_STD_CEA861	(1 << 0)  -- CEA-861 Digital TV Profile 
Constants.V4L2_DV_BT_STD_DMT	(1 << 1)  -- VESA Discrete Monitor Timings 
Constants.V4L2_DV_BT_STD_CVT	(1 << 2)  -- VESA Coordinated Video Timings 
Constants.V4L2_DV_BT_STD_GTF	(1 << 3)  -- VESA Generalized Timings Formula 

-- Flags 
Constants.V4L2_DV_FL_REDUCED_BLANKING		(1 << 0)

Constants.V4L2_DV_FL_CAN_REDUCE_FPS		(1 << 1)

Constants.V4L2_DV_FL_REDUCED_FPS			(1 << 2)

Constants.V4L2_DV_FL_HALF_LINE			(1 << 3)


-- Values for the 'v4l2_dv_timings.type' field
	V4L2_DV_BT_656_1120	 = 0;	-- BT.656/1120 timing type

-- v4l2_bt_timings_cap
Constants.V4L2_DV_BT_CAP_INTERLACED	(1 << 0)
Constants.V4L2_DV_BT_CAP_PROGRESSIVE	(1 << 1)
Constants.V4L2_DV_BT_CAP_REDUCED_BLANKING	(1 << 2)
Constants.V4L2_DV_BT_CAP_CUSTOM		(1 << 3)


--  Values for the 'v4l2_input.type' field 
Constants.V4L2_INPUT_TYPE_TUNER		1
Constants.V4L2_INPUT_TYPE_CAMERA		2

-- field 'v4l2_input.status' - general 
Constants.V4L2_IN_ST_NO_POWER    0x00000001  -- Attached device is off 
Constants.V4L2_IN_ST_NO_SIGNAL   0x00000002
Constants.V4L2_IN_ST_NO_COLOR    0x00000004

-- field 'status' - sensor orientation
-- If sensor is mounted upside down set both bits
Constants.V4L2_IN_ST_HFLIP       0x00000010 -- Frames are flipped horizontally 
Constants.V4L2_IN_ST_VFLIP       0x00000020 -- Frames are flipped vertically 

-- field 'status' - analog 
Constants.V4L2_IN_ST_NO_H_LOCK   0x00000100  -- No horizontal sync lock 
Constants.V4L2_IN_ST_COLOR_KILL  0x00000200  -- Color killer is active 

-- field 'status' - digital 
Constants.V4L2_IN_ST_NO_SYNC     0x00010000  -- No synchronization lock 
Constants.V4L2_IN_ST_NO_EQU      0x00020000  -- No equalizer lock 
Constants.V4L2_IN_ST_NO_CARRIER  0x00040000  -- Carrier recovery failed 

-- field 'status' - VCR and set-top box 
Constants.V4L2_IN_ST_MACROVISION 0x01000000  -- Macrovision detected 
Constants.V4L2_IN_ST_NO_ACCESS   0x02000000  -- Conditional access denied 
Constants.V4L2_IN_ST_VTR         0x04000000  -- VTR time constant 

-- capabilities flags 
Constants.V4L2_IN_CAP_DV_TIMINGS		0x00000002 -- Supports S_DV_TIMINGS 
Constants.V4L2_IN_CAP_CUSTOM_TIMINGS	V4L2_IN_CAP_DV_TIMINGS -- For compatibility 
Constants.V4L2_IN_CAP_STD			0x00000004 -- Supports S_STD 

--  Values for the 'v4l2_output.type' field 
Constants.V4L2_OUTPUT_TYPE_MODULATOR		1
Constants.V4L2_OUTPUT_TYPE_ANALOG			2
Constants.V4L2_OUTPUT_TYPE_ANALOGVGAOVERLAY	3

-- capabilities flags 
Constants.V4L2_OUT_CAP_DV_TIMINGS		0x00000002 -- Supports S_DV_TIMINGS 
Constants.V4L2_OUT_CAP_CUSTOM_TIMINGS	V4L2_OUT_CAP_DV_TIMINGS -- For compatibility 
Constants.V4L2_OUT_CAP_STD		0x00000004 -- Supports S_STD 


Constants.V4L2_CTRL_ID_MASK      	  (0x0fffffff)
Constants.V4L2_CTRL_ID2CLASS(id)    ((id) & 0x0fff0000UL)
Constants.V4L2_CTRL_DRIVER_PRIV(id) (((id) & 0xffff) >= 0x1000)




--  Control flags  
Constants.V4L2_CTRL_FLAG_DISABLED		0x0001
Constants.V4L2_CTRL_FLAG_GRABBED		0x0002
Constants.V4L2_CTRL_FLAG_READ_ONLY 	0x0004
Constants.V4L2_CTRL_FLAG_UPDATE 		0x0008
Constants.V4L2_CTRL_FLAG_INACTIVE 	0x0010
Constants.V4L2_CTRL_FLAG_SLIDER 		0x0020
Constants.V4L2_CTRL_FLAG_WRITE_ONLY 	0x0040
Constants.V4L2_CTRL_FLAG_VOLATILE		0x0080

--  Query flag, to be ORed with the control ID 
Constants.V4L2_CTRL_FLAG_NEXT_CTRL	0x80000000

--  User-class control IDs defined by V4L2 
Constants.V4L2_CID_MAX_CTRLS		1024
--  IDs reserved for driver specific controls 
Constants.V4L2_CID_PRIVATE_BASE		0x08000000
--]]

--  Flags for the 'v4l2_tuner/v4l_modulator.capability' field
Constants.V4L2_TUNER_CAP_LOW		= 0x0001;
Constants.V4L2_TUNER_CAP_NORM		= 0x0002;
Constants.V4L2_TUNER_CAP_HWSEEK_BOUNDED	= 0x0004;
Constants.V4L2_TUNER_CAP_HWSEEK_WRAP	= 0x0008;
Constants.V4L2_TUNER_CAP_STEREO		= 0x0010;
Constants.V4L2_TUNER_CAP_LANG2		= 0x0020;
Constants.V4L2_TUNER_CAP_SAP		= 0x0020;
Constants.V4L2_TUNER_CAP_LANG1		= 0x0040;
Constants.V4L2_TUNER_CAP_RDS		= 0x0080;
Constants.V4L2_TUNER_CAP_RDS_BLOCK_IO	= 0x0100;
Constants.V4L2_TUNER_CAP_RDS_CONTROLS	= 0x0200;
Constants.V4L2_TUNER_CAP_FREQ_BANDS	= 0x0400;
Constants.V4L2_TUNER_CAP_HWSEEK_PROG_LIM	= 0x0800;

--  Flags for the 'v4l2_tuner.rxsubchans' field
Constants.V4L2_TUNER_SUB_MONO		= 0x0001;
Constants.V4L2_TUNER_SUB_STEREO		= 0x0002;
Constants.V4L2_TUNER_SUB_LANG2		= 0x0004;
Constants.V4L2_TUNER_SUB_SAP		= 0x0004;
Constants.V4L2_TUNER_SUB_LANG1		= 0x0008;
Constants.V4L2_TUNER_SUB_RDS		= 0x0010;

--  Values for the 'v4l2_tuner.audmode' field
Constants.V4L2_TUNER_MODE_MONO		= 0x0000;
Constants.V4L2_TUNER_MODE_STEREO	= 0x0001;
Constants.V4L2_TUNER_MODE_LANG2		= 0x0002;
Constants.V4L2_TUNER_MODE_SAP		= 0x0002;
Constants.V4L2_TUNER_MODE_LANG1		= 0x0003;
Constants.V4L2_TUNER_MODE_LANG1_LANG2	= 0x0004;


-- v4l2_frequency
Constants.V4L2_BAND_MODULATION_VSB	= lshift(1, 1);
Constants.V4L2_BAND_MODULATION_FM	= lshift(1, 2);
Constants.V4L2_BAND_MODULATION_AM	= lshift(1, 3);


Constants.V4L2_RDS_BLOCK_MSK 	= 0x7;
Constants.V4L2_RDS_BLOCK_A 	 	= 0;
Constants.V4L2_RDS_BLOCK_B 	 	= 1;
Constants.V4L2_RDS_BLOCK_C 	 	= 2;
Constants.V4L2_RDS_BLOCK_D 	 	= 3;
Constants.V4L2_RDS_BLOCK_C_ALT 	= 4;
Constants.V4L2_RDS_BLOCK_INVALID= 7;

Constants.V4L2_RDS_BLOCK_CORRECTED	= 0x40;
Constants.V4L2_RDS_BLOCK_ERROR 	 	= 0x80;


-- v4l2_encoder_cmd
Constants.V4L2_ENC_CMD_START      = 0;
Constants.V4L2_ENC_CMD_STOP       = 1;
Constants.V4L2_ENC_CMD_PAUSE      = 2;
Constants.V4L2_ENC_CMD_RESUME     = 3;

-- Flags for V4L2_ENC_CMD_STOP 
Constants.V4L2_ENC_CMD_STOP_AT_GOP_END   = 1;	-- (1 << 0)


-- Decoder commands 
Constants.V4L2_DEC_CMD_START       = 0;
Constants.V4L2_DEC_CMD_STOP        = 1;
Constants.V4L2_DEC_CMD_PAUSE       = 2;
Constants.V4L2_DEC_CMD_RESUME      = 3;

-- Flags for V4L2_DEC_CMD_START 
Constants.V4L2_DEC_CMD_START_MUTE_AUDIO	= 1;

-- Flags for V4L2_DEC_CMD_PAUSE 
Constants.V4L2_DEC_CMD_PAUSE_TO_BLACK	= 1;

-- Flags for V4L2_DEC_CMD_STOP 
Constants.V4L2_DEC_CMD_STOP_TO_BLACK	= 1;
Constants.V4L2_DEC_CMD_STOP_IMMEDIATELY	= 2;

-- Play format requirements (returned by the driver): 

-- The decoder has no special format requirements 
Constants.V4L2_DEC_START_FMT_NONE		=(0);
-- The decoder requires full GOPs 
Constants.V4L2_DEC_START_FMT_GOP		=(1);


--  Flags for the 'v4l2_audio.capability' field 
Constants.V4L2_AUDCAP_STEREO		=0x00001;
Constants.V4L2_AUDCAP_AVL			=0x00002;

--  Flags for the 'v4l2_audio.mode' field 
Constants.V4L2_AUDMODE_AVL		=0x00001;


-- MPEG Experimental
Constants.V4L2_ENC_IDX_FRAME_I    = 0;
Constants.V4L2_ENC_IDX_FRAME_P    = 1;
Constants.V4L2_ENC_IDX_FRAME_B    = 2;
Constants.V4L2_ENC_IDX_FRAME_MASK = 0xf;


--  VBI flags  
Constants.V4L2_VBI_UNSYNC		= 1;
Constants.V4L2_VBI_INTERLACED	= 2;

Constants.V4L2_SLICED_TELETEXT_B         = 0x0001;
Constants.V4L2_SLICED_VPS                = 0x0400;
Constants.V4L2_SLICED_CAPTION_525        = 0x1000;
Constants.V4L2_SLICED_WSS_625            = 0x4000;

Constants.V4L2_SLICED_VBI_525            = C.V4L2_SLICED_CAPTION_525;
Constants.V4L2_SLICED_VBI_625            = bor(C.V4L2_SLICED_TELETEXT_B , C.V4L2_SLICED_VPS , C.V4L2_SLICED_WSS_625);



-- Line type IDs 
Constants.V4L2_MPEG_VBI_IVTV_TELETEXT_B    = 1;
Constants.V4L2_MPEG_VBI_IVTV_CAPTION_525   = 4;
Constants.V4L2_MPEG_VBI_IVTV_WSS_625       = 5;
Constants.V4L2_MPEG_VBI_IVTV_VPS           = 7;

Constants.V4L2_MPEG_VBI_IVTV_MAGIC0	= "itv0";
Constants.V4L2_MPEG_VBI_IVTV_MAGIC1	= "ITV0";


Constants.V4L2_EVENT_ALL				= 0;
Constants.V4L2_EVENT_VSYNC				= 1;
Constants.V4L2_EVENT_EOS				= 2;
Constants.V4L2_EVENT_CTRL				= 3;
Constants.V4L2_EVENT_FRAME_SYNC			= 4;
Constants.V4L2_EVENT_PRIVATE_START		= 0x08000000;

-- Payload for V4L2_EVENT_CTRL 
Constants.V4L2_EVENT_CTRL_CH_VALUE		= 1; -- (1 << 0)
Constants.V4L2_EVENT_CTRL_CH_FLAGS		= 2; -- (1 << 1)
Constants.V4L2_EVENT_CTRL_CH_RANGE		= 4; -- (1 << 2)


Constants.V4L2_EVENT_SUB_FL_SEND_INITIAL 	= 1;	-- (1 << 0)
Constants.V4L2_EVENT_SUB_FL_ALLOW_FEEDBACK	= 2;	-- (1 << 1)



--	A D V A N C E D   D E B U G G I N G

--	NOTE: EXPERIMENTAL API, NEVER RELY ON THIS IN APPLICATIONS!
--	FOR DEBUGGING, TESTING AND INTERNAL USE ONLY!


-- VIDIOC_DBG_G_REGISTER and VIDIOC_DBG_S_REGISTER 

Constants.V4L2_CHIP_MATCH_BRIDGE     = 0;  -- Match against chip ID on the bridge (0 for the bridge) 
Constants.V4L2_CHIP_MATCH_SUBDEV     = 4;  -- Match against subdev index 

-- The following four defines are no longer in use 
Constants.V4L2_CHIP_MATCH_HOST = C.V4L2_CHIP_MATCH_BRIDGE;
Constants.V4L2_CHIP_MATCH_I2C_DRIVER = 1;  -- Match against I2C driver name 
Constants.V4L2_CHIP_MATCH_I2C_ADDR   = 2;  -- Match against I2C 7-bit address 
Constants.V4L2_CHIP_MATCH_AC97       = 3;  -- Match against ancillary AC97 chip 

Constants.V4L2_CHIP_FL_READABLE = 1;
Constants.V4L2_CHIP_FL_WRITABLE = 2;




--	I O C T L   C O D E S   F O R   V I D E O   D E V I C E S

local VIDIOC_IOCTL_BASE	= 'V';

local function VIDIOC_IO(nr)	return libc._IO(VIDIOC_IOCTL_BASE,nr) end
local function VIDIOC_IOR(nr,ctype) return 	libc._IOR(VIDIOC_IOCTL_BASE,nr,ctype) end
local function VIDIOC_IOW(nr,ctype)	return	libc._IOW(VIDIOC_IOCTL_BASE,nr,ctype) end
local function VIDIOC_IOWR(nr,ctype) return libc._IOWR(VIDIOC_IOCTL_BASE,nr,ctype) end

Constants.VIDIOC_QUERYCAP	= VIDIOC_IOR(0, T'struct v4l2_capability');
Constants.VIDIOC_RESERVED	= VIDIOC_IO( 1);
Constants.VIDIOC_ENUM_FMT   = VIDIOC_IOWR( 2, T'struct v4l2_fmtdesc');
Constants.VIDIOC_G_FMT		= VIDIOC_IOWR( 4, T'struct v4l2_format');
Constants.VIDIOC_S_FMT		= VIDIOC_IOWR( 5, T'struct v4l2_format');
Constants.VIDIOC_REQBUFS	= VIDIOC_IOWR( 8, T'struct v4l2_requestbuffers');
Constants.VIDIOC_QUERYBUF	= VIDIOC_IOWR( 9, T'struct v4l2_buffer');
Constants.VIDIOC_G_FBUF		= VIDIOC_IOR(10, T'struct v4l2_framebuffer');
Constants.VIDIOC_S_FBUF		= VIDIOC_IOW(11, T'struct v4l2_framebuffer');
Constants.VIDIOC_OVERLAY	= VIDIOC_IOW(14, T'int');
Constants.VIDIOC_QBUF		= VIDIOC_IOWR(15, T'struct v4l2_buffer');
Constants.VIDIOC_EXPBUF		= VIDIOC_IOWR(16, T'struct v4l2_exportbuffer');
Constants.VIDIOC_DQBUF		= VIDIOC_IOWR(17, T'struct v4l2_buffer');
Constants.VIDIOC_STREAMON	= VIDIOC_IOW(18, T'int');
Constants.VIDIOC_STREAMOFF	= VIDIOC_IOW(19, T'int');
Constants.VIDIOC_G_PARM		= VIDIOC_IOWR(21, T'struct v4l2_streamparm');
Constants.VIDIOC_S_PARM		= VIDIOC_IOWR(22, T'struct v4l2_streamparm');
Constants.VIDIOC_G_STD		= VIDIOC_IOR(23, T'v4l2_std_id');
Constants.VIDIOC_S_STD		= VIDIOC_IOW(24, T'v4l2_std_id');
Constants.VIDIOC_ENUMSTD	= VIDIOC_IOWR(25, T'struct v4l2_standard');
Constants.VIDIOC_ENUMINPUT	= VIDIOC_IOWR(26, T'struct v4l2_input');
Constants.VIDIOC_G_CTRL		= VIDIOC_IOWR(27, T'struct v4l2_control');
Constants.VIDIOC_S_CTRL		= VIDIOC_IOWR(28, T'struct v4l2_control');
Constants.VIDIOC_G_TUNER	= VIDIOC_IOWR(29, T'struct v4l2_tuner');
Constants.VIDIOC_S_TUNER	= VIDIOC_IOW(30, T'struct v4l2_tuner');
Constants.VIDIOC_G_AUDIO	= VIDIOC_IOR(33, T'struct v4l2_audio');
Constants.VIDIOC_S_AUDIO	= VIDIOC_IOW(34, T'struct v4l2_audio');
Constants.VIDIOC_QUERYCTRL	= VIDIOC_IOWR(36, T'struct v4l2_queryctrl');
Constants.VIDIOC_QUERYMENU	= VIDIOC_IOWR(37, T'struct v4l2_querymenu');
Constants.VIDIOC_G_INPUT	= VIDIOC_IOR(38, T'int');
Constants.VIDIOC_S_INPUT	= VIDIOC_IOWR(39, T'int');
Constants.VIDIOC_G_OUTPUT	= VIDIOC_IOR(46, T'int');
Constants.VIDIOC_S_OUTPUT	= VIDIOC_IOWR(47, T'int');
Constants.VIDIOC_ENUMOUTPUT	= VIDIOC_IOWR(48, T'struct v4l2_output');
Constants.VIDIOC_G_AUDOUT	= VIDIOC_IOR(49, T'struct v4l2_audioout');
Constants.VIDIOC_S_AUDOUT	= VIDIOC_IOW(50, T'struct v4l2_audioout');
Constants.VIDIOC_G_MODULATOR= VIDIOC_IOWR(54, T'struct v4l2_modulator');
Constants.VIDIOC_S_MODULATOR= VIDIOC_IOW(55, T'struct v4l2_modulator');
Constants.VIDIOC_G_FREQUENCY= VIDIOC_IOWR(56, T'struct v4l2_frequency');
Constants.VIDIOC_S_FREQUENCY= VIDIOC_IOW(57, T'struct v4l2_frequency');
Constants.VIDIOC_CROPCAP	= VIDIOC_IOWR(58, T'struct v4l2_cropcap');
Constants.VIDIOC_G_CROP		= VIDIOC_IOWR(59, T'struct v4l2_crop');
Constants.VIDIOC_S_CROP		= VIDIOC_IOW(60, T'struct v4l2_crop');
Constants.VIDIOC_G_JPEGCOMP	= VIDIOC_IOR(61, T'struct v4l2_jpegcompression');
Constants.VIDIOC_S_JPEGCOMP	= VIDIOC_IOW(62, T'struct v4l2_jpegcompression');
Constants.VIDIOC_QUERYSTD   = VIDIOC_IOR(63, T'v4l2_std_id');
Constants.VIDIOC_TRY_FMT    = VIDIOC_IOWR(64, T'struct v4l2_format');
Constants.VIDIOC_ENUMAUDIO	= VIDIOC_IOWR(65, T'struct v4l2_audio');
Constants.VIDIOC_ENUMAUDOUT	= VIDIOC_IOWR(66, T'struct v4l2_audioout');
Constants.VIDIOC_G_PRIORITY	= VIDIOC_IOR(67, T'uint32_t'); 
Constants.VIDIOC_S_PRIORITY	= VIDIOC_IOW(68, T'uint32_t'); 
Constants.VIDIOC_G_SLICED_VBI_CAP 	= VIDIOC_IOWR(69, T'struct v4l2_sliced_vbi_cap');
Constants.VIDIOC_LOG_STATUS   		= VIDIOC_IO(70);
Constants.VIDIOC_G_EXT_CTRLS		= VIDIOC_IOWR(71, T'struct v4l2_ext_controls');
Constants.VIDIOC_S_EXT_CTRLS		= VIDIOC_IOWR(72, T'struct v4l2_ext_controls');
Constants.VIDIOC_TRY_EXT_CTRLS		= VIDIOC_IOWR(73, T'struct v4l2_ext_controls');
Constants.VIDIOC_ENUM_FRAMESIZES	= VIDIOC_IOWR(74, T'struct v4l2_frmsizeenum');
Constants.VIDIOC_ENUM_FRAMEINTERVALS= VIDIOC_IOWR(75, T'struct v4l2_frmivalenum');
Constants.VIDIOC_G_ENC_INDEX       	= VIDIOC_IOR(76, T'struct v4l2_enc_idx');
Constants.VIDIOC_ENCODER_CMD      	= VIDIOC_IOWR(77, T'struct v4l2_encoder_cmd');
Constants.VIDIOC_TRY_ENCODER_CMD  	= VIDIOC_IOWR(78, T'struct v4l2_encoder_cmd');

--[[
-- Experimental
/* Experimental, meant for debugging, testing and internal use.
   Only implemented if CONFIG_VIDEO_ADV_DEBUG is defined.
   You must be root to use these ioctls. Never use these in applications! */
#define	VIDIOC_DBG_S_REGISTER 	 = VIDIOC_IOW(79, struct v4l2_dbg_register)
#define	VIDIOC_DBG_G_REGISTER 	= VIDIOC_IOWR(80, struct v4l2_dbg_register)

#define VIDIOC_S_HW_FREQ_SEEK	 = VIDIOC_IOW(82, struct v4l2_hw_freq_seek)

#define	VIDIOC_S_DV_TIMINGS	= VIDIOC_IOWR(87, struct v4l2_dv_timings)
#define	VIDIOC_G_DV_TIMINGS	= VIDIOC_IOWR(88, struct v4l2_dv_timings)
#define	VIDIOC_DQEVENT		 = VIDIOC_IOR(89, struct v4l2_event)
#define	VIDIOC_SUBSCRIBE_EVENT	 = VIDIOC_IOW(90, struct v4l2_event_subscription)
#define	VIDIOC_UNSUBSCRIBE_EVENT = VIDIOC_IOW(91, struct v4l2_event_subscription)


/* Experimental, the below two ioctls may change over the next couple of kernel
   versions */
#define VIDIOC_CREATE_BUFS	= VIDIOC_IOWR(92, struct v4l2_create_buffers)
#define VIDIOC_PREPARE_BUF	= VIDIOC_IOWR(93, struct v4l2_buffer)

/* Experimental selection API */
#define VIDIOC_G_SELECTION	= VIDIOC_IOWR(94, struct v4l2_selection)
#define VIDIOC_S_SELECTION	= VIDIOC_IOWR(95, struct v4l2_selection)

/* Experimental, these two ioctls may change over the next couple of kernel
   versions. */
#define VIDIOC_DECODER_CMD	= VIDIOC_IOWR(96, struct v4l2_decoder_cmd)
#define VIDIOC_TRY_DECODER_CMD	= VIDIOC_IOWR(97, struct v4l2_decoder_cmd)

-- Experimental, these three ioctls may change over the next couple of kernel
--   versions.
#define VIDIOC_ENUM_DV_TIMINGS  = VIDIOC_IOWR(98, struct v4l2_enum_dv_timings)
#define VIDIOC_QUERY_DV_TIMINGS  = VIDIOC_IOR(99, struct v4l2_dv_timings)
#define VIDIOC_DV_TIMINGS_CAP   = VIDIOC_IOWR(100, struct v4l2_dv_timings_cap)

-- Experimental, this ioctl may change over the next couple of kernel
--   versions.
#define VIDIOC_ENUM_FREQ_BANDS	= VIDIOC_IOWR(101, struct v4l2_frequency_band)

-- Experimental, meant for debugging, testing and internal use.
--   Never use these in applications!
local VIDIOC_DBG_G_CHIP_INFO  = VIDIOC_IOWR(102, struct v4l2_dbg_chip_info);
--]]

Constants.BASE_VIDIOC_PRIVATE	= 192;		-- 192-255 are private





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

	v4l2_ctrl_type = {
		V4L2_CTRL_TYPE_INTEGER	    = 1,
		V4L2_CTRL_TYPE_BOOLEAN	    = 2,
		V4L2_CTRL_TYPE_MENU	     	= 3,
		V4L2_CTRL_TYPE_BUTTON	    = 4,
		V4L2_CTRL_TYPE_INTEGER64    = 5,
		V4L2_CTRL_TYPE_CTRL_CLASS   = 6,
		V4L2_CTRL_TYPE_STRING       = 7,
		V4L2_CTRL_TYPE_BITMASK      = 8,
		V4L2_CTRL_TYPE_INTEGER_MENU = 9,
	};

	v4l2_frmsizetypes = {
		V4L2_FRMSIZE_TYPE_DISCRETE		= 1,
		V4L2_FRMSIZE_TYPE_CONTINUOUS	= 2,
		V4L2_FRMSIZE_TYPE_STEPWISE		= 3,
	};

	v4l2_frmivaltypes = {
		V4L2_FRMIVAL_TYPE_DISCRETE	= 1,
		V4L2_FRMIVAL_TYPE_CONTINUOUS	= 2,
		V4L2_FRMIVAL_TYPE_STEPWISE	= 3,
	};

	-- Values for 'v4l2_capability.capabilities' field
	-- This was added as an enum instead of simple constants
	-- so that we can easily iterate them
	v4l2_capability_flags = {
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
	};
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

-- A few useful defines to calculate the total blanking and frame sizes
local function V4L2_DV_BT_BLANKING_WIDTH(bt)
	return (bt.hfrontporch + bt.hsync + bt.hbackporch)
end

local function V4L2_DV_BT_FRAME_WIDTH(bt) 
	return (bt.width + V4L2_DV_BT_BLANKING_WIDTH(bt))
end

local function V4L2_DV_BT_BLANKING_HEIGHT(bt)
	return (bt.vfrontporch + bt.vsync + bt.vbackporch + 
	 bt.il_vfrontporch + bt.il_vsync + bt.il_vbackporch)
end

local function V4L2_DV_BT_FRAME_HEIGHT(bt)
	return (bt.height + V4L2_DV_BT_BLANKING_HEIGHT(bt))
end


local Functions = {
	V4L2_FIELD_HAS_TOP = V4L2_FIELD_HAS_TOP;
	V4L2_FIELD_HAS_BOTTOM = V4L2_FIELD_HAS_BOTTOM;
	V4L2_FIELD_HAS_BOTH = V4L2_FIELD_HAS_BOTH;
	V4L2_TYPE_IS_MULTIPLANAR = V4L2_TYPE_IS_MULTIPLANAR;
	V4L2_TYPE_IS_OUTPUT = V4L2_TYPE_IS_OUTPUT;

	V4L2_DV_BT_BLANKING_WIDTH = V4L2_DV_BT_BLANKING_WIDTH;
	V4L2_DV_BT_FRAME_WIDTH = V4L2_DV_BT_FRAME_WIDTH;
	V4L2_DV_BT_BLANKING_HEIGHT = V4L2_DV_BT_BLANKING_HEIGHT;
	V4L2_DV_BT_FRAME_HEIGHT = V4L2_DV_BT_FRAME_HEIGHT;

}

local exports = {
	v4l2_fourcc = v4l2_fourcc;
	Constants = Constants;
	Enums = Enums;
	Functions = Functions;
}

setmetatable(exports, {
	__call = function(self, tbl)
		tbl = tbl or _G;
		
		for k,v in pairs(self.Constants) do
			tbl[k] = v;
		end
		
		tbl["v4l2_fourcc"] = self.v4l2_fourcc;
		for k,v in pairs(self.v4l2_fourcc) do
			tbl[k] = v;
		end

		for k,v in pairs(self.Enums) do
			tbl[k] = v;

			for key,value in pairs(v) do
				tbl[key] = value;
			end
		end

		for k,v in pairs(self.Functions) do
			tbl[k] = v;
		end

		return self;
	end,
})

return exports
