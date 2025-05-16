
#' @title Frozen Rush Data Storage
#'
#' @description
#' Freezes the Redis data base of an [ArchiveAsync] to a  `data.table::data.table()`.
#' No further points can be added to the archive but the data can be accessed and analyzed.
#' Useful when the Redis data base is not permanently available.
#' Use the callback [bbotk.async_freeze_archive] to freeze the archive after the optimization has finished.
#'
#' @section S3 Methods:
#' * `as.data.table(archive)`\cr
#'   [ArchiveAsync] -> [data.table::data.table()]\cr
#'   Returns a tabular view of all performed function calls of the Objective.
#'   The `x_domain` column is unnested to separate columns.
#'
#' @export
ArchiveAsyncFrozen = R6Class("ArchiveAsyncFrozen",
  inherit = ArchiveAsync,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param archive ([ArchiveAsync])\cr
    #' The archive to freeze.
    initialize = function(archive) {
      private$.frozen_data = copy(archive$data)
      self$search_space = archive$search_space
      self$codomain = archive$codomain
      private$.label = "Frozen Data Storage"
      private$.man = "bbotk::ArchiveAsyncFrozen"
    },

    #' @description
    #' Push queued points to the archive.
    #'
    #' @param xss (list of named `list()`)\cr
    #' List of named lists of point values.
    push_points = function(xss) {
      stop("Archive is frozen")
    },

    #' @description
    #' Pop a point from the queue.
    pop_point = function() {
      stop("Archive is frozen")
    },

    #' @description
    #' Push running point to the archive.
    #'
    #' @param xs (named `list`)\cr
    #' Named list of point values.
    #' @param extra (`list()`)\cr
    #' Named list of additional information.
    push_running_point = function(xs, extra = NULL) {
      stop("Archive is frozen")
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
      stop("Archive is frozen")
    },

    #' @description
    #' Push failed point to the archive.
    #'
    #' @param key (`character()`)\cr
    #' Key of the point.
    #' @param message (`character()`)\cr
    #' Error message.
    push_failed_point = function(key, message) {
      stop("Archive is frozen")
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
      stop("Archive is frozen")
    },

    #' @description
    #' Clear all evaluation results from archive.
    clear = function() {
      stop("Archive is frozen")
    }
  ),

  private = list(
    .frozen_data = NULL
  ),

  active = list(

    #' @field data ([data.table::data.table])\cr
    #' Data table with all finished points.
    data = function(rhs) {
      assert_ro_binding(rhs)
      private$.frozen_data
    },

    #' @field queued_data ([data.table::data.table])\cr
    #' Data table with all queued points.
    queued_data = function() {
      self$data["queued", , on = "state"]
    },

    #' @field running_data ([data.table::data.table])\cr
    #' Data table with all running points.
    running_data = function() {
      self$data["running", , on = "state"]
    },

    #' @field finished_data ([data.table::data.table])\cr
    #' Data table with all finished points.
    finished_data = function() {
      self$data["finished", , on = "state"]
    },

    #' @field failed_data ([data.table::data.table])\cr
    #' Data table with all failed points.
    failed_data = function() {
      self$data["failed", , on = "state"]
    },

    #' @field n_queued (`integer(1)`)\cr
    #' Number of queued points.
    n_queued = function() {
      nrow(self$queued_data)
    },

    #' @field n_running (`integer(1)`)\cr
    #' Number of running points.
    n_running = function() {
      nrow(self$running_data)
    },

    #' @field n_finished (`integer(1)`)\cr
    #' Number of finished points.
    n_finished = function() {
      nrow(self$finished_data)
    },

    #' @field n_failed (`integer(1)`)\cr
    #' Number of failed points.
    n_failed = function() {
      nrow(self$failed_data)
    },

    #' @field n_evals (`integer(1)`)\cr
    #' Number of evaluations stored in the archive.
    n_evals = function() {
      nrow(self$finished_data) + nrow(self$failed_data)
    }
  )
)

#' @export
as.data.table.ArchiveAsync = function(x, keep.rownames = FALSE, unnest = "x_domain", ...) { # nolint
  data = x$data
  cols = intersect(unnest, names(data))
  unnest(data, cols, prefix = "{col}_")
}
