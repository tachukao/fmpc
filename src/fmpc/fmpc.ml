(* 
 * Fast MPC
 * 
 * Bindings to Wang and Boyd's fast_mpc
 *
 * The original c code and matlab bindings can be found at 
 * https://web.stanford.edu/~boyd/fast_mpc/
 *
 *)

open Bigarray
module C = Fmpc_bindings.C (Fmpc_generated)

type mat = (float, float64_elt, c_layout) Genarray.t

type sys =
  { a : mat
  ; b : mat
  ; q : mat
  ; r : mat
  ; qf : mat
  }

type constraints =
  { xmax : mat
  ; xmin : mat
  ; umax : mat
  ; umin : mat
  }

(* [modify_layout x] copies [x] and changes its memory layout from 
   c_layout to fortran_layout. This is different from 
   Genarray.change_layout which does not create a new arr
   TODO: change c code to use lapacke instead of lapack *)
let modify_layout x =
  let shp = Genarray.dims x in
  let n = shp.(0)
  and m = shp.(1) in
  let x' = Genarray.create float64 fortran_layout [| n; m |] in
  for i = 0 to n - 1 do
    for j = 0 to m - 1 do
      Genarray.set x' [| i + 1; j + 1 |] Genarray.(get x [| i; j |])
    done
  done;
  x'


let step ?(verbose = false) ~horizon ~n_iters ~kappa sys constraints =
  let n, m =
    let shp = Genarray.dims sys.b in
    shp.(0), shp.(1)
  in
  let a = Ctypes.(bigarray_start genarray (modify_layout sys.a)) in
  let b = Ctypes.(bigarray_start genarray (modify_layout sys.b)) in
  let q = Ctypes.(bigarray_start genarray (modify_layout sys.q)) in
  let r = Ctypes.(bigarray_start genarray (modify_layout sys.r)) in
  let qf = Ctypes.(bigarray_start genarray (modify_layout sys.qf)) in
  let xmax = Ctypes.(bigarray_start genarray (modify_layout constraints.xmax)) in
  let xmin = Ctypes.(bigarray_start genarray (modify_layout constraints.xmin)) in
  let umax = Ctypes.(bigarray_start genarray (modify_layout constraints.umax)) in
  let umin = Ctypes.(bigarray_start genarray (modify_layout constraints.umin)) in
  fun _X0 _U0 _x0 ->
    let _X0 = Ctypes.(bigarray_start genarray (modify_layout _X0)) in
    let _U0 = Ctypes.(bigarray_start genarray (modify_layout _U0)) in
    let _x0 = Ctypes.(bigarray_start genarray (modify_layout _x0)) in
    let xstore = Genarray.create float64 fortran_layout [| n; horizon |] in
    let ustore = Genarray.create float64 fortran_layout [| m; horizon |] in
    let telapsed = Ctypes.(allocate double 0.) in
    let quiet = if verbose then 0 else 1 in
    C.fmpc_step
      a
      b
      q
      r
      qf
      xmax
      xmin
      umax
      umin
      horizon
      n
      m
      n_iters
      kappa
      quiet
      _X0
      _U0
      _x0
      Ctypes.(bigarray_start genarray xstore)
      Ctypes.(bigarray_start genarray ustore)
      telapsed;
    (* TODO: remove dependency on Owl *)
    let xstore = Genarray.change_layout xstore c_layout |> Owl.Mat.transpose in
    let ustore = Genarray.change_layout ustore c_layout |> Owl.Mat.transpose in
    xstore, ustore, Ctypes.(!@telapsed)


let simulate ?(verbose = false) ~horizon ~n_iters ~kappa ~n_steps sys constraints =
  let n, m =
    let shp = Genarray.dims sys.b in
    shp.(0), shp.(1)
  in
  let a = Ctypes.(bigarray_start genarray (modify_layout sys.a)) in
  let b = Ctypes.(bigarray_start genarray (modify_layout sys.b)) in
  let q = Ctypes.(bigarray_start genarray (modify_layout sys.q)) in
  let r = Ctypes.(bigarray_start genarray (modify_layout sys.r)) in
  let qf = Ctypes.(bigarray_start genarray (modify_layout sys.qf)) in
  let xmax = Ctypes.(bigarray_start genarray (modify_layout constraints.xmax)) in
  let xmin = Ctypes.(bigarray_start genarray (modify_layout constraints.xmin)) in
  let umax = Ctypes.(bigarray_start genarray (modify_layout constraints.umax)) in
  let umin = Ctypes.(bigarray_start genarray (modify_layout constraints.umin)) in
  fun _X0 _U0 _x0 w ->
    let _X0 = Ctypes.(bigarray_start genarray (modify_layout _X0)) in
    let _U0 = Ctypes.(bigarray_start genarray (modify_layout _U0)) in
    let _x0 = Ctypes.(bigarray_start genarray (modify_layout _x0)) in
    let w = Ctypes.(bigarray_start genarray (modify_layout w)) in
    let xstore = Genarray.create float64 fortran_layout [| n; n_steps |] in
    let ustore = Genarray.create float64 fortran_layout [| m; n_steps |] in
    let telapsed = Ctypes.(allocate double 0.) in
    let quiet = if verbose then 0 else 1 in
    C.fmpc_sim
      a
      b
      q
      r
      qf
      xmax
      xmin
      umax
      umin
      horizon
      n
      m
      n_iters
      kappa
      n_steps
      quiet
      _X0
      _U0
      _x0
      w
      Ctypes.(bigarray_start genarray xstore)
      Ctypes.(bigarray_start genarray ustore)
      telapsed;
    let xstore = Genarray.change_layout xstore c_layout |> Owl.Mat.transpose in
    let ustore = Genarray.change_layout ustore c_layout |> Owl.Mat.transpose in
    xstore, ustore, Ctypes.(!@telapsed)
