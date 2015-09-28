-- xxhash.lua

local xxhash_ffi = require("xxhash_ffi")

local xxHasher32 = {}

function xxHasher32.init(self, handle)
	local obj = {
		Handle = handle;
	}
	setmetatable(obj, xxHasher32_mt);

	return obj;
end

function xxHasher32.new(self, seed)
	seed = seed or 0
	local state = xxhash_ffi.LZ4_XXH32_createState();
	if nil == state then
		return nil;
	end

	ffi.gc(state, xxhash_ffi.LZ4_XXH32_freeState);
	xxhash_ffi.LZ4_XXH32_reset(seed);

	return self:init(state);
end

function xxHasher32.update(self, data, len)
	errcode = LZ4_XXH32_update(self.Handle, data, len)

	return errcode;
end

function xxHasher32.finish(self)
	local digest = xxhash_ffi.LZ4_XXH32_digest(self.handle)
	self.digest = digest;
end


local function digest32(str, seed)
    seed = seed or 0
    return tonumber(Lib_lz4.LZ4_XXH32(str, #str, seed));
end

local function digest64(str, seed)
    seed = seed or 0
    return Lib_lz4.LZ4_XXH64(str, #str, seed);
end


local exports = {
	xxHasher32 = xxHasher32;

	    -- local functions
    digest32 = digest32;
    digest64 = digest64;

}

return exports
