#' @title Terminator that stops when a performance level has been reached
#'
#' @name mlr_terminators_perf_reached
#' @include Terminator.R
#'
#' @description
#' Class to terminate the optimization after a performance level has been hit.
#'
#' @templateVar id perf_reached
#' @template section_dictionary_terminator
#'
#' @section Parameters:
#' * `level` (`numeric(1)`)\cr
#'   Performance level that needs to be reached, default is 0.
#'   Terminates if the performance exceeds (respective measure has to be maximized) or
#'   falls below (respective measure has to be minimized) this value.
#'   For multi-objective optimization this has to be a vector and all single values have to be exceeded.
#'
#' @family Terminator
#' @export
#' @examples
#' TerminatorPerfReached$new()
#' term("perf_reached")
TerminatorPerfReached = R6Class("TerminatorPerfReached",
  inherit = Terminator,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      custom_check = function(x) {
        check_numeric(x, finite = TRUE, any.missing = FALSE, names = "unique")
      }
      ps = ParamSet$new(list(
        ParamUty$new("level", default = 0, tags = "required", custom_check = custom_check)
      ))
      ps$values = list(level = 0)
      super$initialize(param_set = ps)
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE` otherwise.
    #'
    #' @param archive ([Archive]).
    #'
    #' @return `logical(1)`.
    is_terminated = function(archive) {
      pv = self$param_set$values
      ycols = archive$cols_y
      ydata = archive[, ycols]
      for (yname in ycols) {
        if (archive$objective$minimize[yname]) {
          ydata[, yname := yname <= pv$level[i]]
        } else {
          ydata[, yname := yname >= pv$level[i]]
        }
      }
      return(any(apply(ydata, 1, all)))
    }
  )
)

mlr_terminators$add("perf_reached", TerminatorPerfReached)
