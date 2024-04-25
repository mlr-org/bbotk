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
#' @template field_rush
#'
#' @export
OptimInstanceAsync = R6Class("OptimInstanceAsync",
  inherit = OptimInstance,
  public = list(

    rush = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(
      objective,
      search_space = NULL,
      terminator,
      callbacks = NULL,
      archive = NULL,
      rush = NULL
      ) {
      assert_r6(objective, "Objective")
      search_space = choose_search_space(objective, search_space)
      self$rush = assert_rush(rush, null_ok = TRUE) %??% rsh()

      # archive is passed when a downstream packages creates a new archive class
      archive = if (is.null(archive)) {
        ArchiveAsync$new(
          search_space = search_space,
          codomain = objective$codomain,
          rush = self$rush)
      } else {
        assert_r6(archive, "ArchiveAsync")
      }

      super$initialize(
        objective = objective,
        search_space = search_space,
        terminator = terminator,
        callbacks = callbacks,
        archive = archive)
    },

    #' @description
    #' Printer.
    #'
    #' @param ... (ignored).
    print = function(...) {
      super$print()
      catf(str_indent("* Workers:", self$rush$n_workers))
    },

    #' @description
    #' Reset terminator and clear all evaluation results from archive and results.
    clear = function() {
      self$rush$reset()
      super$clear()
    }
  ),

  private = list(

    # initialize context for optimization
    .initialize_context = function(optimizer) {
      context = ContextAsync$new(instance = self, optimizer = optimizer)
      self$objective$context = context
    }
  )
)

