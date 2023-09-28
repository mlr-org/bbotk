#' @title Logging object for objective function evaluations
#'
#' @description
#' Container around a [data.table::data.table] which stores all performed
#' function calls of the Objective.
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
#' @export
ArchiveRush = R6Class("ArchiveRush",
  public = list(

    #' @field search_space ([paradox::ParamSet])\cr
    #' Search space of objective.
    search_space = NULL,

    #' @field codomain ([Codomain])\cr
    #' Codomain of objective function.
    codomain = NULL,

    #' @field start_time ([POSIXct])\cr
    #' Time stamp of when the optimization started.
    #' The time is set by the [Optimizer].
    start_time = NULL,

    #' @field check_values (`logical(1)`)\cr
    #' Determines if points and results are checked for validity.
    check_values = NULL,

    #' @field rush ([Rush])\cr
    #' Rush.
    rush = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param check_values (`logical(1)`)\cr
    #' Should x-values that are added to the archive be checked for validity?
    #' Search space that is logged into archive.
    #' @param rush ([Rush])\cr
    #' Rush.
    initialize = function(search_space, codomain, check_values = TRUE, rush) {
      self$search_space = assert_param_set(search_space)
      self$codomain = Codomain$new(assert_param_set(codomain)$params)
      self$check_values = assert_flag(check_values)
      self$rush = assert_class(rush, "Rush")
    },

    #' @description
    #' Returns the best scoring evaluation(s).
    #' For single-crit optimization, the solution that minimizes / maximizes the objective function.
    #' For multi-crit optimization, the Pareto set / front.
    #'
    #' @param n_select (`integer(1L)`)\cr
    #' Amount of points to select.
    #' Ignored for multi-crit optimization.
    #'
    #' @return [data.table::data.table()]
    best = function(n_select = 1) {
      data = self$data

      if (self$codomain$target_length == 1L) {
        assert_int(n_select, lower = 1L, upper = nrow(data))
        setkeyv(data, self$codomain$target_ids)
        top_n = if (has_element(self$codomain$target_tags[[1]], "minimize")) head else tail
        res = top_n(data, n_select)
      } else {
        ymat = t(as.matrix(data[, self$codomain$target_ids, with = FALSE]))
        ymat = self$codomain$maximization_to_minimization * ymat
        res = data[!is_dominated(ymat)]
      }

      return(res)
    },

    #' @description
    #' Calculate best points w.r.t. non dominated sorting with hypervolume contribution.
    #'
    #' @return [data.table::data.table()]
    nds_selection = function(n_select = 1, ref_point = NULL) {
      tab = self$data
      assert_int(n_select, lower = 1L, upper = nrow(tab))

      points = t(as.matrix(tab[, self$cols_y, with = FALSE]))
      minimize = map_lgl(self$codomain$target_tags, has_element, "minimize")
      inds = nds_selection(points, n_select, ref_point, minimize)
      tab[inds, ]
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
      self$rush$reset()
      self$start_time = NULL
    },

    #' @description
    #' Copy the data from rush to a local `data.table`.
    #' This is useful on shared computer clusters where the rush instance is not available after the job has finished.
    freeze = function() {
      private$.data = copy(self$rush$fetch_finished_tasks())
      self$rush = NULL
    }
  ),

  active = list(

    #' @field data ([data.table::data.table])\cr
    #' Data table with all evaluations.
    data = function() {
     if (is.null(self$rush)) {
        private$.data
      } else {
        self$rush$fetch_finished_tasks()
      }
    },

    #' @field n_evals (`integer(1)`)\cr
    #' Number of evaluations stored in the archive.
    n_evals = function() {
      if (is.null(self$rush)) {
        nrow(private$.data)
      } else {
        self$rush$n_finished_tasks
      }
    },

    #' @field cols_x (`character()`)\cr
    #' Column names of search space parameters.
    cols_x = function() self$search_space$ids(),

    #' @field cols_y (`character()`)\cr
    #' Column names of codomain target parameters.
    cols_y = function() self$codomain$target_ids
  ),

  private = list(
    # data is only stored here when the archive is frozen
    .data = data.table(),

    deep_clone = function(name, value) {
      switch(name,
        search_space = value$clone(deep = TRUE),
        codomain = value$clone(deep = TRUE),
        value
      )
    }
  )
)

#' @export
as.data.table.ArchiveRush = function(x, ...) { # nolint
  copy(x$data)
}
