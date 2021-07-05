#' @title Optimization via Covariance Matrix Adaptation Evolution Strategy
#'
#' @include Optimizer.R
#' @name mlr_optimizers_cmaes
#'
#' @description
#' `OptimizerCmaes` class that implements CMA-ES. Calls
#' [adagio::pureCMAES()] from package \CRANpkg{adagio}.
#'
#' @templateVar id cmaes
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' \describe{
#' \item{`sigma`}{`numeric(1)`}
#' \item{`start_values`}{`character(1)`\cr
#' Create `random` start values or based on `center` of search space? In the 
#' latter case, it is the center of the parameters before a trafo is applied.}
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
#' if(requireNamespace("adagio")) {
#'
#' search_space = domain = ps(x = p_dbl(lower = -1, upper = 1))
#'
#' codomain = ps(y = p_dbl(tags = "minimize"))
#'
#' objective_function = function(xs) {
#'   list(y = as.numeric(xs)^2)
#' }
#'
#' objective = ObjectiveRFun$new(
#'  fun = objective_function,
#'  domain = domain,
#'  codomain = codomain)
#'
#' instance = OptimInstanceSingleCrit$new(
#'  objective = objective,
#'  search_space = search_space,
#'  terminator = trm("evals", n_evals = 10))
#'
#' optimizer = opt("cmaes")
#'
#' # Modifies the instance by reference
#' optimizer$optimize(instance)
#'
#' # Returns best scoring evaluation
#' instance$result
#'
#' # Allows access of data.table of full path of all evaluations
#' as.data.table(instance$archive$data)
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
      pv$par = search_start(inst$search_space, type = pv$start_values)
      pv$start_values = NULL
      pv$stopeval = .Machine$integer.max # make sure pureCMAES does not stop
      pv$stopfitness = -Inf

      invoke(adagio::pureCMAES, fun = inst$objective_function,
             lower = inst$search_space$lower, upper = inst$search_space$upper,
             .args = pv)
    }
  )
)

mlr_optimizers$add("cmaes", OptimizerCmaes)
