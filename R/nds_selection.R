#' @title Best points w.r.t. non dominated sorting with hypervolume contribution.
#'
#' @description Select best subset of points by non dominated sorting with
#'   hypervolume contribution for tie breaking. Works on an arbitrary dimension
#'   of size two or higher.
#'
#' @param points (`matrix()`)\cr
#'   Numeric matrix with each column corresponding to a point
#' @template param_n_select
#' @template param_ref_point
#' @param minimize ('logical()')\cr
#'  Should the ranking be based on minimization?
#'  Can be specified for each dimension or for all.
#'  Default is `TRUE` for each dimension.
#'
#' @return Vector of indices of selected points
#' @keywords internal
#' @export
nds_selection = function(points, n_select, ref_point = NULL, minimize = TRUE) {

  require_namespaces("emoa")

  # check input for correctness
  assert_matrix(points, mode = "numeric")
  assert_int(n_select, lower = 1, upper = ncol(points))
  assert_logical(
    minimize, min.len = 1, max.len = nrow(points), any.missing = FALSE
  )
  assert_numeric(ref_point, len = nrow(points), null.ok = TRUE)
  assert_logical(minimize)

  # maximize/minimize preprocessing: switch sign in each dim to minimize
  points = points * (minimize * 2 - 1)

  # also switch sign for the reference point if reference point is given
  # otherwise use the maximum values in each dimension
  if (!is.null(ref_point)) {
    ref_point = ref_point * (minimize * 2 - 1)
  } else {
    ref_point = apply(points, 1, max)
  }

  # init output indices
  survivors = seq_col(points)

  # front indices of every point
  front_ranks = emoa::nds_rank(points)
  # the index of the highest front in the end selection
  last_sel_front = min(which(cumsum(table(front_ranks)) >= n_select))

  # non-tied indices by nds rank
  sel_surv = survivors[front_ranks < last_sel_front]

  # tied subselection of indices/points
  tie_surv = survivors[front_ranks == last_sel_front]
  tie_points = points[, front_ranks == last_sel_front, drop = FALSE]

  # remove tied indices/points as long as we are bigger than n_select
  while (length(tie_surv) + length(sel_surv) > n_select) {

    # compute hypervolume contribution
    hv_contrib = emoa::hypervolume_contribution(tie_points, ref_point)

    # index of the tied case with the lowest hypervolume contribution
    to_remove = which(hv_contrib == min(hv_contrib))

    # if two points have the exact same hypervolume contribution, the point is sampled
    if (length(to_remove) > 1) {
      to_remove = sample(to_remove, 1)
    }

    tie_points = tie_points[, -to_remove, drop = FALSE]
    tie_surv = tie_surv[-to_remove]
  }

  # since we only have the true ranks of the ties, we sort to make the output
  # not misleading
  sort(c(sel_surv, tie_surv))
}
