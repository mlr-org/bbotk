#' @title Optimizer
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

    #' @field param_set [paradox::ParamSet]
    param_set = NULL,

    #' @field param_classes `character()`
    param_classes = NULL,

    #' @field properties `character()`
    properties = NULL,

    #' @field packages `character()`
    packages = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' @param param_set [paradox::ParamSet]
    #' @param param_classes `character()`
    #' @param properties `character()`
    #' @param packages `character()`
    initialize = function(param_set, param_classes, properties, packages = character(0)) {
      self$param_set = assert_param_set(param_set)
      self$param_classes = assert_subset(param_classes, c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct", "ParamUty"))
      self$properties = assert_subset(properties, blabot_reflections$optimizer_properties)
      self$packages = assert_set(packages)
    },

    #' @description
    #' Helper for print outputs.
    format = function() {
      sprintf("<%s>", class(self)[1L])
    },

    #' @description
    #' Print method.
    #' @return `character()`
    print = function() {
      catf(format(self))
      catf(str_indent("* Parameters:", as_short_string(self$param_set$values)))
      catf(str_indent("* Parameter classes:", self$param_classes))
      catf(str_indent("* Properties:", self$properties))
      catf(str_indent("* Packages:", self$packages))
    },

    #' @description
    #' Performes the optimization.
    #' @param inst [OptimInstance]
    optimize = function(inst) {
      assert_r6(inst, "OptimInstance")
      require_namespace(self$packages)
      require_namespace(inst$objective$packages)
      # check dependencies
      # check supported parameter class
      private$.optimize(inst)
      private$.best(inst)
    }
  ),

  private = list(
    .optimize = function(inst) stop("abstract"),

    .assign_result = function(inst) {
      optimizer_assign_result_default(inst)
    }
  )
)

optimizer_assign_result_default = function(inst) {
  assert_r6(inst, "FSelectInstance")

  res = inst$archive$get_best()
  x = as.matrix(res[, inst$objective$domain$ids(), with = FALSE])[1, ]
  y = as.matrix(res[, inst$objective$codomain$ids(), with = FALSE])[1, ]

  inst$assign_result(x, y)
  invisible(NULL)
}
