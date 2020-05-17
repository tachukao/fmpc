open Bigarray

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

val step
  :  ?verbose:bool
  -> horizon:int
  -> n_iters:int
  -> kappa:float
  -> sys
  -> constraints
  -> mat
  -> mat
  -> mat
  -> mat * mat * float

val simulate
  :  ?verbose:bool
  -> horizon:int
  -> n_iters:int
  -> kappa:float
  -> n_steps:int
  -> sys
  -> constraints
  -> mat
  -> mat
  -> mat
  -> mat
  -> mat * mat * float
