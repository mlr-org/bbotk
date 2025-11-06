# Get start values for optimizers

Returns a named numeric vector with start values for optimizers.

## Usage

``` r
search_start(search_space, type = "random")
```

## Arguments

- search_space:

  [paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html).

- type:

  (`character(1)`)  
  `random` start values or `center` of search space?

## Value

named [`numeric()`](https://rdrr.io/r/base/numeric.html) with start
values.
