
local ffi = require("ffi")

local Lib_lz4 = ffi.load("lz4")


ffi.cdef[[
typedef size_t LZ4F_errorCode_t;

unsigned    LZ4F_isError(LZ4F_errorCode_t code);
const char* LZ4F_getErrorName(LZ4F_errorCode_t code);   /* return error code string; useful for debugging */
]]


ffi.cdef[[
typedef enum {
    LZ4F_default=0,
    LZ4F_max64KB=4,
    LZ4F_max256KB=5,
    LZ4F_max1MB=6,
    LZ4F_max4MB=7
} LZ4F_blockSizeID_t;

typedef enum {
    LZ4F_blockLinked=0,
    LZ4F_blockIndependent
} LZ4F_blockMode_t;

typedef enum {
    LZ4F_noContentChecksum=0,
    LZ4F_contentChecksumEnabled
} LZ4F_contentChecksum_t;

typedef enum {
    LZ4F_frame=0,
    LZ4F_skippableFrame
} LZ4F_frameType_t;


typedef struct {
  LZ4F_blockSizeID_t     blockSizeID;           /* max64KB, max256KB, max1MB, max4MB ; 0 == default */
  LZ4F_blockMode_t       blockMode;             /* blockLinked, blockIndependent ; 0 == default */
  LZ4F_contentChecksum_t contentChecksumFlag;   /* noContentChecksum, contentChecksumEnabled ; 0 == default  */
  LZ4F_frameType_t       frameType;             /* LZ4F_frame, skippableFrame ; 0 == default */
  unsigned long long     contentSize;           /* Size of uncompressed (original) content ; 0 == unknown */
  unsigned               reserved[2];           /* must be zero for forward compatibility */
} LZ4F_frameInfo_t;

typedef struct {
  LZ4F_frameInfo_t frameInfo;
  int      compressionLevel;       /* 0 == default (fast mode); values above 16 count as 16; values below 0 count as 0 */
  unsigned autoFlush;              /* 1 == always flush (reduce need for tmp buffer) */
  unsigned reserved[4];            /* must be zero for forward compatibility */
} LZ4F_preferences_t;
]]

ffi.cdef[[
/***********************************
 * Simple compression function
 * *********************************/
size_t LZ4F_compressFrameBound(size_t srcSize, const LZ4F_preferences_t* preferencesPtr);
size_t LZ4F_compressFrame(void* dstBuffer, size_t dstMaxSize, const void* srcBuffer, size_t srcSize, const LZ4F_preferences_t* preferencesPtr);
]]


ffi.cdef[[
/**********************************
*  Advanced compression functions
**********************************/
typedef struct LZ4F_cctx_s* LZ4F_compressionContext_t;   /* must be aligned on 8-bytes */

typedef struct {
  unsigned stableSrc;    /* 1 == src content will remain available on future calls to LZ4F_compress(); avoid saving src content within tmp buffer as future dictionary */
  unsigned reserved[3];
} LZ4F_compressOptions_t;

/* Resource Management */
LZ4F_errorCode_t LZ4F_createCompressionContext(LZ4F_compressionContext_t* cctxPtr, unsigned version);
LZ4F_errorCode_t LZ4F_freeCompressionContext(LZ4F_compressionContext_t cctx);



/* Compression */
size_t LZ4F_compressBegin(LZ4F_compressionContext_t cctx, void* dstBuffer, size_t dstMaxSize, const LZ4F_preferences_t* prefsPtr);
size_t LZ4F_compressBound(size_t srcSize, const LZ4F_preferences_t* prefsPtr);
size_t LZ4F_compressUpdate(LZ4F_compressionContext_t cctx, void* dstBuffer, size_t dstMaxSize, const void* srcBuffer, size_t srcSize, const LZ4F_compressOptions_t* cOptPtr);
size_t LZ4F_flush(LZ4F_compressionContext_t cctx, void* dstBuffer, size_t dstMaxSize, const LZ4F_compressOptions_t* cOptPtr);
size_t LZ4F_compressEnd(LZ4F_compressionContext_t cctx, void* dstBuffer, size_t dstMaxSize, const LZ4F_compressOptions_t* cOptPtr);
]]

ffi.cdef[[
/***********************************
*  Decompression functions
***********************************/

typedef struct LZ4F_dctx_s* LZ4F_decompressionContext_t;   /* must be aligned on 8-bytes */

typedef struct {
  unsigned stableDst;       /* guarantee that decompressed data will still be there on next function calls (avoid storage into tmp buffers) */
  unsigned reserved[3];
} LZ4F_decompressOptions_t;


/* Resource management */

LZ4F_errorCode_t LZ4F_createDecompressionContext(LZ4F_decompressionContext_t* dctxPtr, unsigned version);
LZ4F_errorCode_t LZ4F_freeDecompressionContext(LZ4F_decompressionContext_t dctx);



/* Decompression */

size_t LZ4F_getFrameInfo(LZ4F_decompressionContext_t dctx,
                         LZ4F_frameInfo_t* frameInfoPtr,
                         const void* srcBuffer, size_t* srcSizePtr);


size_t LZ4F_decompress(LZ4F_decompressionContext_t dctx,
                       void* dstBuffer, size_t* dstSizePtr,
                       const void* srcBuffer, size_t* srcSizePtr,
                       const LZ4F_decompressOptions_t* dOptPtr);
]]

local LZ4F_VERSION = 100


local function getErrorString(errcode)
    local errStr = Lib_lz4.LZ4F_getErrorName(errcode);
    if errStr == nil then
        return "UNKNOWN ERROR"
    end

    return ffi.string(errStr);
end

local exports = {
    -- constants
    LZ4F_VERSION = LZ4F_VERSION;

    -- enums
    -- LZ4F_blockSizeID_t
    LZ4F_default = ffi.C.LZ4F_default;
    LZ4F_max64KB = ffi.C.LZ4F_max64KB;
    LZ4F_max256KB = ffi.C.LZ4F_max256KB;
    LZ4F_max1MB = ffi.C.LZ4F_max1MB;
    LZ4F_max4MB = ffi.C.LZ4F_max4MB;

    -- LZ4F_blockMode_t
    LZ4F_blockLinked = ffi.C.LZ4F_blockLinked;
    LZ4F_blockIndependent = ffi.C.LZ4F_blockIndependent;

    -- LZ4F_contentChecksum_t
    LZ4F_noContentChecksum = ffi.C.LZ4F_noContentChecksum;
    LZ4F_contentChecksumEnabled = ffi.C.LZ4F_contentChecksumEnabled;

    -- LZ4F_frameType_t
    LZ4F_frame = ffi.C.LZ4F_frame;
    LZ4F_skippableFrame = ffi.C.LZ4F_skippableFrame;


    -- library types
    LZ4F_preferences_t = ffi.typeof("LZ4F_preferences_t");
    LZ4F_decompressionContext_t = ffi.typeof("LZ4F_decompressionContext_t");
    LZ4F_compressOptions_t = ffi.typeof("LZ4F_compressOptions_t");
    LZ4F_decompressOptions_t = ffi.typeof("LZ4F_decompressOptions_t");

    -- library functions
    LZ4F_isError = Lib_lz4.LZ4F_isError;
    LZ4F_getErrorName = Lib_lz4.LZ4F_getErrorName;

    LZ4F_compressFrameBound = Lib_lz4.LZ4F_compressFrameBound;
    LZ4F_compressFrame = Lib_lz4.LZ4F_compressFrame;
    LZ4F_createCompressionContext = Lib_lz4.LZ4F_createCompressionContext;
    LZ4F_freeCompressionContext = Lib_lz4.LZ4F_freeCompressionContext;
    LZ4F_compressBegin = Lib_lz4.LZ4F_compressBegin;
    LZ4F_compressBound = Lib_lz4.LZ4F_compressBound;
    LZ4F_compressUpdate = Lib_lz4.LZ4F_compressUpdate;
    LZ4F_flush = Lib_lz4.LZ4F_flush;
    LZ4F_compressEnd = Lib_lz4.LZ4F_compressEnd;

    LZ4F_createDecompressionContext = Lib_lz4.LZ4F_createDecompressionContext;
    LZ4F_freeDecompressionContext = Lib_lz4.LZ4F_freeDecompressionContext;

    LZ4F_getFrameInfo = Lib_lz4.LZ4F_getFrameInfo;
    LZ4F_decompress = Lib_lz4.LZ4F_decompress;

    -- local functions
    LZ4f_strerror = getErrorString;
}

setmetatable(exports, {
    __call = function(self)
        for k,v in pairs(exports) do
            _G[k] = v;
        end
        
        return self;
    end,
})

return exports