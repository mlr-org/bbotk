#FIXME: ist der paramset-name hier wirklich gut? ist mehr das feasible set?

#' @title Optimization Instance with budget and archive
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
#' @export
OptimInstance = R6Class("OptimInstance",
  public = list(

      #' @field objective [Objective]
      objective = NULL,

      #' @field param_set [paradox::ParamSet]
      param_set = NULL,

      #' @field terminator [Terminator]
      terminator = NULL,

      #' @field archive [Archive]
      archive = NULL,

      #' @description
      #' Creates a new instance of this [R6][R6::R6Class] class.
      #' @param objective [Objective]
      #' @param param_set [paradox::ParamSet]
      #' @param terminator [Terminator]
      initialize = function(objective, param_set, terminator) {
        self$objective = objective
        self$param_set = param_set
        self$terminator = terminator
      },

      #' @description
      #' Evaluates all hyperparameter configurations in `dt` through
      #' resampling, where each configuration is a row, and columns are scalar
      #' parameters. eturns a named list with the following elements:
      #'
      #' * `"batch_nr"`: Number of the new batch. This number is calculated in an
      #' auto-increment fashion.
      #'
      #' * `"perf"`: A [data.table::data.table()] of
      #' evaluated performances for each row of the `dt`. Has the same number
      #' of rows as `dt`, and the same number of columns as length of
      #' `measures`. Columns are named with measure-IDs. A cell entry is the
      #' (aggregated) performance of that configuration for that measure.
      #'
      #' Before each batch-evaluation, the [Terminator] is checked, and if it
      #' is positive, an exception of class `terminated_error` is raised. This
      #' function should be internally called by the tuner.
      #' @param xdt [data.table::data.table]
      eval_batch = function(xdt) {
        if (self$terminator$is_terminated(self)) {
          return(NULL)
        }
        design = Design$new(self$param_set, xdt, remove_dupl = FALSE)
        xss_trafoed = design$transpose(trafo = TRUE, filter_na = TRUE)
        ydt = self$objective$evaluate_many(xdt)
        # FIXME: also add things like parlist_trafo, parlist_untrafoed to result
        # FIXME: collect the trace in some way
        self$archive$add_evals(xdt, xss_trafoed, ydt)
        return(invisible(ydt))
      },

      #' @description
      #' The [Optimizer] object writes the best found point
      #' and estimated performance values here. For internal use.
      #' @param x `character`
      #' @param y `numeric`
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
