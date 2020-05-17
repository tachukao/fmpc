module C = Configurator.V1

let () =
  C.main ~name:"fmpc" (fun _ ->
      let cflags = [] in
      let libs = [ "-lm"; "-llapack"; "-lblas" ] in
      let conf : C.Pkg_config.package_conf = { cflags; libs } in
      C.Flags.write_sexp "c_flags.sexp" conf.cflags;
      C.Flags.write_sexp "c_library_flags.sexp" conf.libs)
