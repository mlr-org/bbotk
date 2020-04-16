#' @title Objective function with domain and co-domain
#'
#' @description
#' Describes a black-box objective function that maps an arbitrary domain to a numerical codomain.
#'
#' @export
Objective = R6Class("Objective",
  public = list(

    #' @field id `character(1)`
    id = NULL,

    #' @field properties `character()`
    properties = NULL,

    #' @field domain [paradox::ParamSet]\cr
    #' Specifies domain of function, hence its innput parameters, their types and ranges.
    domain = NULL,

    #' @field codomain [paradox::ParamSet]
    #' Specifies codomain of function, hence its feasible values.
    codomain = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' @param id `character(1)`
    #' @param properties `character()`
    #' @param domain [paradox::ParamSet]\cr
    #' Specifies domain of function, hence its innput parameters, their types and ranges.
    #' @param codomain [paradox::ParamSet]\cr
    #' Specifies codomain of function, hence its feasible values.
    initialize = function(id = "f", properties = character(), domain, codomain = ParamSet$new(list(ParamDbl$new("y", tags = "minimize")))) {
      self$id = assert_string(id)
      self$domain = assert_param_set(domain)

      assert_codomain = function(x) {
          # check that "codomain" is
          # (1) all numeric and
          # (2) every parameter's tags contain at most one of 'minimize' or 'maximize' and
          # (3) there is at least one parameter with tag 'minimize' / 'maximize'
          assert_param_set(x)
          assert_true(all(x$is_number))
          assert_true(all(sapply(x$tags, function(x) sum(x %in% c("minimize", "maximize"))) <= 1))
          assert_true(any(c("minimize", "maximize") %in% unlist(x$tags)))
          return(x)
      }

      self$codomain = assert_codomain(codomain)
      self$properties = assert_character(properties) #FIXME: assert_subset(properties, blabot_reflections$objective_properties)
    },

    #' @description
    #' Helper for print outputs.
    #' @return `character()`
    format = function() {
      sprintf("<%s> '%s'", class(self)[1L], self$id)
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
    #' @param xs `list()` A list that contains a single x value, e.g. `list(x1 = 1, x2 = 2)`.
    #' @return `list()` A list that contains the result of the evaluation, e.g. `list(y = 1)`.
    eval = function(xs) {
      as.list(self$eval_many(list(xs)))
    },

    #' @description
    #' Evaluates multiple input values on the objective function
    #' @param xss `list()` A list of lists that contains multiple x values, e.g. `list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4))`.
    #' @return `list()` A list that contains the result of all evaluations, e.g. `list(list(y = 1), list(y=2))`.
    eval_many = function(xss) {
      res = map_dtr(xss, function(xs) as.data.table(self$eval(xs)))
      colnames(res) = self$codomain$ids()
      return(res)
    },

    #' @description
    #' Evaluates a single input value on the objective function and checks its validity as well as the validity of the result.
    #' @param xs `list()` A list that contains a single x value, e.g. `list(x1 = 1, x2 = 2)`.
    #' @return `list()` A list that contains the result of the evaluation, e.g. `list(y = 1)`.
    eval_checked = function(xs) {
      self$domain$assert(xs)
      res = self$eval(xs)
      self$codomain$assert(res)
    },

    #' @description
    #' Evaluates multiple input values on the objective function and checks the validity of the input.
    #' @param xss `list()` A list of lists that contains multiple x values, e.g. `list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4))`.
    #' @return `list()` A list that contains the result of all evaluations, e.g. `list(list(y = 1), list(y=2))`.
    eval_many_checked = function(xss) {
      lapply(xss, self$domain$assert)
      res = self$evaluate_many(xss)
      # lapply(res, self$codomain$assert) #FIXME: Does not work easily if res is dt
    }
  ),

  active = list(
    #' @field xdim `ìnteger(1)`\cr
    #' Dimension of domain.
    xdim = function() self$domain$length,
    
    #' @field ydim `ìnteger(1)`\cr
    #' Dimension of codomain.
    ydim = function() self$codomain$length
  )
)


# @export
#assert_objective = function(x, ydim = NULL) {
#  assert_r6(x, "Objective")
#  if (!is.null(ydim)) # FIXME: better error message here
#    assert_true(x$ydim == ydim)
#  invisible(x)
#}





workhorse = function(i, objective, xs) {
  x = as.list(xs[[i]])
  n = length(xs)
  lg$info("Eval point '%s' (batch %i/%i)", as_short_string(x), i, n)
  res = encapsulate(
    method = objective$encapsulate,
    .f = objective$fun,
    .args = list(x = x),
    # FIXME: we likely need to allow the user to configure this? or advice to load all paackaes in the user defined objective function?
    .pkgs = "bbotk",
    .seed = NA_integer_
  )
  # FIXME: encapsulate also returns time and log, we should probably do something with it?
  y = res$result
  assert_numeric(y, len = objective$ydim, any.missing = FALSE, finite = TRUE)
  lg$info("Result '%s'", as_short_string(y))
  as.list(y)
}

