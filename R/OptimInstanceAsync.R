#' @title Optimization Instance for Asynchronous Optimization
#'
#' @include OptimInstance.R
#'
#' @description
#' The `OptimInstanceAsync` specifies an optimization problem for an [OptimizerAsync].
#' The function [oi_async()] creates an [OptimInstanceAsyncSingleCrit] or [OptimInstanceAsyncMultiCrit].
#'
#' @details
#' `OptimInstanceAsync` is an abstract base class that implements the base functionality each instance must provide.
#'
#' @template param_objective
#' @template param_search_space
#' @template param_terminator
#' @template param_check_values
#' @template param_callbacks
#' @template param_archive
#' @template param_rush
#' @template param_label
#' @template param_man
#'
#' @template field_rush
#'
#' @export
OptimInstanceAsync = R6Class("OptimInstanceAsync",
  inherit = OptimInstance,
  cloneable = FALSE,
  public = list(

    rush = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(
      objective,
      search_space = NULL,
      terminator,
      check_values = FALSE,
      callbacks = NULL,
      archive = NULL,
      rush = NULL,
      label = NA_character_,
      man = NA_character_
      ) {
      require_namespaces("rush")
      assert_r6(objective, "Objective")
      search_space = choose_search_space(objective, search_space)
      self$rush = rush::assert_rush(rush, null_ok = TRUE) %??% rush::rsh()

      # archive is passed when a downstream packages creates a new archive class
      archive = if (is.null(archive)) {
        ArchiveAsync$new(
          search_space = search_space,
          codomain = objective$codomain,
          check_values = check_values,
          rush = self$rush)
      } else {
        assert_r6(archive, "ArchiveAsync")
      }

      super$initialize(
        objective = objective,
        search_space = search_space,
        terminator = terminator,
        callbacks = callbacks,
        archive = archive,
        label = label,
        man = man)
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
    },

    #' @description
    #' Reconnect to Redis.
    #' The connection breaks when the [rush::Rush] is saved to disk.
    #' Call this method to reconnect after loading the object.
    reconnect = function() {
      self$rush$reconnect()
    }
  ),

  private = list(
    .xs = NULL,
    .xs_trafoed = NULL,
    .extra = NULL,
    .ys = NULL,

    .eval_point = function(xs) {
      # transpose point
      private$.xs = xs[self$archive$cols_x]
      private$.xs_trafoed = trafo_xs(private$.xs, self$search_space)
      private$.extra = xs[names(xs) %nin% c(self$archive$cols_x, "x_domain")]

      call_back("on_optimizer_before_eval", self$objective$callbacks, self$objective$context)

      # eval
      key = self$archive$push_running_point(private$.xs)
      private$.ys = self$objective$eval(private$.xs_trafoed)

      call_back("on_optimizer_after_eval", self$objective$callbacks, self$objective$context)

      # push result
      self$archive$push_result(key, private$.ys, x_domain = private$.xs_trafoed, extra = private$.extra)

      return(invisible(private$.ys))
    },

    .eval_queue = function() {
      while (!self$is_terminated && self$archive$n_queued) {
        task = self$archive$pop_point()
        if (!is.null(task)) {
          private$.xs = task$xs

          # transpose point
          private$.xs_trafoed = trafo_xs(private$.xs, self$search_space)

          # eval
          call_back("on_optimizer_before_eval", self$objective$callbacks, self$objective$context)
          private$.ys = self$objective$eval(private$.xs_trafoed)

          # push reuslt
          call_back("on_optimizer_after_eval", self$objective$callbacks, self$objective$context)
          self$archive$push_result(task$key, private$.ys, x_domain = private$.xs_trafoed)
        }
      }
    },

    # initialize context for optimization
    .initialize_context = function(optimizer) {
      context = ContextAsync$new(inst = self, optimizer = optimizer)
      self$objective$context = context
    }
  )
)
