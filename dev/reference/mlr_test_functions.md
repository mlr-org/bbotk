# Dictionary of Optimization Test Functions

A simple
[mlr3misc::Dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
storing well-known optimization test functions as
[ObjectiveRFun](https://bbotk.mlr-org.com/dev/reference/ObjectiveRFun.md)
objects.

Each objective has two additional fields beyond the standard
[ObjectiveRFun](https://bbotk.mlr-org.com/dev/reference/ObjectiveRFun.md)
interface:

- `optimum` (`numeric(1)`) - Known global optimum value (f\*).

- `optimum_x` ([`list()`](https://rdrr.io/r/base/list.html)) - List of
  known global optima (each a named list).

For a more convenient way to retrieve test functions, see
[`otfun()`](https://bbotk.mlr-org.com/dev/reference/otfun.md)/[`otfuns()`](https://bbotk.mlr-org.com/dev/reference/otfun.md).

## Format

[R6::R6Class](https://r6.r-lib.org/reference/R6Class.html) object
inheriting from
[mlr3misc::Dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html).

## Methods

See
[mlr3misc::Dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html).

## S3 methods

- `as.data.table(dict, ..., objects = FALSE)`  
  [mlr3misc::Dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
  -\>
  [`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)  
  Returns a
  [`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)
  with fields "key", "label", "optimum", and "optimum_x" as columns. If
  `objects` is set to `TRUE`, the constructed objects are returned in
  the list column named `object`.

## See also

Sugar functions:
[`otfun()`](https://bbotk.mlr-org.com/dev/reference/otfun.md),
[`otfuns()`](https://bbotk.mlr-org.com/dev/reference/otfun.md)

## Examples

``` r
as.data.table(mlr_test_functions)
#> Key: <key>
#>                 key           label     optimum optimum_x
#>              <char>          <char>       <num>    <list>
#>  1:           beale           Beale    0.000000 <list[1]>
#>  2:          branin          Branin    0.397887 <list[3]>
#>  3:       branin_wu       Branin-Wu    0.397887 <list[3]>
#>  4:   cross_in_tray   Cross-in-Tray   -2.062610 <list[4]>
#>  5:       eggholder       Eggholder -959.640700 <list[1]>
#>  6: goldstein_price Goldstein-Price    3.000000 <list[1]>
#>  7:      himmelblau      Himmelblau    0.000000 <list[4]>
#>  8:    holder_table    Holder Table  -19.208500 <list[4]>
#>  9:       mccormick       McCormick   -1.913300 <list[1]>
#> 10:       rastrigin       Rastrigin    0.000000 <list[1]>
#> 11:      rosenbrock      Rosenbrock    0.000000 <list[1]>
#> 12:        schwefel        Schwefel    0.000000 <list[1]>
#> 13:  six_hump_camel  Six-Hump Camel   -1.031600 <list[2]>
#> 14:          sphere          Sphere    0.000000 <list[1]>
#> 15: styblinski_tang Styblinski-Tang  -78.331980 <list[1]>
obj = mlr_test_functions$get("branin")
obj$eval(list(x1 = 0, x2 = 0))
#> $y
#> [1] 55.60211
#> 
```
