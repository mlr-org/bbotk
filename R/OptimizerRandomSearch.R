#' @title Optimization via Random Search
#'
#' @include Optimizer.R
#' @name mlr_optimizers_random_search
#'
#' @description
#' `OptimizerRandomSearch` class that implements a simple Random Search.
#'
#' In order to support general termination criteria and parallelization, we
#' evaluate points in a batch-fashion of size `batch_size`. Larger batches mean
#' we can parallelize more, smaller batches imply a more fine-grained checking
#' of termination criteria.
#'
#' @templateVar id random_search
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' \describe{
#' \item{`batch_size`}{`integer(1)`\cr
#' Maximum number of points to try in a batch.}
#' }
#'
#' @source
#' `r tools::toRd(bibentries["bergstra_2012"])`
#'
#' @export
#' @template example
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
        properties = c("dependencies", "single-crit", "multi-crit")
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      batch_size = self$param_set$values$batch_size
      sampler = SamplerUnif$new(inst$search_space)
      repeat { # iterate until we have an exception from eval_batch
        design = sampler$sample(batch_size)
        inst$eval_batch(design$data)
      }
    }
  )
)

mlr_optimizers$add("random_search", OptimizerRandomSearch)
