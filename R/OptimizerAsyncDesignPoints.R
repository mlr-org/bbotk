#' @title Asynchronous Optimization via Design Points
#'
#' @include OptimizerAsync.R
#' @name mlr_optimizers_async_design_points
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
#'   Design points to try in search, one per row.}
#' }
#'
#' @export
OptimizerAsyncDesignPoints = R6Class("OptimizerAsyncDesignPoints",
  inherit = OptimizerAsync,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        design = p_uty(tags = "required", custom_check = function(x) check_data_table(x, min.rows = 1, min.cols = 1, null.ok = TRUE))
      )
      param_set$values = list(design = NULL)
      super$initialize(
        id = "design_points",
        param_set = param_set,
        param_classes = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct", "ParamUty"),
        properties = c("dependencies", "single-crit", "multi-crit"),
        label = "Design Points",
        man = "bbotk::mlr_optimizers_async_design_points"
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
      design = inst$search_space$assert_dt(self$param_set$values$design)
      inst$archive$push_points(transpose_list(design))

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
      while (!inst$is_terminated) {
        task = archive$pop_point() # FIXME: Add fields argument?
         if (!is.null(task)) {
          xs_trafoed = trafo_xs(task$xs, inst$search_space)
          ys = inst$objective$eval(xs_trafoed)
          archive$push_result(task$key, ys, x_domain = xs_trafoed)
         }
      }
    }
  )
)

mlr_optimizers$add("async_design_points", OptimizerAsyncDesignPoints)
