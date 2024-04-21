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
#' @export
OptimizerBatch = R6Class("OptimizerBatch",
  inherit = Optimizer,

  public = list(

    #' @description
    #' Performs the optimization and writes optimization result into
    #' [OptimInstance]. The optimization result is returned but the complete
    #' optimization path is stored in [Archive] of [OptimInstance].
    #'
    #' @param inst ([OptimInstance]).
    #' @return [data.table::data.table].
    optimize = function(inst) {
      # start optimization
      start_optimize_batch_bbotk(inst, self)

      # run optimization
      run_optimize_batch_bbotk(inst, self)

      # finish optimization
      finish_optimize_batch_bbotk(inst)
    }
  )
)

#' @keywords internal
#' @export
start_optimize_batch_bbotk = function(inst, optimizer) {
  assert_instance_properties(optimizer, inst)

  inst$archive$start_time = Sys.time()
  inst$.__enclos_env__$private$.context = ContextOptimization$new(instance = inst, optimizer = optimizer)
  call_back("on_optimization_begin", inst$callbacks, get_private(inst)$.context)
}

#' @keywords internal
#' @export
run_optimize_batch_bbotk = function(inst, optimizer) {
  if (isNamespaceLoaded("progressr")) {
    # progressor must be initialized here because progressor finishes when exiting a function since version 0.7.0
    max_steps = assert_int(inst$terminator$status(inst$archive)["max_steps"])
    unit = assert_character(inst$terminator$unit)
    progressor = progressr::progressor(steps = max_steps)
    inst$progressor = Progressor$new(progressor, unit)
    inst$progressor$max_steps = max_steps
  }

  lg$info("Starting to optimize %i parameter(s) with '%s' and '%s'",
    inst$search_space$length, optimizer$format(), inst$terminator$format(with_params = TRUE))
  tryCatch({
    get_private(optimizer)$.optimize(inst)
  }, terminated_error = function(cond) {})
}

#' @keywords internal
#' @export
finish_optimize_batch_bbotk = function(inst) {
  private$.assign_result(inst)
  lg$info("Finished optimizing after %i evaluation(s)", inst$archive$n_evals)
  lg$info("Result:")
  lg$info(capture.output(print(
    inst$result, lass = FALSE, row.names = FALSE, print.keys = FALSE)))
  return(inst$result)
}

#' @title Default Batch Optimization Function
#'
#' @description
#' Used internally in the [OptimizerBatch].
#' Brings together the private `.optimize()` method and the private `.assign_result()` method.
#'
#' @param inst [OptimInstance]
#' @param self [OptimizerBatch]
#' @param private (`environment()`)
#'
#' @return [data.table::data.table]
#'
#' @keywords internal
#' @export
optimize_batch_default = function(inst, self, private) {
  assert_instance_properties(self, inst)

  inst$archive$start_time = Sys.time()
  inst$.__enclos_env__$private$.context = ContextOptimization$new(instance = inst, optimizer = self)
  call_back("on_optimization_begin", inst$callbacks, get_private(inst)$.context)

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

  # assign result
  private$.assign_result(inst)
  lg$info("Finished optimizing after %i evaluation(s)", inst$archive$n_evals)
  lg$info("Result:")
  lg$info(capture.output(print(
    inst$result, lass = FALSE, row.names = FALSE, print.keys = FALSE)))
  return(inst$result)
}

