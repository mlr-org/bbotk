# Asynchronous Optimization via Random Search

`OptimizerAsyncRandomSearch` class that implements a simple Random
Search.

## Source

Bergstra J, Bengio Y (2012). “Random Search for Hyper-Parameter
Optimization.” *Journal of Machine Learning Research*, **13**(10),
281–305. <https://jmlr.csail.mit.edu/papers/v13/bergstra12a.html>.

## Dictionary

This [Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/dev/reference/opt.md):

    mlr_optimizers$get("async_random_search")
    opt("async_random_search")

## Super classes

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
-\>
[`bbotk::OptimizerAsync`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md)
-\> `OptimizerAsyncRandomSearch`

## Methods

### Public methods

- [`OptimizerAsyncRandomSearch$new()`](#method-OptimizerAsyncRandomSearch-new)

- [`OptimizerAsyncRandomSearch$clone()`](#method-OptimizerAsyncRandomSearch-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)
- [`bbotk::OptimizerAsync$optimize()`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.html#method-optimize)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerAsyncRandomSearch$new()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerAsyncRandomSearch$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# example only runs if a Redis server is available
if (mlr3misc::require_namespaces(c("rush", "redux", "mirai"), quietly = TRUE) &&
  redux::redis_available()) {
# define the objective function
fun = function(xs) {
  list(y = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
}

# set domain
domain = ps(
  x1 = p_dbl(-10, 10),
  x2 = p_dbl(-5, 5)
)

# set codomain
codomain = ps(
  y = p_dbl(tags = "maximize")
)

# create objective
objective = ObjectiveRFun$new(
  fun = fun,
  domain = domain,
  codomain = codomain,
  properties = "deterministic"
)

# start workers
rush::rush_plan(worker_type = "remote")
mirai::daemons(1)

# initialize instance
instance = oi_async(
  objective = objective,
  terminator = trm("evals", n_evals = 20)
)

# load optimizer
optimizer = opt("async_random_search")

# trigger optimization
optimizer$optimize(instance)

# all evaluated configurations
instance$archive

# best performing configuration
instance$archive$best()

# covert to data.table
as.data.table(instance$archive)
}
#>        state         x1          x2             y        timestamp_xs   pid
#>       <char>      <num>       <num>         <num>              <POSc> <int>
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2026-02-27 14:23:28  8901
#>  2: finished  2.6451261 -0.47433125    3.20480965 2026-02-27 14:23:28  8901
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2026-02-27 14:23:28  8901
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2026-02-27 14:23:28  8901
#>  5: finished -4.2982254  4.20337792  -81.55629675 2026-02-27 14:23:28  8901
#>  6: finished -5.3318011  3.07859096  -80.70457510 2026-02-27 14:23:28  8901
#>  7: finished -1.2947935  4.44486001  -56.28160502 2026-02-27 14:23:28  8901
#>  8: finished  4.4867714 -4.92985296    0.09163568 2026-02-27 14:23:28  8901
#>  9: finished -4.1477403  2.28072295  -55.68074611 2026-02-27 14:23:28  8901
#> 10: finished -5.6137151  4.91263287 -110.57841706 2026-02-27 14:23:28  8901
#> 11: finished  0.5407374 -0.53103894    1.77478382 2026-02-27 14:23:28  8901
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2026-02-27 14:23:28  8901
#> 13: finished -8.4307422  4.47890861 -154.73445725 2026-02-27 14:23:28  8901
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2026-02-27 14:23:28  8901
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2026-02-27 14:23:28  8901
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2026-02-27 14:23:28  8901
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2026-02-27 14:23:28  8901
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2026-02-27 14:23:28  8901
#> 19: finished -2.3908942  0.02101378  -18.40647620 2026-02-27 14:23:28  8901
#> 20: finished  0.8103813  4.51596998  -47.90499748 2026-02-27 14:23:28  8901
#>        state         x1          x2             y        timestamp_xs   pid
#>       <char>      <num>       <num>         <num>              <POSc> <int>
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2026-02-27 14:23:28 b75e0361-9f88-44e1-bd84-3e39dab4160b
#>  2: papery_hog 2026-02-27 14:23:28 682dd19b-9b55-4142-a414-4fd1acd65d64
#>  3: papery_hog 2026-02-27 14:23:28 5be92cb4-5ec2-476a-acb9-ac8abaa26015
#>  4: papery_hog 2026-02-27 14:23:28 8ab1eb4c-9b07-4d3e-98c5-a145522f5b21
#>  5: papery_hog 2026-02-27 14:23:28 b175bac2-95be-4330-ba8b-819989e47156
#>  6: papery_hog 2026-02-27 14:23:28 aed1d2a7-bae9-48cb-83bd-b9033abcf6ec
#>  7: papery_hog 2026-02-27 14:23:28 0be17493-18ed-4e52-8601-3252ee7c4a26
#>  8: papery_hog 2026-02-27 14:23:28 4145d959-6806-4538-8bea-096e700a3993
#>  9: papery_hog 2026-02-27 14:23:28 52077247-299e-4aab-b813-efbe1a90bf70
#> 10: papery_hog 2026-02-27 14:23:28 4e9db61d-785b-4288-a4f8-565df02d1627
#> 11: papery_hog 2026-02-27 14:23:28 717f3291-ec34-4d39-b9b9-04dba0885b4b
#> 12: papery_hog 2026-02-27 14:23:28 32894956-5830-486f-82d7-0c49bef2bc8d
#> 13: papery_hog 2026-02-27 14:23:28 c8e62cc5-80eb-4901-a68c-63ca4b1f8015
#> 14: papery_hog 2026-02-27 14:23:28 65ed7723-addf-4071-977a-9050fe276e1d
#> 15: papery_hog 2026-02-27 14:23:28 c4d34aaf-ce2d-4d1c-9588-5b747a0a4eb5
#> 16: papery_hog 2026-02-27 14:23:28 457ed91b-8cdc-4ee1-abc8-74b33546e5f2
#> 17: papery_hog 2026-02-27 14:23:28 3ff300e3-5173-44f5-bdc6-1d1bcfe84428
#> 18: papery_hog 2026-02-27 14:23:28 ee103518-feb5-4374-ba91-60ae5e6a5981
#> 19: papery_hog 2026-02-27 14:23:28 d0bb0d6a-577e-4d39-b9ce-14bb9ed9d64d
#> 20: papery_hog 2026-02-27 14:23:28 b70f869f-564f-4bff-ac65-5ad7ab0d4c8b
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>     x_domain_x1 x_domain_x2
#>           <num>       <num>
#>  1:  -8.6401429 -0.22082921
#>  2:   2.6451261 -0.47433125
#>  3:   6.6553863 -4.98604438
#>  4:   5.0158969 -1.16851633
#>  5:  -4.2982254  4.20337792
#>  6:  -5.3318011  3.07859096
#>  7:  -1.2947935  4.44486001
#>  8:   4.4867714 -4.92985296
#>  9:  -4.1477403  2.28072295
#> 10:  -5.6137151  4.91263287
#> 11:   0.5407374 -0.53103894
#> 12:  -5.7833451 -3.39854730
#> 13:  -8.4307422  4.47890861
#> 14:   7.1022916 -0.75569363
#> 15:   5.9002467 -2.48642191
#> 16:   4.0407162 -0.43184476
#> 17:  -7.4830553 -2.92798538
#> 18:  -3.9849409 -1.06526646
#> 19:  -2.3908942  0.02101378
#> 20:   0.8103813  4.51596998
#>     x_domain_x1 x_domain_x2
#>           <num>       <num>
```
