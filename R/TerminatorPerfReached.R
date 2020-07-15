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
#' \describe{
#' \item{`level`}{`numeric(1)`\cr
#' Performance level that needs to be reached, default is 0. Terminates if the
#' performance exceeds (respective measure has to be maximized) or falls below
#' (respective measure has to be minimized) this value.}
#' }
#'
#' @family Terminator
#' @export
#' @examples
#' TerminatorPerfReached$new()
#' trm("perf_reached")
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
        ParamUty$new("level", tags = "required", custom_check = custom_check,
          default = c(y1 = 0.1))
      ))
      ps$values = list(level = c(y1 = 0.1))
      super$initialize(param_set = ps, "single-crit")
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE`
    #' otherwise.
    #'
    #' @param archive ([Archive]).
    #' @return `logical(1)`.
    is_terminated = function(archive) {
      pv = self$param_set$values
      ycol = archive$cols_y
      minimize = "minimize" %in% archive$codomain$tags
      if (archive$n_evals == 0) {
        return(FALSE)
      }

      ydata = archive$data()[, ycol, , drop = FALSE, with = FALSE]
      if (minimize) {
        res = ydata <= pv$level
      } else {
        res = ydata >= pv$level
      }
      any(res)
    }
  )
)

mlr_terminators$add("perf_reached", TerminatorPerfReached)
