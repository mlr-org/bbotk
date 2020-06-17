#' @title Syntactic Sugar Terminator Construction
#'
#' @description
#' This function complements [mlr_terminators] with functions in the spirit
#' of [mlr3::mlr_sugar].
#'
#' @inheritParams mlr3::mlr_sugar
#' @return
#' * [Terminator] for `term()`.
#' * list of [Terminator] for `terms()`.
#' @export
#' @examples
#' term("evals", n_evals = 10)
term = function(.key, ...) {
  dictionary_sugar(mlr_terminators, .key, ...)
}

#' @rdname term
#' @export
terms = function(.key, ...) {
  dictionary_sugar_mget(mlr_terminators, .key, ...)
}

#' @title Syntactic Sugar Optimizer Construction
#'
#' @description
#' This function complements [mlr_optimizer] with functions in the spirit
#' of [mlr3::mlr_sugar].
#'
#' @inheritParams mlr3::mlr_sugar
#' @return
#' * [Optimizer] for `opt()`.
#' * list of [Optimizer] for `opts()`.
#' @export
#' @examples
#' opt("random_search", batch_size = 10)
#' @export
opt = function(.key, ...) {
  dictionary_sugar(mlr_optimizers, .key, ...)
}

#' @rdname opt
#' @export
opts = function(.key, ...) {
  dictionary_sugar_mget(mlr_optimizers, .key, ...)
}
