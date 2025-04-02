let () =
  Gegl.gegl_init ();
  let w, h = (100, 100) in

  let rect = Gegl.gegl_rectangle (0, 0, w, h) in
  let fmt = Gegl.babl_format "RGBA float" in

  let buf = Gegl.gegl_buffer_new rect fmt in

  let s =
    Gegl.Utils.init_buffer ~w ~h (fun ~x ~y ->
      let r = (float y) /. (float (pred h)) in
      let g = (float x) /. (float (pred w)) in
      let b = 1.0 -. r in
      (r, g, b, 1.0)
    )
  in

  Gegl.gegl_buffer_set buf rect fmt s;

  let graph = Gegl.gegl_node_new () in

  let load_buf = Gegl.gegl_node_buffer_source graph buf in
  let save_node = Gegl.gegl_node_png_save graph "output.png" in

  Gegl.gegl_node_connect_to load_buf save_node;
  Gegl.gegl_node_process save_node;

  Gegl.gegl_node_unref graph;
  Gegl.gegl_buffer_unref buf;

  Gegl.gegl_exit ();
;;
