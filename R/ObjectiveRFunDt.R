#' @title Objective interface for basic R functions.
#'
#' @description
#' Objective interface where user can pass an R function that works on an `data.table()`.
#'
#' @template param_domain
#' @template param_codomain
#' @template param_xdt
#' @template param_check_values
#' @template param_constants
#' @export
ObjectiveRFunDt = R6Class("ObjectiveRFunDt",
  inherit = Objective,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param fun (`function`)\cr
    #' R function that encodes objective and expects an `data.table()` as input
    #' whereas each point is represented by one row.
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
      if (is.null(codomain)) {
        codomain = ps(y = p_dbl(tags = "minimize"))
      }
      private$.fun = assert_function(fun, "xdt")
      # asserts id, domain, codomain, properties
      super$initialize(
        id = id,
        domain = domain,
        codomain = codomain,
        properties = properties,
        constants = constants,
        check_values = check_values,
        label = "Objective Custom R Function Eval Data Table",
        man = "bbotk::ObjectiveRFunDt")
    },

    #' @description
    #' Evaluates multiple input values received as a list, converted to a `data.table()` on the
    #' objective function. Missing columns in xss are filled with `NA`s in `xdt`.
    #'
    #' @param xss (`list()`)\cr
    #'   A list of lists that contains multiple x values, e.g.
    #'   `list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4))`.
    #'
    #' @return [data.table::data.table()] that contains one y-column for single-criteria functions
    #' and multiple y-columns for multi-criteria functions, e.g.
    #' `data.table(y = 1:2)` or `data.table(y1 = 1:2, y2 = 3:4)`.
    eval_many = function(xss) {
      if (self$check_values) lapply(xss, self$domain$assert)
      xdt = rbindlist(xss, use.names = TRUE, fill = TRUE)
      # add missing columns
      if (ncol(xdt) < self$domain$length) {
        proto = as.data.table(lapply(self$domain$class, switch,
          ParamFct = NA_character_,
          ParamDbl = NA_real_,
          ParamInt = NA_integer_,
          ParamLgl = NA,
          ParamUty = NA
        ))
        xdt = rbindlist(list(proto, xdt), use.names = TRUE, fill = TRUE)[-1]
      }
      res = invoke(private$.fun, xdt, .args = self$constants$values)
      if (self$check_values) self$codomain$assert_dt(res[, self$codomain$ids(), with = FALSE])
      return(res)
    },

    #' @description
    #' Evaluates multiple input values on the objective function supplied by the user.
    #'
    #' @return data.table::data.table()] that contains one y-column for single-criteria functions
    #' and multiple y-columns for multi-criteria functions, e.g.
    #' `data.table(y = 1:2)` or `data.table(y1 = 1:2, y2 = 3:4)`.
    eval_dt = function(xdt) {
      if (self$check_values) self$domain$assert_dt(xdt)
      res = invoke(private$.fun, xdt, .args = self$constants$values)
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
