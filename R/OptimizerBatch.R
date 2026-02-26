#' @title Batch Optimizer
#'
#' @include mlr_optimizers.R
#'
#' @description
#' Abstract `OptimizerBatch` class that implements the base functionality each `OptimizerBatch` subclass must provide.
#' A `OptimizerBatch` object describes the optimization strategy.
#' A `OptimizerBatch` object must write its result to the `$assign_result()` method of the [OptimInstance] at the end in order to store the best point and its estimated performance vector.
#'
#' @template section_progress_bars
#'
#' @seealso [OptimizerBatchDesignPoints], [OptimizerBatchGridSearch], [OptimizerBatchRandomSearch]
#' @export
OptimizerBatch = R6Class("OptimizerBatch",
  inherit = Optimizer,

  public = list(

    #' @description
    #' Performs the optimization and writes optimization result into [OptimInstanceBatch].
    #' The optimization result is returned but the complete optimization path is stored in [ArchiveBatch] of [OptimInstanceBatch].
    #'
    #' @param inst ([OptimInstanceBatch]).
    #' @return [data.table::data.table].
    optimize = function(inst) {
      optimize_batch_default(inst, self)
    }
  )
)
#' @title Default Batch Optimization Function
#'
#' @description
#' Used internally in the [OptimizerBatch].
#'
#' @param instance [OptimInstance]
#' @param optimizer [OptimizerBatch]
#'
#' @return [data.table::data.table]
#'
#' @keywords internal
#' @export
optimize_batch_default = function(instance, optimizer) {
  assert_instance_properties(optimizer, instance)

  instance$archive$start_time = Sys.time()
  get_private(instance)$.initialize_context(optimizer)
  call_back("on_optimization_begin", instance$objective$callbacks, instance$objective$context)

  if (isNamespaceLoaded("progressr")) {
    # progressor must be initialized here because progressor finishes when exiting a function since version 0.7.0
    max_steps = assert_int(instance$terminator$status(instance$archive)["max_steps"])
    unit = assert_character(instance$terminator$unit)
    progressor = progressr::progressor(steps = max_steps)
    instance$progressor = Progressor$new(progressor, unit)
    instance$progressor$max_steps = max_steps
  }

  # start optimization
  lg$info("Starting to optimize %i parameter(s) with '%s' and '%s'",
    instance$search_space$length, optimizer$format(), instance$terminator$format(with_params = TRUE))
  tryCatch({
    get_private(optimizer)$.optimize(instance)
  }, Mlr3ErrorBbotkTerminated = function(cond) {})

  # assign result
  get_private(optimizer)$.assign_result(instance)
  lg$info("Finished optimizing after %i evaluation(s)", instance$archive$n_evals)
  lg$info("Result:")
  lg$info(capture.output(print(
    instance$result, lass = FALSE, row.names = FALSE, print.keys = FALSE)))
  call_back("on_optimization_end", instance$objective$callbacks, instance$objective$context)
  return(instance$result)
}

