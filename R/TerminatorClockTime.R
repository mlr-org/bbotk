#' @title Terminator that stops according to the clock time
#'
#' @name mlr_terminators_clock_time
#' @include Terminator.R
#'
#' @description
#' Class to terminate the optimization after a fixed time point has been reached
#' (as reported by [Sys.time()]).
#'
#' @templateVar id clock_time
#' @template section_dictionary_terminator
#'
#' @section Parameters:
#' \describe{
#' \item{`stop_time`}{`POSIXct(1)`\cr
#' Terminator stops after this point in time.}
#' }
#'
#' @family Terminator
#' @export
#' @examples
#' stop_time = as.POSIXct("2030-01-01 00:00:00")
#' term("clock_time", stop_time = stop_time)
TerminatorClockTime = R6Class("TerminatorClockTime",
  inherit = Terminator,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      custom_check = function(x) {
        check_class(x, "POSIXct")
      }
      ps = ParamSet$new(list(
        ParamUty$new("stop_time", tags = "required",
          custom_check = custom_check)
      ))
      super$initialize(param_set = ps, properties = c("single-crit", "multi-crit"))
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE`
    #' otherwise.
    #'
    #' @param archive ([Archive]).
    #'
    #' @return `logical(1)`.
    is_terminated = function(archive) {
      return(Sys.time() >= self$param_set$values$stop_time)
    }
  )
)

mlr_terminators$add("clock_time", TerminatorClockTime)
