
local bit = require("bit")
local lshift, rshift, band, bor = bit.lshift, bit.rshift, bit.band, bit.bor

local C = {}

-- Control classes 
C.V4L2_CTRL_CLASS_USER		= 0x00980000	-- Old-style 'user' controls 
C.V4L2_CTRL_CLASS_MPEG		= 0x00990000	-- MPEG-compression controls 
C.V4L2_CTRL_CLASS_CAMERA		= 0x009a0000	-- Camera class controls 
C.V4L2_CTRL_CLASS_FM_TX		= 0x009b0000	-- FM Modulator controls 
C.V4L2_CTRL_CLASS_FLASH		= 0x009c0000	-- Camera flash controls 
C.V4L2_CTRL_CLASS_JPEG		= 0x009d0000	-- JPEG-compression controls 
C.V4L2_CTRL_CLASS_IMAGE_SOURCE	= 0x009e0000	-- Image source controls 
C.V4L2_CTRL_CLASS_IMAGE_PROC	= 0x009f0000	-- Image processing controls 
C.V4L2_CTRL_CLASS_DV		= 0x00a00000	-- Digital Video controls 
C.V4L2_CTRL_CLASS_FM_RX		= 0x00a10000	-- FM Receiver controls 



-- User-class control IDs 
C.V4L2_CID_BASE			= bor(C.V4L2_CTRL_CLASS_USER, 0x900)
C.V4L2_CID_USER_BASE 		= C.V4L2_CID_BASE
C.V4L2_CID_USER_CLASS 		= bor(C.V4L2_CTRL_CLASS_USER, 1)
C.V4L2_CID_BRIGHTNESS		= (C.V4L2_CID_BASE+0)
C.V4L2_CID_CONTRAST		= (C.V4L2_CID_BASE+1)
C.V4L2_CID_SATURATION		= (C.V4L2_CID_BASE+2)
C.V4L2_CID_HUE			= (C.V4L2_CID_BASE+3)
C.V4L2_CID_AUDIO_VOLUME		= (C.V4L2_CID_BASE+5)
C.V4L2_CID_AUDIO_BALANCE		= (C.V4L2_CID_BASE+6)
C.V4L2_CID_AUDIO_BASS		= (C.V4L2_CID_BASE+7)
C.V4L2_CID_AUDIO_TREBLE		= (C.V4L2_CID_BASE+8)
C.V4L2_CID_AUDIO_MUTE		= (C.V4L2_CID_BASE+9)
C.V4L2_CID_AUDIO_LOUDNESS		= (C.V4L2_CID_BASE+10)
C.V4L2_CID_BLACK_LEVEL		= (C.V4L2_CID_BASE+11) -- Deprecated 
C.V4L2_CID_AUTO_WHITE_BALANCE	= (C.V4L2_CID_BASE+12)
C.V4L2_CID_DO_WHITE_BALANCE	= (C.V4L2_CID_BASE+13)
C.V4L2_CID_RED_BALANCE		= (C.V4L2_CID_BASE+14)
C.V4L2_CID_BLUE_BALANCE		= (C.V4L2_CID_BASE+15)
C.V4L2_CID_GAMMA			= (C.V4L2_CID_BASE+16)
C.V4L2_CID_WHITENESS		= (C.V4L2_CID_GAMMA) -- Deprecated 
C.V4L2_CID_EXPOSURE		= (C.V4L2_CID_BASE+17)
C.V4L2_CID_AUTOGAIN		= (C.V4L2_CID_BASE+18)
C.V4L2_CID_GAIN			= (C.V4L2_CID_BASE+19)
C.V4L2_CID_HFLIP			= (C.V4L2_CID_BASE+20)
C.V4L2_CID_VFLIP			= (C.V4L2_CID_BASE+21)

C.V4L2_CID_POWER_LINE_FREQUENCY	= (C.V4L2_CID_BASE+24)

C.V4L2_CID_HUE_AUTO			= (C.V4L2_CID_BASE+25)
C.V4L2_CID_WHITE_BALANCE_TEMPERATURE	= (C.V4L2_CID_BASE+26)
C.V4L2_CID_SHARPNESS			= (C.V4L2_CID_BASE+27)
C.V4L2_CID_BACKLIGHT_COMPENSATION 	= (C.V4L2_CID_BASE+28)
C.V4L2_CID_CHROMA_AGC                     = (C.V4L2_CID_BASE+29)
C.V4L2_CID_COLOR_KILLER                   = (C.V4L2_CID_BASE+30)
C.V4L2_CID_COLORFX			= (C.V4L2_CID_BASE+31)

C.V4L2_CID_AUTOBRIGHTNESS			= (C.V4L2_CID_BASE+32)
C.V4L2_CID_BAND_STOP_FILTER		= (C.V4L2_CID_BASE+33)

C.V4L2_CID_ROTATE				= (C.V4L2_CID_BASE+34)
C.V4L2_CID_BG_COLOR			= (C.V4L2_CID_BASE+35)

C.V4L2_CID_CHROMA_GAIN                    = (C.V4L2_CID_BASE+36)

C.V4L2_CID_ILLUMINATORS_1			= (C.V4L2_CID_BASE+37)
C.V4L2_CID_ILLUMINATORS_2			= (C.V4L2_CID_BASE+38)

C.V4L2_CID_MIN_BUFFERS_FOR_CAPTURE	= (C.V4L2_CID_BASE+39)
C.V4L2_CID_MIN_BUFFERS_FOR_OUTPUT		= (C.V4L2_CID_BASE+40)

C.V4L2_CID_ALPHA_COMPONENT		= (C.V4L2_CID_BASE+41)
C.V4L2_CID_COLORFX_CBCR			= (C.V4L2_CID_BASE+42)

-- last CID + 1 
C.V4L2_CID_LASTP1                         = (C.V4L2_CID_BASE+43)

-- USER-class private control IDs 


C.V4L2_CID_USER_MEYE_BASE			= (C.V4L2_CID_USER_BASE + 0x1000)
C.V4L2_CID_USER_BTTV_BASE			= (C.V4L2_CID_USER_BASE + 0x1010)
C.V4L2_CID_USER_S2255_BASE		= (C.V4L2_CID_USER_BASE + 0x1030)
C.V4L2_CID_USER_SI476X_BASE		= (C.V4L2_CID_USER_BASE + 0x1040)
C.V4L2_CID_USER_TI_VPE_BASE		= (C.V4L2_CID_USER_BASE + 0x1050)





C.V4L2_CID_MPEG_BASE 			= bor(C.V4L2_CTRL_CLASS_MPEG, 0x900)
C.V4L2_CID_MPEG_CLASS 			= bor(C.V4L2_CTRL_CLASS_MPEG, 1)

--  MPEG streams, specific to multiplexed streams 
C.V4L2_CID_MPEG_STREAM_TYPE 		= (C.V4L2_CID_MPEG_BASE+0)
C.V4L2_CID_MPEG_STREAM_PID_PMT 		= (C.V4L2_CID_MPEG_BASE+1)
C.V4L2_CID_MPEG_STREAM_PID_AUDIO 		= (C.V4L2_CID_MPEG_BASE+2)
C.V4L2_CID_MPEG_STREAM_PID_VIDEO 		= (C.V4L2_CID_MPEG_BASE+3)
C.V4L2_CID_MPEG_STREAM_PID_PCR 		= (C.V4L2_CID_MPEG_BASE+4)
C.V4L2_CID_MPEG_STREAM_PES_ID_AUDIO 	= (C.V4L2_CID_MPEG_BASE+5)
C.V4L2_CID_MPEG_STREAM_PES_ID_VIDEO 	= (C.V4L2_CID_MPEG_BASE+6)
C.V4L2_CID_MPEG_STREAM_VBI_FMT 		= (C.V4L2_CID_MPEG_BASE+7)


--  MPEG audio controls specific to multiplexed streams  
C.V4L2_CID_MPEG_AUDIO_SAMPLING_FREQ 	= (C.V4L2_CID_MPEG_BASE+100)
C.V4L2_CID_MPEG_AUDIO_ENCODING 		= (C.V4L2_CID_MPEG_BASE+101)
C.V4L2_CID_MPEG_AUDIO_L1_BITRATE 		= (C.V4L2_CID_MPEG_BASE+102)
C.V4L2_CID_MPEG_AUDIO_L2_BITRATE 		= (C.V4L2_CID_MPEG_BASE+103)
C.V4L2_CID_MPEG_AUDIO_L3_BITRATE 		= (C.V4L2_CID_MPEG_BASE+104)
C.V4L2_CID_MPEG_AUDIO_MODE 		= (C.V4L2_CID_MPEG_BASE+105)
C.V4L2_CID_MPEG_AUDIO_MODE_EXTENSION 	= (C.V4L2_CID_MPEG_BASE+106)
C.V4L2_CID_MPEG_AUDIO_EMPHASIS 		= (C.V4L2_CID_MPEG_BASE+107)
C.V4L2_CID_MPEG_AUDIO_CRC 		= (C.V4L2_CID_MPEG_BASE+108)
C.V4L2_CID_MPEG_AUDIO_MUTE 		= (C.V4L2_CID_MPEG_BASE+109)
C.V4L2_CID_MPEG_AUDIO_AAC_BITRATE		= (C.V4L2_CID_MPEG_BASE+110)
C.V4L2_CID_MPEG_AUDIO_AC3_BITRATE		= (C.V4L2_CID_MPEG_BASE+111)


C.V4L2_CID_MPEG_AUDIO_DEC_PLAYBACK	= (C.V4L2_CID_MPEG_BASE+112)
C.V4L2_CID_MPEG_AUDIO_DEC_MULTILINGUAL_PLAYBACK = (C.V4L2_CID_MPEG_BASE+113)




--  MPEG video controls specific to multiplexed streams 
C.V4L2_CID_MPEG_VIDEO_ENCODING 		= (C.V4L2_CID_MPEG_BASE+200)
C.V4L2_CID_MPEG_VIDEO_ASPECT 		= (C.V4L2_CID_MPEG_BASE+201)

C.V4L2_CID_MPEG_VIDEO_B_FRAMES 		= (C.V4L2_CID_MPEG_BASE+202)
C.V4L2_CID_MPEG_VIDEO_GOP_SIZE 		= (C.V4L2_CID_MPEG_BASE+203)
C.V4L2_CID_MPEG_VIDEO_GOP_CLOSURE 	= (C.V4L2_CID_MPEG_BASE+204)
C.V4L2_CID_MPEG_VIDEO_PULLDOWN 		= (C.V4L2_CID_MPEG_BASE+205)
C.V4L2_CID_MPEG_VIDEO_BITRATE_MODE 	= (C.V4L2_CID_MPEG_BASE+206)

C.V4L2_CID_MPEG_VIDEO_BITRATE 		= (C.V4L2_CID_MPEG_BASE+207)
C.V4L2_CID_MPEG_VIDEO_BITRATE_PEAK 	= (C.V4L2_CID_MPEG_BASE+208)
C.V4L2_CID_MPEG_VIDEO_TEMPORAL_DECIMATION = (C.V4L2_CID_MPEG_BASE+209)
C.V4L2_CID_MPEG_VIDEO_MUTE 		= (C.V4L2_CID_MPEG_BASE+210)
C.V4L2_CID_MPEG_VIDEO_MUTE_YUV 		= (C.V4L2_CID_MPEG_BASE+211)
C.V4L2_CID_MPEG_VIDEO_DECODER_SLICE_INTERFACE		= (C.V4L2_CID_MPEG_BASE+212)
C.V4L2_CID_MPEG_VIDEO_DECODER_MPEG4_DEBLOCK_FILTER	= (C.V4L2_CID_MPEG_BASE+213)
C.V4L2_CID_MPEG_VIDEO_CYCLIC_INTRA_REFRESH_MB		= (C.V4L2_CID_MPEG_BASE+214)
C.V4L2_CID_MPEG_VIDEO_FRAME_RC_ENABLE			= (C.V4L2_CID_MPEG_BASE+215)
C.V4L2_CID_MPEG_VIDEO_HEADER_MODE				= (C.V4L2_CID_MPEG_BASE+216)

C.V4L2_CID_MPEG_VIDEO_MAX_REF_PIC			= (C.V4L2_CID_MPEG_BASE+217)
C.V4L2_CID_MPEG_VIDEO_MB_RC_ENABLE		= (C.V4L2_CID_MPEG_BASE+218)
C.V4L2_CID_MPEG_VIDEO_MULTI_SLICE_MAX_BYTES	= (C.V4L2_CID_MPEG_BASE+219)
C.V4L2_CID_MPEG_VIDEO_MULTI_SLICE_MAX_MB		= (C.V4L2_CID_MPEG_BASE+220)
C.V4L2_CID_MPEG_VIDEO_MULTI_SLICE_MODE		= (C.V4L2_CID_MPEG_BASE+221)

C.V4L2_CID_MPEG_VIDEO_VBV_SIZE			= (C.V4L2_CID_MPEG_BASE+222)
C.V4L2_CID_MPEG_VIDEO_DEC_PTS			= (C.V4L2_CID_MPEG_BASE+223)
C.V4L2_CID_MPEG_VIDEO_DEC_FRAME			= (C.V4L2_CID_MPEG_BASE+224)
C.V4L2_CID_MPEG_VIDEO_VBV_DELAY			= (C.V4L2_CID_MPEG_BASE+225)
C.V4L2_CID_MPEG_VIDEO_REPEAT_SEQ_HEADER		= (C.V4L2_CID_MPEG_BASE+226)

C.V4L2_CID_MPEG_VIDEO_H263_I_FRAME_QP		= (C.V4L2_CID_MPEG_BASE+300)
C.V4L2_CID_MPEG_VIDEO_H263_P_FRAME_QP		= (C.V4L2_CID_MPEG_BASE+301)
C.V4L2_CID_MPEG_VIDEO_H263_B_FRAME_QP		= (C.V4L2_CID_MPEG_BASE+302)
C.V4L2_CID_MPEG_VIDEO_H263_MIN_QP			= (C.V4L2_CID_MPEG_BASE+303)
C.V4L2_CID_MPEG_VIDEO_H263_MAX_QP			= (C.V4L2_CID_MPEG_BASE+304)
C.V4L2_CID_MPEG_VIDEO_H264_I_FRAME_QP		= (C.V4L2_CID_MPEG_BASE+350)
C.V4L2_CID_MPEG_VIDEO_H264_P_FRAME_QP		= (C.V4L2_CID_MPEG_BASE+351)
C.V4L2_CID_MPEG_VIDEO_H264_B_FRAME_QP		= (C.V4L2_CID_MPEG_BASE+352)
C.V4L2_CID_MPEG_VIDEO_H264_MIN_QP			= (C.V4L2_CID_MPEG_BASE+353)
C.V4L2_CID_MPEG_VIDEO_H264_MAX_QP			= (C.V4L2_CID_MPEG_BASE+354)
C.V4L2_CID_MPEG_VIDEO_H264_8X8_TRANSFORM		= (C.V4L2_CID_MPEG_BASE+355)
C.V4L2_CID_MPEG_VIDEO_H264_CPB_SIZE		= (C.V4L2_CID_MPEG_BASE+356)
C.V4L2_CID_MPEG_VIDEO_H264_ENTROPY_MODE		= (C.V4L2_CID_MPEG_BASE+357)

C.V4L2_CID_MPEG_VIDEO_H264_I_PERIOD		= (C.V4L2_CID_MPEG_BASE+358)
C.V4L2_CID_MPEG_VIDEO_H264_LEVEL			= (C.V4L2_CID_MPEG_BASE+359)
C.V4L2_CID_MPEG_VIDEO_H264_LOOP_FILTER_ALPHA	= (C.V4L2_CID_MPEG_BASE+360)
C.V4L2_CID_MPEG_VIDEO_H264_LOOP_FILTER_BETA	= (C.V4L2_CID_MPEG_BASE+361)
C.V4L2_CID_MPEG_VIDEO_H264_LOOP_FILTER_MODE	= (C.V4L2_CID_MPEG_BASE+362)
C.V4L2_CID_MPEG_VIDEO_H264_PROFILE		= (C.V4L2_CID_MPEG_BASE+363)




C.V4L2_CID_MPEG_VIDEO_H264_VUI_EXT_SAR_HEIGHT	= (C.V4L2_CID_MPEG_BASE+364)
C.V4L2_CID_MPEG_VIDEO_H264_VUI_EXT_SAR_WIDTH	= (C.V4L2_CID_MPEG_BASE+365)
C.V4L2_CID_MPEG_VIDEO_H264_VUI_SAR_ENABLE		= (C.V4L2_CID_MPEG_BASE+366)
C.V4L2_CID_MPEG_VIDEO_H264_VUI_SAR_IDC		= (C.V4L2_CID_MPEG_BASE+367)
C.V4L2_CID_MPEG_VIDEO_H264_SEI_FRAME_PACKING		= (C.V4L2_CID_MPEG_BASE+368)
C.V4L2_CID_MPEG_VIDEO_H264_SEI_FP_CURRENT_FRAME_0		= (C.V4L2_CID_MPEG_BASE+369)
C.V4L2_CID_MPEG_VIDEO_H264_SEI_FP_ARRANGEMENT_TYPE	= (C.V4L2_CID_MPEG_BASE+370)
C.V4L2_CID_MPEG_VIDEO_H264_FMO			= (C.V4L2_CID_MPEG_BASE+371)
C.V4L2_CID_MPEG_VIDEO_H264_FMO_MAP_TYPE		= (C.V4L2_CID_MPEG_BASE+372)
C.V4L2_CID_MPEG_VIDEO_H264_FMO_SLICE_GROUP	= (C.V4L2_CID_MPEG_BASE+373)
C.V4L2_CID_MPEG_VIDEO_H264_FMO_CHANGE_DIRECTION	= (C.V4L2_CID_MPEG_BASE+374)


C.V4L2_CID_MPEG_VIDEO_H264_FMO_CHANGE_RATE	= (C.V4L2_CID_MPEG_BASE+375)
C.V4L2_CID_MPEG_VIDEO_H264_FMO_RUN_LENGTH		= (C.V4L2_CID_MPEG_BASE+376)
C.V4L2_CID_MPEG_VIDEO_H264_ASO			= (C.V4L2_CID_MPEG_BASE+377)
C.V4L2_CID_MPEG_VIDEO_H264_ASO_SLICE_ORDER	= (C.V4L2_CID_MPEG_BASE+378)
C.V4L2_CID_MPEG_VIDEO_H264_HIERARCHICAL_CODING		= (C.V4L2_CID_MPEG_BASE+379)
C.V4L2_CID_MPEG_VIDEO_H264_HIERARCHICAL_CODING_TYPE	= (C.V4L2_CID_MPEG_BASE+380)

C.V4L2_CID_MPEG_VIDEO_H264_HIERARCHICAL_CODING_LAYER	= (C.V4L2_CID_MPEG_BASE+381)
C.V4L2_CID_MPEG_VIDEO_H264_HIERARCHICAL_CODING_LAYER_QP	= (C.V4L2_CID_MPEG_BASE+382)
C.V4L2_CID_MPEG_VIDEO_MPEG4_I_FRAME_QP	= (C.V4L2_CID_MPEG_BASE+400)
C.V4L2_CID_MPEG_VIDEO_MPEG4_P_FRAME_QP	= (C.V4L2_CID_MPEG_BASE+401)
C.V4L2_CID_MPEG_VIDEO_MPEG4_B_FRAME_QP	= (C.V4L2_CID_MPEG_BASE+402)
C.V4L2_CID_MPEG_VIDEO_MPEG4_MIN_QP	= (C.V4L2_CID_MPEG_BASE+403)
C.V4L2_CID_MPEG_VIDEO_MPEG4_MAX_QP	= (C.V4L2_CID_MPEG_BASE+404)
C.V4L2_CID_MPEG_VIDEO_MPEG4_LEVEL		= (C.V4L2_CID_MPEG_BASE+405)
C.V4L2_CID_MPEG_VIDEO_MPEG4_PROFILE	= (C.V4L2_CID_MPEG_BASE+406)
C.V4L2_CID_MPEG_VIDEO_MPEG4_QPEL		= (C.V4L2_CID_MPEG_BASE+407)








C.V4L2_CID_MPEG_VIDEO_VPX_NUM_PARTITIONS		= (C.V4L2_CID_MPEG_BASE+500)
C.V4L2_CID_MPEG_VIDEO_VPX_IMD_DISABLE_4X4		= (C.V4L2_CID_MPEG_BASE+501)
C.V4L2_CID_MPEG_VIDEO_VPX_NUM_REF_FRAMES		= (C.V4L2_CID_MPEG_BASE+502)
C.V4L2_CID_MPEG_VIDEO_VPX_FILTER_LEVEL		= (C.V4L2_CID_MPEG_BASE+503)
C.V4L2_CID_MPEG_VIDEO_VPX_FILTER_SHARPNESS	= (C.V4L2_CID_MPEG_BASE+504)
C.V4L2_CID_MPEG_VIDEO_VPX_GOLDEN_FRAME_REF_PERIOD	= (C.V4L2_CID_MPEG_BASE+505)
C.V4L2_CID_MPEG_VIDEO_VPX_GOLDEN_FRAME_SEL	= (C.V4L2_CID_MPEG_BASE+506)
--  MPEG-class control IDs specific to the CX2341x driver as defined by V4L2 
C.V4L2_CID_MPEG_CX2341X_BASE 				= bor(C.V4L2_CTRL_CLASS_MPEG, 0x1000)
C.V4L2_CID_MPEG_CX2341X_VIDEO_SPATIAL_FILTER_MODE 	= (C.V4L2_CID_MPEG_CX2341X_BASE+0)
C.V4L2_CID_MPEG_CX2341X_VIDEO_SPATIAL_FILTER 		= (C.V4L2_CID_MPEG_CX2341X_BASE+1)
C.V4L2_CID_MPEG_CX2341X_VIDEO_LUMA_SPATIAL_FILTER_TYPE 	= (C.V4L2_CID_MPEG_CX2341X_BASE+2)
C.V4L2_CID_MPEG_CX2341X_VIDEO_CHROMA_SPATIAL_FILTER_TYPE 	= (C.V4L2_CID_MPEG_CX2341X_BASE+3)
C.V4L2_CID_MPEG_CX2341X_VIDEO_TEMPORAL_FILTER_MODE 	= (C.V4L2_CID_MPEG_CX2341X_BASE+4)
C.V4L2_CID_MPEG_CX2341X_VIDEO_TEMPORAL_FILTER 		= (C.V4L2_CID_MPEG_CX2341X_BASE+5)
C.V4L2_CID_MPEG_CX2341X_VIDEO_MEDIAN_FILTER_TYPE 		= (C.V4L2_CID_MPEG_CX2341X_BASE+6)



C.V4L2_CID_MPEG_CX2341X_VIDEO_LUMA_MEDIAN_FILTER_BOTTOM 	= (C.V4L2_CID_MPEG_CX2341X_BASE+7)
C.V4L2_CID_MPEG_CX2341X_VIDEO_LUMA_MEDIAN_FILTER_TOP 	= (C.V4L2_CID_MPEG_CX2341X_BASE+8)
C.V4L2_CID_MPEG_CX2341X_VIDEO_CHROMA_MEDIAN_FILTER_BOTTOM	= (C.V4L2_CID_MPEG_CX2341X_BASE+9)
C.V4L2_CID_MPEG_CX2341X_VIDEO_CHROMA_MEDIAN_FILTER_TOP 	= (C.V4L2_CID_MPEG_CX2341X_BASE+10)
C.V4L2_CID_MPEG_CX2341X_STREAM_INSERT_NAV_PACKETS 	= (C.V4L2_CID_MPEG_CX2341X_BASE+11)

--  MPEG-class control IDs specific to the Samsung MFC 5.1 driver as defined by V4L2 
C.V4L2_CID_MPEG_MFC51_BASE				= bor(C.V4L2_CTRL_CLASS_MPEG, 0x1100)

C.V4L2_CID_MPEG_MFC51_VIDEO_DECODER_H264_DISPLAY_DELAY		= (C.V4L2_CID_MPEG_MFC51_BASE+0)
C.V4L2_CID_MPEG_MFC51_VIDEO_DECODER_H264_DISPLAY_DELAY_ENABLE	= (C.V4L2_CID_MPEG_MFC51_BASE+1)
C.V4L2_CID_MPEG_MFC51_VIDEO_FRAME_SKIP_MODE			= (C.V4L2_CID_MPEG_MFC51_BASE+2)
C.V4L2_CID_MPEG_MFC51_VIDEO_FORCE_FRAME_TYPE			= (C.V4L2_CID_MPEG_MFC51_BASE+3)
C.V4L2_CID_MPEG_MFC51_VIDEO_PADDING				= (C.V4L2_CID_MPEG_MFC51_BASE+4)
C.V4L2_CID_MPEG_MFC51_VIDEO_PADDING_YUV				= (C.V4L2_CID_MPEG_MFC51_BASE+5)
C.V4L2_CID_MPEG_MFC51_VIDEO_RC_FIXED_TARGET_BIT			= (C.V4L2_CID_MPEG_MFC51_BASE+6)
C.V4L2_CID_MPEG_MFC51_VIDEO_RC_REACTION_COEFF			= (C.V4L2_CID_MPEG_MFC51_BASE+7)
C.V4L2_CID_MPEG_MFC51_VIDEO_H264_ADAPTIVE_RC_ACTIVITY		= (C.V4L2_CID_MPEG_MFC51_BASE+50)
C.V4L2_CID_MPEG_MFC51_VIDEO_H264_ADAPTIVE_RC_DARK			= (C.V4L2_CID_MPEG_MFC51_BASE+51)
C.V4L2_CID_MPEG_MFC51_VIDEO_H264_ADAPTIVE_RC_SMOOTH		= (C.V4L2_CID_MPEG_MFC51_BASE+52)
C.V4L2_CID_MPEG_MFC51_VIDEO_H264_ADAPTIVE_RC_STATIC		= (C.V4L2_CID_MPEG_MFC51_BASE+53)
C.V4L2_CID_MPEG_MFC51_VIDEO_H264_NUM_REF_PIC_FOR_P		= (C.V4L2_CID_MPEG_MFC51_BASE+54)






--  Camera class control IDs 
C.V4L2_CID_CAMERA_CLASS_BASE 	= bor(C.V4L2_CTRL_CLASS_CAMERA, 0x900)
C.V4L2_CID_CAMERA_CLASS 		= bor(C.V4L2_CTRL_CLASS_CAMERA, 1)

C.V4L2_CID_EXPOSURE_AUTO			= (C.V4L2_CID_CAMERA_CLASS_BASE+1)

C.V4L2_CID_EXPOSURE_ABSOLUTE		= (C.V4L2_CID_CAMERA_CLASS_BASE+2)
C.V4L2_CID_EXPOSURE_AUTO_PRIORITY		= (C.V4L2_CID_CAMERA_CLASS_BASE+3)

C.V4L2_CID_PAN_RELATIVE			= (C.V4L2_CID_CAMERA_CLASS_BASE+4)
C.V4L2_CID_TILT_RELATIVE			= (C.V4L2_CID_CAMERA_CLASS_BASE+5)
C.V4L2_CID_PAN_RESET			= (C.V4L2_CID_CAMERA_CLASS_BASE+6)
C.V4L2_CID_TILT_RESET			= (C.V4L2_CID_CAMERA_CLASS_BASE+7)

C.V4L2_CID_PAN_ABSOLUTE			= (C.V4L2_CID_CAMERA_CLASS_BASE+8)
C.V4L2_CID_TILT_ABSOLUTE			= (C.V4L2_CID_CAMERA_CLASS_BASE+9)

C.V4L2_CID_FOCUS_ABSOLUTE			= (C.V4L2_CID_CAMERA_CLASS_BASE+10)
C.V4L2_CID_FOCUS_RELATIVE			= (C.V4L2_CID_CAMERA_CLASS_BASE+11)
C.V4L2_CID_FOCUS_AUTO			= (C.V4L2_CID_CAMERA_CLASS_BASE+12)

C.V4L2_CID_ZOOM_ABSOLUTE			= (C.V4L2_CID_CAMERA_CLASS_BASE+13)
C.V4L2_CID_ZOOM_RELATIVE			= (C.V4L2_CID_CAMERA_CLASS_BASE+14)
C.V4L2_CID_ZOOM_CONTINUOUS		= (C.V4L2_CID_CAMERA_CLASS_BASE+15)

C.V4L2_CID_PRIVACY			= (C.V4L2_CID_CAMERA_CLASS_BASE+16)

C.V4L2_CID_IRIS_ABSOLUTE			= (C.V4L2_CID_CAMERA_CLASS_BASE+17)
C.V4L2_CID_IRIS_RELATIVE			= (C.V4L2_CID_CAMERA_CLASS_BASE+18)

C.V4L2_CID_AUTO_EXPOSURE_BIAS		= (C.V4L2_CID_CAMERA_CLASS_BASE+19)

C.V4L2_CID_AUTO_N_PRESET_WHITE_BALANCE	= (C.V4L2_CID_CAMERA_CLASS_BASE+20)

C.V4L2_CID_WIDE_DYNAMIC_RANGE		= (C.V4L2_CID_CAMERA_CLASS_BASE+21)
C.V4L2_CID_IMAGE_STABILIZATION		= (C.V4L2_CID_CAMERA_CLASS_BASE+22)

C.V4L2_CID_ISO_SENSITIVITY		= (C.V4L2_CID_CAMERA_CLASS_BASE+23)
C.V4L2_CID_ISO_SENSITIVITY_AUTO		= (C.V4L2_CID_CAMERA_CLASS_BASE+24)


C.V4L2_CID_EXPOSURE_METERING		= (C.V4L2_CID_CAMERA_CLASS_BASE+25)


C.V4L2_CID_SCENE_MODE			= (C.V4L2_CID_CAMERA_CLASS_BASE+26)


C.V4L2_CID_3A_LOCK			= (C.V4L2_CID_CAMERA_CLASS_BASE+27)
C.V4L2_LOCK_EXPOSURE			= 1;
C.V4L2_LOCK_WHITE_BALANCE		= 2;
C.V4L2_LOCK_FOCUS				= 4;

C.V4L2_CID_AUTO_FOCUS_START		= (C.V4L2_CID_CAMERA_CLASS_BASE+28)
C.V4L2_CID_AUTO_FOCUS_STOP		= (C.V4L2_CID_CAMERA_CLASS_BASE+29)
C.V4L2_CID_AUTO_FOCUS_STATUS		= (C.V4L2_CID_CAMERA_CLASS_BASE+30)
C.V4L2_AUTO_FOCUS_STATUS_IDLE		= 0;
C.V4L2_AUTO_FOCUS_STATUS_BUSY		= 1;
C.V4L2_AUTO_FOCUS_STATUS_REACHED	= 2;
C.V4L2_AUTO_FOCUS_STATUS_FAILED		= 4;

C.V4L2_CID_AUTO_FOCUS_RANGE		= (C.V4L2_CID_CAMERA_CLASS_BASE+31)





-- FM Modulator class control IDs 

C.V4L2_CID_FM_TX_CLASS_BASE		= bor(C.V4L2_CTRL_CLASS_FM_TX, 0x900)
C.V4L2_CID_FM_TX_CLASS			= bor(C.V4L2_CTRL_CLASS_FM_TX, 1)

C.V4L2_CID_RDS_TX_DEVIATION		= (C.V4L2_CID_FM_TX_CLASS_BASE + 1)
C.V4L2_CID_RDS_TX_PI			= (C.V4L2_CID_FM_TX_CLASS_BASE + 2)
C.V4L2_CID_RDS_TX_PTY			= (C.V4L2_CID_FM_TX_CLASS_BASE + 3)
C.V4L2_CID_RDS_TX_PS_NAME			= (C.V4L2_CID_FM_TX_CLASS_BASE + 5)
C.V4L2_CID_RDS_TX_RADIO_TEXT		= (C.V4L2_CID_FM_TX_CLASS_BASE + 6)

C.V4L2_CID_AUDIO_LIMITER_ENABLED		= (C.V4L2_CID_FM_TX_CLASS_BASE + 64)
C.V4L2_CID_AUDIO_LIMITER_RELEASE_TIME	= (C.V4L2_CID_FM_TX_CLASS_BASE + 65)
C.V4L2_CID_AUDIO_LIMITER_DEVIATION	= (C.V4L2_CID_FM_TX_CLASS_BASE + 66)

C.V4L2_CID_AUDIO_COMPRESSION_ENABLED	= (C.V4L2_CID_FM_TX_CLASS_BASE + 80)
C.V4L2_CID_AUDIO_COMPRESSION_GAIN		= (C.V4L2_CID_FM_TX_CLASS_BASE + 81)
C.V4L2_CID_AUDIO_COMPRESSION_THRESHOLD	= (C.V4L2_CID_FM_TX_CLASS_BASE + 82)
C.V4L2_CID_AUDIO_COMPRESSION_ATTACK_TIME	= (C.V4L2_CID_FM_TX_CLASS_BASE + 83)
C.V4L2_CID_AUDIO_COMPRESSION_RELEASE_TIME	= (C.V4L2_CID_FM_TX_CLASS_BASE + 84)

C.V4L2_CID_PILOT_TONE_ENABLED		= (C.V4L2_CID_FM_TX_CLASS_BASE + 96)
C.V4L2_CID_PILOT_TONE_DEVIATION		= (C.V4L2_CID_FM_TX_CLASS_BASE + 97)
C.V4L2_CID_PILOT_TONE_FREQUENCY		= (C.V4L2_CID_FM_TX_CLASS_BASE + 98)

C.V4L2_CID_TUNE_PREEMPHASIS		= (C.V4L2_CID_FM_TX_CLASS_BASE + 112)

C.V4L2_CID_TUNE_POWER_LEVEL		= (C.V4L2_CID_FM_TX_CLASS_BASE + 113)
C.V4L2_CID_TUNE_ANTENNA_CAPACITOR		= (C.V4L2_CID_FM_TX_CLASS_BASE + 114)


-- Flash and privacy = (indicator) light controls 

C.V4L2_CID_FLASH_CLASS_BASE		= bor(C.V4L2_CTRL_CLASS_FLASH, 0x900)
C.V4L2_CID_FLASH_CLASS			= bor(C.V4L2_CTRL_CLASS_FLASH, 1)

C.V4L2_CID_FLASH_LED_MODE			= (C.V4L2_CID_FLASH_CLASS_BASE + 1)



C.V4L2_CID_FLASH_STROBE_SOURCE		= (C.V4L2_CID_FLASH_CLASS_BASE + 2)


C.V4L2_CID_FLASH_STROBE			= (C.V4L2_CID_FLASH_CLASS_BASE + 3)
C.V4L2_CID_FLASH_STROBE_STOP		= (C.V4L2_CID_FLASH_CLASS_BASE + 4)
C.V4L2_CID_FLASH_STROBE_STATUS		= (C.V4L2_CID_FLASH_CLASS_BASE + 5)

C.V4L2_CID_FLASH_TIMEOUT			= (C.V4L2_CID_FLASH_CLASS_BASE + 6)
C.V4L2_CID_FLASH_INTENSITY		= (C.V4L2_CID_FLASH_CLASS_BASE + 7)
C.V4L2_CID_FLASH_TORCH_INTENSITY		= (C.V4L2_CID_FLASH_CLASS_BASE + 8)
C.V4L2_CID_FLASH_INDICATOR_INTENSITY	= (C.V4L2_CID_FLASH_CLASS_BASE + 9)

C.V4L2_CID_FLASH_FAULT			= (C.V4L2_CID_FLASH_CLASS_BASE + 10)
C.V4L2_FLASH_FAULT_OVER_VOLTAGE		= 1;
C.V4L2_FLASH_FAULT_TIMEOUT		= 2;
C.V4L2_FLASH_FAULT_OVER_TEMPERATURE	= 4;
C.V4L2_FLASH_FAULT_SHORT_CIRCUIT		= 8;
C.V4L2_FLASH_FAULT_OVER_CURRENT		= 16;
C.V4L2_FLASH_FAULT_INDICATOR		= 32;

C.V4L2_CID_FLASH_CHARGE			= (C.V4L2_CID_FLASH_CLASS_BASE + 11)
C.V4L2_CID_FLASH_READY			= (C.V4L2_CID_FLASH_CLASS_BASE + 12)




-- JPEG-class control IDs 

C.V4L2_CID_JPEG_CLASS_BASE		= bor(C.V4L2_CTRL_CLASS_JPEG, 0x900)
C.V4L2_CID_JPEG_CLASS			= bor(C.V4L2_CTRL_CLASS_JPEG, 1)

C.V4L2_CID_JPEG_CHROMA_SUBSAMPLING	= (C.V4L2_CID_JPEG_CLASS_BASE + 1)

C.V4L2_CID_JPEG_RESTART_INTERVAL		= (C.V4L2_CID_JPEG_CLASS_BASE + 2)
C.V4L2_CID_JPEG_COMPRESSION_QUALITY	= (C.V4L2_CID_JPEG_CLASS_BASE + 3)

C.V4L2_CID_JPEG_ACTIVE_MARKER		= (C.V4L2_CID_JPEG_CLASS_BASE + 4)
C.V4L2_JPEG_ACTIVE_MARKER_APP0		= lshift(1, 0)
C.V4L2_JPEG_ACTIVE_MARKER_APP1		= lshift(1, 1)
C.V4L2_JPEG_ACTIVE_MARKER_COM		= lshift(1, 16)
C.V4L2_JPEG_ACTIVE_MARKER_DQT		= lshift(1, 17)
C.V4L2_JPEG_ACTIVE_MARKER_DHT		= lshift(1, 18)




-- Image source controls 
C.V4L2_CID_IMAGE_SOURCE_CLASS_BASE	= bor(C.V4L2_CTRL_CLASS_IMAGE_SOURCE, 0x900)
C.V4L2_CID_IMAGE_SOURCE_CLASS		= bor(C.V4L2_CTRL_CLASS_IMAGE_SOURCE, 1)

C.V4L2_CID_VBLANK				= (C.V4L2_CID_IMAGE_SOURCE_CLASS_BASE + 1)
C.V4L2_CID_HBLANK				= (C.V4L2_CID_IMAGE_SOURCE_CLASS_BASE + 2)
C.V4L2_CID_ANALOGUE_GAIN			= (C.V4L2_CID_IMAGE_SOURCE_CLASS_BASE + 3)




-- Image processing controls 

C.V4L2_CID_IMAGE_PROC_CLASS_BASE		= bor(C.V4L2_CTRL_CLASS_IMAGE_PROC, 0x900)
C.V4L2_CID_IMAGE_PROC_CLASS		= bor(C.V4L2_CTRL_CLASS_IMAGE_PROC, 1)

C.V4L2_CID_LINK_FREQ			= (C.V4L2_CID_IMAGE_PROC_CLASS_BASE + 1)
C.V4L2_CID_PIXEL_RATE			= (C.V4L2_CID_IMAGE_PROC_CLASS_BASE + 2)
C.V4L2_CID_TEST_PATTERN			= (C.V4L2_CID_IMAGE_PROC_CLASS_BASE + 3)




--  DV-class control IDs defined by V4L2 
C.V4L2_CID_DV_CLASS_BASE			= bor(C.V4L2_CTRL_CLASS_DV, 0x900)
C.V4L2_CID_DV_CLASS			= bor(C.V4L2_CTRL_CLASS_DV, 1)

C.V4L2_CID_DV_TX_HOTPLUG			= (C.V4L2_CID_DV_CLASS_BASE + 1)
C.V4L2_CID_DV_TX_RXSENSE			= (C.V4L2_CID_DV_CLASS_BASE + 2)
C.V4L2_CID_DV_TX_EDID_PRESENT		= (C.V4L2_CID_DV_CLASS_BASE + 3)
C.V4L2_CID_DV_TX_MODE			= (C.V4L2_CID_DV_CLASS_BASE + 4)
C.V4L2_CID_DV_TX_RGB_RANGE		= (C.V4L2_CID_DV_CLASS_BASE + 5)




C.V4L2_CID_DV_RX_POWER_PRESENT		= (C.V4L2_CID_DV_CLASS_BASE + 100)
C.V4L2_CID_DV_RX_RGB_RANGE		= (C.V4L2_CID_DV_CLASS_BASE + 101)

C.V4L2_CID_FM_RX_CLASS_BASE		= bor(C.V4L2_CTRL_CLASS_FM_RX, 0x900)
C.V4L2_CID_FM_RX_CLASS			= bor(C.V4L2_CTRL_CLASS_FM_RX, 1)

C.V4L2_CID_TUNE_DEEMPHASIS		= (C.V4L2_CID_FM_RX_CLASS_BASE + 1)

C.V4L2_CID_RDS_RECEPTION			= (C.V4L2_CID_FM_RX_CLASS_BASE + 2)



local Enums = {
	v4l2_power_line_frequency = {
	V4L2_CID_POWER_LINE_FREQUENCY_DISABLED	= 0,
	V4L2_CID_POWER_LINE_FREQUENCY_50HZ	= 1,
	V4L2_CID_POWER_LINE_FREQUENCY_60HZ	= 2,
	V4L2_CID_POWER_LINE_FREQUENCY_AUTO	= 3,
	};	

	v4l2_colorfx = {
	V4L2_COLORFX_NONE			= 0,
	V4L2_COLORFX_BW				= 1,
	V4L2_COLORFX_SEPIA			= 2,
	V4L2_COLORFX_NEGATIVE			= 3,
	V4L2_COLORFX_EMBOSS			= 4,
	V4L2_COLORFX_SKETCH			= 5,
	V4L2_COLORFX_SKY_BLUE			= 6,
	V4L2_COLORFX_GRASS_GREEN		= 7,
	V4L2_COLORFX_SKIN_WHITEN		= 8,
	V4L2_COLORFX_VIVID			= 9,
	V4L2_COLORFX_AQUA			= 10,
	V4L2_COLORFX_ART_FREEZE			= 11,
	V4L2_COLORFX_SILHOUETTE			= 12,
	V4L2_COLORFX_SOLARIZATION		= 13,
	V4L2_COLORFX_ANTIQUE			= 14,
	V4L2_COLORFX_SET_CBCR			= 15,
	};

	v4l2_mpeg_stream_type = {
	V4L2_MPEG_STREAM_TYPE_MPEG2_PS   = 0, -- MPEG-2 program stream 
	V4L2_MPEG_STREAM_TYPE_MPEG2_TS   = 1, -- MPEG-2 transport stream 
	V4L2_MPEG_STREAM_TYPE_MPEG1_SS   = 2, -- MPEG-1 system stream 
	V4L2_MPEG_STREAM_TYPE_MPEG2_DVD  = 3, -- MPEG-2 DVD-compatible stream 
	V4L2_MPEG_STREAM_TYPE_MPEG1_VCD  = 4, -- MPEG-1 VCD-compatible stream 
	V4L2_MPEG_STREAM_TYPE_MPEG2_SVCD = 5, -- MPEG-2 SVCD-compatible stream 
	};

	v4l2_mpeg_audio_mode = {
	V4L2_MPEG_AUDIO_MODE_STEREO       = 0,
	V4L2_MPEG_AUDIO_MODE_JOINT_STEREO = 1,
	V4L2_MPEG_AUDIO_MODE_DUAL         = 2,
	V4L2_MPEG_AUDIO_MODE_MONO         = 3,
	};
	v4l2_mpeg_audio_mode_extension = {
	V4L2_MPEG_AUDIO_MODE_EXTENSION_BOUND_4  = 0,
	V4L2_MPEG_AUDIO_MODE_EXTENSION_BOUND_8  = 1,
	V4L2_MPEG_AUDIO_MODE_EXTENSION_BOUND_12 = 2,
	V4L2_MPEG_AUDIO_MODE_EXTENSION_BOUND_16 = 3,
	};
	v4l2_mpeg_audio_emphasis = {
	V4L2_MPEG_AUDIO_EMPHASIS_NONE         = 0,
	V4L2_MPEG_AUDIO_EMPHASIS_50_DIV_15_uS = 1,
	V4L2_MPEG_AUDIO_EMPHASIS_CCITT_J17    = 2,
	};
	v4l2_mpeg_audio_crc = {
	V4L2_MPEG_AUDIO_CRC_NONE  = 0,
	V4L2_MPEG_AUDIO_CRC_CRC16 = 1,
	};
	v4l2_mpeg_audio_ac3_bitrate = {
	V4L2_MPEG_AUDIO_AC3_BITRATE_32K  = 0,
	V4L2_MPEG_AUDIO_AC3_BITRATE_40K  = 1,
	V4L2_MPEG_AUDIO_AC3_BITRATE_48K  = 2,
	V4L2_MPEG_AUDIO_AC3_BITRATE_56K  = 3,
	V4L2_MPEG_AUDIO_AC3_BITRATE_64K  = 4,
	V4L2_MPEG_AUDIO_AC3_BITRATE_80K  = 5,
	V4L2_MPEG_AUDIO_AC3_BITRATE_96K  = 6,
	V4L2_MPEG_AUDIO_AC3_BITRATE_112K = 7,
	V4L2_MPEG_AUDIO_AC3_BITRATE_128K = 8,
	V4L2_MPEG_AUDIO_AC3_BITRATE_160K = 9,
	V4L2_MPEG_AUDIO_AC3_BITRATE_192K = 10,
	V4L2_MPEG_AUDIO_AC3_BITRATE_224K = 11,
	V4L2_MPEG_AUDIO_AC3_BITRATE_256K = 12,
	V4L2_MPEG_AUDIO_AC3_BITRATE_320K = 13,
	V4L2_MPEG_AUDIO_AC3_BITRATE_384K = 14,
	V4L2_MPEG_AUDIO_AC3_BITRATE_448K = 15,
	V4L2_MPEG_AUDIO_AC3_BITRATE_512K = 16,
	V4L2_MPEG_AUDIO_AC3_BITRATE_576K = 17,
	V4L2_MPEG_AUDIO_AC3_BITRATE_640K = 18,
	};

	v4l2_mpeg_stream_vbi_fmt = {
	V4L2_MPEG_STREAM_VBI_FMT_NONE = 0,  -- No VBI in the MPEG stream 
	V4L2_MPEG_STREAM_VBI_FMT_IVTV = 1,  -- VBI in private packets, IVTV format 
	};

	v4l2_mpeg_audio_sampling_freq = {
	V4L2_MPEG_AUDIO_SAMPLING_FREQ_44100 = 0,
	V4L2_MPEG_AUDIO_SAMPLING_FREQ_48000 = 1,
	V4L2_MPEG_AUDIO_SAMPLING_FREQ_32000 = 2,
	};

	v4l2_mpeg_audio_encoding = {
	V4L2_MPEG_AUDIO_ENCODING_LAYER_1 = 0,
	V4L2_MPEG_AUDIO_ENCODING_LAYER_2 = 1,
	V4L2_MPEG_AUDIO_ENCODING_LAYER_3 = 2,
	V4L2_MPEG_AUDIO_ENCODING_AAC     = 3,
	V4L2_MPEG_AUDIO_ENCODING_AC3     = 4,
	};

	v4l2_mpeg_audio_l1_bitrate = {
	V4L2_MPEG_AUDIO_L1_BITRATE_32K  = 0,
	V4L2_MPEG_AUDIO_L1_BITRATE_64K  = 1,
	V4L2_MPEG_AUDIO_L1_BITRATE_96K  = 2,
	V4L2_MPEG_AUDIO_L1_BITRATE_128K = 3,
	V4L2_MPEG_AUDIO_L1_BITRATE_160K = 4,
	V4L2_MPEG_AUDIO_L1_BITRATE_192K = 5,
	V4L2_MPEG_AUDIO_L1_BITRATE_224K = 6,
	V4L2_MPEG_AUDIO_L1_BITRATE_256K = 7,
	V4L2_MPEG_AUDIO_L1_BITRATE_288K = 8,
	V4L2_MPEG_AUDIO_L1_BITRATE_320K = 9,
	V4L2_MPEG_AUDIO_L1_BITRATE_352K = 10,
	V4L2_MPEG_AUDIO_L1_BITRATE_384K = 11,
	V4L2_MPEG_AUDIO_L1_BITRATE_416K = 12,
	V4L2_MPEG_AUDIO_L1_BITRATE_448K = 13,
	};

	v4l2_mpeg_audio_l2_bitrate = {
	V4L2_MPEG_AUDIO_L2_BITRATE_32K  = 0,
	V4L2_MPEG_AUDIO_L2_BITRATE_48K  = 1,
	V4L2_MPEG_AUDIO_L2_BITRATE_56K  = 2,
	V4L2_MPEG_AUDIO_L2_BITRATE_64K  = 3,
	V4L2_MPEG_AUDIO_L2_BITRATE_80K  = 4,
	V4L2_MPEG_AUDIO_L2_BITRATE_96K  = 5,
	V4L2_MPEG_AUDIO_L2_BITRATE_112K = 6,
	V4L2_MPEG_AUDIO_L2_BITRATE_128K = 7,
	V4L2_MPEG_AUDIO_L2_BITRATE_160K = 8,
	V4L2_MPEG_AUDIO_L2_BITRATE_192K = 9,
	V4L2_MPEG_AUDIO_L2_BITRATE_224K = 10,
	V4L2_MPEG_AUDIO_L2_BITRATE_256K = 11,
	V4L2_MPEG_AUDIO_L2_BITRATE_320K = 12,
	V4L2_MPEG_AUDIO_L2_BITRATE_384K = 13,
	};




	v4l2_mpeg_audio_l3_bitrate = {
	V4L2_MPEG_AUDIO_L3_BITRATE_32K  = 0,
	V4L2_MPEG_AUDIO_L3_BITRATE_40K  = 1,
	V4L2_MPEG_AUDIO_L3_BITRATE_48K  = 2,
	V4L2_MPEG_AUDIO_L3_BITRATE_56K  = 3,
	V4L2_MPEG_AUDIO_L3_BITRATE_64K  = 4,
	V4L2_MPEG_AUDIO_L3_BITRATE_80K  = 5,
	V4L2_MPEG_AUDIO_L3_BITRATE_96K  = 6,
	V4L2_MPEG_AUDIO_L3_BITRATE_112K = 7,
	V4L2_MPEG_AUDIO_L3_BITRATE_128K = 8,
	V4L2_MPEG_AUDIO_L3_BITRATE_160K = 9,
	V4L2_MPEG_AUDIO_L3_BITRATE_192K = 10,
	V4L2_MPEG_AUDIO_L3_BITRATE_224K = 11,
	V4L2_MPEG_AUDIO_L3_BITRATE_256K = 12,
	V4L2_MPEG_AUDIO_L3_BITRATE_320K = 13,
	};

	v4l2_mpeg_audio_dec_playback = {
	V4L2_MPEG_AUDIO_DEC_PLAYBACK_AUTO	    = 0,
	V4L2_MPEG_AUDIO_DEC_PLAYBACK_STEREO	    = 1,
	V4L2_MPEG_AUDIO_DEC_PLAYBACK_LEFT	    = 2,
	V4L2_MPEG_AUDIO_DEC_PLAYBACK_RIGHT	    = 3,
	V4L2_MPEG_AUDIO_DEC_PLAYBACK_MONO	    = 4,
	V4L2_MPEG_AUDIO_DEC_PLAYBACK_SWAPPED_STEREO = 5,
	};
	v4l2_mpeg_video_encoding = {
	V4L2_MPEG_VIDEO_ENCODING_MPEG_1     = 0,
	V4L2_MPEG_VIDEO_ENCODING_MPEG_2     = 1,
	V4L2_MPEG_VIDEO_ENCODING_MPEG_4_AVC = 2,
	};

	v4l2_mpeg_video_aspect = {
	V4L2_MPEG_VIDEO_ASPECT_1x1     = 0,
	V4L2_MPEG_VIDEO_ASPECT_4x3     = 1,
	V4L2_MPEG_VIDEO_ASPECT_16x9    = 2,
	V4L2_MPEG_VIDEO_ASPECT_221x100 = 3,
	};

	v4l2_mpeg_video_bitrate_mode = {
	V4L2_MPEG_VIDEO_BITRATE_MODE_VBR = 0,
	V4L2_MPEG_VIDEO_BITRATE_MODE_CBR = 1,
	};
	v4l2_mpeg_video_header_mode = {
	V4L2_MPEG_VIDEO_HEADER_MODE_SEPARATE			= 0,
	V4L2_MPEG_VIDEO_HEADER_MODE_JOINED_WITH_1ST_FRAME	= 1,

	};
	v4l2_mpeg_video_multi_slice_mode = {
	V4L2_MPEG_VIDEO_MULTI_SLICE_MODE_SINGLE		= 0,
	V4L2_MPEG_VIDEO_MULTI_SICE_MODE_MAX_MB		= 1,
	V4L2_MPEG_VIDEO_MULTI_SICE_MODE_MAX_BYTES	= 2,
	};

	v4l2_mpeg_video_h264_entropy_mode = {
	V4L2_MPEG_VIDEO_H264_ENTROPY_MODE_CAVLC	= 0,
	V4L2_MPEG_VIDEO_H264_ENTROPY_MODE_CABAC	= 1,
	};

	v4l2_mpeg_video_h264_level = {
	V4L2_MPEG_VIDEO_H264_LEVEL_1_0	= 0,
	V4L2_MPEG_VIDEO_H264_LEVEL_1B	= 1,
	V4L2_MPEG_VIDEO_H264_LEVEL_1_1	= 2,
	V4L2_MPEG_VIDEO_H264_LEVEL_1_2	= 3,
	V4L2_MPEG_VIDEO_H264_LEVEL_1_3	= 4,
	V4L2_MPEG_VIDEO_H264_LEVEL_2_0	= 5,
	V4L2_MPEG_VIDEO_H264_LEVEL_2_1	= 6,
	V4L2_MPEG_VIDEO_H264_LEVEL_2_2	= 7,
	V4L2_MPEG_VIDEO_H264_LEVEL_3_0	= 8,
	V4L2_MPEG_VIDEO_H264_LEVEL_3_1	= 9,
	V4L2_MPEG_VIDEO_H264_LEVEL_3_2	= 10,
	V4L2_MPEG_VIDEO_H264_LEVEL_4_0	= 11,
	V4L2_MPEG_VIDEO_H264_LEVEL_4_1	= 12,
	V4L2_MPEG_VIDEO_H264_LEVEL_4_2	= 13,
	V4L2_MPEG_VIDEO_H264_LEVEL_5_0	= 14,
	V4L2_MPEG_VIDEO_H264_LEVEL_5_1	= 15,
	};

	v4l2_mpeg_video_h264_loop_filter_mode = {
	V4L2_MPEG_VIDEO_H264_LOOP_FILTER_MODE_ENABLED				= 0,
	V4L2_MPEG_VIDEO_H264_LOOP_FILTER_MODE_DISABLED				= 1,
	V4L2_MPEG_VIDEO_H264_LOOP_FILTER_MODE_DISABLED_AT_SLICE_BOUNDARY	= 2,
	};
	v4l2_mpeg_video_h264_profile = {
	V4L2_MPEG_VIDEO_H264_PROFILE_BASELINE			= 0,
	V4L2_MPEG_VIDEO_H264_PROFILE_CONSTRAINED_BASELINE	= 1,
	V4L2_MPEG_VIDEO_H264_PROFILE_MAIN			= 2,
	V4L2_MPEG_VIDEO_H264_PROFILE_EXTENDED			= 3,
	V4L2_MPEG_VIDEO_H264_PROFILE_HIGH			= 4,
	V4L2_MPEG_VIDEO_H264_PROFILE_HIGH_10			= 5,
	V4L2_MPEG_VIDEO_H264_PROFILE_HIGH_422			= 6,
	V4L2_MPEG_VIDEO_H264_PROFILE_HIGH_444_PREDICTIVE	= 7,
	V4L2_MPEG_VIDEO_H264_PROFILE_HIGH_10_INTRA		= 8,
	V4L2_MPEG_VIDEO_H264_PROFILE_HIGH_422_INTRA		= 9,
	V4L2_MPEG_VIDEO_H264_PROFILE_HIGH_444_INTRA		= 10,
	V4L2_MPEG_VIDEO_H264_PROFILE_CAVLC_444_INTRA		= 11,
	V4L2_MPEG_VIDEO_H264_PROFILE_SCALABLE_BASELINE		= 12,
	V4L2_MPEG_VIDEO_H264_PROFILE_SCALABLE_HIGH		= 13,
	V4L2_MPEG_VIDEO_H264_PROFILE_SCALABLE_HIGH_INTRA	= 14,
	V4L2_MPEG_VIDEO_H264_PROFILE_STEREO_HIGH		= 15,
	V4L2_MPEG_VIDEO_H264_PROFILE_MULTIVIEW_HIGH		= 16,
	};


	v4l2_mpeg_video_h264_vui_sar_idc = {
	V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_UNSPECIFIED	= 0,
	V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_1x1		= 1,
	V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_12x11		= 2,
	V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_10x11		= 3,
	V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_16x11		= 4,
	V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_40x33		= 5,
	V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_24x11		= 6,
	V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_20x11		= 7,
	V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_32x11		= 8,
	V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_80x33		= 9,
	V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_18x11		= 10,
	V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_15x11		= 11,
	V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_64x33		= 12,
	V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_160x99		= 13,
	V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_4x3		= 14,
	V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_3x2		= 15,
	V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_2x1		= 16,
	V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_EXTENDED	= 17,
	};

	v4l2_mpeg_video_h264_sei_fp_arrangement_type = {
	V4L2_MPEG_VIDEO_H264_SEI_FP_ARRANGEMENT_TYPE_CHECKERBOARD	= 0,
	V4L2_MPEG_VIDEO_H264_SEI_FP_ARRANGEMENT_TYPE_COLUMN		= 1,
	V4L2_MPEG_VIDEO_H264_SEI_FP_ARRANGEMENT_TYPE_ROW		= 2,
	V4L2_MPEG_VIDEO_H264_SEI_FP_ARRANGEMENT_TYPE_SIDE_BY_SIDE	= 3,
	V4L2_MPEG_VIDEO_H264_SEI_FP_ARRANGEMENT_TYPE_TOP_BOTTOM		= 4,
	V4L2_MPEG_VIDEO_H264_SEI_FP_ARRANGEMENT_TYPE_TEMPORAL		= 5,
	};

	v4l2_mpeg_video_h264_fmo_map_type = {
	V4L2_MPEG_VIDEO_H264_FMO_MAP_TYPE_INTERLEAVED_SLICES		= 0,
	V4L2_MPEG_VIDEO_H264_FMO_MAP_TYPE_SCATTERED_SLICES		= 1,
	V4L2_MPEG_VIDEO_H264_FMO_MAP_TYPE_FOREGROUND_WITH_LEFT_OVER	= 2,
	V4L2_MPEG_VIDEO_H264_FMO_MAP_TYPE_BOX_OUT			= 3,
	V4L2_MPEG_VIDEO_H264_FMO_MAP_TYPE_RASTER_SCAN			= 4,
	V4L2_MPEG_VIDEO_H264_FMO_MAP_TYPE_WIPE_SCAN			= 5,
	V4L2_MPEG_VIDEO_H264_FMO_MAP_TYPE_EXPLICIT			= 6,
	};

	v4l2_mpeg_video_h264_fmo_change_dir = {
	V4L2_MPEG_VIDEO_H264_FMO_CHANGE_DIR_RIGHT	= 0,
	V4L2_MPEG_VIDEO_H264_FMO_CHANGE_DIR_LEFT	= 1,
	};

	v4l2_mpeg_video_h264_hierarchical_coding_type = {
	V4L2_MPEG_VIDEO_H264_HIERARCHICAL_CODING_B	= 0,
	V4L2_MPEG_VIDEO_H264_HIERARCHICAL_CODING_P	= 1,
	};

	v4l2_mpeg_video_mpeg4_level = {
	V4L2_MPEG_VIDEO_MPEG4_LEVEL_0	= 0,
	V4L2_MPEG_VIDEO_MPEG4_LEVEL_0B	= 1,
	V4L2_MPEG_VIDEO_MPEG4_LEVEL_1	= 2,
	V4L2_MPEG_VIDEO_MPEG4_LEVEL_2	= 3,
	V4L2_MPEG_VIDEO_MPEG4_LEVEL_3	= 4,
	V4L2_MPEG_VIDEO_MPEG4_LEVEL_3B	= 5,
	V4L2_MPEG_VIDEO_MPEG4_LEVEL_4	= 6,
	V4L2_MPEG_VIDEO_MPEG4_LEVEL_5	= 7,
	};

	v4l2_mpeg_video_mpeg4_profile = {
	V4L2_MPEG_VIDEO_MPEG4_PROFILE_SIMPLE				= 0,
	V4L2_MPEG_VIDEO_MPEG4_PROFILE_ADVANCED_SIMPLE			= 1,
	V4L2_MPEG_VIDEO_MPEG4_PROFILE_CORE				= 2,
	V4L2_MPEG_VIDEO_MPEG4_PROFILE_SIMPLE_SCALABLE			= 3,
	V4L2_MPEG_VIDEO_MPEG4_PROFILE_ADVANCED_CODING_EFFICIENCY	= 4,
	};

	v4l2_vp8_num_partitions = {
	V4L2_CID_MPEG_VIDEO_VPX_1_PARTITION	= 0,
	V4L2_CID_MPEG_VIDEO_VPX_2_PARTITIONS	= 1,
	V4L2_CID_MPEG_VIDEO_VPX_4_PARTITIONS	= 2,
	V4L2_CID_MPEG_VIDEO_VPX_8_PARTITIONS	= 3,
	};

	v4l2_vp8_num_ref_frames = {
	V4L2_CID_MPEG_VIDEO_VPX_1_REF_FRAME	= 0,
	V4L2_CID_MPEG_VIDEO_VPX_2_REF_FRAME	= 1,
	V4L2_CID_MPEG_VIDEO_VPX_3_REF_FRAME	= 2,
	};

	v4l2_vp8_golden_frame_sel = {
	V4L2_CID_MPEG_VIDEO_VPX_GOLDEN_FRAME_USE_PREV		= 0,
	V4L2_CID_MPEG_VIDEO_VPX_GOLDEN_FRAME_USE_REF_PERIOD	= 1,
	};

	v4l2_mpeg_cx2341x_video_spatial_filter_mode = {
	V4L2_MPEG_CX2341X_VIDEO_SPATIAL_FILTER_MODE_MANUAL = 0,
	V4L2_MPEG_CX2341X_VIDEO_SPATIAL_FILTER_MODE_AUTO   = 1,
	};

	v4l2_mpeg_cx2341x_video_luma_spatial_filter_type = {
	V4L2_MPEG_CX2341X_VIDEO_LUMA_SPATIAL_FILTER_TYPE_OFF                  = 0,
	V4L2_MPEG_CX2341X_VIDEO_LUMA_SPATIAL_FILTER_TYPE_1D_HOR               = 1,
	V4L2_MPEG_CX2341X_VIDEO_LUMA_SPATIAL_FILTER_TYPE_1D_VERT              = 2,
	V4L2_MPEG_CX2341X_VIDEO_LUMA_SPATIAL_FILTER_TYPE_2D_HV_SEPARABLE      = 3,
	V4L2_MPEG_CX2341X_VIDEO_LUMA_SPATIAL_FILTER_TYPE_2D_SYM_NON_SEPARABLE = 4,
	};

	v4l2_mpeg_cx2341x_video_chroma_spatial_filter_type = {
	V4L2_MPEG_CX2341X_VIDEO_CHROMA_SPATIAL_FILTER_TYPE_OFF    = 0,
	V4L2_MPEG_CX2341X_VIDEO_CHROMA_SPATIAL_FILTER_TYPE_1D_HOR = 1,
	};

	v4l2_mpeg_cx2341x_video_temporal_filter_mode = {
	V4L2_MPEG_CX2341X_VIDEO_TEMPORAL_FILTER_MODE_MANUAL = 0,
	V4L2_MPEG_CX2341X_VIDEO_TEMPORAL_FILTER_MODE_AUTO   = 1,
	};

	v4l2_mpeg_cx2341x_video_median_filter_type = {
	V4L2_MPEG_CX2341X_VIDEO_MEDIAN_FILTER_TYPE_OFF      = 0,
	V4L2_MPEG_CX2341X_VIDEO_MEDIAN_FILTER_TYPE_HOR      = 1,
	V4L2_MPEG_CX2341X_VIDEO_MEDIAN_FILTER_TYPE_VERT     = 2,
	V4L2_MPEG_CX2341X_VIDEO_MEDIAN_FILTER_TYPE_HOR_VERT = 3,
	V4L2_MPEG_CX2341X_VIDEO_MEDIAN_FILTER_TYPE_DIAG     = 4,
	};

	v4l2_mpeg_mfc51_video_frame_skip_mode = {
	V4L2_MPEG_MFC51_VIDEO_FRAME_SKIP_MODE_DISABLED		= 0,
	V4L2_MPEG_MFC51_VIDEO_FRAME_SKIP_MODE_LEVEL_LIMIT	= 1,
	V4L2_MPEG_MFC51_VIDEO_FRAME_SKIP_MODE_BUF_LIMIT		= 2,
	};

	v4l2_mpeg_mfc51_video_force_frame_type = {
	V4L2_MPEG_MFC51_VIDEO_FORCE_FRAME_TYPE_DISABLED		= 0,
	V4L2_MPEG_MFC51_VIDEO_FORCE_FRAME_TYPE_I_FRAME		= 1,
	V4L2_MPEG_MFC51_VIDEO_FORCE_FRAME_TYPE_NOT_CODED	= 2,
	};

	 v4l2_exposure_auto_type = {
	V4L2_EXPOSURE_AUTO = 0,
	V4L2_EXPOSURE_MANUAL = 1,
	V4L2_EXPOSURE_SHUTTER_PRIORITY = 2,
	V4L2_EXPOSURE_APERTURE_PRIORITY = 3
	};

	v4l2_auto_n_preset_white_balance = {
	V4L2_WHITE_BALANCE_MANUAL		= 0,
	V4L2_WHITE_BALANCE_AUTO			= 1,
	V4L2_WHITE_BALANCE_INCANDESCENT		= 2,
	V4L2_WHITE_BALANCE_FLUORESCENT		= 3,
	V4L2_WHITE_BALANCE_FLUORESCENT_H	= 4,
	V4L2_WHITE_BALANCE_HORIZON		= 5,
	V4L2_WHITE_BALANCE_DAYLIGHT		= 6,
	V4L2_WHITE_BALANCE_FLASH		= 7,
	V4L2_WHITE_BALANCE_CLOUDY		= 8,
	V4L2_WHITE_BALANCE_SHADE		= 9,
	};

	v4l2_iso_sensitivity_auto_type = {
	V4L2_ISO_SENSITIVITY_MANUAL		= 0,
	V4L2_ISO_SENSITIVITY_AUTO		= 1,
	};

	v4l2_exposure_metering = {
	V4L2_EXPOSURE_METERING_AVERAGE		= 0,
	V4L2_EXPOSURE_METERING_CENTER_WEIGHTED	= 1,
	V4L2_EXPOSURE_METERING_SPOT		= 2,
	V4L2_EXPOSURE_METERING_MATRIX		= 3,
	};

	v4l2_scene_mode = {
	V4L2_SCENE_MODE_NONE			= 0,
	V4L2_SCENE_MODE_BACKLIGHT		= 1,
	V4L2_SCENE_MODE_BEACH_SNOW		= 2,
	V4L2_SCENE_MODE_CANDLE_LIGHT		= 3,
	V4L2_SCENE_MODE_DAWN_DUSK		= 4,
	V4L2_SCENE_MODE_FALL_COLORS		= 5,
	V4L2_SCENE_MODE_FIREWORKS		= 6,
	V4L2_SCENE_MODE_LANDSCAPE		= 7,
	V4L2_SCENE_MODE_NIGHT			= 8,
	V4L2_SCENE_MODE_PARTY_INDOOR		= 9,
	V4L2_SCENE_MODE_PORTRAIT		= 10,
	V4L2_SCENE_MODE_SPORTS			= 11,
	V4L2_SCENE_MODE_SUNSET			= 12,
	V4L2_SCENE_MODE_TEXT			= 13,
	};

	v4l2_auto_focus_range = {
	V4L2_AUTO_FOCUS_RANGE_AUTO		= 0,
	V4L2_AUTO_FOCUS_RANGE_NORMAL		= 1,
	V4L2_AUTO_FOCUS_RANGE_MACRO		= 2,
	V4L2_AUTO_FOCUS_RANGE_INFINITY		= 3,
	};

	v4l2_preemphasis = {
	V4L2_PREEMPHASIS_DISABLED	= 0,
	V4L2_PREEMPHASIS_50_uS		= 1,
	V4L2_PREEMPHASIS_75_uS		= 2,
	};

	v4l2_flash_led_mode = {
	V4L2_FLASH_LED_MODE_NONE,
	V4L2_FLASH_LED_MODE_FLASH,
	V4L2_FLASH_LED_MODE_TORCH,
	};

	v4l2_flash_strobe_source = {
	V4L2_FLASH_STROBE_SOURCE_SOFTWARE,
	V4L2_FLASH_STROBE_SOURCE_EXTERNAL,
	};

	v4l2_jpeg_chroma_subsampling = {
	V4L2_JPEG_CHROMA_SUBSAMPLING_444	= 0,
	V4L2_JPEG_CHROMA_SUBSAMPLING_422	= 1,
	V4L2_JPEG_CHROMA_SUBSAMPLING_420	= 2,
	V4L2_JPEG_CHROMA_SUBSAMPLING_411	= 3,
	V4L2_JPEG_CHROMA_SUBSAMPLING_410	= 4,
	V4L2_JPEG_CHROMA_SUBSAMPLING_GRAY	= 5,
	};

	v4l2_dv_tx_mode = {
	V4L2_DV_TX_MODE_DVI_D	= 0,
	V4L2_DV_TX_MODE_HDMI	= 1,
	};

	v4l2_dv_rgb_range = {
	V4L2_DV_RGB_RANGE_AUTO	  = 0,
	V4L2_DV_RGB_RANGE_LIMITED = 1,
	V4L2_DV_RGB_RANGE_FULL	  = 2,
	};

	v4l2_deemphasis = {
	V4L2_DEEMPHASIS_DISABLED	= 0,
	V4L2_DEEMPHASIS_50_uS		= 1,
	V4L2_DEEMPHASIS_75_uS		= 2,
	};
}

local exports = {
	Constants = C;
	Enums = Enums;
}

return exports

