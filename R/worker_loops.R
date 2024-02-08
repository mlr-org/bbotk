#' @title Worker loop for Rush
#'
#' @description
#' Loop run on the workers.
#' Pops a task from the queue and evaluates it with the objective function.
#' Pushes the results back to the data base.
#'
#' @template param_rush
#' @template param_objective
#' @template param_search_space
#'
#' @export
bbotk_worker_loop_centralized = function(rush, objective, search_space) {
  while(!rush$terminated) {
    task = rush$pop_task(fields = c("xs", "seed"))
    xs_trafoed = trafo_xs(task$xs, search_space)

    if (!is.null(task)) {
      tryCatch({
        ys = with_rng_state(objective$eval, args = list(xs = xs_trafoed), seed = task$seed)
        rush$push_results(task$key, yss = list(ys), extra = list(list(x_domain = list(xs_trafoed), timestamp_ys = Sys.time())))
      }, error = function(e) {
        condition = list(message = e$message)
        rush$push_failed(task$key, conditions = list(condition))
      })
    }
  }
  return(NULL)
}

#' @export
bbotk_worker_loop_decentralized = function(rush, optimizer, instance) {
  # replace controller with worker
  instance$rush = rush
  instance$archive$rush = rush

  # run optimizer loop
  get_private(optimizer)$.optimize_remote(instance)

  return(NULL)
}
