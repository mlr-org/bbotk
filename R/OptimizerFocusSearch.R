#' @title Optimization via Focus Search
#'
#' @include Optimizer.R
#' @name mlr_optimizers_focus_search
#'
#' @description
#' `OptimizerFocusSearch` class that implements a Focus Search.
#'
#' Focus Search starts with evaluating `n_points` drawn uniformly at random.
#' For 1 to `maxit` batches, `n_points` are then drawn uniformly at random and
#' if the best value of a batch outperforms the previous best value over all
#' batches evaluated so far, the search space is shrinked around this new best
#' point prior to the next batch being sampled and evaluated.
#'
#' For details on the shrinking, see [shrink_ps].
#'
#' Depending on the [Terminator] this procedure simply restarts after `maxit` is
#' reached.
#'
#' @templateVar id focus_search
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' \describe{
#' \item{`n_points`}{`integer(1)`\cr
#' Number of points to evaluate in each random search batch.}
#' \item{`maxit`}{`integer(1)`\cr
#' Number of random search batches to run.}
#' }
#'
#' @template section_progress_bars
#'
#' @export
#' @template example
OptimizerFocusSearch = R6Class("OptimizerFocusSearch",
  inherit = Optimizer,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      # Note: maybe make range / 2 a hyperparameter?
      param_set = ps(
        n_points = p_int(default = 100L, tags = "required"),
        maxit = p_int(default = 100L, tags = "required")
      )
      param_set$values = list(n_points = 100L, maxit = 100L)

      super$initialize(
        param_set = param_set,
        param_classes = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct"),
        properties = c("dependencies", "single-crit")  # Note: think about multi-crit variant
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
              if ("shrinked" %in% param_set_local$params[[id]]$tags) {
                rep(param_set_local$params[[id]]$default, times = length(param))
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

mlr_optimizers$add("focus_search", OptimizerFocusSearch)



#' @title Shrink a ParamSet towards a point.
#'
#' @description
#' Shrinks a [paradox::ParamSet] towards a point.
#' Boundaries of numeric values are shrinked to an interval around the point of
#' half of the previous length, while for discrete variables, a random
#' (currently not chosen) level is dropped.
#'
#' Note that for [paradox::ParamLgl]s the value to be shrinked around is set as
#' the `default` value instead of dropping a level. Also, a tag `shrinked` is
#' added.
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
#' param_set = ParamSet$new(list(
#'   ParamDbl$new("x1", lower = 0, upper = 10),
#'   ParamInt$new("x2", lower = -10, upper = 10),
#'   ParamFct$new("x3", levels = c("a", "b", "c")),
#'   ParamLgl$new("x4"))
#' )
#' x = data.table(x1 = 5, x2 = 0, x3 = "b", x4 = FALSE)
#' shrink_ps(param_set, x = x)
shrink_ps = function(param_set, x, check.feasible = FALSE) {
  param_set = param_set$clone(deep = TRUE)  # avoid unwanted side effects
  assert_param_set(param_set)
  assert_data_table(x, nrows = 1L, min.cols = 1L)
  assert_flag(check.feasible)

  # shrink each parameter
  params_new = map(seq_along(param_set$params), function(i) {
    param = param_set$params[[i]]
    # only shrink if there is a value
    val = x[[param$id]]
    if (test_atomic(val, any.missing = FALSE, len = 1L)) {
      if (check.feasible & !param$test(val)) {
        stop(sprintf("Parameter value %s is not feasible for %s.", val, param$id))
      }

      if (param$is_number) {
        range = param$upper - param$lower

        if (param_set$has_trafo) {
          xdt = copy(x)
          val = tryCatch({
            # find val on the original scale
            val = stats::uniroot(
              function(x_rep) {
                xdt[[param$id]] = x_rep
                param_set$trafo(xdt)[[param$id]] - val
              },
              interval = c(param$lower, param$upper),
              extendInt = "yes",
              tol = .Machine$double.eps ^ 0.5 * range,
              maxiter = 10 ^ 4
            )$root
          }, error = function(error_condition) {
            param$upper + 1
          })
        }

        # if it is not feasible we do nothing
        if (param$test(val)) {
          # shrink to range / 2, centered at val
          lower = pmax(param$lower, val - (range / 4))
          upper = pmin(param$upper, val + (range / 4))
          if (test_r6(param, classes = "ParamInt")) {
            lower = as.integer(floor(lower))
            upper = as.integer(ceiling(upper))
            ParamInt$new(id = param$id, lower = lower, upper = upper,
              special_vals = param$special_vals, default = param$default,
              tags = param$tags)
          } else {  # it's ParamDbl then
            ParamDbl$new(id = param$id, lower = lower, upper = upper,
              special_vals = param$special_vals, default = param$default,
              tags = param$tags, tolerance = param$tolerance)
          }
        }
      } else if (param$is_categ) {
        if (param$test(val)) {
          # randomly drop a level, which is not val
          if (length(param$levels) > 1L) {
            levels = setdiff(param$levels, sample(setdiff(param$levels, val), size = 1L))
            if (test_r6(param, classes = "ParamFct")) {
              ParamFct$new(id = param$id, levels = levels,
                special_vals = param$special_vals, default = param$default,
                tags = param$tags)
            } else {
              # for ParamLgls we cannot specify levels; instead we set a default
              ParamLgl$new(id = param$id,
                special_vals = param$special_vals, default = levels,
                tags = unique(c(param$tags, "shrinked")))
            }
          }
        }
      }
    }
  })

  missing = which(map_lgl(params_new, is.null))
  if (length(missing)) {
    params_new[missing] = map(param_set$params[missing], function(param) param$clone(deep = TRUE))
  }
  param_set_new = ParamSet$new(params_new)
  param_set_new$deps = param_set$deps
  param_set_new$trafo = param_set$trafo
  param_set_new$values = param_set$values  # needed for handling constants
  param_set_new
}

