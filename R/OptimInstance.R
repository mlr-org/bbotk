#' @title Optimization Instance with budget and archive
#'
#' @description
#' Abstract base class.
#'
#' @section Technical details:
#' The [Optimizer] writes the final result to the `.result` field by using
#' the `$assign_result()` method. `.result` stores a [data.table::data.table]
#' consisting of x values in the *search space*, (transformed) x values in the
#' *domain space* and y values in the *codomain space* of the [Objective]. The
#' user can access the results with active bindings (see below).
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
    #' If no search space is provided, search space is set to domain of
    #' objective.
    #' @param terminator ([Terminator]).
    initialize = function(objective, search_space = NULL, terminator) {
      self$objective = assert_r6(objective, "Objective")
      self$search_space = if (is.null(search_space)) {
         self$objective$domain
      } else {
        assert_param_set(search_space)
      }
      self$terminator = assert_terminator(terminator, self)
      self$archive = Archive$new(search_space = self$search_space,
        codomain = objective$codomain)

      if (!all(self$search_space$is_number)) {
        private$.objective_function = objective_error
      } else {
        private$.objective_function = objective_function
        private$.objective_multiplicator =
          ifelse(self$objective$codomain$tags == "minimize", 1, -1)
      }
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
      if("progressr" %in% self$terminator$properties && isNamespaceLoaded(
        "progressr")) {
        self$terminator$run_progressor(self$archive)
      }

      xss_trafoed = transform_xdt_to_xss(xdt, self$search_space)
      lg$info("Evaluating %i configuration(s)", nrow(xdt))
      ydt = self$objective$eval_many(xss_trafoed)
      self$archive$add_evals(xdt, xss_trafoed, ydt)
      lg$info("Result of batch %i:", self$archive$n_batch)
      lg$info(capture.output(print(cbind(xdt, ydt),
        class = FALSE, row.names = FALSE, print.keys = FALSE)))
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
      stop("Abstract class")
    },

    #' @description
    #' Evaluates (untransformed) points of only numeric values.
    #' Returns a numeric scalar for single-crit or a numeric vector for multi-crit.
    #' The return value(s) are negated if the measure is maximized.
    #' Internally, `$eval_batch()` is called with a single row. This function
    #' serves as a objective function for optimizers of numeric spaces - which
    #' should always be minimized.
    #'
    #' @param x (`numeric()`)\cr
    #' Untransformed points.
    #'
    #' @return Objective value as `numeric(1)`, negated for maximization problems.
    objective_function = function(x) {
      private$.objective_function(x, self, private$.objective_multiplicator)
    }
  ),

  active = list(
    #' @field result ([data.table::data.table])\cr
    #' Get result
    result = function() {
      private$.result
    },

    #' @field result_x_search_space ([data.table::data.table])\cr
    #'   x part of the result in the *search space*.
    result_x_search_space = function() {
      private$.result[, self$search_space$ids(), with = FALSE]
    },

    #' @field result_x_domain (`list()`)\cr
    #'   (transformed) x part of the result in the *domain space* of the objective.
    result_x_domain = function() {
      private$.result$x_domain[[1]]
    },

    #' @field result_y (`numeric()`)\cr
    #'   Optimal outcome.
    result_y = function() {
      unlist(private$.result[, self$objective$codomain$ids(), with = FALSE])
    }
  ),

  private = list(
    .result = NULL,

    .objective_function = NULL,

    .objective_multiplicator = NULL
  )
)

objective_function = function(x, inst, multiplicator) {
    xs = set_names(as.list(x), inst$search_space$ids())
    inst$search_space$assert(xs)
    xdt = as.data.table(xs)
    res = inst$eval_batch(xdt)
    y = as.numeric(res[, inst$objective$codomain$ids(), with = FALSE])
    y * multiplicator
}

objective_error = function(x, inst, multiplicator) {
  stop("$objective_function can only be called if search_space only
    contains numeric values")
}
