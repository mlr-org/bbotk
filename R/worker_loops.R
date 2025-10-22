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

  require_namespaces(instance$objective$packages)

  # reduce number of threads to 1
  old_dt = data.table::getDTthreads()
  on.exit(data.table::setDTthreads(old_dt), add = TRUE)
  data.table::setDTthreads(1, restore_after_fork = TRUE)

  # RhpcBLASctl is licensed under AGPL and therefore should be in suggest
  if (require_namespaces("RhpcBLASctl", quietly = TRUE)) {
    old_blas_threads = RhpcBLASctl::blas_get_num_procs()
    on.exit(RhpcBLASctl::blas_set_num_threads(old_blas_threads), add = TRUE)
    RhpcBLASctl::blas_set_num_threads(1)
  } else { # try the bare minimum to disable threading of the most popular blas implementations
    old_blas = Sys.getenv("OPENBLAS_NUM_THREADS")
    old_mkl = Sys.getenv("MKL_NUM_THREADS")
    Sys.setenv(OPENBLAS_NUM_THREADS = 1)
    Sys.setenv(MKL_NUM_THREADS = 1)

    on.exit({
      Sys.setenv(OPENBLAS_NUM_THREADS = old_blas)
      Sys.setenv(MKL_NUM_THREADS = old_mkl)
    }, add = TRUE)
  }

  call_back("on_worker_begin", instance$objective$callbacks, instance$objective$context)

  # run optimizer loop
  get_private(optimizer)$.optimize(instance)

  call_back("on_worker_end", instance$objective$callbacks, instance$objective$context)

  return(NULL)
}
