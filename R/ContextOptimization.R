#' @title Optimization Context
#'
#' @description
#' This [Context] can access the
#' * `instance` - [OptimInstance]
#' * `optimizer` - [Optimizer]
#' * `result` - Optimization result
#'
#' ```
#' on_optimization_begin
#'     on_optimizer_before_eval
#'         on_eval_after_design
#'         on_eval_after_benchmark
#'         on_eval_after_aggregation
#'     on_result_begin
#'     on_result_end
#'     on_optimization_after_eval
#' on_optimization_end
#' ```
#'
#' @export
ContextOptimization = R6Class("ContextOptimization",
  inherit = Context,
  public = list(
    #' @field instance ([OptimInstance])\cr
    #'   Instance.
    instance = NULL,

    #' @field optimizer ([Optimizer])\cr
    #'   Optimizer.
    optimizer = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param instance ([OptimInstance])\cr
    #'   Instance.
    #' @param optimizer ([Optimizer])\cr
    #'   Optimizer.
    initialize = function(instance, optimizer) {
      self$instance = assert_class(instance, "OptimInstance")
      self$optimizer = assert_class(optimizer, "Optimizer")
    }
  ),

  active = list(

    #' @field result ([data.table::data.table])\cr
    #'   Result.
    result = function(rhs) {
      if (missing(rhs)) {
        get_private(self$instance)$.result
      } else {
        get_private(self$instance, ".result") = rhs
      }
    }
  )
)
