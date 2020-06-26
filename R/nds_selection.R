#' @title Best points w.r.t. non dominated sorting with hypervolume contribution.
#'
#' @description Select best subset of points by non dominated sorting with
#'   hypervolume contribution for tie breaking. Works on an arbitrary dimension
#'   of size two or higher.
#' @param points (`matrix()`)\cr
#'   Numeric matrix with each column corresponding to a point
#' @template param_n_select
#' @template param_ref_point
#' @param minimize ('logical()')\cr
#'  Should the ranking be based on minimization?
#'  Can be specified for each dimension or for all.
#'  Default is `TRUE` for each dimension.
#' @return Vector of indices of selected points
#' @export
nds_selection = function(points, n_select, ref_point = NULL, minimize = TRUE) {

  require_namespaces("emoa")

  # check input for correctness
  assert_matrix(points, mode = "numeric")
  assert_int(n_select, lower = 1, upper = ncol(points))
  if (length(minimize) == 1) {
    minimize = rep(minimize, times = nrow(points))
  }
  assert_logical(minimize, len = nrow(points), any.missing = FALSE)
  assert_numeric(ref_point, len = nrow(points), null.ok = TRUE)

  # maximize/minimize preprocessing: switch sign in each dim to maximize
  points = points * (minimize * 2 - 1)

  # init output indices
  survivors = seq_col(points)

  # if no reference point is defined, use maximum of each dimensions
  if (is.null(ref_point)) {
    ref_point = apply(points, 1, max)
  }

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

    # tie points extended with the reference point to never end up with a two
    # point matrix (this would break the following sapply)
    tie_points_ext = cbind(tie_points, ref_point)

    # calculate the hypervolume with each point excluded separately
    hypervolumes = map_dbl(
      seq_len(ncol(tie_points_ext) - 1L),
      function(i) {
        emoa::dominated_hypervolume(
          tie_points_ext[, -i, drop = FALSE],
          ref = ref_point
        )
      }
    )

    # index of the tied case with the lowest hypervolume contribution
    to_remove = which(hypervolumes == max(hypervolumes))
    # sample the index as tie breaker
    to_remove = sample(to_remove, 1)
    tie_points = tie_points[, -to_remove, drop = FALSE]
    tie_surv = tie_surv[-to_remove]
  }

  # since we only have the true ranks of the ties, we sort to make the output
  # not misleading
  sort(c(sel_surv, tie_surv))
}
