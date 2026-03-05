# Syntactic Sugar for Optimization Test Functions

This function complements
[mlr_test_functions](https://bbotk.mlr-org.com/dev/reference/mlr_test_functions.md)
with functions in the spirit of `mlr_sugar` from
[mlr3](https://CRAN.R-project.org/package=mlr3).

## Usage

``` r
otfun(.key, ...)

otfuns(.keys, ...)
```

## Arguments

- .key:

  (`character(1)`)  
  Key passed to the respective
  [dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
  to retrieve the object.

- ...:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named arguments passed to the constructor. See
  [`mlr3misc::dictionary_sugar_get()`](https://mlr3misc.mlr-org.com/reference/dictionary_sugar_get.html)
  for more details.

- .keys:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Keys passed to the respective
  [dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
  to retrieve multiple objects.

## Value

- [ObjectiveRFun](https://bbotk.mlr-org.com/dev/reference/ObjectiveRFun.md)
  for `otfun()`.

- list of
  [ObjectiveRFun](https://bbotk.mlr-org.com/dev/reference/ObjectiveRFun.md)
  for `otfuns()`.

## Examples

``` r
obj = otfun("branin")
obj$eval(list(x1 = 1, x2 = 2))
#> $y
#> [1] 21.62764
#> 
```
