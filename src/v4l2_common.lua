local ffi = require("ffi")
local bit = require("bit")
local lshift, rshift, band, bor = bit.lshift, bit.rshift, bit.band, bit.bor


-- Selection interface definitions


local exports = {
	V4L2_SEL_TGT_CROP		=0x0000;		-- Current cropping area
	V4L2_SEL_TGT_CROP_DEFAULT	=0x0001;		-- Default cropping area
	V4L2_SEL_TGT_CROP_BOUNDS	=0x0002;		-- Cropping bounds
	V4L2_SEL_TGT_COMPOSE		=0x0100;		-- Current composing area
	V4L2_SEL_TGT_COMPOSE_DEFAULT	=0x0101;	-- Default composing area
	V4L2_SEL_TGT_COMPOSE_BOUNDS	=0x0102;	-- Composing bounds
	V4L2_SEL_TGT_COMPOSE_PADDED	=0x0103;	-- Current composing area plus all padding pixels



-- Selection flags */
	V4L2_SEL_FLAG_GE		=lshift(1, 0);
	V4L2_SEL_FLAG_LE		=lshift(1, 1);
	V4L2_SEL_FLAG_KEEP_CONFIG	=lshift(1, 2);
}

return exports

