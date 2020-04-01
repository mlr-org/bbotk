
#' @title Evaluator for logged and parralel evaluations
#'
#' @usage NULL
#' @format [R6::R6Class] object.
#'
#' @description
#' Wraps an [Objective] function with extra services for convenient evaluation.
#'
#' * Automatic storing of results in an [Archive] after evaluation.
#' * Automatic checking for termination. Evaluations of design points are performed in batches.
#'   Before a batch is evaluated, the [Terminator] is queried for the remaining budget.
#'   If the available budget is exhausted, an exception is raised, and no further evaluations can be performed from this point on.
#' * Parallel evaluation of a batch via [future.apply::future_lapply()].
#' * Logging of evaluations on R console
#' * Encapsulated evaluation via evaluate / callr with function [mlr3misc::encapsulate()]
#'   to guard against exceptions and even segfaults.
#'   Note that behavior is define in [Objective] argument `encapsulate`.
#'
#' @section Construction:
#' ```
#' ev = Evaluator$new(objective, archive, terminator)
#' ```
#' * `objective` :: [Objective].
#' * `archive` :: [Archive].
#' * `terminator` :: [Terminator].
#'
#' @section Fields:
#' * `objective` :: [Objective]; from construction.
#' * `terminator` :: [Terminator]; from construction.
#'
#' @section Methods:
#' * `eval_batch(dt)`\cr
#'   [data.table::data.table()] -> named `list()`\cr
#'   Evaluates all hyperparameter configurations in `dt` through resampling, where each configuration is a row, and columns are scalar parameters.
#'   eturns a named list with the following elements:
#'   * `"batch_nr"`: Number of the new batch.
#'     This number is calculated in an auto-increment fashion.
#'   * `"perf"`: A [data.table::data.table()] of evaluated performances for each row of the `dt`.
#'     Has the same number of rows as `dt`, and the same number of columns as length of `measures`.
#'     Columns are named with measure-IDs. A cell entry is the (aggregated) performance of that configuration for that measure.
#'
#'   Before each batch-evaluation, the [Terminator] is checked, and if it is positive, an exception of class `terminated_error` is raised.
#'   This function should be internally called by the tuner.
#'
#'
#' @export

Evaluator = R6Class("Archive",
  public = list(
    objective = NULL,
    archive = NULL,
    terminator = NULL,
    terminated = FALSE,

    initialize = function(objective, archive, terminator) {
      self$objective = assert_r6(objective, "Objective")
      self$archive = assert_r6(archive, "Archive")
      self$terminator = assert_r6(terminator, "Terminator")
      self$terminated = FALSE
    },

  )
)
