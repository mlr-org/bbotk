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

if (FALSE) {
  ymat = matrix(c(1, 2, 2, 1, 2, 2), nrow = 2)
  print(ymat)
  is_dominated(ymat)

  ymat = matrix(runif(2 * 100), nrow = 2)
  is_dominated(ymat)
  ymat
  bm(is_dominated(ymat), is_dominated_r(ymat))


  ymat = matrix(c(0.1, 0.3, 0.2, 0.4, 0.3, 0.1), nrow = 2)
  ymat
  is_dominated(ymat)

}

is_dominated_r = function(ymat) {
  #FIXME Replace with C implementation
  # implementation based emoa/src/dominance.c

  n = ncol(ymat)
  d = nrow(ymat)
  res = logical(n)
  dom = 0L
  idom = FALSE
  jdom = FALSE

  for (i in seq_len(n)) {
    if (!res[i]) {
      for (j in seq(min(n, i + 1), n)) {
        if (!res[j]) {
          idom = jdom = FALSE
          for (k in seq_len(d)) {
            if (ymat[k, i] < ymat[k, j]) {
              jdom = TRUE
            } else if (ymat[k, j] < ymat[k, i]) {
              idom = TRUE
            }
          }
          dom = jdom - idom
          if (dom == 1) {
            res[j] = TRUE # i dominates j
          } else if (dom == -1) {
            res[i] = TRUE # j dominates i
          }
        }
      }
    }
  }

  return(res)
}
