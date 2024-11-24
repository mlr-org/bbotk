#' @title Backup Archive Callback
#'
#' @include CallbackBatch.R
#' @name bbotk.backup
#'
#' @description
#' This [CallbackBatch] writes the [Archive] after each batch to disk.
#'
#' @examples
#' clbk("bbotk.backup", path = "backup.rds")
NULL

load_callback_backup = function() {
  callback_batch("bbotk.backup",
    label = "Backup Archive Callback",
    man = "bbotk::bbotk.backup",
    on_optimization_begin = function(callback, context) {
      assert_path_for_output(callback$state$path)
    },

    on_optimizer_after_eval = function(callback, context) {
      if (file.exists(callback$state$path)) unlink(callback$state$path)
      saveRDS(context$instance$archive$data, callback$state$path)
    }
  )
}
