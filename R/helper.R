terminated_error = function(optim_instance) {
  msg = sprintf(
    fmt = "Objective (obj:%s, term:%s) terminated",
    optim_instance$objective$id,
    format(optim_instance$terminator)
  )

  set_class(list(message = msg, call = NULL),
    c("terminated_error", "error", "condition"))
}

#' @title Calculate which points are dominated
#' @description
#' Calculates which points are not dominated,
#' i.e. points that belong to the Pareto front.
#'
#' @param ymat (`matrix()`) \cr
#'   A numeric matrix. Each column (!) contains one point.
#' @useDynLib bbotk c_is_dominated
#' @export
is_dominated = function(ymat) {
  assert_matrix(ymat, mode = "double")
  .Call(c_is_dominated, ymat, PACKAGE = "bbotk")
}

#' @title Calculates the transformed x-values
#' @description
#' Transforms a given `data.table` to a list with transformed x values.
#' If no trafo is defined it will just convert the `data.table` to a list.
#' Mainly for internal usage.
#'
#' @param xdt (`data.table`) \cr
#' The data table with x-columns.
#' Column names have to match ids of the `search_space`.
#' However, `xdt` can contain additional columns.
#' @param search_space [paradox::ParamSet] \cr
#' The ParamSet.
#' @return `list()`
#' @keywords internal
#' @export
transform_xdt_to_xss = function(xdt, search_space) {
  design = Design$new(
    search_space,
    xdt[, search_space$ids(), with = FALSE],
    remove_dupl = FALSE
  )
  design$transpose(trafo = TRUE, filter_na = TRUE)
}
