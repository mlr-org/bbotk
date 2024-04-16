#' @title Asynchronous Optimization via Grid Search
#'
#' @include Optimizer.R
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
#' @template section_progress_bars
#'
#' @source
#' `r format_bib("bergstra_2012")`
#'
#' @export
#' @template example
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
      # start workers
      start_async_optimize(inst, self, private)

      # generate grid and send to workers
      pv = self$param_set$values
      design = generate_design_grid(inst$search_space, resolution = pv$resolution, param_resolutions = pv$param_resolutions)$data
      inst$rush$push_tasks(transpose_list(design), extra = list(list(timestamp_xs = Sys.time())))

      # print logs and check for termination
      wait_for_async_optimize(inst, self, private)

      # assign and print results
      finish_async_optimize(inst, self, private)
    }
  ),

  private = list(
    .optimize = function(inst) {
      search_space = inst$search_space
      rush = inst$rush

      # evaluate grid points
      while (rush$n_queued_tasks && !inst$is_terminated) {
        task = rush$pop_task(fields = "xs")
        xs_trafoed = trafo_xs(task$xs, inst$search_space)
        ys = inst$objective$eval(xs_trafoed)
        rush$push_results(
          task$key,
          yss = list(ys),
          extra = list(list(x_domain = list(xs_trafoed),
          timestamp_ys = Sys.time())))
      }
    }
  )
)

mlr_optimizers$add("async_grid_search", OptimizerAsyncGridSearch)


