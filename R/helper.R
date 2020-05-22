terminated_error = function(optim_instance) {
  msg = sprintf(
    fmt = "Objective (obj:%s, term:%s) terminated",
    optim_instance$objective$id,
    format(optim_instance$terminator)
  )

  set_class(list(message = msg, call = NULL),
    c("terminated_error", "error", "condition"))
}

# r implementation of emoa do_is_dominated (emoa/src/dominance.c)
# for 1000x2 matrix it is actually faster then going into c
#' @title Calculate which points are domintad
#' @description A slow implementation that calculates which points are not dominated / belong to the Pareto front.
#' @param ymat `matrix` \cr
#'   A numeric matrix. Each column(!) contains one point.
#' @export
is_dominated = function(ymat) {
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
      for (j in seq(min(n,i+1), n)) {
        if (!res[j]) {
          idom = jdom = FALSE
          for (k in seq_len(d)) {
            if (ymat[k,i] < ymat[k,j]) jdom = TRUE
            else if (ymat[k,j] < ymat[k,i]) idom = TRUE
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
