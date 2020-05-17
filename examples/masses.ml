(* 
 * Oscillating Masses
 * 
 * This example is adapted from matlab code "masses_example.m" 
 * written by Yang Wang and Stephen Boyd. The original code can be 
 * found at https://web.stanford.edu/~boyd/fast_mpc/
 * 
 *)

open Owl

let dir = Cmdargs.(get_string "-d" |> force ~usage:"-d [dir]")
let in_dir s = Printf.sprintf "%s/%s" dir s

(* spring constant  *)
let k = 1.

(* damping constant *)
let lam = 0.
let a = -2. *. k
let b = -2. *. lam
let c = k
let d = lam

(* sampling time *)
let ts = 0.02

(* state dimension *)
let n = 12

(* input dimension *)
let m = 3

let amat, bmat =
  let n2 = n / 2 in
  let a1 = Mat.(zeros n2 n2 @|| eye n2) in
  let a2 =
    [| [| a; c; 0.; 0.; 0.; 0.; b; d; 0.; 0.; 0.; 0. |]
     ; [| c; a; c; 0.; 0.; 0.; d; b; d; 0.; 0.; 0. |]
     ; [| 0.; c; a; c; 0.; 0.; 0.; d; b; d; 0.; 0. |]
     ; [| 0.; 0.; c; a; c; 0.; 0.; 0.; d; b; d; 0. |]
     ; [| 0.; 0.; 0.; c; a; c; 0.; 0.; 0.; d; b; d |]
     ; [| 0.; 0.; 0.; 0.; c; a; 0.; 0.; 0.; 0.; d; b |]
    |]
    |> Mat.of_arrays
  in
  let camat = Mat.(ts $* a1 @= a2) in
  let cbmat =
    let b1 = Mat.zeros (n / 2) m in
    let b2 =
      [| [| 1.; 0.; 0. |]
       ; [| -1.; 0.; 0. |]
       ; [| 0.; 1.; 0. |]
       ; [| 0.; 0.; 1. |]
       ; [| 0.; -1.; 0. |]
       ; [| 0.; 0.; -1. |]
      |]
      |> Mat.of_arrays
    in
    Mat.(ts $* b1 @= b2)
  in
  let amat = Linalg.D.expm camat in
  let bmat = Linalg.D.linsolve camat Mat.((amat - eye n) *@ cbmat) in
  amat, bmat


(* objective matrices *)
let q = Mat.eye n
let qf = q
let r = Mat.eye m

(* state and control limits *)
let xmax, xmin =
  let xmax = Mat.(4. $* ones n 1) in
  xmax, Mat.neg xmax


let umax, umin =
  let umax = Mat.(0.5 $* ones m 1) in
  umax, Mat.neg umax


(* initial state *)
let x0 = Mat.zeros n 1
let horizon = 10

(* fast MPC parameters *)
(* barrier parameter *)
let kappa = 0.01

(* number of iter *)
let n_iters = 10

(* quiet *)
let quiet = true

(* set up initial state and input trajectories *)
let _X0 = Mat.zeros n horizon
let _U0 = Mat.zeros m horizon
let sys = Fmpc.{ a = amat; b = bmat; q; r; qf }
let constraints = Fmpc.{ xmax; xmin; umax; umin }
let n_steps = 100

let w =
  let w = Mat.(uniform Stdlib.(n / 2) n_steps) in
  let w = Mat.(w -$ 0.5) in
  Mat.(zeros Stdlib.(n / 2) n_steps @= w)


(* this function uses Fmpc.step *)
let simulate n_steps x0 _X0 _U0 =
  let step = Fmpc.step ~horizon ~n_iters ~kappa ~verbose:false sys constraints in
  let rec run k _X _U x xstore ustore loss ts =
    if k < n_steps
    then (
      let _X, _U, t = step _X _U x in
      let u = Mat.col _U 0 in
      let ts = t :: ts in
      let l = Mat.(sum' (x * (q *@ x))) +. Mat.(sum' (u * (r *@ u))) in
      let loss = l :: loss in
      let xstore = x :: xstore in
      let ustore = u :: ustore in
      let x = Mat.((amat *@ x) + (bmat *@ u) + col w k) in
      let _X = Mat.(get_slice [ []; [ 1; -1 ] ] _X @|| zeros n 1) in
      let _U = Mat.(get_slice [ []; [ 1; -1 ] ] _U @|| zeros m 1) in
      run (succ k) _X _U x xstore ustore loss ts)
    else (
      let xs = xstore |> List.rev |> Array.of_list |> Mat.concatenate ~axis:1 in
      let us = ustore |> List.rev |> Array.of_list |> Mat.concatenate ~axis:1 in
      let loss = [| loss |> List.rev |> Array.of_list |] |> Mat.of_arrays in
      xs, us, loss)
  in
  run 0 _X0 _U0 x0 [] [] [] []


(* this function uses Fmpc.sim *)
let simulate2 n_steps x0 _X0 _U0 w =
  Fmpc.simulate
    ~horizon
    ~n_iters
    ~kappa
    ~n_steps
    ~verbose:false
    sys
    constraints
    _X0
    _U0
    x0
    w


(* simulate and simulate2 should give the same results *)
let () =
  let xs, us, loss = simulate n_steps x0 _X0 _U0 in
  Mat.save_txt ~out:(in_dir "xs") Mat.(transpose xs);
  Mat.save_txt ~out:(in_dir "us") Mat.(transpose us);
  Mat.save_txt ~out:(in_dir "loss") Mat.(transpose loss)


let () =
  let xs, us, _ = simulate2 n_steps x0 _X0 _U0 w in
  let loss =
    let lx = Mat.(sum ~axis:0 (xs * (q *@ xs))) in
    let lu = Mat.(sum ~axis:0 (us * (r *@ us))) in
    Mat.(lx + lu)
  in
  Mat.save_txt ~out:(in_dir "xs2") Mat.(transpose xs);
  Mat.save_txt ~out:(in_dir "us2") Mat.(transpose us);
  Mat.save_txt ~out:(in_dir "loss2") Mat.(transpose loss)
