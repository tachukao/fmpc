open Ctypes

module C (F : Ctypes.FOREIGN) = struct
  open F

  let printmat = foreign "printmat" (ptr double @-> int @-> int @-> returning void)

  let fmpc_step =
    foreign
      "fmpc_step"
      ((* A *)
       ptr double
      (* B *)
      @-> ptr double
      (* Q *)
      @-> ptr double
      (* R *)
      @-> ptr double
      (* Qf *)
      @-> ptr double
      (* xmax *)
      @-> ptr double
      (* xmin *)
      @-> ptr double
      (* umax *)
      @-> ptr double
      (* umin *)
      @-> ptr double
      (* T *)
      @-> int
      (* n *)
      @-> int
      (* m *)
      @-> int
      (* niters  *)
      @-> int
      (* kappa *)
      @-> double
      (* quiet *)
      @-> int
      (* X0 *)
      @-> ptr double
      (* U0 *)
      @-> ptr double
      (* x0 *)
      @-> ptr double
      (* X *)
      @-> ptr double
      (* U *)
      @-> ptr double
      (* telapsed *)
      @-> ptr double
      @-> returning void)


  let fmpc_sim =
    foreign
      "fmpc_sim"
      ((* A *)
       ptr double
      (* B *)
      @-> ptr double
      (* Q *)
      @-> ptr double
      (* R *)
      @-> ptr double
      (* Qf *)
      @-> ptr double
      (* xmax *)
      @-> ptr double
      (* xmin *)
      @-> ptr double
      (* umax *)
      @-> ptr double
      (* umin *)
      @-> ptr double
      (* T *)
      @-> int
      (* n *)
      @-> int
      (* m *)
      @-> int
      (* niters  *)
      @-> int
      (* kappa *)
      @-> double
      (* nsteps *)
      @-> int
      (* quiet *)
      @-> int
      (* X0 *)
      @-> ptr double
      (* U0 *)
      @-> ptr double
      (* x0 *)
      @-> ptr double
      (* w *)
      @-> ptr double
      (* Xhist *)
      @-> ptr double
      (* Uhist *)
      @-> ptr double
      (* telapsed *)
      @-> ptr double
      @-> returning void)
end
