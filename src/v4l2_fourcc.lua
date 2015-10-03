-- v4l2_fourcc.lua
local fourcc = require("fourcc")
local fourcc_enc = fourcc.fourcc_encode;


local exports = {
--      Pixel format         FOURCC                          depth  Description  

-- RGB formats 
	V4L2_PIX_FMT_RGB332  = fourcc_enc('R', 'G', 'B', '1'); --  8  RGB-3-3-2     
	V4L2_PIX_FMT_RGB444  = fourcc_enc('R', '4', '4', '4'); -- 16  xxxxrrrr ggggbbbb 
	V4L2_PIX_FMT_RGB555  = fourcc_enc('R', 'G', 'B', 'O'); -- 16  RGB-5-5-5     
	V4L2_PIX_FMT_RGB565  = fourcc_enc('R', 'G', 'B', 'P'); -- 16  RGB-5-6-5     
	V4L2_PIX_FMT_RGB555X = fourcc_enc('R', 'G', 'B', 'Q'); -- 16  RGB-5-5-5 BE  
	V4L2_PIX_FMT_RGB565X = fourcc_enc('R', 'G', 'B', 'R'); -- 16  RGB-5-6-5 BE  
	V4L2_PIX_FMT_BGR666  = fourcc_enc('B', 'G', 'R', 'H'); -- 18  BGR-6-6-6	  
	V4L2_PIX_FMT_BGR24   = fourcc_enc('B', 'G', 'R', '3'); -- 24  BGR-8-8-8     
	V4L2_PIX_FMT_RGB24   = fourcc_enc('R', 'G', 'B', '3'); -- 24  RGB-8-8-8     
	V4L2_PIX_FMT_BGR32   = fourcc_enc('B', 'G', 'R', '4'); -- 32  BGR-8-8-8-8   
	V4L2_PIX_FMT_RGB32   = fourcc_enc('R', 'G', 'B', '4'); -- 32  RGB-8-8-8-8   

-- Grey formats 
	V4L2_PIX_FMT_GREY    = fourcc_enc('G', 'R', 'E', 'Y'); --  8  Greyscale     
	V4L2_PIX_FMT_Y4      = fourcc_enc('Y', '0', '4', ' '); --  4  Greyscale     
	V4L2_PIX_FMT_Y6      = fourcc_enc('Y', '0', '6', ' '); --  6  Greyscale     
	V4L2_PIX_FMT_Y10     = fourcc_enc('Y', '1', '0', ' '); -- 10  Greyscale     
	V4L2_PIX_FMT_Y12     = fourcc_enc('Y', '1', '2', ' '); -- 12  Greyscale     
	V4L2_PIX_FMT_Y16     = fourcc_enc('Y', '1', '6', ' '); -- 16  Greyscale     

-- Grey bit-packed formats 
	V4L2_PIX_FMT_Y10BPACK    = fourcc_enc('Y', '1', '0', 'B'); -- 10  Greyscale bit-packed 

-- Palette formats 
	V4L2_PIX_FMT_PAL8    = fourcc_enc('P', 'A', 'L', '8'); --  8  8-bit palette 

-- Chrominance formats 
	V4L2_PIX_FMT_UV8     = fourcc_enc('U', 'V', '8', ' '); --  8  UV 4:4 

-- Luminance+Chrominance formats 
	V4L2_PIX_FMT_YVU410  = fourcc_enc('Y', 'V', 'U', '9'); --  9  YVU 4:1:0     
	V4L2_PIX_FMT_YVU420  = fourcc_enc('Y', 'V', '1', '2'); -- 12  YVU 4:2:0     
	V4L2_PIX_FMT_YUYV    = fourcc_enc('Y', 'U', 'Y', 'V'); -- 16  YUV 4:2:2     
	V4L2_PIX_FMT_YYUV    = fourcc_enc('Y', 'Y', 'U', 'V'); -- 16  YUV 4:2:2     
	V4L2_PIX_FMT_YVYU    = fourcc_enc('Y', 'V', 'Y', 'U'); -- 16 YVU 4:2:2 
	V4L2_PIX_FMT_UYVY    = fourcc_enc('U', 'Y', 'V', 'Y'); -- 16  YUV 4:2:2     
	V4L2_PIX_FMT_VYUY    = fourcc_enc('V', 'Y', 'U', 'Y'); -- 16  YUV 4:2:2     
	V4L2_PIX_FMT_YUV422P = fourcc_enc('4', '2', '2', 'P'); -- 16  YVU422 planar 
	V4L2_PIX_FMT_YUV411P = fourcc_enc('4', '1', '1', 'P'); -- 16  YVU411 planar 
	V4L2_PIX_FMT_Y41P    = fourcc_enc('Y', '4', '1', 'P'); -- 12  YUV 4:1:1     
	V4L2_PIX_FMT_YUV444  = fourcc_enc('Y', '4', '4', '4'); -- 16  xxxxyyyy uuuuvvvv 
	V4L2_PIX_FMT_YUV555  = fourcc_enc('Y', 'U', 'V', 'O'); -- 16  YUV-5-5-5     
	V4L2_PIX_FMT_YUV565  = fourcc_enc('Y', 'U', 'V', 'P'); -- 16  YUV-5-6-5     
	V4L2_PIX_FMT_YUV32   = fourcc_enc('Y', 'U', 'V', '4'); -- 32  YUV-8-8-8-8   
	V4L2_PIX_FMT_YUV410  = fourcc_enc('Y', 'U', 'V', '9'); --  9  YUV 4:1:0     
	V4L2_PIX_FMT_YUV420  = fourcc_enc('Y', 'U', '1', '2'); -- 12  YUV 4:2:0     
	V4L2_PIX_FMT_HI240   = fourcc_enc('H', 'I', '2', '4'); --  8  8-bit color   
	V4L2_PIX_FMT_HM12    = fourcc_enc('H', 'M', '1', '2'); --  8  YUV 4:2:0 16x16 macroblocks 
	V4L2_PIX_FMT_M420    = fourcc_enc('M', '4', '2', '0'); -- 12  YUV 4:2:0 2 lines y, 1 line uv interleaved 

-- two planes -- one Y, one Cr + Cb interleaved  
	V4L2_PIX_FMT_NV12    = fourcc_enc('N', 'V', '1', '2'); -- 12  Y/CbCr 4:2:0  
	V4L2_PIX_FMT_NV21    = fourcc_enc('N', 'V', '2', '1'); -- 12  Y/CrCb 4:2:0  
	V4L2_PIX_FMT_NV16    = fourcc_enc('N', 'V', '1', '6'); -- 16  Y/CbCr 4:2:2  
	V4L2_PIX_FMT_NV61    = fourcc_enc('N', 'V', '6', '1'); -- 16  Y/CrCb 4:2:2  
	V4L2_PIX_FMT_NV24    = fourcc_enc('N', 'V', '2', '4'); -- 24  Y/CbCr 4:4:4  
	V4L2_PIX_FMT_NV42    = fourcc_enc('N', 'V', '4', '2'); -- 24  Y/CrCb 4:4:4  

-- two non contiguous planes - one Y, one Cr + Cb interleaved  
	V4L2_PIX_FMT_NV12M   = fourcc_enc('N', 'M', '1', '2'); -- 12  Y/CbCr 4:2:0  
	V4L2_PIX_FMT_NV21M   = fourcc_enc('N', 'M', '2', '1'); -- 21  Y/CrCb 4:2:0  
	V4L2_PIX_FMT_NV16M   = fourcc_enc('N', 'M', '1', '6'); -- 16  Y/CbCr 4:2:2  
	V4L2_PIX_FMT_NV61M   = fourcc_enc('N', 'M', '6', '1'); -- 16  Y/CrCb 4:2:2  
	V4L2_PIX_FMT_NV12MT  = fourcc_enc('T', 'M', '1', '2'); -- 12  Y/CbCr 4:2:0 64x32 macroblocks 
	V4L2_PIX_FMT_NV12MT_16X16 = fourcc_enc('V', 'M', '1', '2'); -- 12  Y/CbCr 4:2:0 16x16 macroblocks 

-- three non contiguous planes - Y, Cb, Cr 
	V4L2_PIX_FMT_YUV420M = fourcc_enc('Y', 'M', '1', '2'); -- 12  YUV420 planar 
	V4L2_PIX_FMT_YVU420M = fourcc_enc('Y', 'M', '2', '1'); -- 12  YVU420 planar 

-- Bayer formats - see http://www.siliconimaging.com/RGB%20Bayer.htm 
	V4L2_PIX_FMT_SBGGR8  = fourcc_enc('B', 'A', '8', '1'); --  8  BGBG.. GRGR.. 
	V4L2_PIX_FMT_SGBRG8  = fourcc_enc('G', 'B', 'R', 'G'); --  8  GBGB.. RGRG.. 
	V4L2_PIX_FMT_SGRBG8  = fourcc_enc('G', 'R', 'B', 'G'); --  8  GRGR.. BGBG.. 
	V4L2_PIX_FMT_SRGGB8  = fourcc_enc('R', 'G', 'G', 'B'); --  8  RGRG.. GBGB.. 
	V4L2_PIX_FMT_SBGGR10 = fourcc_enc('B', 'G', '1', '0'); -- 10  BGBG.. GRGR.. 
	V4L2_PIX_FMT_SGBRG10 = fourcc_enc('G', 'B', '1', '0'); -- 10  GBGB.. RGRG.. 
	V4L2_PIX_FMT_SGRBG10 = fourcc_enc('B', 'A', '1', '0'); -- 10  GRGR.. BGBG.. 
	V4L2_PIX_FMT_SRGGB10 = fourcc_enc('R', 'G', '1', '0'); -- 10  RGRG.. GBGB.. 
	V4L2_PIX_FMT_SBGGR12 = fourcc_enc('B', 'G', '1', '2'); -- 12  BGBG.. GRGR.. 
	V4L2_PIX_FMT_SGBRG12 = fourcc_enc('G', 'B', '1', '2'); -- 12  GBGB.. RGRG.. 
	V4L2_PIX_FMT_SGRBG12 = fourcc_enc('B', 'A', '1', '2'); -- 12  GRGR.. BGBG.. 
	V4L2_PIX_FMT_SRGGB12 = fourcc_enc('R', 'G', '1', '2'); -- 12  RGRG.. GBGB.. 
	-- 10bit raw bayer a-law compressed to 8 bits 
	V4L2_PIX_FMT_SBGGR10ALAW8 = fourcc_enc('a', 'B', 'A', '8');
	V4L2_PIX_FMT_SGBRG10ALAW8 = fourcc_enc('a', 'G', 'A', '8');
	V4L2_PIX_FMT_SGRBG10ALAW8 = fourcc_enc('a', 'g', 'A', '8');
	V4L2_PIX_FMT_SRGGB10ALAW8 = fourcc_enc('a', 'R', 'A', '8');
	-- 10bit raw bayer DPCM compressed to 8 bits 
	V4L2_PIX_FMT_SBGGR10DPCM8 = fourcc_enc('b', 'B', 'A', '8');
	V4L2_PIX_FMT_SGBRG10DPCM8 = fourcc_enc('b', 'G', 'A', '8');
	V4L2_PIX_FMT_SGRBG10DPCM8 = fourcc_enc('B', 'D', '1', '0');
	V4L2_PIX_FMT_SRGGB10DPCM8 = fourcc_enc('b', 'R', 'A', '8');
	--
	-- 10bit raw bayer, expanded to 16 bits
	-- xxxxrrrrrrrrrrxxxxgggggggggg xxxxggggggggggxxxxbbbbbbbbbb...
	 
	V4L2_PIX_FMT_SBGGR16 = fourcc_enc('B', 'Y', 'R', '2'); -- 16  BGBG.. GRGR.. 

-- compressed formats 
	V4L2_PIX_FMT_MJPEG    = fourcc_enc('M', 'J', 'P', 'G'); -- Motion-JPEG   
	V4L2_PIX_FMT_JPEG     = fourcc_enc('J', 'P', 'E', 'G'); -- JFIF JPEG     
	V4L2_PIX_FMT_DV       = fourcc_enc('d', 'v', 's', 'd'); -- 1394          
	V4L2_PIX_FMT_MPEG     = fourcc_enc('M', 'P', 'E', 'G'); -- MPEG-1/2/4 Multiplexed 
	V4L2_PIX_FMT_H264     = fourcc_enc('H', '2', '6', '4'); -- H264 with start codes 
	V4L2_PIX_FMT_H264_NO_SC = fourcc_enc('A', 'V', 'C', '1'); -- H264 without start codes 
	V4L2_PIX_FMT_H264_MVC = fourcc_enc('M', '2', '6', '4'); -- H264 MVC 
	V4L2_PIX_FMT_H263     = fourcc_enc('H', '2', '6', '3'); -- H263          
	V4L2_PIX_FMT_MPEG1    = fourcc_enc('M', 'P', 'G', '1'); -- MPEG-1 ES     
	V4L2_PIX_FMT_MPEG2    = fourcc_enc('M', 'P', 'G', '2'); -- MPEG-2 ES     
	V4L2_PIX_FMT_MPEG4    = fourcc_enc('M', 'P', 'G', '4'); -- MPEG-4 part 2 ES 
	V4L2_PIX_FMT_XVID     = fourcc_enc('X', 'V', 'I', 'D'); -- Xvid           
	V4L2_PIX_FMT_VC1_ANNEX_G = fourcc_enc('V', 'C', '1', 'G'); -- SMPTE 421M Annex G compliant stream 
	V4L2_PIX_FMT_VC1_ANNEX_L = fourcc_enc('V', 'C', '1', 'L'); -- SMPTE 421M Annex L compliant stream 
	V4L2_PIX_FMT_VP8      = fourcc_enc('V', 'P', '8', '0'); -- VP8 

--  Vendor-specific formats   
	V4L2_PIX_FMT_CPIA1    = fourcc_enc('C', 'P', 'I', 'A'); -- cpia1 YUV 
	V4L2_PIX_FMT_WNVA     = fourcc_enc('W', 'N', 'V', 'A'); -- Winnov hw compress 
	V4L2_PIX_FMT_SN9C10X  = fourcc_enc('S', '9', '1', '0'); -- SN9C10x compression 
	V4L2_PIX_FMT_SN9C20X_I420 = fourcc_enc('S', '9', '2', '0'); -- SN9C20x YUV 4:2:0 
	V4L2_PIX_FMT_PWC1     = fourcc_enc('P', 'W', 'C', '1'); -- pwc older webcam 
	V4L2_PIX_FMT_PWC2     = fourcc_enc('P', 'W', 'C', '2'); -- pwc newer webcam 
	V4L2_PIX_FMT_ET61X251 = fourcc_enc('E', '6', '2', '5'); -- ET61X251 compression 
	V4L2_PIX_FMT_SPCA501  = fourcc_enc('S', '5', '0', '1'); -- YUYV per line 
	V4L2_PIX_FMT_SPCA505  = fourcc_enc('S', '5', '0', '5'); -- YYUV per line 
	V4L2_PIX_FMT_SPCA508  = fourcc_enc('S', '5', '0', '8'); -- YUVY per line 
	V4L2_PIX_FMT_SPCA561  = fourcc_enc('S', '5', '6', '1'); -- compressed GBRG bayer 
	V4L2_PIX_FMT_PAC207   = fourcc_enc('P', '2', '0', '7'); -- compressed BGGR bayer 
	V4L2_PIX_FMT_MR97310A = fourcc_enc('M', '3', '1', '0'); -- compressed BGGR bayer 
	V4L2_PIX_FMT_JL2005BCD = fourcc_enc('J', 'L', '2', '0'); -- compressed RGGB bayer 
	V4L2_PIX_FMT_SN9C2028 = fourcc_enc('S', 'O', 'N', 'X'); -- compressed GBRG bayer 
	V4L2_PIX_FMT_SQ905C   = fourcc_enc('9', '0', '5', 'C'); -- compressed RGGB bayer 
	V4L2_PIX_FMT_PJPG     = fourcc_enc('P', 'J', 'P', 'G'); -- Pixart 73xx JPEG 
	V4L2_PIX_FMT_OV511    = fourcc_enc('O', '5', '1', '1'); -- ov511 JPEG 
	V4L2_PIX_FMT_OV518    = fourcc_enc('O', '5', '1', '8'); -- ov518 JPEG 
	V4L2_PIX_FMT_STV0680  = fourcc_enc('S', '6', '8', '0'); -- stv0680 bayer 
	V4L2_PIX_FMT_TM6000   = fourcc_enc('T', 'M', '6', '0'); -- tm5600/tm60x0 
	V4L2_PIX_FMT_CIT_YYVYUY = fourcc_enc('C', 'I', 'T', 'V'); -- one line of Y then 1 line of VYUY 
	V4L2_PIX_FMT_KONICA420  = fourcc_enc('K', 'O', 'N', 'I'); -- YUV420 planar in blocks of 256 pixels 
	V4L2_PIX_FMT_JPGL	= fourcc_enc('J', 'P', 'G', 'L'); -- JPEG-Lite 
	V4L2_PIX_FMT_SE401      = fourcc_enc('S', '4', '0', '1'); -- se401 janggu compressed rgb 
	V4L2_PIX_FMT_S5C_UYVY_JPG = fourcc_enc('S', '5', 'C', 'I'); -- S5C73M3 interleaved UYVY/JPEG 


}

setmetatable(exports, {
	__call = function(self, tbl)
		tbl = tbl or _G

		for k,v in pairs(self) do
			tbl[k] = v;
		end

		return self;
	end,
})

return exports
