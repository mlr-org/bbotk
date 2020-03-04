#' @title Assertion for bbotk objects
#'
#' @description
#' Most assertion functions ensure the right class attrbiture, and optionally
#' additional properties.
#'
#' If an assertion fails, an exception is raised. Otherwise, the input object is
#' returned invisibly.
#'
#' @name mlr_assertions
#' @keywords internal
NULL

#' @export 
#' @param terminator ([Terminator])
#' @rdname mlr_assertions
assert_terminator = function(terminator) {
  assert_r6(terminator, "Terminator")
}

#' @export 
#' @param x ([any])
#' @param empty ([logical(1)])
#' @param .var.name ([character(1)])
#' @rdname mlr_assertions
assert_set = function(x, empty = TRUE, .var.name = vname(x)) {
  assert_character(x, min.len = as.integer(!empty), any.missing = FALSE, min.chars = 1L, unique = TRUE, .var.name = .var.name)
}
