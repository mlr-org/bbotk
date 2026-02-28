#' @title Termination Error
#'
#' @description
#' Error class for termination.
#'
#' @param optim_instance [OptimInstance]\cr
#' OptimInstance that terminated.
#'
#' @return A `Mlr3ErrorBbotkTerminated` condition.
#' @export
terminated_error = function(optim_instance) {
  msg = sprintf(
    fmt = "Objective (obj:%s, term:%s) terminated",
    optim_instance$objective$id,
    class(optim_instance$terminator)[[1L]]
  )

  error_bbotk_terminated(msg)
}

#' @title Calculate which points are dominated
#' @description
#' Returns which points from a set are dominated by another point in the set.
#'
#' @param ymat (`matrix()`) \cr
#'   A numeric matrix. Each column (!) contains one point.
#'
#' @useDynLib bbotk c_is_dominated
#' @return `logical()` with `TRUE` if a point (column of `ymat`) is dominated.
#' @export
is_dominated = function(ymat) {
  assert_matrix(ymat, mode = "double")
  .Call(c_is_dominated, ymat, PACKAGE = "bbotk")
}

#' @title Calculates the transformed x-values
#'
#' @description
#' Transforms a given `data.table()` to a list with transformed x values.
#' If no trafo is defined it will just convert the `data.table()` to a list.
#' Mainly for internal usage.
#'
#' @template param_xdt
#' @template param_search_space
#'
#' @return `list()` with transformed x values.
#' @keywords internal
#' @export
transform_xdt_to_xss = function(xdt, search_space) {
  design = Design$new(
    search_space,
    xdt[, search_space$ids(), with = FALSE],
    remove_dupl = FALSE
  )
  design$transpose(trafo = TRUE, filter_na = TRUE)
}

#' @title Calculate the transformed x-values
#'
#' @description
#' Transforms a given `list()` to a list with transformed x values.
#'
#' @param xs (`list()`) \cr
#'  List of x-values.
#' @param search_space [paradox::ParamSet]\cr
#'  Search space.
#'
#' @return `list()` with transformed x values.
#' @export
trafo_xs = function(xs, search_space) {
  xs = discard(xs, is_scalar_na)
  if (search_space$has_trafo) {
    xs = search_space$trafo(xs, search_space)
  }
  return(xs)
}

#' @title Get start values for optimizers
#'
#' @description
#' Returns a named numeric vector with start
#' values for optimizers.
#'
#' @param search_space [paradox::ParamSet].
#' @param type (`character(1)`)\cr
#' `random` start values or `center` of search space?
#'
#' @return named `numeric()` with start values.
#'
#' @keywords internal
search_start = function(search_space, type = "random") {
  assert_choice(type, c("random", "center"))
  if (type == "random") {
    unlist(generate_design_random(search_space, 1)$data[1, ])
  } else if (type == "center") {
    if (!all(search_space$storage_type == "numeric")) {
      stop("Cannot generate center values of non-numeric parameters.")
    }
    (search_space$upper + search_space$lower) / 2
  }
}

#' @title Branin Function
#'
#' @description
#' Classic 2-D Branin function with noise `branin(x1, x2, noise)` and Branin function with fidelity parameter `branin_wu(x1, x2, fidelity)`.
#'
#' @source
#' `r format_bib("wu_2019")`
#'
#' @param x1 (`numeric()`).
#' @param x2 (`numeric()`).
#' @param noise (`numeric()`).
#' @param fidelity (`numeric()`).
#'
#' @return `numeric()`
#'
#' @export
#' @examples
#' branin(x1 = 12, x2 = 2, noise = 0.05)
#' branin_wu(x1 = 12, x2 = 2, fidelity = 1)
branin = function(x1, x2, noise = 0) {
  (x2 - 5.1 / (4 * pi^2) * x1^2 + 5 / pi * x1 - 6)^2 + 10 * (1 - 1 / (8 * pi)) * cos(x1) + 10
}

#' @rdname branin
#' @export
branin_wu = function(x1, x2, fidelity) {
  (x2 - (5.1 / (4 * pi^2) - 0.1 * (1 - fidelity)) * x1^2 + 5 / pi * x1 - 6) ^ 2 +  10 * (1 - 1 / (8 * pi)) * cos(x1) + 10
}

allow_partial_matching = list(
  warnPartialMatchArgs = FALSE,
  warnPartialMatchAttr = FALSE,
  warnPartialMatchDollar = FALSE
)

