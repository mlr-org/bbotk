#' @title None Terminator
#'
#' @name mlr_terminators_none
#' @include Terminator.R
#'
#' @description
#' Mainly useful for optimization algorithms where the stopping is inherently controlled by the algorithm itself (e.g. [OptimizerGridSearch]).
#'
#' @templateVar id none
#' @template section_dictionary_terminator
#'
#' @family Terminator
#'
#' @template param_archive
#'
#' @export
TerminatorNone = R6Class("TerminatorNone",
  inherit = Terminator,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(
        id = "none",
        properties = c("single-crit", "multi-crit"),
        label = "None",
        man = "bbotk::mlr_terminators_none"
        )
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE`
    #' otherwise.
    #'
    #' @return `logical(1)`.
    is_terminated = function(archive) {
      assert_r6(archive, "Archive")
      return(FALSE)
    }
  )
)

mlr_terminators$add("none", TerminatorNone)
