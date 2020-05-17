let () =
  let fmt file = Format.formatter_of_out_channel (open_out file) in
  let fmt_c = fmt "fmpc_stubs.c" in
  Format.fprintf fmt_c "#include \"fmpc.h\"@.";
  Cstubs.write_c fmt_c ~prefix:"caml" (module Fmpc_bindings.C);
  let fmt_ml = fmt "fmpc_generated.ml" in
  Cstubs.write_ml fmt_ml ~prefix:"caml" (module Fmpc_bindings.C);
  flush_all ()
