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
#' @template param_search_space
#' @template param_keep_evals
#' @export
OptimInstance = R6Class("OptimInstance",
  public = list(

    #' @field objective ([Objective]).
    objective = NULL,

    #' @field search_space ([paradox::ParamSet]).
    search_space = NULL,

    #' @field terminator ([Terminator]).
    terminator = NULL,

    #' @field archive ([Archive]).
    archive = NULL,

    #' @field progressor (`progressor()`)\cr
    #' Stores `progressor` function.
    progressor = NULL,

    #' @field objective_multiplicator (`integer()`).
    objective_multiplicator = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param objective ([Objective]).
    #' @param terminator ([Terminator]).
    #' @param check_values (`logical(1)`)\cr
    #' Should x-values that are added to the archive be checked for validity?
    #' Search space that is logged into archive.
    initialize = function(objective, search_space = NULL, terminator,
      keep_evals = "all", check_values = TRUE) {

      assert_choice(keep_evals, c("all", "best"))
      self$objective = assert_r6(objective, "Objective")

      domain_search_space = self$objective$domain$search_space()
      self$search_space = if (is.null(search_space) && domain_search_space$length == 0) {
        self$objective$domain
      } else if (is.null(search_space) && domain_search_space$length > 0) {
        domain_search_space
      } else if (!is.null(search_space) && domain_search_space$length == 0) {
        assert_param_set(search_space)
      } else {
        stop("If the domain contains TuneTokens, you cannot supply a search_space.")
      }
      self$terminator = assert_terminator(terminator, self)

      assert_flag(check_values)

      is_rfundt = inherits(self$objective, "ObjectiveRFunDt")

      self$archive = if (keep_evals == "all") {
        Archive$new(search_space = self$search_space,
          codomain = objective$codomain, check_values = check_values,
          store_x_domain = !is_rfundt || self$search_space$has_trafo)
      } else if (keep_evals == "best") {
        ArchiveBest$new(search_space = self$search_space,
          codomain = objective$codomain, check_values = check_values,
          store_x_domain = !is_rfundt || self$search_space$has_trafo)
        # only not store xss if we have RFunDT and not trafo
      }

      if (!self$search_space$all_numeric) {
        private$.objective_function = objective_error
      } else {
        private$.objective_function = objective_function
      }
      self$objective_multiplicator = self$objective$codomain$maximization_to_minimization
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
      catf(str_indent("* State: ", if (is.null(private$.result)) "Not optimized" else "Optimized"))
      catf(str_indent("* Objective:", format(self$objective)))
      catf("* Search Space:")
      print(self$search_space)
      catf(str_indent("* Terminator:", format(self$terminator)))
      catf(str_indent("* Terminated:", self$is_terminated))
      if (!is.null(private$.result)) {
        catf("* Result:")
        print(self$result)
      }
      catf("* Archive:")
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
    #' @param xdt (`data.table::data.table()`)\cr
    #' x values as `data.table()` with one point per row. Contains the value in
    #' the *search space* of the [OptimInstance] object. Can contain additional
    #' columns for extra information.
    eval_batch = function(xdt) {
      # update progressor
      if (!is.null(self$progressor)) self$progressor$update(self$terminator, self$archive)

      if (self$is_terminated) stop(terminated_error(self))
      assert_data_table(xdt)
      assert_names(colnames(xdt), must.include = self$search_space$ids())

      lg$info("Evaluating %i configuration(s)", max(1, nrow(xdt)))

      is_rfundt = inherits(self$objective, "ObjectiveRFunDt")
      # calculate the x as (trafoed) domain only if needed
      if (self$search_space$has_trafo || self$search_space$has_deps || self$archive$store_x_domain || !is_rfundt) {
        xss_trafoed = transform_xdt_to_xss(xdt, self$search_space)
      } else {
        xss_trafoed = NULL
      }

      # eval if search space is empty
      if (nrow(xdt) == 0) {
        ydt = self$objective$eval_many(list(list()))
        # if no trafos, no deps and objective evals dt directly, we go a shortcut
      } else if (is_rfundt && !self$search_space$has_trafo && !self$search_space$has_deps) {
        ydt = self$objective$eval_dt(xdt[, self$search_space$ids(), with = FALSE])
      } else {
        ydt = self$objective$eval_many(xss_trafoed)
      }

      self$archive$add_evals(xdt, xss_trafoed, ydt)
      lg$info("Result of batch %i:", self$archive$n_batch)
      lg$info(capture.output(print(cbind(xdt, ydt),
        class = FALSE, row.names = FALSE, print.keys = FALSE)))
      return(invisible(ydt[, self$archive$cols_y, with = FALSE]))
    },

    #' @description
    #' The [Optimizer] object writes the best found point
    #' and estimated performance value here. For internal use.
    #'
    #' @param xdt (`data.table::data.table()`)\cr
    #' x values as `data.table()` with one row. Contains the value in the *search
    #' space* of the [OptimInstance] object. Can contain additional columns for
    #' extra information.
    #' @param y (`numeric(1)`)\cr
    #'   Optimal outcome.
    assign_result = function(xdt, y) {
      stop("Abstract class")
    },

    #' @description
    #' Evaluates (untransformed) points of only numeric values. Returns a
    #' numeric scalar for single-crit or a numeric vector for multi-crit. The
    #' return value(s) are negated if the measure is maximized. Internally,
    #' `$eval_batch()` is called with a single row. This function serves as a
    #' objective function for optimizers of numeric spaces - which should always
    #' be minimized.
    #'
    #' @param x (`numeric()`)\cr
    #' Untransformed points.
    #'
    #' @return Objective value as `numeric(1)`, negated for maximization problems.
    objective_function = function(x) {
      private$.objective_function(x, self, self$objective_multiplicator)
    },

    #' @description
    #' Reset terminator and clear all evaluation results from archive and results.
    clear = function() {
      self$archive$clear()
      private$.result = NULL
      self$progressor = Progressor$new()
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
    .result = NULL,

    .objective_function = NULL
  )
)

objective_function = function(x, inst, maximization_to_minimization) {
  xs = set_names(as.list(x), inst$search_space$ids())
  inst$search_space$assert(xs)
  xdt = as.data.table(xs)
  res = inst$eval_batch(xdt)
  y = as.numeric(res[, inst$objective$codomain$target_ids, with = FALSE])
  y * maximization_to_minimization
}

objective_error = function(x, inst, maximization_to_minimization) {
  stop("$objective_function can only be called if search_space only
    contains numeric values")
}
