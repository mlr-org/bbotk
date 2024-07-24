#' @title Single Criterion Optimization Instance for Asynchronous Optimization
#'
#' @description
#' The `OptimInstanceAsyncSingleCrit` specifies an optimization problem for an [OptimizerAsync].
#' The function [oi_async()] creates an [OptimInstanceAsyncSingleCrit].
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
OptimInstanceAsyncSingleCrit = R6Class("OptimInstanceAsyncSingleCrit",
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
      if (objective$codomain$target_length > 1) {
        stop("Codomain length must be 1.")
      }

      super$initialize(
        objective = objective,
        search_space = search_space,
        terminator = terminator,
        check_values = check_values,
        callbacks = callbacks,
        archive = archive,
        rush = rush,
        label = "Async Single Criteria Instance",
        man = "bbotk::OptimInstanceAsyncSingleCrit")
    },

    #' @description
    #' The [OptimizerAsync] object writes the best found point and estimated performance value here.
    #' For internal use.
    #'
    #' @param y (`numeric(1)`)\cr
    #' Optimal outcome.
    #' @param ... (`any`)\cr
    #' ignored.
    assign_result = function(xdt, y, ...) {
      # FIXME: We could have one way that just lets us put a 1xn DT as result directly.
      assert_data_table(xdt)
      assert_names(names(xdt), must.include = self$search_space$ids())
      assert_number(y)
      assert_names(names(y), permutation.of = self$objective$codomain$target_ids)
      x_domain = unlist(transform_xdt_to_xss(xdt, self$search_space), recursive = FALSE)
      if (is.null(x_domain)) x_domain = list()
      private$.result = cbind(xdt, x_domain = list(x_domain), t(y)) # t(y) so the name of y stays
      call_back("on_result", self$objective$callbacks, self$objective$context)
    }
  ),

  active = list(

    #' @field result_x_domain (`list()`)\cr
    #' (transformed) x part of the result in the *domain space* of the objective.
    result_x_domain = function() {
      private$.result$x_domain[[1]]
    },

    #' @field result_y (`numeric()`)\cr
    #' Optimal outcome.
    result_y = function() {
      unlist(private$.result[, self$objective$codomain$ids(), with = FALSE])
    }
  )
)
