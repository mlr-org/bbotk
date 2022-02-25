#' @title Optimizer
#'
#' @include mlr_optimizers.R
#'
#' @description
#' Abstract `Optimizer` class that implements the base functionality each
#' `Optimizer` subclass must provide. A `Optimizer` object describes the
#' optimization strategy.
#'
#' A `Optimizer` object must write its result to the `$assign_result()` method
#' of the [OptimInstance] at the end in order to store the best point  and its
#' estimated performance vector.
#'
#' @template section_progress_bars
#' @export
Optimizer = R6Class("Optimizer",
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param param_set ([paradox::ParamSet]).
    #' @param param_classes (`character()`).
    #' @param properties (`character()`).
    #' @param packages (`character()`).
    #' @param man (`character(1)`)\cr
    #'   String in the format `[pkg]::[topic]` pointing to a manual page for this object.
    #'   The referenced help package can be opened via method `$help()`.
    initialize = function(param_set, param_classes, properties, packages = character(), man = NA_character_) {
      private$.param_set = assert_param_set(param_set)
      private$.param_classes = assert_subset(param_classes,
        c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct", "ParamUty"))
      # has to have at least multi-crit or single-crit property
      private$.properties = assert_subset(properties, bbotk_reflections$optimizer_properties, empty.ok = FALSE)
      private$.packages = union("bbotk", assert_character(packages, any.missing = FALSE, min.chars = 1L))
      private$.man = assert_string(man, na.ok = TRUE)

      check_packages_installed(self$packages,
        msg = sprintf("Package '%%s' required but not installed for Optimizer '%s'", format(self)))
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
      catf(format(self))
      catf(str_indent("* Parameters:", as_short_string(self$param_set$values)))
      catf(str_indent("* Parameter classes:", self$param_classes))
      catf(str_indent("* Properties:", self$properties))
      catf(str_indent("* Packages:", self$packages))
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

    #' @field param_set ([paradox::ParamSet]).
    param_set = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.param_set)) {
        stop("$param_set is read-only.")
      }
      private$.param_set
    },

    #' @field param_classes (`character()`).
    param_classes = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.param_classes)) {
        stop("$param_classes is read-only.")
      }
      private$.param_classes
    },

    #' @field properties (`character()`).
    properties = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.properties)) {
        stop("$properties is read-only.")
      }
      private$.properties
    },

    #' @field packages (`character()`).
    packages = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.packages)) {
        stop("$packages is read-only.")
      }
      private$.packages
    },

    #' @field man (`character()`).
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
    .man = NULL
  )
)
