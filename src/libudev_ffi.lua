
local ffi = require("ffi")


-- core types
ffi.cdef[[
typedef uint32_t dev_t;
]]

ffi.cdef[[
/*
 * udev - library context
 *
 * reads the udev config and system environment
 * allows custom logging
 */
struct udev;
struct udev *udev_ref(struct udev *udev);
struct udev *udev_unref(struct udev *udev);
struct udev *udev_new(void);
void udev_set_log_fn(struct udev *udev,
                            void (*log_fn)(struct udev *udev,
                                           int priority, const char *file, int line, const char *fn,
                                           const char *format, va_list args));
int udev_get_log_priority(struct udev *udev);
void udev_set_log_priority(struct udev *udev, int priority);
void *udev_get_userdata(struct udev *udev);
void udev_set_userdata(struct udev *udev, void *userdata);
]]

ffi.cdef[[
/*
 * udev_list
 *
 * access to libudev generated lists
 */
struct udev_list_entry;
struct udev_list_entry *udev_list_entry_get_next(struct udev_list_entry *list_entry);
struct udev_list_entry *udev_list_entry_get_by_name(struct udev_list_entry *list_entry, const char *name);
const char *udev_list_entry_get_name(struct udev_list_entry *list_entry);
const char *udev_list_entry_get_value(struct udev_list_entry *list_entry);
]]




ffi.cdef[[
/*
 * udev_device
 *
 * access to sysfs/kernel devices
 */
struct udev_device;
struct udev_device *udev_device_ref(struct udev_device *udev_device);
struct udev_device *udev_device_unref(struct udev_device *udev_device);
struct udev *udev_device_get_udev(struct udev_device *udev_device);
struct udev_device *udev_device_new_from_syspath(struct udev *udev, const char *syspath);
struct udev_device *udev_device_new_from_devnum(struct udev *udev, char type, dev_t devnum);
struct udev_device *udev_device_new_from_subsystem_sysname(struct udev *udev, const char *subsystem, const char *sysname);
struct udev_device *udev_device_new_from_device_id(struct udev *udev, char *id);
struct udev_device *udev_device_new_from_environment(struct udev *udev);
/* udev_device_get_parent_*() does not take a reference on the returned device, it is automatically unref'd with the parent */
struct udev_device *udev_device_get_parent(struct udev_device *udev_device);
struct udev_device *udev_device_get_parent_with_subsystem_devtype(struct udev_device *udev_device,
                                                                  const char *subsystem, const char *devtype);

]]

ffi.cdef[[
/* retrieve device properties */
const char *udev_device_get_devpath(struct udev_device *udev_device);
const char *udev_device_get_subsystem(struct udev_device *udev_device);
const char *udev_device_get_devtype(struct udev_device *udev_device);
const char *udev_device_get_syspath(struct udev_device *udev_device);
const char *udev_device_get_sysname(struct udev_device *udev_device);
const char *udev_device_get_sysnum(struct udev_device *udev_device);
const char *udev_device_get_devnode(struct udev_device *udev_device);
int udev_device_get_is_initialized(struct udev_device *udev_device);
struct udev_list_entry *udev_device_get_devlinks_list_entry(struct udev_device *udev_device);
struct udev_list_entry *udev_device_get_properties_list_entry(struct udev_device *udev_device);
struct udev_list_entry *udev_device_get_tags_list_entry(struct udev_device *udev_device);
struct udev_list_entry *udev_device_get_sysattr_list_entry(struct udev_device *udev_device);
const char *udev_device_get_property_value(struct udev_device *udev_device, const char *key);
const char *udev_device_get_driver(struct udev_device *udev_device);
dev_t udev_device_get_devnum(struct udev_device *udev_device);
const char *udev_device_get_action(struct udev_device *udev_device);
unsigned long long int udev_device_get_seqnum(struct udev_device *udev_device);
unsigned long long int udev_device_get_usec_since_initialized(struct udev_device *udev_device);
const char *udev_device_get_sysattr_value(struct udev_device *udev_device, const char *sysattr);
int udev_device_set_sysattr_value(struct udev_device *udev_device, const char *sysattr, char *value);
int udev_device_has_tag(struct udev_device *udev_device, const char *tag);
]]

ffi.cdef[[
/*
 * udev_monitor
 *
 * access to kernel uevents and udev events
 */
struct udev_monitor;
struct udev_monitor *udev_monitor_ref(struct udev_monitor *udev_monitor);
struct udev_monitor *udev_monitor_unref(struct udev_monitor *udev_monitor);
struct udev *udev_monitor_get_udev(struct udev_monitor *udev_monitor);
/* kernel and udev generated events over netlink */
struct udev_monitor *udev_monitor_new_from_netlink(struct udev *udev, const char *name);
/* bind socket */
int udev_monitor_enable_receiving(struct udev_monitor *udev_monitor);
int udev_monitor_set_receive_buffer_size(struct udev_monitor *udev_monitor, int size);
int udev_monitor_get_fd(struct udev_monitor *udev_monitor);
struct udev_device *udev_monitor_receive_device(struct udev_monitor *udev_monitor);
/* in-kernel socket filters to select messages that get delivered to a listener */
int udev_monitor_filter_add_match_subsystem_devtype(struct udev_monitor *udev_monitor,
                                                    const char *subsystem, const char *devtype);
int udev_monitor_filter_add_match_tag(struct udev_monitor *udev_monitor, const char *tag);
int udev_monitor_filter_update(struct udev_monitor *udev_monitor);
int udev_monitor_filter_remove(struct udev_monitor *udev_monitor);
]]

ffi.cdef[[
/*
 * udev_enumerate
 *
 * search sysfs for specific devices and provide a sorted list
 */
struct udev_enumerate;
struct udev_enumerate *udev_enumerate_ref(struct udev_enumerate *udev_enumerate);
struct udev_enumerate *udev_enumerate_unref(struct udev_enumerate *udev_enumerate);
struct udev *udev_enumerate_get_udev(struct udev_enumerate *udev_enumerate);
struct udev_enumerate *udev_enumerate_new(struct udev *udev);
/* device properties filter */
int udev_enumerate_add_match_subsystem(struct udev_enumerate *udev_enumerate, const char *subsystem);
int udev_enumerate_add_nomatch_subsystem(struct udev_enumerate *udev_enumerate, const char *subsystem);
int udev_enumerate_add_match_sysattr(struct udev_enumerate *udev_enumerate, const char *sysattr, const char *value);
int udev_enumerate_add_nomatch_sysattr(struct udev_enumerate *udev_enumerate, const char *sysattr, const char *value);
int udev_enumerate_add_match_property(struct udev_enumerate *udev_enumerate, const char *property, const char *value);
int udev_enumerate_add_match_sysname(struct udev_enumerate *udev_enumerate, const char *sysname);
int udev_enumerate_add_match_tag(struct udev_enumerate *udev_enumerate, const char *tag);
int udev_enumerate_add_match_parent(struct udev_enumerate *udev_enumerate, struct udev_device *parent);
int udev_enumerate_add_match_is_initialized(struct udev_enumerate *udev_enumerate);
int udev_enumerate_add_syspath(struct udev_enumerate *udev_enumerate, const char *syspath);
/* run enumeration with active filters */
int udev_enumerate_scan_devices(struct udev_enumerate *udev_enumerate);
int udev_enumerate_scan_subsystems(struct udev_enumerate *udev_enumerate);
/* return device list */
struct udev_list_entry *udev_enumerate_get_list_entry(struct udev_enumerate *udev_enumerate);
]]

ffi.cdef[[
/*
 * udev_queue
 *
 * access to the currently running udev events
 */
struct udev_queue;
struct udev_queue *udev_queue_ref(struct udev_queue *udev_queue);
struct udev_queue *udev_queue_unref(struct udev_queue *udev_queue);
struct udev *udev_queue_get_udev(struct udev_queue *udev_queue);
struct udev_queue *udev_queue_new(struct udev *udev);
unsigned long long int udev_queue_get_kernel_seqnum(struct udev_queue *udev_queue);
unsigned long long int udev_queue_get_udev_seqnum(struct udev_queue *udev_queue);
int udev_queue_get_udev_is_active(struct udev_queue *udev_queue);
int udev_queue_get_queue_is_empty(struct udev_queue *udev_queue);
int udev_queue_get_seqnum_is_finished(struct udev_queue *udev_queue, unsigned long long int seqnum);
int udev_queue_get_seqnum_sequence_is_finished(struct udev_queue *udev_queue,
                                               unsigned long long int start, unsigned long long int end);
struct udev_list_entry *udev_queue_get_queued_list_entry(struct udev_queue *udev_queue);
]]

ffi.cdef[[
/*
 *  udev_hwdb
 *
 *  access to the static hardware properties database
 */
struct udev_hwdb;
struct udev_hwdb *udev_hwdb_new(struct udev *udev);
struct udev_hwdb *udev_hwdb_ref(struct udev_hwdb *hwdb);
struct udev_hwdb *udev_hwdb_unref(struct udev_hwdb *hwdb);
struct udev_list_entry *udev_hwdb_get_properties_list_entry(struct udev_hwdb *hwdb, const char *modalias, unsigned int flags);
]]

ffi.cdef[[
/*
 * udev_util
 *
 * udev specific utilities
 */
int udev_util_encode_string(const char *str, char *str_enc, size_t len);
]]


local function safeffistring(str)
    if str == nil then
        return nil;
    end

    return ffi.string(str);
end

local Lib_udev = ffi.load("udev")

local exports = {
    Lib_udev = Lib_udev;  

    -- library functions
    udev_new = Lib_udev.udev_new;
    udev_unref = Lib_udev.udev_unref;


    udev_device_new_from_syspath = Lib_udev.udev_device_new_from_syspath;
    udev_device_get_action = Lib_udev.udev_device_get_action;
    udev_device_get_devtype = Lib_udev.udev_device_get_devtype;
    udev_device_get_devnode = Lib_udev.udev_device_get_devnode;
    udev_device_get_devpath = Lib_udev.udev_device_get_devpath;
    udev_device_get_driver = Lib_udev.udev_device_get_driver;
    udev_device_get_is_initialized = Lib_udev.udev_device_get_is_initialized;
    udev_device_get_parent = Lib_udev.udev_device_get_parent;
    udev_device_get_parent_with_subsystem_devtype = Lib_udev.udev_device_get_parent_with_subsystem_devtype;
    udev_device_get_properties_list_entry = Lib_udev.udev_device_get_properties_list_entry;
    udev_device_get_subsystem = Lib_udev.udev_device_get_subsystem;
    udev_device_get_sysattr_value = Lib_udev.udev_device_get_sysattr_value;
    udev_device_get_sysname = Lib_udev.udev_device_get_sysname;
    udev_device_get_sysnum = Lib_udev.udev_device_get_sysnum;
    udev_device_get_syspath = Lib_udev.udev_device_get_syspath;
    udev_device_get_tags_list_entry = Lib_udev.udev_device_get_tags_list_entry;
    udev_device_unref = Lib_udev.udev_device_unref;

    udev_enumerate_new = Lib_udev.udev_enumerate_new;
    udev_enumerate_add_match_subsystem = Lib_udev.udev_enumerate_add_match_subsystem;
    udev_enumerate_get_list_entry = Lib_udev.udev_enumerate_get_list_entry;
    udev_enumerate_scan_devices = Lib_udev.udev_enumerate_scan_devices;
    udev_enumerate_scan_subsystems = Lib_udev.udev_enumerate_scan_subsystems;
    udev_enumerate_unref = Lib_udev.udev_enumerate_unref;

    udev_hwdb_new = Lib_udev.udev_hwdb_new;
    udev_hwdb_ref = Lib_udev.udev_hwdb_ref;
    udev_hwdb_unref = Lib_udev.udev_hwdb_unref;
    udev_hwdb_get_properties_list_entry = Lib_udev.udev_hwdb_get_properties_list_entry;

    udev_list_entry_get_name = Lib_udev.udev_list_entry_get_name;
    udev_list_entry_get_next = Lib_udev.udev_list_entry_get_next;
    udev_list_entry_get_value = Lib_udev.udev_list_entry_get_value;

    udev_queue_new = Lib_udev.udev_queue_new;

    -- local functions
    safeffistring = safeffistring;
}
setmetatable(exports, {
  __call = function(self, ...)
    for k,v in pairs(self) do
      _G[k] = v;
    end

    return self;
  end,
})

return exports
