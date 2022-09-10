#' @title Backup Archive Callback
#'
#' @include CallbackOptimization.R
#' @name bbotk.backup
#'
#' @description
#' This [Callback] writes the [Archive] after each batch to disk.
#'
#' @examples
#' clbk("bbotk.backup", path = "backup.rds")
NULL

callback_backup = callback_optimization("mlr3tuning.backup",
  label = "Backup Benchmark Result Callback",
  man = "mlr3tuning::mlr3tuning.backup",
  on_optimization_begin = function(callback, context) {
    assert_path_for_output(callback$state$path)
  },

  on_optimizer_after_eval = function(callback, context) {
    if (file.exists(callback$state$path)) unlink(callback$state$path)
    saveRDS(context$instance$archive$data, callback$state$path)
  },
  fields = list(path = "archive.rds")
)

mlr_callbacks$add("bbotk.backup", callback_backup)
