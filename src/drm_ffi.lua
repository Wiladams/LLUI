local ffi = require("ffi")

local bit = require("bit")
local bor = bit.bor;
local band = bit.band;
local bnot = bit.bnot;

local libc = require("libc")



ffi.cdef[[
typedef unsigned int drm_handle_t;
]]


ffi.cdef[[
typedef unsigned int drm_context_t;
typedef unsigned int drm_drawable_t;
typedef unsigned int drm_magic_t;
]]

ffi.cdef[[
struct drm_clip_rect {
	unsigned short x1;
	unsigned short y1;
	unsigned short x2;
	unsigned short y2;
};
]]

ffi.cdef[[
struct drm_drawable_info {
	unsigned int num_rects;
	struct drm_clip_rect *rects;
};
]]

ffi.cdef[[
struct drm_tex_region {
	unsigned char next;
	unsigned char prev;
	unsigned char in_use;
	unsigned char padding;
	unsigned int age;
};
]]

ffi.cdef[[

struct drm_hw_lock {
	__volatile__ unsigned int lock;		//< lock variable 
	char padding[60];			//< Pad to cache line 
};
]]

ffi.cdef[[

struct drm_version {
	int version_major;	  //< Major version 
	int version_minor;	  //< Minor version 
	int version_patchlevel;	  //< Patch level 
	size_t name_len;	  //< Length of name buffer 
	char *name;	  //< Name of driver 
	size_t date_len;	  //< Length of date buffer 
	char *date;	  //< User-space buffer to hold date 
	size_t desc_len;	  //< Length of desc buffer 
	char *desc;	  //< User-space buffer to hold desc 
};
]]

ffi.cdef[[

struct drm_unique {
	size_t unique_len;	  //< Length of unique 
	char *unique;	  //< Unique name for driver instantiation 
};

struct drm_list {
	int count;		  //< Length of user-space structures 
	struct drm_version *version;
};

struct drm_block {
	int unused;
};
]]

ffi.cdef[[

struct drm_control {
	enum {
		DRM_ADD_COMMAND,
		DRM_RM_COMMAND,
		DRM_INST_HANDLER,
		DRM_UNINST_HANDLER
	} func;
	int irq;
};
]]

ffi.cdef[[

enum drm_map_type {
	_DRM_FRAME_BUFFER = 0,	  //< WC (no caching), no core dump 
	_DRM_REGISTERS = 1,	  //< no caching, no core dump 
	_DRM_SHM = 2,		  //< shared, cached 
	_DRM_AGP = 3,		  //< AGP/GART 
	_DRM_SCATTER_GATHER = 4,  //< Scatter/gather memory for PCI DMA 
	_DRM_CONSISTENT = 5,	  //< Consistent memory for PCI DMA 
};


enum drm_map_flags {
	_DRM_RESTRICTED = 0x01,	     //< Cannot be mapped to user-virtual 
	_DRM_READ_ONLY = 0x02,
	_DRM_LOCKED = 0x04,	     //< shared, cached, locked 
	_DRM_KERNEL = 0x08,	     //< kernel requires access 
	_DRM_WRITE_COMBINING = 0x10, //< use write-combining if available 
	_DRM_CONTAINS_LOCK = 0x20,   //< SHM page that contains lock 
	_DRM_REMOVABLE = 0x40,	     //< Removable mapping 
	_DRM_DRIVER = 0x80	     //< Managed by driver 
};

struct drm_ctx_priv_map {
	unsigned int ctx_id;	 //< Context requesting private mapping 
	void *handle;		 //< Handle of map 
};


struct drm_map {
	unsigned long offset;	 //< Requested physical address (0 for SAREA)
	unsigned long size;	 //< Requested physical size (bytes) 
	enum drm_map_type type;	 //< Type of memory to map 
	enum drm_map_flags flags;	 //< Flags 
	void *handle;		 //< User-space: "Handle" to pass to mmap() 
				 //< Kernel-space: kernel-virtual address 
	int mtrr;		 //< MTRR slot used 
	//   Private data 
};
]]

ffi.cdef[[

struct drm_client {
	int idx;		//< Which client desired? 
	int auth;		//< Is client authenticated? 
	unsigned long pid;	//< Process ID 
	unsigned long uid;	//< User ID 
	unsigned long magic;	//< Magic 
	unsigned long iocs;	//< Ioctl count 
};

enum drm_stat_type {
	_DRM_STAT_LOCK,
	_DRM_STAT_OPENS,
	_DRM_STAT_CLOSES,
	_DRM_STAT_IOCTLS,
	_DRM_STAT_LOCKS,
	_DRM_STAT_UNLOCKS,
	_DRM_STAT_VALUE,	//< Generic value 
	_DRM_STAT_BYTE,		//< Generic byte counter (1024bytes/K) 
	_DRM_STAT_COUNT,	//< Generic non-byte counter (1000/k) 

	_DRM_STAT_IRQ,		//< IRQ 
	_DRM_STAT_PRIMARY,	//< Primary DMA bytes 
	_DRM_STAT_SECONDARY,	//< Secondary DMA bytes 
	_DRM_STAT_DMA,		//< DMA 
	_DRM_STAT_SPECIAL,	//< Special DMA (e.g., priority or polled) 
	_DRM_STAT_MISSED	//< Missed DMA opportunity 
	    // Add to the *END* of the list 
};
]]

ffi.cdef[[

struct drm_stats {
	unsigned long count;
	struct {
		unsigned long value;
		enum drm_stat_type type;
	} data[15];
};


enum drm_lock_flags {
	_DRM_LOCK_READY = 0x01,	     //< Wait until hardware is ready for DMA 
	_DRM_LOCK_QUIESCENT = 0x02,  //< Wait until hardware quiescent 
	_DRM_LOCK_FLUSH = 0x04,	     //< Flush this context's DMA queue first 
	_DRM_LOCK_FLUSH_ALL = 0x08,  //< Flush all DMA queues first 
	// These *HALT* flags aren't supported yet
	   // they will be used to support the
	   // full-screen DGA-like mode. 
	_DRM_HALT_ALL_QUEUES = 0x10, //< Halt all current and future queues 
	_DRM_HALT_CUR_QUEUES = 0x20  //< Halt all current queues 
};
]]

ffi.cdef[[

struct drm_lock {
	int context;
	enum drm_lock_flags flags;
};


enum drm_dma_flags {
	// Flags for DMA buffer dispatch 
	_DRM_DMA_BLOCK = 0x01,
				       
	_DRM_DMA_WHILE_LOCKED = 0x02, //< Dispatch while lock held 
	_DRM_DMA_PRIORITY = 0x04,     //< High priority dispatch 

	// Flags for DMA buffer request 
	_DRM_DMA_WAIT = 0x10,	      //< Wait for free buffers 
	_DRM_DMA_SMALLER_OK = 0x20,   //< Smaller-than-requested buffers OK 
	_DRM_DMA_LARGER_OK = 0x40     //< Larger-than-requested buffers OK 
};
]]

ffi.cdef[[

struct drm_buf_desc {
	int count;		 //< Number of buffers of this size 
	int size;		 //< Size in bytes 
	int low_mark;		 //< Low water mark 
	int high_mark;		 //< High water mark 
	enum {
		_DRM_PAGE_ALIGN = 0x01,	//< Align on page boundaries for DMA 
		_DRM_AGP_BUFFER = 0x02,	//< Buffer is in AGP space 
		_DRM_SG_BUFFER = 0x04,	//< Scatter/gather memory buffer 
		_DRM_FB_BUFFER = 0x08,	//< Buffer is in frame buffer 
		_DRM_PCI_BUFFER_RO = 0x10 //< Map PCI DMA buffer read-only 
	} flags;
	unsigned long agp_start; 
				  
};
]]

ffi.cdef[[

struct drm_buf_info {
	int count;		//< Entries in list 
	struct drm_buf_desc *list;
};
]]

ffi.cdef[[

struct drm_buf_free {
	int count;
	int *list;
};


struct drm_buf_pub {
	int idx;		       //< Index into the master buffer list 
	int total;		       //< Buffer size 
	int used;		       //< Amount of buffer in use (for DMA) 
	void *address;	       //< Address of buffer 
};
]]

ffi.cdef[[

struct drm_buf_map {
	int count;		//< Length of the buffer list 
	void *virtual;		//< Mmap'd area in user-virtual 
	struct drm_buf_pub *list;	//< Buffer information 
};
]]

ffi.cdef[[

struct drm_dma {
	int context;			  //< Context handle 
	int send_count;			  //< Number of buffers to send 
	int *send_indices;	  //< List of handles to buffers 
	int *send_sizes;		  //< Lengths of data to send 
	enum drm_dma_flags flags;	  //< Flags 
	int request_count;		  //< Number of buffers requested 
	int request_size;		  //< Desired size for buffers 
	int *request_indices;	  //< Buffer information 
	int *request_sizes;
	int granted_count;		  //< Number of buffers granted 
};

enum drm_ctx_flags {
	_DRM_CONTEXT_PRESERVED = 0x01,
	_DRM_CONTEXT_2DONLY = 0x02
};
]]

ffi.cdef[[

struct drm_ctx {
	drm_context_t handle;
	enum drm_ctx_flags flags;
};
]]

ffi.cdef[[

struct drm_ctx_res {
	int count;
	struct drm_ctx *contexts;
};
]]

ffi.cdef[[

struct drm_draw {
	drm_drawable_t handle;
};
]]

ffi.cdef[[

typedef enum {
	DRM_DRAWABLE_CLIPRECTS,
} drm_drawable_info_type_t;

struct drm_update_draw {
	drm_drawable_t handle;
	unsigned int type;
	unsigned int num;
	unsigned long long data;
};
]]

ffi.cdef[[

struct drm_auth {
	drm_magic_t magic;
};
]]

ffi.cdef[[

struct drm_irq_busid {
	int irq;	//< IRQ number 
	int busnum;	//< bus number 
	int devnum;	//< device number 
	int funcnum;	//< function number 
};

enum drm_vblank_seq_type {
	_DRM_VBLANK_ABSOLUTE = 0x0,	//< Wait for specific vblank sequence number 
	_DRM_VBLANK_RELATIVE = 0x1,	//< Wait for given number of vblanks 
	// bits 1-6 are reserved for high crtcs 
	_DRM_VBLANK_HIGH_CRTC_MASK = 0x0000003e,
	_DRM_VBLANK_EVENT = 0x4000000,   //< Send event instead of blocking 
	_DRM_VBLANK_FLIP = 0x8000000,   //< Scheduled buffer swap should flip 
	_DRM_VBLANK_NEXTONMISS = 0x10000000,	//< If missed, wait for next vblank 
	_DRM_VBLANK_SECONDARY = 0x20000000,	//< Secondary display controller 
	_DRM_VBLANK_SIGNAL = 0x40000000	//< Send signal instead of blocking, unsupported 
};
]]

ffi.cdef[[
struct drm_wait_vblank_request {
	enum drm_vblank_seq_type type;
	unsigned int sequence;
	unsigned long signal;
};

struct drm_wait_vblank_reply {
	enum drm_vblank_seq_type type;
	unsigned int sequence;
	long tval_sec;
	long tval_usec;
};


union drm_wait_vblank {
	struct drm_wait_vblank_request request;
	struct drm_wait_vblank_reply reply;
};
]]



ffi.cdef[[

struct drm_modeset_ctl {
	uint32_t crtc;
	uint32_t cmd;
};
]]

ffi.cdef[[

struct drm_agp_mode {
	unsigned long mode;	//< AGP mode 
};
]]

ffi.cdef[[

struct drm_agp_buffer {
	unsigned long size;	//< In bytes -- will round to page boundary 
	unsigned long handle;	//< Used for binding / unbinding 
	unsigned long type;	//< Type of memory to allocate 
	unsigned long physical;	//< Physical used by i810 
};
]]

ffi.cdef[[

struct drm_agp_binding {
	unsigned long handle;	//< From drm_agp_buffer 
	unsigned long offset;	//< In bytes -- will round to page boundary 
};
]]

ffi.cdef[[

struct drm_agp_info {
	int agp_version_major;
	int agp_version_minor;
	unsigned long mode;
	unsigned long aperture_base;	// physical address 
	unsigned long aperture_size;	// bytes 
	unsigned long memory_allowed;	// bytes 
	unsigned long memory_used;

	// PCI information 
	unsigned short id_vendor;
	unsigned short id_device;
};
]]

ffi.cdef[[

struct drm_scatter_gather {
	unsigned long size;	//< In bytes -- will round to page boundary 
	unsigned long handle;	//< Used for mapping / unmapping 
};
]]

ffi.cdef[[

struct drm_set_version {
	int drm_di_major;
	int drm_di_minor;
	int drm_dd_major;
	int drm_dd_minor;
};
]]

ffi.cdef[[
// DRM_IOCTL_GEM_CLOSE ioctl argument type 
struct drm_gem_close {
	// Handle of the object to be closed. 
	uint32_t handle;
	uint32_t pad;
};
]]

ffi.cdef[[
// DRM_IOCTL_GEM_FLINK ioctl argument type 
struct drm_gem_flink {
	// Handle for the object being named 
	uint32_t handle;

	// Returned global name 
	uint32_t name;
};
]]

ffi.cdef[[
// DRM_IOCTL_GEM_OPEN ioctl argument type 
struct drm_gem_open {
	// Name of object being opened 
	uint32_t name;

	// Returned handle for the object 
	uint32_t handle;

	// Returned size of the object 
	uint64_t size;
};
]]


ffi.cdef[[
// DRM_IOCTL_GET_CAP ioctl argument type 
struct drm_get_cap {
	uint64_t capability;
	uint64_t value;
};
]]


ffi.cdef[[
// DRM_IOCTL_SET_CLIENT_CAP ioctl argument type 
struct drm_set_client_cap {
	uint64_t capability;
	uint64_t value;
};
]]

ffi.cdef[[
struct drm_prime_handle {
	uint32_t handle;

	// Flags.. only applicable for handle->fd 
	uint32_t flags;

	// Returned dmabuf file descriptor 
	int32_t fd;
};
]]

require("drm_mode")



--[[
--*
 * Device specific ioctls should only be in their respective headers
 * The device specific ioctl range is from 0x40 to 0x9f.
 * Generic IOCTLS restart at 0xA0.
 *
 * \sa drmCommandNone(), drmCommandRead(), drmCommandWrite(), and
 * drmCommandReadWrite().
 
	DRM_COMMAND_BASE        0x40
	DRM_COMMAND_END			0xA0

--*
 * Header for events written back to userspace on the drm fd.  The
 * type defines the type of event, the length specifies the total
 * length of the event (including the header), and user_data is
 * typically a 64 bit value passed with the ioctl that triggered the
 * event.  A read on the drm fd will always only return complete
 * events, that is, if for example the read buffer is 100 bytes, and
 * there are two 64 byte events pending, only one will be returned.
 *
 * Event types 0 - 0x7fffffff are generic drm events, 0x80000000 and
 * up are chipset specific.
 
 --]]

ffi.cdef[[
struct drm_event {
	uint32_t type;
	uint32_t length;
};
]]


ffi.cdef[[
struct drm_event_vblank {
	struct drm_event base;
	uint64_t user_data;
	uint32_t tv_sec;
	uint32_t tv_usec;
	uint32_t sequence;
	uint32_t reserved;
};
]]

ffi.cdef[[

typedef struct drm_clip_rect drm_clip_rect_t;
typedef struct drm_drawable_info drm_drawable_info_t;
typedef struct drm_tex_region drm_tex_region_t;
typedef struct drm_hw_lock drm_hw_lock_t;
typedef struct drm_version drm_version_t;
typedef struct drm_unique drm_unique_t;
typedef struct drm_list drm_list_t;
typedef struct drm_block drm_block_t;
typedef struct drm_control drm_control_t;
typedef enum drm_map_type drm_map_type_t;
typedef enum drm_map_flags drm_map_flags_t;
typedef struct drm_ctx_priv_map drm_ctx_priv_map_t;
typedef struct drm_map drm_map_t;
typedef struct drm_client drm_client_t;
typedef enum drm_stat_type drm_stat_type_t;
typedef struct drm_stats drm_stats_t;
typedef enum drm_lock_flags drm_lock_flags_t;
typedef struct drm_lock drm_lock_t;
typedef enum drm_dma_flags drm_dma_flags_t;
typedef struct drm_buf_desc drm_buf_desc_t;
typedef struct drm_buf_info drm_buf_info_t;
typedef struct drm_buf_free drm_buf_free_t;
typedef struct drm_buf_pub drm_buf_pub_t;
typedef struct drm_buf_map drm_buf_map_t;
typedef struct drm_dma drm_dma_t;
typedef union drm_wait_vblank drm_wait_vblank_t;
typedef struct drm_agp_mode drm_agp_mode_t;
typedef enum drm_ctx_flags drm_ctx_flags_t;
typedef struct drm_ctx drm_ctx_t;
typedef struct drm_ctx_res drm_ctx_res_t;
typedef struct drm_draw drm_draw_t;
typedef struct drm_update_draw drm_update_draw_t;
typedef struct drm_auth drm_auth_t;
typedef struct drm_irq_busid drm_irq_busid_t;
typedef enum drm_vblank_seq_type drm_vblank_seq_type_t;

typedef struct drm_agp_buffer drm_agp_buffer_t;
typedef struct drm_agp_binding drm_agp_binding_t;
typedef struct drm_agp_info drm_agp_info_t;
typedef struct drm_scatter_gather drm_scatter_gather_t;
typedef struct drm_set_version drm_set_version_t;
]]



local Lib_drm = ffi.load("drm")

return Lib_drm;