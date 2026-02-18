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
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2026-02-18 13:47:25  8743
#>  2: finished  2.6451261 -0.47433125    3.20480965 2026-02-18 13:47:25  8743
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2026-02-18 13:47:25  8743
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2026-02-18 13:47:25  8743
#>  5: finished -4.2982254  4.20337792  -81.55629675 2026-02-18 13:47:25  8743
#>  6: finished -5.3318011  3.07859096  -80.70457510 2026-02-18 13:47:25  8743
#>  7: finished -1.2947935  4.44486001  -56.28160502 2026-02-18 13:47:25  8743
#>  8: finished  4.4867714 -4.92985296    0.09163568 2026-02-18 13:47:25  8743
#>  9: finished -4.1477403  2.28072295  -55.68074611 2026-02-18 13:47:25  8743
#> 10: finished -5.6137151  4.91263287 -110.57841706 2026-02-18 13:47:25  8743
#> 11: finished  0.5407374 -0.53103894    1.77478382 2026-02-18 13:47:25  8743
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2026-02-18 13:47:25  8743
#> 13: finished -8.4307422  4.47890861 -154.73445725 2026-02-18 13:47:25  8743
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2026-02-18 13:47:25  8743
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2026-02-18 13:47:26  8743
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2026-02-18 13:47:26  8743
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2026-02-18 13:47:26  8743
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2026-02-18 13:47:26  8743
#> 19: finished -2.3908942  0.02101378  -18.40647620 2026-02-18 13:47:26  8743
#> 20: finished  0.8103813  4.51596998  -47.90499748 2026-02-18 13:47:26  8743
#>        state         x1          x2             y        timestamp_xs   pid
#>       <char>      <num>       <num>         <num>              <POSc> <int>
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2026-02-18 13:47:25 a2a5971a-9a05-429a-83a6-ae901c07c4ea
#>  2: papery_hog 2026-02-18 13:47:25 6b0e98ea-0d98-4736-a2e9-420e45c7e35a
#>  3: papery_hog 2026-02-18 13:47:25 438b7f7c-4013-4b49-b84d-3e5b3cbca2fa
#>  4: papery_hog 2026-02-18 13:47:25 b59c04c6-65a9-4809-b698-1d96e0116ff6
#>  5: papery_hog 2026-02-18 13:47:25 15667cd6-c13c-421e-84b1-a7866b118091
#>  6: papery_hog 2026-02-18 13:47:25 a7c477f9-9fea-4c96-b2f9-542661085443
#>  7: papery_hog 2026-02-18 13:47:25 438315f6-ed1b-4412-b7ee-44b5ca4dac22
#>  8: papery_hog 2026-02-18 13:47:25 e8de7549-6d8b-40ea-bacd-f2fa8d1f9348
#>  9: papery_hog 2026-02-18 13:47:25 2341db38-50bf-4c24-a39e-cddf72bf07b8
#> 10: papery_hog 2026-02-18 13:47:25 ab530a83-328b-4262-a616-8963ac315f2a
#> 11: papery_hog 2026-02-18 13:47:25 e0073f9a-8407-40aa-982d-c301b0c84b4b
#> 12: papery_hog 2026-02-18 13:47:25 eaaca0c0-88ff-4333-b9f9-ebdd2f414a28
#> 13: papery_hog 2026-02-18 13:47:25 59cc8157-c348-4039-9eda-629b158ae3b6
#> 14: papery_hog 2026-02-18 13:47:25 7029209a-d297-41e8-bd34-37cfeb344251
#> 15: papery_hog 2026-02-18 13:47:26 513c8f6c-7069-49ac-bf33-5a3a89654ddb
#> 16: papery_hog 2026-02-18 13:47:26 c0e80580-42c2-4f62-b118-42e0d3caf705
#> 17: papery_hog 2026-02-18 13:47:26 a138dc4c-ad31-47e0-83d4-758db70affc8
#> 18: papery_hog 2026-02-18 13:47:26 b3261483-0c82-47f9-98b9-d68460422bd5
#> 19: papery_hog 2026-02-18 13:47:26 568ae25c-7a7c-4149-8258-921d1802c43c
#> 20: papery_hog 2026-02-18 13:47:26 da8f2830-c0b9-43e7-9c49-d5a59dd635b8
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
