#' @title Multi Criteria Optimization Instance for Asynchronous Optimization
#'
#' @description
#' The [OptimInstanceAsyncMultiCrit] specifies an optimization problem for an [OptimizerAsync].
#' The function [oi_async()] creates an [OptimInstanceAsyncMultiCrit].
#'
#' @template param_objective
#' @template param_search_space
#' @template param_terminator
#' @template param_check_values
#' @template param_callbacks
#' @template param_archive
#' @template param_rush
#'
#' @template param_xdt
#'
#' @export
OptimInstanceAsyncMultiCrit = R6Class("OptimInstanceAsyncMultiCrit",
  inherit = OptimInstanceAsync,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(
      objective,
      search_space = NULL,
      terminator,
      check_values = FALSE,
      callbacks = NULL,
      archive = NULL,
      rush = NULL
      ) {
      if (objective$codomain$target_length == 1) {
        stop("Codomain length must be greater than 1.")
      }
      super$initialize(
        objective = objective,
        search_space = search_space,
        terminator = terminator,
        check_values = check_values,
        rush = rush,
        callbacks = callbacks,
        archive = archive,
        label = "Async Multi Criteria Instance",
        man = "bbotk::OptimInstanceAsyncMultiCrit")
    },

    #' @description
    #' The [OptimizerAsync] writes the best found points and estimated performance values here (probably the Pareto set / front).
    #' For internal use.
    #'
    #' @param ydt (`numeric(1)`)\cr
    #' Optimal outcomes, e.g. the Pareto front.
    #' @param extra (`data.table::data.table()`)\cr
    #' Additional information.
    #' @param ... (`any`)\cr
    #' ignored.
    assign_result = function(xdt, ydt, extra, ...) {
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
