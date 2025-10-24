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
#' @examplesIf mlr3misc::require_namespaces(c("rush", "redux"), quietly = TRUE) && redux::redis_available()
#' @examples
#' # example only runs if a Redis server is available
#' \donttest{
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
#'   terminator = trm("evals", n_evals = 20)
#' )
#'
#' # load optimizer
#' optimizer = opt("async_random_search")
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


