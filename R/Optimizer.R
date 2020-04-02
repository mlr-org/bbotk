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
    
    #' @field properties 
    properties = NULL,
    
    #' @field packages
    packages = NULL,
    
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' @param param_set [paradox::ParamSet]
    #' @param param_classes `character()`
    #' @param properties 
    #' @param packages
    initialize = function(param_set, param_classes, properties, packages = character(0)) {
      self$param_set = assert_param_set(param_set)
      self$param_classes = assert_subset(param_classes, c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct", "ParamUty"))
      self$properties = assert_subset(properties, blabot_reflections$optimizer_properties)
      self$packages = assert_set(packages)
    },
    
    #' @description 
    #' Performes the optimization
    #' @param optinst [OptimInstance]
    optimize = function(optinst) {
      assert_r6(optinst, "OptimInstance")
      require_namespace(self$packages)
      require_namespace(optinst$objective$packages)
      # check dependencies
      # check supported parameter class
      private$.optimize(optinst)
      private$.best(optinst)
    }
  ),
  
  private = list(
    .optimize = function(optinst) stop("abstract"),
    .best = function(optinst) {
      # default method to get "best" instances; should respect optinst$objective$codomain$tags being "minimize" or "maximize"
      return(best_result_in_optinst)
    }
  )
)