#' @title Objective interface where user cass pass R function
#'
#' @description
#' Objective interface where user cass pass R function.
#'
#' @export
ObjectiveRFun = R6Class("ObjectiveRFun",
  inherit = Objective,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' @param fun `function`\cr
    #' R function that encodes objective.
    #' @param domain [paradox::ParamSet]\cr
    #' Specifies domain of function, hence its innput parameters, their types
    #' and ranges.
    #' @param codomain [paradox::ParamSet]\cr
    #' Specifies codomain of function, hence its feasible values.
    #' @param id `character(1)`
    #' @param properties `character()`
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
    #' @param x Input values.
    eval = function(x) {
      private$.fun(x)
    }
  ),

  active = list(

    #' @field fun `function`\cr
    #' Objective function.
    fun = function(lhs) {
      if (!missing(lhs) && !identical(lhs, private$.fun)) stop("fun is read-only")
      private$.fun
    }
  ),

  private = list(
    .fun = NULL
  )
)

# FIXME: ist das mit dem evaluate, evaluate_checked so sinnvoll?
# kann man die checks nur in der instance vielleicht machen? per flag an und aus?
