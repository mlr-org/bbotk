#' @title Multi Criteria Optimization Instance for Asynchronous Optimization
#'
#' @description
#' The [OptimInstanceAsyncMultiCrit] specifies an optimization problem for an [OptimizerAsync].
#' The function [oi_async()] creates an [OptimInstanceAsyncMultiCrit].
#'
#' @template param_objective
#' @template param_search_space
#' @template param_terminator
#' @template param_check_values
#' @template param_callbacks
#' @template param_archive
#' @template param_rush
#'
#' @template param_xdt
#'
#' @export
#' @examples
#' # example only runs if a Redis server is available
#' if (mlr3misc::require_namespaces(c("rush", "redux", "mirai"), quietly = TRUE) &&
#'   redux::redis_available()) {
#' # define the objective function
#' fun = function(xs) {
#'   data.table(
#'     y1 = xs$x1^2 +  xs$x2^2,
#'     y2 = (xs$x1 - 2)^2 + (xs$x2 - 1)^2
#'   )
#' }
#'
#' # set domain
#' domain = ps(
#'   x1 = p_dbl(-5, 5),
#'   x2 = p_dbl(-5, 5)
#' )
#'
#' # set codomain
#' codomain = ps(
#'   y1 = p_dbl(tags = "minimize"),
#'   y2 = p_dbl(tags = "minimize")
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
#' # start workers
#' rush::rush_plan(worker_type = "remote")
#' mirai::daemons(1)
#'
#' # initialize instance
#' instance = oi_async(
#'   objective = objective,
#'   terminator = trm("evals", n_evals = 100))
#' }
OptimInstanceAsyncMultiCrit = R6Class("OptimInstanceAsyncMultiCrit",
  inherit = OptimInstanceAsync,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(
      objective,
      search_space = NULL,
      terminator,
      check_values = FALSE,
      callbacks = NULL,
      archive = NULL,
      rush = NULL
      ) {
      if (objective$codomain$target_length == 1) {
        stop("Codomain length must be greater than 1.")
      }
      super$initialize(
        objective = objective,
        search_space = search_space,
        terminator = terminator,
        check_values = check_values,
        rush = rush,
        callbacks = callbacks,
        archive = archive,
        label = "Async Multi Criteria Instance",
        man = "bbotk::OptimInstanceAsyncMultiCrit")
    },

    #' @description
    #' The [OptimizerAsync] writes the best found points and estimated performance values here (probably the Pareto set / front).
    #' For internal use.
    #'
    #' @param ydt (`numeric(1)`)\cr
    #' Optimal outcomes, e.g. the Pareto front.
    #' @param extra (`data.table::data.table()`)\cr
    #' Additional information.
    #' @param ... (`any`)\cr
    #' ignored.
    assign_result = function(xdt, ydt, extra = NULL, ...) {
     # assign for callbacks
      private$.result_xdt = xdt
      private$.result_ydt = ydt
      private$.result_extra = extra

      call_back("on_result_begin", self$objective$callbacks, self$objective$context)

      # assert inputs
      assert_data_table(private$.result_xdt)
      assert_names(names(private$.result_xdt), must.include = self$search_space$ids())
      assert_data_table(private$.result_ydt)
      assert_names(names(private$.result_ydt), permutation.of = self$objective$codomain$ids())
      assert_data_table(private$.result_extra, null.ok = TRUE)

      # add x_domain to result
      x_domain = transform_xdt_to_xss(private$.result_xdt, self$search_space)
      if (length(x_domain) == 0) x_domain = list(list())

      private$.result = cbind(private$.result_xdt, x_domain = x_domain, private$.result_ydt)
      call_back("on_result_end", self$objective$callbacks, self$objective$context)
    }
  ),

  active = list(

    #' @field result_x_domain (`list()`)\cr
    #' (transformed) x part of the result in the *domain space* of the objective.
    result_x_domain = function() {
      private$.result$x_domain
    },

    #' @field result_y (`numeric(1)`)\cr
    #' Optimal outcome.
    result_y = function() {
      private$.result[, self$objective$codomain$ids(), with = FALSE]
    }
  ),

  private = list(
    # intermediate objects
    .result_ydt = NULL
  )
)
