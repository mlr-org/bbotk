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
#' @note
#' This terminator only works if `archive$start_time` is set. This is usually
#' done by the [Optimizer].
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
      super$initialize(param_set = ps, properties = c("single-crit", "multi-crit"))
      self$unit = "seconds"
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE`
    #' otherwise.
    #' @return `logical(1)`.
    is_terminated = function(archive) {
      if(is.null(archive$start_time)) {
        stop("`archive$start_time` must be set.")
      }

      d = as.numeric(difftime(Sys.time(), archive$start_time), units = "secs")
      return(d >= self$param_set$values$secs)
    }
  ),

  private = list(
    .status = function(archive) {
      max_steps = self$param_set$values$secs
      current_steps =  as.integer(difftime(Sys.time(), archive$start_time), units = "secs")
      c("max_steps" = max_steps, "current_steps" = current_steps)
    }
  )
)

mlr_terminators$add("run_time", TerminatorRunTime)
