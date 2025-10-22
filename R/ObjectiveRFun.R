#' @title Objective interface with custom R function
#'
#' @description
#' Objective interface where the user can pass a custom R function that expects a list as input.
#' If the return of the function is unnamed, it is named with the ids of the codomain.
#'
#' @template param_domain
#' @template param_codomain
#' @template param_check_values
#' @template param_constants
#' @template param_packages
#'
#' @export
#' @examples
#' # define objective function
#' fun = function(xs) {
#'   -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10
#' }
#'
#' # set domain
#' domain = ps(
#'   x1 = p_dbl(-10, 10),
#'   x2 = p_dbl(-5, 5)
#' )
#'
#' # set codomain
#' codomain = ps(y = p_dbl(tags = "maximize"))
#'
#' # create Objective object
#' obfun = ObjectiveRFun$new(
#'   fun = fun,
#'   domain = domain,
#'   codomain = codomain,
#'   properties = "deterministic"
#' )
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
    initialize = function(
      fun,
      domain,
      codomain = NULL,
      id = "function",
      properties = character(),
      constants = ps(),
      packages = character(),
      check_values = TRUE
      ) {
      if (is.null(codomain)) {
        codomain = ps(y = p_dbl(tags = "minimize"))
      }
      private$.fun = assert_function(fun, "xs")
      # asserts id, domain, codomain, properties
      super$initialize(
        id = id,
        domain = domain,
        codomain = codomain,
        properties = properties,
        constants = constants,
        packages = packages,
        check_values = check_values,
        label = "Objective Custom R Function",
        man = "bbotk::ObjectiveRFun")
    },

    #' @description
    #' Evaluates input value(s) on the objective function. Calls the R function
    #' supplied by the user.
    #' @param xs Input values.
    eval = function(xs) {
      if (self$check_values) self$domain$assert(xs)
      res = invoke(private$.fun, xs, .args = self$constants$values)
      if (!test_named(res)) names(res)[seq_len(self$codomain$length)] = self$codomain$ids()
      if (self$check_values) self$codomain$assert(as.list(res)[self$codomain$ids()])
      return(res)
    }
  ),

  active = list(

    #' @field fun (`function`)\cr
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
