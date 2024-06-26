#' @title Worker loop for Rush
#'
#' @description
#' Loop run on the workers.
#' Pops a task from the queue and evaluates it with the objective function.
#' Pushes the results back to the data base.
#'
#' @template param_rush
#'
#' @param optimizer [OptimizerAsync].
#' @param instance [OptimInstanceAsync].
#'
#' @keywords internal
#' @export
bbotk_worker_loop = function(rush, optimizer, instance) {
  # replace controller with worker
  instance$rush = rush
  instance$archive$rush = rush

  call_back("on_worker_begin", instance$objective$callbacks, instance$objective$context)

  # run optimizer loop
  get_private(optimizer)$.optimize(instance)

  call_back("on_worker_end", instance$objective$callbacks, instance$objective$context)

  return(NULL)
}
