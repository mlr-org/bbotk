#' @title Optimization via Generalized Simulated Annealing
#'
#' @include Optimizer.R
#' @name mlr_optimizers_gensa
#'
#' @description
#' `OptimizerGenSA` class that implements generalized simulated annealing. Calls
#' [GenSA::GenSA()] from package \CRANpkg{GenSA}.
#'
#' @templateVar id gensa
#' @template section_dictionary_optimizers
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
#' For the meaning of the control parameters, see [GenSA::GenSA()]. Note that we
#' have removed all control parameters which refer to the termination of the
#' algorithm and where our terminators allow to obtain the same behavior.
#'
#' @source
#' `r format_bib("tsallis_1996", "xiang_2013")`
#'
#' @export
#' @examples
#' if(requireNamespace("GenSA")) {
#' library(paradox)
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
#'                               domain = domain,
#'                               codomain = codomain)
#' terminator = trm("evals", n_evals = 10)
#' instance = OptimInstanceSingleCrit$new(
#'  objective = objective,
#'  search_space = search_space,
#'  terminator = terminator)
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
OptimizerGenSA = R6Class("OptimizerGenSA", inherit = Optimizer,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      ps = ParamSet$new(list(
        ParamLgl$new("smooth", default = TRUE),
        ParamDbl$new("temperature", default = 5230),
        ParamDbl$new("acceptance.param", default = -5),
        ParamLgl$new("verbose", default = FALSE),
        ParamLgl$new("trace.mat", default = TRUE)
      ))
      super$initialize(
        param_set = ps,
        param_classes = "ParamDbl",
        properties = "single-crit",
        packages = "GenSA"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      v = self$param_set$values
      v$maxit = .Machine$integer.max # make sure GenSA does not stop
      GenSA::GenSA(par = NULL, fn = inst$objective_function,
        lower = inst$search_space$lower, upper = inst$search_space$upper,
        control = v)
    }
  )
)

mlr_optimizers$add("gensa", OptimizerGenSA)
