#' @title Stagnation Hypervolume Terminator
#'
#' @name mlr_terminators_stagnation_hypervolume
#' @include Terminator.R
#'
#' @description
#' Class to terminate the optimization after the hypervolume stagnates, i.e. does not improve more than `threshold` over the last `iters` iterations.
#'
#' @templateVar id stagnation_hypervolume
#' @template section_dictionary_terminator
#'
#' @section Parameters:
#' \describe{
#' \item{`iters`}{`integer(1)`\cr
#'  Number of iterations to evaluate the performance improvement on, default is 10.}
#' \item{`threshold`}{`numeric(1)`\cr
#'  If the improvement is less than `threshold`, optimization is stopped, default is `0`.}
#' }
#'
#' @family Terminator
#'
#' @template param_archive
#'
#' @export
#' @examples
#' TerminatorStagnation$new()
#' trm("stagnation", iters = 5, threshold = 1e-5)
TerminatorStagnationHypervolume = R6Class("TerminatorStagnationHypervolume",
  inherit = Terminator,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        iters = p_int(lower = 1L, tags = "required"),
        threshold = p_dbl(lower = 0, tags = "required")
      )
      param_set$values = list(iters = 10, threshold = 0)

      super$initialize(
        id = "stagnation_hypervolume",
        param_set = param_set,
        properties = "multi-crit",
        label = "Stagnation Hypervolume",
        man = "bbotk::mlr_terminators_stagnation_hypervolume"
      )
    },

    #' @description
    #' Is `TRUE` if the termination criterion is positive, and `FALSE` otherwise.
    #'
    #' @return `logical(1)`.
    is_terminated = function(archive) {
      assert_class(archive, "Archive")
      pv = self$param_set$values
      iters = pv$iters
      ycols = archive$cols_y

      # we cannot terminate until we have enough observations
      if (archive$n_evals <= pv$iters) {
        return(FALSE)
      }

      points = t(as.matrix(archive$data[, ycols, , drop = FALSE, with = FALSE]))

      # switch sign in each dim to minimize
      minimize = map_lgl(archive$codomain$target_tags, has_element, "minimize")
      points = points * (minimize * 2 - 1)

      # points outside iters windows
      points_before = points[, seq(1, ncol(points) - iters), drop = FALSE]

      hypervolume = emoa::dominated_hypervolume(points)
      hypervolume_before = emoa::dominated_hypervolume(points_before)

      # hypervolume is always maximized
      return(hypervolume <= hypervolume_before + pv$threshold)
    }
  )
)

mlr_terminators$add("stagnation_hypervolume", TerminatorStagnationHypervolume)
