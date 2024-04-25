#' @title Batch Optimization Context
#'
#' @description
#' A [CallbackBatch] accesses and modifies data during the optimization via the `ContextBatch`.
#' See the section on active bindings for a list of modifiable objects.
#' See [callback_batch()] for a list of stages which that `ContextBatch`.
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
      self$instance = assert_class(instance, "OptimInstanceBatch")
      self$optimizer = assert_class(optimizer, "OptimizerBatch")
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
