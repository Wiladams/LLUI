--[[
/*
 *  V4L2 video capture example
 *
 *  This program can be used and distributed without restrictions.
 *
 *      This program is provided with the V4L2 API
 * see http://linuxtv.org/docs.php for more information
 */
--]]
package.path = package.path..";../src/?.lua"

local ffi = require("ffi")
local bit = require("bit")
local band, bor, lshift, rshift = bit.band, bit.bor, bit.lshift, bit.rshift

local libc = require("libc")()
local videodev2 = require ("videodev2")()
local enumbits = require("enumbits")


local int = ffi.typeof("int")


local function  CLEAR(x) 
    libc.memset(x, 0, ffi.sizeof(x))
end



ffi.cdef[[
struct buffer {
        void   *start;
        size_t  length;
};
]]

--struct buffer          *buffers;
--static unsigned int     n_buffers;
--static int              out_buf;
local force_format = true;
local frame_count = 70;

local function errno_exit(s)
    io.stderr:write(string.format("%s error %d, %s\n", s, ffi.errno(), libc.strerror()));
    error();
end

local function xioctl(fh, request, param)
    local r;

    repeat 
        r = libc.ioctl(fh, request, param);
    until (-1 ~= r or (EINTR ~= ffi.errno()));

    return r;
end

local function process_image(p, size)

    if (out_buf ~= nil) then
        fwrite(p, size, 1, stdout);
    end

    libc.fflush(io.stderr);
    libc.fprintf(io.stderr, ".");
    libc.fflush(io.stdout);
end

local function read_frame(fd)    
    print("read_frame: ", buffers[0].start, buffers[0].length)
    local res = libc.read(fd, buffers[0].start, buffers[0].length)

    if (-1 == res) then 
        if ffi.errno() == libc.errnos.EAGAIN then
            return 0;
        else
            if ffi.errno() == libc.errnos.EIO then
                -- Could ignore EIO, see spec.
                -- fall through
            end
            
            errno_exit("read");
        end
    end

    process_image(buffers[0].start, buffers[0].length);

    return 1;
end

local function mainloop(fd)

    local count = frame_count;

    while (count > 0) do
        while (true) do
--[[
                        fd_set fds;
                        struct timeval tv;
                        int r;

                        FD_ZERO(&fds);
                        FD_SET(fd, &fds);

                        /* Timeout. */
                        tv.tv_sec = 2;
                        tv.tv_usec = 0;

                        r = select(fd + 1, &fds, NULL, NULL, &tv);

                        if (-1 == r) {
                                if (EINTR == errno)
                                        continue;
                                errno_exit("select");
                        }

                        if (0 == r) {
                                fprintf(stderr, "select timeout\n");
                                exit(EXIT_FAILURE);
                        }

                        if (read_frame())
                                break;
                        /* EAGAIN - continue select loop. */
--]]
                        if (read_frame(fd) ~= 0) then
                            break
                        end
                end

                count = count - 1;
        end
end



local function uninit_device()
    libc.free(buffers[0].start);
--    libc.free(buffers);
end

local function init_read(buffer_size)
    buffers = ffi.new("struct buffer[1]")
 
    buffers[0].length = buffer_size;
    buffers[0].start = libc.malloc(buffer_size);

    if (buffers[0].start == nil) then
        io.stderr:write("Out of memory\n");
        error();
    end
end



local function init_device(fd, dev_name)

    local cap = ffi.new("struct v4l2_capability");
    local cropcap = ffi.new("struct v4l2_cropcap");
    local crop = ffi.new("struct v4l2_crop");
    local fmt = ffi.new("struct v4l2_format");
    
    if (-1 == xioctl(fd, VIDIOC_QUERYCAP, cap)) then
        if (EINVAL == ffi.errno() or (ENOTTY == ffi.errno())) then
            io.stderr:write(string.format("%s is no V4L2 device\n", dev_name));
            error();
        else
            errno_exit("VIDIOC_QUERYCAP");
        end
    end

    io.write("Capabilities: ")
    for _, name in enumbits(cap.capabilities, v4l2_capability_flags, 32) do
        io.write(string.format("%s,", name))
    end
    print()

    if (band(cap.capabilities, V4L2_CAP_VIDEO_CAPTURE) == 0) then
        io.stderr:write(string.format("%s is no video capture device\n",dev_name));
        error();
    end

    if (band(cap.capabilities, V4L2_CAP_STREAMING) == 0) then
        io.stderr:write(string.format("%s does not support streaming\n", dev_name));
        error();
    end


    -- Select video input, video standard and tune here.

    cropcap.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;

    if (0 == xioctl(fd, VIDIOC_CROPCAP, cropcap)) then
        crop.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        crop.c = cropcap.defrect; -- reset to default

        if (-1 == xioctl(fd, VIDIOC_S_CROP, crop)) then
            if ffi.errno() == EINVAL or ffi.errno() == ENOTTY then
                print("Cropping not supported: ", ffi.errno())
            else
                -- Errors ignored.
            end
        end
    else
        -- Errors ignored.
        print("xioctl(VIDIOC_CROPCAP) FAILED: ", ffi.errno())
    end


    fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    if (force_format) then
                fmt.fmt.pix.width       = 640;
                fmt.fmt.pix.height      = 480;
                fmt.fmt.pix.pixelformat = V4L2_PIX_FMT_YUYV;
                fmt.fmt.pix.field       = V4L2_FIELD_INTERLACED;

                if (-1 == xioctl(fd, VIDIOC_S_FMT, fmt)) then
                        errno_exit("VIDIOC_S_FMT");
                end

                -- Note VIDIOC_S_FMT may change width and height.
    else
        -- Preserve original settings as set by v4l2-ctl for example
        if (-1 == xioctl(fd, VIDIOC_G_FMT, fmt)) then
            errno_exit("VIDIOC_G_FMT");
        end
    end


    -- Buggy driver paranoia.
    local min = fmt.fmt.pix.width * 2;
    if (fmt.fmt.pix.bytesperline < min) then
        fmt.fmt.pix.bytesperline = min;
    end

    min = fmt.fmt.pix.bytesperline * fmt.fmt.pix.height;
    if (fmt.fmt.pix.sizeimage < min) then
        fmt.fmt.pix.sizeimage = min;
    end

    print("---- pix format ----")
    print(string.format("  Dimension: %dX%d", fmt.fmt.pix.width, fmt.fmt.pix.height))
    print(string.format("      Pitch: %d", fmt.fmt.pix.bytesperline))
    print(string.format(" Size Image: %d", fmt.fmt.pix.sizeimage))
    print(string.format("     Format: %s", libc.getValueName(fmt.fmt.pix.pixelformat,v4l2_fourcc)))
    print(string.format("Color Space: %s", libc.getValueName(fmt.fmt.pix.colorspace, v4l2_colorspace)))
    print(string.format("      Field: %s", libc.getValueName(fmt.fmt.pix.field, v4l2_field)))

    init_read(fmt.fmt.pix.sizeimage);
end

--[[
struct v4l2_pix_format {
    uint32_t            width;
    uint32_t            height;
    uint32_t            pixelformat;
    uint32_t            field;      /* enum v4l2_field */
    uint32_t           bytesperline;    /* for padding, zero if unused */
    uint32_t            sizeimage;
    uint32_t            colorspace; /* enum v4l2_colorspace */
    uint32_t            priv;       /* private data, depends on pixelformat */
};
--]]
local function close_device(fd)
    if (-1 == libc.close(fd)) then
        errno_exit("close");
    end

    fd = -1;
end

local function open_device(dev_name)
--[[
        struct stat st;

        if (-1 == stat(dev_name, &st)) {
                fprintf(stderr, "Cannot identify '%s': %d, %s\n",
                         dev_name, errno, strerror(errno));
                exit(EXIT_FAILURE);
        }

        if (!S_ISCHR(st.st_mode)) {
                fprintf(stderr, "%s is no device\n", dev_name);
                exit(EXIT_FAILURE);
        }
--]]
    local fd = open(dev_name, libc.O_RDWR, int(0));

    if (-1 == fd) then
        errno_exit(string.format("Cannot open: '%s'", dev_name));
    end

    return fd;
end



local function main(argc, argv)
    local dev_name = "/dev/video0";

    local fd = open_device(dev_name);
    init_device(fd, dev_name);
    mainloop(fd);
    uninit_device(fd);
    close_device(fd);

    print();
        
    return true;
end

main(#arg, arg)
