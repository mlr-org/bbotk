# Calculates the transformed x-values

Transforms a given
[`data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)
to a list with transformed x values. If no trafo is defined it will just
convert the
[`data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)
to a list. Mainly for internal usage.

## Usage

``` r
transform_xdt_to_xss(xdt, search_space)
```

## Arguments

- xdt:

  ([`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html))  
  Set of untransformed points / points from the *search space*. One
  point per row, e.g. `data.table(x1 = c(1, 3), x2 = c(2, 4))`. Column
  names have to match ids of the `search_space`. However, `xdt` can
  contain additional columns.

- search_space:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Specifies the search space for the
  [Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md). The
  [paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)
  describes either a subset of the `domain` of the
  [Objective](https://bbotk.mlr-org.com/dev/reference/Objective.md) or
  it describes a set of parameters together with a `trafo` function that
  transforms values from the search space to values of the domain.
  Depending on the context, this value defaults to the domain of the
  objective.

## Value

[`list()`](https://rdrr.io/r/base/list.html) with transformed x values.
