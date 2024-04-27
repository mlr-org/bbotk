#' @title Asynchronous Optimization via Grid Search
#'
#' @include OptimizerAsync.R
#' @name mlr_optimizers_async_grid_search
#'
#' @description
#' `OptimizerAsyncGridSearch` class that implements a grid search.
#' The grid is constructed as a Cartesian product over discretized values per parameter, see [paradox::generate_design_grid()].
#' The points of the grid are evaluated in a random order.
#'
#' @templateVar id async_grid_search
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' \describe{
#' \item{`batch_size`}{`integer(1)`\cr
#' Maximum number of points to try in a batch.}
#' }
#'
#'
#' @source
#' `r format_bib("bergstra_2012")`
#'
#' @export
OptimizerAsyncGridSearch = R6Class("OptimizerAsyncGridSearch",
  inherit = OptimizerAsync,

  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        resolution = p_int(lower = 1L),
        param_resolutions = p_uty()
      )
      param_set$values = list(resolution = 10L)

      super$initialize(
        id = "async_grid_search",
        param_set = param_set,
        param_classes = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct"),
        properties = c("dependencies", "single-crit", "multi-crit"),
        label = "Asynchronous Grid Search",
        man = "bbotk::mlr_optimizers_async_grid_search"
      )
    },

    #' @description
    #' Starts the asynchronous optimization.
    #'
    #' @param inst ([OptimInstance]).
    #' @return [data.table::data.table].
    optimize = function(inst) {

      # generate grid
      pv = self$param_set$values
      design = generate_design_grid(inst$search_space, resolution = pv$resolution, param_resolutions = pv$param_resolutions)$data

      optimize_async_default(inst, self, design)
    }
  ),

  private = list(
    .optimize = function(inst) {
      archive = inst$archive

      # evaluate grid points
      evaluate_queue_default(inst)
    }
  )
)

mlr_optimizers$add("async_grid_search", OptimizerAsyncGridSearch)

