#' @title Optimization via Grid Search
#'
#' @include Optimizer.R
#' @name mlr_optimizers_grid_search
#'
#' @description
#' `OptimizerBatchGridSearch` class that implements grid search. The grid is
#' constructed as a Cartesian product over discretized values per parameter, see
#' [paradox::generate_design_grid()]. The points of the grid are evaluated in a
#' random order.
#'
#' In order to support general termination criteria and parallelization, we
#' evaluate points in a batch-fashion of size `batch_size`. Larger batches mean
#' we can parallelize more, smaller batches imply a more fine-grained checking
#' of termination criteria.
#'
#' @templateVar id grid_search
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' \describe{
#' \item{`resolution`}{`integer(1)`\cr
#' Resolution of the grid, see [paradox::generate_design_grid()].}
#' \item{`param_resolutions`}{named `integer()`\cr
#' Resolution per parameter, named by parameter ID, see
#' [paradox::generate_design_grid()].}
#' \item{`batch_size`}{`integer(1)`\cr
#' Maximum number of points to try in a batch.}
#' }
#'
#' @template section_progress_bars
#'
#' @export
#' @template example
OptimizerBatchGridSearch = R6Class("OptimizerBatchGridSearch", inherit = OptimizerBatch,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        batch_size = p_int(lower = 1L, tags = "required"),
        resolution = p_int(lower = 1L),
        param_resolutions = p_uty()
      )
      param_set$values = list(resolution = 10L, batch_size = 1L)
      super$initialize(
        id = "grid_search",
        param_set = param_set,
        param_classes = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct"),
        properties = c("dependencies", "single-crit", "multi-crit"),
        label = "Grid Search",
        man = "bbotk::mlr_optimizers_grid_search"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      pv = self$param_set$values
      g = generate_design_grid(inst$search_space, resolution = pv$resolution,
        param_resolutions = pv$param_resolutions)
      ch = chunk_vector(seq_row(g$data), chunk_size = pv$batch_size,
        shuffle = TRUE)
      for (inds in ch) {
        inst$eval_batch(g$data[inds])
      }
    }
  )
)

mlr_optimizers$add("grid_search", OptimizerBatchGridSearch)
