# Shrink a ParamSet towards a point.

Shrinks a
[paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)
towards a point. Boundaries of numeric values are shrinked to an
interval around the point of half of the previous length, while for
discrete variables, a random (currently not chosen) level is dropped.

Note that for
[`paradox::p_lgl()`](https://paradox.mlr-org.com/reference/Domain.html)s
the value to be shrinked around is set as the `default` value instead of
dropping a level. Also, a tag `shrinked` is added.

Note that the returned
[paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)
has lost all its original `default`s, as they may have become
infeasible.

If the
[paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)
has a trafo, `x` is expected to contain the transformed values.

## Usage

``` r
shrink_ps(param_set, x, check.feasible = FALSE)
```

## Arguments

- param_set:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  The
  [paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)
  to be shrinked.

- x:

  ([data.table::data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html))  
  [data.table::data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html)
  with one row containing the point to shrink around.

- check.feasible:

  (`logical(1)`)  
  Should feasibility of the parameters be checked? If feasibility is not
  checked, and invalid values are present, no shrinking will be done.
  Must be turned off in the case of the
  [paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)
  having a trafo. Default is `FALSE`.

## Value

[paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)

## Examples

``` r
library(paradox)
library(data.table)
param_set = ps(
  x = p_dbl(lower = 0, upper = 10),
  x2 = p_int(lower = -10, upper = 10),
  x3 = p_fct(levels = c("a", "b", "c")),
  x4 = p_lgl()
)
x = data.table(x1 = 5, x2 = 0, x3 = "b", x4 = FALSE)
shrink_ps(param_set, x = x)
#> <ParamSet(4)>
#>        id    class lower upper nlevels        default  value
#>    <char>   <char> <num> <num>   <num>         <list> <list>
#> 1:      x ParamDbl     0    10     Inf <NoDefault[0]> [NULL]
#> 2:     x2 ParamInt    -5     5      11 <NoDefault[0]> [NULL]
#> 3:     x3 ParamFct    NA    NA       2 <NoDefault[0]> [NULL]
#> 4:     x4 ParamLgl    NA    NA       2          FALSE [NULL]
```
