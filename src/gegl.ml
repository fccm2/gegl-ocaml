(* Copyright (C) 2025 Florent Monnier
   Permission to use, copy, modify, and/or distribute this software.
   (See the file License for details.)
*)

external gegl_init : string array -> unit
  = "caml_gegl_init"

let gegl_init () =
  gegl_init Sys.argv

external gegl_exit : unit -> unit
  = "caml_gegl_exit"

type gegl_rectangle
external gegl_rectangle : (int * int * int * int) -> gegl_rectangle
  = "caml_alloc_gegl_rectangle_new"

type gegl_color
external gegl_color_new : string -> gegl_color
  = "caml_gegl_color_new"

type gegl_path
external gegl_path_new : unit -> gegl_path
  = "caml_gegl_path_new"

external gegl_path_move_to : gegl_path -> float * float -> unit
  = "caml_gegl_path_move_to"

external gegl_path_line_to : gegl_path -> float * float -> unit
  = "caml_gegl_path_line_to"

external gegl_path_curve_to : gegl_path ->  float * float -> float * float -> float * float -> unit
  = "caml_gegl_path_curve_to"

external gegl_path_new_from_string : string -> gegl_path
  = "caml_gegl_path_new_from_string"

type babl
external babl_format : string -> babl
  = "caml_babl_format"

type gegl_buffer
external gegl_buffer_new : gegl_rectangle -> babl -> gegl_buffer
  = "caml_gegl_buffer_new"

external gegl_buffer_set : gegl_buffer -> gegl_rectangle -> babl -> bytes -> unit
  = "caml_gegl_buffer_set"

external gegl_buffer_unref : gegl_buffer -> unit
  = "caml_gegl_buffer_unref"

type node
external gegl_node_new : unit -> node
  = "caml_gegl_node_new"

external gegl_node_unref : node -> unit
  = "caml_gegl_node_unref"

external gegl_node_buffer_source : node -> gegl_buffer -> node
  = "caml_gegl_node_buffer_source"

external gegl_node_png_save : node -> string -> node
  = "caml_gegl_node_png_save"

external gegl_node_jpg_save : node -> string -> ?q:int -> unit -> node
  = "caml_gegl_node_jpg_save"

external gegl_node_display : node -> string -> node
  = "caml_gegl_node_display"

external gegl_node_png_load : node -> string -> node
  = "caml_gegl_node_png_load"

external gegl_node_jpg_load : node -> string -> node
  = "caml_gegl_node_jpg_load"

external gegl_node_svg_load : node -> string -> node
  = "caml_gegl_node_svg_load"

external gegl_node_plasma : node -> int -> int -> int -> node
  = "caml_gegl_node_plasma"

external gegl_node_perlin_noise : node -> node
  = "caml_gegl_node_perlin_noise"

external gegl_node_connect_to : node -> node -> unit
  = "caml_gegl_node_connect_to"

external gegl_node_connect_to2 : node -> node -> unit
  = "caml_gegl_node_connect_to2"

external gegl_node_process : node -> unit
  = "caml_gegl_node_process"

external gegl_list_operations : unit -> string array
  = "caml_gegl_list_operations"

external gegl_operation_list_properties : string -> (string * string) array
  = "caml_gegl_operation_list_properties"

external gegl_node_crop : node -> float * float * float * float -> bool -> node
  = "caml_gegl_node_crop_bytecode"
    "caml_gegl_node_crop"

external gegl_node_gaussian_blur : node -> float -> float -> node
  = "caml_gegl_node_gaussian_blur"

external gegl_node_edge_sobel : node -> node
  = "caml_gegl_node_edge_sobel"

external gegl_node_image_gradient : node -> node
  = "caml_gegl_node_image_gradient"

external gegl_node_edge_neon : node -> radius:float -> amount:float -> node
  = "caml_gegl_node_edge_neon"

external gegl_node_noise_pick : node -> pct_random:float -> repeat:int -> seed:int -> node
  = "caml_gegl_node_noise_pick"

external gegl_node_slic : node -> node
  = "caml_gegl_node_slic"

external gegl_node_waterpixels : node -> node
  = "caml_gegl_node_waterpixels"

external gegl_node_threshold : node -> node
  = "caml_gegl_node_threshold"

external gegl_node_brightness_contrast : node -> brightness:float -> contrast:float -> node
  = "caml_gegl_node_brightness_contrast"

external gegl_node_negative_darkroom : node -> node
  = "caml_gegl_node_negative_darkroom"

external gegl_node_normal_map : node -> node
  = "caml_gegl_node_normal_map"

external gegl_node_dither : node -> node
  = "caml_gegl_node_dither"

external gegl_node_pixelize : node -> node
  = "caml_gegl_node_pixelize"

external gegl_node_invert_linear : node -> node
  = "caml_gegl_node_invert_linear"

external gegl_node_newsprint : node -> node
  = "caml_gegl_node_newsprint"

type compositor =
  | Multiply
  | Difference
  | Screen
  | Overlay
  | Subtract
  | Exclusion

external gegl_node_compose : node -> compositor -> node
  = "caml_gegl_node_compose"

external gegl_node_fill_path : node -> d:gegl_path -> color:gegl_color -> node
  = "caml_gegl_node_fill_path"

external gegl_node_vector_stroke : node -> d:gegl_path -> color:gegl_color -> node
  = "caml_gegl_node_vector_stroke"

module Utils = struct

  let init_buffer ~w ~h f =
    let size_of_float = 4 in
    let s = Bytes.create (4 * w * h * size_of_float) in
    for i = 0 to pred (w * h) do
      let set c p =
        let p = size_of_float * p in
        let d = Int32.bits_of_float c in
        let d0 = Int32.logand (d) 0xffl in
        let d1 = Int32.logand (Int32.shift_right_logical d 8) 0xffl in
        let d2 = Int32.logand (Int32.shift_right_logical d 16) 0xffl in
        let d3 = (Int32.shift_right_logical d 24) in
        let char_of_int32 d = char_of_int (Int32.to_int d) in
        Bytes.set s (p+0) (char_of_int32 d0);
        Bytes.set s (p+1) (char_of_int32 d1);
        Bytes.set s (p+2) (char_of_int32 d2);
        Bytes.set s (p+3) (char_of_int32 d3);
      in
      let x = (i mod w) in
      let y = (i / w) in
      let r, g, b, a = f ~x ~y in
      set r (i * 4 + 0);
      set g (i * 4 + 1);
      set b (i * 4 + 2);
      set a (i * 4 + 3);
    done;
    (s)
end
