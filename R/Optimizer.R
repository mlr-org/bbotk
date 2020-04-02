Optimizer = R6Class("Optimizer",
  public = list(
    param_set = NULL,
    param_classes = NULL,
    properties = NULL,
    packages = NULL,
    initialize = function(param_set, param_classes, properties, packages = character(0)) {

    },
    
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