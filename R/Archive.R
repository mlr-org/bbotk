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

    #' @field data_extra (named `list`)\cr
    #' Data created by specific [`Optimizer`]s that does not relate to any individual function evaluation and can therefore not be held in `$data`.
    #' Every optimizer should create and refer to its own entry in this list, named by its `class()`.
    data_extra = named_list(),

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
    add_evals = function(xdt, xss_trafoed = NULL, ydt) {
      assert_data_table(xdt)
      assert_data_table(ydt)
      assert_list(xss_trafoed, null.ok = TRUE)
      assert_data_table(ydt[, self$cols_y, with = FALSE], any.missing = FALSE)
      if (self$check_values) {
        self$search_space$assert_dt(xdt[, self$cols_x, with = FALSE])
      }
      xydt = cbind(xdt, ydt)
      assert_subset(c(self$search_space$ids(), self$codomain$ids()), colnames(xydt))
      if (!is.null(xss_trafoed)) set(xydt, j = "x_domain", value = list(xss_trafoed))
      set(xydt, j = "timestamp", value = Sys.time())
      batch_nr = self$data$batch_nr
      set(xydt, j = "batch_nr", value = if (length(batch_nr)) max(batch_nr) + 1L else 1L)
      self$data = rbindlist(list(self$data, xydt), fill = TRUE, use.names = TRUE)
    },

    #' @description
    #' Returns the best scoring evaluation(s).
    #' For single-crit optimization, the solution that minimizes / maximizes the objective function.
    #' For multi-crit optimization, the Pareto set / front.
    #'
    #' @param batch (`integer()`)\cr
    #' The batch number(s) to limit the best results to.
    #' Default is all batches.
    #' @param n_select (`integer(1L)`)\cr
    #' Amount of points to select.
    #' Ignored for multi-crit optimization.
    #'
    #' @return [data.table::data.table()]
    best = function(batch = NULL, n_select = 1L) {
      if (!self$n_batch) return(data.table())
      assert_subset(batch, seq_len(self$n_batch))
      assert_int(n_select, lower = 1L)

      tab = if (is.null(batch)) self$data else self$data[list(batch), , on = "batch_nr"]

      if (self$codomain$target_length == 1L) {
        if (n_select == 1L) {
          # use which_max to find the best point
          y = tab[[self$cols_y]] * -self$codomain$maximization_to_minimization
          ii = which_max(y, ties_method = "random")
          tab[ii]
        } else {
          # use partial sort to find the best points
          y = tab[[self$cols_y]] * self$codomain$maximization_to_minimization
          i = sort(y, partial = n_select)[n_select]
          ii = which(y <= i)
          tab[ii]
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
    #' @param batch (`integer()`)\cr
    #'   The batch number(s) to limit the best points to. Default is
    #'   all batches.
    #'
    #' @return [data.table::data.table()]
    nds_selection = function(batch = NULL, n_select = 1, ref_point = NULL) {
      if (self$n_batch == 0L) stop("No results stored in archive")
      if (is.null(batch)) batch = seq_len(self$n_batch)
      assert_integerish(batch, lower = 1L, upper = self$n_batch, coerce = TRUE)

      tab = self$data[get("batch_nr") %in% batch, ]
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
      self$data = data.table()
      self$start_time = NULL
    }
  ),

  active = list(

    #' @field n_evals (`integer(1)`)\cr
    #' Number of evaluations stored in the archive.
    n_evals = function() nrow(self$data),

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
    cols_y = function() self$codomain$target_ids
  ),

  private = list(
    .data = NULL,

    deep_clone = function(name, value) {
      switch(name,
        search_space = value$clone(deep = TRUE),
        codomain = value$clone(deep = TRUE),
        data = copy(value),
        value
      )
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
