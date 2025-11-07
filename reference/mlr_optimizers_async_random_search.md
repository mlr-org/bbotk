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
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2025-11-07 11:47:46  9957
#>  2: finished  2.6451261 -0.47433125    3.20480965 2025-11-07 11:47:46  9957
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2025-11-07 11:47:46  9957
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2025-11-07 11:47:46  9957
#>  5: finished -4.2982254  4.20337792  -81.55629675 2025-11-07 11:47:46  9957
#>  6: finished -5.3318011  3.07859096  -80.70457510 2025-11-07 11:47:46  9957
#>  7: finished -1.2947935  4.44486001  -56.28160502 2025-11-07 11:47:46  9957
#>  8: finished  4.4867714 -4.92985296    0.09163568 2025-11-07 11:47:47  9957
#>  9: finished -4.1477403  2.28072295  -55.68074611 2025-11-07 11:47:47  9957
#> 10: finished -5.6137151  4.91263287 -110.57841706 2025-11-07 11:47:47  9957
#> 11: finished  0.5407374 -0.53103894    1.77478382 2025-11-07 11:47:47  9957
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2025-11-07 11:47:47  9957
#> 13: finished -8.4307422  4.47890861 -154.73445725 2025-11-07 11:47:47  9957
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2025-11-07 11:47:47  9957
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2025-11-07 11:47:47  9957
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2025-11-07 11:47:47  9957
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2025-11-07 11:47:47  9957
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2025-11-07 11:47:47  9957
#> 19: finished -2.3908942  0.02101378  -18.40647620 2025-11-07 11:47:47  9957
#> 20: finished  0.8103813  4.51596998  -47.90499748 2025-11-07 11:47:47  9957
#>        state         x1          x2             y        timestamp_xs   pid
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2025-11-07 11:47:46 d1201e47-a8be-42dc-b7f7-deb3f8586dcf
#>  2: papery_hog 2025-11-07 11:47:46 dbd50a28-7e49-4920-8c2b-dba7fce0e7c7
#>  3: papery_hog 2025-11-07 11:47:46 610ca5f3-4c3b-49cc-b572-0a6f85f014ab
#>  4: papery_hog 2025-11-07 11:47:46 315914d1-d554-406d-af0c-3e6e89268870
#>  5: papery_hog 2025-11-07 11:47:46 9ba7c9e6-0d0e-4722-bffd-5cac50d90cda
#>  6: papery_hog 2025-11-07 11:47:46 8e7423aa-aa08-4cbd-938e-f32f6a0ad2d9
#>  7: papery_hog 2025-11-07 11:47:46 57661990-9990-4559-9d21-460b861dcbec
#>  8: papery_hog 2025-11-07 11:47:47 539c8b84-5c8e-49f7-b535-e1245ca99212
#>  9: papery_hog 2025-11-07 11:47:47 6259db11-2bc5-43bf-bdb1-dbfd0b67376b
#> 10: papery_hog 2025-11-07 11:47:47 4fad3e37-69d2-43b1-971b-29177517005d
#> 11: papery_hog 2025-11-07 11:47:47 77297607-b5f2-4c0f-b413-ebd276b4fef2
#> 12: papery_hog 2025-11-07 11:47:47 42584758-fe66-4ac7-831e-c193026b62b0
#> 13: papery_hog 2025-11-07 11:47:47 fc6c9a56-c5a7-49d2-842f-2f5efc80327f
#> 14: papery_hog 2025-11-07 11:47:47 072d2c89-ba40-4578-8c89-b4f77e407bde
#> 15: papery_hog 2025-11-07 11:47:47 cefbeb52-cacf-4312-839e-481db9eaa023
#> 16: papery_hog 2025-11-07 11:47:47 29fb10a1-0b99-4251-bdfa-09221bb2f944
#> 17: papery_hog 2025-11-07 11:47:47 a12d6aab-e85b-4df1-b834-6bee74417e5d
#> 18: papery_hog 2025-11-07 11:47:47 62434a89-945d-4c36-85ee-dd1cd394449e
#> 19: papery_hog 2025-11-07 11:47:47 76833cd4-5964-48fa-88e2-d9b74e92568f
#> 20: papery_hog 2025-11-07 11:47:47 47e877da-c707-437d-9c11-fdcb9eb4de7b
#>      worker_id        timestamp_ys                                 keys
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
```
