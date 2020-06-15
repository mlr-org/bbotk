#' @import data.table
#' @import checkmate
#' @import paradox
#' @import mlr3misc
#' @importFrom R6 R6Class
"_PACKAGE"


.onLoad = function(libname, pkgname) {
  # nocov start

  if(isNamespaceLoaded("mlr3tuning")) {
    assign("lg", lgr::get_logger("mlr3/mlr3tuning"), envir = parent.env(environment()))
  } else if (isNamespaceLoaded("mlr3fselect")) {
    assign("lg", lgr::get_logger("mlr3/mlr3fselect"), envir = parent.env(environment()))
  } else {
    assign("lg", lgr::get_logger("bbotk"), envir = parent.env(environment()))
  }

  if (Sys.getenv("IN_PKGDOWN") == "true") {
    lg$set_threshold("warn")
  }
} # nocov end
