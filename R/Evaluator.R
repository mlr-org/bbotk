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
      # FIXME: for loop ok, but not great, can we turn the design into a list in an easier way?
      for (i in 1:nrow(xdt)) {
        xs = as.list(xdt[i,])
        print(str(xs))
        y = self$objective$fun(xs)
        assert_numeric(y, len = self$objective$ydim, any.missing = FALSE, finite = TRUE)
        ydt = as.data.table(as.list(y))
        xydt = cbind(xdt, ydt)
      }
      self$archive$add_evals(xydt)
      return(ydt)
    }
  )
)


