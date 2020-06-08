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
#' * `stop_time` `POSIXct(1)`\cr
#'   Terminator stops after this point in time.
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
      super$initialize(param_set = ps, properties = "multi-objective")
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE`
    #' otherwise.
    #'
    #' @param archive ([Archive]).
    #'
    #' @return `logical(1)`.
    is_terminated = function(archive) {
      private$.run_progressor(archive)
      return(Sys.time() >= self$param_set$values$stop_time)
    }
  ),
  private = list(
    .run_progressor = function(archive) {
      if (isNamespaceLoaded("progressr") && !is.null(archive$start_time)) {
        ps = self$param_set$values
        if (is.null(self$progressor)) {
          n = ceiling(as.numeric(difftime(ps$stop_time, archive$start_time), units = "secs"))
          print(n)
          self$progressor = progressr::progressor(steps = n)
        } else {
          ts = unique(archive$data$timestamp)
          td = as.numeric(difftime(ts[length(ts)], ts[length(ts) - 1]), units = "secs")
          d = as.integer(difftime(ps$stop_time, Sys.time()), unit = "secs")
          self$progressor(message = sprintf("%i seconds left", d),
            amount = td)
        }
      }
    }
  )
)

mlr_terminators$add("clock_time", TerminatorClockTime)
