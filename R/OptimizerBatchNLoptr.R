#' @title Optimization via Non-linear Optimization
#'
#' @include Optimizer.R
#' @name mlr_optimizers_nloptr
#'
#' @description
#' `OptimizerBatchNLoptr` class that implements non-linear optimization.
#' Calls [nloptr::nloptr()] from package \CRANpkg{nloptr}.
#'
#' @section Parameters:
#' \describe{
#' \item{`algorithm`}{`character(1)`}
#' \item{`eval_g_ineq`}{`function()`}
#' \item{`xtol_rel`}{`numeric(1)`}
#' \item{`xtol_abs`}{`numeric(1)`}
#' \item{`ftol_rel`}{`numeric(1)`}
#' \item{`ftol_abs`}{`numeric(1)`}
#' \item{`start_values`}{`character(1)`\cr
#' Create `random` start values or based on `center` of search space?
#' In the latter case, it is the center of the parameters before a trafo is applied.}
#' \item{`approximate_eval_grad_f`}{`logical(1)`\cr
#' Should gradients be numerically approximated via finite differences ([nloptr::nl.grad]).
#' Only required for certain algorithms.
#' Note that function evaluations required for the numerical gradient approximation will be logged as usual
#' and are not treated differently than regular function evaluations by, e.g., [Terminator]s.}
#' }
#'
#' For the meaning of the control parameters, see [nloptr::nloptr()] and
#' [nloptr::nloptr.print.options()].
#'
#' The termination conditions `stopval`, `maxtime` and `maxeval` of
#' [nloptr::nloptr()] are deactivated and replaced by the [Terminator]
#' subclasses. The x and function value tolerance termination conditions
#' (`xtol_rel = 10^-4`, `xtol_abs = rep(0.0, length(x0))`, `ftol_rel = 0.0` and
#' `ftol_abs = 0.0`) are still available and implemented with their package
#' defaults. To deactivate these conditions, set them to `-1`.
#'
#' @template section_progress_bars
#'
#' @source
#' `r format_bib("johnson_2014")`
#'
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("nloptr")) {
#'
#'   search_space = domain = ps(x = p_dbl(lower = -1, upper = 1))
#'
#'   codomain = ps(y = p_dbl(tags = "minimize"))
#'
#'   objective_function = function(xs) {
#'     list(y = as.numeric(xs)^2)
#'   }
#'
#'   objective = ObjectiveRFun$new(
#'     fun = objective_function,
#'     domain = domain,
#'     codomain = codomain)
#'
#'
#'   # We use the internal termination criterion xtol_rel
#'   terminator = trm("none")
#'   instance = OptimInstanceBatchSingleCrit$new(
#'     objective = objective,
#'     search_space = search_space,
#'     terminator = terminator)
#'
#'
#'   optimizer = opt("nloptr", algorithm = "NLOPT_LN_BOBYQA")
#'
#'   # Modifies the instance by reference
#'   optimizer$optimize(instance)
#'
#'   # Returns best scoring evaluation
#'   instance$result
#'
#'   # Allows access of data.table of full path of all evaluations
#'   as.data.table(instance$archive)
#' }
#' }
#'
OptimizerBatchNLoptr = R6Class("OptimizerBatchNLoptr", inherit = OptimizerBatch,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        algorithm = p_fct(
          levels = c(
            "NLOPT_GN_DIRECT_L", "NLOPT_GN_DIRECT_L_RAND", "NLOPT_GN_DIRECT_NOSCAL", "NLOPT_GN_DIRECT_L_NOSCAL",
            "NLOPT_GN_DIRECT_L_RAND_NOSCAL", "NLOPT_GN_ORIG_DIRECT", "NLOPT_GN_ORIG_DIRECT_L", "NLOPT_GD_STOGO",
            "NLOPT_GD_STOGO_RAND", "NLOPT_LD_SLSQP", "NLOPT_LD_LBFGS_NOCEDAL", "NLOPT_LD_LBFGS", "NLOPT_LN_PRAXIS",
            "NLOPT_LD_VAR1", "NLOPT_LD_VAR2", "NLOPT_LD_TNEWTON", "NLOPT_LD_TNEWTON_RESTART", "NLOPT_LD_TNEWTON_PRECOND",
            "NLOPT_LD_TNEWTON_PRECOND_RESTART", "NLOPT_GN_CRS2_LM", "NLOPT_GN_MLSL", "NLOPT_GD_MLSL", "NLOPT_GN_MLSL_LDS",
            "NLOPT_GD_MLSL_LDS", "NLOPT_LD_MMA", "NLOPT_LD_CCSAQ", "NLOPT_LN_COBYLA", "NLOPT_LN_NEWUOA",
            "NLOPT_LN_NEWUOA_BOUND", "NLOPT_LN_NELDERMEAD", "NLOPT_LN_SBPLX", "NLOPT_LN_AUGLAG", "NLOPT_LD_AUGLAG",
            "NLOPT_LN_AUGLAG_EQ", "NLOPT_LD_AUGLAG_EQ", "NLOPT_LN_BOBYQA", "NLOPT_GN_ISRES"),
          tags = "required"),
        eval_g_ineq = p_uty(default = NULL),
        xtol_rel = p_dbl(default = 10^-4, lower = 0, upper = Inf, special_vals = list(-1)),
        xtol_abs = p_dbl(default = 0, lower = 0, upper = Inf, special_vals = list(-1)),
        ftol_rel = p_dbl(default = 0, lower = 0, upper = Inf, special_vals = list(-1)),
        ftol_abs = p_dbl(default = 0, lower = 0, upper = Inf, special_vals = list(-1)),
        start_values = p_fct(default = "random", levels = c("random", "center")),
        approximate_eval_grad_f = p_lgl(default = FALSE)
      )
      param_set$values$start_values = "random"
      param_set$values$approximate_eval_grad_f = FALSE

      super$initialize(
        id = "nloptr",
        param_set = param_set,
        param_classes = "ParamDbl",
        properties = "single-crit",
        packages = "nloptr",
        label = "Non-linear Optimization",
        man = "bbotk::mlr_optimizers_nloptr"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      pv = self$param_set$values

      pv$x0 = search_start(inst$search_space, type = pv$start_values)
      pv$start_values = NULL

      if (pv$approximate_eval_grad_f) {
        eval_grad_f = function(x) {
          invoke(nloptr::nl.grad, x0 = x, fn = inst$objective_function)
        }
        saveguard_epsilon = 1e-5
      } else {
        eval_grad_f = NULL
        saveguard_epsilon = 0

      }
      pv$eval_grad_f = eval_grad_f
      pv$approximate_eval_grad_f = NULL

      opts = pv[which(names(pv) %nin% formalArgs(nloptr::nloptr))]
      # deactivate termination criterions which are replaced by Terminators
      opts = insert_named(opts, list(
        maxeval = -1,
        maxtime = -1,
        stopval = -Inf
      ))
      pv = pv[which(names(pv) %nin% names(opts))]

      invoke(nloptr::nloptr,
        eval_f = inst$objective_function,
        lb = inst$search_space$lower + saveguard_epsilon,  # needed due to numerical issues with NLoptr
        ub = inst$search_space$upper - saveguard_epsilon,  # needed due to numerical issues with NLoptr
        opts = opts,
        .args = pv)
    }
  )
)

mlr_optimizers$add("nloptr", OptimizerBatchNLoptr)
