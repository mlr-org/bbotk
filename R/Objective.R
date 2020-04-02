#FIXME: Let marc do R6 rox2 docs, and iterate over docs
#FIXME: do we want the "unnest" feature as in mlr3tuning
#FIXME: how do we handle it that we can actually log multiple extra things to the archive from the objective?
# we need to check in mlr3tuning the case of SOO but with multiple measures
# FIXME: implement the "tuner_objective" service function which can directly be passed to on optimizer
# FIXME: do we need the start time in the evaluator
# FIXME: we could add some basic, simple optimizers from R here. connecting them here would enable them for many
#  tasks in optimization, not only mlr3tuning. think then how mlr3mbo extends this system then / regiusters itself
# FIXME: maybe also connect some stuff from ecr2?
# #FIXME: provide some basic MOO functionality
# FIXME: write a simple tutorial. this should include how parallezation works. does this go into the mlr3 book?
# FIXME: implement "best" function from Tuning Instance
# FIXME: is ist irgendwie komisch wann / wo wie die exception von eval_batch geworfen und gefangen wird
# das kann man auch in test_rs bei der random search sehen
# FIXME: Objective (or the Archive) should have a reset / clear functiuon to wipe the Archive

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
#' * `fun` :: `function(xdt, ...)`\cr
#'   R function that encodes objective. First argument `xdt` must be a `data.table`, where colnames
#'   agree with the parameters specified in `domain`. Returns a `data.table` with columns that contain the `xdt` values, the outcomes in columns that agree with the `codomain` and additional columns.
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
#' * `id` :: `character(1)`.; from construction
#' * `properties` :: `character()`.; from construction
#' * `domain` :: [paradox::ParamSet]; from construction
#' * `codomain` :: [paradox::ParamSet]; (Realvalued) codomain as ParamSet, auto-constructed.
#' * `ydim` :: `integer(1)`; from construction
#' * `xdim` :: `integer(1)`\cr
#'    Number of input parameters in `domain`.
#' @export
Objective = R6Class("Objective",
  public = list(
    id = NULL,
    properties = NULL,
    domain = NULL,
    codomain = NULL,

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

    format = function() {
      sprintf("<%s> '%s'", class(self)[1L], self$id)
    },

    print = function() {
      catf(self$format())
      catf("Domain:")
      print(self$domain)
      catf("Codomain:")
      print(self$codomain)
    },

    # in: list of on x setting
    # out: list
    eval = function(xs) {
      as.list(self$eval_batch(list(xs)))
    },

    # in: list n of lists of x settings
    # out: data.table with n rows
    eval_many = function(xss) {
      res = map_dtr(xss, function(xs) as.data.table(self$eval(xs)))
      colnames(res) = self$codomain$ids()
      return(res)
    },

    eval_checked = function(xs) {
      self$domain$assert(xs)
      res = self$eval(xs)
      self$codomain$assert(res)
    },

    eval_many_checked = function(xss) {
      lapply(xss, self$domain$assert)
      res = self$evaluate_many(xss)
      # lapply(res, self$codomain$assert) #FIXME: Does not work easily if res is dt
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

