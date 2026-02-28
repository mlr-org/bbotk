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
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2026-02-28 07:04:08  8880
#>  2: finished  2.6451261 -0.47433125    3.20480965 2026-02-28 07:04:08  8880
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2026-02-28 07:04:08  8880
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2026-02-28 07:04:08  8880
#>  5: finished -4.2982254  4.20337792  -81.55629675 2026-02-28 07:04:08  8880
#>  6: finished -5.3318011  3.07859096  -80.70457510 2026-02-28 07:04:08  8880
#>  7: finished -1.2947935  4.44486001  -56.28160502 2026-02-28 07:04:08  8880
#>  8: finished  4.4867714 -4.92985296    0.09163568 2026-02-28 07:04:08  8880
#>  9: finished -4.1477403  2.28072295  -55.68074611 2026-02-28 07:04:08  8880
#> 10: finished -5.6137151  4.91263287 -110.57841706 2026-02-28 07:04:08  8880
#> 11: finished  0.5407374 -0.53103894    1.77478382 2026-02-28 07:04:08  8880
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2026-02-28 07:04:08  8880
#> 13: finished -8.4307422  4.47890861 -154.73445725 2026-02-28 07:04:08  8880
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2026-02-28 07:04:08  8880
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2026-02-28 07:04:08  8880
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2026-02-28 07:04:08  8880
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2026-02-28 07:04:08  8880
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2026-02-28 07:04:08  8880
#> 19: finished -2.3908942  0.02101378  -18.40647620 2026-02-28 07:04:08  8880
#> 20: finished  0.8103813  4.51596998  -47.90499748 2026-02-28 07:04:08  8880
#>        state         x1          x2             y        timestamp_xs   pid
#>       <char>      <num>       <num>         <num>              <POSc> <int>
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2026-02-28 07:04:08 e922827d-0b4d-4d25-9375-ebf898ea8c48
#>  2: papery_hog 2026-02-28 07:04:08 61918332-6435-4d4c-bbed-db7fe93b569f
#>  3: papery_hog 2026-02-28 07:04:08 d8095f05-b5ba-40ef-9b5f-3b115432ef5e
#>  4: papery_hog 2026-02-28 07:04:08 77a5af51-4403-49b1-9395-84b2f806a6ac
#>  5: papery_hog 2026-02-28 07:04:08 59ed1cfe-7ad0-43d4-83d9-c4177812ecc4
#>  6: papery_hog 2026-02-28 07:04:08 14305f70-7e67-4bd2-a492-e2c10ac7d013
#>  7: papery_hog 2026-02-28 07:04:08 c11b8e6b-3f22-44e9-a607-0d7fbad7a179
#>  8: papery_hog 2026-02-28 07:04:08 7c75468d-bc07-462f-acdc-fba205cf90da
#>  9: papery_hog 2026-02-28 07:04:08 faca3226-96be-495e-9071-c35c893d0c19
#> 10: papery_hog 2026-02-28 07:04:08 fa7999f2-4979-4423-96e4-8748991c1e7f
#> 11: papery_hog 2026-02-28 07:04:08 4cf7fc3b-32b0-4b7a-927f-8da7c9476a66
#> 12: papery_hog 2026-02-28 07:04:08 b597f729-6bad-44f7-a067-df81aafc3341
#> 13: papery_hog 2026-02-28 07:04:08 7241c6c1-f331-4229-b031-9286909bc345
#> 14: papery_hog 2026-02-28 07:04:08 03166e2e-2325-4d8b-b1d1-74f6ed2a4f80
#> 15: papery_hog 2026-02-28 07:04:08 4a580f64-de11-4dc5-8614-afa430bbff78
#> 16: papery_hog 2026-02-28 07:04:08 d5fd5df3-92f0-4be1-aadb-9cfa55bd036e
#> 17: papery_hog 2026-02-28 07:04:08 8ea959cd-7eaa-481a-90da-84b264ae89eb
#> 18: papery_hog 2026-02-28 07:04:08 84fe2c33-7780-4262-8565-52388b27a4d5
#> 19: papery_hog 2026-02-28 07:04:08 d8d646af-69ef-426f-b702-d6a1eefffb84
#> 20: papery_hog 2026-02-28 07:04:08 a0c08325-1b16-4dba-9eb9-22fd437e9862
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
