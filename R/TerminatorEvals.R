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
#' \describe{
#' \item{`n_evals`}{`integer(1)`\cr
#' Number of allowed evaluations, default is 100L.}
#' }
#'
#' @family Terminator
#' @template param_archive
#' @export
#' @examples
#' TerminatorEvals$new()
#' trm("evals", n_evals = 5)
TerminatorEvals = R6Class("TerminatorEvals",
  inherit = Terminator,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      ps = ParamSet$new(list(ParamInt$new("n_evals", lower = 1L, default = 100L,
        tags = "required")))
      ps$values = list(n_evals = 100L)
<<<<<<< HEAD
      super$initialize(param_set = ps, properties = c("single-crit", "multi-crit", "progressr"))
=======

      super$initialize(param_set = ps, properties = c("single-crit",
        "multi-crit"))
>>>>>>> master
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE`
    #' otherwise.
    #' @return `logical(1)`.
    is_terminated = function(archive) {
      archive$n_evals >= self$param_set$values$n_evals
    },

    #' @description
    #' Returns the number of allowed evaluations.
    #' @return `integer(1)`
    progressr_steps = function(archive) {
      self$param_set$values$n_evals
    },

    #' @description
    #' Returns the number of evaluations in the last batch (`amount`) and the
    #' total number of evaluations (`sum`).
    #' @return list of `numeric(1)` and `integer(1)`
    progressr_update = function(archive) {
      amount = nrow(archive$data()[batch_nr == archive$n_batch])
      sum = archive$n_evals
      list(amount = amount, sum = sum)
    }
  ),
)

mlr_terminators$add("evals", TerminatorEvals)