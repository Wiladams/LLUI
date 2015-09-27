local libc = require("libc")
local ffi = require("ffi")

local int = ffi.typeof("int")

--[[
	Write out an image using the binary PPM format (P6)
	This format has R,G,B, so it's 24-bit, NOT 32-bit
	It's fairly big on its own, but will compress nicely using
	any standard compression algorithm.
--]]
local function  write_PPM_binary(filename, bits, width, height, stride)

	local fp = libc.fopen(filename, "wb");
	if fp == nil then return false end;


	-- write out the image header
	libc.fprintf(fp, "P6\n%d %d\n255\n", int(width), int(height));

	-- write the individual pixel values in binary form
	local pixelPtr = ffi.cast("uint8_t *", bits);
	local rgb = ffi.new("uint8_t[3]");

	for row = 0, height-1 do
		for col = 0, width-1 do
			rgb[2] = pixelPtr[(col*4)];
			rgb[1] = pixelPtr[(col*4)+1];
			rgb[0] = pixelPtr[(col*4)+2];
			libc.fwrite(rgb, 3, 1, fp);
			--fwrite(&pixelPtr[col], 3, 1, fp);
		end
		pixelPtr = pixelPtr + stride;
	end

	libc.fclose(fp);

	return true;
end

local exports = {
	write_PPM_binary = write_PPM_binary;	
}

return exports