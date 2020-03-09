#FIXME: do we want the "unnest" feature as in mlr3tuning
#FIXME: how do we handle it that we can actually log multiple extra things to the archive from the objective?
# we need to check in mlr3tuning the case of SOO but with multiple measures
# FIXME: implement the "tuner_objective" service function which can directly be passed to on optimizer
# FIXME: do we need the start time in the evaluator
# FIXME: we could add some basic, simple optimizers from R here. connecting them here would enable them for many
#  tasks in optimization, not only mlr3tuning. think then how mlr3mbo extends this system then / regiusters itself
# FIXME: maybe also connect some stuff from ecr2?
# #FIXME: provide some basic MOO functionality
# FIXME: write a simple tutorial. this should include how parallezation works. does this go into the mlr3 book?
# FIXME: implement "best" function from Tuning Instance

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
#' * Parallel evaluation of a batch via [future.apply::future.lapply].
#' * Logging of evaluations on R console
#' * Encapsulated evaluation via evaluate / callr with function [mlr3misc::encapsulate]
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

    initialize = function(objective, archive, terminator) {
      self$objective = assert_r6(objective, "Objective")
      self$archive = assert_r6(archive, "Archive")
      self$terminator = assert_r6(terminator, "Terminator")
    },

    eval_batch = function(xdt) {
      # xdt can contain missings because of non-fulfilled dependencies
      assert_data_table(xdt, any.missing = TRUE, min.rows = 1L, min.cols = 1L)
      # FIXME: this asserts, but we need a better helper for this
      # this checks the validity of xdt lines in the paramset
      design = Design$new(self$objective$domain, xdt, remove_dupl = FALSE)
      if (self$terminator$is_terminated(self$archive)) {
        stop(terminated_error(self))
      }
      # convert configs to lists and remove non-satisfied deps
      parlist_trafoed = design$transpose(trafo = TRUE, filter_na = TRUE)
      parlist_untrafoed = design$transpose(trafo = FALSE, filter_na = TRUE)

      #FIXME: run unit tests with encaps + termination and real function error
      ydt = data.table()
      n = nrow(xdt)
      if (use_future()) {
        lg$debug("Running Evaluator::eval() via future with %i iterations", n)
        res = future.apply::future_lapply(seq_len(n), workhorse,
          objective = self$objective, xs = parlist_trafoed,
          future.globals = FALSE, future.scheduling = structure(TRUE, ordering = "random"),
          future.packages = "bbotk")
      } else {
        lg$debug("Running Evaluator::eval() sequentially with %i iterations", n)
        res = lapply(seq_len(n), workhorse, objective = self$objective, xs = parlist_trafoed)
      }

      ydt = rbindlist(res)
      xydt = cbind(xdt, ydt)

      # add column "batch_nr"

      # add column "tune_x"
      #FIXME: in mlr3tuning this was call "tune_x"
      # FIXME: maybe handle "opt_x" and "batch_nr" down in call "add_evals"?
      self$archive$add_evals(xdt, ydt)
      return(ydt)
    }
  )
)

workhorse = function(i, objective, xs) {
  x = as.list(xs[[i]])
  n = length(xs)
  lg$info("Eval point '%s' (batch %i/%i)", as_short_string(x), i, n)
  res = encapsulate(
    method = objective$encapsulate,
    .f = objective$fun,
    .args = list(x = x),
    # FIXME: we likely need to allow the user to configure this? or advice to load all paackaes in the user defined objective function?
    .pkgs = "bbotk",
    .seed = NA_integer_
  )
  # FIXME: encapsulate also returns time and log, we should probably do something with it?
  y = res$result
  assert_numeric(y, len = objective$ydim, any.missing = FALSE, finite = TRUE)
  lg$info("Result '%s'", as_short_string(y))
  as.list(y)
}
