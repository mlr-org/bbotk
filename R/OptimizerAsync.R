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
  assert_class(instance, "OptimInstanceAsync")
  assert_class(optimizer, "OptimizerAsync")
  assert_data_table(design, null.ok = TRUE)

  instance$archive$start_time = Sys.time()
  get_private(instance)$.initialize_context(optimizer)
  call_back("on_optimization_begin", instance$objective$callbacks, instance$objective$context)

  # send design to workers
  if (!is.null(design)) instance$archive$push_points(transpose_list(design))

  if (getOption("bbotk_local", FALSE)) {
    # debug mode runs .optimize() in main process
    rush = rush::RushWorker$new(instance$rush$network_id, remote = FALSE)
    instance$rush = rush
    instance$archive$rush = rush

    call_back("on_worker_begin", instance$objective$callbacks, instance$objective$context)

    # run optimizer loop
    get_private(optimizer)$.optimize(instance)

    call_back("on_worker_end", instance$objective$callbacks, instance$objective$context)
  } else {
    # run .optimize() on workers
    rush = instance$rush

    # FIXME: How to pass globals and packages?
    if (rush$n_pre_workers) {
      # start remote workers
      lg$info("Starting to optimize %i parameter(s) with '%s' and '%s' on %i remote worker(s)",
        instance$search_space$length,
        optimizer$format(),
        instance$terminator$format(with_params = TRUE),
        rush$n_pre_workers
      )

      rush$start_remote_workers(
        worker_loop = bbotk_worker_loop,
        packages = c(optimizer$packages, "bbotk"), # add packages from objective
        optimizer = optimizer,
        instance = instance)
    } else if (rush::rush_available()) {
      # local workers
      lg$info("Starting to optimize %i parameter(s) with '%s' and '%s' on %i remote worker(s)",
        instance$search_space$length,
        optimizer$format(),
        instance$terminator$format(with_params = TRUE),
        rush::rush_config()$n_workers
      )

      rush$start_local_workers(
        worker_loop = bbotk_worker_loop,
        packages = c(optimizer$packages, "bbotk"), # add packages from objective
        optimizer = optimizer,
        instance = instance,
        wait_for_workers = TRUE)
    } else {
       stop("No rush plan available to start local workers and no pre-started remote workers found. See `?rush::rush_plan()`.")
    }
  }

  # wait until optimization is finished
  # check terminated workers when the terminator is "none"
  while(TRUE) {
    Sys.sleep(1)
    instance$rush$print_log()

    # fetch new results for printing
    new_results = instance$rush$fetch_new_tasks()
    if (nrow(new_results)) {
      lg$info("Results of %i configuration(s):", nrow(new_results))
      lg$info(capture.output(print(new_results, class = FALSE, row.names = FALSE, print.keys = FALSE)))
    }

    if (instance$rush$all_workers_lost && !instance$is_terminated && !instance$rush$all_workers_terminated) {
      stop("All workers have crashed.")
    }

    if (instance$is_terminated) break
    if (instance$rush$all_workers_terminated) break
  }

  # assign result
  get_private(optimizer)$.assign_result(instance)
  lg$info("Finished optimizing after %i evaluation(s)", instance$archive$n_evals)
  lg$info("Result:")
  lg$info(capture.output(print(instance$result, lass = FALSE, row.names = FALSE, print.keys = FALSE)))

  call_back("on_optimization_end", instance$objective$callbacks, instance$objective$context)
  return(instance$result)
}
