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
  with fields "key", "label", "dimension", "optimum", and "optimum_x" as
  columns. If `objects` is set to `TRUE`, the constructed objects are
  returned in the list column named `object`.

## See also

Sugar functions:
[`otfun()`](https://bbotk.mlr-org.com/dev/reference/otfun.md),
[`otfuns()`](https://bbotk.mlr-org.com/dev/reference/otfun.md)

## Examples

``` r
as.data.table(mlr_test_functions)
#> Key: <key>
#>                 key           label dimension      optimum optimum_x
#>              <char>          <char>     <int>        <num>    <list>
#>  1:           beale           Beale         2    0.0000000 <list[1]>
#>  2:          branin          Branin         2    0.3978870 <list[3]>
#>  3:       branin_wu       Branin-Wu         2    0.3978870 <list[3]>
#>  4:   cross_in_tray   Cross-in-Tray         2   -2.0626100 <list[4]>
#>  5:       eggholder       Eggholder         2 -959.6407000 <list[1]>
#>  6:       forrester       Forrester         1   -6.0207400 <list[1]>
#>  7: goldstein_price Goldstein-Price         2    3.0000000 <list[1]>
#>  8:     gramacy_lee     Gramacy-Lee         1   -0.8690111 <list[1]>
#>  9:      himmelblau      Himmelblau         2    0.0000000 <list[4]>
#> 10:    holder_table    Holder Table         2  -19.2085000 <list[4]>
#> 11:       mccormick       McCormick         2   -1.9133000 <list[1]>
#> 12:       rastrigin       Rastrigin         2    0.0000000 <list[1]>
#> 13:      rosenbrock      Rosenbrock         2    0.0000000 <list[1]>
#> 14:        schwefel        Schwefel         2    0.0000000 <list[1]>
#> 15:  six_hump_camel  Six-Hump Camel         2   -1.0316000 <list[2]>
#> 16:          sphere          Sphere         2    0.0000000 <list[1]>
#> 17: styblinski_tang Styblinski-Tang         2  -78.3319800 <list[1]>
obj = mlr_test_functions$get("branin")
obj$eval(list(x1 = 0, x2 = 0))
#> $y
#> [1] 55.60211
#> 
```
