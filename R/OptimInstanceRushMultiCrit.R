#' @title Multi Criterion Optimization Instance
#'
#' @description
#' The [OptimInstanceRushMultiCrit] specifies an optimization problem for [Optimizer]s.
#' Points are evaluated asynchronously with the `rush` package.
#' The function [oi()] creates an [OptimInstanceRushMultiCrit] and the function [bb_optimize()] creates an instance internally.
#'
#' @template param_objective
#' @template param_search_space
#' @template param_terminator
#' @template param_rush
#' @template param_callbacks
#' @template param_archive
#'
#' @export
OptimInstanceRushMultiCrit = R6Class("OptimInstanceRushMultiCrit",
  inherit = OptimInstanceRush,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(
      objective,
      search_space = NULL,
      terminator,
      rush,
      callbacks = list(),
      archive = NULL
      ) {
      if (objective$codomain$target_length == 1) {
        stop("Codomain length must be greater than 1.")
      }
      super$initialize(
        objective = objective,
        search_space = search_space,
        terminator = terminator,
        rush = rush,
        callbacks = callbacks,
        archive = archive)
    }
  ),

  private = list(
    assign_result = function(xdt, ydt) {
      # FIXME: We could have one way that just lets us put a 1xn DT as result directly.
      assert_data_table(xdt)
      assert_names(names(xdt), must.include = self$search_space$ids())
      assert_data_table(ydt)
      assert_names(names(ydt), permutation.of = self$objective$codomain$ids())
      x_domain = transform_xdt_to_xss(xdt, self$search_space)
      if (length(x_domain) == 0) x_domain = list(list())
      private$.result = cbind(xdt, x_domain = x_domain, ydt)
      call_back("on_result", self$callbacks, private$.context)
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
