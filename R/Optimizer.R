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
    initialize = function(param_set, param_classes, properties,
      packages = character(0)) {
      self$param_set = assert_param_set(param_set)
      self$param_classes = assert_subset(param_classes,
        c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct", "ParamUty"))
      self$properties = assert_character(properties) # FIXME: assert_subset(properties, blabot_reflections$optimizer_properties)
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
    #' Performes the optimization and writes optimization result into [OptimInstance].
    #' @param inst [OptimInstance]
    #' @return NULL
    optimize = function(inst) {
      assert_r6(inst, "OptimInstance")
      require_namespaces(self$packages, "Packages for the Optimization")
      # check dependencies
      if ("dependencies" %nin% self$properties && inst$search_space$has_deps) {
        stopf(
          "Tuner '%s' does not support param sets with dependencies!",
          self$format())
      }
      # check supported parameter class
      not_supported_pclasses = setdiff(
        unique(inst$search_space$class),
        self$param_classes)
      if (length(not_supported_pclasses) > 0L) {
        stopf(
          "Tuner '%s' does not support param types: '%s'", class(self)[1L],
          paste0(not_supported_pclasses, collapse = ","))
      }
      tryCatch({
        private$.optimize(inst)
      }, terminated_error = function(cond) {})
      private$.assign_result(inst)
      invisible(NULL)
    }
  ),

  private = list(
    .optimize = function(inst) stop("abstract"),

    .assign_result = function(inst) {
      assert_r6(inst, "OptimInstance")
      res = inst$archive$get_best()

      xdt = res[, inst$objective$domain$ids(), with = FALSE]
      opt_x = res[["opt_x"]][[1]]
      y = unlist(res[, inst$objective$codomain$ids(), with = FALSE]) #unlist keeps name!

      inst$assign_result(xdt, y, opt_x)
      invisible(NULL)
    }
  )
)
