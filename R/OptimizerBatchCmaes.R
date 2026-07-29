#' @title Optimization via Covariance Matrix Adaptation Evolution Strategy
#'
#' @include Optimizer.R
#' @name mlr_optimizers_cmaes
#'
#' @description
#' `OptimizerBatchCmaes` class that implements CMA-ES.
#' Calls [libcmaesr::cmaes()] from package \CRANpkg{libcmaesr}, which is a lightweight interface to the `libcmaes` C++
#' library.
#' The algorithm is typically applied to search space dimensions between three and fifty.
#'
#' @templateVar id cmaes
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' \describe{
#' \item{`start_values`}{`character(1)`\cr
#' Create `"random"` start values or based on `"center"` of search space?
#' In the latter case, it is the center of the parameters before a trafo is applied.
#' If set to `"custom"`, the start values can be passed via the `start` parameter.}
#' \item{`start`}{`numeric()`\cr
#' Custom start values. Only applicable if `start_values` parameter is set to `"custom"`.}
#' \item{`seed`}{`integer(1)`\cr
#' Seed of the random number generator of `libcmaes`.
#' Unset by default, in which case the generator is seeded from R and the optimization is reproducible with
#' [set.seed()].}
#' }
#'
#' All remaining parameters are passed to [libcmaesr::cmaes_control()], see there for their meaning.
#' Note that we have removed all control parameters which refer to the termination of the algorithm and where our
#' terminators allow to obtain the same behavior, i.e. `max_fevals`, `max_iter`, and `ftarget`.
#' The internal convergence criteria of the algorithm still apply, so the optimization can stop before the
#' [Terminator] is triggered.
#'
#' @section Batch evaluation:
#' The optimizer evaluates a whole generation of `lambda` points in one batch.
#' The [Terminator] is only checked between generations, so the number of evaluations can exceed the budget of
#' [TerminatorEvals] by up to `lambda - 1` points.
#'
#' @template section_progress_bars
#'
#' @export
#' @examples
#' # example only runs if libcmaesr is available
#' if (mlr3misc::require_namespaces("libcmaesr", quietly = TRUE)) {
#' # define the objective function
#' fun = function(xs) {
#'   list(y = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 - (xs[[3]] + 4)^2 + 10)
#' }
#'
#' # set domain
#' domain = ps(
#'   x1 = p_dbl(-10, 10),
#'   x2 = p_dbl(-5, 5),
#'   x3 = p_dbl(-5, 5)
#' )
#'
#' # set codomain
#' codomain = ps(
#'   y = p_dbl(tags = "maximize")
#' )
#'
#' # create objective
#' objective = ObjectiveRFun$new(
#'   fun = fun,
#'   domain = domain,
#'   codomain = codomain,
#'   properties = "deterministic"
#' )
#'
#' # initialize instance
#' instance = oi(
#'   objective = objective,
#'   terminator = trm("evals", n_evals = 20)
#' )
#'
#' # load optimizer
#' optimizer = opt("cmaes")
#'
#' # trigger optimization
#' optimizer$optimize(instance)
#'
#' # all evaluated configurations
#' instance$archive
#'
#' # best performing configuration
#' instance$result
#' }
OptimizerBatchCmaes = R6Class(
  "OptimizerBatchCmaes",
  inherit = OptimizerBatch,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        algo = p_fct(
          default = "acmaes",
          levels = c(
            "cmaes", "ipop", "bipop", "acmaes", "aipop", "abipop", "sepcmaes", "sepipop", "sepbipop", "sepacmaes",
            "sepaipop", "sepabipop", "vdcma", "vdipopcma", "vdbipopcma"
          )
        ),
        sigma = p_dbl(lower = 0),
        lambda = p_int(lower = 2L),
        max_restarts = p_int(lower = 0L),
        elitism = p_int(lower = 0L, upper = 3L),
        tpa = p_int(lower = 0L, upper = 2L),
        tpa_dsigma = p_dbl(lower = 0),
        seed = p_int(lower = 0L),
        f_tolerance = p_dbl(lower = 0),
        x_tolerance = p_dbl(lower = 0),
        x0_lower = p_uty(default = NULL),
        x0_upper = p_uty(default = NULL),
        # bbotk parameters
        start_values = p_fct(levels = c("random", "center", "custom"), init = "random"),
        start = p_uty(default = NULL, depends = start_values == "custom")
      )

      super$initialize(
        id = "cmaes",
        param_set = param_set,
        param_classes = "ParamDbl",
        properties = "single-crit",
        packages = "libcmaesr",
        label = "Covariance Matrix Adaptation Evolution Strategy",
        man = "bbotk::mlr_optimizers_cmaes"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      pv = self$param_set$values

      x0 = if (pv$start_values == "custom") {
        assert_numeric(pv$start, len = inst$search_space$length, any.missing = FALSE)
      } else {
        search_start(inst$search_space, type = pv$start_values)
      }
      pv$start_values = NULL
      pv$start = NULL

      # the terminators control the budget, so the internal evaluation limit is disabled and `ftarget` is reserved for
      # stopping the algorithm from within the objective function
      control = invoke(libcmaesr::cmaes_control, max_fevals = NA_integer_, ftarget = -Inf, .args = pv)

      target = inst$objective$codomain$target_ids
      direction = inst$objective_multiplicator

      # libcmaesr catches errors raised in the objective function and re-raises a generic error, so the original
      # condition is stored here and re-raised below
      condition = NULL
      fun = function(x) {
        # `eval_batch()` signals the termination with an exception, which libcmaesr prints to stderr, so the
        # generation is left unevaluated and the target value is reported instead, which stops the algorithm after
        # this generation without any output
        if (inst$is_terminated) {
          return(rep(-Inf, nrow(x)))
        }
        tryCatch(
          {
            xdt = set_names(as.data.table(x), inst$search_space$ids())
            inst$eval_batch(xdt)[[target]] * direction
          },
          error = function(cond) {
            condition <<- cond
            stop(cond)
          }
        )
      }

      tryCatch(
        libcmaesr::cmaes(
          objective = fun,
          x0 = unname(x0),
          lower = inst$search_space$lower,
          upper = inst$search_space$upper,
          control = control,
          batch = TRUE
        ),
        error = function(cond) {
          stop(condition %??% cond)
        }
      )
    }
  )
)

mlr_optimizers$add("cmaes", OptimizerBatchCmaes)
