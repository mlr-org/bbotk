
#' @title Map
#'
#' @description
#' Describes a function (domain) -> (codomain)
#'
#' domain, codomain: ParamSet
#' fun: function. takes 1 list argument and returns a list, with positions and names agreeing with
#' domain, codomain
#'
#'
#' fun must be given as a function of two arguments. The second is set from
#' the param_set. $fun will then only have one parameter.
#'
#' @export
Objective = R6Class("Objective",
  public = list(
    id = NULL,
    fun = NULL,
    domain = NULL,
    codomain = NULL,
    # FIXME: how do we handle constants? we need an example quick
    # constants = NULL,

    initialize = function(fun, domain, codomain, id = "f") {
      assert_function(fun)
      assert_param_set(domain)
      assert_param_set(codomain)
      # FIXME: we need to assert the correct signature of f
      self$fun = fun
      self$domain = domain
      self$codomain = codomain
      self$id = id
    },

    # FIXME: how do we ensure that this can happen in parallel?
    # FIXME: shouldnt the evaluator do this?
    eval = function(dt) {
      # FIXME: this asserts, but we need a better helper for this
      Design$new(self$domain, dt, FALSE)
      ydt = self$fun(dt)
      Design$new(self$codomain, ydt, FALSE)
      return(ydt)
    },

    format = function() {
      sprintf("<%s> '%s'", class(self)[1L], self$id)
    },

    print = function() {
      catf(self$format())
      catf("Domain:")
      print(self$domain)
      catf("Codomain:")
      print(self$codomain)
    }
  )
)

ObjectiveSO = R6Class("ObjectiveSO", inherit = Objective,
  public = list(
    initialize = function(fun, domain, id = "f") {
      codomain = ParamSet$new(list(ParamDbl$new("y")))
      super$initialize(fun, domain, codomain, id)
    }
  )
)


