let () =
  Gegl.gegl_init ();

  let operations =
    Gegl.gegl_list_operations ()
  in

  Array.iter (fun op ->
    let properties =
      Gegl.gegl_operation_list_properties op
    in
    Printf.printf "- %s\n" op;
    Array.iter (fun (property, prop_type) ->
      Printf.printf "  . %s / %s\n" property prop_type;
    ) properties
  ) operations;

  Gegl.gegl_exit ();
;;
