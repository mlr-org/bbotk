#' @title Minimal logging object for objective function evaluations
#'
#' @description
#' The [ArchiveY] stores only the outcome and records the best scoring
#' evaluation passed to `$add_evals()`. The [Archive] API is fully implemented
#' but many parameters are ignored and some methods do nothing. The archive
#' still works with [TerminatorClockTime], [TerminatorEvals], [TerminatorNone],
#' [TerminatorStagnation] and [TerminatorEvals].
#'
#' @template param_codomain
#' @template param_search_space
#' @template param_xdt
#' @template param_ydt
#' @export
ArchiveY = R6Class("ArchiveY",
  inherit = Archive,
  public = list(

  #' @description
  #' Creates a new instance of this [R6][R6::R6Class] class.
  #'
  #' @param check_values (`logical(1)`)\cr
  #' ignored.
  initialize = function(search_space, codomain, check_values = FALSE) {
    self$search_space = assert_param_set(search_space)
    self$codomain = assert_param_set(codomain)
  },

  #' @description
  #' Stores the best result in `ydt`.
  #'
  #' @param xss_trafoed (`list()`)\cr
  #' Transformed point(s) in the *domain space*.
  add_evals = function(xdt, xss_trafoed, ydt) {
    tab = rbindlist(list(private$.best, cbind(xdt, ydt)), fill = TRUE, use.names = TRUE)

    max_to_min = mult_max_to_min(self$codomain)
    private$.best = if (self$codomain$length == 1L) {
      setorderv(tab, self$codomain$ids(), order = max_to_min, na.last = TRUE)
      tab[1, ]
    } else {
      ymat = t(as.matrix(tab[, self$cols_y, with = FALSE]))
      ymat = max_to_min * ymat
      tab[!is_dominated(ymat)]
    }

    private$.data = rbindlist(list(private$.data, ydt), fill = TRUE, use.names = TRUE)
  },

  #' @description
  #' Returns the best scoring evaluation. For single-crit optimization,
  #' the solution that minimizes / maximizes the objective function.
  #' For multi-crit optimization, the Pareto set / front.
  #'
  #' @param m (`integer()`)\cr
  #' ignored.
  #'
  #' @return [data.table::data.table()]
  best = function(m = NULL) {
    private$.best
  },

  #' @description
  #' Empty [data.table].
  #'
  #' @param unnest (`character()`)\cr
  #' ignored.
  #'
  #' @return [data.table].
  data = function(unnest = NULL) {
    private$.data
  }
  ),

  active = list(

  #' @field n_evals (`integer(1)`)\cr
  #' Number of evaluations stored in the archive.
  n_evals = function() nrow(private$.data),

  #' @field n_batch (`integer(1)`)\cr
  #' Number of batches stored in the archive.
  n_batch = function() 1,

  #' @field cols_x (`character()`)\cr
  #' Column names of search space parameters.
  cols_x = function() self$search_space$ids(),

  #' @field cols_y (`character()`)\cr
  #' Column names of codomain parameters.
  cols_y = function() self$codomain$ids()
  ),

  private = list(
  # Is always an empty data.table
  .data = data.table(),

  # Stores best result
  .best = NULL
  )
)
