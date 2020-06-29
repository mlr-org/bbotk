#' @title Terminator that stops according to the run time
#'
#' @include Terminator.R
#'
#' @description
#' Class to terminate the optimization after the optimization process took a
#' number of seconds on the clock.
#'
#' @section Parameters:
#' * `secs` `numeric(1)`\cr
#'   Maximum allowed time, in seconds, default is 100.
#'   Mutually exclusive with argument `stop_time`.
#'
#' @family Terminator
#' @export
#' @examples
#' terminator = TerminatorRunTime$new()
#' terminator$param_set$values$secs = 1000
TerminatorRunTime = R6Class("TerminatorRunTime",
  inherit = Terminator,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      ps = ParamSet$new(list(
        ParamDbl$new("secs", lower = 0, default = 30)
      ))
      ps$values$secs = 30
      super$initialize(param_set = ps, properties = c("single-crit", "multi-crit"))
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE`
    #' otherwise.
    #' @param archive ([Archive]).
    #' @return `logical(1)`.
    is_terminated = function(archive) {
      d = as.numeric(difftime(Sys.time(), archive$start_time), units = "secs")
      return(d >= self$param_set$values$secs)
    }
  )
)
