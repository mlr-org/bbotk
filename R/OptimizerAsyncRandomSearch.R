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
#' @template section_progress_bars
#'
#' @source
#' `r format_bib("bergstra_2012")`
#'
#' @export
#' @template example
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
        properties = c("dependencies", "single-crit", "multi-crit"),
        label = "Asynchronous Random Search",
        man = "bbotk::mlr_optimizers_random_search"
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

      while(!inst$is_terminated) {
        # ask
        sampler = SamplerUnif$new(search_space)
        xdt = sampler$sample(1)$data
        xss = transpose_list(xdt)
        xs = xss[[1]][inst$archive$cols_x]
        xs_trafoed = trafo_xs(xs, search_space)
        keys = inst$rush$push_running_task(list(xs),
          extra = list(list(timestamp_xs = Sys.time())))

        # eval
        ys = inst$objective$eval(xs_trafoed)

        # tell
        rush$push_results(keys, yss = list(ys), extra = list(list(
          x_domain = list(xs_trafoed),
          timestamp_ys = Sys.time())))
      }
    }
  )
)

mlr_optimizers$add("async_random_search", OptimizerAsyncRandomSearch)


