#' @title Optimization Instance with Rush
#'
#' @include OptimInstance.R
#'
#' @description
#'
#'
#' Abstract base class for [OptimInstanceAsyncSingleCrit] and [OptimInstanceAsyncMultiCrit].
#' The optimization instances specify an optimization problem for [Optimizer]s.
#' Points are evaluated asynchronously with the `rush` package.
#' The function [oi()] creates an [OptimInstanceAsyncSingleCrit] or [OptimInstanceAsyncMultiCrit] and the function [bb_optimize()] creates an instance internally.
#'
#' @template param_objective
#' @template param_search_space
#' @template param_terminator
#' @template param_callbacks
#' @template param_archive
#' @template param_rush
#'
#' @template field_objective
#' @template field_search_space
#' @template field_terminator
#' @template field_rush
#' @template field_callbacks
#' @template field_archive_rush
#'
#' @export
OptimInstanceAsync = R6Class("OptimInstanceAsync",
  public = list(

    objective = NULL,

    search_space = NULL,

    terminator = NULL,

    rush = NULL,

    callbacks = NULL,

    archive = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(
      objective,
      search_space = NULL,
      terminator,
      callbacks = list(),
      archive = NULL,
      rush = NULL
      ) {
      self$objective = assert_r6(objective, "Objective")
      self$search_space = choose_search_space(self$objective, search_space)
      self$terminator = assert_terminator(terminator, self)
      self$callbacks = assert_callbacks(as_callbacks(callbacks))
      self$rush = assert_rush(rush, null_ok = TRUE) %??% rsh()

      # archive is passed when a downstream packages creates a new archive class
      self$archive = if (is.null(archive)) {
        ArchiveRush$new(search_space = self$search_space, codomain = self$objective$codomain, rush = self$rush)
      } else {
        assert_r6(archive, "ArchiveRush")
      }
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
    print = function(...) {
      catf(format(self))
      catf(str_indent("* State: ", if (is.null(private$.result)) "Not optimized" else "Optimized"))
      catf(str_indent("* Objective:", format(self$objective)))
      catf("* Search Space:")
      print(as.data.table(self$search_space)[, c("id", "class", "lower", "upper", "nlevels"), with = FALSE])
      catf(str_indent("* Terminator:", format(self$terminator)))
      catf(str_indent("* Workers:", self$rush$n_workers))
      if (!is.null(private$.result)) {
        catf("* Result:")
        print(self$result[, c(self$archive$cols_x, self$archive$cols_y), with = FALSE])
        catf("* Archive:")
        print(as.data.table(self$archive)[, c(self$archive$cols_x, self$archive$cols_y), with = FALSE])
      }
    },

    #' @description
    #' Reset terminator and clear all evaluation results from archive and results.
    clear = function() {
      self$rush$reset()
      self$archive$clear()
      private$.result = NULL
      invisible(self)
    },

    #' @description
    #' The [Optimizer] object writes the best found point and estimated performance value here.
    #' For internal use.
    #'
    #' @param xdt (`data.table::data.table()`)\cr
    #'  x values as `data.table::data.table()` with one row.
    #' Contains the value in the  *search space* of the [OptimInstance] object.
    #' Can contain additional columns for extra information.
    #' @param y (`numeric(1)`)\cr
    #'   Optimal outcome.
    assign_result = function(xdt, y) {
      stop("Abstract class")
    }
  ),

  active = list(
    #' @field result ([data.table::data.table])\cr
    #' Get result
    result = function() {
      private$.result
    },

    #' @field result_x_search_space ([data.table::data.table])\cr
    #' x part of the result in the *search space*.
    result_x_search_space = function() {
      private$.result[, self$search_space$ids(), with = FALSE]
    },

    #' @field result_x_domain (`list()`)\cr
    #' (transformed) x part of the result in the *domain space* of the objective.
    result_x_domain = function() {
      private$.result$x_domain[[1]]
    },

    #' @field result_y (`numeric()`)\cr
    #' Optimal outcome.
    result_y = function() {
      unlist(private$.result[, self$objective$codomain$ids(), with = FALSE])
    },

    #' @field is_terminated (`logical(1)`).
    is_terminated = function() {
      self$terminator$is_terminated(self$archive)
    }
  ),

  private = list(
    .xdt = NULL,
    .result = NULL,
    .objective_function = NULL,
    .context = NULL,
    .freeze_archive = NULL,
    .detect_lost_tasks = NULL,

    .assign_result = function(xdt, y) {
      stop("Abstract class")
    },

    deep_clone = function(name, value) {
      switch(name,
        objective = value$clone(deep = TRUE),
        search_space = value$clone(deep = TRUE),
        terminator = value$clone(deep = TRUE),
        archive = value$clone(deep = TRUE),
        value
      )
    }
  )
)

