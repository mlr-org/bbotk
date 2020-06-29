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
#' * `assert_instance_properties(optimizer, instance)`\cr
#'   ([Optimizer], [OptimInstance]) -> `NULL`\cr
#'   Checks if the instance is applicable to the optimizer.
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

#' @export
#' @param optimizer ([Optimizer])
#' @rdname bbotk_assertions
assert_optimizer = function(optimizer) {
  assert_r6(optimizer, "Optimizer")
}

#' @export
#' @param optimizer ([Optimizer]).
#' @param instance ([OptimInstance]).
#' @rdname bbotk_assertions
assert_instance_properties = function(optimizer, inst) {
  assert_r6(inst, "OptimInstance")

  require_namespaces(optimizer$packages, "Packages for the Optimization")

  # check multi or single-crit
  if ("multi-crit" %nin% optimizer$properties && inst$objective$ydim > 1) {
    stopf(
      "'%s' does not support multi-crit objectives",
      optimizer$format())
  }
  if ("single-crit" %nin% optimizer$properties && inst$objective$ydim == 1) {
    stopf(
      "'%s' does not support single-crit objectives",
      optimizer$format())
  }

  # check dependencies
  if ("dependencies" %nin% optimizer$properties && inst$search_space$has_deps) {
    stopf(
      "'%s' does not support param sets with dependencies!",
      optimizer$format())
  }

  # check supported parameter class
  not_supported_pclasses = setdiff(
    unique(inst$search_space$class),
    optimizer$param_classes)
  if (length(not_supported_pclasses) > 0L) {
    stopf(
      "'%s' does not support param types: '%s'", class(optimizer)[1L],
      paste0(not_supported_pclasses, collapse = ","))
  }
}

#' @export
#' @param codomain ([paradox::ParamSet]).
#' @rdname bbotk_assertions
assert_codomain = function(codomain) {
  assert_param_set(codomain)

  # check that "codomain" is
  for(y in codomain$params) {

    # (1) all numeric
    if(!y$is_number) {
      stopf("%s in codomain is not numeric", y$id)
    }

    # (2) every parameter's tags contain at most one of 'minimize' or 'maximize'
    if(sum(y$tags %in% c("minimize", "maximize")) > 1) {
      stopf("%s in codomain contains a 'minimize' and 'maximize' tag",
            y$id)
    }

    # (3) every parameter contains a 'minimize' or 'maximize' tag
    if(!any(y$tags %in% c("minimize", "maximize"))) {
      stopf("%s in codomain contains no 'minimize' or 'maximize' tag",
            y$id)
    }
  }
  return(codomain)
}
