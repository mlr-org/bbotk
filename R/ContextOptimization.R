#' @title Optimization Context
#'
#' @description
#' The [ContextBatch] allows [mlr3misc::Callback]s to access and modify data while optimization.
#' See section on active bindings for a list of modifiable objects.
#' See [callback_optimization()] for a list of stages which access [ContextBatch].
#'
#' @export
ContextBatch = R6Class("ContextBatch",
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
      self$instance = assert_multi_class(instance, c("OptimInstance", "OptimInstanceAsync"))
      self$optimizer = optimizer
    }
  ),

  active = list(

    #' @field xdt ([data.table::data.table])\cr
    #'   The points of the latest batch.
    #'   Contains the values in the search space i.e. transformations are not yet applied.
    xdt = function(rhs) {
      if (missing(rhs)) {
        get_private(self$instance)$.xdt
      } else {
        get_private(self$instance)$.xdt = rhs
      }
    },

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
