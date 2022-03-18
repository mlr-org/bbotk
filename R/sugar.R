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
