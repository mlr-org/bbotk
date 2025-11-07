# Best points w.r.t. non dominated sorting with hypervolume contribution.

Select best subset of points by non dominated sorting with hypervolume
contribution for tie breaking. Works on an arbitrary dimension of size
two or higher.

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
