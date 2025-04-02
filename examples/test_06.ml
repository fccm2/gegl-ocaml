let () =
  Gegl.gegl_init ();
  let graph = Gegl.gegl_node_new () in

  let load_node = Gegl.gegl_node_svg_load graph "land_b.svg" in
  let save_node = Gegl.gegl_node_png_save graph "output6.png" in
  let d = Gegl.gegl_path_new_from_string "M20,108 L55,73 L90,108" in

  let fill_path =
    Gegl.gegl_node_fill_path graph ~d:d
      ~color:(Gegl.gegl_color_new "rgba(0.8, 0.1, 0.0, 1.0)") in

  (*
  let fill_path =
    Gegl.gegl_node_vector_stroke graph ~d:d
      ~color:(Gegl.gegl_color_new "rgba(0.8, 0.4, 0.1, 1.0)") in
  *)

  Gegl.gegl_node_connect_to load_node fill_path;
  Gegl.gegl_node_connect_to fill_path save_node;
  Gegl.gegl_node_process save_node;

  Gegl.gegl_node_unref graph;
  Gegl.gegl_exit ();
;;
