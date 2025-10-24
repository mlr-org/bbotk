#' @title Batch Optimization Context
#'
#' @description
#' A [CallbackBatch] accesses and modifies data during the optimization via the `ContextBatch`.
#' See the section on active bindings for a list of modifiable objects.
#' See [callback_batch()] for a list of stages which that `ContextBatch`.
#'
#' @seealso [CallbackBatch]
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
    #' @param inst ([OptimInstance]).
    #' @param optimizer ([Optimizer]).
    initialize = function(inst, optimizer) {
      self$instance = assert_instance_batch(inst)
      self$optimizer = optimizer
    }
  ),

  active = list(

    #' @field xdt ([data.table::data.table])\cr
    #' The points of the latest batch in `instance$eval_batch()`.
    #' Contains the values in the search space i.e. transformations are not yet applied.
    xdt = function(rhs) {
      if (missing(rhs)) {
        get_private(self$instance)$.xdt
      } else {
        get_private(self$instance)$.xdt = rhs
      }
    },

    #' @field result_xdt ([data.table::data.table])\cr
    #' The xdt passed to `instance$assign_result()`.
    result_xdt = function(rhs) {
      if (missing(rhs)) {
        return(get_private(self$instance)$.result_xdt)
      } else {
        self$instance$.__enclos_env__$private$.result_xdt = rhs
      }
    },

    #' @field result_y (`numeric(1)`)\cr
    #' The y passed to `instance$assign_result()`.
    #' Only available for single criterion optimization.
    result_y = function(rhs) {
      if (missing(rhs)) {
        return(get_private(self$instance)$.result_y)
      } else {
        self$instance$.__enclos_env__$private$.result_y = rhs
      }
    },

    #' @field result_ydt ([data.table::data.table])\cr
    #' The ydt passed to `instance$assign_result()`.
    #' Only available for multi criterion optimization.
    result_ydt = function(rhs) {
      if (missing(rhs)) {
        return(get_private(self$instance)$.result_ydt)
      } else {
        self$instance$.__enclos_env__$private$.result_ydt = rhs
      }
    },

    #' @field result_extra ([data.table::data.table])\cr
    #' Additional information about the result passed to `instance$assign_result()`.
    result_extra = function(rhs) {
      if (missing(rhs)) {
        get_private(self$instance)$.result_extra
      } else {
        get_private(self$instance, ".result_extra") = rhs
      }
    },

    #' @field result ([data.table::data.table])\cr
    #' The result of the optimization in `instance$assign_result()`.
    result = function(rhs) {
      if (missing(rhs)) {
        get_private(self$instance)$.result
      } else {
        get_private(self$instance, ".result") = rhs
      }
    }
  )
)
