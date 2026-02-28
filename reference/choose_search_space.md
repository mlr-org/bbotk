# Choose Search Space

Determines the search space from an objective's domain, handling
TuneTokens. Used internally by
[OptimInstance](https://bbotk.mlr-org.com/reference/OptimInstance.md)
and
[OptimInstanceAsync](https://bbotk.mlr-org.com/reference/OptimInstanceAsync.md).

## Usage

``` r
choose_search_space(objective, search_space)
```

## Arguments

- objective:

  ([Objective](https://bbotk.mlr-org.com/reference/Objective.md)) The
  objective function.

- search_space:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)
  \| `NULL`) Optional explicit search space.

## Value

A
[paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)
to use as the search space.
