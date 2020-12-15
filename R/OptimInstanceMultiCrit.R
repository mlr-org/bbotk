#' @title Optimization Instance with budget and archive
#'
#' @description
#' Wraps a multi-criteria [Objective] function with extra services for
#' convenient evaluation. Inherits from [OptimInstance].
#'
#' * Automatic storing of results in an [Archive] after evaluation.
#' * Automatic checking for termination. Evaluations of design points are
#'   performed in batches. Before a batch is evaluated, the [Terminator] is
#'   queried for the remaining budget. If the available budget is exhausted, an
#'   exception is raised, and no further evaluations can be performed from this
#'   point on.
#'
#' @template param_xdt
#' @template param_ydt
#' @template param_search_space
#' @export
OptimInstanceMultiCrit = R6Class("OptimInstanceMultiCrit",
  inherit = OptimInstance,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param objective ([Objective]).
    #' @param terminator ([Terminator])\cr
    #' Multi-criteria terminator.
    #' @param archive_type (`character(1)`)\cr
    #' Archive type that stores full archive (`Archive`),
    #' only best result (`ArchiveBest`) or only y (`ArchiveY`).
    initialize = function(objective, search_space = NULL, terminator,
      archive_type = "Archive") {
      super$initialize(objective, search_space, terminator, archive_type)
    },

    #' @description
    #' The [Optimizer] object writes the best found points
    #' and estimated performance values here (probably the Pareto set / front).
    #' For internal use.
    #'
    #' @param ydt (`numeric(1)`)\cr
    #'   Optimal outcomes, e.g. the Pareto front.
    assign_result = function(xdt, ydt) {
      # FIXME: We could have one way that just lets us put a 1xn DT as result directly.
      assert_data_table(xdt)
      assert_names(names(xdt), must.include = self$search_space$ids())
      assert_data_table(ydt)
      assert_names(names(ydt), permutation.of = self$objective$codomain$ids())
      x_domain = transform_xdt_to_xss(xdt, self$search_space)
      private$.result = cbind(xdt, x_domain = x_domain, ydt)
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
