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
#' @seealso [Terminator], [OptimInstance], [Optimizer], [Archive]
NULL

#' @export
#' @param terminator ([Terminator]).
#' @param instance ([OptimInstance]).
#' @template param_null_ok
#' @rdname bbotk_assertions
assert_terminator = function(terminator, instance = NULL, null_ok = FALSE) {
  if (null_ok && is.null(terminator)) return(NULL)
  assert_r6(terminator, "Terminator")

  if (!is.null(instance)) {
    assert_terminable(terminator, instance)
  }

  invisible(terminator)
}

#' @export
#' @param terminators (list of [Terminator]).
#' @rdname bbotk_assertions
assert_terminators = function(terminators) {
  invisible(lapply(terminators, assert_terminator))
}

#' @export
#' @param terminator ([Terminator]).
#' @param instance ([OptimInstance]).
#' @rdname bbotk_assertions
assert_terminable = function(terminator, instance) {
  if ("OptimInstanceBatchMultiCrit" %in% class(instance)) {
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
#' @param optimizer ([OptimizerBatch]).
#' @template param_null_ok
#' @rdname bbotk_assertions
assert_optimizer = function(optimizer, null_ok = FALSE) {
  if (null_ok && is.null(optimizer)) return(NULL)
  assert_r6(optimizer, "Optimizer")
}

#' @export
#' @param optimizer ([OptimizerAsync])
#' @template param_null_ok
#' @rdname bbotk_assertions
assert_optimizer_async = function(optimizer, null_ok = FALSE) {
   if (null_ok && is.null(optimizer)) return(NULL)
  assert_r6(optimizer, "OptimizerAsync")
}

#' @export
#' @param optimizer ([OptimizerAsync])
#' @template param_null_ok
#' @rdname bbotk_assertions
assert_optimizer_batch = function(optimizer, null_ok = FALSE) {
  if (null_ok && is.null(optimizer)) return(NULL)
  assert_r6(optimizer, "OptimizerBatch")
}

#' @export
#' @param inst ([OptimInstance])
#' @template param_null_ok
#' @rdname bbotk_assertions
assert_instance = function(inst, null_ok = FALSE) {
  if (null_ok && is.null(inst)) return(NULL)
  assert_r6(inst, "OptimInstance")
}

#' @param inst ([OptimInstanceBatch])
#' @template param_null_ok
#' @rdname bbotk_assertions
assert_instance_batch = function(inst, null_ok = FALSE) {
  if (null_ok && is.null(inst)) return(NULL)
  assert_r6(inst, "OptimInstanceBatch")
}

#' @export
#' @param inst ([OptimInstanceAsync])
#' @template param_null_ok
#' @rdname bbotk_assertions
assert_instance_async = function(inst, null_ok = FALSE) {
  if (null_ok && is.null(inst)) return(NULL)
  assert_r6(inst, "OptimInstanceAsync")
}

#' @export
#' @param optimizer ([Optimizer]).
#' @param instance ([OptimInstance]).
#' @rdname bbotk_assertions
assert_instance_properties = function(optimizer, inst) {
  assert_class(inst, "OptimInstance")

  require_namespaces(optimizer$packages)

  # check multi or single-crit
  if ("multi-crit" %nin% optimizer$properties && inst$objective$ydim > 1) {
    stopf("'%s' does not support multi-crit objectives", optimizer$format())
  }
  if ("single-crit" %nin% optimizer$properties && inst$objective$ydim == 1) {
    stopf( "'%s' does not support single-crit objectives", optimizer$format())
  }

  # check dependencies
  if ("dependencies" %nin% optimizer$properties && inst$search_space$has_deps) {
    stopf("'%s' does not support param sets with dependencies!", optimizer$format())
  }

  # check supported parameter class
  not_supported_pclasses = setdiff(unique(inst$search_space$class), get_private(optimizer)$.param_classes)
  if (length(not_supported_pclasses) > 0L) {
    stopf("'%s' does not support param types: '%s'", class(optimizer)[1L], paste0(not_supported_pclasses, collapse = ","))
  }
}

#' @export
#' @param archive ([Archive]).
#' @template param_null_ok
#' @rdname bbotk_assertions
assert_archive = function(archive, null_ok = FALSE) {
  if (null_ok && is.null(archive)) return(NULL)
  assert_r6(archive, "Archive")
}

#' @export
#' @param archive ([ArchiveAsync]).
#' @template param_null_ok
#' @rdname bbotk_assertions
assert_archive_async = function(archive, null_ok = FALSE) {
  if (null_ok && is.null(archive)) return(NULL)
  assert_r6(archive, "ArchiveAsync")
}

#' @export
#' @param archive ([ArchiveBatch]).
#' @template param_null_ok
#' @rdname bbotk_assertions
assert_archive_batch = function(archive, null_ok = FALSE) {
  if (null_ok && is.null(archive)) return(NULL)
  assert_r6(archive, "ArchiveBatch")
}

#' @title Assert Python Packages
#'
#' @description
#' Assert that the given Python packages are available.
#'
#' @param packages (`character()`)\cr
#'   Python packages to check.
#' @param python_version (`character(1)`)\cr
#'   Python version to use. If `NULL`, the default Python version is used.
#'
#' @return (`character()`)\cr
#'   Invisibly returns the input `packages` vector if all requested Python packages are available; otherwise throws an error listing the missing packages.
assert_python_packages = function(packages, python_version = NULL) {
  reticulate::py_require(packages, python_version = python_version)
  available = map_lgl(packages, reticulate::py_module_available)
  if (any(!available)) {
    stopf("Package %s not available.", as_short_string(packages[!available]))
  }
  invisible(packages)
}
