#' @title Optimization via Focus Search
#'
#' @include Optimizer.R
#' @name mlr_optimizers_focus_search
#'
#' @description
#' `OptimizerBatchFocusSearch` class that implements a Focus Search.
#'
#' Focus Search starts with evaluating `n_points` drawn uniformly at random.
#' For 1 to `maxit` batches, `n_points` are then drawn uniformly at random and if the best value of a batch outperforms the previous best value over all batches evaluated so far, the search space is shrinked around this new best point prior to the next batch being sampled and evaluated.
#'
#' For details on the shrinking, see [shrink_ps].
#'
#' Depending on the [Terminator] this procedure simply restarts after `maxit` is reached.
#'
#' @templateVar id focus_search
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' \describe{
#' \item{`n_points`}{`integer(1)`\cr
#'   Number of points to evaluate in each random search batch.}
#' \item{`maxit`}{`integer(1)`\cr
#'   Number of random search batches to run.}
#' }
#'
#' @template section_progress_bars
#'
#' @export
#' @template example
OptimizerBatchFocusSearch = R6Class("OptimizerBatchFocusSearch",
  inherit = OptimizerBatch,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      # NOTE: maybe make range / 2 a hyperparameter?
      param_set = ps(
        n_points = p_int(tags = "required"),
        maxit = p_int(tags = "required")
      )
      param_set$values = list(n_points = 100L, maxit = 100L)

      super$initialize(
        id = "focus_search",
        param_set = param_set,
        param_classes = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct"),
        properties = c("dependencies", "single-crit"),  # NOTE: think about multi-crit variant
        label = "Focus Search",
        man = "bbotk::mlr_optimizers_focus_search"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      n_points = self$param_set$values$n_points
      maxit = self$param_set$values$maxit
      cols_x = inst$archive$cols_x
      cols_y = inst$archive$cols_y
      om = inst$objective_multiplicator
      n_repeats = 0L

      repeat {  # iterate until we have an exception from eval_batch
        param_set_local = inst$search_space$clone(deep = TRUE)
        lgls = param_set_local$ids()[param_set_local$class == "ParamLgl"]
        sampler = SamplerUnif$new(param_set_local)
        inst$eval_batch(sampler$sample(n_points)$data)
        start_batch = (n_repeats * maxit) + n_repeats + 1L
        best = inst$archive$best(batch = start_batch)  # needed for restart to work

        for (i in seq_len(maxit)) {
          # ParamLgls have the value to be shrinked around set as a default
          data = sampler$sample(n_points)$data
          if (length(lgls)) {
            data[, (lgls) := imap(.SD, function(param, id) {
              if ("shrinked" %in% param_set_local$tags[[id]]) {
                rep(param_set_local$default[[id]], times = length(param))
              } else {
                param
              }
            }), .SDcols = lgls]
          }

          inst$eval_batch(data)
          best_i = inst$archive$best(batch = inst$archive$n_batch)
          if (om * best_i[[cols_y]] < om * best[[cols_y]]) {
            lg$info("Shrinking ParamSet")
            param_set_local = shrink_ps(param_set_local, x = best_i[, cols_x, with = FALSE])
            sampler = SamplerUnif$new(param_set_local)
          }
          # always update the incumbent after each batch
          # respect potential restarts
          best = inst$archive$best(start_batch:inst$archive$n_batch)
        }

        n_repeats = n_repeats + 1L
        lg$info(sprintf("Restart no. %i", n_repeats))
      }
    }
  )
)

mlr_optimizers$add("focus_search", OptimizerBatchFocusSearch)



#' @title Shrink a ParamSet towards a point.
#'
#' @description
#' Shrinks a [paradox::ParamSet] towards a point.
#' Boundaries of numeric values are shrinked to an interval around the point of
#' half of the previous length, while for discrete variables, a random
#' (currently not chosen) level is dropped.
#'
#' Note that for [paradox::p_lgl()]s the value to be shrinked around is set as
#' the `default` value instead of dropping a level. Also, a tag `shrinked` is
#' added.
#'
#' Note that the returned [paradox::ParamSet] has lost all its original
#' `default`s, as they may have become infeasible.
#'
#' If the [paradox::ParamSet] has a trafo, `x` is expected to contain the
#' transformed values.
#'
#' @param param_set ([paradox::ParamSet])\cr
#' The [paradox::ParamSet] to be shrinked.
#' @param x ([data.table::data.table])\cr
#' [data.table::data.table] with one row containing the point to shrink
#' around.
#' @param check.feasible (`logical(1)`)\cr
#' Should feasibility of the parameters be checked?
#' If feasibility is not checked, and invalid values are present, no shrinking
#' will be done.
#' Must be turned off in the case of the [paradox::ParamSet] having a trafo.
#' Default is `FALSE`.
#' @return [paradox::ParamSet]
#' @export
#' @examples
#' library(paradox)
#' library(data.table)
#' param_set = ps(
#'   x = p_dbl(lower = 0, upper = 10),
#'   x2 = p_int(lower = -10, upper = 10),
#'   x3 = p_fct(levels = c("a", "b", "c")),
#'   x4 = p_lgl()
#' )
#' x = data.table(x1 = 5, x2 = 0, x3 = "b", x4 = FALSE)
#' shrink_ps(param_set, x = x)
shrink_ps = function(param_set, x, check.feasible = FALSE) {

  assert_param_set(param_set)
  assert_data_table(x, nrows = 1L, min.cols = 1L)
  assert_flag(check.feasible)

  # shrink each parameter
  subspaces = if ("subspaces" %in% names(param_set)) {
    param_set$subspaces()
  } else {
    # old paradox
    lapply(param_set$params, function(x) ParamSet$new(list(x)))
  }
  # old paradox: individual trafos as list of NULL
  param_trafos = set_names(param_set$params$.trafo %??% vector("list", param_set$length), param_set$ids())
  params_new = map(seq_along(subspaces), function(i) {
    param = subspaces[[i]]

    pid = param$ids()
    # only shrink if there is a value
    val = x[[pid]]
    param_test_val = param$test(structure(list(val), names = pid))
    if (test_atomic(val, any.missing = FALSE, len = 1L)) {

      if (param$is_number) {
        range = param$upper - param$lower

        if (param_set$has_trafo) {
          xdt = copy(x)
          val = tryCatch({
            # find val on the original scale
            val = stats::uniroot(
              function(x_rep) {
                xdt[[pid]] = x_rep
                param_set$trafo(xdt)[[pid]] - val
              },
              interval = c(param$lower, param$upper),
              extendInt = "yes",
              tol = .Machine$double.eps ^ 0.5 * range,
              maxiter = 10 ^ 4
            )$root
          }, error = function(error_condition) {
            param$upper + 1
          })
          param_test_val = param$test(structure(list(val), names = pid))
        }
        if (check.feasible && !param_test_val) {
          stop(sprintf("Parameter value %s is not feasible for %s.", val, pid))
        }

        # if it is not feasible we do nothing
        if (param_test_val) {
          # shrink to range / 2, centered at val
          lower = pmax(param$lower, val - (range / 4))
          upper = pmin(param$upper, val + (range / 4))
          if (param$class == "ParamInt") {
            lower = as.integer(floor(lower))
            upper = as.integer(ceiling(upper))
            do.call(ps, structure(list(
              p_int(lower = lower, upper = upper,
                special_vals = param$special_vals[[pid]], tags = param$tags[[pid]],
                trafo = param_trafos[[pid]])
            ), names = pid))
          } else {  # it's ParamDbl then

            do.call(ps, structure(list(
              p_dbl(lower = lower, upper = upper,
                special_vals = param$special_vals[[pid]], tags = param$tags[[pid]],
                tolerance = param$params$tolerance[[1]] %??% param$params[[1]]$tolerance,  # since 'param' is from subspaces(), it only has 1 line ; '%??%' is for old pdaradox
                trafo = param_trafos[[pid]])
            ), names = pid))
          }
        }
      } else if (param$is_categ) {
        if (check.feasible && !param_test_val) {
          stop(sprintf("Parameter value %s is not feasible for %s.", val, pid))
        }

        if (param_test_val) {
          # randomly drop a level, which is not val
          levels = param$levels[[pid]]
          if (length(levels) > 1L) {
            levels = setdiff(levels, sample(setdiff(levels, val), size = 1L))
            if (param$class == "ParamFct") {
              do.call(ps, structure(list(
                p_fct(levels = levels,
                  special_vals = param$special_vals[[pid]], tags = param$tags[[pid]],
                  trafo = param_trafos[[pid]]
                )
              ), names = pid))
            } else {
              # for ParamLgls we cannot specify levels; instead we set a default
              do.call(ps, structure(list(
                p_lgl(special_vals = param$special_vals[[pid]],
                  default = levels, tags = unique(c(param$tags[[pid]], "shrinked")),
                  trafo = param_trafos[[pid]])
              ), names = pid))
            }
          }
        }
      }
    }
  })

  missing = which(map_lgl(params_new, is.null))
  if (length(missing)) {
    params_new[missing] = subspaces[missing]
  }
  param_set_new = get0("ps_union",
    # old paradox
    ifnotfound = function(x) ParamSet$new(lapply(x, function(y) y$params[[1]]))
  )(params_new)
  param_set_new$deps = param_set$deps
  if ("extra_trafo" %in% names(param_set_new)) {
    param_set_new$extra_trafo = param_set$extra_trafo
  } else {
    # old paradox
    param_set_new$trafo = param_set$trafo
  }
  param_set_new$values = param_set$values  # needed for handling constants
  param_set_new
}

