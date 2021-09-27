#' @import data.table
#' @import checkmate
#' @import paradox
#' @import mlr3misc
#' @importFrom R6 R6Class
#' @importFrom utils capture.output head tail
#' @importFrom methods formalArgs
"_PACKAGE"

.onLoad = function(libname, pkgname) {
  # nocov start
  lg = lgr::get_logger("bbotk")
  assign("lg", lg, envir = parent.env(environment()))
  f = function(event) {
    event$msg = paste("[bbotk]", event$msg)
    TRUE
  }
  lg$set_filters(f)

  if (Sys.getenv("IN_PKGDOWN") == "true") {
    lg$set_threshold("warn")
  }
} # nocov end


leanify_package()
