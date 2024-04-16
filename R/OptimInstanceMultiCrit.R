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
#' @template param_keep_evals
#' @template param_callbacks
#' @template param_archive
#'
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
    #' @param check_values (`logical(1)`)\cr
    #' Should x-values that are added to the archive be checked for validity?
    #' Search space that is logged into archive.
    initialize = function(
      objective,
      search_space = NULL,
      terminator,
      keep_evals = "all",
      check_values = TRUE,
      callbacks = list(),
      archive = NULL
      ) {
      super$initialize(
        objective = objective,
        search_space = search_space,
        terminator = terminator,
        keep_evals = keep_evals,
        check_values = check_values,
        callbacks = callbacks,
        archive = archive)
    },

    #' @description
    #' The [Optimizer] object writes the best found points
    #' and estimated performance values here (probably the Pareto set / front).
    #' For internal use.
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
