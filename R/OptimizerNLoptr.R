#' @title Optimization via Non-linear Optimization
#'
#' @include Optimizer.R
#'
#' @description
#' `OptimizerNLopt` class that implements non-linear optimization. Calls
#' [nloptr::nloptr] from package \CRANpkg{nloptr}.
#'
#' @section Parameters:
#' \describe{
#' \item{`smooth`}{`logical(1)`}
#' \item{`temperature`}{`numeric(1)`}
#' \item{`acceptance.param`}{`numeric(1)`}
#' \item{`verbose`}{`logical(1)`}
#' \item{`trace.mat`}{`logical(1)`}
#' }
#'
#' Termination is handled by [nloptr::nloptr] termination conditions.
#'
#' @export
#' @templateVar id OptimizerGenSA$new()
#' @template example
OptimizerNLoptr = R6Class("OptimizerNLoptr", inherit = Optimizer,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      ps = ParamSet$new(list(
        ParamFct$new("algorithm", default = "NLOPT_LN_COBYLA", levels =
          c("NLOPT_GN_DIRECT", "NLOPT_GN_DIRECT_L", "NLOPT_GN_DIRECT_L_RAND",
            "NLOPT_GN_DIRECT_NOSCAL", "NLOPT_GN_DIRECT_L_NOSCAL",
            "NLOPT_GN_DIRECT_L_RAND_NOSCAL", "NLOPT_GN_ORIG_DIRECT",
            "NLOPT_GN_ORIG_DIRECT_L", "NLOPT_GD_STOGO", "NLOPT_GD_STOGO_RAND",
            "NLOPT_LD_SLSQP", "NLOPT_LD_LBFGS_NOCEDAL", "NLOPT_LD_LBFGS",
            "NLOPT_LN_PRAXIS", "NLOPT_LD_VAR1", "NLOPT_LD_VAR2",
            "NLOPT_LD_TNEWTON", "NLOPT_LD_TNEWTON_RESTART",
            "NLOPT_LD_TNEWTON_PRECOND", "NLOPT_LD_TNEWTON_PRECOND_RESTART",
            "NLOPT_GN_CRS2_LM", "NLOPT_GN_MLSL", "NLOPT_GD_MLSL",
            "NLOPT_GN_MLSL_LDS", "NLOPT_GD_MLSL_LDS", "NLOPT_LD_MMA",
            "NLOPT_LD_CCSAQ", "NLOPT_LN_COBYLA", "NLOPT_LN_NEWUOA",
            "NLOPT_LN_NEWUOA_BOUND", "NLOPT_LN_NELDERMEAD", "NLOPT_LN_SBPLX",
            "NLOPT_LN_AUGLAG", "NLOPT_LD_AUGLAG", "NLOPT_LN_AUGLAG_EQ",
            "NLOPT_LD_AUGLAG_EQ", "NLOPT_LN_BOBYQA", "NLOPT_GN_ISRES")),
        ParamUty$new("x0"),
        ParamUty$new("eval_g_ineq", default = NULL),
        ParamDbl$new("xtol_rel", default = 10^-4, lower = 0, upper = Inf),
        ParamDbl$new("xtol_abs", default = 0, lower = 0, upper = Inf),
        ParamDbl$new("ftol_rel", default = 0, lower = 0, upper = Inf),
        ParamDbl$new("ftol_abs", default = 0, lower = 0, upper = Inf),
        ParamDbl$new("stopval", default = -Inf, lower = -Inf, upper = Inf),
        ParamInt$new("maxeval", default = 100, lower = 1L, upper = Inf),
        ParamInt$new("maxtime", default = -1L, lower = 0L, upper = Inf, special_vals = list(-1L))
      ))
      ps$values = list(algorithm = "NLOPT_LN_BOBYQA", xtol_rel = 10^-8)
      super$initialize(param_set = ps, param_classes = "ParamDbl",
        properties = "single-crit", packages = "nloptr")
    }
  ),

  private = list(
    .optimize = function(inst) {
      pv = self$param_set$values
      opts = pv[which(names(pv) %nin% formalArgs(nloptr::nloptr))]
      pv = pv[which(names(pv) %nin% names(opts))]

      invoke(nloptr::nloptr, eval_f = inst$objective_function,
        lb = inst$search_space$lower, ub = inst$search_space$upper, opts = opts,
        .args = pv)
    }
  )
)
