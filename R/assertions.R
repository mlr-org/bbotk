#' @title Assertion for bbotk objects
#'
#' @description
#' Most assertion functions ensure the right class attribute, and optionally
#' additional properties. Additionally, the following compound assertions are
#' implemented:
#'
#' * `assert_terminable(terminator, instance)`\cr
#'   ([Terminator], [OptimInstance]) -> `NULL`\cr
#'   Checks if the terminator is applicable to the optimization.
#'
#' If an assertion fails, an exception is raised. Otherwise, the input object is
#' returned invisibly.
#'
#' @name bbotk_assertions
#' @keywords internal
NULL

#' @export
#' @param terminator ([Terminator]).
#' @param instance ([OptimInstance]).
#' @rdname bbotk_assertions
assert_terminator = function(terminator, instance = NULL) {
  assert_r6(terminator, "Terminator")

  if (!is.null(instance)) {
    assert_terminable(terminator, instance)
  }

  invisible(terminator)
}

#' @export
#' @param terminator ([Terminator]).
#' @param instance ([OptimInstance]).
#' @rdname bbotk_assertions
assert_terminable = function(terminator, instance) {
  if ("OptimInstanceMulticrit" %in% class(instance)) {
    if (!"multi-crit" %in% terminator$properties) {
      stopf("Terminator '%s' does not support multi-crit optimization",
        terminator$format())
    }
  } else {
    if (!"single-crit" %in% terminator$properties) {
      stopf("Terminator '%s' does not support single-crit optimization",
        terminator$format())
    }
  }
}

#' @export
#' @param x (any)
#' @param empty (`logical(1)`)
#' @param .var.name (`character(1)`)
#' @rdname bbotk_assertions
assert_set = function(x, empty = TRUE, .var.name = vname(x)) {
  assert_character(x, min.len = as.integer(!empty), any.missing = FALSE,
    min.chars = 1L, unique = TRUE, .var.name = .var.name)
}
