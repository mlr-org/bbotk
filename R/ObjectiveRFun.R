#FIXME: ist das mit dem evaluate, evaluate_checked so sinnvoll?
#kann man die checks nur in der instance vielleicht machen? per flag an und aus?


#' @title Objective interface where user cass pass R function
#'
#' @usage NULL
#' @format [R6::R6Class] object.
#'
#' @description
#'
#' @section Construction:
#' ```
#' obj = ObjectiveRFun$new(fun, domain, codomain = NULL, id = "function", properties = character(0))
#' ```
#' * `objective` :: [Objective].
#' * `param_set` :: [ParamSet].
#' * `terminator` :: [Terminator].
#'
#' @export
ObjectiveRFun = R6Class("ObjectiveRFun",
  inherit = Objective,
  public = list(
    initialize = function(fun, domain, codomain = NULL, id = "function", properties = character(0)) {
      if (is.null(codomain))
        codomain = ParamSet$new(list(ParamDbl$new("y", tags = "minimize")))
      private$.fun = assert_function(fun, "xs")
      # asserts id, domain, codomain, properties
      super$initialize(id = id, domain = domain, codomain = codomain, properties = properties)
    },

    evaluate = function(x) {
      private$.fun(x)
    }
  ),

  active = list(
    fun = function(lhs) {
      if (!missing(lhs) && !identical(lhs, private$.fun)) stop("fun is read-only")
      private$.fun
    }
  ),

  private = list(
    .fun = NULL
  )
)
