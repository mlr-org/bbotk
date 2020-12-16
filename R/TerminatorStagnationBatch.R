#' @title Terminator that stops when optimization does not improve
#'
#' @name mlr_terminators_stagnation_batch
#' @include Terminator.R
#'
#' @description
#' Class to terminate the optimization after the performance stagnates, i.e.
#' does not improve more than `threshold` over the last `n` batches.
#'
#' @templateVar id stagnation_batch
#' @template section_dictionary_terminator
#'
#' @section Parameters:
#' \describe{
#' \item{`n`}{`integer(1)`\cr
#'  Number of batches to evaluate the performance improvement on, default
#'  is 1.}
#' \item{`threshold`}{`numeric(1)`\cr
#'  If the improvement is less than `threshold`, optimization is stopped,
#'  default is `0`.}
#' }
#'
#' @family Terminator
#' @export
#' @examples
#' TerminatorStagnationBatch$new()
#' trm("stagnation_batch", n = 1, threshold = 1e-5)
TerminatorStagnationBatch = R6Class("TerminatorStagnationBatch",
  inherit = Terminator,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      ps = ParamSet$new(list(
        ParamInt$new("n", lower = 1L, default = 1, tags = "required"),
        ParamDbl$new("threshold", lower = 0, default = 0, tags = "required")
      ))
      ps$values = list(n = 1, threshold = 0)
      super$initialize(param_set = ps, properties = "single-crit")
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE`
    #' otherwise.
    #'
    #' @param archive ([Archive]).
    #'
    #' @return `logical(1)`.
    is_terminated = function(archive) {

      pv = self$param_set$values
      ycol = archive$cols_y
      present_batch = archive$n_batch
      previous_batch = (archive$n_batch - 1):(archive$n_batch - pv$n)
      minimize = "minimize" %in% archive$codomain$tags

      # we cannot terminate until we have enough observations
      if (archive$n_batch <= pv$n) {
        return(FALSE)
      }
      batch_nr = NULL # CRAN check
      perf_before = archive$data[batch_nr %in% previous_batch,
        c(ycol, "batch_nr"), with = FALSE]
      perf_present = archive$data[batch_nr == present_batch,
        c(ycol, "batch_nr"), with = FALSE]

      if (minimize) {
        res = map(perf_before$batch_nr, function(nr) {
          min(perf_present[, ycol, with = FALSE]) >= min(
            perf_before[batch_nr == nr, ycol, with = FALSE]) - pv$threshold
        })
      } else {
        res = map(perf_before$batch_nr, function(nr) {
          max(perf_present[, ycol, with = FALSE]) <= max(
            perf_before[batch_nr == nr, ycol, with = FALSE]) + pv$threshold
        })
      }

      all(unlist(res))
    }
  )
)

mlr_terminators$add("stagnation_batch", TerminatorStagnationBatch)
