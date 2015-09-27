local ffi = require("ffi")
local ENUM = ffi.C;
local bit = require("bit")
local band, bor, bnot = bit.band, bit.bor, bit.bnot;
local lshift, rshift = bit.lshift, bit.rshift;

local Lib_pixman = require("pixman_ffi")


local Constants = {}


local Enums = {
    pixman_repeat_t = 
    {
        PIXMAN_REPEAT_NONE = ENUM.PIXMAN_REPEAT_NONE,
        PIXMAN_REPEAT_NORMAL = ENUM.PIXMAN_REPEAT_NORMAL,
        PIXMAN_REPEAT_PAD = ENUM.PIXMAN_REPEAT_PAD,
        PIXMAN_REPEAT_REFLECT = ENUM.PIXMAN_REPEAT_REFLECT
    };

    pixman_filter_t = 
    {
    PIXMAN_FILTER_FAST = ENUM.PIXMAN_FILTER_FAST,
    PIXMAN_FILTER_GOOD = ENUM.PIXMAN_FILTER_GOOD,
    PIXMAN_FILTER_BEST = ENUM.PIXMAN_FILTER_BEST,
    PIXMAN_FILTER_NEAREST = ENUM.PIXMAN_FILTER_NEAREST,
    PIXMAN_FILTER_BILINEAR = ENUM.PIXMAN_FILTER_BILINEAR,
    PIXMAN_FILTER_CONVOLUTION = ENUM.PIXMAN_FILTER_CONVOLUTION,
    PIXMAN_FILTER_SEPARABLE_CONVOLUTION = ENUM.PIXMAN_FILTER_SEPARABLE_CONVOLUTION
    };



    pixman_op_t = 
    {
    PIXMAN_OP_CLEAR         = 0x00,
    PIXMAN_OP_SRC           = 0x01,
    PIXMAN_OP_DST           = 0x02,
    PIXMAN_OP_OVER          = 0x03,
    PIXMAN_OP_OVER_REVERSE      = 0x04,
    PIXMAN_OP_IN            = 0x05,
    PIXMAN_OP_IN_REVERSE        = 0x06,
    PIXMAN_OP_OUT           = 0x07,
    PIXMAN_OP_OUT_REVERSE       = 0x08,
    PIXMAN_OP_ATOP          = 0x09,
    PIXMAN_OP_ATOP_REVERSE      = 0x0a,
    PIXMAN_OP_XOR           = 0x0b,
    PIXMAN_OP_ADD           = 0x0c,
    PIXMAN_OP_SATURATE          = 0x0d,

    PIXMAN_OP_DISJOINT_CLEAR        = 0x10,
    PIXMAN_OP_DISJOINT_SRC      = 0x11,
    PIXMAN_OP_DISJOINT_DST      = 0x12,
    PIXMAN_OP_DISJOINT_OVER     = 0x13,
    PIXMAN_OP_DISJOINT_OVER_REVERSE = 0x14,
    PIXMAN_OP_DISJOINT_IN       = 0x15,
    PIXMAN_OP_DISJOINT_IN_REVERSE   = 0x16,
    PIXMAN_OP_DISJOINT_OUT      = 0x17,
    PIXMAN_OP_DISJOINT_OUT_REVERSE  = 0x18,
    PIXMAN_OP_DISJOINT_ATOP     = 0x19,
    PIXMAN_OP_DISJOINT_ATOP_REVERSE = 0x1a,
    PIXMAN_OP_DISJOINT_XOR      = 0x1b,

    PIXMAN_OP_CONJOINT_CLEAR        = 0x20,
    PIXMAN_OP_CONJOINT_SRC      = 0x21,
    PIXMAN_OP_CONJOINT_DST      = 0x22,
    PIXMAN_OP_CONJOINT_OVER     = 0x23,
    PIXMAN_OP_CONJOINT_OVER_REVERSE = 0x24,
    PIXMAN_OP_CONJOINT_IN       = 0x25,
    PIXMAN_OP_CONJOINT_IN_REVERSE   = 0x26,
    PIXMAN_OP_CONJOINT_OUT      = 0x27,
    PIXMAN_OP_CONJOINT_OUT_REVERSE  = 0x28,
    PIXMAN_OP_CONJOINT_ATOP     = 0x29,
    PIXMAN_OP_CONJOINT_ATOP_REVERSE = 0x2a,
    PIXMAN_OP_CONJOINT_XOR      = 0x2b,

    PIXMAN_OP_MULTIPLY                  = 0x30,
    PIXMAN_OP_SCREEN                    = 0x31,
    PIXMAN_OP_OVERLAY                   = 0x32,
    PIXMAN_OP_DARKEN                    = 0x33,
    PIXMAN_OP_LIGHTEN                   = 0x34,
    PIXMAN_OP_COLOR_DODGE               = 0x35,
    PIXMAN_OP_COLOR_BURN                = 0x36,
    PIXMAN_OP_HARD_LIGHT                = 0x37,
    PIXMAN_OP_SOFT_LIGHT                = 0x38,
    PIXMAN_OP_DIFFERENCE                = 0x39,
    PIXMAN_OP_EXCLUSION                 = 0x3a,
    PIXMAN_OP_HSL_HUE           = 0x3b,
    PIXMAN_OP_HSL_SATURATION        = 0x3c,
    PIXMAN_OP_HSL_COLOR         = 0x3d,
    PIXMAN_OP_HSL_LUMINOSITY        = 0x3e
    } ;

    pixman_region_overlap_t = 
    {
        PIXMAN_REGION_OUT = ENUM.PIXMAN_REGION_OUT,
        PIXMAN_REGION_IN = ENUM.PIXMAN_REGION_IN,
        PIXMAN_REGION_PART = ENUM.PIXMAN_REGION_PART
    };



pixman_format_code_t = {
PIXMAN_a8r8g8b8 = 0x20028888,
PIXMAN_x8r8g8b8 = 0x20020888,
PIXMAN_a8b8g8r8 = 0x20038888,
PIXMAN_x8b8g8r8 = 0x20030888,
PIXMAN_b8g8r8a8 = 0x20088888,
PIXMAN_b8g8r8x8 = 0x20080888,
PIXMAN_r8g8b8a8 = 0x20098888,
PIXMAN_r8g8b8x8 = 0x20090888,
PIXMAN_x14r6g6b6 = 0x20020666,
PIXMAN_x2r10g10b10 = 0x20020aaa,
PIXMAN_a2r10g10b10 = 0x20022aaa,
PIXMAN_x2b10g10r10 = 0x20030aaa,
PIXMAN_a2b10g10r10 = 0x20032aaa,
PIXMAN_a8r8g8b8_sRGB = 0x200a8888,
PIXMAN_r8g8b8 = 0x18020888,
PIXMAN_b8g8r8 = 0x18030888,
PIXMAN_r5g6b5 = 0x10020565,
PIXMAN_b5g6r5 = 0x10030565,
PIXMAN_a1r5g5b5 = 0x10021555,
PIXMAN_x1r5g5b5 = 0x10020555,
PIXMAN_a1b5g5r5 = 0x10031555,
PIXMAN_x1b5g5r5 = 0x10030555,
PIXMAN_a4r4g4b4 = 0x10024444,
PIXMAN_x4r4g4b4 = 0x10020444,
PIXMAN_a4b4g4r4 = 0x10034444,
PIXMAN_x4b4g4r4 = 0x10030444,
PIXMAN_a8 = 0x8018000,
PIXMAN_r3g3b2 = 0x8020332,
PIXMAN_b2g3r3 = 0x8030332,
PIXMAN_a2r2g2b2 = 0x8022222,
PIXMAN_a2b2g2r2 = 0x8032222,
PIXMAN_c8 = 0x8040000,
PIXMAN_g8 = 0x8050000,
PIXMAN_x4a4 = 0x8014000,
PIXMAN_x4c4 = 0x8040000,
PIXMAN_x4g4 = 0x8050000,
PIXMAN_a4 = 0x4014000,
PIXMAN_r1g2b1 = 0x4020121,
PIXMAN_b1g2r1 = 0x4030121,
PIXMAN_a1r1g1b1 = 0x4021111,
PIXMAN_a1b1g1r1 = 0x4031111,
PIXMAN_c4 = 0x4040000,
PIXMAN_g4 = 0x4050000,
PIXMAN_a1 = 0x1011000,
PIXMAN_g1 = 0x1050000,
PIXMAN_yuy2 = 0x10060000,
PIXMAN_yv12 = 0xc070000
} ;

}


--[[
    All the types that are declared in the library
--]]
local Types = {
    pixman_bool_t = ffi.typeof("pixman_bool_t");
    pixman_fixed_32_32_t = ffi.typeof("pixman_fixed_32_32_t");
    pixman_fixed_48_16_t = ffi.typeof("pixman_fixed_48_16_t");
    pixman_fixed_1_31_t = ffi.typeof("pixman_fixed_1_31_t");
    pixman_fixed_1_16_t = ffi.typeof("pixman_fixed_1_16_t");
    pixman_fixed_16_16_t = ffi.typeof("pixman_fixed_16_16_t");
    pixman_fixed_t = ffi.typeof("pixman_fixed_t");

    pixman_color = ffi.typeof("struct pixman_color");
    pixman_point_fixed = ffi.typeof("struct pixman_point_fixed");
    pixman_line_fixed = ffi.typeof("struct pixman_line_fixed");

    pixman_vector = ffi.typeof("struct pixman_vector");
    pixman_transform = ffi.typeof("struct pixman_transform");

    -- floating point matrices
    pixman_f_transform_t = ffi.typeof("pixman_f_transform_t");
    pixman_f_vector_t = ffi.typeof("pixman_f_vector_t");
    pixman_f_vector = ffi.typeof("struct pixman_f_vector");
    pixman_f_transform = ffi.typeof("struct pixman_f_transform");

    -- Regions
    pixman_region16_data_t = ffi.typeof("pixman_region16_data_t");
    pixman_box16_t = ffi.typeof("pixman_box16_t");
    pixman_rectangle16_t = ffi.typeof("pixman_rectangle16_t");
    pixman_region16_t = ffi.typeof("pixman_region16_t");

    pixman_region16_data = ffi.typeof("struct pixman_region16_data");
    pixman_rectangle16 = ffi.typeof("struct pixman_rectangle16");
    pixman_box16 = ffi.typeof("struct pixman_box16");
    pixman_region16 = ffi.typeof("struct pixman_region16");

    pixman_gradient_stop = ffi.typeof("struct pixman_gradient_stop");
 
    pixman_indexed = ffi.typeof("struct pixman_indexed");

    -- 32-bit regions
    pixman_region32_data = ffi.typeof("struct pixman_region32_data");
    pixman_rectangle32 = ffi.typeof("struct pixman_rectangle32");
    pixman_box32 = ffi.typeof("struct pixman_box32");
    pixman_region32 = ffi.typeof("struct pixman_region32");

    pixman_glyph_t = ffi.typeof("pixman_glyph_t");

    pixman_edge = ffi.typeof("struct pixman_edge");
    pixman_trapezoid = ffi.typeof("struct pixman_trapezoid");
    pixman_triangle = ffi.typeof("struct pixman_triangle");
    pixman_span_fix = ffi.typeof("struct pixman_span_fix");
    pixman_trap = ffi.typeof("struct pixman_trap");
}

Types.pixman_gradient_stop_t = Types.pixman_gradient_stop;

--[[
    Filling out this list of functions is a convenience for putting the 
    functions pointers into the global namespace.  This table is needed
    in the least, as you can access the functions more quickly using the
    library references directly.
--]]
local Functions = {
    -- Transforms
    pixman_transform_init_identity = Lib_pixman.pixman_transform_init_identity;
    pixman_transform_point_3d = Lib_pixman.pixman_transform_point_3d;
    pixman_transform_point = Lib_pixman.pixman_transform_point;
    pixman_transform_multiply = Lib_pixman.pixman_transform_multiply;
    pixman_transform_init_scale = Lib_pixman.pixman_transform_init_scale;
    pixman_transform_scale = Lib_pixman.pixman_transform_scale;
    pixman_transform_init_rotate = Lib_pixman.pixman_transform_init_rotate;
    pixman_transform_rotate = Lib_pixman.pixman_transform_rotate;
    pixman_transform_init_translate = Lib_pixman.pixman_transform_init_translate;
    pixman_transform_translate = Lib_pixman.pixman_transform_translate;
    pixman_transform_bounds = Lib_pixman.pixman_transform_bounds;
    pixman_transform_invert = Lib_pixman.pixman_transform_invert;
    pixman_transform_is_identity = Lib_pixman.pixman_transform_is_identity;
    pixman_transform_is_scale = Lib_pixman.pixman_transform_is_scale;
    pixman_transform_is_int_translate = Lib_pixman.pixman_transform_is_int_translate;
    pixman_transform_is_inverse = Lib_pixman.pixman_transform_is_inverse;

    -- Floating point transforms
    pixman_transform_from_pixman_f_transform= Lib_pixman.pixman_transform_from_pixman_f_transform;
    pixman_f_transform_from_pixman_transform= Lib_pixman.pixman_f_transform_from_pixman_transform;
    pixman_f_transform_invert= Lib_pixman.pixman_f_transform_invert;
    pixman_f_transform_point= Lib_pixman.pixman_f_transform_point;
    pixman_f_transform_point_3d= Lib_pixman.pixman_f_transform_point_3d;
    pixman_f_transform_multiply= Lib_pixman.pixman_f_transform_multiply;
    pixman_f_transform_init_scale= Lib_pixman.pixman_f_transform_init_scale;
    pixman_f_transform_scale= Lib_pixman.pixman_f_transform_scale;
    pixman_f_transform_init_rotate= Lib_pixman.pixman_f_transform_init_rotate;
    pixman_f_transform_rotate= Lib_pixman.pixman_f_transform_rotate;
    pixman_f_transform_init_translate= Lib_pixman.pixman_f_transform_init_translate;
    pixman_f_transform_translate= Lib_pixman.pixman_f_transform_translate;
    pixman_f_transform_bounds= Lib_pixman.pixman_f_transform_bounds;
    pixman_f_transform_init_identity= Lib_pixman.pixman_f_transform_init_identity;

    -- Regions
    pixman_region_init = Lib_pixman.pixman_region_init;
    pixman_region_init_rect = Lib_pixman.pixman_region_init_rect;
    pixman_region_init_rects = Lib_pixman.pixman_region_init_rects;
    pixman_region_init_with_extents = Lib_pixman.pixman_region_init_with_extents;
    pixman_region_init_from_image = Lib_pixman.pixman_region_init_from_image;
    pixman_region_fini = Lib_pixman.pixman_region_fini;
    pixman_region_translate = Lib_pixman.pixman_region_translate;
    pixman_region_copy = Lib_pixman.pixman_region_copy;
    pixman_region_intersect = Lib_pixman.pixman_region_intersect;
    pixman_region_union = Lib_pixman.pixman_region_union;
    pixman_region_union_rect = Lib_pixman.pixman_region_union_rect;
    pixman_region_intersect_rect = Lib_pixman.pixman_region_intersect_rect;
    pixman_region_subtract = Lib_pixman.pixman_region_subtract;
    pixman_region_inverse = Lib_pixman.pixman_region_inverse;
    pixman_region_contains_point = Lib_pixman.pixman_region_contains_point;
    pixman_region_contains_rectangle = Lib_pixman.pixman_region_contains_rectangle;
    pixman_region_not_empty = Lib_pixman.pixman_region_not_empty;
    pixman_region_extents = Lib_pixman.pixman_region_extents;
    pixman_region_n_rects = Lib_pixman.pixman_region_n_rects;
    pixman_region_rectangles = Lib_pixman.pixman_region_rectangles;
    pixman_region_equal = Lib_pixman.pixman_region_equal;
    pixman_region_selfcheck = Lib_pixman.pixman_region_selfcheck;
    pixman_region_reset = Lib_pixman.pixman_region_reset;
    pixman_region_clear = Lib_pixman.pixman_region_clear;

    -- Region32
    -- Miscellaneous
    pixman_blt = Lib_pixman.pixman_blt;
    pixman_fill = Lib_pixman.pixman_fill;
    pixman_version = Lib_pixman.pixman_version;
    pixman_version_string = Lib_pixman.pixman_version_string;

    -- Image Constructors
    pixman_image_create_solid_fill = Lib_pixman.pixman_image_create_solid_fill;
    pixman_image_create_linear_gradient = Lib_pixman.pixman_image_create_linear_gradient;
    pixman_image_create_radial_gradient = Lib_pixman.pixman_image_create_radial_gradient;
    pixman_image_create_conical_gradient = Lib_pixman.pixman_image_create_conical_gradient;
    pixman_image_create_bits = Lib_pixman.pixman_image_create_bits;
    pixman_image_create_bits_no_clear = Lib_pixman.pixman_image_create_bits_no_clear;

    -- Image Destructors
    pixman_image_ref = Lib_pixman.pixman_image_ref;
    pixman_image_unref = Lib_pixman.pixman_image_unref;
    pixman_image_set_destroy_function = Lib_pixman.pixman_image_set_destroy_function;
    pixman_image_get_destroy_data = Lib_pixman.pixman_image_get_destroy_data;

    -- Image Properties
    pixman_image_set_clip_region = Lib_pixman.pixman_image_set_clip_region;
    pixman_image_set_clip_region32 = Lib_pixman.pixman_image_set_clip_region32;
    pixman_image_set_has_client_clip = Lib_pixman.pixman_image_set_has_client_clip;
    pixman_image_set_transform = Lib_pixman.pixman_image_set_transform;
    pixman_image_set_repeat = Lib_pixman.pixman_image_set_repeat;
    pixman_image_set_filter = Lib_pixman.pixman_image_set_filter;
    pixman_image_set_source_clipping = Lib_pixman.pixman_image_set_source_clipping;
    pixman_image_set_alpha_map = Lib_pixman.pixman_image_set_alpha_map;
    pixman_image_set_component_alpha = Lib_pixman.pixman_image_set_component_alpha;
    pixman_image_get_component_alpha = Lib_pixman.pixman_image_get_component_alpha;
    pixman_image_set_accessors = Lib_pixman.pixman_image_set_accessors;
    pixman_image_set_indexed = Lib_pixman.pixman_image_set_indexed;
    pixman_image_get_data = Lib_pixman.pixman_image_get_data;
    pixman_image_get_width = Lib_pixman.pixman_image_get_width;
    pixman_image_get_height = Lib_pixman.pixman_image_get_height;
    pixman_image_get_stride = Lib_pixman.pixman_image_get_stride;
    pixman_image_get_depth = Lib_pixman.pixman_image_get_depth;
    pixman_image_get_format = Lib_pixman.pixman_image_get_format;

    -- Compositing
    pixman_compute_composite_region = Lib_pixman.pixman_compute_composite_region;
    pixman_image_composite = Lib_pixman.pixman_image_composite;
    pixman_image_composite32 = Lib_pixman.pixman_image_composite32;

    -- Glyphs

    -- Trapezoid Library Functions
    pixman_sample_ceil_y = Lib_pixman.pixman_sample_ceil_y;
    pixman_sample_floor_y = Lib_pixman.pixman_sample_floor_y;
    pixman_edge_step = Lib_pixman.pixman_edge_step;
    pixman_edge_init = Lib_pixman.pixman_edge_init;
    pixman_line_fixed_edge_init = Lib_pixman.pixman_line_fixed_edge_init;
    pixman_rasterize_edges = Lib_pixman.pixman_rasterize_edges;
    pixman_add_traps = Lib_pixman.pixman_add_traps;
    pixman_add_trapezoids = Lib_pixman.pixman_add_trapezoids;
    pixman_rasterize_trapezoid = Lib_pixman.pixman_rasterize_trapezoid;
    pixman_composite_trapezoids = Lib_pixman.pixman_composite_trapezoids;
    pixman_composite_triangles = Lib_pixman.pixman_composite_triangles;
    pixman_add_triangles = Lib_pixman.pixman_add_triangles;
}

function Functions.pixman_fixed_to_int(f) return ffi.cast("int", rshift((f), 16)) end;
function Functions.pixman_int_to_fixed(i) return ffi.cast("pixman_fixed_t", lshift(i, 16)) end;
function Functions.pixman_fixed_to_double(f) return	ffi.cast("double", (f / ffi.cast("double", Constants.pixman_fixed_1))) end;
function Functions.pixman_double_to_fixed(d) return	ffi.cast("pixman_fixed_t", d * 65536.0) end;
function Functions.pixman_fixed_frac(f)	return	band(f, Constants.pixman_fixed_1_minus_e) end;
function Functions.pixman_fixed_floor(f) return	band(f, bnot(Constants.pixman_fixed_1_minus_e)) end;
function Functions.pixman_fixed_ceil(f)	return	Functions.pixman_fixed_floor (f + Constants.pixman_fixed_1_minus_e) end;
function Functions.pixman_fixed_fraction(f)	return band(f, Constants.pixman_fixed_1_minus_e) end;
function Functions.pixman_fixed_mod_2(f) return		band(f, bor(Constants.pixman_fixed1, Constants.pixman_fixed_1_minus_e)) end




Constants.pixman_fixed_e	= ffi.cast("pixman_fixed_t", 1);
Constants.pixman_fixed_1	= Functions.pixman_int_to_fixed(1);
Constants.pixman_fixed_1_minus_e	=	Constants.pixman_fixed_1 - Constants.pixman_fixed_e;
Constants.pixman_fixed_minus_1	=	Functions.pixman_int_to_fixed(-1);
Constants.pixman_max_fixed_48_16	=	tonumber(ffi.cast("pixman_fixed_48_16_t", 0x7fffffff));
Constants.pixman_min_fixed_48_16	=	tonumber(-ffi.cast("pixman_fixed_48_16_t", lshift(1, 31)));



--/* whether 't' is a well defined not obviously empty trapezoid */
function Functions.pixman_trapezoid_valid(t)   
    return (t.left.p1.y ~= t.left.p2.y and			   
     t.right.p1.y ~= t.right.p2.y and
     (t.bottom > t.top))
end


local exports = {
	Lib_pixman = Lib_pixman;

    Constants = Constants;
    Enums = Enums;
    Functions = Functions;
    Types = Types;
}

setmetatable(exports, {
    __call = function(self, tbl)
        tbl = tbl or _G;
        for k,v in pairs(self.Constants) do
            tbl[k] = v;
        end

        for k,v in pairs(self.Enums) do
            for key, value in pairs(v) do 
                tbl[key] = value;
            end
        end

        for k,v in pairs(self.Functions) do
            tbl[k] = v;
        end

        for k,v in pairs(self.Types) do
            tbl[k] = v;
        end
        
        return self;
    end,
})

return exports
