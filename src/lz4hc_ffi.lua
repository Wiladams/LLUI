local ffi = require("ffi")

local Lib_lz4 = ffi.load("lz4")

-- Simple block compression
ffi.cdef[[
int LZ4_compress_HC (const char* src, char* dst, int srcSize, int maxDstSize, int compressionLevel);
]]

ffi.cdef[[
int LZ4_sizeofStateHC();
int LZ4_compress_HC_extStateHC(void* state, const char* src, char* dst, int srcSize, int maxDstSize, int compressionLevel);
]]

-- streaming interfaces
ffi.cdef[[
static const int LZ4_STREAMHCSIZE       = 262192;
static const int LZ4_STREAMHCSIZE_SIZET = (LZ4_STREAMHCSIZE / sizeof(size_t));

typedef struct { 
  size_t table[LZ4_STREAMHCSIZE_SIZET]; 
} LZ4_streamHC_t;



LZ4_streamHC_t* LZ4_createStreamHC();
int             LZ4_freeStreamHC (LZ4_streamHC_t* streamHCPtr);


void LZ4_resetStreamHC (LZ4_streamHC_t* streamHCPtr, int compressionLevel);
int  LZ4_loadDictHC (LZ4_streamHC_t* streamHCPtr, const char* dictionary, int dictSize);

int LZ4_compress_HC_continue (LZ4_streamHC_t* streamHCPtr, const char* src, char* dst, int srcSize, int maxDstSize);

int LZ4_saveDictHC (LZ4_streamHC_t* streamHCPtr, char* safeBuffer, int maxDictSize);
]]

local exports = {
    -- library reference
    Lib_lz4hc = Lib_lz4;

    -- library types
    LZ4_streamHC_t = ffi.typeof("LZ4_streamHC_t");

    -- library functions
    LZ4_compress_HC = Lib_lz4.LZ4_compress_HC;
    LZ4_sizeofStateHC = Lib_lz4.LZ4_sizeofStateHC;
    LZ4_compress_HC_extStateHC = Lib_lz4.LZ4_compress_HC_extStateHC;
    LZ4_createStreamHC = Lib_lz4.LZ4_createStreamHC;
    LZ4_freeStreamHC = Lib_lz4.LZ4_freeStreamHC;
    LZ4_resetStreamHC = Lib_lz4.LZ4_resetStreamHC;
    LZ4_loadDictHC = Lib_lz4.LZ4_loadDictHC;
    LZ4_compress_HC_continue = Lib_lz4.LZ4_compress_HC_continue;
    LZ4_saveDictHC = Lib_lz4.LZ4_saveDictHC;
}

setmetatable(exports, {
    __call = function(self, ...)
        for k,v in pairs(exports) do 
            _G[k] = v;
        end
        
        return self
    end,
})

return exports
