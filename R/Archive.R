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
Archive = R6Class("Archive",
  public = list(

    #' @field search_space ([paradox::ParamSet])\cr
    #' Search space of objective.
    search_space = NULL,

    #' @field codomain ([Codomain])\cr
    #' Codomain of objective function.
    codomain = NULL,

    #' @field start_time ([POSIXct])\cr
    #' Time stamp of when the optimization started. The time is set by the
    #' [Optimizer].
    start_time = NULL,

    #' @field check_values (`logical(1)`)\cr
    #' Determines if points and results are checked for validity.
    check_values = NULL,

    #' @field data ([data.table::data.table])\cr
    #' Contains all performed [Objective] function calls.
    data = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param check_values (`logical(1)`)\cr
    #' Should x-values that are added to the archive be checked for validity?
    #' Search space that is logged into archive.
    initialize = function(search_space, codomain, check_values = TRUE) {
      self$search_space = assert_param_set(search_space)
      self$codomain = Codomain$new(assert_param_set(codomain)$params)
      self$check_values = assert_flag(check_values)
      self$data = data.table()
    },

    #' @description
    #' Adds function evaluations to the archive table.
    #'
    #' @param xss_trafoed (`list()`)\cr
    #'   Transformed point(s) in the *domain space*.
    #' @param status (`character()`)\cr
    #'   Status (`"proposed"` | `"evaluated"`) of points in `xdt`.
    add_evals = function(xdt, xss_trafoed = NULL, ydt = data.table(), status = "evaluated") {
      assert_data_table(xdt)
      assert_data_table(ydt)
      assert_list(xss_trafoed, null.ok = TRUE)
      status = ordered(assert_choice(status, c("proposed", "evaluated")), c("proposed", "in_progress", "resolved", "evaluated"))
      assert_names(names(xdt), must.include = self$search_space$ids())
      if (status == "evaluated") assert_names(names(ydt), must.include = self$codomain$ids())
      if (self$check_values) self$search_space$assert_dt(xdt[, self$cols_x, with = FALSE])

      if (status == "proposed") lg$info("Proposing %i configuration(s).", nrow(xdt))

      xydt = cbind(xdt, ydt)
      if (!is.null(xss_trafoed)) set(xydt, j = "x_domain", value = list(xss_trafoed))
      set(xydt, j = "timestamp", value = Sys.time())
      batch_nr = self$data$batch_nr
      set(xydt, j = "batch_nr", value = if (length(batch_nr)) max(batch_nr) + 1L else 1L)
      set(xydt, j = "status", value = status)

      self$data = rbindlist(list(self$data, xydt), fill = TRUE, use.names = TRUE)
    },

    #' @description
    #' Returns the best scoring evaluation(s). For single-crit optimization,
    #' the solution that minimizes / maximizes the objective function.
    #' For multi-crit optimization, the Pareto set / front.
    #'
    #' @param batch (`integer()`)\cr
    #'  The batch number(s) to limit the best results to. Default is
    #'  all batches.
    #' @param n_select (`integer(1L)`)\cr
    #'   Amount of points to select. Ignored for multi-crit optimization.
    #'
    #' @return [data.table::data.table()]
    best = function(batch = NULL, n_select = 1) {
      if (self$n_batch == 0L) return(data.table())
      if (is.null(batch)) batch = seq_len(self$n_batch)
      assert_subset(batch, seq_len(self$n_batch))

      tab = self$data[list(batch, "evaluated"), on = c("batch_nr", "status")]
      assert_int(n_select, lower = 1L, upper = nrow(tab))

      max_to_min = self$codomain$maximization_to_minimization
      if (self$codomain$target_length == 1L) {
        setorderv(tab, self$cols_y, order = max_to_min, na.last = TRUE)
        res = tab[seq_len(n_select), ]
      } else {
        ymat = t(as.matrix(tab[, self$cols_y, with = FALSE]))
        ymat = max_to_min * ymat
        res = tab[!is_dominated(ymat)]
      }

      return(res)
    },

    #' @description
    #' Calculate best points w.r.t. non dominated sorting with hypervolume
    #' contribution.
    #'
    #' @param batch (`integer()`)\cr
    #'   The batch number(s) to limit the best points to. Default is
    #'   all batches.
    #'
    #' @return [data.table::data.table()]
    nds_selection = function(batch = NULL, n_select = 1, ref_point = NULL) {
      if (self$n_batch == 0L) stop("No results stored in archive")
      if (is.null(batch)) batch = seq_len(self$n_batch)
      assert_integerish(batch, lower = 1L, upper = self$n_batch, coerce = TRUE)

      tab = self$data[list(batch, "evaluated"), on = c("batch_nr", "status")]
      assert_int(n_select, lower = 1L, upper = nrow(tab))

      points = t(as.matrix(tab[, self$cols_y, with = FALSE]))
      minimize = map_lgl(self$codomain$target_tags, has_element, "minimize")
      inds = nds_selection(points, n_select, ref_point, minimize)
      tab[inds, ]
    },

    #' @description
    #' Helper for print outputs.
    format = function() {
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
      self$data = data.table()
    }
  ),

  active = list(

    #' @field n_evals (`integer(1)`)\cr
    #' Number of finished evaluations stored in the archive.
    n_evals = function() {
      if (!nrow(self$data)) return(0L)
      nrow(self$data["evaluated", on = "status", nomatch = NULL])
    },

    #' @field n_batch (`integer(1)`)\cr
    #' Number of batches stored in the archive.
    n_batch = function() {
      if (is.null(self$data$batch_nr)) {
        0L
      } else {
        max(self$data$batch_nr)
      }
    },

    #' @field cols_x (`character()`)\cr
    #' Column names of search space parameters.
    cols_x = function() self$search_space$ids(),

    #' @field cols_y (`character()`)\cr
    #' Column names of codomain target parameters.
    cols_y = function() self$codomain$target_ids,

    #' @field n_in_progress (`integer(1)`)\cr
    #' Number of points with status `"in_progress"`.
    n_in_progress = function() {
      if (!nrow(self$data)) return(0L)
      nrow(self$data["in_progress", on = "status", nomatch = NULL])
    }
  ),

  private = list(
    .data = NULL,

    deep_clone = function(name, value) {
      if (name == "data") copy(value) else value
    }
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
