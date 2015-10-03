--
-- /usr/include/libv4lconvert.h
--
local ffi = require("ffi")


require("videodev2")


ffi.cdef[[
struct libv4l_dev_ops;
struct v4lconvert_data;

const struct libv4l_dev_ops *v4lconvert_get_default_dev_ops();

struct v4lconvert_data *v4lconvert_create(int fd);
struct v4lconvert_data *v4lconvert_create_with_dev_ops(int fd,
		void *dev_ops_priv, const struct libv4l_dev_ops *dev_ops);
void v4lconvert_destroy(struct v4lconvert_data *data);


int v4lconvert_supported_dst_fmt_only(
		struct v4lconvert_data *data);


int v4lconvert_try_format(struct v4lconvert_data *data,
		struct v4l2_format *dest_fmt, /* in / out */
		struct v4l2_format *src_fmt); /* out */


int v4lconvert_enum_fmt(struct v4lconvert_data *data,
		struct v4l2_fmtdesc *fmt);

int v4lconvert_needs_conversion(struct v4lconvert_data *data,
		const struct v4l2_format *src_fmt,   /* in */
		const struct v4l2_format *dest_fmt); /* in */


int v4lconvert_convert(struct v4lconvert_data *data,
		const struct v4l2_format *src_fmt,  /* in */
		const struct v4l2_format *dest_fmt, /* in */
		unsigned char *src, int src_size, unsigned char *dest, int dest_size);

const char *v4lconvert_get_error_message(struct v4lconvert_data *data);


int v4lconvert_enum_framesizes(struct v4lconvert_data *data,
		struct v4l2_frmsizeenum *frmsize);


int v4lconvert_enum_frameintervals(struct v4lconvert_data *data,
		struct v4l2_frmivalenum *frmival);

int v4lconvert_vidioc_queryctrl(struct v4lconvert_data *data, void *arg);
int v4lconvert_vidioc_g_ctrl(struct v4lconvert_data *data, void *arg);
int v4lconvert_vidioc_s_ctrl(struct v4lconvert_data *data, void *arg);

int v4lconvert_supported_dst_format(unsigned int pixelformat);


int v4lconvert_get_fps(struct v4lconvert_data *data);
void v4lconvert_set_fps(struct v4lconvert_data *data, int fps);
]]

local Lib = ffi.load("v4lconvert")

return Lib;