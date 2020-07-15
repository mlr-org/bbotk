#' @title Logging object for objective function evaluations
#'
#' @description
#' Container around a [data.table::data.table] which stores all performed
#' [Objective] function calls.
#'
#' @section Technical details:
#'
#' The data is stored in a private `.data` field that contains a
#' [data.table::data.table] which logs all performed [Objective] function calls.
#' The [data.table::data.table] is accessed with the `$data()` method. New
#' values can be added with the `$add_evals()` method. This however is usually
#' done through the evaluation of the [OptimInstance] by the [Optimizer].
#'
#' @template param_codomain
#' @template param_search_space
#' @template param_xdt
#' @template param_ydt
#' @export
Archive = R6Class("Archive",
  public = list(

    #' @field search_space ([paradox::ParamSet])\cr
    #' Search space of objective.
    search_space = NULL,

    #' @field codomain ([paradox::ParamSet])\cr
    #' Codomain of objective function.
    codomain = NULL,

    #' @field start_time ([POSIXct]).
    start_time = NULL,

    #' @field check_values (`logical(1)`)
    check_values = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param check_values (`logical(1)`)\cr
    #' Should x-values that are added to the archive be checked for validity?
    #' Search space that is logged into archive.
    initialize = function(search_space, codomain, check_values = TRUE) {
      self$search_space = assert_param_set(search_space)
      self$codomain = assert_param_set(codomain)
      self$check_values = assert_flag(check_values)
      private$.data = data.table()
    },

    #' @description
    #' Adds function evaluations to the archive table.
    #'
    #' @param xss_trafoed (`list()`)\cr
    #' Transformed point(s) in the *domain space*.
    add_evals = function(xdt, xss_trafoed, ydt) {
      assert_data_table(xdt)
      assert_data_table(ydt)
      assert_list(xss_trafoed)
      assert_data_table(ydt[, self$cols_y, with = FALSE], any.missing = FALSE)
      if (self$check_values) {
        self$search_space$assert_dt(xdt[, self$cols_x, with = FALSE])
      }
      xydt = cbind(xdt, ydt)
      assert_subset(c(self$search_space$ids(), self$codomain$ids()), colnames(xydt))
      xydt[, "x_domain" := list(xss_trafoed)]
      xydt[, "timestamp" := Sys.time()]
      batch_nr = private$.data$batch_nr
      batch_nr = if (length(batch_nr)) max(batch_nr) + 1L else 1L
      xydt[, "batch_nr" := batch_nr]
      private$.data = rbindlist(list(private$.data, xydt), fill = TRUE, use.names = TRUE)
    },

    #' @description
    #' Returns the best scoring evaluation. For single-crit optimization,
    #' the solution that minimizes / maximizes the objective function.
    #' For multi-crit optimization, the Pareto set / front.
    #'
    #' @param m (`integer()`)\cr
    #' Take only batches `m` into account. Default is all batches.
    #'
    #' @return [data.table::data.table]
    best = function(m = NULL) {
      if (self$n_batch == 0L) {
        stop("No results stored in archive")
      }

      m = if (is.null(m)) {
        seq_len(self$n_batch)
      } else {
        assert_integerish(m, lower = 1L, upper = self$n_batch, coerce = TRUE)
      }

      tab = private$.data[batch_nr %in% m]

      if (self$codomain$length == 1L) {
        order = if (self$codomain$tags[1L] == "minimize") 1L else -1L
        setorderv(tab, self$codomain$ids(), order = order, na.last = TRUE)
        res = tab[1, ]
      } else {
        ymat = t(as.matrix(tab[, self$cols_y, with = FALSE]))
        minimize = map_lgl(self$codomain$tags, has_element, "minimize")
        ymat = ifelse(minimize, 1L, -1L) * ymat
        res = tab[!is_dominated(ymat)]
      }

      return(res)
    },

    #' @description
    #' Returns a [data.table::data.table] which contains all performed
    #' [Objective] function calls.
    #'
    #' @param unnest (`character()`)\cr
    #' Set of column names for columns to unnest via [mlr3misc::unnest()].
    #' Unnested columns are stored in separate columns instead of list-columns.
    #'
    #' @return [data.table::data.table]
    data = function(unnest = NULL) {
      if (is.null(unnest)) {
        return(copy(private$.data))
      }
      unnest(copy(private$.data), unnest, prefix = "{col}_")
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
      print(private$.data)
    },

    #' @description
    #' Clear all evaluation results from archive.
    clear = function() {
      private$.data = data.table()
    }
  ),

  active = list(

    #' @field n_evals (`ìnteger(1)`)\cr
    #' Number of evaluations stored in the archive.
    n_evals = function() nrow(private$.data),

    #' @field n_batch (`ìnteger(1)`)\cr
    #' Number of batches stored in the archive.
    n_batch = function() {
      if (is.null(private$.data$batch_nr)) {
        0L
      } else {
        max(private$.data$batch_nr)
      }
    },

    #' @field cols_x (`character()`).
    cols_x = function() self$search_space$ids(),

    #' @field cols_y (`character()`).
    cols_y = function() self$codomain$ids()
    # idx_unevaled = function() private$.data$y
  ),

  private = list(
    .data = NULL
  )
)
