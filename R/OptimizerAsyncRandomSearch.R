#' @title Asynchronous Optimization via Random Search
#'
#' @include OptimizerAsync.R
#' @name mlr_optimizers_async_random_search
#'
#' @description
#' `OptimizerAsyncRandomSearch` class that implements a simple Random Search.
#'
#' @templateVar id async_random_search
#' @template section_dictionary_optimizers
#'
#' @source
#' `r format_bib("bergstra_2012")`
#'
#' @export
OptimizerAsyncRandomSearch = R6Class("OptimizerAsyncRandomSearch",
  inherit = OptimizerAsync,

  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(
        id = "async_random_search",
        param_set = ps(),
        param_classes = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct"),
        properties = c("dependencies", "single-crit", "multi-crit", "async"),
        packages = "rush",
        label = "Asynchronous Random Search",
        man = "bbotk::mlr_optimizers_random_search"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      search_space = inst$search_space

      # usually the queue is empty but callbacks might have added points
      get_private(inst)$.eval_queue()

      while(!inst$is_terminated) {
        # sample new points
        sampler = SamplerUnif$new(search_space)
        xdt = sampler$sample(1)$data
        xs = transpose_list(xdt)[[1]]

        # evaluate
        get_private(inst)$.eval_point(xs)
      }
    }
  )
)

mlr_optimizers$add("async_random_search", OptimizerAsyncRandomSearch)


