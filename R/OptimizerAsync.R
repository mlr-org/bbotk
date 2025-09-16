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
#' @export
OptimizerAsync = R6Class("OptimizerAsync",
  inherit = Optimizer,
  public = list(

    #' @description
    #' Performs the optimization on a [OptimInstanceAsyncSingleCrit] or [OptimInstanceAsyncMultiCrit] until termination.
    #' The single evaluations will be written into the [ArchiveAsync].
    #' The result will be written into the instance object.
    #'
    #' @param inst ([OptimInstanceAsyncSingleCrit] | [OptimInstanceAsyncMultiCrit]).
    #'
    #' @return [data.table::data.table()]
    optimize = function(inst) {
      optimize_async_default(inst, self)
    }
  ),

  private = list(
    .xdt = NULL,
    .ys = NULL
  )
)

#' @title Default Asynchronous Optimization
#'
#' @description
#' Used internally in [OptimizerAsync].
#'
#' @param instance [OptimInstanceAsync].
#' @param optimizer [OptimizerAsync].
#' @param design [data.table::data.table()]\cr
#' (Initial) design send to the queue.
#' @param n_workers
#' Number of workers to be started.
#' Defaults to the number of workers set by [rush::rush_plan()].
#' @keywords internal
#' @export
optimize_async_default = function(instance, optimizer, design = NULL, n_workers = NULL) {
  assert_data_table(design, null.ok = TRUE)

  instance$archive$start_time = Sys.time()
  get_private(instance)$.initialize_context(optimizer)
  call_back("on_optimization_begin", instance$objective$callbacks, instance$objective$context)

  # send design to workers
  if (!is.null(design)) instance$archive$push_points(transpose_list(design))

  if (getOption("bbotk.debug", FALSE)) {
    # debug mode runs .optimize() in main process
    rush = rush::RushWorker$new(instance$rush$network_id, remote = FALSE)
    instance$rush = rush
    instance$archive$rush = rush
    worker_type = "debug_local"

    call_back("on_worker_begin", instance$objective$callbacks, instance$objective$context)

    # run optimizer loop
    get_private(optimizer)$.optimize(instance)

    call_back("on_worker_end", instance$objective$callbacks, instance$objective$context)
  } else {
    # run .optimize() on workers
    rush = instance$rush
    worker_type = rush::rush_config()$worker_type %??% "local"

    if (worker_type == "script") {
      # worker script
      rush$worker_script(
        worker_loop = bbotk_worker_loop,
        packages = c(optimizer$packages, instance$objective$packages, "bbotk"),
        optimizer = optimizer,
        instance = instance)
    } else if (worker_type == "remote") {
      # remote workers
      rush$start_remote_workers(
        n_workers = n_workers,
        worker_loop = bbotk_worker_loop,
        packages = c(optimizer$packages, instance$objective$packages, "bbotk"),
        optimizer = optimizer,
        instance = instance)
    } else if (worker_type == "local") {
      # local workers
      rush$start_local_workers(
        n_workers = n_workers,
        worker_loop = bbotk_worker_loop,
        packages = c(optimizer$packages, instance$objective$packages, "bbotk"),
        optimizer = optimizer,
        instance = instance)
    }
  }

  lg$info("Starting to optimize %i parameter(s) with '%s' and '%s' on %s %s worker(s)",
    instance$search_space$length,
    optimizer$format(),
    instance$terminator$format(with_params = TRUE),
    as.character(rush::rush_config()$n_workers %??% ""),
    worker_type)

  n_running_workers = 0
  # wait until optimization is finished
  # check terminated workers when the terminator is "none"
  while(TRUE) {
    Sys.sleep(1)

    if (rush$n_running_workers > n_running_workers) {
      n_running_workers = rush$n_running_workers
      lg$info("%i worker(s) started", n_running_workers)
    }

    instance$rush$print_log()

    if (getOption("bbotk.tiny_logging", FALSE)) {
      tiny_logging(instance, optimizer)
    } else {
      new_results = instance$rush$fetch_new_tasks()

      if (nrow(new_results)) {
        lg$info("Results of %i configuration(s):", nrow(new_results))
        setcolorder(new_results, c(instance$archive$cols_y, instance$archive$cols_x, "timestamp_xs", "timestamp_ys"))
        cns = setdiff(colnames(new_results), c("pid", "x_domain", "keys"))
        lg$info(capture.output(print(new_results[, cns, with = FALSE], class = FALSE, row.names = FALSE, print.keys = FALSE)))
      }
    }

    if (instance$rush$all_workers_lost && !instance$is_terminated && !instance$rush$all_workers_terminated) {
      stop("All workers have crashed.")
    }

    if (instance$is_terminated) break
    if (instance$rush$all_workers_terminated) {
      lg$info("All workers have terminated.")
      break
    }
  }

  # assign result
  get_private(optimizer)$.assign_result(instance)
  lg$info("Finished optimizing after %i evaluation(s)", instance$archive$n_evals)
  lg$info("Result:")

  if (getOption("bbotk.tiny_logging", FALSE)) {
    for (i in seq_row(instance$result)) {
      lg$info(as_short_string(keep(as.list(instance$result[i, c(instance$archive$cols_y, instance$archive$cols_x), with = FALSE]), function(x) !is.na(x))))
    }
  } else {
    lg$info(capture.output(print(instance$result, class = FALSE, row.names = FALSE, print.keys = FALSE)))
  }

  call_back("on_optimization_end", instance$objective$callbacks, instance$objective$context)
  instance$rush$stop_workers(type = "kill")
  return(instance$result)
}

#' @title Tiny Logging
#'
#' @description
#' Used internally in [OptimizerAsync].
#' Adapts tiny logging to the different instance types.
#'
#' @param instance [OptimInstanceAsync].
#' @param optimizer [OptimizerAsync].
#' @keywords internal
#'
#' @export
tiny_logging = function(instance, optimizer) {
  UseMethod("tiny_logging")
}

#' @export
tiny_logging.OptimInstanceAsync = function(instance, optimizer) {
  new_results = instance$rush$fetch_new_tasks()
  task_keys = instance$rush$tasks
  ids = which(task_keys %in% new_results$keys)
  best = instance$archive$best()
  best_ids = which(task_keys %in% best$keys)

  cns = intersect(c(instance$archive$cols_y, instance$archive$cols_x), colnames(new_results))

  for (i in seq_row(new_results)) {
    lg$info("Evaluation %i: %s (Current best %s: %s)",
      ids[i],
      as_short_string(keep(as.list(new_results[i, cns, with = FALSE]), function(x) !is.na(x))),
      as_short_string(best_ids),
      as_short_string(keep(as.list(best[, instance$archive$cols_y, with = FALSE]), function(x) !is.na(x)))
    )
  }
}

#' @export
tiny_logging.TuningInstanceAsync = function(instance, optimizer) {
  new_results = instance$rush$fetch_new_tasks()
  task_keys = instance$rush$tasks
  ids = which(task_keys %in% new_results$keys)
  best = instance$archive$best()
  best_ids = which(task_keys %in% best$keys)

  cns = intersect(c(instance$archive$cols_y, instance$archive$cols_x, "runtime_learners", "warnings", "errors"), colnames(new_results))

  # unnest internal_tuned_values
  if ("internal_tuned_values" %in% colnames(new_results)) {
    cns = c(cns, names(new_results$internal_tuned_values[[1]]))
    new_results = unnest(new_results, "internal_tuned_values")
  }

  for (i in seq_row(new_results)) {
    lg$info("Evaluation %i: %s (Current best %s: %s)",
      ids[i],
      as_short_string(keep(as.list(new_results[i, cns, with = FALSE]), function(x) !is.na(x))),
      as_short_string(best_ids),
      as_short_string(keep(as.list(best[, instance$archive$cols_y, with = FALSE]), function(x) !is.na(x)))
    )
  }
}
