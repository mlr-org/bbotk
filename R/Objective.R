#FIXME: Let marc do R6 rox2 docs, and iterate over docs

#' @title Objective function with domain and co-domain
#'
#' @usage NULL
#' @format [R6::R6Class] object.
#'
#' @description
#' Describes a black-box objective function that maps an arbitrary domain to a numerical codomain.
#'
#' @section Construction:
#' ```
#' obj = Objective$new(fun, domain, ydim = 1L, minimize = NULL, id = "f", encapsulate = "none")
#' ```
#' * `fun` :: `function(x, ...)`\cr
#'   R function that encodes objective. First argument `x` must be a list, where names and positions
#'   agree with the parameters specified in `domain`. Returns a numeric of length `ydim`.
#' * `domain` :: [paradox::ParamSet]\cr
#'   Specifies domain of function, hence its innput parameters, their types and ranges.
#' * `ydim` :: `integer(1)`\cr
#'   Dimension of codomain, ydim=1 implies single-objective, ydim>1 implies multi-objective optimization.
#' * `minimize` :: named `logical`.
#'   Should objective (component) function be minimized (or maximized)?
#'   By naming this logical, you can also define the names of the objectives.
#'   By default, all objectives are minimized and they are named `y1` to `y[ydim]`.
#' * `id` :: `character(1)`\cr
#'   Name of function. Not very much currently used.
#' * `encapsulate` :: `character(1)`.
#'   Defines how the [Evaluator] encapsulates function calls.
#'   See [mlr3misc::encapsulate] for behavior and possible values.
#'
#' @section Fields:
#' * `fun` :: `function(x, ...)`; from construction
#' * `domain` :: [paradox::ParamSet]; from construction
#' * `codomain` :: [paradox::ParamSet]; (Realvalued) codomain as ParamSet, auto-constructed.
#' * `minimize` :: named `logical`; from construction
#' * `id` :: `character(1)`.; from construction
#' * `encapsulate` :: `character(1)`; from construction
#' * `ydim` :: `integer(1)`; from construction
#' * `xdim` :: `integer(1)`\cr
#'    Number of input parameters in `domain`.
#' @export
Objective = R6Class("Objective",
  public = list(
    id = NULL,
    fun = NULL,
    domain = NULL,
    codomain = NULL,
    minimize = NULL,
    encapsulate = "none",

    initialize = function(fun, domain, ydim = 1L, minimize = NULL, id = "f", encapsulate = "none") {
      self$fun = assert_function(fun, args = "x")
      self$domain = assert_param_set(domain)
      ydim = assert_int(ydim, lower = 1L)
      assert_logical(minimize, len = ydim, null.ok = TRUE)
      if (is.null(minimize))
        minimize = rep(TRUE, ydim)
      if (is.null(names(minimize)))
        names(minimize) = paste0("y", 1:ydim)
      else
        assert_named(minimize, "unique")
      self$minimize = minimize
      self$codomain = ParamSet$new(lapply(names(minimize), function(s) ParamDbl$new(id = s)))
      self$id = assert_string(id)
      self$encapsulate = assert_choice(encapsulate, c("none", "evaluate", "callr"))
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


# @export
#assert_objective = function(x, ydim = NULL) {
#  assert_r6(x, "Objective")
#  if (!is.null(ydim)) # FIXME: better error message here
#    assert_true(x$ydim == ydim)
#  invisible(x)
#}
