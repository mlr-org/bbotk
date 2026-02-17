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
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2026-02-17 15:05:18 14778
#>  2: finished  2.6451261 -0.47433125    3.20480965 2026-02-17 15:05:18 14778
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2026-02-17 15:05:18 14778
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2026-02-17 15:05:18 14778
#>  5: finished -4.2982254  4.20337792  -81.55629675 2026-02-17 15:05:18 14778
#>  6: finished -5.3318011  3.07859096  -80.70457510 2026-02-17 15:05:18 14778
#>  7: finished -1.2947935  4.44486001  -56.28160502 2026-02-17 15:05:18 14778
#>  8: finished  4.4867714 -4.92985296    0.09163568 2026-02-17 15:05:18 14778
#>  9: finished -4.1477403  2.28072295  -55.68074611 2026-02-17 15:05:18 14778
#> 10: finished -5.6137151  4.91263287 -110.57841706 2026-02-17 15:05:18 14778
#> 11: finished  0.5407374 -0.53103894    1.77478382 2026-02-17 15:05:18 14778
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2026-02-17 15:05:18 14778
#> 13: finished -8.4307422  4.47890861 -154.73445725 2026-02-17 15:05:18 14778
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2026-02-17 15:05:18 14778
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2026-02-17 15:05:18 14778
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2026-02-17 15:05:18 14778
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2026-02-17 15:05:18 14778
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2026-02-17 15:05:18 14778
#> 19: finished -2.3908942  0.02101378  -18.40647620 2026-02-17 15:05:18 14778
#> 20: finished  0.8103813  4.51596998  -47.90499748 2026-02-17 15:05:18 14778
#>        state         x1          x2             y        timestamp_xs   pid
#>       <char>      <num>       <num>         <num>              <POSc> <int>
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2026-02-17 15:05:18 da9d08a8-b793-4aa9-a11a-7eb638f8413f
#>  2: papery_hog 2026-02-17 15:05:18 05a0aa1a-1c08-4c30-b3ae-8024f7dc56f0
#>  3: papery_hog 2026-02-17 15:05:18 811fa31b-1044-4db5-9363-8e6e28bebde9
#>  4: papery_hog 2026-02-17 15:05:18 f6054580-7521-4c97-b341-93da1d8f7e20
#>  5: papery_hog 2026-02-17 15:05:18 086c752c-5b1e-4694-886d-07881e64e3f0
#>  6: papery_hog 2026-02-17 15:05:18 d9fcb279-5b94-42a5-9197-1f68f310e6f7
#>  7: papery_hog 2026-02-17 15:05:18 bee72778-26a6-46f7-a18f-98d86773d18a
#>  8: papery_hog 2026-02-17 15:05:18 6b910dfb-5011-41d5-be0b-dc2acd7445c4
#>  9: papery_hog 2026-02-17 15:05:18 4a1b634c-2e03-462e-af5e-f005b91b49ea
#> 10: papery_hog 2026-02-17 15:05:18 8b079673-35aa-40e6-a3de-cdc74c5440c4
#> 11: papery_hog 2026-02-17 15:05:18 882d2c99-5556-4556-9dc4-f7b4518e13b6
#> 12: papery_hog 2026-02-17 15:05:18 96f37e7a-a618-45e1-b4f7-9d61cb5ee22f
#> 13: papery_hog 2026-02-17 15:05:18 95583a48-ecb6-4225-9c51-e4f9c0ee88e3
#> 14: papery_hog 2026-02-17 15:05:18 e8af26a0-b3b8-4664-bfaf-86793a5f85c7
#> 15: papery_hog 2026-02-17 15:05:18 4bd8609c-dbf0-4b23-b76f-294368ee4e37
#> 16: papery_hog 2026-02-17 15:05:18 6fd4cf7e-9a2d-4a18-8433-38b7e5f70a87
#> 17: papery_hog 2026-02-17 15:05:18 6093e915-00c3-49fd-91e7-0e4b67e7720d
#> 18: papery_hog 2026-02-17 15:05:18 74e5d219-6bea-4341-8365-84508956cde3
#> 19: papery_hog 2026-02-17 15:05:18 d1d5da96-75c3-4d5d-9fa7-7e5ebc31e80a
#> 20: papery_hog 2026-02-17 15:05:18 aca68e08-a9f3-443c-a6fa-4f3dbbb4d319
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
