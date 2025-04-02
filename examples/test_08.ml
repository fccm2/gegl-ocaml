let () =
  Gegl.gegl_init ();
  let graph = Gegl.gegl_node_new () in

  let lay1_node = Gegl.gegl_node_svg_load graph "layer1.svg" in
  let lay2_node = Gegl.gegl_node_svg_load graph "layer2.svg" in

  let blend = Gegl.gegl_node_compose graph Gegl.Exclusion in
  (*
  | Multiply
  | Difference
  | Screen
  | Overlay
  | Subtract
  | Exclusion
  *)

  Gegl.gegl_node_connect_to lay1_node blend;
  Gegl.gegl_node_connect_to2 lay2_node blend;

  let save_node = Gegl.gegl_node_png_save graph "output.png" in

  Gegl.gegl_node_connect_to blend save_node;
  Gegl.gegl_node_process save_node;

  Gegl.gegl_node_unref graph;
  Gegl.gegl_exit ();
;;
