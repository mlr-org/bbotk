#' @title Optimization Instance with budget and archive
#'
#' @description
#' Wraps an [Objective] function with extra services for convenient evaluation.
#'
#' * Automatic storing of results in an [Archive] after evaluation.
#' * Automatic checking for termination. Evaluations of design points are
#'   performed in batches. Before a batch is evaluated, the [Terminator] is
#'   queried for the remaining budget. If the available budget is exhausted, an
#'   exception is raised, and no further evaluations can be performed from this
#'   point on.
#'
#' @section Technical details:
#' The [Optimizer] writes the final result to the `.result` field by using
#' the `$assign_result()` method. `.result` stores a [data.table::data.table]
#' consisting of x values in the *search space*, (transformed) x values in the
#' *domain space* and y values in the *codomain space* of the [Objective]. The
#' user can access the results with active bindings (see below).
#'
#' In order to replace the default logging messages with custom logging, the
#' `.log_*` private methods can be overwritten in an `OptimInstance` subclass:
#'
#' * `$.log_eval_batch_start()` Called at the beginning of `$eval_batch()`
#' * `$.log_eval_batch_finish()` Called at the end of `$eval_batch()`
#'
#' @template param_xdt
#' @export
OptimInstance = R6Class("OptimInstance",
  public = list(

    #' @field objective ([Objective]).
    objective = NULL,

    #' @field search_space ([paradox::ParamSet]).
    search_space = NULL,

    #' @field terminator ([Terminator]).
    terminator = NULL,

    #' @field is_terminated (`logical(1)`).
    is_terminated = FALSE,

    #' @field archive ([Archive]).
    archive = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param objective ([Objective]).
    #' @param search_space ([paradox::ParamSet]).
    #' @param terminator ([Terminator]).
    initialize = function(objective, search_space, terminator) {
      self$objective = assert_r6(objective, "Objective")
      self$search_space = assert_param_set(search_space)
      self$terminator = assert_terminator(terminator)
      self$archive = Archive$new(search_space = search_space,
        codomain = objective$codomain)
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
    print = function(...) {
      catf(format(self))
      catf(str_indent("* Objective:", format(self$objective)))
      catf("* Search Space:")
      print(self$search_space)
      catf(str_indent("* Terminator:", format(self$terminator)))
      catf(str_indent("* Terminated:", self$is_terminated))
      print(self$archive)
    },

    #' @description
    #' Evaluates all input values in `xdt` by calling
    #' the [Objective]. Applies possible transformations to the input values
    #' and writes the results to the [Archive].
    #'
    #' Before each batch-evaluation, the [Terminator] is checked, and if it
    #' is positive, an exception of class `terminated_error` is raised. This
    #' function should be internally called by the [Optimizer].
    #' @param xdt (`data.table`)\cr
    #'   x values as `data.table` with one point per row.
    #'   Contains the value in the *search space* of the [OptimInstance] object.
    #'   Can contain additional columns for extra information.
    eval_batch = function(xdt) {
      if (self$is_terminated || self$terminator$is_terminated(self$archive)) {
        self$is_terminated = TRUE
        stop(terminated_error(self))
      }
      xss_trafoed = transform_xdt_to_xss(xdt, self$search_space)
      private$.log_eval_batch_start(xdt)
      ydt = self$objective$eval_many(xss_trafoed)
      self$archive$add_evals(xdt, xss_trafoed, ydt)
      private$.log_eval_batch_finish(xdt, ydt)
      return(invisible(ydt))
    },

    #' @description
    #' The [Optimizer] object writes the best found point
    #' and estimated performance value here. For internal use.
    #'
    #' @param xdt (`data.table`)\cr
    #'   x values as `data.table` with one row.
    #'   Contains the value in the *search space* of the [OptimInstance] object.
    #'   Can contain additional columns for extra information.
    #' @param y (`numeric(1)`)\cr
    #'   Optimal outcome.
    assign_result = function(xdt, y) {
      # FIXME: We could have one way that just lets us put a 1xn DT as result directly.
      assert_data_table(xdt, nrows = 1)
      assert_names(names(xdt), must.include = self$search_space$ids())
      assert_number(y)
      assert_names(names(y), permutation.of = self$objective$codomain$ids())
      opt_x = transform_xdt_to_xss(xdt, self$search_space)[[1]]
      private$.result = cbind(xdt, opt_x = list(opt_x), t(y)) # t(y) so the name of y stays
    }
  ),

  active = list(
    #' @field result ([data.table::data.table])\cr
    #' Get result
    result = function() {
      private$.result
    },

    #' @field result_x ([data.table::data.table])\cr
    #'   x part of the result in the *search space*.
    result_x = function() {
      private$.result[, self$search_space$ids(), with = FALSE]
    },

    #' @field result_opt_x (`list()`)\cr
    #'   (transformed) x part of the result in the *domain space* of the objective.
    result_opt_x = function() {
      private$.result$opt_x[[1]]
    },

    #' @field result_y (`numeric()`)\cr
    #'   Optimal outcome.
    result_y = function() {
      unlist(private$.result[, self$objective$codomain$ids(), with = FALSE])
    }
  ),

  private = list(
    .result = NULL,

    .log_eval_batch_start = function(xdt) {
      lg$info("Evaluating %i configuration(s)", nrow(xdt))
    },

    .log_eval_batch_finish = function(xdt, ydt) {
      lg$info("Result of batch %i:", self$archive$n_batch)
      lg$info(capture.output(print(cbind(xdt, ydt),
        class = FALSE, row.names = FALSE, print.keys = FALSE)))
    }
  )
)
