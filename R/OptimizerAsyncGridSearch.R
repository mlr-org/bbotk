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

      # generate grid and send to workers
      pv = self$param_set$values
      design = generate_design_grid(inst$search_space, resolution = pv$resolution, param_resolutions = pv$param_resolutions)$data
      inst$archive$push_points(transpose_list(design))

      # start workers
      start_async_optimize(inst, self, private)

      # print logs and check for termination
      wait_for_async_optimize(inst, self, private, n_evals = nrow(design))

      # assign and print results
      finish_async_optimize(inst, self, private)
    }
  ),

  private = list(
    .optimize = function(inst) {
      archive = inst$archive

      # evaluate grid points
      while (archive$n_queued && !inst$is_terminated) {
        task = archive$pop_point() # FIXME: Add fields argument?
        xs_trafoed = trafo_xs(task$xs, inst$search_space)
        ys = inst$objective$eval(xs_trafoed)
        archive$push_result(task$key, ys, x_domain = xs_trafoed)
      }
    }
  )
)

mlr_optimizers$add("async_grid_search", OptimizerAsyncGridSearch)

