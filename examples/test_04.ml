let () =
  Gegl.gegl_init ();
  let graph = Gegl.gegl_node_new () in

  let load_node = Gegl.gegl_node_png_load graph "input.png" in
  let save_node = Gegl.gegl_node_png_save graph "blured.png" in

  let blur_node = Gegl.gegl_node_gaussian_blur graph 10.0 10.0 in

  Gegl.gegl_node_connect_to load_node blur_node;
  Gegl.gegl_node_connect_to blur_node save_node;
  Gegl.gegl_node_process save_node;

  Gegl.gegl_node_unref graph;
  Gegl.gegl_exit ();
;;
