#FIXME: ist der paramset-name hier wirklich gut? ist mehr das feasible set?

#' @title Optimization Instance with budget and archive
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
#' * Logging of evaluations on R console
#' * Encapsulated evaluation via evaluate / callr with function [mlr3misc::encapsulate()]
#'   to guard against exceptions and even segfaults.
#'   Note that behavior is define in [Objective] argument `encapsulate`.
#'
#' @section Construction:
#' ```
#' inst = OptimInstance$new(objective, param_set, terminator)
#' ```
#' * `objective` :: [Objective].
#' * `param_set` :: [ParamSet].
#' * `terminator` :: [Terminator].
#'
#' @section Fields:
#' * `objective` :: [Objective]; from construction.
#' * `param_Set` :: [ParamSet]; from construction.
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
OptimInstance = R6Class("OptimInstance",
  public = list(
      objective = NULL,
      param_set = NULL,
      terminator = NULL,
      archive = NULL,
      initialize = function(objective, param_set, terminator) {
        self$objective = objective
        self$param_set = param_set
        self$terminator = terminator
      },

      eval_batch = function(dt) {
        if (self$terminator$is_terminated(self)) {
          return(NULL)
        }
        design = Design$new(self$param_set, dt, remove_dupl = FALSE)
        parlist_trafoed = design$transpose(trafo = TRUE, filter_na = TRUE)
        result = self$objective$evaluate_many(dt)
        # TODO: also add things like parlist_trafo, parlist_untrafoed to result
        database = if (is.null(database)) result else rbind(database, result)  # collect the trace in some way
        result
      },

      assign_result = function(x, y) {
        assert_names(x, subset.of = self$objective$domain$ids())
        assert_numeric(y)
        assert_names(names(y), permutation.of = self$objective$codomain$ids())
        private$.result = list(feat = feat, perf = perf)
      }
  ),

  active = list(
    #' @field result
    result = function() {
      list(x = private$.result$x, y = private$.result$y)
    }
  ),

  private = list(
    .result = NULL
  )
)
