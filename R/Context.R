#' @title Instance Context
#'
#' @description
#' Context
#'
#' @export
ContextInstance = R6Class("ContextInstance",
  public = list(
    #' @field instance ([OptimInstance])\cr
    #'   Instance.
    instance = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param instance ([OptimInstance])\cr
    #'   Instance.
    initialize = function(instance) {
      self$instance = assert_r6(instance, "OptimInstance")
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
