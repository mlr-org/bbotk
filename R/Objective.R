#' @title Objective function with domain and co-domain
#'
#' @description
#' Describes a black-box objective function that maps an arbitrary domain to a
#' numerical codomain.
#'
#' @template param_domain
#' @template param_codomain
#' @template param_xdt
#' @export
Objective = R6Class("Objective",
  public = list(

    #' @field id (`character(1)`)).
    id = NULL,

    #' @field properties (`character()`).
    properties = NULL,

    #' @field domain ([paradox::ParamSet])\cr
    #' Specifies domain of function, hence its input parameters, their types
    #' and ranges.
    domain = NULL,

    #' @field codomain ([paradox::ParamSet])\cr
    #' Specifies codomain of function, hence its feasible values.
    codomain = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param id (`character(1)`).
    #' @param properties (`character()`).
    initialize = function(id = "f", properties = character(), domain,
      codomain = ParamSet$new(list(ParamDbl$new("y", tags = "minimize")))) {
      self$id = assert_string(id)
      self$domain = assert_param_set(domain)
      self$codomain = assert_codomain(codomain)
      self$properties = assert_subset(properties, bbotk_reflections$objective_properties)
    },

    #' @description
    #' Helper for print outputs.
    #' @return `character()`
    format = function() {
      sprintf("<%s:%s>", class(self)[1L], self$id)
    },

    #' @description
    #' Print method.
    #' @return `character()`
    print = function() {
      catf(self$format())
      catf("Domain:")
      print(self$domain)
      catf("Codomain:")
      print(self$codomain)
    },

    #' @description
    #' Evaluates a single input value on the objective function
    #'
    #' @param xs (`list()`)\cr
    #'   A list that contains a single x value, e.g. `list(x1 = 1, x2 = 2)`.
    #'
    #' @return `list()` that contains the result of the evaluation, e.g. `list(y = 1)`.
    #' The list can also contain additional *named* entries that will be stored in the
    #' archive if called through the [OptimInstance].
    #' These extra entries are referred to as *extras*.
    eval = function(xs) {
      as.list(self$eval_many(list(xs)))
    },

    #' @description
    #' Evaluates multiple input values on the objective function.
    #' *bbotk* does not take care of parallelization.
    #' If the function should make use of parallel computing,
    #' it has to be implemented by deriving from this class and
    #' overwriting this function.
    #'
    #' @param xss (`list()`)\cr
    #'   A list of lists that contains multiple x values, e.g.
    #'   `list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4))`.
    #'
    #' @return `data.table()`\cr
    #' A `data.table` that contains one y-column for single-criteria functions and
    #' multiple y-columns for multi-criteria functions, e.g.
    #' `data.table(y = 1:2)` or `data.table(y1 = 1:2, y2 = 3:4)`.
    #' It may also contain additional columns that will be stored in the archive if
    #' called through the [OptimInstance].
    #' These extra columns are referred to as *extras*.
    eval_many = function(xss) {
      res = map_dtr(xss, function(xs) {
        ys = self$eval(xs)
        as.data.table(lapply(ys, function(y) if (is.list(y)) list(y) else y))
      })
      # to keep it simple we expect the order of the results to be right. extras keep their names
      colnames(res)[seq_len(self$codomain$length)] = self$codomain$ids()
      return(res)
    },

    #' @description
    #' Evaluates multiple input values on the objective function
    #'
    #' @return `data.table()`\cr
    #' A `data.table` that contains one y-column for single-criteria functions and
    #' multiple y-columns for multi-criteria functions, e.g.
    #' `data.table(y = 1:2)` or `data.table(y1 = 1:2, y2 = 3:4)`.
    eval_dt = function(xdt) {
      self$eval_many(transpose_list(xdt))
    },

    #' @description
    #' Evaluates a single input value on the objective function and checks its
    #' validity as well as the validity of the result.
    #' Note: Calling the objective this way will fail if the function returns extras (see above)
    #' because the output is checked against the codomain.
    #'
    #' @param xs (`list()`)\cr
    #' A list that contains a single x value, e.g. `list(x1 = 1, x2 = 2)`.
    #'
    #' @return `list()`\cr
    #' A list that contains the result of the evaluation, e.g. `list(y = 1)`.
    eval_checked = function(xs) {
      self$domain$assert(xs)
      res = self$eval(xs)
      self$codomain$assert(res) #FIXME: Does not allow extras do be returned
      return(res)
    },

    #' @description
    #' Evaluates multiple input values on the objective function and checks the
    #' validity of the input.
    #'
    #' @param xss (`list()`)\cr
    #' A list of lists that contains multiple x values, e.g.
    #' `list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4))`.
    #'
    #' @return `data.table()`\cr
    #' A `data.table` that contains one y-column for single-criteria functions and multiple
    #' y-columns for multi-criteria functions, e.g.
    #' `data.table(y = 1:2)` or `data.table(y1 = 1:2, y2 = 3:4)`.
    eval_many_checked = function(xss) {
      lapply(xss, self$domain$assert)
      res = self$eval_many(xss)
      # lapply(res, self$codomain$assert) #FIXME: Does not work easily if res is dt
    }
  ),

  active = list(
    #' @field xdim (`ìnteger(1)`)\cr
    #' Dimension of domain.
    xdim = function() self$domain$length,

    #' @field ydim (`ìnteger(1)`)\cr
    #' Dimension of codomain.
    ydim = function() self$codomain$length
  )
)
