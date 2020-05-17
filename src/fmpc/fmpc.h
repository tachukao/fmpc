/* ******************************************************************
 * 
 * Fast MPC 
 * 
 * This code is adapted from the fast_mpc code written by Yang Wang 
 * and Stephen Boyd. The original code can be found at 
 * https://web.stanford.edu/~boyd/fast_mpc/
 * 
 * ******************************************************************/

void printmat(double *A, int m, int n);

void fmpc_step(double *A, double *B, double *Q, double *R, double *Qf,
               double *xmax, double *xmin, double *umax, double *umin,
               int T, int n, int m, int niters, double kappa, int quiet,
               double *X0, double *U0, double *x0,
               double *X, double *U, double *telapsed);

void fmpc_sim(double *A, double *B, double *Q, double *R, double *Qf,
              double *xmax, double *xmin, double *umax, double *umin,
              int T, int n, int m, int niters, double kappa, int nsteps,
              int quiet, double *X0, double *U0, double *x0, double *w,
              double *Xhist, double *Uhist, double *telapsed);