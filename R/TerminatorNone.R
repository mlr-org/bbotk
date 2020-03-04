#' @title Terminator that never stops.
#'
#' @name mlr_terminators_none
#' @include Terminator.R
#'
#' @description
#' Mainly useful for optimization algorithms where the stopping is inherently
#' controlled by the algorithm itself (e.g. [mlr3tuning::TunerGridSearch]).
#'
#' @templateVar id none
#' @template section_dictionary_terminator
#'
#' @family Terminator
#' @export
TerminatorNone = R6Class("TerminatorNone",
  inherit = Terminator,
  public = list(
   
   #' @description
   #' Creates a new instance of this [R6][R6::R6Class] class.
   initialize = function() {
     super$initialize()
   },
   
   #' @description
   #' Is `TRUE` iff the termination criterion is positive, and `FALSE` otherwise.
   #'
   #' @param instance ([Instance]).
   #'
   #' @return `logical(1)`.
   is_terminated = function(instance) return(FALSE)
  )
)

mlr_terminators$add("none", TerminatorNone)