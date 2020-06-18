#' @title Optimization Instance with budget and archive
#'
#' @description
#' Wraps an multi-criteria [Objective] function with extra services for convenient evaluation.
#' Inherits from [OptimInstance]
#'
#' @template param_xdt
#' @template param_ydt
#' @export
OptimInstanceMulticrit = R6Class("OptimInstanceMulticrit",
  inherit = OptimInstance,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param objective ([Objective]).
    #' @param search_space ([paradox::ParamSet]).
    #' @param terminator ([Terminator])\cr
    #' Multi-criteria terminator.
    initialize = function(objective, search_space, terminator) {
      super$initialize(objective, search_space, terminator)
    },

    #' @description
    #' The [Optimizer] object writes the best found points
    #' and estimated performance values here (e.g. the Pareto Front). For internal use.
    #'
    #' @param xdt (`data.table`)\cr
    #'   x values as `data.table`.
    #'   Each row is one point.
    #'   Contains the value in the *search space* of the [OptimInstance] object.
    #'   Can contain additional columns for extra information.
    #' @param ydt (`numeric(1)`)\cr
    #'   Optimal outcomes, e.g. the Pareto front.
    assign_result = function(xdt, ydt) {
      #FIXME: We could have one way that just lets us put a 1xn DT as result directly.
      assert_data_table(xdt)
      assert_names(names(xdt), must.include = self$search_space$ids())
      assert_data_table(ydt)
      assert_names(names(ydt), permutation.of = self$objective$codomain$ids())
      x_domain = transform_xdt_to_xss(xdt, self$search_space)
      private$.result = cbind(xdt, x_domain = x_domain, ydt)
    }
  ),

  active = list(
    #' @field result_x_search_space ([data.table::data.table])\cr
    #'   x part of the result in the *search space*.
    result_x_search_space = function() {
      private$.result[, self$search_space$ids(), with = FALSE]
    },

    #' @field result_x_domain (`list()`)\cr
    #'   (transformed) x part of the result in the *domain space* of the objective.
    result_x_domain = function() {
      private$.result$x_domain
    },

    #' @field result_y (`numeric(1)`)\cr
    #'   Optimal outcome.
    result_y = function() {
      private$.result[, self$objective$codomain$ids(), with = FALSE]
    }
  ),

  private = list(
    .result = NULL
  )
)
