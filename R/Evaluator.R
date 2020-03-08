#' Evaluator for logged and parralel evaluations
#'
#' Allow the following modified evaluation of objection function:
#' * In parallel
#' * Logged on the console
#' * Logged in archive object
#' * Encapsulated evaluation via callr
#' * Check for termination

Evaluator = R6Class("Archive",
  public = list(
    objective = NULL,
    archive = NULL,
    terminator = NULL,

    initialize = function(objective, archive, terminator) {
      assert_r6(objective, "Objective")
      assert_r6(archive, "Archive")
      assert_r6(terminator, "Terminator")
      self$objective = objective
      self$archive = archive
      self$terminator = terminator
    },

    eval = function(xdt) {
      # FIXME: this asserts, but we need a better helper for this
      Design$new(self$objective$domain, xdt, FALSE)
      ydt = data.table()
      n = nrow(xdt)
      if (use_future()) {
        lg$debug("Running Evaluator::eval() via future with %i iterations", n)
        res = future.apply::future_lapply(seq_len(n), workhorse, objective = self$objective, xdt = xdt,
          future.globals = FALSE, future.scheduling = structure(TRUE, ordering = "random"),
          future.packages = "bbotk")
      } else {
        lg$debug("Running Evaluator::eval() sequentially with %i iterations", n)
        res = lapply(seq_len(n), workhorse, objective = self$objective, xdt = xdt)
      }
      ydt = rbindlist(res)
      xydt = cbind(xdt, ydt)
      self$archive$add_evals(xydt)
      return(ydt)
    }
  )
)

workhorse = function(i, objective, xdt) {
  xs = as.list(xdt[i,])
  n = nrow(xdt)
  lg$info("Eval point '%s' (batch %i/%i)", as_short_string(xs), i, n)
  y = objective$fun(xs)
  assert_numeric(y, len = objective$ydim, any.missing = FALSE, finite = TRUE)
  as.list(y)
}
