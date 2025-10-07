#' @title Generalized Simulated Annealing
#'
#' @include Optimizer.R
#' @name mlr_optimizers_gensa
#'
#' @description
#' `OptimizerBatchGenSA` class that implements generalized simulated annealing.
#' Calls [GenSA::GenSA()] from package \CRANpkg{GenSA}.
#'
#' @templateVar id gensa
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' \describe{
#' \item{`par`}{`numeric()`\cr
#'   Initial parameter values.
#'   Default is `NULL`, in which case, default values will be generated automatically.}
#' \item{`start_values`}{`character(1)`\cr
#'   Create `"random"` start values or based on `"center"` of search space?
#'   In the latter case, it is the center of the parameters before a trafo is applied.
#'   By default, `nloptr` will generate start values automatically.
#'   Custom start values can be passed via the `par` parameter.}
#' }
#'
#' For the meaning of the control parameters, see [GenSA::GenSA()].
#' Note that [GenSA::GenSA()] uses `smooth = TRUE` as a default.
#' In the case of using this optimizer for Hyperparameter Optimization you may want to set `smooth = FALSE`.
#'
#' @section Internal Termination Parameters:
#' The algorithm can terminated with all [Terminator]s.
#' Additionally, the following internal termination parameters can be used:
#'
#' \describe{
#' \item{`maxit`}{`integer(1)`\cr
#'   Maximum number of iterations.
#'   Original default is `5000`.
#'   Overwritten with `.Machine$integer.max`.}
#' \item{`threshold.stop`}{`numeric(1)`\cr
#'   Threshold stop.
#'   Deactivated with `NULL`.
#'   Default is `NULL`.}
#' \item{`nb.stop.improvement`}{`integer(1)`\cr
#'   Number of stop improvement.
#'   Deactivated with `-1L`.
#'   Default is `-1L`.}
#' \item{`max.call`}{`integer(1)`\cr
#'   Maximum number of calls.
#'   Original default is `1e7`.
#'   Overwritten with `.Machine$integer.max`.}
#' \item{`max.time`}{`integer(1)`\cr
#'   Maximum time.
#'   Deactivate with `NULL`.
#'   Default is `NULL`.}
#' }
#'
#' @template section_progress_bars
#'
#' @source
#' `r format_bib("tsallis_1996", "xiang_2013")`
#'
#' @export
#' @examplesIf requireNamespace("GenSA", quietly = TRUE)
#' @examples
#' search_space = domain = ps(x = p_dbl(lower = -1, upper = 1))
#'
#' codomain = ps(y = p_dbl(tags = "minimize"))
#'
#' objective_function = function(xs) {
#'   list(y = as.numeric(xs)^2)
#' }
#'
#' objective = ObjectiveRFun$new(
#'   fun = objective_function,
#'   domain = domain,
#'   codomain = codomain)
#'
#' instance = OptimInstanceBatchSingleCrit$new(
#'   objective = objective,
#'   search_space = search_space,
#'   terminator = trm("evals", n_evals = 10))
#'
#' optimizer = opt("gensa")
#'
#' # Modifies the instance by reference
#' optimizer$optimize(instance)
#'
#' # Returns best scoring evaluation
#' instance$result
#'
#' # Allows access of data.table of full path of all evaluations
#' as.data.table(instance$archive$data)
OptimizerBatchGenSA = R6Class("OptimizerBatchGenSA", inherit = OptimizerBatch,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        par = p_uty(default = NULL),
        smooth = p_lgl(default = TRUE),
        temperature = p_dbl(default = 5230),
        visiting.param = p_dbl(default = 2.62, lower = 2.01, upper = 2.99),  # see https://journal.r-project.org/archive/2013-1/xiang-gubian-suomela-etal.pdf
        acceptance.param = p_dbl(default = -5, upper = -0.01),  # see https://journal.r-project.org/archive/2013-1/xiang-gubian-suomela-etal.pdf
        simple.function = p_lgl(default = FALSE),
        verbose = p_lgl(default = FALSE),
        trace.mat = p_lgl(default = TRUE),
        # bbotk parameters
        start_values = p_fct(levels = c("random", "center")),
        # internal termination criteria
        maxit = p_int(lower = 1L, init = .Machine$integer.max),
        threshold.stop = p_dbl(lower = 0),
        nb.stop.improvement = p_int(lower = 1L, init = -1L, special_vals = list(-1L)),
        max.call = p_int(lower = 1L, init = .Machine$integer.max),
        max.time = p_int(lower = 0L)
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
      pv = self$param_set$values

      if (!is.null(pv$start_values) && is.null(pv$par)) {
        pv$par = search_start(inst$search_space, type = pv$start_values)
      }
      pv$start_values = NULL
      par = pv$par
      pv$par = NULL

      GenSA::GenSA(
        par = par,
        fn = inst$objective_function,
        lower = inst$search_space$lower,
        upper = inst$search_space$upper,
        control = pv)
    }
  )
)

mlr_optimizers$add("gensa", OptimizerBatchGenSA)

# a note on smooth and simple.function
# smooth: switching the local search algorithm from using L-BFGS-B (default) to Nelder-Mead approach that works better when the objective function has very few places where numerical derivatives can be computed (highly non-smooth function)
# simple.function: simple.function argument is impacting the number of local searches performed when the best energy value is not updated after several iterations
# as we mainly use this for HPO smooth = FALSE and simple.function = FALSE seems sensible (we just assume the worst)
