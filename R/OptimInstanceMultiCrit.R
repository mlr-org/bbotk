#' @title Multi Criteria Optimization Instance for Batch Optimization
#'
#' @description
#' `OptimInstanceMultiCrit` is a deprecated class that is now a wrapper around [OptimInstanceBatchMultiCrit].
#'
#' @template param_objective
#' @template param_search_space
#' @template param_terminator
#' @template param_check_values
#' @template param_callbacks
#' @template param_keep_evals
#'
#' @seealso [OptimInstanceBatchMultiCrit]
#' @export
OptimInstanceMultiCrit = R6Class("OptimInstanceMultiCrit",
  inherit = OptimInstanceBatchMultiCrit,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(
      objective,
      search_space = NULL,
      terminator,
      keep_evals = "all",
      check_values = TRUE,
      callbacks = NULL
      ) {

      message("OptimInstanceMultiCrit is deprecated. Use OptimInstanceBatchMultiCrit instead.")

      super$initialize(
        objective = objective,
        search_space = search_space,
        terminator = terminator,
        check_values = check_values,
        callbacks = callbacks)
    }
  )
)
