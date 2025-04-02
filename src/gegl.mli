(** Gegl-Interface *)
(* Copyright (C) 2025 Florent Monnier
   Permission to use, copy, modify, and/or distribute this software.
*)

(** {3 Init/exit} *)

val gegl_init : unit -> unit
val gegl_exit : unit -> unit

(** {3 Gegl-kinds} *)

type gegl_rectangle
val gegl_rectangle : int * int * int * int -> gegl_rectangle

type gegl_color
val gegl_color_new : string -> gegl_color

type gegl_path
val gegl_path_new : unit -> gegl_path

type babl
val babl_format : string -> babl

type gegl_buffer
val gegl_buffer_new : gegl_rectangle -> babl -> gegl_buffer

val gegl_buffer_set : gegl_buffer -> gegl_rectangle -> babl -> bytes -> unit

val gegl_buffer_unref : gegl_buffer -> unit

(** {3 Nodes} *)

type node
val gegl_node_new : unit -> node

val gegl_node_unref : node -> unit

(** {3 Buffer-source} *)

val gegl_node_buffer_source : node -> gegl_buffer -> node

(** {3 Load/save} *)

val gegl_node_png_save : node -> string -> node
val gegl_node_jpg_save : node -> string -> ?q:int -> unit -> node

val gegl_node_png_load : node -> string -> node
val gegl_node_jpg_load : node -> string -> node
val gegl_node_svg_load : node -> string -> node

val gegl_node_display : node -> string -> node

val gegl_node_plasma : node -> int -> int -> int -> node
val gegl_node_perlin_noise : node -> node

(** {3 Connect nodes and process} *)

val gegl_node_connect_to : node -> node -> unit
val gegl_node_connect_to2 : node -> node -> unit

val gegl_node_process : node -> unit

(** {3 List-operations} *)

val gegl_list_operations : unit -> string array
val gegl_operation_list_properties : string -> (string * string) array

(** {3 Operations} *)

val gegl_node_crop : node -> float * float * float * float -> bool -> node

val gegl_node_gaussian_blur : node -> float -> float -> node

val gegl_node_edge_sobel : node -> node

val gegl_node_image_gradient : node -> node

val gegl_node_edge_neon : node -> radius:float -> amount:float -> node

val gegl_node_noise_pick : node -> pct_random:float -> repeat:int -> seed:int -> node

val gegl_node_slic : node -> node

val gegl_node_waterpixels : node -> node

val gegl_node_threshold : node -> node

val gegl_node_brightness_contrast : node -> brightness:float -> contrast:float -> node

val gegl_node_negative_darkroom : node -> node

val gegl_node_normal_map : node -> node

val gegl_node_dither : node -> node

val gegl_node_pixelize : node -> node

val gegl_node_invert_linear : node -> node

val gegl_node_newsprint : node -> node

(** {3 Compose} *)

type compositor =
  | Multiply
  | Difference
  | Screen
  | Overlay
  | Subtract
  | Exclusion

val gegl_node_compose : node -> compositor -> node

(** {3 Path} *)

val gegl_path_new_from_string : string -> gegl_path

val gegl_path_move_to : gegl_path -> float * float -> unit
val gegl_path_line_to : gegl_path -> float * float -> unit
val gegl_path_curve_to : gegl_path -> float * float -> float * float -> float * float -> unit

val gegl_node_fill_path : node -> d:gegl_path -> color:gegl_color -> node

val gegl_node_vector_stroke : node -> d:gegl_path -> color:gegl_color -> node

(** {3 Utils} *)

module Utils : sig
 val init_buffer :
   w:int -> h:int -> (x:int -> y:int -> float * float * float * float) -> bytes
end


(** {3 doc-links} *)

(** docs from gegl.org:

- {{:https://gegl.org/operations/GeglOperationSource.html}
     gegl-operation-source}
 
- {{:https://gegl.org/operations/}
     all-gegl-operations}
 
- {{:https://gegl.org/operations/GeglOperationPointComposer.html}
     gegl-operation-point-composer-operations} /
  {{:https://gegl.org/operations/compositors.html}
     compositors}
 
- {{:https://gegl.org/operations/output.html}
     gegl-output-operations}
 
- {{:https://gegl.org/operations/color.html}
     gegl-color-operations}
*)

(** {3 Exemple} *)

(** exemple, loading a .png input, and saving it back to a .png output: *)

(**
{[
let () =
  Gegl.gegl_init ();
  let graph = Gegl.gegl_node_new () in

  let load_node = Gegl.gegl_node_png_load graph "input.png" in
  let save_node = Gegl.gegl_node_png_save graph "output.png" in

  Gegl.gegl_node_connect_to load_node save_node;
  Gegl.gegl_node_process save_node;

  Gegl.gegl_node_unref graph;
  Gegl.gegl_exit ();
;;
]}
*)

(** nodes have to be connected, and the output node has to be processed,

    to produce the output result *)

(** {3 Exemple-2} *)

(** chaining nodes to apply filters: *)

(**
{[
let () =
  Gegl.gegl_init ();
  let graph = Gegl.gegl_node_new () in

  let load_node = Gegl.gegl_node_jpg_load graph "input.jpg" in
  let save_node = Gegl.gegl_node_jpg_save graph "filtered.jpg" () in

  let oper_node = Gegl.gegl_node_edge_neon graph ~radius:1.0 ~amount:1.0 in

  Gegl.gegl_node_connect_to load_node oper_node;
  Gegl.gegl_node_connect_to oper_node save_node;
  Gegl.gegl_node_process save_node;

  Gegl.gegl_node_unref graph;
  Gegl.gegl_exit ();
;;
]}
*)

(** {3 Exemple-3} *)

(** example to compose layers: *)

(** [node_connect_to2] connects to the [aux] connector of a node *)

(**
{[
let () =
  Gegl.gegl_init ();
  let graph = Gegl.gegl_node_new () in

  let lay1_node = Gegl.gegl_node_png_load graph "layer1.png" in
  let lay2_node = Gegl.gegl_node_png_load graph "layer2.png" in

  let blend = Gegl.gegl_node_compose graph Gegl.Multiply in

  Gegl.gegl_node_connect_to lay1_node blend;
  Gegl.gegl_node_connect_to2 lay2_node blend;

  let save_node = Gegl.gegl_node_png_save graph "output.png" in

  Gegl.gegl_node_connect_to blend save_node;
  Gegl.gegl_node_process save_node;

  Gegl.gegl_node_unref graph;
  Gegl.gegl_exit ();
;;
]}
*)

