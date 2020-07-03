#' @title Objective interface with custom R function
#'
#' @description
#' Objective interface where the user can pass a custom R function that expects a list as input.
#'
#' @template param_domain
#' @template param_codomain
#' @export
ObjectiveRFun = R6Class("ObjectiveRFun",
  inherit = Objective,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param fun (`function`)\cr
    #' R function that encodes objective and expects a list with the input for a single point
    #' (e.g. `list(x1 = 1, x2 = 2)`) and returns the result either as a numeric vector or a
    #' list (e.g. `list(y = 3)`).
    #' @param id (`character(1)`).
    #' @param properties (`character()`).
    initialize = function(fun, domain, codomain = NULL, id = "function",
      properties = character(0)) {
      if (is.null(codomain)) {
        codomain = ParamSet$new(list(ParamDbl$new("y", tags = "minimize")))
      }
      private$.fun = assert_function(fun, "xs")
      # asserts id, domain, codomain, properties
      super$initialize(id = id, domain = domain, codomain = codomain,
        properties = properties)
    },

    #' @description
    #' Evaluates input value(s) on the objective function. Calls the R function
    #' supplied by the user.
    #' @param xs Input values.
    eval = function(xs) {
      private$.fun(xs)
    }
  ),

  active = list(

    #' @field fun (`function`)\cr
    #'   Objective function.
    fun = function(lhs) {
      if (!missing(lhs) && !identical(lhs, private$.fun)) stop("fun is read-only")
      private$.fun
    }
  ),

  private = list(
    .fun = NULL
  )
)
