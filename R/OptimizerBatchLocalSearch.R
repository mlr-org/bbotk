#' @title Optimization via Local Search
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
#' @section Parameters:\cr
#' The same as for [local_search_control()], with the same defaults (except for `minimize`).
#'
#' @template section_progress_bars
#'
#' @export
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
        mut_sigma_init = p_dbl(lower = 0L, default = ls_default$mut_sigma_init),
        mut_sigma_factor = p_dbl(lower = 1L, default = ls_default$mut_sigma_factor),
        mut_sigma_max = p_dbl(lower = 0L, default = ls_default$mut_sigma_max),
        lahc_buf_size = p_int(lower = 1L, default = ls_default$lahc_buf_size),
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
