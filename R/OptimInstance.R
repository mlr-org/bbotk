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
    #'   Should x-values that are added to the archive be checked for validity?
    #'   Search space that is logged into archive.
    initialize = function(objective, search_space = NULL, terminator, keep_evals = "all", check_values = TRUE) {
      self$objective = assert_r6(objective, "Objective")
      self$terminator = assert_terminator(terminator, self)
      assert_choice(keep_evals, c("all", "best"))
      assert_flag(check_values)

      # set search space
      domain_search_space = self$objective$domain$search_space()
      self$search_space = if (is.null(search_space) && domain_search_space$length == 0) {
        # use whole domain as search space
        self$objective$domain
      } else if (is.null(search_space) && domain_search_space$length > 0) {
        # create search space from tune token in domain
        domain_search_space
      } else if (!is.null(search_space) && domain_search_space$length == 0) {
        # use supplied search space
        assert_param_set(search_space)
      } else {
        stop("If the domain contains TuneTokens, you cannot supply a search_space.")
      }

      # use minimal archive if only best points are needed
      self$archive = if (keep_evals == "all") {
        Archive$new(search_space = self$search_space, codomain = objective$codomain, check_values = check_values)
      } else if (keep_evals == "best") {
        ArchiveBest$new(search_space = self$search_space, codomain = objective$codomain, check_values = check_values)
      }

      # disable objective function if search space is not all numeric
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
      xss_trafoed = NULL
      if (!nrow(xdt)) {
        # eval if search space is empty
        ydt = self$objective$eval_many(list(list()))
      } else if (!self$search_space$has_trafo && !self$search_space$has_deps && inherits(self$objective, "ObjectiveRFunDt")) {
        # if search space has no transformation function and dependencies, and the objective takes a data table
        # use shortcut to skip conversion between data table and list
        ydt = self$objective$eval_dt(xdt[, self$search_space$ids(), with = FALSE])
      } else {
        xss_trafoed = transform_xdt_to_xss(xdt, self$search_space)
        ydt = self$objective$eval_many(xss_trafoed)
      }

      self$archive$add_evals(xdt, xss_trafoed, ydt)
      lg$info("Result of batch %i:", self$archive$n_batch)
      lg$info(capture.output(print(cbind(xdt, ydt),
        class = FALSE, row.names = FALSE, print.keys = FALSE)))
      return(invisible(ydt[, self$archive$cols_y, with = FALSE]))
    },

    #' @description
    #' Evaluates points in archive with status `"proposed"` by calling
    #' the [Objective] (asynchronously).
    #'
    #' @param i (`integer()`)\cr
    #'   Row ids of archive table for which values are evaluated. If `NULL`
    #'   (default), evaluate all values with status `"proposed"`.
    #' @param async (`logical(1)`)\cr
    #'   Determines if points are evaluated asynchronously with the package
    #'   \CRANpkg{future}.
    #' @param single_worker (`logical(1)`)\cr
    #'   Determines if all points of a batch are evaluated in a single worker or
    #'   in one worker per point.
    #'
    #' @return If `async = TRUE`, `data.table::data.table()` with columns
    #' `"promise"`, `"status"` and `"resolve_id"`, otherwise outcome. If `i` is
    #' not specified, all points with status `"in_progress"` (async) or
    #' `"evaluated"` (sync) are returned.
    eval_proposed = function(i = NULL, async = FALSE, single_worker = FALSE) {
      data = self$archive$data
      assert_subset(i, seq(nrow(data)))
      assert_flag(async)
      assert_flag(single_worker)
      if (!nrow(data)) return(invisible(data.table()))

      if (self$is_terminated) stop(terminated_error(self))

      # if search space has no transformation function and dependencies, and the objective takes a data table
      # use shortcut to skip conversion between data table and list
      dt_shortcut = !self$search_space$has_trafo && !self$search_space$has_deps && inherits(self$objective, "ObjectiveRFunDt")

      # transform values
      if (!dt_shortcut) {
        data["proposed", "x_domain" := list(transform_xdt_to_xss(.SD, self$search_space)), .SDcols = self$archive$cols_x, on = c("status")]
      }
      # columns send to worker
      cols_x = if (dt_shortcut) self$archive$cols_x else "x_domain"

      # asynchronous evaluation
      if (async) {
        # decouple objective from instance so that only objective is send to workers
        objective_async = self$objective

        fun = if (single_worker && !dt_shortcut) {
          # eval all points in single worker
          function(xss_trafoed) {
            promise = list(future::future(objective_async$eval_many(xss_trafoed[[1]]), seed = TRUE))
            list("promise" = promise, "status" = "in_progress", "resolve_id" = seq_along(xss_trafoed[[1]]))
          }
        } else if (single_worker && dt_shortcut) {
          # eval all points in single worker with dt shortcut
          function(xdt) {
            promise = list(future::future(objective_async$eval_dt(xdt), seed = TRUE))
            list("promise" = promise, "status" = "in_progress", "resolve_id" = seq_len(nrow(xdt)))
          }
        } else if (!single_worker && !dt_shortcut) {
          # eval each point in separate worker
          function(xss_trafoed, n) {
            promise = map(xss_trafoed[[1]], function(xs_trafoed) future::future(objective_async$eval_many(list(xs_trafoed)), seed = TRUE))
            list("promise" = promise, "status" = "in_progress", "resolve_id" = 1L)
          }
        } else if (!single_worker && dt_shortcut) {
          # eval each point in separate worker with dt shortcut
          function(xdt, n) {
            promise = map(seq(nrow(xdt)), function(n) future::future(objective_async$eval_dt(xdt[n]), seed = TRUE))
            list("promise" = promise, "status" = "in_progress", "resolve_id" = 1L)
          }
        }
        # columns returned by fun
        cols_y = c("promise", "status", "resolve_id")

      # sequential evaluation
      } else {
        fun = if (!dt_shortcut) {
          function(xss_trafoed) self$objective$eval_many(xss_trafoed[[1]])
        } else {
          function(xdt) self$objective$eval_dt(xdt)
        }
        # columns returned by fun
        cols_y = self$archive$cols_y
      }

      # start worker and add promise, or evaluate
      if (is.null(i)) {
        # all proposed points
        data["proposed", (cols_y) := fun(.SD), .SDcols = cols_x, by = "batch_nr", on = "status"]
        return(invisible(data["in_progress", cols_y, on = "status", with = FALSE]))
      } else {
        # or subset i
        data[i, (cols_y) := fun(.SD), .SDcols = cols_x, by = "batch_nr"]
        return(invisible(data[i, cols_y, with = FALSE]))
      }
    },

    #' @description
    #' Retrieve values of resolved futures and add them to the archive table.
    #'
    #' @param i (`integer()`)\cr
    #'   Row ids of archive table for which values are retrieved. If `NULL`
    #'   (default), retrieve values from all futures which are resolved.
    #'
    #' @return [`data.table::data.table()`] (invisibly).
    resolve_promise = function(i = NULL) {
      archive = self$archive
      assert_subset(i, seq(nrow(archive$data)))

      # mark resolved points
      fun_resolved = function(p) if (future::resolved(p)) "resolved" else "in_progress"
      archive$data["in_progress", "status" := map_chr(get("promise"), fun_resolved), , on = "status"]

      # get values and set status
      fun_value = function(promise, resolve_id) pmap_dtr(list(promise, resolve_id), function(p, id) future::value(p)[id])
      ydt = archive$data["resolved", fun_value(get("promise"), get("resolve_id")), on = "status", nomatch = NULL]
      id = archive$data["resolved", on = "status", which = TRUE, nomatch = NULL]
      if (length(id)) {
        set(archive$data, i = id, j = names(ydt), value = ydt)
        set(archive$data, i = id, j = "status", value = "evaluated")

        lg$info("Result of evaluating %i configuration(s):", length(id))
        lg$info(capture.output(print(archive$data[id], class = FALSE, row.names = FALSE, print.keys = FALSE)))
      }

      invisible(ydt)
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
    .objective_function = NULL,

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
