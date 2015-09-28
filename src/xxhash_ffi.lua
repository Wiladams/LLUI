local ffi = require("ffi")

local Lib_lz4 = ffi.load("lz4")

ffi.cdef[[
typedef enum { 
    XXH_OK=0, 
    XXH_ERROR 
} XXH_errorcode;
]]

ffi.cdef[[
//  Simple Hash Functions
unsigned int       LZ4_XXH32 (const void* input, size_t length, unsigned seed);
unsigned long long LZ4_XXH64 (const void* input, size_t length, unsigned long long seed);
]]

ffi.cdef[[
//  Advanced Hash Functions
typedef struct { 
    long long ll[ 6]; 
} XXH32_state_t;

typedef struct { 
    long long ll[11]; 
} XXH64_state_t;


XXH32_state_t* LZ4_XXH32_createState(void);
XXH_errorcode  LZ4_XXH32_freeState(XXH32_state_t* statePtr);

XXH64_state_t* LZ4_XXH64_createState(void);
XXH_errorcode  LZ4_XXH64_freeState(XXH64_state_t* statePtr);


XXH_errorcode LZ4_XXH32_reset  (XXH32_state_t* statePtr, unsigned seed);
XXH_errorcode LZ4_XXH32_update (XXH32_state_t* statePtr, const void* input, size_t length);
unsigned int  LZ4_XXH32_digest (const XXH32_state_t* statePtr);

XXH_errorcode      LZ4_XXH64_reset  (XXH64_state_t* statePtr, unsigned long long seed);
XXH_errorcode      LZ4_XXH64_update (XXH64_state_t* statePtr, const void* input, size_t length);
unsigned long long LZ4_XXH64_digest (const XXH64_state_t* statePtr);
]]



local exports = {
    Lib_XXHash =  Lib_lz4;

    -- library types
    XXH32_state_t = ffi.typeof("XXH32_state_t");
    XXH64_state_t = ffi.typeof("XXH64_state_t");

    -- library functions
    LZ4_XXH32 = Lib_lz4.LZ4_XXH32;
    LZ4_XXH32_createState = Lib_lz4.LZ4_XXH32_createState;
    LZ4_XXH32_freeState = Lib_lz4.LZ4_XXH32_freeState;
    LZ4_XXH32_reset = Lib_lz4.LZ4_XXH32_reset;
    LZ4_XXH32_update = Lib_lz4.LZ4_XXH32_update;
    LZ4_XXH32_digest = Lib_lz4.LZ4_XXH32_digest;

    LZ4_XXH64 = Lib_lz4.LZ4_XXH64;
    LZ4_XXH64_createState = Lib_lz4.LZ4_XXH64_createState;
    LZ4_XXH64_freeState = Lib_lz4.LZ4_XXH64_freeState;
    LZ4_XXH64_reset = Lib_lz4.LZ4_XXH64_reset;
    LZ4_XXH64_update = Lib_lz4.LZ4_XXH64_update;
    LZ4_XXH64_digest = Lib_lz4.LZ4_XXH64_digest;

}

setmetatable(exports, {
    __call = function(self, ...)
        for k,v in pairs(exports) do 
            _G[k] = v
        end

        return self;
    end,
})

return exports
