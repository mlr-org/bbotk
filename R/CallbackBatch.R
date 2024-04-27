#' @title Create Batch Optimization Callback
#'
#' @description
#' Specialized [mlr3misc::Callback] for batch optimization.
#' Callbacks allow to customize the behavior of processes in bbotk.
#' The [callback_batch()] function creates a [CallbackBatch].
#' Predefined callbacks are stored in the [dictionary][mlr3misc::Dictionary] [mlr_callbacks] and can be retrieved with [clbk()].
#' For more information on optimization callbacks see [callback_batch()].
#'
#' @export
#' @examples
#' # write archive to disk
#' callback_batch("bbotk.backup",
#'   on_optimization_end = function(callback, context) {
#'     saveRDS(context$instance$archive, "archive.rds")
#'   }
#' )
CallbackBatch = R6Class("CallbackBatch",
  inherit = Callback,
  public = list(

    #' @field on_optimization_begin (`function()`)\cr
    #'   Stage called at the beginning of the optimization.
    #'   Called in `Optimizer$optimize()`.
    on_optimization_begin = NULL,

    #' @field on_optimizer_before_eval (`function()`)\cr
    #'   Stage called after the optimizer proposes points.
    #'   Called in `OptimInstance$eval_batch()`.
    on_optimizer_before_eval = NULL,

    #' @field on_optimizer_after_eval (`function()`)\cr
    #'   Stage called after points are evaluated.
    #'   Called in `OptimInstance$eval_batch()`.
    on_optimizer_after_eval = NULL,

    #' @field on_result (`function()`)\cr
    #'   Stage called after result are written.
    #'   Called in `OptimInstance$assign_result()`.
    on_result = NULL,

    #' @field on_optimization_end (`function()`)\cr
    #'   Stage called at the end of the optimization.
    #'   Called in `Optimizer$optimize()`.
    on_optimization_end = NULL
  )
)

#' @title Create Batch Optimization Callback
#'
#' @description
#' Function to create a [CallbackBatch].
#'
#' Optimization callbacks can be called from different stages of optimization process.
#' The stages are prefixed with `on_*`.
#'
#' ```
#' Start Optimization
#'      - on_optimization_begin
#'     Start Optimizer Batch
#'          - on_optimizer_before_eval
#'          - on_optimizer_after_eval
#'     End Optimizer Batch
#'      - on_result
#'      - on_optimization_end
#' End Optimization
#' ```
#'
#' See also the section on parameters for more information on the stages.
#' A optimization callback works with [ContextBatch].
#'
#' @details
#' A callback can write data to its state (`$state`), e.g. settings that affect the callback itself.
#' The [ContextBatch] allows to modify the instance, archive, optimizer and final result.
#'
#'
#' @param id (`character(1)`)\cr
#'   Identifier for the new instance.
#' @param label (`character(1)`)\cr
#'   Label for the new instance.
#' @param man (`character(1)`)\cr
#'   String in the format `[pkg]::[topic]` pointing to a manual page for this object.
#'   The referenced help package can be opened via method `$help()`.
#' @param on_optimization_begin (`function()`)\cr
#'   Stage called at the beginning of the optimization.
#'   Called in `Optimizer$optimize()`.
#'   The functions must have two arguments named `callback` and `context`.
#' @param on_optimizer_before_eval (`function()`)\cr
#'   Stage called after the optimizer proposes points.
#'   Called in `OptimInstance$eval_batch()`.
#'   The functions must have two arguments named `callback` and `context`.
#' @param on_optimizer_after_eval (`function()`)\cr
#'   Stage called after points are evaluated.
#'   Called in `OptimInstance$eval_batch()`.
#'   The functions must have two arguments named `callback` and `context`.
#' @param on_result (`function()`)\cr
#'   Stage called after result are written.
#'   Called in `OptimInstance$assign_result()`.
#'   The functions must have two arguments named `callback` and `context`.
#' @param on_optimization_end (`function()`)\cr
#'   Stage called at the end of the optimization.
#'   Called in `Optimizer$optimize()`.
#'   The functions must have two arguments named `callback` and `context`.
#' @param fields (list of `any`)\cr
#'   List of additional fields.
#'
#' @export
#' @inherit CallbackBatch examples
callback_batch = function(
  id,
  label = NA_character_,
  man = NA_character_,
  on_optimization_begin = NULL,
  on_optimizer_before_eval = NULL,
  on_optimizer_after_eval = NULL,
  on_result = NULL,
  on_optimization_end = NULL,
  fields = list()
  ) {
  stages = discard(set_names(list(
    on_optimization_begin,
    on_optimizer_before_eval,
    on_optimizer_after_eval,
    on_result,
    on_optimization_end),
    c(
      "on_optimization_begin",
      "on_optimizer_before_eval",
      "on_optimizer_after_eval",
      "on_result",
      "on_optimization_end")), is.null)
  walk(stages, function(stage) assert_function(stage, args = c("callback", "context")))
  callback = CallbackBatch$new(id, label, man)
  iwalk(stages, function(stage, name) callback[[name]] = stage)
  callback
}
