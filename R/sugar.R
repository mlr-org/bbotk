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
#' Function to construct a [OptimInstanceBatchSingleCrit] and [OptimInstanceBatchMultiCrit].
#'
#'
#' @template param_objective
#' @template param_search_space
#' @template param_terminator
#' @template param_callbacks
#' @template param_check_values
#' @template param_keep_evals
#'
#' @export
#' @examples
#' # define the objective function
#' fun = function(xs) {
#'   list(y = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
#' }
#'
#' # set domain
#' domain = ps(
#'   x1 = p_dbl(-10, 10),
#'   x2 = p_dbl(-5, 5)
#' )
#'
#' # set codomain
#' codomain = ps(
#'   y = p_dbl(tags = "maximize")
#' )
#'
#' # create objective
#' objective = ObjectiveRFun$new(
#'   fun = fun,
#'   domain = domain,
#'   codomain = codomain,
#'   properties = "deterministic"
#' )
#'
#' # initialize instance
#' instance = oi(
#'   objective = objective,
#'   terminator = trm("evals", n_evals = 20)
#' )
oi = function(
  objective,
  search_space = NULL,
  terminator,
  callbacks = NULL,
  check_values = TRUE,
  keep_evals = "all"
  ) {
  assert_r6(objective, "Objective")

  Instance = if (objective$codomain$target_length == 1) OptimInstanceBatchSingleCrit else OptimInstanceBatchMultiCrit
  Instance$new(
    objective = objective,
    search_space = search_space,
    terminator = terminator,
    callbacks = callbacks)
}

#' @title Syntactic Sugar for Asynchronous Optimization Instance Construction
#'
#' @description
#' Function to construct an [OptimInstanceAsyncSingleCrit] and [OptimInstanceAsyncMultiCrit].
#'
#' @template param_objective
#' @template param_search_space
#' @template param_terminator
#' @template param_check_values
#' @template param_callbacks
#' @template param_rush
#'
#' @export
#' @examples
#' # example only runs if a Redis server is available
#' if (mlr3misc::require_namespaces(c("rush", "redux"), quietly = TRUE) && redux::redis_available()) {
#' # define the objective function
#' fun = function(xs) {
#'   list(y = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
#' }
#'
#' # set domain
#' domain = ps(
#'   x1 = p_dbl(-10, 10),
#'   x2 = p_dbl(-5, 5)
#' )
#'
#' # set codomain
#' codomain = ps(
#'   y = p_dbl(tags = "maximize")
#' )
#'
#' # create objective
#' objective = ObjectiveRFun$new(
#'   fun = fun,
#'   domain = domain,
#'   codomain = codomain,
#'   properties = "deterministic"
#' )
#'
#' # initialize instance
#' instance = oi_async(
#'   objective = objective,
#'   terminator = trm("evals", n_evals = 20)
#' )
#' }
oi_async = function(
  objective,
  search_space = NULL,
  terminator,
  check_values = FALSE,
  callbacks = NULL,
  rush = NULL
  ) {
  assert_r6(objective, "Objective")

  Instance = if (objective$codomain$target_length == 1) OptimInstanceAsyncSingleCrit else OptimInstanceAsyncMultiCrit
  Instance$new(
    objective = objective,
    search_space = search_space,
    terminator = terminator,
    check_values = check_values,
    callbacks = callbacks,
    rush = rush)
}
