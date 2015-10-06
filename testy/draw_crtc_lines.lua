--[[
	Draw on the frame buffer of the current default crtc

	The way to go about drawing to the current screen, without changing modes is:
		Create a card
			From that card, get the first connection that's actually connected to something
				From there, get the encoder it's using
					From there, get the crt controller associated with the encoder
						From there, get the framebuffer associated with the controller
							From there, we have the width, height, pitch, and data ptr
		
		So, that's enough to do some drawing
--]]

package.path = package.path..";../src/?.lua"

local ffi = require("ffi")
local bit = require("bit")
local bor, band, lshift, rshift = bit.bor, bit.band, bit.lshift, bit.rshift

local libc = require("libc")
local utils = require("utils")
local fun = require("fun")
local ppm = require("ppm")
local GraphPort = require("render_simple")
local DRMCard = require("DRMCard")
local DRMEnvironment = require("DRMEnvironment")


local function getCard(cardnum)
	return fun.nth(cardnum, DRMEnvironment:cards())
end


local function RGB(r,g,b)
	return band(0xFFFFFF, bor(lshift(r, 16), lshift(g, 8), b))
end

local function drawLines(fb)
	local color = RGB(23, 250, 127)

	for i = 1, 180 do
		GraphPort.h_line(fb, 10+i, 10+i, i, color)
	end
end



local function drawRectangles(fb)
	GraphPort.rect(fb, 20, 20, 280, 200, RGB(230, 34, 127))
end

local function draw(fb)
	drawRectangles(fb);
	drawLines(fb)
end

local function main(argc, argv)
	local cardnum = tonumber(argv[1])
	cardnum = cardnum or 1

	
	local card = getCard(cardnum)
	assert(card, "could not create card")

	local fb = card:getDefaultFrameBuffer();
	fb.DataPtr = fb:getDataPtr();

	print("fb: [bpp, depth, pitch]: ", fb.BitsPerPixel, fb.Depth, fb.Pitch)

	draw(fb);

	ppm.write_PPM_binary("draw_crtc_lines.ppm", fb.DataPtr, fb.Width, fb.Height, fb.Pitch)
end

main(#arg, arg)
