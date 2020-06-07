#' @title Terminator that stops after a number of evaluations
#'
#' @name mlr_terminators_evals
#' @include Terminator.R
#'
#' @description
#' Class to terminate the optimization depending on the number of evaluations.
#' An evaluation is defined by one resampling of a parameter value.
#'
#' @templateVar id evals
#' @template section_dictionary_terminator
#'
#' @section Parameters:
#' * `n_evals` `integer(1)`\cr
#'   Number of allowed evaluations, default is 100L
#'
#' @family Terminator
#' @export
#' @examples
#' TerminatorEvals$new()
#' term("evals", n_evals = 5)
TerminatorEvals = R6Class("TerminatorEvals",
  inherit = Terminator,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      ps = ParamSet$new(list(ParamInt$new("n_evals", lower = 1L, default = 100L,
        tags = "required")))
      ps$values = list(n_evals = 100L)

      super$initialize(param_set = ps, properties = "multi-objective")
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE`
    #' otherwise.
    #' @param archive ([Archive]).
    #' @return `logical(1)`.
    is_terminated = function(archive) {
      if (is.null(self$progressor)) {
        n = self$param_set$values$n_evals
        self$progressor = get_progressor(n)
      } else {
        self$progressor(message = sprintf("%i", archive$n_evals),
          amount = archive$n_evals / archive$n_batch)
      }
      archive$n_evals >= self$param_set$values$n_evals
    }
  )
)

mlr_terminators$add("evals", TerminatorEvals)
