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

    # FIXME: function is somewhat duplicated with Objective$eval...?
    eval = function(xdt) {
      # FIXME: this asserts, but we need a better helper for this
      Design$new(self$objective$domain, xdt, FALSE)
      ydt = self$objective$fun(xdt)
      Design$new(self$objective$codomain, ydt, FALSE)
      xydt = cbind(xdt, ydt)
      self$archive$add_evals(xydt)
      return(ydt)
    }
  )
)


