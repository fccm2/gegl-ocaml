let () =
  Gegl.gegl_init ();
  let graph = Gegl.gegl_node_new () in

  let load_node = Gegl.gegl_node_png_load graph "output.png" in
  let save_node = Gegl.gegl_node_jpg_save graph "output.jpg" () in

  Gegl.gegl_node_connect_to load_node save_node;
  Gegl.gegl_node_process save_node;

  Gegl.gegl_node_unref graph;
  Gegl.gegl_exit ();
;;
