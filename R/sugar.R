#' @title Syntactic Sugar Terminator Construction
#'
#' @description
#' This function complements [mlr_terminators] with functions in the spirit
#' of `mlr_sugar` from \CRANpkg{mlr3}.
#'
#' @param .key (`character(1)`)\cr
#' Key passed to the respective [dictionary][mlr3misc::Dictionary] to retrieve
#' the object.
#' @param .keys (`character()`)\cr
#' Keys passed to the respective [dictionary][mlr3misc::Dictionary] to retrieve
#' multiple objects.
#' @param ... (named `list()`)\cr
#' Named arguments passed to the constructor, to be set as parameters in the
#' [paradox::ParamSet], or to be set as public field. See
#' [mlr3misc::dictionary_sugar_get()] for more details.
#'
#' @return
#' * [Terminator] for `trm()`.
#' * list of [Terminator] for `trms()`.
#'
#' @export
#' @examples
#' trm("evals", n_evals = 10)
trm = function(.key, ...) {
  dictionary_sugar(mlr_terminators, .key, ...)
}

#' @rdname trm
#' @export
trms = function(.keys, ...) {
  dictionary_sugar_mget(mlr_terminators, .keys, ...)
}

#' @title Syntactic Sugar Optimizer Construction
#'
#' @description
#' This function complements [mlr_optimizers] with functions in the spirit
#' of `mlr_sugar` from \CRANpkg{mlr3}.
#'
#' @param .key (`character(1)`)\cr
#' Key passed to the respective [dictionary][mlr3misc::Dictionary] to retrieve
#' the object.
#' @param .keys (`character()`)\cr
#' Keys passed to the respective [dictionary][mlr3misc::Dictionary] to retrieve
#' multiple objects.
#' @param ... (named `list()`)\cr
#' Named arguments passed to the constructor, to be set as parameters in the
#' [paradox::ParamSet], or to be set as public field. See
#' [mlr3misc::dictionary_sugar_get()] for more details.
#'
#' @return
#' * [Optimizer] for `opt()`.
#' * list of [Optimizer] for `opts()`.
#'
#' @export
#' @examples
#' opt("random_search", batch_size = 10)
#' @export
opt = function(.key, ...) {
  dictionary_sugar(mlr_optimizers, .key, ...)
}

#' @rdname opt
#' @export
opts = function(.keys, ...) {
  dictionary_sugar_mget(mlr_optimizers, .keys, ...)
}


#' @export
bb_optimize = function(method, fun = NULL, objective = NULL, term_evals = NULL, term_time = NULL, search_space = NULL,
  lower = NULL, upper = NULL, codomain = NULL, ...) {

  assert_choice(method, mlr_optimizers$keys())
  optimizer = opt(method, ...)
  assert_function(fun, null.ok = TRUE)
  assert_r6(objective, "Objective", null.ok = TRUE)
  terminator = terminator_selection(term_evals, term_time)
  if (!is.null(search_space)) assert_param_set(search_space)
  assert_numeric(lower, null.ok = TRUE)
  assert_numeric(upper, null.ok = TRUE)

  if (!xor(is.null(fun), is.null(objective))) {
    stop("Either `fun` or `objective` must be provided.")
  }

  if (xor(is.null(lower), is.null(upper))) {
    stop("`lower` and `upper` must be provided.")
  }

  if (!is.null(fun)) {
    if(is.null(search_space)) {
      ids = if (is.null(names(lower))) paste0("x", seq(lower)) else names(lower)

      search_space = ParamSet$new(pmap(list(ids, lower, upper), function(s, lb, ub) {
        ParamDbl$new(id = s, lower = lb, upper = ub)
      }))
    }
    if (is.null(codomain)) codomain = ps(y = p_dbl(tags = "minimize"))
    objective = ObjectiveRFun$new(fun, search_space, codomain, check_values = FALSE)
  }

  instance = OptimInstanceSingleCrit$new(objective, terminator = terminator, check_values = FALSE)
  optimizer$optimize(instance)
  par = if (instance$search_space$all_numeric) {
    set_names(as.numeric(instance$result_x_search_space), instance$search_space$ids()) 
  } else {
    instance$result_x_search_space
  }

  list(par =  par, value = instance$result_y, instance = instance)
}

terminator_selection = function(term_evals, term_time) {
  assert_int(term_evals, null.ok = TRUE)
  assert_int(term_time, null.ok = TRUE)

  if (is.null(term_evals) && is.null(term_time)) {
    trm("none")
  } else if (!is.null(term_evals) && !is.null(term_time)) {
    trm("combo", list(trm("evals", n_evals = term_evals), trm("run_time", secs = term_time)))
  } else if (!is.null(term_evals)) {
    trm("evals", n_evals = term_evals)
  } else if (!is.null(term_time)) {
    trm("run_time", secs = term_time)
  }
}
