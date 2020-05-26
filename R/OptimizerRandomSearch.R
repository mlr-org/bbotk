#' @title Optimization via Random Search
#'
#' @description
#' `OptimizerRandomSearch` class that implements a simple Random Search.
#'
#' @export
OptimizerRandomSearch = R6Class("OptimizerRandomSearch",
  inherit = Optimizer,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      ps = ParamSet$new(list(
        ParamInt$new("batch_size", default = 1L, tags = "required")
      ))
      ps$values = list(batch_size = 1L)

      super$initialize(
        param_set = ps,
        param_classes = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct"),
        properties = "dependencies"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      batch_size = self$param_set$values$batch_size
      sampler = SamplerUnif$new(inst$search_space) #FIXME if instance has sampler take this
      repeat { # iterate until we have an exception from eval_batch
        design = sampler$sample(batch_size)
        inst$eval_batch(design$data)
      }
    }
  )
)
