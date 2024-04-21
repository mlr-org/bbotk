#' @title Async Optimization Context
#'
#' @description
#' The [ContextAsync] allows [mlr3misc::Callback]s to access and modify data while optimization.
#' See section on active bindings for a list of modifiable objects.
#' See [callback_optimization()] for a list of stages which access [ContextAsync].
#'
#' @export
ContextAsync = R6Class("ContextAsync",
  inherit = Context,
  public = list(

    #' @field instance ([OptimInstance]).
    instance = NULL,

    #' @field optimizer ([Optimizer]).
    optimizer = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param instance ([OptimInstance]).
    #' @param optimizer ([Optimizer]).
    initialize = function(instance, optimizer) {
      self$instance = assert_class(instance, "OptimInstanceAsync")
      self$optimizer = assert_class(optimizer, "OptimizerAsync")
    }
  ),

  active = list(

    #' @field result ([data.table::data.table])\cr
    #'   The result of the optimization.
    result = function(rhs) {
      if (missing(rhs)) {
        get_private(self$instance)$.result
      } else {
        get_private(self$instance, ".result") = rhs
      }
    }
  )
)
