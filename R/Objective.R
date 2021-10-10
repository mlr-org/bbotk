#' @title Objective function with domain and co-domain
#'
#' @description
#' Describes a black-box objective function that maps an arbitrary domain to a
#' numerical codomain.
#'
#' @section Technical details:
#' `Objective` objects can have the following properties: `"noisy"`,
#' `"deterministic"`, `"single-crit"` and `"multi-crit"`.
#'
#' @template param_domain
#' @template param_codomain
#' @template param_xdt
#' @template param_check_values
#' @template param_constants
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

    #' @field constants ([paradox::ParamSet]).\cr
    #' Changeable constants or parameters that are not subject to tuning can be
    #' stored and accessed here. Set constant values are passed to `$.eval()`
    #' and `$.eval_many()` as named arguments.
    constants = NULL,

    #' @field check_values (`logical(1)`)\cr
    check_values = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param id (`character(1)`).
    #' @param properties (`character()`).
    initialize = function(id = "f", properties = character(), domain, codomain = ps(y = p_dbl(tags = "minimize")),
      constants = ps(), check_values = TRUE) {
      self$id = assert_string(id)
      self$domain = assert_param_set(domain)
      self$codomain = Codomain$new(assert_param_set(codomain)$params)
      assert_names(self$domain$ids(), disjunct.from = self$codomain$ids())
      assert_names(self$domain$ids(), disjunct.from = c("x_domain", "timestamp", "batch_nr"))
      assert_names(self$codomain$ids(), disjunct.from = c("x_domain", "timestamp", "batch_nr"))
      self$properties = assert_subset(properties, bbotk_reflections$objective_properties)
      self$constants = assert_param_set(constants)
      self$check_values = assert_flag(check_values)
    },

    #' @description
    #' Helper for print outputs.
    #' @return `character()`.
    format = function() {
      sprintf("<%s:%s>", class(self)[1L], self$id)
    },

    #' @description
    #' Print method.
    #' @return `character()`.
    print = function() {
      catf(self$format())
      catf("Domain:")
      print(self$domain)
      catf("Codomain:")
      print(self$codomain)
      if (length(self$constants$values) > 0) {
        catf("Constants:")
        print(self$constants)
      }
    },

    #' @description
    #' Evaluates a single input value on the objective function. If
    #' `check_values = TRUE`, the validity of the point as well as the validity
    #' of the result is checked.
    #'
    #' @param xs (`list()`)\cr
    #'   A list that contains a single x value, e.g. `list(x1 = 1, x2 = 2)`.
    #'
    #' @return `list()` that contains the result of the evaluation, e.g. `list(y = 1)`.
    #' The list can also contain additional *named* entries that will be stored in the
    #' archive if called through the [OptimInstance].
    #' These extra entries are referred to as *extras*.
    eval = function(xs) {
      if (self$check_values) self$domain$assert(xs)
      res = invoke(private$.eval, xs, .args = self$constants$values)
      if (self$check_values) self$codomain$assert(res[self$codomain$ids()])
      return(res)
    },

    #' @description
    #' Evaluates multiple input values on the objective function. If
    #' `check_values = TRUE`, the validity of the points as well as the validity
    #' of the results are checked. *bbotk* does not take care of
    #' parallelization. If the function should make use of parallel computing,
    #' it has to be implemented by deriving from this class and overwriting this
    #' function.
    #'
    #' @param xss (`list()`)\cr
    #'   A list of lists that contains multiple x values, e.g.
    #'   `list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4))`.
    #'
    #' @return data.table::data.table()] that contains one y-column for
    #' single-criteria functions and multiple y-columns for multi-criteria functions,
    #' e.g.  `data.table(y = 1:2)` or `data.table(y1 = 1:2, y2 = 3:4)`.
    #' It may also contain additional columns that will be stored in the archive if
    #' called through the [OptimInstance].
    #' These extra columns are referred to as *extras*.
    eval_many = function(xss) {
      if (self$check_values) lapply(xss, self$domain$assert)
      res = invoke(private$.eval_many, xss, .args = self$constants$values)
      if (self$check_values) {
        self$codomain$assert_dt(res[, self$codomain$ids(), with = FALSE])
      }
      return(res)
    },

    #' @description
    #' Evaluates multiple input values on the objective function
    #'
    #' @return data.table::data.table()] that contains one y-column for
    #' single-criteria functions and multiple y-columns for multi-criteria
    #' functions, e.g.  `data.table(y = 1:2)` or `data.table(y1 = 1:2, y2 = 3:4)`.
    eval_dt = function(xdt) {
      self$eval_many(transpose_list(xdt))
    }
  ),

  active = list(
    #' @field xdim (`integer(1)`)\cr
    #' Dimension of domain.
    xdim = function() self$domain$length,

    #' @field ydim (`integer(1)`)\cr
    #' Dimension of codomain.
    ydim = function() self$codomain$target_length
  ),

  private = list(
    .eval = function(xs, ...) { # ... allows constants
      as.list(self$eval_many(list(xs)))
    },

    .eval_many = function(xss, ...) {
      res = map_dtr(xss, function(xs) {
        ys = self$eval(xs)
        as.data.table(lapply(ys, function(y) if (is.list(y)) list(y) else y))
      })
      # to keep it simple we expect the order of the results to be right. extras keep their names
      colnames(res)[seq_len(self$codomain$length)] = self$codomain$ids()
      return(res)
    }
  )
)
