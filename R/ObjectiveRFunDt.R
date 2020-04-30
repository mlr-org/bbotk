#' @title Objective interface where user cass pass R function
#'
#' @description
#' Objective interface where user cass pass R function.
#'
#' @export
ObjectiveRFunDt = R6Class("ObjectiveRFunDt",
  inherit = Objective,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' @param fun `function`\cr
    #' R function that encodes objective and expects an `data.table` as input whereas each point is represented by one row.
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
      private$.fun = assert_function(fun, "xdt")
      # asserts id, domain, codomain, properties
      super$initialize(id = id, domain = domain, codomain = codomain,
        properties = properties)
    },

    #' @description
    #' Evaluates multiple input values received as a list, converted to a `data.table` on the objective function.
    #' @param xss `list()`\cr
    #' A list of lists that contains multiple x values, e.g.
    #' `list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4))`.
    #' @return `data.table()`\cr
    #' A `data.table` that contains one y-column for single-objective functions and multiple y-columns for multi-objective functions, e.g.
    #' `data.table(y = 1:2)` or `data.table(y1 = 1:2, y2 = 3:4)`.
    eval_many = function(xs) {
      private$.fun(rbindlist(xs))
    },

    #' @description
    #' Evaluates multiple input values on the objective function suplied by the user.
    #' @param xdt `data.table()`\cr
    #' A `data.table` that contains one point to evaluate per row, e.g.
    #' `data.table(x1 = c(1,3), x2 = c(2,4))`.
    #' @return `data.table()`\cr
    #' A `data.table` that contains one y-column for single-objective functions and multiple y-columns for multi-objective functions, e.g.
    #' `data.table(y = 1:2)` or `data.table(y1 = 1:2, y2 = 3:4)`.
    eval_dt = function(xdt) {
      private$.fun(xdt)
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
