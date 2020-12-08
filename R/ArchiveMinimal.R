#' @title Minimal logging object for objective function evaluations
#'
#' @description
#' The [ArchiveMinimal] stores no data but records the best scoring evaluation
#' passed by `add_evals`. The [Archive] API is fully implemented but many
#' parameters are ignored and some methods do nothing. The archive still works
#' with `TerminatorClockTime`, `TerminatorEvals`, `TerminatorNone` and
#' `TerminatorEvals`.
#'
#' @template param_codomain
#' @template param_search_space
#' @template param_xdt
#' @template param_ydt
#' @export
ArchiveMinimal = R6Class("ArchiveMinimal",
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
    #' Increases `n_evals` counter and stores best result.
    #'
    #' @param xss_trafoed (`list()`)\cr
    #' Transformed point(s) in the *domain space*.
    add_evals = function(xdt, xss_trafoed, ydt) {

      # Increase number of evaluations
      private$.n_evals = private$.n_evals+nrow(xdt)

      # Calculate best
      tab = cbind(xdt, ydt)
      max_to_min = mult_max_to_min(self$codomain)
      setorderv(tab, self$codomain$ids(), order = max_to_min, na.last = TRUE)
      private$.best = if(is.null(private$.best)) {
        tab[1, ]
      } else {
        y_old = as.numeric(private$.best[1, self$cols_y, with=FALSE])
        y_new = as.numeric(tab[1, self$cols_y, with=FALSE])
        if (y_new < y_old) tab[1, ] else private$.best
      }
    },

    #' @description
    #' Returns the best scoring evaluation. For single-crit optimization,
    #' the solution that minimizes / maximizes the objective function.
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
      data.table()
    }
  ),

  active = list(

    #' @field n_evals (`integer(1)`)\cr
    #' Number of evaluations stored in the archive.
    n_evals = function() private$.n_evals,

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
    .data = NULL,

    .n_evals = 0,

    .best = NULL
  )
)
