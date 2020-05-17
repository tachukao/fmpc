# Ocaml Bindings for Fast MPC

[fast_mpc](https://web.stanford.edu/~boyd/fast_mpc/) is a fast algorithm for model predictive control, presented in the paper [Fast Model Predictive Control using Online Optimization](http://stanford.edu/~boyd/papers/pdf/fast_mpc.pdf) by Yang Wang and Stephen Boyd.

This library is a binding to Wang and Boyd's implementation of the algorithm.

## Install

```sh 
dune build @install
dune install
```

## Dependencies
* LAPACK
* BLAS
* [Owl](https://github.com/owlbarn/owl.git)
* [Cmdargs](https://github.com/ghennequin/cmdargs.git) (only used in examples)

## Examples

```sh
dune exe ./examples/masses.exe -- -d results
```