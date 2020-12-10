#' @title Reflections for bbotk
#'
#' @format [environment].
#' @description
#' Environment which stores various information to allow objects to examine and
#' introspect their structure and properties
#' (c.f. [Reflections](https://www.wikiwand.com/en/Reflection_(computer_programming))).
#'
#' This environment be modified by third-party packages.
#'
#' The following objects are set by \CRANpkg{bbotk}:
#'
#' * `optimizer_properties` (`character()`)\cr
#'   Properties of an optimizer, e.g. "dependencies".
#'
#' * `objective_properties` (`character()`)\cr
#'   Properties of an objective, e.g. "noisy".
#'
#' @keywords internal
#' @export
#' @examples
#' ls.str(bbotk_reflections)
bbotk_reflections = new.env(parent = emptyenv())

### optimizer_properties
bbotk_reflections$optimizer_properties = c(
  "dependencies", "single-crit", "multi-crit"
)

### objective_properties
bbotk_reflections$objective_properties = c(
  "noisy", "single-crit", "multi-crit", "deterministic"
)

### terminator_properties
bbotk_reflections$terminator_properties = c(
    "single-crit", "multi-crit"
)
