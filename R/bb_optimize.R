#' @title Black-Box Optimization
#'
#' @description
#' This function optimizes a function or [Objective] with a given method.
#'
#' @param x (`function` | [Objective]).
#' @param method (`character(1)` | [Optimizer])\cr
#'  Key to retrieve optimizer from [mlr_optimizers] dictionary or [Optimizer].
#' @param max_evals (`integer(1)`)\cr
#'  Number of allowed evaluations.
#' @param max_time (`integer(1)`)\cr
#'  Maximum allowed time in seconds.
#' @param lower (`numeric()`)\cr
#'  Lower bounds on the parameters. If named, names are used to create the
#'  domain.
#' @param upper (`numeric()`)\cr
#'  Upper bounds on the parameters.
#' @param maximize (`logical()`)\cr
#'  Logical vector used to create the codomain e.g. c(TRUE, FALSE) -> ps(y1 = p_dbl(tags = "maximize"), y2 = pd_dbl(tags = "minimize")).
#'  If named, names are used to create the codomain.
#' @param search_space ([paradox::ParamSet]).
#' @param ... (named `list()`)\cr
#'  Named arguments passed to objective function. Ignored if [Objective] is
#'  optimized.
#'
#' @note
#' If both `max_evals` and `max_time` are `NULL`, [TerminatorNone] is used. This
#' is useful if the [Optimizer] can terminate itself. If both are given,
#' [TerminatorCombo] is created and the optimization stops if the time or
#' evaluation budget is exhausted.
#'
#' @return `list` of
#'  * `"par"` - Best found parameters
#'  * `"value"` - Optimal outcome
#'  * `"instance"` - [OptimInstanceBatchSingleCrit] | [OptimInstanceBatchMultiCrit]
#'
#' @export
#' @examples
#' # function and bounds
#' fun = function(xs) {
#'   -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10
#' }
#'
#' bb_optimize(fun, lower = c(-10, -5), upper = c(10, 5), max_evals = 10)
#'
#' # function and constant
#' fun = function(xs, c) {
#'   -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + c
#' }
#'
#' bb_optimize(fun, lower = c(-10, -5), upper = c(10, 5), max_evals = 10, c = 1)
#'
#' # objective
#' fun = function(xs) {
#'   c(z = -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
#' }
#'
#' # define domain and codomain using a `ParamSet` from paradox
#' domain = ps(x1 = p_dbl(-10, 10), x2 = p_dbl(-5, 5))
#' codomain = ps(z = p_dbl(tags = "minimize"))
#' objective = ObjectiveRFun$new(fun, domain, codomain)
#'
#' bb_optimize(objective, method = "random_search", max_evals = 10)
bb_optimize = function(x, method = "random_search", max_evals = 1000, max_time = NULL, ...) {
  assert_int(max_time, lower = 0, null.ok = TRUE)
  assert_int(max_evals, lower = 0, null.ok = TRUE)
  UseMethod("bb_optimize")
}

#' @rdname bb_optimize
#' @export
bb_optimize.function = function(x, method = "random_search", max_evals = 1000, max_time = NULL, lower = NULL,
  upper = NULL, maximize = FALSE, ...) {
  assert_numeric(lower, finite = TRUE, min.len = 1)
  assert_numeric(upper, finite = TRUE, len = length(lower))
  # construct constants set
  if (length(list(...)) > 0) {
    constants = invoke(ps, .args = map(list(...), function(x) p_uty()))
    constants$values = list(...)
  } else {
    constants = ps()
  }

  ids_domain = if (is.null(names(lower))) paste0("x", seq_along(lower)) else names(lower)
  domain = do.call(ps, set_names(pmap(list(lower, upper), p_dbl), ids_domain))

  ids_codomain = if (is.null(names(maximize))) paste0("y", seq_along(maximize)) else names(maximize)
  codomain = do.call(ps, set_names(map(maximize, function(x) p_dbl(tags = if (x) "maximize" else "minimize")), ids_codomain))

  objective = ObjectiveRFun$new(x, domain, codomain, constants = constants, check_values = FALSE)
  bb_optimize(objective, method, max_evals, max_time, ...)
}

#' @rdname bb_optimize
#' @export
bb_optimize.Objective = function(x, method = "random_search", max_evals = 1000, max_time = NULL, search_space = NULL, ...) {
  optimizer = if (is.character(method)) opt(assert_choice(method, mlr_optimizers$keys())) else assert_optimizer(method)
  terminator = if (is.null(max_evals) && is.null(max_time)) {
    trm("none")
  } else if (!is.null(max_evals) && !is.null(max_time)) {
    trm("combo", list(trm("evals", n_evals = max_evals), trm("run_time", secs = max_time)))
  } else if (!is.null(max_evals)) {
    trm("evals", n_evals = max_evals)
  } else if (!is.null(max_time)) {
    trm("run_time", secs = max_time)
  }
  optiminstance = if (x$codomain$length == 1) OptimInstanceBatchSingleCrit else OptimInstanceBatchMultiCrit

  instance = optiminstance$new(x, terminator = terminator, search_space = search_space, check_values = FALSE)
  optimizer$optimize(instance)

  list(
    par = instance$result_x_search_space,
    value = instance$result_y,
    instance = instance)
}
