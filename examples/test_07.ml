let () =
  Gegl.gegl_init ();
  let graph = Gegl.gegl_node_new () in

  let load_node = Gegl.gegl_node_jpg_load graph "input.jpg" in
  let save_node = Gegl.gegl_node_jpg_save graph "filtered.jpg" () in

  let oper_node =
    match Sys.argv with
    | [| _; "edge-sobel" |] ->
        Gegl.gegl_node_edge_sobel graph

    | [| _; "edge-neon" |] ->
        Gegl.gegl_node_edge_neon graph ~radius:1.0 ~amount:1.0

    | [| _; "noise-pick" |] ->
        Gegl.gegl_node_noise_pick graph ~pct_random:50.0 ~repeat:1 ~seed:123

    | [| _; "slic" |] ->
        Gegl.gegl_node_slic graph

    | [| _; "waterpixels" |] ->
        Gegl.gegl_node_waterpixels graph

    | [| _; "threshold" |] ->
        Gegl.gegl_node_threshold graph

    | [| _; "brightness" |] ->
        Gegl.gegl_node_brightness_contrast graph ~brightness:0.3 ~contrast:1.0

    | [| _; "contrast" |] ->
        Gegl.gegl_node_brightness_contrast graph ~brightness:0.0 ~contrast:3.0

    | [| _; "negative-darkroom" |] ->
        Gegl.gegl_node_negative_darkroom graph

    | [| _; "normal-map" |] ->
        Gegl.gegl_node_normal_map graph

    | [| _; "dither" |] ->
        Gegl.gegl_node_dither graph

    | [| _; "pixelize" |] ->
        Gegl.gegl_node_pixelize graph

    | [| _; "invert" |] ->
        Gegl.gegl_node_invert_linear graph

    | [| _; "newsprint" |] ->
        Gegl.gegl_node_newsprint graph

    | [| _; "image-gradient" |]
    | _ -> Gegl.gegl_node_image_gradient graph
  in

  Gegl.gegl_node_connect_to load_node oper_node;
  Gegl.gegl_node_connect_to oper_node save_node;
  Gegl.gegl_node_process save_node;

  Gegl.gegl_node_unref graph;
  Gegl.gegl_exit ();
;;
