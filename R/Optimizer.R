#' @title Optimizer
#'
#' @include mlr_optimizers.R
#'
#' @description
#' Abstract `Optimizer` class that implements the base functionality each `Optimizer` subclass must provide.
#' A `Optimizer` object describes the optimization strategy.
#' A `Optimizer` object must write its result to the `$assign_result()` method of the [OptimInstance] at the end in order to store the best point and its estimated performance vector.
#'
#' @template section_progress_bars
#'
#' @template field_param_set
#' @template field_label
#' @template field_man
#'
#' @template param_id
#' @template param_param_set
#' @template param_label
#' @template param_man
#'
#' @export
Optimizer = R6Class("Optimizer",
  public = list(
    #' @template field_id
    id = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param param_classes (`character()`)\cr
    #'   Supported parameter classes that the optimizer can optimize.
    #'   Subclasses of [paradox::Param].
    #'
    #' @param properties (`character()`)\cr
    #'   Set of properties of the optimizer.
    #'   Must be a subset of [`mlr_reflections$optimizer_properties`][mlr3::mlr_reflections].
    #'
     #' @param packages (`character()`)\cr
    #'   Set of required packages.
    #'   A warning is signaled by the constructor if at least one of the packages is not installed, but loaded (not attached) later on-demand via [requireNamespace()].
    initialize = function(id, param_set, param_classes, properties, packages = character(), label = NA_character_, man = NA_character_) {
      self$id = assert_string(id, min.chars = 1L)
      private$.param_set = assert_param_set(param_set)
      private$.param_classes = assert_subset(param_classes, c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct", "ParamUty"))
      # has to have at least multi-crit or single-crit property
      private$.properties = assert_subset(properties, bbotk_reflections$optimizer_properties, empty.ok = FALSE)
      private$.packages = union("bbotk", assert_character(packages, any.missing = FALSE, min.chars = 1L))
      private$.label = assert_string(label, na.ok = TRUE)
      private$.man = assert_string(man, na.ok = TRUE)

      check_packages_installed(self$packages, msg = sprintf("Package '%%s' required but not installed for Optimizer '%s'", format(self)))
    },

    #' @description
    #' Helper for print outputs.
    format = function() {
      sprintf("<%s>", class(self)[1L])
    },

    #' @description
    #' Print method.
    #'
    #' @return (`character()`).
    print = function() {
      catn(format(self), if (is.na(self$label)) "" else paste0(": ", self$label))
      catn(str_indent("* Parameters:", as_short_string(self$param_set$values)))
      catn(str_indent("* Parameter classes:", self$param_classes))
      catn(str_indent("* Properties:", self$properties))
      catn(str_indent("* Packages:", self$packages))
    },

    #' @description
    #' Opens the corresponding help page referenced by field `$man`.
    help = function() {
      open_help(self$man)
    },

    #' @description
    #' Performs the optimization and writes optimization result into
    #' [OptimInstance]. The optimization result is returned but the complete
    #' optimization path is stored in [Archive] of [OptimInstance].
    #'
    #' @param inst ([OptimInstance]).
    #' @return [data.table::data.table].
    optimize = function(inst) {
      optimize_default(inst, self, private)
    }
  ),

  active = list(

    param_set = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.param_set)) {
        stop("$param_set is read-only.")
      }
      private$.param_set
    },

    #' @field param_classes (`character()`)\cr
    #'   Supported parameter classes that the optimizer can optimize.
    #'   Subclasses of [paradox::Param].
    param_classes = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.param_classes)) {
        stop("$param_classes is read-only.")
      }
      private$.param_classes
    },

    #' @field properties (`character()`)\cr
    #'   Set of properties of the optimizer.
    #'   Must be a subset of [`mlr_reflections$optimizer_properties`][mlr3::mlr_reflections].
    properties = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.properties)) {
        stop("$properties is read-only.")
      }
      private$.properties
    },

    #' @field packages (`character()`)\cr
    #'   Set of required packages.
    #'   A warning is signaled by the constructor if at least one of the packages is not installed, but loaded (not attached) later on-demand via [requireNamespace()].
    packages = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.packages)) {
        stop("$packages is read-only.")
      }
      private$.packages
    },

    label = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.label)) {
        stop("$label is read-only.")
      }
      private$.label
    },

    man = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.man)) {
        stop("$man is read-only.")
      }
      private$.man
    }
  ),

  private = list(
    .optimize = function(inst) stop("abstract"),

    .assign_result = function(inst) {
      assert_r6(inst, "OptimInstance")
      assign_result_default(inst)
    },

    .param_set = NULL,
    .param_classes = NULL,
    .properties = NULL,
    .packages = NULL,
    .label = NULL,
    .man = NULL
  )
)
