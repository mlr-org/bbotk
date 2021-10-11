#' @title Minimal logging object for objective function evaluations
#'
#' @description
#' The [ArchiveBest] stores no data but records the best scoring evaluation
#' passed to `$add_evals()`. The [Archive] API is fully implemented but many
#' parameters are ignored and some methods do nothing. The archive still works
#' with [TerminatorClockTime], [TerminatorEvals], [TerminatorNone] and
#' [TerminatorEvals].
#'
#' @template param_codomain
#' @template param_search_space
#' @template param_xdt
#' @template param_ydt
#' @template param_store_x_domain
#' @export
ArchiveBest = R6Class("ArchiveBest",
  inherit = Archive,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param check_values (`logical(1)`)\cr
    #' ignored.
    initialize = function(search_space, codomain, check_values = FALSE, store_x_domain = FALSE) {
      super$initialize(search_space, codomain, check_values = check_values,
        store_x_domain)
      private$.max_to_min = mult_max_to_min(self$codomain)
      if(self$codomain$length == 1) {
        private$.best_y = if(private$.max_to_min == -1) -Inf else Inf
      }
    },

    #' @description
    #' Stores the best result in `ydt`.
    #'
    #' @param xss_trafoed (`list()`)\cr
    #' Transformed point(s) in the *domain space*.
    #' @param status (`character()`)\cr
    #' Ignored.
    add_evals = function(xdt, xss_trafoed = NULL, ydt, status = "evaluated") {
      private$.n_evals = private$.n_evals+nrow(xdt)

      if(self$codomain$length == 1) {
        y = ydt[[1]]*private$.max_to_min
        id = which_min(y)
        if(y[id] < private$.best_y*private$.max_to_min) {
          private$.best_y = ydt[id,]
          private$.best_x = xdt[id,]
          private$.best_x_trafoed = if(self$store_x_domain) xss_trafoed[id]
        }
      } else {
        y = rbindlist(list(ydt, private$.best_y))
        x = rbindlist(list(xdt, private$.best_x))

        ymat = t(as.matrix(y))
        ymat = private$.max_to_min * ymat
        id = !is_dominated(ymat)

        private$.best_y = y[id,]
        private$.best_x = x[id,]
        private$.best_x_trafoed = if(self$store_x_domain) xss_trafoed[id]
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
    #' @return [data.table::data.table()]
    best = function(m = NULL) {
      if(self$n_evals == 0) {
        stop("No results stored in archive")
      } else {
        cbind(private$.best_x, private$.best_y)
      }
    }
  ),

  active = list(

    #' @field n_evals (`integer(1)`)\cr
    #' Number of evaluations stored in the archive.
    n_evals = function() private$.n_evals,

    #' @field n_batch (`integer(1)`)\cr
    #' Number of batches stored in the archive.
    n_batch = function() 1
  ),

  private = list(
    # Is increased by $add_evals()
    .n_evals = 0,

    # Stores best x
    .best_x = NULL,

    # Stores best x trafoed
    .best_x_trafoed = NULL,

    # Stores best y
    .best_y = NULL,

    # Stores max to min vector
    .max_to_min = NULL
  )
)
