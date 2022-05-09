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
#' @template section_progress_bars
#'
#' @source
#' `r format_bib("tsallis_1996", "xiang_2013")`
#'
#' @export
#' @examples
#' if (requireNamespace("GenSA")) {
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
#'   instance = OptimInstanceSingleCrit$new(
#'     objective = objective,
#'     search_space = search_space,
#'     terminator = trm("evals", n_evals = 10))
#'
#'   optimizer = opt("cmaes")
#'
#'   # Modifies the instance by reference
#'   optimizer$optimize(instance)
#'
#'   # Returns best scoring evaluation
#'   instance$result
#'
#'   # Allows access of data.table of full path of all evaluations
#'   as.data.table(instance$archive$data)
#' }
OptimizerGenSA = R6Class("OptimizerGenSA", inherit = Optimizer,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        smooth = p_lgl(default = TRUE),
        temperature = p_dbl(default = 5230),
        acceptance.param = p_dbl(default = -5),
        verbose = p_lgl(default = FALSE),
        trace.mat = p_lgl(default = TRUE)
      )
      super$initialize(
        id = "gensa",
        param_set = param_set,
        param_classes = "ParamDbl",
        properties = "single-crit",
        packages = "GenSA",
        label = "Generalized Simulated Annealing",
        man = "bbotk::mlr_optimizers_gensa"
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
