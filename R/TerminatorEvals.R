#' @title Terminator that stops after a number of evaluations
#'
#' @name mlr_terminators_evals
#' @include Terminator.R
#'
#' @description
#' Class to terminate the optimization depending on the number of evaluations.
#' An evaluation is defined by one resampling of a parameter value.
#' The total number of evaluations \eqn{B} is defined as
#'
#' \deqn{
#'    B = \mathtt{n\_evals} + \mathtt{k} * D
#' }{
#'    B = n_evals + k * D
#' }
#' where \eqn{D} is the dimension of the search space.
#'
#' @templateVar id evals
#' @template section_dictionary_terminator
#'
#' @section Parameters:
#' \describe{
#' \item{`n_evals`}{`integer(1)`\cr
#'   See formula above. Default is 100.}
#' \item{`k`}{`integer(1)`\cr
#'   See formula above. Default is 0.}
#' }
#'
#' @family Terminator
#'
#' @template param_archive
#'
#' @export
#' @examples
#' TerminatorEvals$new()
#'
#' # 5 evaluations in total
#' trm("evals", n_evals = 5)
#'
#' # 3 * [dimension of search space] evaluations in total
#' trm("evals", n_evals = 0, k = 3)
#'
#' # (3 * [dimension of search space] + 1) evaluations in total
#' trm("evals", n_evals = 1, k = 3)
TerminatorEvals = R6Class("TerminatorEvals",
  inherit = Terminator,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        n_evals = p_int(lower = 0L, default = 100L, tags = "required"),
        k = p_int(lower = 0L, default = 0L, tags = "required")
      )
      param_set$values = list(n_evals = 100L, k = 0L)
      super$initialize(
        id = "evals",
        param_set = param_set,
        properties = c("single-crit", "multi-crit"),
        unit = "evaluations",
        label = "Number of Evaluation",
        man = "bbotk::mlr_terminators_evals")
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE`
    #' otherwise.
    #'
    #' @return `logical(1)`.
    is_terminated = function(archive) {
      # assert_r6(archive, "Archive")
      pv = self$param_set$values
      archive$n_evals >= pv$n_evals + pv$k * archive$search_space$length
    }
  ),

  private = list(
    .status = function(archive) {
      pv = self$param_set$values
      max_steps = pv$n_evals + pv$k * archive$search_space$length
      current_steps = archive$n_evals
      c("max_steps" = max_steps, "current_steps" = current_steps)
    }
  )
)

mlr_terminators$add("evals", TerminatorEvals)
