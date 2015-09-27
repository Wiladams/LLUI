local ffi = require("ffi")

local function h_line(fb, x,y,count,color)
	local startOffset = (y*fb.Pitch)+(x*(fb.BitsPerPixel/8));
	local ptr = ffi.cast("uint8_t *", fb.DataPtr)+ startOffset;
	for i=0, count-1 do
		ffi.cast("uint32_t *", ptr)[i] = color;
	end
end

local function rect(fb, x1,y1, width, height, color)
	for row=y1, y1+height-1 do
		h_line(fb, x1, row, width, color);
	end
end

local exports = {
	h_line = h_line;
	rect = rect;
}

setmetatable(exports, {
	__call = function(self, ...)
		for k,v in pairs(exports) do
			_G[k] = v;
		end

		return self;
	end,
})

return exports