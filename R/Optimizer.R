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
#' @export
Optimizer = R6Class("Optimizer",
  public = list(

    #' @field param_set ([paradox::ParamSet]).
    param_set = NULL,

    #' @field param_classes (`character()`).
    param_classes = NULL,

    #' @field properties (`character()`).
    properties = NULL,

    #' @field packages (`character()`).
    packages = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param param_set ([paradox::ParamSet]).
    #' @param param_classes (`character()`).
    #' @param properties (`character()`).
    #' @param packages (`character()`).
    initialize = function(param_set, param_classes, properties,
      packages = character()) {
      self$param_set = assert_param_set(param_set)
      self$param_classes = assert_subset(param_classes,
        c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct", "ParamUty"))
      self$properties = assert_subset(properties, bbotk_reflections$optimizer_properties, empty.ok = FALSE) #has to have at least multi-crit or single-crit property
      self$packages = assert_set(packages)
    },

    #' @description
    #' Helper for print outputs.
    format = function() {
      sprintf("<%s>", class(self)[1L])
    },

    #' @description
    #' Print method.
    #' @return (`character()`).
    print = function() {
      catf(format(self))
      catf(str_indent("* Parameters:", as_short_string(self$param_set$values)))
      catf(str_indent("* Parameter classes:", self$param_classes))
      catf(str_indent("* Properties:", self$properties))
      catf(str_indent("* Packages:", self$packages))
    },

    #' @description
    #' Performs the optimization and writes optimization result into [OptimInstance].
    #'
    #' @param inst ([OptimInstance]).
    #' @return NULL
    optimize = function(inst) {
      optimize_default(inst, self, private)
    }
  ),

  private = list(
    .optimize = function(inst) stop("abstract"),

    .assign_result = function(inst) {
      assert_r6(inst, "OptimInstance")
      assign_result_default(inst)
    }
  )
)
