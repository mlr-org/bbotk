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
#' @examples
#' # example only runs if a Redis server is available
#' if (mlr3misc::require_namespaces(c("rush", "redux"), quietly = TRUE) && redux::redis_available()) {
#' # define the objective function
#' fun = function(xs) {
#'   list(y = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
#' }
#'
#' # set domain
#' domain = ps(
#'   x1 = p_dbl(-10, 10),
#'   x2 = p_dbl(-5, 5)
#' )
#'
#' # set codomain
#' codomain = ps(
#'   y = p_dbl(tags = "maximize")
#' )
#'
#' # create objective
#' objective = ObjectiveRFun$new(
#'   fun = fun,
#'   domain = domain,
#'   codomain = codomain,
#'   properties = "deterministic"
#' )
#'
#' # initialize instance
#' instance = oi_async(
#'   objective = objective,
#'   terminator = trm("none")
#' )
#'
#' # load optimizer
#' design = data.table(x1 = c(0, 1), x2 = c(0, 1))
#' optimizer = opt("async_design_points", design = design)
#'
#' # trigger optimization
#' optimizer$optimize(instance)
#'
#' # all evaluated configurations
#' instance$archive
#'
#' # best performing configuration
#' instance$archive$best()
#'
#' # covert to data.table
#' as.data.table(instance$archive)
#' }
OptimizerAsyncDesignPoints = R6Class("OptimizerAsyncDesignPoints",
  inherit = OptimizerAsync,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        design = p_uty(tags = "required", custom_check = function(x) check_data_frame(x, min.rows = 1, min.cols = 1, null.ok = TRUE))
      )
      param_set$values = list(design = NULL)
      super$initialize(
        id = "design_points",
        param_set = param_set,
        param_classes = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct", "ParamUty"),
        properties = c("dependencies", "single-crit", "multi-crit", "async"),
        packages = "rush",
        label = "Asynchronous Design Points",
        man = "bbotk::mlr_optimizers_async_design_points"
      )
    },

    #' @description
    #' Starts the asynchronous optimization.
    #'
    #' @param inst ([OptimInstance]).
    #' @return [data.table::data.table].
    optimize = function(inst) {
      # generate grid and send to workers
      design = inst$search_space$assert_dt(self$param_set$values$design)

      optimize_async_default(inst, self, design)
    }
  ),

  private = list(
    .optimize = function(inst) {
      # evaluate design of points
      get_private(inst)$.eval_queue()
    }
  )
)

mlr_optimizers$add("async_design_points", OptimizerAsyncDesignPoints)

