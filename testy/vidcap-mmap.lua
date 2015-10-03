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


require ("videodev2")()

local int = ffi.typeof("int")

local function  CLEAR(x) 
    libc.memset(x, 0, ffi.sizeof(x))
end

--[[
local io_method = {
    IO_METHOD_READ = 0,
    IO_METHOD_MMAP = 1,
    IO_METHOD_USERPTR = 2,
};
--]]

ffi.cdef[[
struct buffer {
        void   *start;
        size_t  length;
};
]]

static char            *dev_name;
local   io = io_method.IO_METHOD_MMAP;
static int              fd = -1;
struct buffer          *buffers;
static unsigned int     n_buffers;
static int              out_buf;
static int              force_format;
static int              frame_count = 70;

local function errno_exit(s)
    libc.fprintf(io.stderr, "%s error %d, %s\n", s, errno, strerror(errno));
    error(EXOT_FAILURE);
end

local function xioctl(int fh, int request, void *arg)
    local r;

    do {
        r = libc.ioctl(fh, request, arg);
    } while (-1 == r && EINTR == errno);

    return r;
end

local function process_image(const void *p, int size)

        if (out_buf ~= nil) then
                fwrite(p, size, 1, stdout);
        end

        libc.fflush(io.stderr);
        libc.fprintf(io.stderr, ".");
        libc.fflush(io.stdout);
end

local function read_frame(fd)

        struct v4l2_buffer buf;
        unsigned int i;

        switch (io) {
        case IO_METHOD_READ:
                if (-1 == read(fd, buffers[0].start, buffers[0].length)) {
                        switch (errno) {
                        case EAGAIN:
                                return 0;

                        case EIO:
                                /* Could ignore EIO, see spec. */

                                /* fall through */

                        default:
                                errno_exit("read");
                        }
                }

                process_image(buffers[0].start, buffers[0].length);
                break;

        case IO_METHOD_MMAP:
                CLEAR(buf);

                buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
                buf.memory = V4L2_MEMORY_MMAP;

                if (-1 == xioctl(fd, VIDIOC_DQBUF, &buf)) {
                        switch (errno) {
                        case EAGAIN:
                                return 0;

                        case EIO:
                                /* Could ignore EIO, see spec. */

                                /* fall through */

                        default:
                                errno_exit("VIDIOC_DQBUF");
                        }
                }

                assert(buf.index < n_buffers);

                process_image(buffers[buf.index].start, buf.bytesused);

                if (-1 == xioctl(fd, VIDIOC_QBUF, &buf))
                        errno_exit("VIDIOC_QBUF");
                break;

        case IO_METHOD_USERPTR:
                CLEAR(buf);

                buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
                buf.memory = V4L2_MEMORY_USERPTR;

                if (-1 == xioctl(fd, VIDIOC_DQBUF, &buf)) {
                        switch (errno) {
                        case EAGAIN:
                                return 0;

                        case EIO:
                                /* Could ignore EIO, see spec. */

                                /* fall through */

                        default:
                                errno_exit("VIDIOC_DQBUF");
                        }
                }

                for (i = 0; i < n_buffers; ++i)
                        if (buf.m.userptr == (unsigned long)buffers[i].start
                            && buf.length == buffers[i].length)
                                break;

                assert(i < n_buffers);

                process_image((void *)buf.m.userptr, buf.bytesused);

                if (-1 == xioctl(fd, VIDIOC_QBUF, &buf))
                        errno_exit("VIDIOC_QBUF");
                break;
        }

        return 1;
end

local function mainloop(fd)

        local count = frame_count;

        while (count > 0) do
                while true do
                        fd_set fds;
                        struct timeval tv;
                        int r;

                        FD_ZERO(&fds);
                        FD_SET(fd, &fds);

                        /* Timeout. */
                        tv.tv_sec = 2;
                        tv.tv_usec = 0;

                        r = select(fd + 1, &fds, NULL, NULL, &tv);

                        if (-1 == r) then
                                if (EINTR == errno) then
                                        continue;
                                end
                                errno_exit("select");
                        end

                        if (0 == r) then
                                fprintf(stderr, "select timeout\n");
                                exit(EXIT_FAILURE);
                        end

                        if (read_frame(fd)) then
                                break;
                        end

                        -- EAGAIN - continue select loop.
                end
            count = count - 1;
        end
end

local function stop_capturing(fd)
    local atype = ffi.new("int[1]", V4L2_BUF_TYPE_VIDEO_CAPTURE);
    if (-1 == xioctl(fd, VIDIOC_STREAMOFF, atype)) then
        errno_exit("VIDIOC_STREAMOFF");
    end
end

local function start_capturing(fd)

        unsigned int i;
        enum v4l2_buf_type type;

                for (i = 0; i < n_buffers; ++i) {
                        struct v4l2_buffer buf;

                        CLEAR(buf);
                        buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
                        buf.memory = V4L2_MEMORY_MMAP;
                        buf.index = i;

                        if (-1 == xioctl(fd, VIDIOC_QBUF, &buf))
                                errno_exit("VIDIOC_QBUF");
                }
                type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
                if (-1 == xioctl(fd, VIDIOC_STREAMON, &type))
                        errno_exit("VIDIOC_STREAMON");

end

local function uninit_device()

    unsigned int i;

    for i = 0, n_buffers-1 do
        if (-1 == libc.munmap(buffers[i].start, buffers[i].length)) then
            errno_exit("munmap");
        end
    end

    libc.free(buffers);
end



local function init_mmap(fd)

    struct v4l2_requestbuffers req;

    CLEAR(req);

    req.count = 4;
    req.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    req.memory = V4L2_MEMORY_MMAP;

    if (-1 == xioctl(fd, VIDIOC_REQBUFS, &req)) {
                if (EINVAL == errno) {
                        fprintf(stderr, "%s does not support "
                                 "memory mapping\n", dev_name);
                        exit(EXIT_FAILURE);
                } else {
                        errno_exit("VIDIOC_REQBUFS");
                }
    }

    if (req.count < 2) 
    {
                fprintf(stderr, "Insufficient buffer memory on %s\n",
                         dev_name);
                exit(EXIT_FAILURE);
    }

    buffers = calloc(req.count, sizeof(*buffers));

    if (!buffers) {
                fprintf(stderr, "Out of memory\n");
                exit(EXIT_FAILURE);
    }

    for (n_buffers = 0; n_buffers < req.count; ++n_buffers) {
                struct v4l2_buffer buf;

                CLEAR(buf);

                buf.type        = V4L2_BUF_TYPE_VIDEO_CAPTURE;
                buf.memory      = V4L2_MEMORY_MMAP;
                buf.index       = n_buffers;

                if (-1 == xioctl(fd, VIDIOC_QUERYBUF, &buf))
                        errno_exit("VIDIOC_QUERYBUF");

                buffers[n_buffers].length = buf.length;
                buffers[n_buffers].start =
                        mmap(NULL /* start anywhere */,
                              buf.length,
                              PROT_READ | PROT_WRITE /* required */,
                              MAP_SHARED /* recommended */,
                              fd, buf.m.offset);

                if (MAP_FAILED == buffers[n_buffers].start)
                        errno_exit("mmap");
    }
end


local function init_device(fd)

        struct v4l2_capability cap;
        struct v4l2_cropcap cropcap;
        struct v4l2_crop crop;
        struct v4l2_format fmt;
        unsigned int min;

        if (-1 == xioctl(fd, VIDIOC_QUERYCAP, &cap)) {
                if (EINVAL == errno) {
                        fprintf(stderr, "%s is no V4L2 device\n",
                                 dev_name);
                        exit(EXIT_FAILURE);
                } else {
                        errno_exit("VIDIOC_QUERYCAP");
                }
        }

        if (!(cap.capabilities & V4L2_CAP_VIDEO_CAPTURE)) {
                fprintf(stderr, "%s is no video capture device\n",
                         dev_name);
                exit(EXIT_FAILURE);
        }


        --  case IO_METHOD_MMAP:
        if (!(cap.capabilities & V4L2_CAP_STREAMING)) then
                        fprintf(io.stderr, "%s does not support streaming i/o\n",
                                 dev_name);
                        exit(EXIT_FAILURE);
        end



        -- Select video input, video standard and tune here.


        CLEAR(cropcap);

        cropcap.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;

        if (0 == xioctl(fd, VIDIOC_CROPCAP, &cropcap)) then
                crop.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
                crop.c = cropcap.defrect; -- reset to default

                if (-1 == xioctl(fd, VIDIOC_S_CROP, &crop)) then
                        switch (errno) {
                        case EINVAL:
                                -- Cropping not supported.
                                break;
                        default:
                                -- Errors ignored.
                                break;
                        }
                end
        else
                -- Errors ignored.
        end


        CLEAR(fmt);

        fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        if (force_format) then
                fmt.fmt.pix.width       = 640;
                fmt.fmt.pix.height      = 480;
                fmt.fmt.pix.pixelformat = V4L2_PIX_FMT_YUYV;
                fmt.fmt.pix.field       = V4L2_FIELD_INTERLACED;

                if (-1 == xioctl(fd, VIDIOC_S_FMT, &fmt)) then
                        errno_exit("VIDIOC_S_FMT");
                end

                -- Note VIDIOC_S_FMT may change width and height.
        else
                -- Preserve original settings as set by v4l2-ctl for example 
                if (-1 == xioctl(fd, VIDIOC_G_FMT, &fmt)) then
                        errno_exit("VIDIOC_G_FMT");
                end
        end

        -- Buggy driver paranoia. 
        min = fmt.fmt.pix.width * 2;
        if (fmt.fmt.pix.bytesperline < min) then
                fmt.fmt.pix.bytesperline = min;
        end
        min = fmt.fmt.pix.bytesperline * fmt.fmt.pix.height;
        if (fmt.fmt.pix.sizeimage < min) then
                fmt.fmt.pix.sizeimage = min;
        end


    init_mmap(fd);
end

local function close_device(fd)
    if (-1 == libc.close(fd)) then
        errno_exit("close");
    end

    fd = -1;
end

local function open_device(dev_name)
        local fd = -1;

        local st = ffi.new("struct stat");

        if (-1 == libc.stat(dev_name, st)) then
                fprintf(io.stderr, "Cannot identify '%s': %d, %s\n",
                         dev_name, ffi.errno(), libc.strerror(ffi.errno()));
                exit(EXIT_FAILURE);
        end

        if (!S_ISCHR(st.st_mode)) then
                libc.fprintf(io.stderr, "%s is no device\n", dev_name);
                error(EXIT_FAILURE);
        end

        fd = open(dev_name, bor(libc.O_RDWR, libc.O_NONBLOCK), int(0));

        if (-1 == fd) then
                libc.fprintf(stderr, "Cannot open '%s': %d, %s\n",
                         dev_name, errno, strerror(errno));
                error(EXIT_FAILURE);
        end
end

local function usage(FILE *fp, int argc, char **argv)

        libc.fprintf(fp,
                 "Usage: %s [options]\n\n"
                 "Version 1.0\n"
                 "Options:\n"
                 "-d | --device name   Video device name [%s]\n"
                 "-h | --help          Print this message\n"
                 "-o | --output        Outputs stream to stdout\n"
                 "-f | --format        Force format to 640x480 YUYV\n"
                 "-c | --count         Number of frames to grab [%i]\n"
                 "",
                 argv[0], dev_name, frame_count);
end

--[[
local short_options[] = "d:hmruofc:";

static const struct option
long_options[] = {
        { "device", required_argument, NULL, 'd' },
        { "help",   no_argument,       NULL, 'h' },
        { "mmap",   no_argument,       NULL, 'm' },
        { "read",   no_argument,       NULL, 'r' },
        { "userp",  no_argument,       NULL, 'u' },
        { "output", no_argument,       NULL, 'o' },
        { "format", no_argument,       NULL, 'f' },
        { "count",  required_argument, NULL, 'c' },
        { 0, 0, 0, 0 }
};
--]]

local function main(argc, argv)

    local dev_name = "/dev/video0";

        for (;;) {
                int idx;
                int c;open_device

                c = getopt_long(argc, argv,
                                short_options, long_options, &idx);

                if (-1 == c)
                        break;

                switch (c) {
                case 0: /* getopt_long() flag */
                        break;

                case 'd':
                        dev_name = optarg;
                        break;

                case 'h':
                        usage(stdout, argc, argv);
                        exit(EXIT_SUCCESS);

                case 'm':
                        io = IO_METHOD_MMAP;
                        break;



                case 'o':
                        out_buf++;
                        break;

                case 'f':
                        force_format++;
                        break;

                case 'c':
                        errno = 0;
                        frame_count = strtol(optarg, NULL, 0);
                        if (errno)
                                errno_exit(optarg);
                        break;

                default:
                        usage(io.stderr, argc, argv);
                        error(EXIT_FAILURE);
                }
        }

    local fd = open_device(dev_name);
    init_device(fd);
    start_capturing(fd);
    mainloop();
    stop_capturing(fd);
    uninit_device();
    close_device(fd);
    libc.fprintf(io.stderr, "\n");
        
    return true;
end

main(#arg, arg)
