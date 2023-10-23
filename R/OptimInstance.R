#' @title Optimization Instance
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
#' @template param_callbacks
#' @template param_archive
#'
#'
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

    #' @field callbacks (List of [CallbackOptimization]s).
    callbacks = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param objective ([Objective]).
    #' @param terminator ([Terminator]).
    #' @param check_values (`logical(1)`)\cr
    #'   Should x-values that are added to the archive be checked for validity?
    #'   Search space that is logged into archive.
    initialize = function(
      objective,
      search_space = NULL,
      terminator,
      keep_evals = "all",
      check_values = TRUE,
      callbacks = list(),
      archive = NULL
      ) {
      self$objective = assert_r6(objective, "Objective")
      self$search_space = choose_search_space(self$objective, search_space)
      self$terminator = assert_terminator(terminator, self)
      assert_choice(keep_evals, c("all", "best"))
      assert_flag(check_values)
      self$callbacks = assert_callbacks(as_callbacks(callbacks))

      # archive is passed when a downstream packages creates a new archive class
      self$archive = if (is.null(archive)) {
        # use minimal archive if only best points are needed
        Archive = if (keep_evals == "all") Archive else ArchiveBest
        Archive$new(
          search_space = self$search_space,
          codomain = objective$codomain,
          check_values = check_values)
      } else {
        assert_r6(archive, "Archive")
      }

      # disable objective function if search space is not all numeric
      private$.objective_function = if (!self$search_space$all_numeric) objective_error else objective_function
      self$objective_multiplicator = self$objective$codomain$maximization_to_minimization
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
      if (!is.null(private$.result)) {
        catf("* Result:")
        print(self$result[, c(self$archive$cols_x, self$archive$cols_y), with = FALSE])
        catf("* Archive:")
        print(as.data.table(self$archive)[, c(self$archive$cols_x, self$archive$cols_y), with = FALSE])
      }
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
      private$.xdt = xdt
      call_back("on_optimizer_before_eval", self$callbacks, private$.context)
      # update progressor
      if (!is.null(self$progressor)) self$progressor$update(self$terminator, self$archive)

      if (self$is_terminated) stop(terminated_error(self))
      assert_data_table(xdt)
      assert_names(colnames(xdt), must.include = self$search_space$ids())

      lg$info("Evaluating %i configuration(s)", max(1, nrow(xdt)))
      xss_trafoed = NULL
      if (!nrow(xdt)) {
        # eval if search space is empty
        ydt = self$objective$eval_many(list(list()))
      } else if (!self$search_space$has_trafo && !self$search_space$has_deps && inherits(self$objective, "ObjectiveRFunDt")) {
        # if search space has no transformation function and dependencies, and the objective takes a data table
        # use shortcut to skip conversion between data table and list
        ydt = self$objective$eval_dt(private$.xdt[, self$search_space$ids(), with = FALSE])
      } else {
        xss_trafoed = transform_xdt_to_xss(private$.xdt, self$search_space)
        ydt = self$objective$eval_many(xss_trafoed)
      }

      self$archive$add_evals(xdt, xss_trafoed, ydt)
      lg$info("Result of batch %i:", self$archive$n_batch)
      lg$info(capture.output(print(cbind(xdt, ydt),
        class = FALSE, row.names = FALSE, print.keys = FALSE)))
      call_back("on_optimizer_after_eval", self$callbacks, private$.context)
      return(invisible(ydt[, self$archive$cols_y, with = FALSE]))
    },

    #' @description
    #' The [Optimizer] object writes the best found point
    #' and estimated performance value here. For internal use.
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
    #' Evaluates (untransformed) points of only numeric values. Returns a
    #' numeric scalar for single-crit or a numeric vector for multi-crit. The
    #' return value(s) are negated if the measure is maximized. Internally,
    #' `$eval_batch()` is called with a single row. This function serves as a
    #' objective function for optimizers of numeric spaces - which should always
    #' be minimized.
    #'
    #' @param x (`numeric()`)\cr
    #'   Untransformed points.
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
      self$progressor = NULL
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
    .xdt = NULL,
    .result = NULL,
    .objective_function = NULL,
    .context = NULL,

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

# used by OptimInstance and OptimInstanceRush
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
