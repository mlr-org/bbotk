#' @title Local Search
#'
#' @include Optimizer.R
#' @name mlr_optimizers_local_search
#'
#' @description
#' Implements a simple Local Search, see [local_search()] for details.
#' Currently, setting initial points is not supported.
#'
#' @templateVar id local_search
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' The same as for [local_search_control()], with the same defaults (except for `minimize`).
#'
#' @template section_progress_bars
#'
#' @export
#' @examples
#' # define the objective function
#' fun = function(xs) {
#'   list(y = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
#' }
#'
#' # set domain
#' domain = ps(
#'   x1 = p_dbl(-10, 10),
#'   x2 = p_dbl(-5, 5)
#' )
#'
#' # set codomain
#' codomain = ps(
#'   y = p_dbl(tags = "maximize")
#' )
#'
#' # create objective
#' objective = ObjectiveRFun$new(
#'   fun = fun,
#'   domain = domain,
#'   codomain = codomain,
#'   properties = "deterministic"
#' )
#'
#' # initialize instance
#' instance = oi(
#'   objective = objective,
#'   terminator = trm("evals", n_evals = 20)
#' )
#'
#' # load optimizer
#' optimizer = opt("local_search")
#'
#' # trigger optimization
#' optimizer$optimize(instance)
#'
#' # all evaluated configurations
#' instance$archive
#'
#' # best performing configuration
#' instance$result
OptimizerBatchLocalSearch = R6Class("OptimizerBatchLocalSearch",
  inherit = bbotk::OptimizerBatch,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      ls_default = local_search_control()
      ls_default$minimize = NULL
      param_set = ps(
        n_searches = p_int(lower = 1L, default = ls_default$n_searches),
        n_steps = p_int(lower = 1L, default = ls_default$n_steps),
        n_neighs = p_int(lower = 1L, default = ls_default$n_neighs),
        mut_sd = p_dbl(lower = 0L, default = ls_default$mut_sd),
        stagnate_max = p_int(lower = 1L, default = ls_default$stagnate_max)
      )
      param_set$values = ls_default

      super$initialize(
        id = "local_search",
        param_set = param_set,
        param_classes = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct"),
        properties = c("dependencies", "single-crit"),
        label = "Local Search",
        man = "bbotk::mlr_optimizers_local_search"
      )
    }
  ),
  private = list(
    .optimize = function(inst) {
      psv = self$param_set$values
      minimize = "minimize" %in% inst$objective$codomain$tags
      psv$minimize = minimize
      ctrl = do.call(local_search_control, psv)
      obj = function(xdt) inst$eval_batch(xdt)[[1]]
      local_search(obj, inst$search_space, ctrl)
    }
  )
)

mlr_optimizers$add("local_search", OptimizerBatchLocalSearch)
