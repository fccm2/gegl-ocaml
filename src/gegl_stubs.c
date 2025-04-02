/* Copyright (C) 2025 Florent Monnier
   Permission to use, copy, modify, and/or distribute this software.
   (See the file License for details.)
*/
#define CAML_NAME_SPACE 1
#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/fail.h>
#include <caml/custom.h>

#include <gegl.h>
#include <babl/babl.h>


/* GeglRectangle rect */

static value Val_gegl_rectangle(GeglRectangle *rect)
{
  value v = caml_alloc(1, Abstract_tag);
  *((GeglRectangle **) Data_abstract_val(v)) = rect;
  return v;
}

#define Gegl_rectangle_val(r) \
  *((GeglRectangle **) Data_abstract_val(r))


/* GeglColor color */

static value Val_gegl_color(GeglColor *color)
{
  value v = caml_alloc(1, Abstract_tag);
  *((GeglColor **) Data_abstract_val(v)) = color;
  return v;
}

#define Gegl_color_val(r) \
  *((GeglColor **) Data_abstract_val(r))


/* GeglPath path */

static value Val_gegl_path(GeglPath *path)
{
  value v = caml_alloc(1, Abstract_tag);
  *((GeglPath **) Data_abstract_val(v)) = path;
  return v;
}

#define Gegl_path_val(r) \
  *((GeglPath **) Data_abstract_val(r))


/* GeglBuffer */

static value Val_gegl_buffer(GeglBuffer *buffer)
{
  value v = caml_alloc(1, Abstract_tag);
  *((GeglBuffer **) Data_abstract_val(v)) = buffer;
  return v;
}

#define Gegl_buffer_val(b) \
  *((GeglBuffer **) Data_abstract_val(b))


/* GeglNode */

static value Val_gegl_node(GeglNode *node)
{
  value v = caml_alloc(1, Abstract_tag);
  *((GeglNode **) Data_abstract_val(v)) = node;
  return v;
}

#define Gegl_node_val(n) \
  *((GeglNode **) Data_abstract_val(n))


/* (Babl *) */

static value Val_babl(const Babl *b)
{
  value v = caml_alloc(1, Abstract_tag);
  *((const Babl **) Data_abstract_val(v)) = b;
  return v;
}

#define Babl_val(b) \
  *((Babl **) Data_abstract_val(b))


/* Functions */

CAMLprim value
caml_gegl_init(value caml_argv)
{
  int argc = 0;
  char **argv = NULL;

  // Initialises Gegl
  gegl_init(&argc, &argv);

  return Val_unit;
}

CAMLprim value
caml_gegl_exit(value u)
{
  // Exit Gegl
  gegl_exit();
  return Val_unit;
}

CAMLprim value
caml_alloc_gegl_rectangle_new(value r)
{
  // Alloc Gegl rectangle
  GeglRectangle *rect = caml_stat_alloc(sizeof(GeglRectangle));
  rect->x      = Long_val(Field(r,0));
  rect->y      = Long_val(Field(r,1));
  rect->width  = Long_val(Field(r,2));
  rect->height = Long_val(Field(r,3));
  return Val_gegl_rectangle(rect);
}

CAMLprim value
caml_babl_format(value s)
{
  // Define color format
  const Babl *format = babl_format(String_val(s));
  return Val_babl(format);
}

CAMLprim value
caml_gegl_buffer_new(value r, value fmt)
{
  GeglRectangle *rect = Gegl_rectangle_val(r);
  const Babl *format = Babl_val(fmt);

  // Create a Gegl buffer
  GeglBuffer *buffer = gegl_buffer_new(rect, format);
  return Val_gegl_buffer(buffer);
}

CAMLprim value
caml_gegl_buffer_set(value b, value r, value fmt, value s)
{
  GeglBuffer *buffer = Gegl_buffer_val(b);
  GeglRectangle *rect = Gegl_rectangle_val(r);
  const Babl *format = Babl_val(fmt);

  int len = caml_string_length(s);
  int n = 4 * rect->width * rect->height * sizeof(float);

  if (n != len) {
    caml_failwith("gegl_buffer_set: size mismatch");
  }

  // Write the data into the Gegl buffer
  gegl_buffer_set(buffer, rect, 0, format, Bytes_val(s), rect->width * 4 * sizeof(float));

  return Val_unit;
}

CAMLprim value
caml_gegl_buffer_unref(value b)
{
  GeglBuffer *buffer = Gegl_buffer_val(b);

  // Use g_object_unref() to free the buffer
  g_object_unref(G_OBJECT(buffer));

  return Val_unit;
}

CAMLprim value
caml_gegl_node_unref(value n)
{
  GeglNode *node = Gegl_node_val(n);

  // Use g_object_unref() to free the node
  g_object_unref(G_OBJECT(node));

  return Val_unit;
}

CAMLprim value
caml_gegl_node_new(value u)
{
  // Create a Gegl node for image manipulation
  GeglNode *node = gegl_node_new();

  return Val_gegl_node(node);
}

CAMLprim value
caml_gegl_node_buffer_source(value n, value b)
{
  GeglNode *node = Gegl_node_val(n);
  GeglBuffer *buffer = Gegl_buffer_val(b);

  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:buffer-source",
    "buffer", buffer,
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_png_save(value n, value s)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:png-save",
    "path", String_val(s),
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_jpg_save(value n, value s, value q, value u)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:jpg-save",
    "quality", (Is_none(q) ? 90 : Long_val(Some_val(q))),
    "path", String_val(s),
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_png_load(value n, value s)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:png-load",
    "path", String_val(s),
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_jpg_load(value n, value s)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:jpg-load",
    "path", String_val(s),
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_svg_load(value n, value s)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:svg-load",
    "path", String_val(s),
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_perlin_noise(value n)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:perlin-noise",
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_plasma(value n, value w, value h, value s)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:plasma",
    "width", Long_val(w),
    "height", Long_val(h),
    "seed", Long_val(s),
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_display(value n, value w)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:display",
    "window-title", String_val(w),
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_crop(value n, value x, value y, value w, value h, value b)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:crop",
    "x", Double_val(x),
    "y", Double_val(y),
    "width", Double_val(w),
    "height", Double_val(h),
    "reset-origin", Bool_val(b),
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_crop_bytecode(value * argv, int argn)
{
  return caml_gegl_node_crop(
    argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}

CAMLprim value
caml_gegl_node_gaussian_blur(value n, value x, value y)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:gaussian-blur",
    "std-dev-x", Double_val(x),
    "std-dev-y", Double_val(y),
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_edge_sobel(value n)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:edge-sobel",
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_image_gradient(value n)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:image-gradient",
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_edge_neon(value n, value r, value a)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:edge-neon",
    "radius", Double_val(r),
    "amount", Double_val(a),
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_noise_pick(value n, value pr, value r, value s)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:noise-pick",
    "pct-random", Double_val(pr),
    "repeat", Int_val(r),
    "seed", (guint) Int_val(s),
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_slic(value n)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:slic",
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_waterpixels(value n)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:waterpixels",
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_threshold(value n)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:threshold",
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_brightness_contrast(value n, value b, value c)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:brightness-contrast",
    "brightness", Double_val(b),
    "contrast", Double_val(c),
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_negative_darkroom(value n)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:negative-darkroom",
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_normal_map(value n)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:normal-map",
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_dither(value n)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:dither",
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_pixelize(value n)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:pixelize",
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_invert_linear(value n)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:invert-linear",
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_newsprint(value n)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:newsprint",
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_compose(value n, value c)
{
  GeglNode *node = Gegl_node_val(n);
  gchar *compose_op = NULL;
  switch (Long_val(c))
  { case 0: compose_op = "gegl:multiply"; break;
    case 1: compose_op = "gegl:difference"; break;
    case 2: compose_op = "gegl:screen"; break;
    case 3: compose_op = "gegl:overlay"; break;
    case 4: compose_op = "gegl:subtract"; break;
    case 5: compose_op = "gegl:exclusion"; break;
    default: caml_failwith("compose_op");
  }

  GeglNode *child = gegl_node_new_child(node,
    "operation", compose_op,
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_connect_to(value n1, value n2)
{
  GeglNode *node1 = Gegl_node_val(n1);
  GeglNode *node2 = Gegl_node_val(n2);

  // Connect nodes
  gegl_node_connect_to(node1, "output", node2, "input");

  return Val_unit;
}

CAMLprim value
caml_gegl_node_connect_to2(value n1, value n2)
{
  GeglNode *node1 = Gegl_node_val(n1);
  GeglNode *node2 = Gegl_node_val(n2);

  // Connect nodes
  gegl_node_connect_to(node1, "output", node2, "aux");

  return Val_unit;
}

CAMLprim value
caml_gegl_node_process(value n)
{
  GeglNode *node = Gegl_node_val(n);

  // Process operations
  gegl_node_process(node);

  return Val_unit;
}

CAMLprim value
caml_gegl_color_new(value s)
{
  GeglColor *color = gegl_color_new(String_val(s));

  return Val_gegl_color(color);
}

CAMLprim value
caml_gegl_path_new(value u)
{
  GeglPath *path = gegl_path_new();

  return Val_gegl_path(path);
}

CAMLprim value
caml_gegl_path_new_from_string(value s)
{
  GeglPath *path = gegl_path_new_from_string(String_val(s));

  return Val_gegl_path(path);
}

CAMLprim value
caml_gegl_path_move_to(value _path, value p)
{
  GeglPath *path = Gegl_path_val(_path);
  GeglPathItem pi;

  pi.type = 'M';
  pi.point[0].x = Double_val(Field(p,0));
  pi.point[0].y = Double_val(Field(p,1));
  gegl_path_insert_node(path, -1, &pi);

  return Val_unit;
}

CAMLprim value
caml_gegl_path_line_to(value _path, value p)
{
  GeglPath *path = Gegl_path_val(_path);
  GeglPathItem pi;

  pi.type = 'L';
  pi.point[0].x = Double_val(Field(p,0));
  pi.point[0].y = Double_val(Field(p,1));
  gegl_path_insert_node(path, -1, &pi);

  return Val_unit;
}

CAMLprim value
caml_gegl_path_curve_to(value _path, value p1, value p2, value p3)
{
  GeglPath *path = Gegl_path_val(_path);
  GeglPathItem pi;

  pi.type = 'C';
  pi.point[0].x = Double_val(Field(p1,0));
  pi.point[0].y = Double_val(Field(p1,1));
  pi.point[1].x = Double_val(Field(p2,0));
  pi.point[1].y = Double_val(Field(p2,1));
  pi.point[2].x = Double_val(Field(p3,0));
  pi.point[2].y = Double_val(Field(p3,1));
  gegl_path_insert_node(path, -1, &pi);

  return Val_unit;
}

CAMLprim value
caml_gegl_node_fill_path(value n, value p, value c)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:fill-path",
    "d", Gegl_path_val(p),
    "color", Gegl_color_val(c),
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_node_vector_stroke(value n, value p, value c)
{
  GeglNode *node = Gegl_node_val(n);
  GeglNode *child = gegl_node_new_child(node,
    "operation", "gegl:vector-stroke",
    "d", Gegl_path_val(p),
    "color", Gegl_color_val(c),
    NULL);

  return Val_gegl_node(child);
}

CAMLprim value
caml_gegl_list_operations(value u)
{
  CAMLparam1(u);
  CAMLlocal1(arr);

  gchar **operations;
  guint   n_operations;
  gint i;

  operations = gegl_list_operations(&n_operations);
 
  arr = caml_alloc(n_operations, 0);

  for (i=0; i < n_operations; i++)
  {
    Store_field(arr, i, caml_copy_string(operations[i]));
  }

  g_free(operations);

  CAMLreturn(arr);
}

CAMLprim value
caml_gegl_operation_list_properties(value operation)
{
  CAMLparam1(operation);
  CAMLlocal2(arr, property);

  guint n_properties, i;
  GParamSpec **properties =
    gegl_operation_list_properties(String_val(operation), &n_properties);

  if (!properties) {
    caml_failwith("gegl_operation_list_properties: no properties found");
  }

  arr = caml_alloc(n_properties, 0);

  for (i = 0; i < n_properties; i++) {
    GParamSpec *param = properties[i];
    GType t = param->value_type;

    property = caml_alloc(2, 0);
    Store_field(property, 0, caml_copy_string(g_param_spec_get_name(param)));
    Store_field(property, 1, caml_copy_string(g_type_name(t)));

    Store_field(arr, i, property);
  }

  g_free(properties);

  CAMLreturn(arr);
}

