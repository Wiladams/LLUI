-- media_utils.lua
local bit = require("bit")
local band, bor, lshift, rshift = bit.band, bit.bor, bit.lshift, bit.rshift

--  Four-character-code (FOURCC)
local B = string.byte;
local function fourcc_encode(a, b, c, d)

	-- return a fourcc encoding of the given
	-- components
	return bor(B(a) ,
		 lshift(B(b) , 8) ,
		 lshift(B(c) , 16) ,
		 lshift(B(d) , 24))
end

local function fourcc_decode(cc)
	local C = string.char;


	return C(band(cc,0xff)), 
		C(band(rshift(cc, 8),0xff)), 
		C(band(rshift(cc, 16),0xff)), 
		C(band(rshift(cc, 24),0xff))
end

local exports = {
	fourcc_encode = fourcc_encode;
	fourcc_decode = fourcc_decode;
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
