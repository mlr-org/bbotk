#' @title Terminator that stops according to the run time
#'
#' @name mlr_terminators_run_time
#' @include Terminator.R
#'
#' @description
#' Class to terminate the optimization after the optimization process took a
#' number of seconds on the clock.
#'
#' @templateVar id run_time
#' @template section_dictionary_terminator
#'
#' @section Parameters:
#' \describe{
#' \item{`secs`}{`numeric(1)`\cr
#' Maximum allowed time, in seconds, default is 100.}
#' }
#'
#' @family Terminator
#' @template param_archive
#' @export
#' @examples
#' trm("run_time", secs = 1800)
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
      super$initialize(param_set = ps, properties = c("single-crit", "multi-crit", "progressr"))
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE`
    #' otherwise.
    #' @return `logical(1)`.
    is_terminated = function(archive) {
      d = as.numeric(difftime(Sys.time(), archive$start_time), units = "secs")
      return(d >= self$param_set$values$secs)
    },

    #' @description
    #' Returns the allowed runtime in seconds.
    #' @return `integer(1)`
    progressr_steps = function(archive) {
      self$param_set$values$secs
    },

    #' @description
    #' Returns time difference between the last two batches (`amount`) and
    #' current runtime (`sum`) in seconds.
    #' @return list of `numeric(1)` and `integer(1)`
    progressr_update = function(archive) {
      ts = unique(archive$data()$timestamp)
      amount = as.numeric(difftime(ts[length(ts)], ts[length(ts) - 1]),
        units = "secs")
      sum = self$param_set$values$secs - as.integer(difftime(Sys.time(), archive$start_time),
        units = "secs")
      list(amount = amount, sum = sum)
    }
  )
)

mlr_terminators$add("run_time", TerminatorRunTime)
