#' @title Instance Class
#'
#' @description
#' This is the abstract base class for instance objects.
#' 
#' @family Instance
#' @export
Instance = R6Class("Instance",
  public = list(
   
   #' @field task ([mlr3::Task]).
   task = NULL,
   
   #' @field learner ([mlr3::Learner]).
   learner = NULL,
   
   #' @field resampling ([mlr3::Resampling])\cr
   resampling = NULL,
   
   #' @field measures (list of [mlr3::Measure]).
   measures = NULL,
   
   #' @field param_set ([paradox::ParamSet]).
   param_set = NULL,
   
   #' @field terminator ([Terminator]).
   terminator = NULL,
   
   #' @field bm_args (named `list()`)\cr
   #'   Further arguments for [mlr3::benchmark()].
   bm_args = NULL,
   
   #' @field bmr ([mlr3::BenchmarkResult])\cr
   #'   A benchmark result, container object for all performed
   #'   [mlr3::ResampleResult]s when evaluating hyperparameter configurations.
   bmr = NULL,
   
   #' @field start_time (`POSIXct(1)`)\cr
   #'   Time the optimization was started. This is set in the beginning of
   #'   optimization.
   start_time = NULL,
   
   #' @description
   #' Creates a new instance of this [R6][R6::R6Class] class.
   #'
   #' @param task ([mlr3::Task]).
   #'
   #' @param learner ([mlr3::Learner]).
   #'
   #' @param resampling ([mlr3::Resampling])\cr
   #'   Note that uninstantiated resamplings are instantiated during
   #'   construction so that all configurations are evaluated on the same data
   #'   splits.
   #'
   #' @param measures (list of [mlr3::Measure]).
   #'
   #' @param param_set ([paradox::ParamSet]).
   #'
   #' @param terminator ([Terminator]).
   #'
   #' @param bm_args (named `list()`)\cr
   #'   Further arguments for [mlr3::benchmark()].
   initialize = function(task, learner, resampling, measures, param_set, terminator, bm_args = list()) {
     self$task = assert_task(as_task(task, clone = TRUE))
     self$learner = assert_learner(as_learner(learner, clone = TRUE), task = self$task)
     self$resampling = assert_resampling(as_resampling(resampling, clone = TRUE))
     self$measures = assert_measures(as_measures(measures, clone = TRUE), task = self$task, learner = self$learner)
     self$param_set = assert_param_set(param_set, must_bounded = TRUE, no_untyped = TRUE)
     self$terminator = assert_terminator(terminator)
     self$bm_args = assert_list(bm_args, names = "unique")
     self$bmr = BenchmarkResult$new(data.table())
     if (!resampling$is_instantiated)
       self$resampling$instantiate(self$task)
   },
   
   #' @description
   #' Helper for print outputs.
   format = function() {
     sprintf("<%s>", class(self)[1L])
   },
   
   #' @description
   #' Printer.
   #' @param ... (ignored).
   print = function() {
     stop("abstract")
   },
   
   #' @description
   #' Performace evaluator.
   eval_batch = function() {
     stop("abstract")
   },
   
   #' @description
   #' Objective function.
   objective = function() {
     stop("abstract")
   },
   
   #' @description
   #' Archive.
   archive = function(unnest = "no") {
     stop("abstract")
   },
   
   #' @description
   #' Best [mlr3::ResampleResult].
   best = function() {
     stop("abstract")
   },
   
   #' @description
   #' The optimization algorithm writes the best found list of settings and
   #' estimated performance values here.
   assign_result = function() {
     stop("abstract")
   }
  ),
  
  active = list(
   #' @field n_evals (`integer(1)`)\cr
   #'   Number of configuration evaluations stored in the container.
   n_evals = function() self$bmr$n_resample_results,
   
   #' @field result (named `list()`)\cr
   #'   Result of the optimization, i.e., the optimal settings and its estimated
   #'   performance:
   result = function() {
     stop("abstract")
   }
  ),
  
  private = list(
   .result = NULL
  )
)