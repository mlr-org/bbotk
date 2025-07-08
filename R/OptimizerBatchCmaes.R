#' @title Optimization via Covariance Matrix Adaptation Evolution Strategy
#'
#' @include Optimizer.R
#' @name mlr_optimizers_cmaes
#'
#' @description
#' `OptimizerBatchCmaes` class that implements CMA-ES.
#' Calls `cma_es()` from package \CRANpkg{cmaes}.
#' The algorithm is typically applied to search space dimensions between three and fifty.
#' Lower search space dimensions might crash.
#'
#' @templateVar id cmaes
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' \describe{
#' \item{`start_values`}{`character(1)`\cr
#'   Create `"random"` start values or based on `"center"` of search space?
#'   In the latter case, it is the center of the parameters before a trafo is applied.
#'   If set to `"custom"`, the start values can be passed via the `start` parameter.}
#' \item{`start`}{`numeric()`\cr
#'   Custom start values.
#'   Only applicable if `start_values` parameter is set to `"custom"`.}
#' }
#'
#' For the meaning of the control parameters, see `cma_es()`.
#' The parameters `maxit`, `stopfitness` and `stop.tolx` can be used additionally to our terminators.
#' The default values of `maxit` is `100 * D^2` where `D` is the number of dimensions of the search space.
#' The `stop.tolx` parameter stops when the step size is smaller than `1e-12 * sigma`.
#' The `vectorized` parameter is always set to `TRUE`.
#'
#' @template section_progress_bars
#'
#' @export
#' @examples
#' if (requireNamespace("adagio")) {
#'   search_space = domain = ps(
#'     x1 = p_dbl(-10, 10),
#'     x2 = p_dbl(-5, 5)
#'   )
#'
#'   codomain = ps(y = p_dbl(tags = "maximize"))
#'
#'   objective_function = function(xs) {
#'     c(y = -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
#'   }
#'
#'   objective = ObjectiveRFun$new(
#'     fun = objective_function,
#'     domain = domain,
#'     codomain = codomain)
#'
#'   instance = OptimInstanceBatchSingleCrit$new(
#'     objective = objective,
#'     search_space = search_space,
#'     terminator = trm("evals", n_evals = 10))
#'
#'   optimizer = opt("cmaes")
#'
#'   # modifies the instance by reference
#'   optimizer$optimize(instance)
#'
#'   # returns best scoring evaluation
#'   instance$result
#'
#'   # allows access of data.table of full path of all evaluations
#'   as.data.table(instance$archive$data)
#' }
OptimizerBatchCmaes = R6Class("OptimizerBatchCmaes",
  inherit = OptimizerBatch,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        fnscale       = p_dbl(default = 1),
        maxit         = p_int(lower  = 1L),
        stopfitness   = p_dbl(default = -Inf),
        keep.best     = p_lgl(default = TRUE),
        sigma         = p_uty(default = 0.5),
        mu            = p_int(lower = 1L),
        lambda        = p_int(lower = 1L),
        weights       = p_uty(),
        damps         = p_dbl(),
        cs            = p_dbl(),
        ccum          = p_dbl(),
        ccov.1        = p_dbl(lower = 0),
        ccov.mu       = p_dbl(lower = 0),
        diag.sigma    = p_lgl(default = FALSE),
        diag.eigen    = p_lgl(default = FALSE),
        diag.pop      = p_lgl(default = FALSE),
        diag.value    = p_lgl(default = FALSE),
        stop.tolx     = p_dbl(), # undocumented stop criterion
        start_values  = p_fct(default = "random", levels = c("random", "center", "custom")),
        start         = p_uty(default = NULL, depends = start_values == "custom")
      )
      param_set$values$start_values = "random"
      param_set$values$start = NULL

      super$initialize(
        id = "cmaes",
        param_set = param_set,
        param_classes = "ParamDbl",
        properties = "single-crit",
        packages = "cmaes",
        label = "Covariance Matrix Adaptation Evolution Strategy",
        man = "bbotk::mlr_optimizers_cmaes"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      pv = self$param_set$values
      start_values = pv$start_values
      start = pv$start


      par = if (pv$start_values == "custom") set_names(start, inst$search_space$ids()) else search_start(inst$search_space, type = start_values)

      if (length(par) < 2L) {
        warning("CMA-ES is typically applied to search space dimensions between three and fifty. A lower search space dimension might crash.")
      }

      control = pv[names(pv) %nin% c("start_values", "start")]
      control$vectorized = TRUE

      wrapper = function(xmat, inst) {
        xdt = as.data.table(t(xmat))
        res = inst$eval_batch(xdt)
        y = res[, inst$objective$codomain$target_ids, with = FALSE][[1]]
        y * inst$objective_multiplicator
      }

      invoke(cmaes::cma_es,
        par = par,
        fn = wrapper,
        lower = inst$search_space$lower,
        upper = inst$search_space$upper,
        control = control,
        inst = inst)
    }
  )
)

mlr_optimizers$add("cmaes", OptimizerBatchCmaes)
