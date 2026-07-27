# Best points w.r.t. non dominated sorting with hypervolume contribution.

Select best subset of points by non dominated sorting with hypervolume
contribution for tie breaking. Works on an arbitrary dimension of size
two or higher. Non-dominated sorting is computed with
[`moocore::pareto_rank()`](https://multi-objective.github.io/moocore/r/reference/pareto_rank.html)
and hypervolume contributions with
[`moocore::hv_contributions()`](https://multi-objective.github.io/moocore/r/reference/hv_contributions.html).
Boundary points, i.e., points that are best in at least one objective
within their front, always survive tie breaking.

## Usage

``` r
nds_selection(points, n_select, ref_point = NULL, minimize = TRUE)
```

## Arguments

- points:

  ([`matrix()`](https://rdrr.io/r/base/matrix.html))  
  Numeric matrix with each column corresponding to a point

- n_select:

  (`integer(1L)`)  
  Amount of points to select.

- ref_point:

  ([`numeric()`](https://rdrr.io/r/base/numeric.html))  
  Reference point for hypervolume.

- minimize:

  ('logical()')  
  Should the ranking be based on minimization? Can be specified for each
  dimension or for all. Default is `TRUE` for each dimension.

## Value

Vector of indices of selected points
