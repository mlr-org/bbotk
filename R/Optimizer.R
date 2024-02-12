#' @title Optimizer
#'
#' @include mlr_optimizers.R
#'
#' @description
#' Abstract `Optimizer` class that implements the base functionality each `Optimizer` subclass must provide.
#' A `Optimizer` object describes the optimization strategy.
#' A `Optimizer` object must write its result to the `$assign_result()` method of the [OptimInstance] at the end in order to store the best point and its estimated performance vector.
#'
#' @template section_progress_bars
#'
#' @template field_param_set
#' @template field_label
#' @template field_man
#'
#' @template param_id
#' @template param_param_set
#' @template param_label
#' @template param_man
#'
#' @export
Optimizer = R6Class("Optimizer",
  public = list(
    #' @template field_id
    id = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param param_classes (`character()`)\cr
    #'   Supported parameter classes that the optimizer can optimize.
    #'   Subclasses of [paradox::Param].
    #'
    #' @param properties (`character()`)\cr
    #'   Set of properties of the optimizer.
    #'   Must be a subset of [`bbotk_reflections$optimizer_properties`][bbotk_reflections].
    #'
     #' @param packages (`character()`)\cr
    #'   Set of required packages.
    #'   A warning is signaled by the constructor if at least one of the packages is not installed, but loaded (not attached) later on-demand via [requireNamespace()].
    initialize = function(id = "optimizer", param_set, param_classes, properties, packages = character(), label = NA_character_, man = NA_character_) {
      self$id = assert_string(id, min.chars = 1L)
      private$.param_set = assert_param_set(param_set)
      private$.param_classes = assert_subset(param_classes, c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct", "ParamUty"))
      # has to have at least multi-crit or single-crit property
      private$.properties = assert_subset(properties, bbotk_reflections$optimizer_properties, empty.ok = FALSE)
      private$.packages = union("bbotk", assert_character(packages, any.missing = FALSE, min.chars = 1L))
      private$.label = assert_string(label, na.ok = TRUE)
      private$.man = assert_string(man, na.ok = TRUE)

      check_packages_installed(self$packages, msg = sprintf("Package '%%s' required but not installed for Optimizer '%s'", format(self)))
    },

    #' @description
    #' Helper for print outputs.
    #' @param ... (ignored).
    format = function(...) {
      sprintf("<%s>", class(self)[1L])
    },

    #' @description
    #' Print method.
    #'
    #' @return (`character()`).
    print = function() {
      catn(format(self), if (is.na(self$label)) "" else paste0(": ", self$label))
      catn(str_indent("* Parameters:", as_short_string(self$param_set$values)))
      catn(str_indent("* Parameter classes:", self$param_classes))
      catn(str_indent("* Properties:", self$properties))
      catn(str_indent("* Packages:", self$packages))
    },

    #' @description
    #' Opens the corresponding help page referenced by field `$man`.
    help = function() {
      open_help(self$man)
    },

    #' @description
    #' Performs the optimization and writes optimization result into
    #' [OptimInstance]. The optimization result is returned but the complete
    #' optimization path is stored in [Archive] of [OptimInstance].
    #'
    #' @param inst ([OptimInstance]).
    #' @return [data.table::data.table].
    optimize = function(inst) {
      inst$archive$start_time = Sys.time()
      inst$.__enclos_env__$private$.context = ContextOptimization$new(instance = inst, optimizer = self)
      call_back("on_optimization_begin", inst$callbacks, get_private(inst)$.context)
      result = optimize_default(inst, self, private)
      call_back("on_optimization_end", inst$callbacks, get_private(inst)$.context)
      result
    }
  ),

  active = list(

    param_set = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.param_set)) {
        stop("$param_set is read-only.")
      }
      private$.param_set
    },

    #' @field param_classes (`character()`)\cr
    #'   Supported parameter classes that the optimizer can optimize.
    #'   Subclasses of [paradox::Param].
    param_classes = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.param_classes)) {
        stop("$param_classes is read-only.")
      }
      private$.param_classes
    },

    #' @field properties (`character()`)\cr
    #'   Set of properties of the optimizer.
    #'   Must be a subset of [`bbotk_reflections$optimizer_properties`][bbotk_reflections].
    properties = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.properties)) {
        stop("$properties is read-only.")
      }
      private$.properties
    },

    #' @field packages (`character()`)\cr
    #'   Set of required packages.
    #'   A warning is signaled by the constructor if at least one of the packages is not installed, but loaded (not attached) later on-demand via [requireNamespace()].
    packages = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.packages)) {
        stop("$packages is read-only.")
      }
      private$.packages
    },

    label = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.label)) {
        stop("$label is read-only.")
      }
      private$.label
    },

    man = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.man)) {
        stop("$man is read-only.")
      }
      private$.man
    }
  ),

  private = list(
    .optimize = function(inst) stop("abstract"),

    .optimize_async = function(inst) stop("abstract"),

    .assign_result = function(inst) {
      assign_result_default(inst)
    },

    .param_set = NULL,
    .param_classes = NULL,
    .properties = NULL,
    .packages = NULL,
    .label = NULL,
    .man = NULL
  )
)

#' @title Default Optimization Function
#'
#' @description
#' Used internally in the [Optimizer].
#' Brings together the private `.optimize()` method and the private `.assign_result()` method.
#'
#' @param inst [OptimInstance]
#' @param self [Optimizer]
#' @param private (`environment()`)
#'
#' @return [data.table::data.table]
#'
#' @keywords internal
#' @export
optimize_default = function(inst, self, private) {
  UseMethod("optimize_default")
}

#' @rdname optimize_default
#' @export
optimize_default.OptimInstance = function(inst, self, private) {
  assert_instance_properties(self, inst)

  if (isNamespaceLoaded("progressr")) {
    # initialize progressor
    # progressor must be initialized here because progressor finishes when exiting a function since version 0.7.0
    max_steps = assert_int(inst$terminator$status(inst$archive)["max_steps"])
    unit = assert_character(inst$terminator$unit)
    progressor = progressr::progressor(steps = max_steps)
    inst$progressor = Progressor$new(progressor, unit)
    inst$progressor$max_steps = max_steps
  }

  # start optimization
  lg$info("Starting to optimize %i parameter(s) with '%s' and '%s'",
    inst$search_space$length, self$format(), inst$terminator$format(with_params = TRUE))
  tryCatch({
    private$.optimize(inst)
  }, terminated_error = function(cond) {
  })
  private$.assign_result(inst)
  lg$info("Finished optimizing after %i evaluation(s)", inst$archive$n_evals)
  lg$info("Result:")
  lg$info(capture.output(print(
    inst$result, lass = FALSE, row.names = FALSE, print.keys = FALSE)))
  return(inst$result)
}

#' @rdname optimize_default
#' @export
optimize_default.OptimInstanceRush = function(inst, self, private) {
  assert_instance_properties(self, inst)

  # decouple from instance
  objective = inst$objective
  search_space = inst$search_space

  if (rush_available()) {
    inst$rush$start_workers(
      worker_loop = bbotk_worker_loop_centralized,
      packages = "bbotk",
      objective = objective,
      search_space = search_space,
      wait_for_workers = TRUE)
  } else {
    stop("No rush plan available. See `?rush::rush_plan()`")
  }

  lg$info("Starting to optimize %i parameter(s) with '%s' and '%s' on %i worker(s)",
    inst$search_space$length,
    self$format(),
    inst$terminator$format(with_params = TRUE),
    inst$rush$n_running_workers
  )

  tryCatch({
    private$.optimize_async(inst)
  }, terminated_error = function(cond) {
  })

  # assign result
  private$.assign_result(inst)
  # if (get_private(inst)$.freeze_archive) inst$archive$freeze()
  lg$info("Finished optimizing after %i evaluation(s)", inst$archive$n_evals)
  lg$info("Result:")
  lg$info(capture.output(print(inst$result, lass = FALSE, row.names = FALSE, print.keys = FALSE)))
  return(inst$result)
}

#' @title Decentralized Optimization Function
#'
#' @description
#' Used internally in the [Optimizer].
#' Brings together the private `.optimize()` method and the private `.assign_result()` method.
#'
#' @param inst [OptimInstance]
#' @param self [Optimizer]
#' @param private (`environment()`)
#'
#' @return [data.table::data.table]
#'
#' @keywords internal
#' @export
optimize_decentralized = function(inst, self, private) {
  assert_class(inst, "OptimInstanceRush")

  if (!rush_available()) stop("No rush plan available. See `?rush::rush_plan()`")

  inst$archive$start_time = Sys.time()
  inst$.__enclos_env__$private$.context = ContextOptimization$new(instance = inst, optimizer = self)
  call_back("on_optimization_begin", inst$callbacks, get_private(inst)$.context)

  # FIXME: How to handle manual start of workers?
  # How to pass globals and packages?
  inst$rush$start_workers(
    worker_loop = bbotk_worker_loop_decentralized,
    packages = "bbotk",
    optimizer = self,
    instance = inst,
    wait_for_workers = TRUE)

  lg$info("Starting to optimize %i parameter(s) with '%s' and '%s' on %i worker(s)",
    inst$search_space$length,
    self$format(),
    inst$terminator$format(with_params = TRUE),
    inst$rush$n_running_workers
  )

  # wait until optimization is finished
  while(!inst$is_terminated) {
    Sys.sleep(1)
    inst$rush$print_log()
    inst$rush$detect_lost_workers()

    # fetch new results for printing
    new_results = inst$rush$fetch_new_tasks()
    if (nrow(new_results)) {
      lg$info("Results of %i configuration(s):", nrow(new_results))
      lg$info(capture.output(print(new_results, class = FALSE, row.names = FALSE, print.keys = FALSE)))
    }

    if (!inst$is_terminated && inst$rush$n_running_workers == 0) {
      stop("All workers have crashed.")
    }
  }

  # assign result
  private$.assign_result(inst)

  # assign result
  private$.assign_result(inst)
  lg$info("Finished optimizing after %i evaluation(s)", inst$archive$n_evals)
  lg$info("Result:")
  lg$info(capture.output(print(inst$result, lass = FALSE, row.names = FALSE, print.keys = FALSE)))

  call_back("on_optimization_end", inst$callbacks, get_private(inst)$.context)
  return(inst$result)
}

#' @title Default Assign Result Function
#'
#' @description
#' Used internally in the [Optimizer].
#' It is the default way to determine the result by simply obtaining the best performing result from the archive.
#'
#' @param inst [OptimInstance]
#'
#' @keywords internal
#' @export
assign_result_default = function(inst) {
  UseMethod("assign_result_default")
}

#' @rdname assign_result_default
#' @export
assign_result_default.OptimInstance = function(inst) {
  assert_r6(inst, "OptimInstance")
  res = inst$archive$best()

  xdt = res[, inst$search_space$ids(), with = FALSE]

  if (inherits(inst, "OptimInstanceMultiCrit")) {
    ydt = res[, inst$archive$cols_y, with = FALSE]
    inst$assign_result(xdt, ydt)
  } else {
    # unlist keeps name!
    y = unlist(res[, inst$archive$cols_y, with = FALSE])
    inst$assign_result(xdt, y)
  }

  invisible(NULL)
}

#' @rdname assign_result_default
#' @export
assign_result_default.OptimInstanceRush = function(inst) {

  if (!inst$archive$n_evals) {
    stopf("Can't assign result to %s.\n %s doesn't contain any results. \n Probably the workers have crashed.", format(inst), format(inst$archive))
  }

  res = inst$archive$best()
  xdt = res[, inst$search_space$ids(), with = FALSE]

  if (inherits(inst, "OptimInstanceMultiCrit")) {
    ydt = res[, inst$archive$cols_y, with = FALSE]
    get_private(inst)$.assign_result(xdt, ydt)
  } else {
    # unlist keeps name!
    y = unlist(res[, inst$archive$cols_y, with = FALSE])
    get_private(inst)$.assign_result(xdt, y)
  }

  invisible(NULL)
}
