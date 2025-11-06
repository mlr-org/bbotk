# Dictionary of Optimizer

A simple
[mlr3misc::Dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
storing objects of class
[Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md). Each
optimizer has an associated help page, see `mlr_optimizer_[id]`.

This dictionary can get populated with additional optimizer by add-on
packages.

For a more convenient way to retrieve and construct optimizer, see
[`opt()`](https://bbotk.mlr-org.com/dev/reference/opt.md)/[`opts()`](https://bbotk.mlr-org.com/dev/reference/opt.md).

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
  [`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)  
  Returns a
  [`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)
  with fields "key", "label", "param_classes", "properties" and
  "packages" as columns. If `objects` is set to `TRUE`, the constructed
  objects are returned in the list column named `object`.

## See also

Sugar functions:
[`opt()`](https://bbotk.mlr-org.com/dev/reference/opt.md),
[`opts()`](https://bbotk.mlr-org.com/dev/reference/opt.md)

## Examples

``` r
as.data.table(mlr_optimizers)
#> Key: <key>
#>                     key                                           label
#>                  <char>                                          <char>
#>  1: async_design_points                      Asynchronous Design Points
#>  2:   async_grid_search                        Asynchronous Grid Search
#>  3: async_random_search                      Asynchronous Random Search
#>  4:               chain          Chain Multiple Optimizers Sequentially
#>  5:               cmaes Covariance Matrix Adaptation Evolution Strategy
#>  6:       design_points                                   Design Points
#>  7:        focus_search                                    Focus Search
#>  8:               gensa                 Generalized Simulated Annealing
#>  9:         grid_search                                     Grid Search
#> 10:               irace                                 Iterated Racing
#> 11:        local_search                                    Local Search
#> 12:              nloptr                         Non-linear Optimization
#> 13:       random_search                                   Random Search
#>                                    param_classes
#>                                           <list>
#>  1: ParamLgl,ParamInt,ParamDbl,ParamFct,ParamUty
#>  2:          ParamLgl,ParamInt,ParamDbl,ParamFct
#>  3:          ParamLgl,ParamInt,ParamDbl,ParamFct
#>  4:          ParamLgl,ParamInt,ParamDbl,ParamFct
#>  5:                                     ParamDbl
#>  6: ParamLgl,ParamInt,ParamDbl,ParamFct,ParamUty
#>  7:          ParamLgl,ParamInt,ParamDbl,ParamFct
#>  8:                                     ParamDbl
#>  9:          ParamLgl,ParamInt,ParamDbl,ParamFct
#> 10:          ParamDbl,ParamInt,ParamFct,ParamLgl
#> 11:          ParamLgl,ParamInt,ParamDbl,ParamFct
#> 12:                                     ParamDbl
#> 13:          ParamLgl,ParamInt,ParamDbl,ParamFct
#>                                    properties     packages
#>                                        <list>       <list>
#>  1: dependencies,single-crit,multi-crit,async   bbotk,rush
#>  2: dependencies,single-crit,multi-crit,async   bbotk,rush
#>  3: dependencies,single-crit,multi-crit,async   bbotk,rush
#>  4:       dependencies,single-crit,multi-crit        bbotk
#>  5:                               single-crit bbotk,adagio
#>  6:       dependencies,single-crit,multi-crit        bbotk
#>  7:                  dependencies,single-crit        bbotk
#>  8:                               single-crit  bbotk,GenSA
#>  9:       dependencies,single-crit,multi-crit        bbotk
#> 10:                  dependencies,single-crit  bbotk,irace
#> 11:                  dependencies,single-crit        bbotk
#> 12:                               single-crit bbotk,nloptr
#> 13:       dependencies,single-crit,multi-crit        bbotk
mlr_optimizers$get("random_search")
#> 
#> ── <OptimizerBatchRandomSearch> - Random Search ────────────────────────────────
#> • Parameters: batch_size=1
#> • Parameter classes: <ParamLgl>, <ParamInt>, <ParamDbl>, and <ParamFct>
#> • Properties: dependencies, single-crit, and multi-crit
#> • Packages: bbotk
opt("random_search")
#> 
#> ── <OptimizerBatchRandomSearch> - Random Search ────────────────────────────────
#> • Parameters: batch_size=1
#> • Parameter classes: <ParamLgl>, <ParamInt>, <ParamDbl>, and <ParamFct>
#> • Properties: dependencies, single-crit, and multi-crit
#> • Packages: bbotk
```
