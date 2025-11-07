# Calculate which points are dominated

Returns which points from a set are dominated by another point in the
set.

## Usage

``` r
is_dominated(ymat)
```

## Arguments

- ymat:

  ([`matrix()`](https://rdrr.io/r/base/matrix.html))  
  A numeric matrix. Each column (!) contains one point.

## Value

[`logical()`](https://rdrr.io/r/base/logical.html) with `TRUE` if a
point (column of `ymat`) is dominated.
