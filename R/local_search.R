#' @title Local Search Control
#' @description Control parameters for local search optimizer
#' @param n_searches [integer(1)]
#'   Number of local searches.
#' @param n_steps [integer(1)]
#'   Number of steps per local search.
#' @param n_neighs [integer(1)]
#'   Number of neighbors per local search.
#' @param mut_sd [numeric(1)]
#'   Standard deviation of the mutation.
#' @return [local_search_control]
#'   List with control params as S3 object.
local_search_control = function(minimize = TRUE, n_searches = 10L, n_steps = 5L, n_neighs = 10L, mut_sd = 0.1) {
  assert_int(n_searches, lower = 1L)
  assert_int(n_steps, lower = 1L)
  assert_int(n_neighs, lower = 1L)
  assert_number(mut_sd, lower = 0)
  res = list(n_searches = n_searches, n_steps = n_steps, n_neighs = n_neighs, mut_sd = mut_sd, minimize = minimize)
  set_class(res, "local_search_control")
}


#' @title Local Search
#' @description Local search optimizer
#' @param objective [function(dt)]
#'   Objective to optimize.
#' @param search_space [ParamSet]
#'   Search space for decision variables.
#' 
#' @return [data.table]
#' @export
local_search = function(objective, search_space, control = local_search_control()) {
  assert_class(control, "local_search_control")
  init_points = generate_design_random(search_space, n = control$n_searches)$data
  .Call("c_local_search", objective, search_space, control, init_points, PACKAGE = "bbotk")
}


