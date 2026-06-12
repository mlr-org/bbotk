# Calculate which points are dominated

Returns which points from a set are dominated by another point in the
set. See
[`moocore::is_nondominated()`](https://multi-objective.github.io/moocore/r/reference/nondominated.html)
for details about the implementation. Points that are equal to each
other are all considered non-dominated, i.e. weakly dominated points are
kept.

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

## See also

[`moocore::is_nondominated()`](https://multi-objective.github.io/moocore/r/reference/nondominated.html)
