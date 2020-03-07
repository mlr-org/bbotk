
#' @title Objective function with domain and co-domain
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
    #FIXME: we need to assert based on ydim
    minimize = NULL,

    initialize = function(fun, domain, ydim = 1L, minimize, id = "f") {
      # FIXME: we need to assert the correct signature of f
      self$fun = assert_function(fun)
      self$domain = assert_param_set(domain)
      ydim = assert_int(ydim, lower = 1L)
      # FIXME: y-id is magic const
      # FIXME: the names of cod are now y_repl_1 a bit ugly, better y1?
      self$codomain = ParamDbl$new("y")$rep(ydim)
      self$minimize = assert_logical(minimize, len = ydim)
      self$id = assert_string(id)
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
  ),

  active = list(
    xdim = function() self$domain$length,
    ydim = function() self$codomain$length
  )
)


#' @export
assert_objective = function(x, ydim = NULL) {
  assert_r6(x, "Objective")
  if (!is.null()) # FIXME: better error message here
    assert_equal(x$ydim, ydim)
}
