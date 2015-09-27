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
local ppm = require("ppm")
local GraphPort = require("render_simple")
local DRMCard = require("DRMCard")

local function RGB(r,g,b)
	return band(0xFFFFFF, bor(lshift(r, 16), lshift(g, 8), b))
end

local function drawLines(fb)
	local color = RGB(23, 250, 127)

	for i = 1, 400 do
		GraphPort.h_line(fb, 10+i, 10+i, i, color)
	end
end

local card, err = DRMCard();

local fb = card:getDefaultFrameBuffer();
fb.DataPtr = fb:getDataPtr();

print("fb: [bpp, depth, pitch]: ", fb.BitsPerPixel, fb.Depth, fb.Pitch)

local function drawRectangles(fb)
	GraphPort.rect(fb, 200, 200, 320, 240, RGB(230, 34, 127))
end

local function draw()

	drawLines(fb)

	drawRectangles(fb);
end

draw();

ppm.write_PPM_binary("draw_crtc_lines.ppm", fb.DataPtr, fb.Width, fb.Height, fb.Pitch)
-- sleep for a little bit of time
-- just so we can see what's there
-- libc.sleep(3);

