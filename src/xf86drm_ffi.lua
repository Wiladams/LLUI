--xf86drm.lua

local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor

local drm = require("drm")
local Lib_drm = drm.Lib_drm;
local stat = require("stat")()


ffi.cdef[[
typedef uint32_t gid_t;
typedef uint32_t mode_t;
]]

--[[
DRM_IOCTL_NR(n)		_IOC_NR(n)
DRM_IOC_VOID		_IOC_NONE
DRM_IOC_READ		_IOC_READ
DRM_IOC_WRITE		_IOC_WRITE
DRM_IOC_READWRITE	_IOC_READ|_IOC_WRITE
DRM_IOC(dir, group, nr, size) _IOC(dir, group, nr, size)
--]]




ffi.cdef[[
typedef unsigned int  drmSize,     *drmSizePtr;	    /**< For mapped regions */
typedef void          *drmAddress, **drmAddressPtr; /**< For mapped regions */
]]



ffi.cdef[[
typedef struct _drmServerInfo {
  int (*debug_print)(const char *format, va_list ap);
  int (*load_module)(const char *name);
  void (*get_perms)(gid_t *, mode_t *);
} drmServerInfo, *drmServerInfoPtr;

typedef struct drmHashEntry {
    int      fd;
    void     (*f)(int, void *, void *);
    void     *tagTable;
} drmHashEntry;
]]

ffi.cdef[[
extern int drmIoctl(int fd, unsigned long request, void *arg);
extern void *drmGetHashTable(void);
extern drmHashEntry *drmGetEntry(int fd);
]]

ffi.cdef[[
/**
 * Driver version information.
 *
 * \sa drmGetVersion() and drmSetVersion().
 */
typedef struct _drmVersion {
    int     version_major;        /**< Major version */
    int     version_minor;        /**< Minor version */
    int     version_patchlevel;   /**< Patch level */
    int     name_len; 	          /**< Length of name buffer */
    char    *name;	          /**< Name of driver */
    int     date_len;             /**< Length of date buffer */
    char    *date;                /**< User-space buffer to hold date */
    int     desc_len;	          /**< Length of desc buffer */
    char    *desc;                /**< User-space buffer to hold desc */
} drmVersion, *drmVersionPtr;
]]

local drmVersion_mt = {
	__tostring = function(self)
		return string.format([[
       Version: %d.%d.%d
          Name: %s
          Date: %s
   Description: %s
]],
	self.version_major,
	self.version_minor,
	self.version_patchlevel,
	ffi.string(self.name, self.name_len),
	ffi.string(self.date, self.date_len),
	ffi.string(self.desc, self.desc_len)
	)
	end,

	__index = {
		toLua = function(self)
			local tbl = {
        Version = string.format("%d.%d.%d", self.version_major, self.version_minor, self.version_patchlevel);
        Name = ffi.string(self.name, self.name_len);
        Date = ffi.string(self.data, self.date_len);
        Description = ffi.string(self.desc, self.desc_len);
      }

			return tbl;
		end,
	},
}
ffi.metatype(ffi.typeof("drmVersion"), drmVersion_mt)

ffi.cdef[[
typedef struct _drmStats {
    unsigned long count;	     /**< Number of data */
    struct {
	unsigned long value;	     /**< Value from kernel */
	const char    *long_format;  /**< Suggested format for long_name */
	const char    *long_name;    /**< Long name for value */
	const char    *rate_format;  /**< Suggested format for rate_name */
	const char    *rate_name;    /**< Short name for value per second */
	int           isvalue;       /**< True if value (vs. counter) */
	const char    *mult_names;   /**< Multiplier names (e.g., "KGM") */
	int           mult;          /**< Multiplier value (e.g., 1024) */
	int           verbose;       /**< Suggest only in verbose output */
    } data[15];
} drmStatsT;
]]

ffi.cdef[[
				/* All of these enums *MUST* match with the
                                   kernel implementation -- so do *NOT*
                                   change them!  (The drmlib implementation
                                   will just copy the flags instead of
                                   translating them.) */
typedef enum {
    DRM_FRAME_BUFFER    = 0,      /**< WC, no caching, no core dump */
    DRM_REGISTERS       = 1,      /**< no caching, no core dump */
    DRM_SHM             = 2,      /**< shared, cached */
    DRM_AGP             = 3,	  /**< AGP/GART */
    DRM_SCATTER_GATHER  = 4,	  /**< PCI scatter/gather */
    DRM_CONSISTENT      = 5	  /**< PCI consistent */
} drmMapType;

typedef enum {
    DRM_RESTRICTED      = 0x0001, /**< Cannot be mapped to client-virtual */
    DRM_READ_ONLY       = 0x0002, /**< Read-only in client-virtual */
    DRM_LOCKED          = 0x0004, /**< Physical pages locked */
    DRM_KERNEL          = 0x0008, /**< Kernel requires access */
    DRM_WRITE_COMBINING = 0x0010, /**< Use write-combining, if available */
    DRM_CONTAINS_LOCK   = 0x0020, /**< SHM page that contains lock */
    DRM_REMOVABLE	= 0x0040  /**< Removable mapping */
} drmMapFlags;
]]

ffi.cdef[[
/**
 * \warning These values *MUST* match drm.h
 */
typedef enum {
    /** \name Flags for DMA buffer dispatch */
    /*@{*/
    DRM_DMA_BLOCK        = 0x01, /**< 
				  * Block until buffer dispatched.
				  * 
				  * \note the buffer may not yet have been
				  * processed by the hardware -- getting a
				  * hardware lock with the hardware quiescent
				  * will ensure that the buffer has been
				  * processed.
				  */
    DRM_DMA_WHILE_LOCKED = 0x02, /**< Dispatch while lock held */
    DRM_DMA_PRIORITY     = 0x04, /**< High priority dispatch */
    /*@}*/

    /** \name Flags for DMA buffer request */
    /*@{*/
    DRM_DMA_WAIT         = 0x10, /**< Wait for free buffers */
    DRM_DMA_SMALLER_OK   = 0x20, /**< Smaller-than-requested buffers OK */
    DRM_DMA_LARGER_OK    = 0x40  /**< Larger-than-requested buffers OK */
    /*@}*/
} drmDMAFlags;

typedef enum {
    DRM_PAGE_ALIGN       = 0x01,
    DRM_AGP_BUFFER       = 0x02,
    DRM_SG_BUFFER        = 0x04,
    DRM_FB_BUFFER        = 0x08,
    DRM_PCI_BUFFER_RO    = 0x10
} drmBufDescFlags;

typedef enum {
    DRM_LOCK_READY      = 0x01, /**< Wait until hardware is ready for DMA */
    DRM_LOCK_QUIESCENT  = 0x02, /**< Wait until hardware quiescent */
    DRM_LOCK_FLUSH      = 0x04, /**< Flush this context's DMA queue first */
    DRM_LOCK_FLUSH_ALL  = 0x08, /**< Flush all DMA queues first */
				/* These *HALT* flags aren't supported yet
                                   -- they will be used to support the
                                   full-screen DGA-like mode. */
    DRM_HALT_ALL_QUEUES = 0x10, /**< Halt all current and future queues */
    DRM_HALT_CUR_QUEUES = 0x20  /**< Halt all current queues */
} drmLockFlags;

typedef enum {
    DRM_CONTEXT_PRESERVED = 0x01, /**< This context is preserved and
				     never swapped. */
    DRM_CONTEXT_2DONLY    = 0x02  /**< This context is for 2D rendering only. */
} drm_context_tFlags, *drm_context_tFlagsPtr;
]]

ffi.cdef[[
typedef struct _drmBufDesc {
    int              count;	  /**< Number of buffers of this size */
    int              size;	  /**< Size in bytes */
    int              low_mark;	  /**< Low water mark */
    int              high_mark;	  /**< High water mark */
} drmBufDesc, *drmBufDescPtr;

typedef struct _drmBufInfo {
    int              count;	  /**< Number of buffers described in list */
    drmBufDescPtr    list;	  /**< List of buffer descriptions */
} drmBufInfo, *drmBufInfoPtr;

typedef struct _drmBuf {
    int              idx;	  /**< Index into the master buffer list */
    int              total;	  /**< Buffer size */
    int              used;	  /**< Amount of buffer in use (for DMA) */
    drmAddress       address;	  /**< Address */
} drmBuf, *drmBufPtr;
]]

ffi.cdef[[
/**
 * Buffer mapping information.
 *
 * Used by drmMapBufs() and drmUnmapBufs() to store information about the
 * mapped buffers.
 */
typedef struct _drmBufMap {
    int              count;	  /**< Number of buffers mapped */
    drmBufPtr        list;	  /**< Buffers */
} drmBufMap, *drmBufMapPtr;

typedef struct _drmLock {
    volatile unsigned int lock;
    char                      padding[60];
    /* This is big enough for most current (and future?) architectures:
       DEC Alpha:              32 bytes
       Intel Merced:           ?
       Intel P5/PPro/PII/PIII: 32 bytes
       Intel StrongARM:        32 bytes
       Intel i386/i486:        16 bytes
       MIPS:                   32 bytes (?)
       Motorola 68k:           16 bytes
       Motorola PowerPC:       32 bytes
       Sun SPARC:              32 bytes
    */
} drmLock, *drmLockPtr;
]]

ffi.cdef[[
/**
 * Indices here refer to the offset into
 * list in drmBufInfo
 */
typedef struct _drmDMAReq {
    drm_context_t    context;  	  /**< Context handle */
    int           send_count;     /**< Number of buffers to send */
    int           *send_list;     /**< List of handles to buffers */
    int           *send_sizes;    /**< Lengths of data to send, in bytes */
    drmDMAFlags   flags;          /**< Flags */
    int           request_count;  /**< Number of buffers requested */
    int           request_size;	  /**< Desired size of buffers requested */
    int           *request_list;  /**< Buffer information */
    int           *request_sizes; /**< Minimum acceptable sizes */
    int           granted_count;  /**< Number of buffers granted at this size */
} drmDMAReq, *drmDMAReqPtr;

typedef struct _drmRegion {
    drm_handle_t     handle;
    unsigned int  offset;
    drmSize       size;
    drmAddress    map;
} drmRegion, *drmRegionPtr;

typedef struct _drmTextureRegion {
    unsigned char next;
    unsigned char prev;
    unsigned char in_use;
    unsigned char padding;	/**< Explicitly pad this out */
    unsigned int  age;
} drmTextureRegion, *drmTextureRegionPtr;
]]

ffi.cdef[[
typedef enum {
    DRM_VBLANK_ABSOLUTE = 0x0,	/**< Wait for specific vblank sequence number */
    DRM_VBLANK_RELATIVE = 0x1,	/**< Wait for given number of vblanks */
    /* bits 1-6 are reserved for high crtcs */
    DRM_VBLANK_HIGH_CRTC_MASK = 0x0000003e,
    DRM_VBLANK_EVENT = 0x4000000,	/**< Send event instead of blocking */
    DRM_VBLANK_FLIP = 0x8000000,	/**< Scheduled buffer swap should flip */
    DRM_VBLANK_NEXTONMISS = 0x10000000,	/**< If missed, wait for next vblank */
    DRM_VBLANK_SECONDARY = 0x20000000,	/**< Secondary display controller */
    DRM_VBLANK_SIGNAL   = 0x40000000	/* Send signal instead of blocking */
} drmVBlankSeqType;
]]


ffi.cdef[[
typedef struct _drmVBlankReq {
	drmVBlankSeqType type;
	unsigned int sequence;
	unsigned long signal;
} drmVBlankReq, *drmVBlankReqPtr;

typedef struct _drmVBlankReply {
	drmVBlankSeqType type;
	unsigned int sequence;
	long tval_sec;
	long tval_usec;
} drmVBlankReply, *drmVBlankReplyPtr;

typedef union _drmVBlank {
	drmVBlankReq request;
	drmVBlankReply reply;
} drmVBlank, *drmVBlankPtr;

typedef struct _drmSetVersion {
	int drm_di_major;
	int drm_di_minor;
	int drm_dd_major;
	int drm_dd_minor;
} drmSetVersion, *drmSetVersionPtr;
]]



ffi.cdef[[
/* General user-level programmers API: unprivileged */
extern int           drmAvailable(void);
extern int           drmOpen(const char *name, const char *busid);
]]



ffi.cdef[[
extern int           drmOpenWithType(const char *name, const char *busid,
                                     int type);

extern int           drmOpenControl(int minor);
extern int           drmOpenRender(int minor);
extern int           drmClose(int fd);
extern drmVersionPtr drmGetVersion(int fd);
extern drmVersionPtr drmGetLibVersion(int fd);
extern int           drmGetCap(int fd, uint64_t capability, uint64_t *value);
extern void          drmFreeVersion(drmVersionPtr);
extern int           drmGetMagic(int fd, drm_magic_t * magic);
extern char          *drmGetBusid(int fd);
extern int           drmGetInterruptFromBusID(int fd, int busnum, int devnum,
					      int funcnum);
extern int           drmGetMap(int fd, int idx, drm_handle_t *offset,
			       drmSize *size, drmMapType *type,
			       drmMapFlags *flags, drm_handle_t *handle,
			       int *mtrr);
extern int           drmGetClient(int fd, int idx, int *auth, int *pid,
				  int *uid, unsigned long *magic,
				  unsigned long *iocs);
extern int           drmGetStats(int fd, drmStatsT *stats);
extern int           drmSetInterfaceVersion(int fd, drmSetVersion *version);
extern int           drmCommandNone(int fd, unsigned long drmCommandIndex);
extern int           drmCommandRead(int fd, unsigned long drmCommandIndex,
                                    void *data, unsigned long size);
extern int           drmCommandWrite(int fd, unsigned long drmCommandIndex,
                                     void *data, unsigned long size);
extern int           drmCommandWriteRead(int fd, unsigned long drmCommandIndex,
                                         void *data, unsigned long size);
]]


ffi.cdef[[
/* General user-level programmer's API: X server (root) only  */
extern void          drmFreeBusid(const char *busid);
extern int           drmSetBusid(int fd, const char *busid);
extern int           drmAuthMagic(int fd, drm_magic_t magic);
extern int           drmAddMap(int fd,
			       drm_handle_t offset,
			       drmSize size,
			       drmMapType type,
			       drmMapFlags flags,
			       drm_handle_t * handle);
extern int	     drmRmMap(int fd, drm_handle_t handle);
extern int	     drmAddContextPrivateMapping(int fd, drm_context_t ctx_id,
						 drm_handle_t handle);

extern int           drmAddBufs(int fd, int count, int size,
				drmBufDescFlags flags,
				int agp_offset);
extern int           drmMarkBufs(int fd, double low, double high);
extern int           drmCreateContext(int fd, drm_context_t * handle);
extern int           drmSetContextFlags(int fd, drm_context_t context,
					drm_context_tFlags flags);
extern int           drmGetContextFlags(int fd, drm_context_t context,
					drm_context_tFlagsPtr flags);
extern int           drmAddContextTag(int fd, drm_context_t context, void *tag);
extern int           drmDelContextTag(int fd, drm_context_t context);
extern void          *drmGetContextTag(int fd, drm_context_t context);
extern drm_context_t * drmGetReservedContextList(int fd, int *count);
extern void          drmFreeReservedContextList(drm_context_t *);
extern int           drmSwitchToContext(int fd, drm_context_t context);
extern int           drmDestroyContext(int fd, drm_context_t handle);
extern int           drmCreateDrawable(int fd, drm_drawable_t * handle);
extern int           drmDestroyDrawable(int fd, drm_drawable_t handle);
extern int           drmUpdateDrawableInfo(int fd, drm_drawable_t handle,
					   drm_drawable_info_type_t type,
					   unsigned int num, void *data);
extern int           drmCtlInstHandler(int fd, int irq);
extern int           drmCtlUninstHandler(int fd);
extern int           drmSetClientCap(int fd, uint64_t capability,
				     uint64_t value);
]]

ffi.cdef[[
/* General user-level programmer's API: authenticated client and/or X */
extern int           drmMap(int fd,
			    drm_handle_t handle,
			    drmSize size,
			    drmAddressPtr address);
extern int           drmUnmap(drmAddress address, drmSize size);
extern drmBufInfoPtr drmGetBufInfo(int fd);
extern drmBufMapPtr  drmMapBufs(int fd);
extern int           drmUnmapBufs(drmBufMapPtr bufs);
extern int           drmDMA(int fd, drmDMAReqPtr request);
extern int           drmFreeBufs(int fd, int count, int *list);
extern int           drmGetLock(int fd,
			        drm_context_t context,
			        drmLockFlags flags);
extern int           drmUnlock(int fd, drm_context_t context);
extern int           drmFinish(int fd, int context, drmLockFlags flags);
extern int	     drmGetContextPrivateMapping(int fd, drm_context_t ctx_id, 
						 drm_handle_t * handle);
]]


ffi.cdef[[
/* AGP/GART support: X server (root) only */
extern int           drmAgpAcquire(int fd);
extern int           drmAgpRelease(int fd);
extern int           drmAgpEnable(int fd, unsigned long mode);
extern int           drmAgpAlloc(int fd, unsigned long size,
				 unsigned long type, unsigned long *address,
				 drm_handle_t *handle);
extern int           drmAgpFree(int fd, drm_handle_t handle);
extern int 	     drmAgpBind(int fd, drm_handle_t handle,
				unsigned long offset);
extern int           drmAgpUnbind(int fd, drm_handle_t handle);
]]

ffi.cdef[[
/* AGP/GART info: authenticated client and/or X */
extern int           drmAgpVersionMajor(int fd);
extern int           drmAgpVersionMinor(int fd);
extern unsigned long drmAgpGetMode(int fd);
extern unsigned long drmAgpBase(int fd); /* Physical location */
extern unsigned long drmAgpSize(int fd); /* Bytes */
extern unsigned long drmAgpMemoryUsed(int fd);
extern unsigned long drmAgpMemoryAvail(int fd);
extern unsigned int  drmAgpVendorId(int fd);
extern unsigned int  drmAgpDeviceId(int fd);
]]

ffi.cdef[[
/* PCI scatter/gather support: X server (root) only */
extern int           drmScatterGatherAlloc(int fd, unsigned long size,
					   drm_handle_t *handle);
extern int           drmScatterGatherFree(int fd, drm_handle_t handle);

extern int           drmWaitVBlank(int fd, drmVBlankPtr vbl);
]]

ffi.cdef[[
/* Support routines */
extern void          drmSetServerInfo(drmServerInfoPtr info);
extern int           drmError(int err, const char *label);
extern void          *drmMalloc(int size);
extern void          drmFree(void *pt);
]]


ffi.cdef[[
/* Hash table routines */
extern void *drmHashCreate(void);
extern int  drmHashDestroy(void *t);
extern int  drmHashLookup(void *t, unsigned long key, void **value);
extern int  drmHashInsert(void *t, unsigned long key, void *value);
extern int  drmHashDelete(void *t, unsigned long key);
extern int  drmHashFirst(void *t, unsigned long *key, void **value);
extern int  drmHashNext(void *t, unsigned long *key, void **value);
]]

ffi.cdef[[
/* PRNG routines */
extern void          *drmRandomCreate(unsigned long seed);
extern int           drmRandomDestroy(void *state);
extern unsigned long drmRandom(void *state);
extern double        drmRandomDouble(void *state);
]]

ffi.cdef[[
/* Skip list routines */

extern void *drmSLCreate(void);
extern int  drmSLDestroy(void *l);
extern int  drmSLLookup(void *l, unsigned long key, void **value);
extern int  drmSLInsert(void *l, unsigned long key, void *value);
extern int  drmSLDelete(void *l, unsigned long key);
extern int  drmSLNext(void *l, unsigned long *key, void **value);
extern int  drmSLFirst(void *l, unsigned long *key, void **value);
extern void drmSLDump(void *l);
extern int  drmSLLookupNeighbors(void *l, unsigned long key,
				 unsigned long *prev_key, void **prev_value,
				 unsigned long *next_key, void **next_value);
]]

ffi.cdef[[
extern int drmOpenOnce(void *unused, const char *BusID, int *newlyopened);
extern int drmOpenOnceWithType(const char *BusID, int *newlyopened, int type);
extern void drmCloseOnce(int fd);
extern void drmMsg(const char *format, ...);

extern int drmSetMaster(int fd);
extern int drmDropMaster(int fd);
]]


ffi.cdef[[
typedef struct _drmEventContext {

	/* This struct is versioned so we can add more pointers if we
	 * add more events. */
	int version;

	void (*vblank_handler)(int fd,
			       unsigned int sequence, 
			       unsigned int tv_sec,
			       unsigned int tv_usec,
			       void *user_data);

	void (*page_flip_handler)(int fd,
				  unsigned int sequence,
				  unsigned int tv_sec,
				  unsigned int tv_usec,
				  void *user_data);

} drmEventContext, *drmEventContextPtr;

extern int drmHandleEvent(int fd, drmEventContextPtr evctx);

extern char *drmGetDeviceNameFromFd(int fd);
extern int drmGetNodeTypeFromFd(int fd);

extern int drmPrimeHandleToFD(int fd, uint32_t handle, uint32_t flags, int *prime_fd);
extern int drmPrimeFDToHandle(int fd, int prime_fd, uint32_t *handle);

extern char *drmGetPrimaryDeviceNameFromFd(int fd);
extern char *drmGetRenderDeviceNameFromFd(int fd);
]]


local exports = {
	Lib_drm = Lib_drm;

    -- constants
    DRM_MAX_MINOR  = 16;

    -- Defaults, if nothing set in xf86config
	DRM_DEV_UID  =0;
	DRM_DEV_GID  =0;
-- Default /dev/dri directory permissions 0755
	DRM_DEV_DIRMODE  = bor(S_IRUSR,S_IWUSR,S_IXUSR,S_IRGRP,S_IXGRP,S_IROTH,S_IXOTH);
	DRM_DEV_MODE     = bor(S_IRUSR,S_IWUSR,S_IRGRP,S_IWGRP,S_IROTH,S_IWOTH);

	DRM_DIR_NAME  ="/dev/dri";
	DRM_DEV_NAME  ="%s/card%d";
	DRM_CONTROL_DEV_NAME  ="%s/controlD%d";
	DRM_RENDER_DEV_NAME  ="%s/renderD%d";
	-- DRM_PROC_NAME "/proc/dri/" -- For backward Linux compatibility

	DRM_ERR_NO_DEVICE  = -1001;
	DRM_ERR_NO_ACCESS  = -1002;
	DRM_ERR_NOT_ROOT   = -1003;
	DRM_ERR_INVALID    = -1004;
	DRM_ERR_NO_FD      = -1005;

	DRM_AGP_NO_HANDLE =0;

    DRM_VBLANK_HIGH_CRTC_SHIFT = 1;

    DRM_NODE_PRIMARY = 0;
    DRM_NODE_CONTROL = 1;
    DRM_NODE_RENDER  = 2;

    DRM_EVENT_CONTEXT_VERSION = 2;

	-- Library functions
	drmAvailable = Lib_drm.drmAvailable;
	drmFreeVersion = Lib_drm.drmFreeVersion;
	drmGetBusid = Lib_drm.drmGetBusid;
	drmGetCap = Lib_drm.drmGetCap;
	drmGetLibVersion = Lib_drm.drmGetLibVersion;
	drmGetStats = Lib_drm.drmGetStats;
	drmGetVersion = Lib_drm.drmGetVersion;
  drmIoctl = Lib_drm.drmIoctl;
	drmOpen = Lib_drm.drmOpen;
}

setmetatable(exports, {
	__call = function(self, tbl)
    tbl = tbl or _G
		for k,v in pairs(exports) do
			tbl[k] = v;
		end

		drm(tbl);

		return self;
	end,
})

return exports
