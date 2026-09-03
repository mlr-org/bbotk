#' @title Best points w.r.t. non dominated sorting with hypervolume contribution.
#'
#' @description Select best subset of points by non dominated sorting with
#'   hypervolume contribution for tie breaking. Works on an arbitrary dimension
#'   of size two or higher.
#'   Non-dominated sorting is computed with [moocore::pareto_rank()] and
#'   hypervolume contributions with [moocore::hv_contributions()].
#'   Boundary points, i.e., points that are best in at least one objective within their front,
#'   always survive tie breaking.
#'
#' @param points (`matrix()`)\cr
#'   Numeric matrix with each column corresponding to a point
#' @template param_n_select
#' @template param_ref_point
#' @param minimize ('logical()')\cr
#'  Should the ranking be based on minimization?
#'  Must be of length 1 for all dimensions or of length `nrow(points)` for each dimension.
#'  Default is `TRUE` for each dimension.
#'
#' @return Vector of indices of selected points
#' @keywords internal
#' @export
nds_selection = function(points, n_select, ref_point = NULL, minimize = TRUE) {
  # check input for correctness
  assert_matrix(points, mode = "numeric", any.missing = FALSE)
  assert_int(n_select, lower = 1, upper = ncol(points))
  assert_logical(minimize, any.missing = FALSE, min.len = 1)
  if (length(minimize) == 1L) minimize = rep(minimize, nrow(points))
  assert_logical(minimize, len = nrow(points), .var.name = "minimize")
  assert_numeric(ref_point, len = nrow(points), null.ok = TRUE)

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
  front_ranks = pareto_rank(t(points))
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
    hv_contrib = hv_contributions(t(tie_points), reference = ref_point)

    # boundary points always survive tie breaking to preserve the spread of the front
    boundary = apply(tie_points == apply(tie_points, 1, min), 2, any)
    hv_contrib[boundary] = Inf

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
