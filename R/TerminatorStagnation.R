#' @title Terminator that stops when optimization does not improve
#'
#' @name mlr_terminators_stagnation
#' @include Terminator.R
#'
#' @description
#' Class to terminate the optimization after the performance stagnates, i.e.
#' does not improve more than `threshold` over the last `iters` iterations.
#'
#' @templateVar id stagnation
#' @template section_dictionary_terminator
#'
#' @section Parameters:
#' * `iters` `integer(1)`\cr
#'   Number of iterations to evaluate the performance improvement on, default
#'   is 10.
#'
#' * `threshold` `numeric(1)`\cr
#'   If the improvement is less than `threshold`, optimization is stopped,
#'  default is `0`.
#'
#' @family Terminator
#' @export
#' @examples
#' TerminatorStagnation$new()
#' term("stagnation", iters = 5, threshold = 1e-5)
TerminatorStagnation = R6Class("TerminatorStagnation",
  inherit = Terminator,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      ps = ParamSet$new(list(
        ParamInt$new("iters", lower = 1L, default = 10, tags = "required"),
        ParamDbl$new("threshold", lower = 0, default = 0, tags = "required")
      ))
      ps$values = list(iters = 10, threshold = 0)
      super$initialize(param_set = ps, properties = "single-objective")
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE`
    #' otherwise.
    #'
    #' @param archive ([Archive]).
    #'
    #' @return `logical(1)`.
    is_terminated = function(archive) {

      browser()

      pv = self$param_set$values
      iters = pv$iters
      ycols = archive$cols_y
      if (archive$n_evals <= pv$iters) { # we cannot terminate until we have enough observations
        return(FALSE)
      }
      ydata = archive$data()[, ycols, , drop = FALSE, with = FALSE]
      perf_before = head(ydata, -iters)
      perf_window = tail(ydata, iters)

      if (archive$codomain$tags == "minimize") {
        return(min(perf_window) >= min(perf_before) - pv$threshold)
      } else {
        return(max(perf_window) <= max(perf_before) + pv$threshold)
      }
    }
  )
)

mlr_terminators$add("stagnation", TerminatorStagnation)
