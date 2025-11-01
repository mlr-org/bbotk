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
#' @section Optimization:
#' The [rush::rush_plan(n_workers, worker_type)] function defines the number of workers and their type.
#' There are three types of workers:
#'
#' - "local": Workers are started as local processes with \CRANpkg{processx}.
#'   See `$start_local_workers()` in [Rush] for more details.
#' - "remote": Workers are started with \CRANpkg{mirai} on local or remote machines.
#'   [mirai::daemons()] must be created before starting the optimization.
#'   See `$start_remote_workers()` in [Rush] for more details.
#' - "script": Workers are started by the user with a custom script.
#'   See `$create_worker_script()` in [Rush] for more details.
#'
#' The workers are started when the `$optimize()` method is called.
#' The main process waits until at least one worker is running.
#' The optimization starts directly after the workers are running.
#' The main process prints the evaluation results and other log messages from the workers.
#' The optimization is terminated when the terminator criterion is satisfied.
#' The result is assigned to the [OptimInstanceAsync] field.
#' The main loop periodically checks the status of the workers.
#' If all workers crash the optimization is terminated.
#'
#' @section Debug Mode:
#' The debug mode runs the optimization loop in the main process.
#' This is useful for debugging the optimization algorithm.
#' The debug mode is enabled by setting `options(bbotk.debug = TRUE)`.
#'
#' @section Tiny Logging:
#' The tiny logging mode is enabled by setting the option `bbotk.tiny_logging` to `TRUE`.
#' In the tiny logging mode, the evaluated points are printed in a compact format and the currently best performing point is shown.
#' Deactivated depending parameters are not printed.
#'
#' @seealso [OptimizerAsyncDesignPoints], [OptimizerAsyncGridSearch], [OptimizerAsyncRandomSearch]
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

      rush$wait_for_workers(n = 1)
    } else if (worker_type == "remote") {
      # remote workers
      worker_ids = rush$start_remote_workers(
        n_workers = n_workers,
        worker_loop = bbotk_worker_loop,
        packages = c(optimizer$packages, instance$objective$packages, "bbotk"),
        optimizer = optimizer,
        instance = instance)

      rush$wait_for_workers(n = 1, worker_ids)
    } else if (worker_type == "local") {
      # local workers
      worker_ids = rush$start_local_workers(
        n_workers = n_workers,
        worker_loop = bbotk_worker_loop,
        packages = c(optimizer$packages, instance$objective$packages, "bbotk"),
        optimizer = optimizer,
        instance = instance)

      rush$wait_for_workers(n = 1, worker_ids)
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
  while (!instance$is_terminated) {
    Sys.sleep(1)

    if (rush$n_running_workers > n_running_workers) {
      n_running_workers = rush$n_running_workers
      lg$info("%i worker(s) running", n_running_workers)
    }

    # print logger messages from workers
    rush$print_log()

    # print evaluations
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

    rush$detect_lost_workers()

    if (!rush$n_running_workers) {
      lg$info("All workers have terminated.")
      break
    }
  }

  # move queued and running tasks to failed
  failed_tasks = unlist(rush$tasks_with_state(states = c("queued", "running")))
  if (length(failed_tasks)) {
    rush$push_failed(failed_tasks, conditions = replicate(length(failed_tasks), list(message = "Optimization terminated"), simplify = FALSE))
  }

  if (!instance$archive$n_finished) {
    stopf("Optimization terminated without any finished evaluations.")
  }

  # assign result
  get_private(optimizer)$.assign_result(instance)
  lg$info("Finished optimizing after %i evaluation(s)", instance$rush$n_finished_tasks)
  lg$info("Result:")

  # print result
  if (getOption("bbotk.tiny_logging", FALSE)) {
    tiny_result(instance, optimizer)
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
#' @examples
#' options(bbotk.tiny_logging = TRUE)
tiny_logging = function(instance, optimizer) {
  UseMethod("tiny_logging")
}

#' @export
tiny_logging.OptimInstanceAsync = function(instance, optimizer) {
  new_results = instance$rush$fetch_new_tasks()

  if (nrow(new_results)) {
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
        # works for single and multi-criterion
        paste0(map_chr(seq_row(best), function(i) as_short_string(keep(as.list(best[i, instance$archive$cols_y, with = FALSE]), function(x) !is.na(x)))), collapse = " & ")
      )
    }
  }
}

#' @title Tiny Result
#'
#' @description
#' Used internally in [OptimizerAsync].
#' Adapts tiny result to the different instance types.
#'
#' @param instance [OptimInstanceAsync].
#' @param optimizer [OptimizerAsync].
#' @keywords internal
#' @export
#' @examples
#' options(bbotk.tiny_logging = TRUE)
tiny_result = function(instance, optimizer) {
  UseMethod("tiny_result")
}

#' @export
tiny_result.OptimInstanceAsync = function(instance, optimizer) {
  for (i in seq_row(instance$result)) {
    lg$info(as_short_string(keep(as.list(instance$result[i, c(instance$archive$cols_y, instance$archive$cols_x), with = FALSE]), function(x) !is.na(x))))
  }
}

