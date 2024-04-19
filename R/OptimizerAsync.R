#' @title Asynchronous Optimizer
#'
#' @include mlr_optimizers.R
#'
#' @description
#' The [OptimizerAsync] implements the asynchronous optimization algorithm.
#' The optimization is performed asynchronously on a set of workers.
#'
#' @details
#' [OptimizerAsync] is the abstract base class for all asynchronous optimizers.
#' It provides the basic structure for asynchronous optimization algorithms.
#' The public method `$optimize()` is the main entry point for the optimization and runs in the main process.
#' The method starts the optimization process by starting the workers and pushing the necessary objects to the workers.
#' Optionally, a set of points can be created, e.g. an initial design, and pushed to the workers.
#' The private method `$.optimize()` is the actual optimization algorithm that runs on the workers.
#' Usually, the method proposes new points, evaluates them, and updates the archive.
#'
#' @template field_id
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
OptimizerAsync = R6Class("OptimizerAsync",
  public = list(

    id = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param param_classes (`character()`)\cr
    #'  Supported parameter classes that the optimizer can optimize.
    #'
    #' @param properties (`character()`)\cr
    #'  Set of properties of the optimizer.
    #'  Must be a subset of [`bbotk_reflections$optimizer_properties`][bbotk_reflections].
    #'
    #' @param packages (`character()`)\cr
    #'  Set of required packages.
    #'  A warning is signaled by the constructor if at least one of the packages is not installed, but loaded (not attached) later on-demand via [requireNamespace()].
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
    #' Starts the asynchronous optimization.
    #'
    #' @param inst ([OptimInstance]).
    #' @return [data.table::data.table].
    optimize = function(inst) {
      stop("abstract")
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
    #'   Supported parameter classes that the optimizer can optimize, as given in the [`paradox::ParamSet`] `$class` field.
    param_classes = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.param_classes)) {
        stop("$param_classes is read-only.")
      }
      private$.param_classes
    },

    #' @field properties (`character()`)\cr
    #'  Set of properties of the optimizer.
    #'  Must be a subset of [`bbotk_reflections$optimizer_properties`][bbotk_reflections].
    properties = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.properties)) {
        stop("$properties is read-only.")
      }
      private$.properties
    },

    #' @field packages (`character()`)\cr
    #'  Set of required packages.
    #'  A warning is signaled by the constructor if at least one of the packages is not installed, but loaded (not attached) later on-demand via [requireNamespace()].
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

    # runs asynchronously on the workers
    .optimize = function(inst) {
      stop("abstract")
    },

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

#' @title Start Decentralized Optimization
#'
#' @description
#' Used internally in [OptimizerAsync].
#' Starts the workers and pushes the necessary objects to the workers.
#'
#' @param inst [OptimInstance]
#' @param self [Optimizer]
#' @param private (`environment()`)
#'
#' @keywords internal
#' @export
start_async_optimize = function(inst, self, private) {
  assert_class(inst, "OptimInstanceAsync")

  inst$archive$start_time = Sys.time()
  inst$.__enclos_env__$private$.context = ContextOptimization$new(instance = inst, optimizer = self)
  call_back("on_optimization_begin", inst$callbacks, get_private(inst)$.context)

  if (getOption("bbotk_local", FALSE)) {
    # debug mode runs .optimize() in main process
    rush = RushWorker$new(inst$rush$network_id, host = "local")
    inst$rush = rush
    inst$archive$rush = rush
    private$.optimize(inst)
  } else {
    # run .optimize() on workers

    # check if there are already running workers or a rush plan is available
    if (!inst$rush$n_running_workers && !rush_available()) {
      stop("No running worker found and no rush plan available to start local workers.\n See `?rush::rush_plan()`")
    }

    # FIXME: How to pass globals and packages?
    if (!inst$rush$n_running_workers) {
      lg$debug("Start %i local worker(s)", rush_config()$n_workers)

      packages = c(self$packages, "bbotk") # add packages from objective

      inst$rush$start_workers(
        worker_loop = bbotk_worker_loop,
        packages = packages,
        optimizer = self,
        instance = inst,
        wait_for_workers = TRUE)
    }

    lg$info("Starting to optimize %i parameter(s) with '%s' and '%s' on %i worker(s)",
      inst$search_space$length,
      self$format(),
      inst$terminator$format(with_params = TRUE),
      inst$rush$n_running_workers
    )
  }
}

#' @title Wait for Decentralized Optimization
#'
#' @description
#' Used internally in [OptimizerAsync].
#' Waits until optimization is finished.
#' Prints log messages from the workers and checks for errors.
#'
#' @param inst [OptimInstance]
#' @param self [Optimizer]
#' @param private (`environment()`)
#' @param n_evals (`integer(1)`)\cr
#'  Number of evaluations to wait for.
#'  Default is `Inf`.
#'  Needed for `"none"` termination.
#'
#' @keywords internal
#' @export
wait_for_async_optimize = function(inst, self, private, n_evals = Inf) {
  # wait until optimization is finished

  while(!inst$is_terminated && inst$archive$n_evals < n_evals) {
    Sys.sleep(1)
    inst$rush$print_log()

    # fetch new results for printing
    new_results = inst$rush$fetch_new_tasks()
    if (nrow(new_results)) {
      lg$info("Results of %i configuration(s):", nrow(new_results))
      lg$info(capture.output(print(new_results, class = FALSE, row.names = FALSE, print.keys = FALSE)))
    }

    if (inst$rush$all_workers_lost) {
      stop("All workers have crashed.")
    }
  }
}

#' @title Wait for Decentralized Optimization
#'
#' @description
#' Used internally in [OptimizerAsync].
#' Waits until optimization is finished.
#' Prints log messages from the workers and checks for errors.
#'
#' @param inst [OptimInstance]
#' @param self [Optimizer]
#' @param private (`environment()`)
#'
#' @keywords internal
#' @export
finish_async_optimize = function(inst, self, private) {
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
