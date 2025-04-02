let () =
  Gegl.gegl_init ();
  let graph = Gegl.gegl_node_new () in

  let load_node = Gegl.gegl_node_png_load graph "input.png" in
  let save_node = Gegl.gegl_node_png_save graph "croped.png" in

  let crop_node = Gegl.gegl_node_crop graph (10.0, 10.0, 20.0, 20.0) false in

  Gegl.gegl_node_connect_to load_node crop_node;
  Gegl.gegl_node_connect_to crop_node save_node;
  Gegl.gegl_node_process save_node;

  Gegl.gegl_node_unref graph;
  Gegl.gegl_exit ();
;;
