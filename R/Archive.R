#' @title Data Storage
#'
#' @description
#' The [Archive] class stores all proposed points and their corresponding evaluations.
#'
#' @details
#' The [Archive] is an abstract class that implements the base functionality each archive must provide.
#'
#' * A `$best()` method that returns the best scoring evaluation(s).
#' * A `$nds_selection()` method that calculates the best points w.r.t. non-dominated sorting with hypervolume contribution.
#'
#' @section S3 Methods:
#' * `as.data.table(archive)`\cr
#'   [Archive] -> [data.table::data.table()]\cr
#'   Returns a tabular view of all performed function calls of the
#'   Objective. The `x_domain` column is unnested to separate columns.
#'
#' @template param_codomain
#' @template param_search_space
#' @template param_xdt
#' @template param_ydt
#' @template param_n_select
#' @template param_ref_point
#'
#' @template field_search_space
#' @template field_codomain
#' @template field_start_time
#'
#' @export
Archive = R6Class("Archive",
  public = list(

    search_space = NULL,

    codomain = NULL,

    start_time = NULL,

    #' @field check_values (`logical(1)`)\cr
    #' Determines if points and results are checked for validity.
    check_values = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param check_values (`logical(1)`)\cr
    #' Should x-values that are added to the archive be checked for validity?
    #' Search space that is logged into archive.
    initialize = function(search_space, codomain, check_values = FALSE) {
      self$search_space = assert_param_set(search_space)
      assert_param_set(codomain)
      # get "codomain" element if present (new paradox) or default to $params (old paradox)
      params = get0("domains", codomain, ifnotfound = codomain$params)
      self$codomain = Codomain$new(params)
      self$check_values = assert_flag(check_values)
    },

    #' @description
    #' Returns the best scoring evaluation(s).
    #' For single-crit optimization, the solution that minimizes / maximizes the objective function.
    #' For multi-crit optimization, the Pareto set / front.
    best = function() {
      stop("abstract")
    },

    #' @description
    #' Calculate best points w.r.t. non dominated sorting with hypervolume contribution.
    nds_selection = function() {
      stop("abstract")
    },

    #' @description
    #' Helper for print outputs.
    #' @param ... (ignored).
    format = function(...) {
      sprintf("<%s>", class(self)[1L])
    },

    #' @description
    #' Printer.
    #'
    #' @param ... (ignored).
    print = function() {
      catf(format(self))
      print(self$data[, setdiff(names(self$data), "x_domain"), with = FALSE], digits = 2)
    },

    #' @description
    #' Clear all evaluation results from archive.
    clear = function() {
      self$start_time = NULL
      invisible(self)
    }
  ),

  active = list(

    #' @field n_evals (`integer(1)`)\cr
    #' Number of evaluations stored in the archive.
    n_evals = function() stop("abstract"),

    #' @field cols_x (`character()`)\cr
    #' Column names of search space parameters.
    cols_x = function() self$search_space$ids(),

    #' @field cols_y (`character()`)\cr
    #' Column names of codomain target parameters.
    cols_y = function() self$codomain$target_ids
  )
)

#' @export
as.data.table.Archive = function(x, ...) { # nolint
  if (is.null(x$data$x_domain) || !nrow(x$data)) {
    copy(x$data)
  } else {
    unnest(copy(x$data), "x_domain", prefix = "{col}_")
  }
}
