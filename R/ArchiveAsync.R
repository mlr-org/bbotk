#' @title Rush Data Archive
#'
#' @description
#' Connector to a rush network which stores all performed function calls of the [Objective].
#'
#' @section S3 Methods:
#' * `as.data.table(archive)`\cr
#'   [ArchiveAsync] -> [data.table::data.table()]\cr
#'   Returns a tabular view of all performed function calls of the Objective.
#'   The `x_domain` column is unnested to separate columns.
#'
#' @template param_search_space
#' @template param_codomain
#' @template param_rush
#'
#' @template field_search_space
#' @template field_codomain
#' @template field_start_time
#' @template field_rush
#'
#' @export
ArchiveAsync = R6Class("ArchiveAsync",
  public = list(

    search_space = NULL,

    codomain = NULL,

    start_time = NULL,

    rush = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(search_space, codomain, rush) {
      self$search_space = assert_param_set(search_space)
      self$codomain = Codomain$new(assert_param_set(codomain)$params)
      self$rush = assert_rush(rush)
    },

    #' @description
    #' Push points to the queue.
    #'
    #' @param xss (`list`)\cr
    #' List of points.
    push_points = function(xss) {
      self$rush$push_tasks(xss, extra = list(list(timestamp_xs = Sys.time())))
    },

    #' @description
    #' Pop a point from the queue.
    pop_point = function() {
      self$rush$pop_task(fields = "xs")
    },

    #' @description
    #' Push points to running points without queue.
    #'
    #' @param xss (`list`)\cr
    #' List of points.
    push_running_points = function(xss) {
      self$rush$push_running_tasks(xss, extra = list(list(timestamp_xs = Sys.time())))
    },

    #' @description
    #' Push results to the archive.
    #'
    #' @param keys (`character()`)\cr
    #' Keys of the points.
    #' @param yss (`list()`)\cr
    #' List of results.
    #' @param extra (`list()`)\cr
    #' List of additional information.
    push_results = function(keys, yss, extra = NULL) {
      extra = map(extra, function(x) c(x, list(timestamp_ys = Sys.time())))

      self$rush$push_results(keys, yss, extra = extra)
    },

    #' @description
    #' Push failed points to the archive.
    #'
    #' @param keys (`character()`)\cr
    #' Keys of the points.
    #' @param conditions (`list()`)\cr
    #' List of conditions.
    push_failed_points = function(keys, conditions) {
      self$rush$push_failed(keys, conditions)
    },

    #' @description
    #' Fetch data with a specific state.
    #'
    #' @param fields (`character()`)\cr
    #' Fields to fetch.
    #' Defaults to `c("xs", "ys", "xs_extra", "worker_extra", "ys_extra")`.
    #' @param states (`character()`)\cr
    #' States of the tasks to be fetched.
    #' Defaults to `c("queued", "running", "finished", "failed")`.
    #' @param reset_cache (`logical(1)`)\cr
    #' Whether to reset the cache of the finished points.
    fetch_data_with_state = function(
      fields = c("xs", "ys", "xs_extra", "worker_extra", "ys_extra", "condition"),
      states = c("queued", "running", "finished", "failed"),
      reset_cache = FALSE
      ) {
      self$rush$fetch_tasks_with_state(fields, states, reset_cache)
    },

    #' @description
    #' Returns the best scoring evaluation(s).
    #' For single-crit optimization, the solution that minimizes / maximizes the objective function.
    #' For multi-crit optimization, the Pareto set / front.
    #'
    #' @param n_select (`integer(1L)`)\cr
    #' Amount of points to select.
    #' Ignored for multi-crit optimization.
    #' @param ties_method (`character(1L)`)\cr
    #' Method to break ties when multiple points have the same score.
    #' Either `"first"` (default) or `"random"`.
    #' Ignored for multi-crit optimization.
    #' If `n_select > 1L`, the tie method is ignored and the first point is returned.
    #'
    #' @return [data.table::data.table()]
    best = function(n_select = 1, ties_method = "first") {
      assert_count(n_select)
      tab = self$data

      if (self$codomain$target_length == 1L) {
        if (n_select == 1L) {
          # use which_max to find the best point
          y = tab[[self$cols_y]] * -self$codomain$maximization_to_minimization
          ii = which_max(y, ties_method = ties_method)
          tab[ii]
        } else {
          # copy table to avoid changing the order of the archive
          if (is.null(batch)) tab = copy(self$data)
          # use data.table fast sort to find the best points
          setorderv(tab, cols = self$cols_y, order = self$codomain$maximization_to_minimization)
          head(tab, n_select)
        }
      } else {
        # use non-dominated sorting to find the best points
        ymat = t(as.matrix(tab[, self$cols_y, with = FALSE]))
        ymat = self$codomain$maximization_to_minimization * ymat
        tab[!is_dominated(ymat)]
      }
    },

    #' @description
    #' Calculate best points w.r.t. non dominated sorting with hypervolume contribution.
    #'
    #' @template param_n_select
    #' @template param_ref_point
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
      private$.data = data.table()
    },

    #' @description
    #' Copy the data from rush to a local [data.table::data.table()].
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

    #' @field queued_data ([data.table::data.table])\cr
    #' Data table with all queued points.
    queued_data = function() {
      self$rush$fetch_queued_tasks()
    },

    #' @field running_data ([data.table::data.table])\cr
    #' Data table with all running points.
    running_data = function() {
      self$rush$fetch_running_tasks()
    },

    #' @field finished_data ([data.table::data.table])\cr
    #' Data table with all finished points.
    finished_data = function() {
      self$rush$fetch_finished_tasks()
    },

    #' @field failed_data ([data.table::data.table])\cr
    #' Data table with all failed points.
    failed_data = function() {
      self$rush$fetch_failed_tasks()
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
    .data = NULL,

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
as.data.table.ArchiveAsync = function(x, ...) { # nolint
  copy(x$data)
}
