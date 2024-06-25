#' @title Optimization Instance
#'
#' @description
#' The `OptimInstance` specifies an optimization problem for an [Optimizer].
#'
#' @details
#' `OptimInstance` is an abstract base class that implements the base functionality each instance must provide.
#' The [Optimizer] writes the final result to the `.result` field by using the `$assign_result()` method.
#' `.result` stores a [data.table::data.table] consisting of x values in the *search space*, (transformed) x values in the *domain space* and y values in the *codomain space* of the [Objective].
#' The user can access the results with active bindings (see below).
#'
#' @template param_objective
#' @template param_search_space
#' @template param_terminator
#' @template param_check_values
#' @template param_callbacks
#' @template param_archive
#' @template param_label
#' @template param_man
#'
#' @template param_xdt
#'
#' @template field_objective
#' @template field_search_space
#' @template field_terminator
#' @template field_archive
#' @template field_progressor
#' @template field_label
#' @template field_man
#'
#'
#' @export
OptimInstance = R6Class("OptimInstance",
  public = list(

    objective = NULL,

    search_space = NULL,

    terminator = NULL,

    archive = NULL,

    progressor = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(
      objective,
      search_space = NULL,
      terminator,
      check_values = TRUE,
      callbacks = NULL,
      archive = NULL,
      label = NA_character_,
      man = NA_character_
      ) {
      self$objective = assert_r6(objective, "Objective")
      self$objective$callbacks = assert_callbacks(as_callbacks(callbacks))
      self$search_space = assert_param_set(search_space)
      self$terminator = assert_terminator(terminator, self)
      assert_flag(check_values)
      self$archive = assert_r6(archive, "Archive")

      private$.label = assert_string(label, na.ok = TRUE)
      private$.man = assert_string(man, na.ok = TRUE)
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
      cli_h1(class(self)[1L])
      cli_li(sprintf("State: %s", if (is.null(private$.result)) "Not optimized" else "Optimized"))
      cli_li(sprintf("Objective: %s", class(self$objective)[1]))
      cli_li("Search Space:")
      print(as.data.table(self$search_space)[, c("id", "class", "lower", "upper", "nlevels"), with = FALSE])
      cli_li(sprintf("Terminator: %s %s", class(self$terminator)[1], if (length(self$terminator$param_set$values)) paste0("(", as_short_string(self$terminator$param_set$values), ")") else ""))
      if (!is.null(private$.result)) {
        cli_li("Result:")
        print(self$result[, c(self$archive$cols_x, self$archive$cols_y), with = FALSE])
        cli_li("Archive:")
        tab = as.data.table(self$archive)
        x_domain_ids = names(tab)[grepl("x_domain_" , names(tab))]
        print(tab[, c(self$archive$cols_y, self$archive$cols_x, x_domain_ids), with = FALSE], digits = 1)
      }
    },

    #' @description
    #' The [Optimizer] object writes the best found point and estimated performance value here.
    #' For internal use.
    #'
    #' @param xdt (`data.table::data.table()`)\cr
    #'   x values as `data.table::data.table()` with one row. Contains the value in the
    #'   *search space* of the [OptimInstance] object. Can contain additional
    #'   columns for extra information.
    #' @param y (`numeric(1)`)\cr
    #'   Optimal outcome.
    assign_result = function(xdt, y) {
      stop("Abstract class")
    },

    #' @description
    #' Reset terminator and clear all evaluation results from archive and results.
    clear = function() {
      self$archive$clear()
      private$.result = NULL
      self$progressor = NULL
      self$objective$context = NULL
      invisible(self)
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

    #' @field is_terminated (`logical(1)`).
    is_terminated = function() {
      self$terminator$is_terminated(self$archive)
    },

    label = function(rhs) {
      assert_ro_binding(rhs)
      private$.label
    },

    man = function(rhs) {
      assert_ro_binding(rhs)
      private$.man
    }
  ),

  private = list(
    .result = NULL,
    .label = NULL,
    .man = NULL,

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

# used by OptimInstance and OptimInstanceAsync
choose_search_space = function(objective, search_space) {
  # create search space
  domain_search_space = objective$domain$search_space()
  if (is.null(search_space) && domain_search_space$length == 0) {
    # use whole domain as search space
    objective$domain
  } else if (is.null(search_space) && domain_search_space$length > 0) {
    # create search space from tune token in domain
    domain_search_space
  } else if (!is.null(search_space) && domain_search_space$length == 0) {
    # use supplied search space
    assert_param_set(search_space)
  } else {
    stop("If the domain contains TuneTokens, you cannot supply a search_space.")
  }
}
