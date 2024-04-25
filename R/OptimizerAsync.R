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
  )
)

#' @title Default Asynchronous Optimization
#'
#' @description
#' Used internally in [OptimizerAsync].
#'
#' @param instance [OptimInstanceAsync].
#' @param optimizer [OptimizerAsync].
#'
#' @keywords internal
#' @export
optimize_async_default = function(instance, optimizer, design = NULL) {
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
    rush = RushWorker$new(instance$rush$network_id, host = "local")
    instance$rush = rush
    instance$archive$rush = rush
    private$.optimize(instance)
  } else {
    # run .optimize() on workers

    # check if there are already running workers or a rush plan is available
    if (!instance$rush$n_running_workers && !rush_available()) {
      stop("No running worker found and no rush plan available to start local workers.\n See `?rush::rush_plan()`")
    }

    # FIXME: How to pass globals and packages?
    if (!instance$rush$n_running_workers) {
      lg$debug("Start %i local worker(s)", rush_config()$n_workers)

      packages = c(optimizer$packages, "bbotk") # add packages from objective

      instance$rush$start_workers(
        worker_loop = bbotk_worker_loop,
        packages = packages,
        optimizer = optimizer,
        instance = instance,
        wait_for_workers = TRUE)
    }

    lg$info("Starting to optimize %i parameter(s) with '%s' and '%s' on %i worker(s)",
      instance$search_space$length,
      optimizer$format(),
      instance$terminator$format(with_params = TRUE),
      instance$rush$n_running_workers
    )
  }

  # wait until optimization is finished
  # check for number of evaluations when the terminator is "none"
  while(!instance$is_terminated && instance$archive$n_evals < nrow(design) %??% Inf) {
    Sys.sleep(1)
    instance$rush$print_log()

    # fetch new results for printing
    new_results = instance$rush$fetch_new_tasks()
    if (nrow(new_results)) {
      lg$info("Results of %i configuration(s):", nrow(new_results))
      lg$info(capture.output(print(new_results, class = FALSE, row.names = FALSE, print.keys = FALSE)))
    }

    if (instance$rush$all_workers_lost) {
      stop("All workers have crashed.")
    }
  }

  # assign result
  get_private(optimizer)$.assign_result(instance)
  lg$info("Finished optimizing after %i evaluation(s)", instance$archive$n_evals)
  lg$info("Result:")
  lg$info(capture.output(print(instance$result, lass = FALSE, row.names = FALSE, print.keys = FALSE)))

  call_back("on_optimization_end", instance$objective$callbacks, instance$objective$context)
  return(instance$result)
}

#' @title Default Evaluation of the Queue
#'
#' @description
#' Used internally in `$.optimize()` of [OptimizerAsync] classes to evaluate a queue of points e.g. in [OptimizerAsyncGridSearch].
#'
#' @param instance [OptimInstanceAsync].
#' @param optimizer [OptimizerAsync].
#'
#' @keywords internal
#' @export
evaluate_queue_default = function(instance) {
  while (!instance$is_terminated && instance$archive$n_queued) {
    task = instance$archive$pop_point() # FIXME: Add fields argument?
      if (!is.null(task)) {
      xs_trafoed = trafo_xs(task$xs, instance$search_space)
      ys = instance$objective$eval(xs_trafoed)
      instance$archive$push_result(task$key, ys, x_domain = xs_trafoed)
    }
  }
}
