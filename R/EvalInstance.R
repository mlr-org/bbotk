#' @title Evaluation Instance Base Class
#'
#' @description
#' Abstract base class for instances that evaluate an objective function.
#' This class provides common functionality shared between optimization
#' ([OptimInstance]) and other evaluation patterns (e.g., active learning).
#'
#' @details
#' `EvalInstance` contains the core components needed for any objective
#' evaluation loop:
#' - An [Objective] to evaluate
#' - A search space defining valid inputs
#' - An [Archive] storing evaluation history
#' - A [Terminator] defining stopping conditions
#'
#' Subclasses add specific functionality:
#' - [OptimInstance]: Result tracking, optimization-specific methods
#' - External packages may define their own subclasses
#'
#' @template param_objective
#' @template param_search_space
#' @template param_terminator
#' @template param_archive
#' @template param_label
#' @template param_man
#'
#' @template field_objective
#' @template field_search_space
#' @template field_terminator
#' @template field_archive
#' @template field_label
#' @template field_man
#'
#' @export
EvalInstance = R6Class("EvalInstance",
  public = list(

    objective = NULL,

    search_space = NULL,

    archive = NULL,

    terminator = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(objective, search_space, terminator, archive,
      label = NA_character_, man = NA_character_) {
      self$objective = assert_r6(objective, "Objective")
      self$search_space = assert_param_set(search_space)
      self$terminator = assert_r6(terminator, "Terminator")
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
      cat_cli({
        cli_h1("{.cls {class(self)[1L]}}")
        cli_li("Objective: {.cls {class(self$objective)[1]}}")
        cli_li("Search Space:")
      })
      print(as.data.table(self$search_space)[, c("id", "class", "lower", "upper", "nlevels"), with = FALSE])
      terminator = if (length(self$terminator$param_set$values)) paste0("(", as_short_string(self$terminator$param_set$values), ")") else ""
      cat_cli({
        cli_li("Terminator: {.cls {class(self$terminator)[1]}} {terminator}")
        cli_li("Evaluations: {self$archive$n_evals}")
      })
    },

    #' @description
    #' Clear all evaluation results from archive.
    clear = function() {
      self$archive$clear()
      self$objective$context = NULL
      invisible(self)
    }
  ),

  active = list(
    #' @field is_terminated (`logical(1)`)\cr
    #'   Whether the terminator says we should stop.
    is_terminated = function() {
      self$terminator$is_terminated(self$archive)
    },

    #' @field n_evals (`integer(1)`)\cr
    #'   Number of evaluations performed.
    n_evals = function() {
      self$archive$n_evals
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
