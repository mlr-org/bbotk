#' @title Create Asynchronous Optimization Callback
#'
#' @description
#' Specialized [mlr3misc::Callback] for asynchronous optimization.
#' Callbacks allow to customize the behavior of processes in bbotk.
#' The [callback_async()] function creates a [CallbackAsync].
#' Predefined callbacks are stored in the [dictionary][mlr3misc::Dictionary] [mlr_callbacks] and can be retrieved with [clbk()].
#' For more information on optimization callbacks see [callback_async()].
#'
#' @seealso [callback_async()]
#' @export
CallbackAsync = R6Class("CallbackAsync",
  inherit = Callback,
  public = list(

    #' @field on_optimization_begin (`function()`)\cr
    #' Stage called at the beginning of the optimization in the main process.
    #' Called in `Optimizer$optimize()`.
    on_optimization_begin = NULL,

    #' @field on_worker_begin (`function()`)\cr
    #' Stage called at the beginning of the optimization on the worker.
    #' Called in the worker loop.
    on_worker_begin = NULL,

    #' @field on_optimizer_before_eval (`function()`)\cr
    #' Stage called after the optimizer proposes points.
    #' Called in `OptimInstance$.eval_point()`.
    on_optimizer_before_eval = NULL,

    #' @field on_optimizer_after_eval (`function()`)\cr
    #' Stage called after points are evaluated.
    #' Called in `OptimInstance$.eval_point()`.
    on_optimizer_after_eval = NULL,

    #' @field on_worker_end (`function()`)\cr
    #' Stage called at the end of the optimization on the worker.
    #' Called in the worker loop.
    on_worker_end = NULL,

    #' @field on_result_begin (`function()`)\cr
    #'   Stage called before the results are written.
    #'   Called in `OptimInstance$assign_result()`.
    on_result_begin = NULL,

    #' @field on_result_end (`function()`)\cr
    #'   Stage called after the results are written.
    #'   Called in `OptimInstance$assign_result()`.
    on_result_end = NULL,

    #' @field on_optimization_end (`function()`)\cr
    #'   Stage called at the end of the optimization in the main process.
    #'   Called in `Optimizer$optimize()`.
    on_optimization_end = NULL
  )
)

#' @title Create Asynchronous Optimization Callback
#'
#' @description
#' Function to create a [CallbackAsync].
#'
#' Optimization callbacks can be called from different stages of optimization process.
#' The stages are prefixed with `on_*`.
#'
#' ```
#' Start Optimization
#'      - on_optimization_begin
#'     Start Worker
#'          - on_worker_begin
#'            Start Optimization on Worker
#'              - on_optimizer_before_eval
#'              - on_optimizer_after_eval
#'            End Optimization on Worker
#'          - on_worker_end
#'     End Worker
#'      - on_result_begin
#'      - on_result_end
#'      - on_optimization_end
#' End Optimization
#' ```
#'
#' See also the section on parameters for more information on the stages.
#' A optimization callback works with [ContextAsync].
#'
#' @details
#' A callback can write data to its state (`$state`), e.g. settings that affect the callback itself.
#' The [ContextAsync] allows to modify the instance, archive, optimizer and final result.
#'
#' @param id (`character(1)`)\cr
#'  Identifier for the new instance.
#' @param label (`character(1)`)\cr
#'  Label for the new instance.
#' @param man (`character(1)`)\cr
#'  String in the format `[pkg]::[topic]` pointing to a manual page for this object.
#'  The referenced help package can be opened via method `$help()`.
#'
#' @param on_optimization_begin (`function()`)\cr
#'  Stage called at the beginning of the optimization in the main process.
#'  Called in `Optimizer$optimize()`.
#'  The functions must have two arguments named `callback` and `context`.
#' @param on_worker_begin (`function()`)\cr
#'  Stage called at the beginning of the optimization on the worker.
#'  Called in the worker loop.
#'  The functions must have two arguments named `callback` and `context`.
#' @param on_optimizer_before_eval (`function()`)\cr
#'  Stage called after the optimizer proposes points.
#'  Called in `OptimInstance$.eval_point()`.
#'  The functions must have two arguments named `callback` and `context`.
#'  The argument of `instance$.eval_point(xs)` and `xs_trafoed` and `extra` are available in the `context`.
#'  Or `xs` and `xs_trafoed` of `instance$.eval_queue()` are available in the `context`.
#' @param on_optimizer_after_eval (`function()`)\cr
#'  Stage called after points are evaluated.
#'  Called in `OptimInstance$.eval_point()`.
#'  The functions must have two arguments named `callback` and `context`.
#'  The outcome `y` is available in the `context`.
#' @param on_worker_end (`function()`)\cr
#'  Stage called at the end of the optimization on the worker.
#'  Called in the worker loop.
#'  The functions must have two arguments named `callback` and `context`.
#' @param on_result_begin (`function()`)\cr
#'  Stage called before result are written.
#'  Called in `OptimInstance$assign_result()`.
#'  The functions must have two arguments named `callback` and `context`.
#'  The arguments of `$.assign_result(xdt, y, extra)` are available in the `context`.
#' @param on_result_end (`function()`)\cr
#'  Stage called after result are written.
#'  Called in `OptimInstance$assign_result()`.
#'  The functions must have two arguments named `callback` and `context`.
#'  The final result `instance$result` is available in the `context`.
#' @param on_result (`function()`)\cr
#'  Deprecated.
#'  Use `on_result_end` instead.
#'  Stage called after result are written.
#'  Called in `OptimInstance$assign_result()`.
#'  The functions must have two arguments named `callback` and `context`.
#' @param on_optimization_end (`function()`)\cr
#'  Stage called at the end of the optimization in the main process.
#'  Called in `Optimizer$optimize()`.
#'  The functions must have two arguments named `callback` and `context`.
#'
#' @return [CallbackAsync]
#' @export
callback_async = function(
  id,
  label = NA_character_,
  man = NA_character_,
  on_optimization_begin = NULL,
  on_worker_begin = NULL,
  on_optimizer_before_eval = NULL,
  on_optimizer_after_eval = NULL,
  on_worker_end = NULL,
  on_result_begin = NULL,
  on_result_end = NULL,
  on_result = NULL,
  on_optimization_end = NULL
  ) {
  stages = discard(set_names(list(
    on_optimization_begin,
    on_worker_begin,
    on_optimizer_before_eval,
    on_optimizer_after_eval,
    on_worker_end,
    on_result_begin,
    on_result_end,
    on_result,
    on_optimization_end),
    c("on_optimization_begin",
      "on_worker_begin",
      "on_optimizer_before_eval",
      "on_optimizer_after_eval",
      "on_worker_end",
      "on_result_begin",
      "on_result_end",
      "on_result",
      "on_optimization_end")), is.null)

  if ("on_result" %in% names(stages)) {
    .Deprecated(old = "on_result", new = "on_result_end")
    stages$on_result_end = stages$on_result
    stages$on_result = NULL
  }

  walk(stages, function(stage) assert_function(stage, args = c("callback", "context")))
  callback = CallbackAsync$new(id, label, man)
  iwalk(stages, function(stage, name) callback[[name]] = stage)
  callback
}
