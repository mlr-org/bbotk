#' @title Clock Time Terminator
#'
#' @name mlr_terminators_clock_time
#' @include Terminator.R
#'
#' @description
#' Class to terminate the optimization after a fixed time point has been reached (as reported by [Sys.time()]).
#'
#' @templateVar id clock_time
#' @template section_dictionary_terminator
#'
#' @section Parameters:
#' \describe{
#' \item{`stop_time`}{`POSIXct(1)`\cr
#'   Terminator stops after this point in time.}
#' }
#'
#' @family Terminator
#'
#' @template param_archive
#'
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
      param_set = ps(
        stop_time = p_uty(tags = "required", custom_check = function(x) check_class(x, "POSIXct"))
      )
      super$initialize(
        id = "clock_time",
        param_set = param_set,
        properties = c("single-crit", "multi-crit"),
        unit = "seconds",
        label = "Clock Time",
        man = "bbotk::mlr_terminators_clock_time"
      )
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE`
    #' otherwise.
    #'
    #' @return `logical(1)`.
    is_terminated = function(archive) {
      assert_multi_class(archive, c("Archive", "ArchiveAsync"))
      return(Sys.time() >= self$param_set$values$stop_time)
    }
  ),

  private = list(
    .status = function(archive) {
      max_steps = as.integer(ceiling(difftime(self$param_set$values$stop_time, archive$start_time, units = "secs")))
      current_steps = as.integer(difftime(Sys.time(), archive$start_time, units = "secs"))
      c("max_steps" = max_steps, "current_steps" = current_steps)
    }
  )
)

mlr_terminators$add("clock_time", TerminatorClockTime)
