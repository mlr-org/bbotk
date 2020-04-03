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

      #' @field search_space [paradox::ParamSet]
      search_space = NULL,

      #' @field terminator [Terminator]
      terminator = NULL,

      #' @field is_terminated `logical(1)`
      is_terminated = FALSE,

      #' @field archive [Archive]
      archive = NULL,

      #' @description
      #' Creates a new instance of this [R6][R6::R6Class] class.
      #' @param objective [Objective]
      #' @param search_space [paradox::ParamSet]
      #' @param terminator [Terminator]
      initialize = function(objective, search_space, terminator) {
        self$objective = assert_r6(objective, "Objective")
        self$search_space = assert_param_set(search_space)
        self$terminator = assert_terminator(terminator)
        self$archive = Archive$new(search_space = search_space, codomain = objective$codomain)
      },

      #' @description
      #' Helper for print outputs.
      format = function() {
        sprintf("<%s>", class(self)[1L])
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
        if (self$is_terminated || self$terminator$is_terminated(self$archive)) {
          self$is_terminated = TRUE
          stop(terminated_error(self))
        }
        design = Design$new(self$search_space, xdt, remove_dupl = FALSE)
        xss_trafoed = design$transpose(trafo = TRUE, filter_na = TRUE)
        ydt = self$objective$eval_many(xss_trafoed)
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
    #' @field result Get result
    result = function() {
      list(x = private$.result$x, y = private$.result$y)
    }
  ),

  private = list(
    .result = NULL
  )
)
