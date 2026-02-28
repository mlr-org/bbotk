# Asynchronous Optimization via Random Search

`OptimizerAsyncRandomSearch` class that implements a simple Random
Search.

## Source

Bergstra J, Bengio Y (2012). “Random Search for Hyper-Parameter
Optimization.” *Journal of Machine Learning Research*, **13**(10),
281–305. <https://jmlr.csail.mit.edu/papers/v13/bergstra12a.html>.

## Dictionary

This [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md) can
be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/reference/opt.md):

    mlr_optimizers$get("async_random_search")
    opt("async_random_search")

## Super classes

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md)
-\>
[`bbotk::OptimizerAsync`](https://bbotk.mlr-org.com/reference/OptimizerAsync.md)
-\> `OptimizerAsyncRandomSearch`

## Methods

### Public methods

- [`OptimizerAsyncRandomSearch$new()`](#method-OptimizerAsyncRandomSearch-new)

- [`OptimizerAsyncRandomSearch$clone()`](#method-OptimizerAsyncRandomSearch-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-print)
- [`bbotk::OptimizerAsync$optimize()`](https://bbotk.mlr-org.com/reference/OptimizerAsync.html#method-optimize)

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
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2026-02-28 07:01:05  9330
#>  2: finished  2.6451261 -0.47433125    3.20480965 2026-02-28 07:01:05  9330
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2026-02-28 07:01:05  9330
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2026-02-28 07:01:05  9330
#>  5: finished -4.2982254  4.20337792  -81.55629675 2026-02-28 07:01:05  9330
#>  6: finished -5.3318011  3.07859096  -80.70457510 2026-02-28 07:01:05  9330
#>  7: finished -1.2947935  4.44486001  -56.28160502 2026-02-28 07:01:05  9330
#>  8: finished  4.4867714 -4.92985296    0.09163568 2026-02-28 07:01:06  9330
#>  9: finished -4.1477403  2.28072295  -55.68074611 2026-02-28 07:01:06  9330
#> 10: finished -5.6137151  4.91263287 -110.57841706 2026-02-28 07:01:06  9330
#> 11: finished  0.5407374 -0.53103894    1.77478382 2026-02-28 07:01:06  9330
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2026-02-28 07:01:06  9330
#> 13: finished -8.4307422  4.47890861 -154.73445725 2026-02-28 07:01:06  9330
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2026-02-28 07:01:06  9330
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2026-02-28 07:01:06  9330
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2026-02-28 07:01:06  9330
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2026-02-28 07:01:06  9330
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2026-02-28 07:01:06  9330
#> 19: finished -2.3908942  0.02101378  -18.40647620 2026-02-28 07:01:06  9330
#> 20: finished  0.8103813  4.51596998  -47.90499748 2026-02-28 07:01:06  9330
#>        state         x1          x2             y        timestamp_xs   pid
#>       <char>      <num>       <num>         <num>              <POSc> <int>
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2026-02-28 07:01:05 c0d46b56-7145-430a-97a1-2cbb76634714
#>  2: papery_hog 2026-02-28 07:01:05 04d8a5c8-c35c-412f-b458-677927d86e73
#>  3: papery_hog 2026-02-28 07:01:05 15ba0739-57f9-4ac5-896a-1ad1597d26c5
#>  4: papery_hog 2026-02-28 07:01:05 41386157-133f-4534-816b-ef81b880b207
#>  5: papery_hog 2026-02-28 07:01:05 7b426c47-6806-4a84-b42a-06e40ad507aa
#>  6: papery_hog 2026-02-28 07:01:05 8b08f035-426a-4cac-aa67-96a1fc6991d8
#>  7: papery_hog 2026-02-28 07:01:05 dea81d43-ea23-4dc9-8b10-5a876ae2dc29
#>  8: papery_hog 2026-02-28 07:01:06 05c091a6-4dc7-4d11-95ab-fc5811e4cb82
#>  9: papery_hog 2026-02-28 07:01:06 eb2666ee-de19-4c35-876d-f5cce1968fdb
#> 10: papery_hog 2026-02-28 07:01:06 74fbee25-2278-41d0-a733-6db6924ae1c1
#> 11: papery_hog 2026-02-28 07:01:06 2d72a96b-534d-49ee-b088-46e5ba63e6ce
#> 12: papery_hog 2026-02-28 07:01:06 eef54e57-7e3c-4b04-bb31-3eee65cef56a
#> 13: papery_hog 2026-02-28 07:01:06 86871368-0688-42e8-8276-973e2ceaba66
#> 14: papery_hog 2026-02-28 07:01:06 b3cd0f1a-1e80-4ef4-b28f-9b7668684808
#> 15: papery_hog 2026-02-28 07:01:06 813e75ec-030c-45c4-afeb-96c305e19030
#> 16: papery_hog 2026-02-28 07:01:06 75a77399-4a24-40cf-8c1f-13178a7ac09e
#> 17: papery_hog 2026-02-28 07:01:06 1c7c23d8-c83a-4c5c-8b84-fbb7c644cf6d
#> 18: papery_hog 2026-02-28 07:01:06 70827dd3-6f17-4625-8b54-3e39778cc4ef
#> 19: papery_hog 2026-02-28 07:01:06 010ce539-3a18-4f79-b3a2-107054e4a748
#> 20: papery_hog 2026-02-28 07:01:06 ba6f9abe-59fc-4146-8f35-deeaeebfc7dc
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
