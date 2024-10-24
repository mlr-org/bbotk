#' @title Multi Criteria Optimization Instance for Batch Optimization
#'
#' @description
#' The [OptimInstanceBatchMultiCrit] specifies an optimization problem for an [OptimizerBatch].
#' The function [oi()] creates an [OptimInstanceBatchMultiCrit].
#'
#' @template param_objective
#' @template param_search_space
#' @template param_terminator
#' @template param_check_values
#' @template param_callbacks
#' @template param_archive
#'
#' @template param_xdt
#' @template param_ydt
#'
#' @export
OptimInstanceBatchMultiCrit = R6Class("OptimInstanceBatchMultiCrit",
  inherit = OptimInstanceBatch,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(
      objective,
      search_space = NULL,
      terminator,
      check_values = TRUE,
      callbacks = NULL,
      archive = NULL
      ) {
      super$initialize(
        objective = objective,
        search_space = search_space,
        terminator = terminator,
        check_values = check_values,
        callbacks = callbacks,
        archive = archive,
        label = "Batch Multi Criteria Instance",
        man = "bbotk::OptimInstanceBatchMultiCrit")
    },

    #' @description
    #' The [Optimizer] object writes the best found points
    #' and estimated performance values here (probably the Pareto set / front).
    #' For internal use.
    #' @param extra (`data.table::data.table()`)\cr
    #' Additional information.
    #' @param ... (`any`)\cr
    #' ignored.
    assign_result = function(xdt, ydt, extra = NULL, ...) {
      # FIXME: We could have one way that just lets us put a 1xn DT as result directly.
      assert_data_table(xdt)
      assert_names(names(xdt), must.include = self$search_space$ids())
      assert_data_table(ydt)
      assert_names(names(ydt), permutation.of = self$objective$codomain$ids())
      private$.result_extra = assert_data_table(extra, null.ok = TRUE)
      x_domain = transform_xdt_to_xss(xdt, self$search_space)
      if (length(x_domain) == 0) x_domain = list(list())
      private$.result = cbind(xdt, x_domain = x_domain, ydt)
      call_back("on_result", self$objective$callbacks, self$objective$context)
    }
  ),

  active = list(
    #' @field result_x_domain (`list()`)\cr
    #' (transformed) x part of the result in the *domain space* of the objective.
    result_x_domain = function() {
      private$.result$x_domain
    },

    #' @field result_y (`numeric(1)`)\cr
    #' Optimal outcome.
    result_y = function() {
      private$.result[, self$objective$codomain$ids(), with = FALSE]
    }
  )
)
