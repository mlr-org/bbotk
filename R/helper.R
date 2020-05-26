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
#' A slow implementation that calculates which points are not dominated,
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
