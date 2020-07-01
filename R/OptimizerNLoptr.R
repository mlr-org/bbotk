#' @title Optimization via Non-linear Optimization
#'
#' @include Optimizer.R
#'
#' @description
#' `OptimizerNLoptr` class that implements non-linear optimization. Calls
#' [nloptr::nloptr] from package \CRANpkg{nloptr}.
#'
#' @section Parameters:
#' \describe{
#' \item{`algorithm`}{`character(1)`}
#' \item{`x0`}{`numeric()`}
#' \item{`eval_g_ineq`}{`function()`}
#' \item{`xtol_rel`}{`numeric(1)`}
#' \item{`xtol_abs`}{`numeric(1)`}
#' \item{`ftol_rel`}{`numeric(1)`}
#' \item{`ftol_abs`}{`numeric(1)`}
#' }
#'
#' For the meaning of the control parameters, see [nloptr::nloptr()] and
#' [nloptr::nloptr.print.options()].
#'
#' The termination conditions `stopval`, `maxtime` and `maxeval` of
#' [nloptr::nloptr()] are deactivated and replaced by the [Terminator]
#' subclasses. The x and function value tolerance termination conditions
#' (`xtol_rel = 10^-4`, `xtol_abs = rep(0.0, length(x0))`,
#' `ftol_rel = 0.0` and `ftol_abs = 0.0`) are still available and implemented with
#' their package defaults. To deactivate these conditions, set them to `-1`.
#'
#' @export
#' @examples
#' library(paradox)
#' library(data.table)
#'
#' domain = ParamSet$new(list(ParamDbl$new("x", lower = -1, upper = 1)))
#'
#' search_space = ParamSet$new(list(ParamDbl$new("x", lower = -1, upper = 1)))
#'
#' codomain = ParamSet$new(list(ParamDbl$new("y", tags = "minimize")))
#'
#' objective_function = function(xs) {
#'   list(y = as.numeric(xs)^2)
#' }
#'
#' objective = ObjectiveRFun$new(fun = objective_function,
#'   domain = domain,
#'   codomain = codomain)
#'
#' # We use the internal termination criterion xtol_rel
#' terminator = TerminatorNone$new()
#'
#' instance = OptimInstanceSinglecrit$new(objective = objective,
#'   search_space = search_space,
#'   terminator = terminator)
#'
#' optimizer = OptimizerNLoptr$new()
#' optimizer$param_set$values = mlr3misc::insert_named(optimizer$param_set$values,
#'   list(x0 = 1, algorithm = "NLOPT_LN_BOBYQA"))
#'
#' # Modifies the instance by reference
#' optimizer$optimize(instance)
#'
#' # Returns best scoring evaluation
#' instance$result
#'
#' # Allows access of data.table of full path of all evaluations
#' instance$archive$data()
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
        ParamDbl$new("xtol_rel", default = 10^-4, lower = 0, upper = Inf,
          special_vals = list(-1)),
        ParamDbl$new("xtol_abs", default = 0, lower = 0, upper = Inf,
          special_vals = list(-1)),
        ParamDbl$new("ftol_rel", default = 0, lower = 0, upper = Inf,
          special_vals = list(-1)),
        ParamDbl$new("ftol_abs", default = 0, lower = 0, upper = Inf,
          special_vals = list(-1))
      ))
      super$initialize(param_set = ps, param_classes = "ParamDbl",
        properties = "single-crit", packages = "nloptr")
    }
  ),

  private = list(
    .optimize = function(inst) {
      pv = self$param_set$values
      opts = pv[which(names(pv) %nin% formalArgs(nloptr::nloptr))]
      # Deactivate termination criterions which are replaced by Terminators
      opts = insert_named(opts, list(
        maxeval = -1,
        maxtime = -1,
        stopval = -Inf
      ))
      pv = pv[which(names(pv) %nin% names(opts))]
      invoke(nloptr::nloptr, eval_f = inst$objective_function,
        lb = inst$search_space$lower, ub = inst$search_space$upper, opts = opts,
        .args = pv)
    }
  )
)
