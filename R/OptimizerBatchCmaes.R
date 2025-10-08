#' @title Optimization via Covariance Matrix Adaptation Evolution Strategy
#'
#' @include Optimizer.R
#' @name mlr_optimizers_cmaes
#'
#' @description
#' `OptimizerBatchCmaes` class that implements CMA-ES.
#' Calls `cmaes()` from package \CRANpkg{libcmaesr}.
#'
#' @templateVar id cmaes
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' \describe{
#' \item{`x0`}{`numeric()`\cr
#'   Initial parameter values.
#'   Use `start_values` parameter to create `"random"` or `"center"` initial values.}
#' \item{`start_values`}{`character(1)`\cr
#'   Create `"random"` start values or based on `"center"` of search space?
#'   In the latter case, it is the center of the parameters before a trafo is applied.
#'   Custom start values can be passed via the `x0` parameter.}
#' }
#'
#' For the meaning of the control parameters, see `libcmaesr::cmaes_control()`.
#'
#' @section Internal Termination Parameters:
#' The algorithm can terminated with all [Terminator]s.
#' Additionally, the following internal termination parameters can be used:
#'
#' \describe{
#' \item{`max_fevals`}{`integer(1)`\cr
#'   Maximum number of function evaluations.
#'   Original default is `100`.
#'   Deactivate with `NA`.
#'   Overwritten with `NA`.}
#' \item{`max_iter`}{`integer(1)`\cr
#'   Maximum number of iterations.
#'   Deactivate with `NA`.
#'   Default is `NA`.}
#' \item{`ftarget`}{`numeric(1)`\cr
#'   Target function value.
#'   Deactivate with `NA`.
#'   Default is `NA`.}
#' \item{`f_tolerance`}{`numeric(1)`\cr
#'   Function tolerance.
#'   Deactivate with `NA`.
#'   Default is `NA`.}
#' \item{`x_tolerance`}{`numeric(1)`\cr
#'   Parameter tolerance.
#'   Deactivate with `NA`.
#'   Default is `NA`.}
#' }
#'
#' @template section_progress_bars
#'
#' @export
#' @examples
#' if (requireNamespace("libcmaesr")) {
#'   search_space = domain = ps(
#'     x1 = p_dbl(-10, 10),
#'     x2 = p_dbl(-5, 5)
#'   )
#'
#'   codomain = ps(y = p_dbl(tags = "maximize"))
#'
#'   objective_function = function(xs) {
#'     c(y = -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
#'   }
#'
#'   objective = ObjectiveRFun$new(
#'     fun = objective_function,
#'     domain = domain,
#'     codomain = codomain)
#'
#'   instance = oi(
#'     objective = objective,
#'     search_space = search_space,
#'     terminator = trm("evals", n_evals = 10))
#'
#'   optimizer = opt("cmaes")
#'
#'   # modifies the instance by reference
#'   optimizer$optimize(instance)
#'
#'   # returns best scoring evaluation
#'   instance$result
#'
#'   # allows access of data.table of full path of all evaluations
#'   as.data.table(instance$archive$data)
#' }
OptimizerBatchCmaes = R6Class("OptimizerBatchCmaes",
  inherit = OptimizerBatch,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        x0            = p_uty(default = NULL),
        algo          = p_fct(default = "acmaes", levels = c(
          "cmaes",
          "ipop",
          "bipop",
          "acmaes",
          "aipop",
          "abipop",
          "sepcmaes",
          "sepipop",
          "sepbipop",
          "sepacmaes",
          "sepaipop",
          "sepabipop",
          "vdcma",
          "vdipopcma",
          "vdbipopcma")),
        lambda        = p_int(lower = 1L, default = NA_integer_, special_vals = list(NA_integer_)),
        sigma         = p_dbl(default = NA_real_, special_vals = list(NA_real_)),
        max_restarts  = p_int(lower = 1L, special_vals = list(NA), default = NA),
        tpa           = p_int(default = NA_integer_, special_vals = list(NA_integer_)),
        tpa_dsigma    = p_dbl(default = NA_real_, special_vals = list(NA_real_)),
        seed          = p_int(default = NA_integer_, special_vals = list(NA_integer_)),
        quiet         = p_lgl(default = FALSE),
        # bbotk parameters
        start_values  = p_fct(init = "random", levels = c("random", "center")),
        # internal termination criteria
        max_fevals    = p_int(lower = 1L, init = NA_integer_, special_vals = list(NA_integer_)),
        max_iter      = p_int(lower = 1L, default = NA_integer_, special_vals = list(NA_integer_)),
        ftarget       = p_dbl(default = NA_real_, special_vals = list(NA_real_)),
        f_tolerance   = p_dbl(default = NA_real_, special_vals = list(NA_real_)),
        x_tolerance   = p_dbl(default = NA_real_, special_vals = list(NA_real_))
      )

      super$initialize(
        id = "cmaes",
        param_set = param_set,
        param_classes = "ParamDbl",
        properties = "single-crit",
        packages = "libcmaesr",
        label = "Covariance Matrix Adaptation Evolution Strategy",
        man = "bbotk::mlr_optimizers_cmaes"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      pv = self$param_set$values
      direction = inst$objective$codomain$direction
      lower = inst$search_space$lower
      upper = inst$search_space$upper

      x0 = if (!is.null(pv$x0)) {
        set_names(pv$x0, inst$search_space$ids())
      } else {
        search_start(inst$search_space, type = pv$start_values)
      }

      wrapper = function(xmat) {
        xdt = set_names(as.data.table(xmat), inst$search_space$ids())
        res = inst$eval_batch(xdt)
        y = res[, inst$objective$codomain$target_ids, with = FALSE][[1]]
        y * direction
      }

      control = invoke(libcmaesr::cmaes_control, maximize = direction == -1L,
        .args = pv[which(names(pv) %in% formalArgs(libcmaesr::cmaes_control))])

      libcmaesr::cmaes(
        objective = wrapper,
        x0 = x0,
        lower = lower,
        upper = upper,
        batch = TRUE,
        control = control)
    }
  )
)

mlr_optimizers$add("cmaes", OptimizerBatchCmaes)
