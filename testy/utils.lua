-- utils.lua
local ffi = require("ffi")
local bit = require("bit")
local band, bor, lshift, rshift, bxor = bit.band, bit.bor, bit.lshift, bit.rshift, bit.bxor

local pixman = require("pixman")
local pixlib = pixman.Lib_pixman
local libc = require("libc")()

local int = ffi.typeof("int")
local ENUM = ffi.C
local floor = math.floor;


local function ARRAY_LENGTH(arr)
	return ffi.sizeof(arr)/ffi.sizeof(arr[0])
end

local function color8_to_color16 (color8, color16)

    color16.alpha = rshift(band(color8, 0xff000000), 24);
    color16.red =   rshift(band(color8, 0x00ff0000), 16);
    color16.green = rshift(band(color8, 0x0000ff00), 8);
    color16.blue =  rshift(band(color8, 0x000000ff), 0);

    color16.alpha = bor(color16.alpha, lshift(color16.alpha, 8));
    color16.red   = bor(color16.red, lshift(color16.red, 8));
    color16.blue  = bor(color16.blue, lshift(color16.blue, 8));
    color16.green = bor(color16.green, lshift(color16.green, 8));
end

local function draw_checkerboard (image,check_size, color1, color2)

    local check1 = ffi.new("pixman_color_t")
    local check2 = ffi.new("pixman_color_t")
    color8_to_color16 (color1, check1);
    color8_to_color16 (color2, check2);
    
    local c1 = pixlib.pixman_image_create_solid_fill (check1);
    local c2 = pixlib.pixman_image_create_solid_fill (check2);

    local n_checks_x = floor((pixlib.pixman_image_get_width (image) + check_size - 1) / check_size);
    local n_checks_y = floor((pixlib.pixman_image_get_height (image) + check_size - 1) / check_size);

    for j = 0, n_checks_y-1 do
		for i = 0, n_checks_x-1 do
	
	    	local src = nil;

	    	if band(bxor(i, j), 1) > 0 then
				src = c1;
	    	else
				src = c2;
			end

	    	pixlib.pixman_image_composite32 (ENUM.PIXMAN_OP_SRC, src, nil, image,
				0, 0, 0, 0,
				i * check_size, j * check_size,
				check_size, check_size);
		end
    end
end


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
			rgb[0] = pixelPtr[(col*4)];
			rgb[1] = pixelPtr[(col*4)+1];
			rgb[2] = pixelPtr[(col*4)+2];
			libc.fwrite(rgb, 3, 1, fp);
			--fwrite(&pixelPtr[col], 3, 1, fp);
		end
		pixelPtr = pixelPtr + stride;
	end

	libc.fclose(fp);

	return true;
end

local function print_image(img)
	local width = tonumber(pixlib.pixman_image_get_width(img));
	local height = tonumber(pixlib.pixman_image_get_height(img));
	local stride = tonumber(pixlib.pixman_image_get_stride(img));
	local bits = pixlib.pixman_image_get_data(img);

	print("=+ showing image +=")
	print(string.format("  Size: %dx%d", width, height))
	print(string.format("Stride: %d", stride));
	print(string.format(" Depth: %d", pixlib.pixman_image_get_depth(img)));
	print(string.format("Format: %#x", tonumber(pixlib.pixman_image_get_format(img))));
	print(string.format("  Data: %#x", tonumber(ffi.cast("intptr_t",pixlib.pixman_image_get_data(img)))));

end

-- write the image out as a ppm file
local function save_image(img, filename)
	local width = tonumber(pixlib.pixman_image_get_width(img));
	local height = tonumber(pixlib.pixman_image_get_height(img));
	local stride = tonumber(pixlib.pixman_image_get_stride(img));
	local bits = pixlib.pixman_image_get_data(img);

	write_PPM_binary(filename, bits, width, height, stride)
end


local exports = {
	ARRAY_LENGTH = ARRAY_LENGTH;
	color8_to_color16 = color8_to_color16;
	draw_checkerboard = draw_checkerboard;
	print_image = print_image;
	save_image = save_image;
}
setmetatable(exports, {
	__call = function(self, tbl)
		tbl = tbl or _G;
		for k,v in pairs(self) do
			tbl[k] = v;
		end

		return self;
	end,
})

return exports
