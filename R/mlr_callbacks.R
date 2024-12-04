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

#' @title Freeze Archive Callback
#'
#' @include CallbackAsync.R
#' @name bbotk.async_freeze_archive
#'
#' @description
#' This [CallbackAsync] freezes the [ArchiveAsync] to [ArchiveAsyncFrozen] after the optimization has finished.
#'
#' @examples
#' clbk("bbotk.async_freeze_archive")
NULL

load_callback_freeze_archive = function() {
  callback_async("bbotk.async_freeze_archive",
    label = "Archive Freeze Callback",
    man = "bbotk::bbotk.async_freeze_archive",
    on_optimization_end = function(callback, context) {
      context$instance$archive = ArchiveAsyncFrozen$new(context$instance$archive)
    }
  )
}


