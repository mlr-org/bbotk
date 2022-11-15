#' @title Optimization via Covariance Matrix Adaptation Evolution Strategy
#'
#' @include Optimizer.R
#' @name mlr_optimizers_cmaes
#'
#' @description
#' `OptimizerCmaes` class that implements CMA-ES. Calls [adagio::pureCMAES()]
#' from package \CRANpkg{adagio}. The algorithm is typically applied to search
#' space dimensions between three and fifty. Lower search space dimensions might
#' crash.
#'
#' @templateVar id cmaes
#' @template section_dictionary_optimizers
#'
#' @cparam start_values (`character(1)`)\cr
#'   If `random` (default), start values are created randomly.
#'   If `center`, start values are the center of the search space.
#'   In the latter case, it is the center of the parameters before the transformation function is applied.
#' @cparam cparam_comment
#'   For the meaning of the control parameters, see [adagio::pureCMAES()].
#'   Note that we have removed all control parameters which refer to the termination of the algorithm and where our terminators allow to obtain the same behavior.
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
#'   instance = OptimInstanceSingleCrit$new(
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
OptimizerCmaes = R6Class("OptimizerCmaes",
  inherit = Optimizer,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        sigma = p_dbl(default = 0.5),
        start_values = p_fct(default = "random", levels = c("random", "center"))
      )
      param_set$values$start_values = "random"
      super$initialize(
        id = "cmaes",
        param_set = param_set,
        param_classes = "ParamDbl",
        properties = "single-crit",
        packages = "adagio",
        label = "Covariance Matrix Adaptation Evolution Strategy",
        man = "bbotk::mlr_optimizers_cmaes"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      pv = self$param_set$values
      pv$par = search_start(inst$search_space, type = pv$start_values)
      pv$start_values = NULL
      pv$stopeval = .Machine$integer.max # make sure pureCMAES does not stop
      pv$stopfitness = -Inf

      if (length(pv$par) < 2) warning("CMA-ES is typically applied to search space dimensions between three and fifty. A lower search space dimension might crash.")

      invoke(adagio::pureCMAES, fun = inst$objective_function, lower = inst$search_space$lower,
        upper = inst$search_space$upper, .args = pv)
    }
  )
)

mlr_optimizers$add("cmaes", OptimizerCmaes)
