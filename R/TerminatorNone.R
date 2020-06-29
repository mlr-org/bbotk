#' @title Terminator that never stops.
#'
#' @include Terminator.R
#'
#' @description
#' Mainly useful for optimization algorithms where the stopping is inherently
#' controlled by the algorithm itself (e.g. [mlr3tuning::TunerGridSearch]).
#'
#' @family Terminator
#' @export
TerminatorNone = R6Class("TerminatorNone",
  inherit = Terminator,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(properties = c("single-crit", "multi-crit"))
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE` otherwise.
    #'
    #' @param archive ([Archive]).
    #' @return `logical(1)`.
    is_terminated = function(archive) {
      return(FALSE)
    }
  )
)
