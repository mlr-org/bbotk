#' @title Minimal logging object for objective function evaluations
#'
#' @description
#' The [ArchiveMinimalY] stores only y. The [Archive] API is fully implemented but many
#' parameters are ignored and some methods do nothing. The archive still works
#' with `TerminatorClockTime`, `TerminatorEvals`, `TerminatorNone` and
#' `TerminatorEvals`.
#'
#' @template param_codomain
#' @template param_search_space
#' @template param_xdt
#' @template param_ydt
#' @export
ArchiveMinimalY = R6Class("ArchiveMinimalY",
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
    #' Stores ydt.
    #'
    #' @param xss_trafoed (`list()`)\cr
    #' ignored.
    add_evals = function(xdt, xss_trafoed, ydt) {

      if(self$codomain$length == 1L) {
        private$.data = c(private$.data, as.numeric(ydt))
      } else {
        private$.data = rbindlist(list(private$.data, ydt), fill = TRUE, use.names = TRUE)
      }
    },

    #' @description
    #' Returns the best scoring evaluation. For single-crit optimization,
    #' the solution that minimizes / maximizes the objective function.
    #' For multi-crit optimization, the Pareto set / front.
    #'
    #' @param m (`integer()`)\cr
    #' ignored.
    #'
    #' @return [data.table::data.table()].
    best = function(m = NULL) {
      tab = private$.data

      max_to_min = mult_max_to_min(self$codomain)
      if (self$codomain$length == 1L) {
        res = min(private$.data*max_to_min)*max_to_min
      } else {
        ymat = t(as.matrix(tab[, self$cols_y, with = FALSE]))
        ymat = max_to_min * ymat
        res = tab[!is_dominated(ymat)]
      }

      return(res)
    },

    #' @description
    #' Returns a [data.table::data.table] which contains all performed
    #' [Objective] function calls.
    #'
    #' @param unnest (`character()`)\cr
    #' ignored.
    #'
    #' @return [data.table::data.table()].
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
    n_batch = function() 1
  ),

  private = list(
    .data = NULL
  )
)
