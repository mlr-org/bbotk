#' @title Asynchronous Optimization Context
#'
#' @description
#' A [CallbackAsync] accesses and modifies data during the optimization via the `ContextAsync`.
#' See the section on active bindings for a list of modifiable objects.
#' See [callback_async()] for a list of stages which access `ContextAsync`.
#'
#' @details
#' Changes to `$instance` and `$optimizer` in the stages executed on the workers are not reflected in the main process.
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
