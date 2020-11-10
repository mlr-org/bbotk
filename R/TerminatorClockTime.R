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
#' @template param_archive
#' @export
#' @examples
#' stop_time = as.POSIXct("2030-01-01 00:00:00")
#' trm("clock_time", stop_time = stop_time)
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
      super$initialize(param_set = ps, properties = c("single-crit", "multi-crit", "progressr"))
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE`
    #' otherwise.
    #' @return `logical(1)`.
    is_terminated = function(archive) {
      return(Sys.time() >= self$param_set$values$stop_time)
    },

    #' @description
    #' Returns time difference between start time and stop time in seconds.
    #' @return `integer(1)`
    progressr_steps = function(archive) {
      as.integer(ceiling(difftime(self$param_set$values$stop_time,
        archive$start_time, units = "secs")))
    },

    #' @description
    #' Returns time difference between the last two batches (`amount`) and
    #' current runtime (`sum`) in seconds.
    #' @return list of `numeric(1)` and `integer(1)`
    progressr_update = function(archive) {
      ts = unique(archive$data()$timestamp)
      ts = c(archive$start_time, ts)
      amount = as.numeric(difftime(ts[length(ts)], ts[length(ts) - 1]),
        units = "secs")
      sum = as.integer(ceiling(
        difftime(self$param_set$values$stop_time, Sys.time(), units = "secs")))
      list(amount = amount, sum = sum)
    }
  )
)

mlr_terminators$add("clock_time", TerminatorClockTime)