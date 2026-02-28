#' @title Condition Classes for bbotk
#'
#' @description
#' Condition classes for bbotk.
#'
#' @param msg (`character(1)`)\cr
#'   Error message.
#' @param ... (any)\cr
#'   Passed to [sprintf()].
#' @param class (`character`)\cr
#'   Additional class(es).
#' @param signal (`logical(1)`)\cr
#'   If `FALSE`, the condition object is returned instead of being signaled.
#' @param parent (`condition`)\cr
#'   Parent condition.
#'
#' @section Errors:
#' * `error_bbotk()` for the `Mlr3ErrorBbotk` class,
#'   signalling a general bbotk error.
#' * `error_bbotk_terminated()` for the `Mlr3ErrorBbotkTerminated` class,
#'   signalling a termination error.
#'
#' @export
#' @name bbotk_conditions
error_bbotk = function(msg, ..., class = NULL, signal = TRUE, parent = NULL) {
  error_mlr3(msg, ..., class = c(class, "Mlr3ErrorBbotk"), signal = signal, parent = parent)
}

#' @export
#' @rdname bbotk_conditions
error_bbotk_terminated = function(msg, ..., class = NULL, signal = TRUE, parent = NULL) {
  # "terminated_error" is kept for backwards compatibility with downstream packages
  # (e.g. miesmuschel, mlr3tuning, mlr3book) that catch this class in tryCatch handlers.
  error_mlr3(msg, ..., class = c(class, "Mlr3ErrorBbotkTerminated", "Mlr3ErrorBbotk", "terminated_error"), signal = signal, parent = parent)
}
