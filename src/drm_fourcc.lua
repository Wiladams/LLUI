local bit = require("bit")
local lshift = bit.lshift;

local fourcc = require("fourcc")

local fourcc_encode = fourcc.fourcc_encode


local exports = {
	DRM_FORMAT_BIG_ENDIAN = lshift(1,31); --[[ format is big endian instead of little endian --]]

--[[ color index --]]
	DRM_FORMAT_C8		= fourcc_encode('C', '8', ' ', ' '); --[[ [7:0] C --]]

--[[ 8 bpp RGB --]]
	DRM_FORMAT_RGB332	= fourcc_encode('R', 'G', 'B', '8'); --[[ [7:0] R:G:B 3:3:2 --]]
	DRM_FORMAT_BGR233	= fourcc_encode('B', 'G', 'R', '8'); --[[ [7:0] B:G:R 2:3:3 --]]

--[[ 16 bpp RGB --]]
	DRM_FORMAT_XRGB4444	= fourcc_encode('X', 'R', '1', '2'); --[[ [15:0] x:R:G:B 4:4:4:4 little endian --]]
	DRM_FORMAT_XBGR4444	= fourcc_encode('X', 'B', '1', '2'); --[[ [15:0] x:B:G:R 4:4:4:4 little endian --]]
	DRM_FORMAT_RGBX4444	= fourcc_encode('R', 'X', '1', '2'); --[[ [15:0] R:G:B:x 4:4:4:4 little endian --]]
	DRM_FORMAT_BGRX4444	= fourcc_encode('B', 'X', '1', '2'); --[[ [15:0] B:G:R:x 4:4:4:4 little endian --]]

	DRM_FORMAT_ARGB4444	= fourcc_encode('A', 'R', '1', '2'); --[[ [15:0] A:R:G:B 4:4:4:4 little endian --]]
	DRM_FORMAT_ABGR4444	= fourcc_encode('A', 'B', '1', '2'); --[[ [15:0] A:B:G:R 4:4:4:4 little endian --]]
	DRM_FORMAT_RGBA4444	= fourcc_encode('R', 'A', '1', '2'); --[[ [15:0] R:G:B:A 4:4:4:4 little endian --]]
	DRM_FORMAT_BGRA4444	= fourcc_encode('B', 'A', '1', '2'); --[[ [15:0] B:G:R:A 4:4:4:4 little endian --]]

	DRM_FORMAT_XRGB1555	= fourcc_encode('X', 'R', '1', '5'); --[[ [15:0] x:R:G:B 1:5:5:5 little endian --]]
	DRM_FORMAT_XBGR1555	= fourcc_encode('X', 'B', '1', '5'); --[[ [15:0] x:B:G:R 1:5:5:5 little endian --]]
	DRM_FORMAT_RGBX5551	= fourcc_encode('R', 'X', '1', '5'); --[[ [15:0] R:G:B:x 5:5:5:1 little endian --]]
	DRM_FORMAT_BGRX5551	= fourcc_encode('B', 'X', '1', '5'); --[[ [15:0] B:G:R:x 5:5:5:1 little endian --]]

	DRM_FORMAT_ARGB1555	= fourcc_encode('A', 'R', '1', '5'); --[[ [15:0] A:R:G:B 1:5:5:5 little endian --]]
	DRM_FORMAT_ABGR1555	= fourcc_encode('A', 'B', '1', '5'); --[[ [15:0] A:B:G:R 1:5:5:5 little endian --]]
	DRM_FORMAT_RGBA5551	= fourcc_encode('R', 'A', '1', '5'); --[[ [15:0] R:G:B:A 5:5:5:1 little endian --]]
	DRM_FORMAT_BGRA5551	= fourcc_encode('B', 'A', '1', '5'); --[[ [15:0] B:G:R:A 5:5:5:1 little endian --]]

	DRM_FORMAT_RGB565	= fourcc_encode('R', 'G', '1', '6'); --[[ [15:0] R:G:B 5:6:5 little endian --]]
	DRM_FORMAT_BGR565	= fourcc_encode('B', 'G', '1', '6'); --[[ [15:0] B:G:R 5:6:5 little endian --]]

--[[ 24 bpp RGB --]]
	DRM_FORMAT_RGB888	= fourcc_encode('R', 'G', '2', '4'); --[[ [23:0] R:G:B little endian --]]
	DRM_FORMAT_BGR888	= fourcc_encode('B', 'G', '2', '4'); --[[ [23:0] B:G:R little endian --]]

--[[ 32 bpp RGB --]]
	DRM_FORMAT_XRGB8888	= fourcc_encode('X', 'R', '2', '4'); --[[ [31:0] x:R:G:B 8:8:8:8 little endian --]]
	DRM_FORMAT_XBGR8888	= fourcc_encode('X', 'B', '2', '4'); --[[ [31:0] x:B:G:R 8:8:8:8 little endian --]]
	DRM_FORMAT_RGBX8888	= fourcc_encode('R', 'X', '2', '4'); --[[ [31:0] R:G:B:x 8:8:8:8 little endian --]]
	DRM_FORMAT_BGRX8888	= fourcc_encode('B', 'X', '2', '4'); --[[ [31:0] B:G:R:x 8:8:8:8 little endian --]]

	DRM_FORMAT_ARGB8888	= fourcc_encode('A', 'R', '2', '4'); --[[ [31:0] A:R:G:B 8:8:8:8 little endian --]]
	DRM_FORMAT_ABGR8888	= fourcc_encode('A', 'B', '2', '4'); --[[ [31:0] A:B:G:R 8:8:8:8 little endian --]]
	DRM_FORMAT_RGBA8888	= fourcc_encode('R', 'A', '2', '4'); --[[ [31:0] R:G:B:A 8:8:8:8 little endian --]]
	DRM_FORMAT_BGRA8888	= fourcc_encode('B', 'A', '2', '4'); --[[ [31:0] B:G:R:A 8:8:8:8 little endian --]]

	DRM_FORMAT_XRGB2101010	= fourcc_encode('X', 'R', '3', '0'); --[[ [31:0] x:R:G:B 2:10:10:10 little endian --]]
	DRM_FORMAT_XBGR2101010	= fourcc_encode('X', 'B', '3', '0'); --[[ [31:0] x:B:G:R 2:10:10:10 little endian --]]
	DRM_FORMAT_RGBX1010102	= fourcc_encode('R', 'X', '3', '0'); --[[ [31:0] R:G:B:x 10:10:10:2 little endian --]]
	DRM_FORMAT_BGRX1010102	= fourcc_encode('B', 'X', '3', '0'); --[[ [31:0] B:G:R:x 10:10:10:2 little endian --]]

	DRM_FORMAT_ARGB2101010	= fourcc_encode('A', 'R', '3', '0'); --[[ [31:0] A:R:G:B 2:10:10:10 little endian --]]
	DRM_FORMAT_ABGR2101010	= fourcc_encode('A', 'B', '3', '0'); --[[ [31:0] A:B:G:R 2:10:10:10 little endian --]]
	DRM_FORMAT_RGBA1010102	= fourcc_encode('R', 'A', '3', '0'); --[[ [31:0] R:G:B:A 10:10:10:2 little endian --]]
	DRM_FORMAT_BGRA1010102	= fourcc_encode('B', 'A', '3', '0'); --[[ [31:0] B:G:R:A 10:10:10:2 little endian --]]

--[[ packed YCbCr --]]
	DRM_FORMAT_YUYV		= fourcc_encode('Y', 'U', 'Y', 'V'); --[[ [31:0] Cr0:Y1:Cb0:Y0 8:8:8:8 little endian --]]
	DRM_FORMAT_YVYU		= fourcc_encode('Y', 'V', 'Y', 'U'); --[[ [31:0] Cb0:Y1:Cr0:Y0 8:8:8:8 little endian --]]
	DRM_FORMAT_UYVY		= fourcc_encode('U', 'Y', 'V', 'Y'); --[[ [31:0] Y1:Cr0:Y0:Cb0 8:8:8:8 little endian --]]
	DRM_FORMAT_VYUY		= fourcc_encode('V', 'Y', 'U', 'Y'); --[[ [31:0] Y1:Cb0:Y0:Cr0 8:8:8:8 little endian --]]

	DRM_FORMAT_AYUV		= fourcc_encode('A', 'Y', 'U', 'V'); --[[ [31:0] A:Y:Cb:Cr 8:8:8:8 little endian --]]

--[[
 * 2 plane YCbCr
 * index 0 = Y plane, [7:0] Y
 * index 1 = Cr:Cb plane, [15:0] Cr:Cb little endian
 * or
 * index 1 = Cb:Cr plane, [15:0] Cb:Cr little endian
 --]]
	DRM_FORMAT_NV12		= fourcc_encode('N', 'V', '1', '2'); --[[ 2x2 subsampled Cr:Cb plane --]]
	DRM_FORMAT_NV21		= fourcc_encode('N', 'V', '2', '1'); --[[ 2x2 subsampled Cb:Cr plane --]]
	DRM_FORMAT_NV16		= fourcc_encode('N', 'V', '1', '6'); --[[ 2x1 subsampled Cr:Cb plane --]]
	DRM_FORMAT_NV61		= fourcc_encode('N', 'V', '6', '1'); --[[ 2x1 subsampled Cb:Cr plane --]]

--[[
 * 3 plane YCbCr
 * index 0: Y plane, [7:0] Y
 * index 1: Cb plane, [7:0] Cb
 * index 2: Cr plane, [7:0] Cr
 * or
 * index 1: Cr plane, [7:0] Cr
 * index 2: Cb plane, [7:0] Cb
 --]]
	DRM_FORMAT_YUV410	= fourcc_encode('Y', 'U', 'V', '9'); --[[ 4x4 subsampled Cb (1); and Cr (2); planes --]]
	DRM_FORMAT_YVU410	= fourcc_encode('Y', 'V', 'U', '9'); --[[ 4x4 subsampled Cr (1); and Cb (2); planes --]]
	DRM_FORMAT_YUV411	= fourcc_encode('Y', 'U', '1', '1'); --[[ 4x1 subsampled Cb (1); and Cr (2); planes --]]
	DRM_FORMAT_YVU411	= fourcc_encode('Y', 'V', '1', '1'); --[[ 4x1 subsampled Cr (1); and Cb (2); planes --]]
	DRM_FORMAT_YUV420	= fourcc_encode('Y', 'U', '1', '2'); --[[ 2x2 subsampled Cb (1); and Cr (2); planes --]]
	DRM_FORMAT_YVU420	= fourcc_encode('Y', 'V', '1', '2'); --[[ 2x2 subsampled Cr (1); and Cb (2); planes --]]
	DRM_FORMAT_YUV422	= fourcc_encode('Y', 'U', '1', '6'); --[[ 2x1 subsampled Cb (1); and Cr (2); planes --]]
	DRM_FORMAT_YVU422	= fourcc_encode('Y', 'V', '1', '6'); --[[ 2x1 subsampled Cr (1); and Cb (2); planes --]]
	DRM_FORMAT_YUV444	= fourcc_encode('Y', 'U', '2', '4'); --[[ non-subsampled Cb (1); and Cr (2); planes --]]
	DRM_FORMAT_YVU444	= fourcc_encode('Y', 'V', '2', '4'); --[[ non-subsampled Cr (1); and Cb (2); planes --]]
}

return exports

