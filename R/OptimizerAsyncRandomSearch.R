#' @title Optimization via Asynchronous Random Search
#'
#' @include Optimizer.R
#' @name mlr_optimizers_async_random_search
#'
#' @description
#' `OptimizerAsyncRandomSearch` class that implements a simple Random Search
#' with asynchronous evaluations.
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
#' @template section_progress_bars
#'
#' @export
#' @template example
OptimizerAsyncRandomSearch = R6Class("OptimizerAsyncRandomSearch",
  inherit = Optimizer,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(
        param_set = ps(),
        param_classes = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct"),
        properties = c("dependencies", "single-crit", "multi-crit")
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      sampler = SamplerUnif$new(inst$search_space)
      n_workers = future::nbrOfWorkers()

      repeat({
        replicate(n_workers - inst$archive$n_in_progress, {
          xdt = sampler$sample(1)$data
          inst$archive$add_evals(xdt, status = "proposed")
          inst$eval_proposed(async = TRUE, single_worker = FALSE)
        })
      inst$resolve_promise()
      })
    }
  )
)

mlr_optimizers$add("async_random_search", OptimizerAsyncRandomSearch)
