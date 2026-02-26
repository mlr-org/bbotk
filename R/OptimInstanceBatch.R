#' @title Optimization Instance for Batch Optimization
#'
#' @description
#' The `OptimInstanceBatch` specifies an optimization problem for an [OptimizerBatch].
#' The function [oi()] creates an [OptimInstanceAsyncSingleCrit] or [OptimInstanceAsyncMultiCrit].
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
#' @seealso [oi()], [OptimInstanceBatchSingleCrit], [OptimInstanceBatchMultiCrit]
#' @export
OptimInstanceBatch = R6Class("OptimInstanceBatch",
  inherit = OptimInstance,
  public = list(

    #' @field objective_multiplicator (`integer()`).
    objective_multiplicator = NULL,

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
      assert_r6(objective, "Objective")
      search_space = choose_search_space(objective, search_space)

      # archive is passed when a downstream packages creates a new archive class
      archive = if (is.null(archive)) {
        ArchiveBatch$new(
          search_space = search_space,
          codomain = objective$codomain,
          check_values = check_values)
      } else {
        assert_r6(archive, "ArchiveBatch")
      }

      super$initialize(
        objective = objective,
        search_space = search_space,
        terminator = terminator,
        callbacks = callbacks,
        archive = archive,
        label = label,
        man = man
      )

      # disable objective function if search space is not all numeric
      private$.objective_function = if (!self$search_space$all_numeric) objective_error else objective_function
      self$objective_multiplicator = self$objective$codomain$direction
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
      if (is.null(self$objective$context)) private$.initialize_context(NULL)
      call_back("on_optimizer_before_eval", self$objective$callbacks, self$objective$context)
      # update progressor
      if (!is.null(self$progressor)) self$progressor$update(self$terminator, self$archive)

      if (self$is_terminated) terminated_error(self)
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
      call_back("on_optimizer_after_eval", self$objective$callbacks, self$objective$context)
      return(invisible(ydt[, self$archive$cols_y, with = FALSE]))
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
    # intermediate objects
    .xdt = NULL,
    .objective_function = NULL,

    # initialize context for optimization
    .initialize_context = function(optimizer) {
      context = ContextBatch$new(inst = self, optimizer = optimizer)
      self$objective$context = context
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

objective_function = function(x, inst, direction) {
  xs = set_names(as.list(x), inst$search_space$ids())
  inst$search_space$assert(xs)
  xdt = as.data.table(xs)
  res = inst$eval_batch(xdt)
  y = as.numeric(res[, inst$objective$codomain$target_ids, with = FALSE])
  y * direction
}

objective_error = function(x, inst, direction) {
  stop("$objective_function can only be called if search_space only
    contains numeric values")
}

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
