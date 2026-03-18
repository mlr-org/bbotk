#' @title Convert to a Terminator
#'
#' @description
#' Convert object to a [Terminator] or a list of [Terminator].
#'
#' @param x (any)\cr
#'   Object to convert.
#' @param ... (any)\cr
#'   Additional arguments.
#'
#' @seealso [Terminator]
#' @export
# nolint next
as_terminator = function(x, ...) {
  UseMethod("as_terminator")
}

#' @export
#' @param clone (`logical(1)`)\cr
#'   If `TRUE`, ensures that the returned object is not the same as the input `x`.
#' @rdname as_terminator
# nolint next
as_terminator.Terminator = function(x, clone = FALSE, ...) {
  if (isTRUE(clone)) x$clone() else x
}

#' @export
#' @rdname as_terminator
# nolint next
as_terminators = function(x, ...) {
  UseMethod("as_terminators")
}

#' @export
#' @rdname as_terminator
# nolint next
as_terminators.default = function(x, ...) {
  list(as_terminator(x, ...))
}

#' @export
#' @rdname as_terminator
# nolint next
as_terminators.list = function(x, ...) {
  lapply(x, as_terminator, ...)
}
