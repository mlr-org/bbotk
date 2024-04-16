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
  dictionary_sugar_get(mlr_terminators, .key, ...)
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
  dictionary_sugar_get(mlr_optimizers, .key, ...)
}

#' @rdname opt
#' @export
opts = function(.keys, ...) {
  dictionary_sugar_mget(mlr_optimizers, .keys, ...)
}

#' @title Syntactic Sugar for Optimization Instance Construction
#'
#' @description
#' Function to construct a [OptimInstanceSingleCrit], [OptimInstanceMultiCrit], [OptimInstanceAsyncSingleCrit] or [OptimInstanceAsyncMultiCrit].
#'
#' @template param_objective
#' @template param_search_space
#' @template param_terminator
#' @template param_callbacks
#' @template param_check_values
#' @template param_keep_evals
#'
#' @export
oi = function(
  objective,
  search_space = NULL,
  terminator,
  callbacks = list(),
  check_values = TRUE,
  keep_evals = "all"
  ) {
  assert_r6(objective, "Objective")

  if (rush_available()) {
    Instance = if (objective$codomain$target_length == 1) OptimInstanceSingleCrit else OptimInstanceMultiCrit
    Instance$new(
      objective = objective,
      search_space = search_space,
      terminator = terminator,
      keep_evals = keep_evals,
      check_values = check_values,
      callbacks = callbacks)
  } else {
    Instance = if (objective$codomain$target_length == 1) OptimInstanceAsyncSingleCrit else OptimInstanceAsyncMultiCrit
    Instance$new(
      objective = objective,
      search_space = search_space,
      terminator = terminator,
      callbacks = callbacks)
  }
}
