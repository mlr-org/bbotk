#' @title Objective Interface with Custom R Function
#'
#' @description
#' Objective interface where the user can pass a custom R function that expects a list of configurations as input.
#' If the return of the function is unnamed, it is named with the ids of the codomain.
#'
#' @template param_domain
#' @template param_codomain
#' @template param_check_values
#' @template param_constants
#'
#' @export
#' @examples
#' # define objective function
#' fun = function(xss) {
#'   res = lapply(xss, function(xs) -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
#'   data.table(y = as.numeric(res))
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
#' obfun = ObjectiveRFunMany$new(
#'   fun = fun,
#'   domain = domain,
#'   codomain = codomain,
#'   properties = "deterministic"
#' )
ObjectiveRFunMany = R6Class("ObjectiveRFunMany",
  inherit = Objective,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param fun (`function`)\cr
    #' R function that encodes objective and expects a list of lists that contains multiple x values, e.g. `list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4))`.
    #' The function must return a [data.table::data.table()] that contains one y-column for single-criteria functions and multiple y-columns for multi-criteria functions, e.g.  `data.table(y = 1:2)` or `data.table(y1 = 1:2, y2 = 3:4)`.
    #'
    #' @param id (`character(1)`).
    #' @param properties (`character()`).
    initialize = function(
      fun,
      domain,
      codomain = NULL,
      id = "function",
      properties = character(),
      constants = ps(),
      check_values = TRUE
      ) {
      if (is.null(codomain)) codomain = ps(y = p_dbl(tags = "minimize"))
      private$.fun = assert_function(fun, "xss")
      # asserts id, domain, codomain, properties
      super$initialize(
        id = id,
        domain = domain,
        codomain = codomain,
        properties = properties,
        constants = constants,
        check_values = check_values)
    },

    #' @description
    #' Evaluates input value(s) on the objective function.
    #' Calls the R function supplied by the user.
    #'
    #' @param xss (`list()`)\cr
    #'   A list of lists that contains multiple x values, e.g. `list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4))`.
    #'
    #' @return [data.table::data.table()] that contains one y-column for single-criteria functions and multiple y-columns for multi-criteria functions, e.g.  `data.table(y = 1:2)` or `data.table(y1 = 1:2, y2 = 3:4)`.
    #' It may also contain additional columns that will be stored in the archive if called through the [OptimInstance].
    #' These extra columns are referred to as *extras*.
    eval_many = function(xss) {
      if (self$check_values) lapply(xss, self$domain$assert)
      res = invoke(private$.fun, xss, .args = self$constants$values)
      if (!test_named(res)) names(res)[seq_len(self$codomain$length)] = self$codomain$ids()
      if (self$check_values) self$codomain$assert_dt(res[, self$codomain$ids(), with = FALSE])
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
