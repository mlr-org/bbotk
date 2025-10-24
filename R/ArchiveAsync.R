#' @title Rush Data Storage
#'
#' @description
#' The `ArchiveAsync` stores all evaluated points and performance scores in a [rush::Rush] data base.
#'
#' @section S3 Methods:
#' * `as.data.table(archive)`\cr
#'   [ArchiveAsync] -> [data.table::data.table()]\cr
#'   Returns a tabular view of all performed function calls of the Objective.
#'   The `x_domain` column is unnested to separate columns.
#'
#' @template param_search_space
#' @template param_codomain
#' @template param_check_values
#' @template param_rush
#'
#' @template field_rush
#'
#' @export
#' @examplesIf requireNamespace("rush", quietly = TRUE)
#' @examples
#' # example only runs if a Redis server is available
#' \donttest{
#  # define the objective function
#' fun = function(xs) {
#'   list(y = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
#' }
#'
#' # set domain
#' domain = ps(
#'   x1 = p_dbl(-10, 10),
#'   x2 = p_dbl(-5, 5)
#' )
#'
#' # set codomain
#' codomain = ps(
#'   y = p_dbl(tags = "maximize")
#' )
#'
#' # create objective
#' objective = ObjectiveRFun$new(
#'   fun = fun,
#'   domain = domain,
#'   codomain = codomain,
#'   properties = "deterministic"
#' )
#'
#' # initialize instance
#' instance = oi_async(
#'   objective = objective,
#'   terminator = trm("evals", n_evals = 20)
#' )
#'
#' # load optimizer
#' optimizer = opt("async_random_search")
#'
#' # trigger optimization
#' optimizer$optimize(instance)
#'
#' # all evaluated configuration
#' instance$archive
#'
#' # best performing configuration
#' instance$archive$best()
#'
#' # covert to data.table
#' as.data.table(instance$archive)
#'
#' # reset the rush data base
#' instance$rush$reset()
#' }
ArchiveAsync = R6Class("ArchiveAsync",
  inherit = Archive,
  public = list(

    rush = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(search_space, codomain, check_values = FALSE, rush) {
      require_namespaces("rush")
      self$rush = rush::assert_rush(rush)

      super$initialize(
        search_space = search_space,
        codomain = codomain,
        check_values = check_values,
        label = "Rush Data Storage",
        man = "bbotk::ArchiveAsync")
    },

    #' @description
    #' Push queued points to the archive.
    #'
    #' @param xss (list of named `list()`)\cr
    #' List of named lists of point values.
    push_points = function(xss) {
      if (self$check_values) map(xss, self$search_space$assert)
      self$rush$push_tasks(xss, extra = list(list(timestamp_xs = Sys.time())))
    },

    #' @description
    #' Pop a point from the queue.
    pop_point = function() {
      self$rush$pop_task(fields = "xs")
    },

    #' @description
    #' Push running point to the archive.
    #'
    #' @param xs (named `list`)\cr
    #' Named list of point values.
    #' @param extra (`list()`)\cr
    #' Named list of additional information.
    push_running_point = function(xs, extra = NULL) {
      if (self$check_values) self$search_space$assert(xs)
      extra = c(list(timestamp_xs = Sys.time()), extra)
      self$rush$push_running_tasks(list(xs), extra = list(extra))
    },

    #' @description
    #' Push result to the archive.
    #'
    #' @param key (`character()`)\cr
    #' Key of the point.
    #' @param ys (`list()`)\cr
    #' Named list of results.
    #' @param x_domain (`list()`)\cr
    #' Named list of transformed point values.
    #' @param extra (`list()`)\cr
    #' Named list of additional information.
    push_result = function(key, ys, x_domain, extra = NULL) {
      extra = c(list(x_domain = list(x_domain), timestamp_ys = Sys.time()), extra)
      self$rush$push_results(key, list(ys), extra = list(extra))
    },

    #' @description
    #' Push failed point to the archive.
    #'
    #' @param key (`character()`)\cr
    #' Key of the point.
    #' @param message (`character()`)\cr
    #' Error message.
    push_failed_point = function(key, message) {
      self$rush$push_failed(key, list(list(message = message)))
    },

    #' @description
    #' Fetch points with a specific state.
    #'
    #' @param fields (`character()`)\cr
    #' Fields to fetch.
    #' Defaults to `c("xs", "ys", "xs_extra", "worker_extra", "ys_extra")`.
    #' @param states (`character()`)\cr
    #' States of the tasks to be fetched.
    #' Defaults to `c("queued", "running", "finished", "failed")`.
    #' @param reset_cache (`logical(1)`)\cr
    #' Whether to reset the cache of the finished points.
    data_with_state = function(
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
      tab = self$finished_data

      if (self$codomain$target_length == 1L) {
        if (n_select == 1L) {
          # use which_max to find the best point
          y = tab[[self$cols_y]] * -self$codomain$direction
          ii = which_max(y, ties_method = ties_method)
          tab[ii]
        } else {
          # use data.table fast sort to find the best points
          setorderv(tab, cols = self$cols_y, order = self$codomain$direction)
          head(tab, n_select)
        }
      } else {
        # use non-dominated sorting to find the best points
        ymat = t(as.matrix(tab[, self$cols_y, with = FALSE]))
        ymat = self$codomain$direction * ymat
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
      tab = self$finished_data
      assert_int(n_select, lower = 1L, upper = nrow(tab))

      points = t(as.matrix(tab[, self$cols_y, with = FALSE]))
      minimize = map_lgl(self$codomain$target_tags, has_element, "minimize")
      inds = nds_selection(points, n_select, ref_point, minimize)
      tab[inds, ]
    },

    #' @description
    #' Clear all evaluation results from archive.
    clear = function() {
      self$rush$reset()
      super$clear()
    }
  ),

  active = list(

    #' @field data ([data.table::data.table])\cr
    #' Data table with all finished points.
    data = function(rhs) {
      assert_ro_binding(rhs)
      self$data_with_state()
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

    #' @field n_queued (`integer(1)`)\cr
    #' Number of queued points.
    n_queued = function() {
      self$rush$n_queued_tasks
    },

    #' @field n_running (`integer(1)`)\cr
    #' Number of running points.
    n_running = function() {
      self$rush$n_running_tasks
    },

    #' @field n_finished (`integer(1)`)\cr
    #' Number of finished points.
    n_finished = function() {
      self$rush$n_finished_tasks
    },

    #' @field n_failed (`integer(1)`)\cr
    #' Number of failed points.
    n_failed = function() {
      self$rush$n_failed_tasks
    },

    #' @field n_evals (`integer(1)`)\cr
    #' Number of evaluations stored in the archive.
    n_evals = function() {
      self$rush$n_finished_tasks + self$rush$n_failed_tasks
    }
  )
)

#' @export
as.data.table.ArchiveAsync = function(x, keep.rownames = FALSE, unnest = "x_domain", ...) { # nolint
  data = x$data_with_state()
  cols = intersect(unnest, names(data))
  unnest(data, cols, prefix = "{col}_")
}
