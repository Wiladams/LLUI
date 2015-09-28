
local LIB_libevdev = require("evdev_ffi")

local exports = {
    LIB_libevdef = LIB_libevdev;

    libevdev_new = LIB_libevdev.libevdev_new;
    libevdev_new_from_fd = LIB_libevdev.libevdev_new_from_fd;
    libevdev_free = LIB_libevdev.libevdev_free;

    libevdev_set_log_function = LIB_libevdev.libevdev_set_log_function;
    libevdev_set_log_priority = LIB_libevdev.libevdev_set_log_priority;
    libevdev_get_log_priority = LIB_libevdev.libevdev_get_log_priority;
    libevdev_set_device_log_function = LIB_libevdev.libevdev_set_device_log_function;


  libevdev_next_event = LIB_libevdev.libevdev_next_event;
  libevdev_has_event_pending = LIB_libevdev.libevdev_has_event_pending;
  libevdev_get_name = LIB_libevdev.libevdev_get_name;
  libevdev_set_name = LIB_libevdev.libevdev_set_name;
  libevdev_get_phys = LIB_libevdev.libevdev_get_phys;
  libevdev_set_phys = LIB_libevdev.libevdev_set_phys;
  libevdev_get_uniq = LIB_libevdev.libevdev_get_uniq;
  libevdev_set_uniq = LIB_libevdev.libevdev_set_uniq;
  libevdev_get_id_product = LIB_libevdev.libevdev_get_id_product;
  libevdev_set_id_product = LIB_libevdev.libevdev_set_id_product;
  libevdev_get_id_vendor = LIB_libevdev.libevdev_get_id_vendor;
  libevdev_set_id_vendor = LIB_libevdev.libevdev_set_id_vendor;
  libevdev_get_id_bustype = LIB_libevdev.libevdev_get_id_bustype;
  libevdev_set_id_bustype = LIB_libevdev.libevdev_set_id_bustype;
  libevdev_get_id_version = LIB_libevdev.libevdev_get_id_version;
  libevdev_get_driver_version = LIB_libevdev.libevdev_get_driver_version;
  libevdev_has_property = LIB_libevdev.libevdev_has_property;
  libevdev_enable_property = LIB_libevdev.libevdev_enable_property;
  libevdev_has_event_type = LIB_libevdev.libevdev_has_event_type;
  libevdev_has_event_code = LIB_libevdev.libevdev_has_event_code;
  libevdev_get_abs_minimum = LIB_libevdev.libevdev_get_abs_minimum;
  libevdev_get_abs_maximum = LIB_libevdev.libevdev_get_abs_maximum;
  libevdev_get_abs_fuzz = LIB_libevdev.libevdev_get_abs_fuzz;
  libevdev_get_abs_flat = LIB_libevdev.libevdev_get_abs_flat;
  libevdev_get_abs_resolution = LIB_libevdev.libevdev_get_abs_resolution;
  libevdev_get_abs_info = LIB_libevdev.libevdev_get_abs_info;
  libevdev_get_event_value = LIB_libevdev.libevdev_get_event_value;
  libevdev_set_event_value = LIB_libevdev.libevdev_set_event_value;
  libevdev_fetch_event_value = LIB_libevdev.libevdev_fetch_event_value;
  libevdev_get_slot_value = LIB_libevdev.libevdev_get_slot_value;
  libevdev_set_slot_value = LIB_libevdev.libevdev_set_slot_value;
  libevdev_fetch_slot_value = LIB_libevdev.libevdev_fetch_slot_value;
  libevdev_get_num_slots = LIB_libevdev.libevdev_get_num_slots;
  libevdev_get_current_slot = LIB_libevdev.libevdev_get_current_slot;
  libevdev_set_abs_minimum = LIB_libevdev.libevdev_set_abs_minimum;
  libevdev_set_abs_maximum = LIB_libevdev.libevdev_set_abs_maximum;
  libevdev_set_abs_fuzz = LIB_libevdev.libevdev_set_abs_fuzz;
  libevdev_set_abs_flat = LIB_libevdev.libevdev_set_abs_flat;
  libevdev_set_abs_resolution = LIB_libevdev.libevdev_set_abs_resolution;
  libevdev_set_abs_info = LIB_libevdev.libevdev_set_abs_info;
  libevdev_enable_event_type = LIB_libevdev.libevdev_enable_event_type;
  libevdev_disable_event_type = LIB_libevdev.libevdev_disable_event_type;
  libevdev_enable_event_code = LIB_libevdev.libevdev_enable_event_code;
  libevdev_disable_event_code = LIB_libevdev.libevdev_disable_event_code;
  libevdev_kernel_set_abs_info = LIB_libevdev.libevdev_kernel_set_abs_info;

  libevdev_kernel_set_led_value = LIB_libevdev.libevdev_kernel_set_led_value;
  libevdev_kernel_set_led_values = LIB_libevdev.libevdev_kernel_set_led_values;
  libevdev_set_clock_id = LIB_libevdev.libevdev_set_clock_id;
  libevdev_event_is_type = LIB_libevdev.libevdev_event_is_type;
  libevdev_event_is_code = LIB_libevdev.libevdev_event_is_code;

  libevdev_event_type_get_name = LIB_libevdev.libevdev_event_type_get_name;
  libevdev_event_code_get_name = LIB_libevdev.libevdev_event_code_get_name;
  libevdev_property_get_name = LIB_libevdev.libevdev_property_get_name;

  libevdev_event_type_get_max = LIB_libevdev.libevdev_event_type_get_max;
  libevdev_event_type_from_name = LIB_libevdev.libevdev_event_type_from_name;
  libevdev_event_type_from_name_n = LIB_libevdev.libevdev_event_type_from_name_n;
  libevdev_event_code_from_name = LIB_libevdev.libevdev_event_code_from_name;
  libevdev_event_code_from_name_n = LIB_libevdev.libevdev_event_code_from_name_n;
  libevdev_property_from_name = LIB_libevdev.libevdev_property_from_name;
  libevdev_property_from_name_n = LIB_libevdev.libevdev_property_from_name_n;
  libevdev_get_repeat = LIB_libevdev.libevdev_get_repeat;
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
