#' @title Single Criterion Optimization Instance with Rush
#'
#' @description
#' The [OptimInstanceRushSingleCrit] specifies an optimization problem for [Optimizer]s.
#' Points are evaluated asynchronously with the `rush` package.
#' The function [oi()] creates an [OptimInstanceRushSingleCrit] and the function [bb_optimize()] creates an instance internally.
#'
#' @template param_objective
#' @template param_search_space
#' @template param_terminator
#' @template param_rush
#' @template param_callbacks
#' @template param_archive
#'
#' @export
OptimInstanceRushSingleCrit = R6Class("OptimInstanceRushSingleCrit",
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
      if (objective$codomain$target_length > 1) {
        stop("Codomain length must be 1.")
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
    .assign_result = function(xdt, y) {
      # FIXME: We could have one way that just lets us put a 1xn DT as result directly.
      assert_data_table(xdt)
      assert_names(names(xdt), must.include = self$search_space$ids())
      assert_number(y)
      assert_names(names(y), permutation.of = self$objective$codomain$target_ids)
      x_domain = unlist(transform_xdt_to_xss(xdt, self$search_space), recursive = FALSE)
      if (is.null(x_domain)) x_domain = list()
      private$.result = cbind(xdt, x_domain = list(x_domain), t(y)) # t(y) so the name of y stays
      call_back("on_result", self$callbacks, private$.context)
    }
  )
)
