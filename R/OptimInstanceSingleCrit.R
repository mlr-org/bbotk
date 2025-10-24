#' @title Single Criterion Optimization Instance for Batch Optimization
#'
#' @description
#' `OptimInstanceSingleCrit` is a deprecated class that is now a wrapper around `OptimInstanceBatchSingleCrit`.
#'
#' @template param_objective
#' @template param_search_space
#' @template param_terminator
#' @template param_check_values
#' @template param_callbacks
#' @template param_keep_evals
#'
#' @seealso [OptimInstanceBatchSingleCrit]
#' @export
OptimInstanceSingleCrit = R6Class("OptimInstanceSingleCrit",
  inherit = OptimInstanceBatchSingleCrit,
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

      message("OptimInstanceSingleCrit is deprecated. Use OptimInstanceBatchSingleCrit instead.")

      super$initialize(
        objective = objective,
        search_space = search_space,
        terminator = terminator,
        check_values = check_values,
        callbacks = callbacks)
    }
  )
)
