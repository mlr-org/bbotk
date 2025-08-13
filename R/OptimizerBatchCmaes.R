#' @title Optimization via Covariance Matrix Adaptation Evolution Strategy
#'
#' @include Optimizer.R
#' @name mlr_optimizers_cmaes
#'
#' @description
#' `OptimizerBatchCmaes` class that implements CMA-ES. Calls [adagio::pureCMAES()]
#' from package \CRANpkg{adagio}. The algorithm is typically applied to search
#' space dimensions between three and fifty. Lower search space dimensions might
#' crash.
#'
#' @templateVar id cmaes
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' \describe{
#' \item{`sigma`}{`numeric(1)`}
#' \item{`start_values`}{`character(1)`\cr
#' Create `"random"` start values or based on `"center"` of search space?
#' In the latter case, it is the center of the parameters before a trafo is applied.
#' If set to `"custom"`, the start values can be passed via the `start` parameter.}
#' \item{`start`}{`numeric()`\cr
#' Custom start values. Only applicable if `start_values` parameter is set to `"custom"`.}
#' }
#'
#' For the meaning of the control parameters, see [adagio::pureCMAES()]. Note
#' that we have removed all control parameters which refer to the termination of
#' the algorithm and where our terminators allow to obtain the same behavior.
#'
#' @template section_progress_bars
#'
#' @export
#' @examples
#' if (requireNamespace("adagio")) {
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
#'   instance = OptimInstanceBatchSingleCrit$new(
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
        sigma = p_dbl(default = 0.5),
        start_values = p_fct(default = "random", levels = c("random", "center", "custom")),
        start = p_uty(default = NULL, depends = start_values == "custom")
      )
      param_set$values$start_values = "random"
      param_set$values$start = NULL

      super$initialize(
        id = "cmaes",
        param_set = param_set,
        param_classes = "ParamDbl",
        properties = "single-crit",
        packages = "adagio"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      pv = self$param_set$values

      if (pv$start_values == "custom") {
        pv$par = pv$start
        pv$start_values = NULL
        pv$start = NULL
      } else {
        pv$par = search_start(inst$search_space, type = pv$start_values)
        pv$start_values = NULL
        pv$start = NULL
      }

      pv$stopeval = .Machine$integer.max # make sure pureCMAES does not stop
      pv$stopfitness = -Inf

      if (length(pv$par) < 2L) {
        warning("CMA-ES is typically applied to search space dimensions between three and fifty. A lower search space dimension might crash.")
      }

      invoke(adagio::pureCMAES,
        fun = inst$objective_function,
        lower = inst$search_space$lower,
        upper = inst$search_space$upper,
        .args = pv)
    }
  )
)

mlr_optimizers$add("cmaes", OptimizerBatchCmaes)
