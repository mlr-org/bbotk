#' @title Asynchronous Optimization via Design Points
#'
#' @include Optimizer.R
#' @name mlr_optimizers_design_points
#'
#' @description
#' `OptimizerAsyncDesignPoints` class that implements optimization w.r.t. fixed design points.
#' We simply search over a set of points fully specified by the ser.
#'
#' @templateVar id async_design_points
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' \describe{
#' \item{`design`}{[data.table::data.table]\cr
#' Design points to try in search, one per row.}
#' }
#'
#' @template section_progress_bars
#'
#' @export
OptimizerAsyncDesignPoints = R6Class("OptimizerAsyncDesignPoints",
  inherit = OptimizerAsync,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        batch_size = p_int(lower = 1L, tags = "required"),
        design = p_uty(tags = "required", custom_check = function(x) {
          check_data_table(x, min.rows = 1, min.cols = 1, null.ok = TRUE)
        })
      )
      param_set$values = list(batch_size = 1L, design = NULL)
      super$initialize(
        id = "design_points",
        param_set = param_set,
        param_classes = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct", "ParamUty"),
        properties = c("dependencies", "single-crit", "multi-crit"),
        label = "Design Points",
        man = "bbotk::mlr_optimizers_design_points"
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
      design = instance$search_space$assert_dt(self$param_set$values$design)
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

mlr_optimizers$add("async_design_points", OptimizerAsyncDesignPoints)
