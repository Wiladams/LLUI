
local ffi = require("ffi")

local Lib_lz4 = ffi.load("lz4")


ffi.cdef[[
int LZ4_versionNumber ();
]]

ffi.cdef[[
int LZ4_compress_default(const char* source, char* dest, int sourceSize, int maxDestSize);
int LZ4_decompress_safe (const char* source, char* dest, int compressedSize, int maxDecompressedSize);
int LZ4_compressBound(int inputSize);
]]

ffi.cdef[[
int LZ4_compress_fast (const char* source, char* dest, int sourceSize, int maxDestSize, int acceleration);
int LZ4_sizeofState();
int LZ4_compress_fast_extState (void* state, const char* source, char* dest, int inputSize, int maxDestSize, int acceleration);
int LZ4_compress_destSize (const char* source, char* dest, int* sourceSizePtr, int targetDestSize);
int LZ4_decompress_fast (const char* source, char* dest, int originalSize);
int LZ4_decompress_safe_partial (const char* source, char* dest, int compressedSize, int targetOutputSize, int maxDecompressedSize);
]]


ffi.cdef[[

//  Tuning parameter
static const int LZ4_MEMORY_USAGE = 14;
static const int LZ4_STREAMSIZE_U64 = ((1 << (LZ4_MEMORY_USAGE-3)) + 4);
static const int LZ4_STREAMSIZE     = (LZ4_STREAMSIZE_U64 * sizeof(long long));

typedef struct { 
    long long table[LZ4_STREAMSIZE_U64]; 
} LZ4_stream_t;

void LZ4_resetStream (LZ4_stream_t* streamPtr);

LZ4_stream_t* LZ4_createStream();
int LZ4_freeStream (LZ4_stream_t* streamPtr);
int LZ4_loadDict (LZ4_stream_t* streamPtr, const char* dictionary, int dictSize);
int LZ4_compress_fast_continue (LZ4_stream_t* streamPtr, const char* src, char* dst, int srcSize, int maxDstSize, int acceleration);
int LZ4_saveDict (LZ4_stream_t* streamPtr, char* safeBuffer, int dictSize);
]]


ffi.cdef[[
static const int LZ4_STREAMDECODESIZE_U64  = 4;
static const int LZ4_STREAMDECODESIZE  =   (LZ4_STREAMDECODESIZE_U64 * sizeof(unsigned long long));

typedef struct { 
    unsigned long long table[LZ4_STREAMDECODESIZE_U64]; 
} LZ4_streamDecode_t;


LZ4_streamDecode_t* LZ4_createStreamDecode();
int LZ4_freeStreamDecode (LZ4_streamDecode_t* LZ4_stream);
int LZ4_setStreamDecode (LZ4_streamDecode_t* LZ4_streamDecode, const char* dictionary, int dictSize);
int LZ4_decompress_safe_continue (LZ4_streamDecode_t* LZ4_streamDecode, const char* source, char* dest, int compressedSize, int maxDecompressedSize);
int LZ4_decompress_fast_continue (LZ4_streamDecode_t* LZ4_streamDecode, const char* source, char* dest, int originalSize);
]]

ffi.cdef[[
int LZ4_decompress_safe_usingDict (const char* source, char* dest, int compressedSize, int maxDecompressedSize, const char* dictStart, int dictSize);
int LZ4_decompress_fast_usingDict (const char* source, char* dest, int originalSize, const char* dictStart, int dictSize);
]]

-- Version this binding was originally built against
local LZ4_VERSION_MAJOR    = 1    -- for breaking interface changes  
local LZ4_VERSION_MINOR    = 7    -- for new (non-breaking) interface capabilities 
local LZ4_VERSION_RELEASE  = 1    -- for tweaks, bug-fixes, or development 
local LZ4_VERSION_NUMBER = (LZ4_VERSION_MAJOR *100*100 + LZ4_VERSION_MINOR *100 + LZ4_VERSION_RELEASE)


local LZ4_MAX_INPUT_SIZE        = 0x7E000000   -- 2 113 929 216 bytes

local function  LZ4_COMPRESSBOUND(isize)
    if isize > LZ4_MAX_INPUT_SIZE then
        return 0;
    end

    return   math.floor(isize + ((isize)/255) + 16)
end

local function getVersion()
    local ver = Lib_lz4.LZ4_versionNumber();
    local release = ver % 100;
    local minor = ((ver - release) % (100*100))/100;
    local major = (ver - minor*100 - release) / (100*100) ;
    
    return {major = major, minor = minor, release = release}
end


local exports = {
    Lib_lz4 = Lib_lz4;

    -- constants
    -- These are the version numbers the ffi interface
    -- was originally built for
    LZ4_VERSION_MAJOR = LZ4_VERSION_MAJOR;
    LZ4_VERSION_MINOR = LZ4_VERSION_MINOR;
    LZ4_VERSION_RELEASE = LZ4_VERSION_RELEASE;
    
    -- local functions
    LZ4_Version = getVersion;
    LZ4_COMPRESSBOUND = LZ4_COMPRESSBOUND;

    -- library functions
    LZ4_versionNumber = Lib_lz4.LZ4_versionNumber;
    LZ4_createStreamDecode = Lib_lz4.LZ4_createStreamDecode;
    LZ4_decompress_safe_continue = Lib_lz4.LZ4_decompress_safe_continue;
}

setmetatable(exports, {
    __call = function(self)
        for k,v in pairs(exports) do
            _G[k] = v;
        end
        
        return self
    end,
})

return exports
