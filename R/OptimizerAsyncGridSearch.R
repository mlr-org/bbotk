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
#' optimizer = opt("async_grid_search", resolution = 10)
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
        properties = c("dependencies", "single-crit", "multi-crit", "async"),
        packages = "rush",
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
      # evaluate grid points
      get_private(inst)$.eval_queue()
    }
  )
)

mlr_optimizers$add("async_grid_search", OptimizerAsyncGridSearch)

