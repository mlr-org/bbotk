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
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2025-12-13 11:48:19  8491
#>  2: finished  2.6451261 -0.47433125    3.20480965 2025-12-13 11:48:19  8491
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2025-12-13 11:48:19  8491
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2025-12-13 11:48:19  8491
#>  5: finished -4.2982254  4.20337792  -81.55629675 2025-12-13 11:48:19  8491
#>  6: finished -5.3318011  3.07859096  -80.70457510 2025-12-13 11:48:19  8491
#>  7: finished -1.2947935  4.44486001  -56.28160502 2025-12-13 11:48:19  8491
#>  8: finished  4.4867714 -4.92985296    0.09163568 2025-12-13 11:48:19  8491
#>  9: finished -4.1477403  2.28072295  -55.68074611 2025-12-13 11:48:19  8491
#> 10: finished -5.6137151  4.91263287 -110.57841706 2025-12-13 11:48:19  8491
#> 11: finished  0.5407374 -0.53103894    1.77478382 2025-12-13 11:48:19  8491
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2025-12-13 11:48:19  8491
#> 13: finished -8.4307422  4.47890861 -154.73445725 2025-12-13 11:48:19  8491
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2025-12-13 11:48:19  8491
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2025-12-13 11:48:19  8491
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2025-12-13 11:48:19  8491
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2025-12-13 11:48:19  8491
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2025-12-13 11:48:19  8491
#> 19: finished -2.3908942  0.02101378  -18.40647620 2025-12-13 11:48:19  8491
#> 20: finished  0.8103813  4.51596998  -47.90499748 2025-12-13 11:48:20  8491
#>        state         x1          x2             y        timestamp_xs   pid
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2025-12-13 11:48:19 70bfa526-a88a-495d-8b57-8300dd913b6a
#>  2: papery_hog 2025-12-13 11:48:19 5e8188ec-faa1-41b4-a607-956dbec91bc2
#>  3: papery_hog 2025-12-13 11:48:19 8abd97ae-42a2-4b4f-8d7f-f0e0bf255eec
#>  4: papery_hog 2025-12-13 11:48:19 ce9492c6-fda0-4597-9a6b-5189fe0dfea4
#>  5: papery_hog 2025-12-13 11:48:19 20e043a9-afbb-47b2-82a8-ec0bf3ed7f3b
#>  6: papery_hog 2025-12-13 11:48:19 e3e3e942-6f98-4b73-ac61-75bed5120e78
#>  7: papery_hog 2025-12-13 11:48:19 08fa46d7-3dd8-4139-a476-7a76e7044090
#>  8: papery_hog 2025-12-13 11:48:19 9bb62070-66fb-41db-842a-fe1d926d53a6
#>  9: papery_hog 2025-12-13 11:48:19 ffaeec74-8fc7-4cf9-a215-d032b61227b8
#> 10: papery_hog 2025-12-13 11:48:19 f56f0551-10db-411b-bffd-7d56c52a40d2
#> 11: papery_hog 2025-12-13 11:48:19 a2cb79ad-333a-4efe-8554-0de8230c1306
#> 12: papery_hog 2025-12-13 11:48:19 300d2814-215a-4556-b19e-0dd83bed2077
#> 13: papery_hog 2025-12-13 11:48:19 5fe8b0db-5f3e-4be8-9361-9791d7c821d7
#> 14: papery_hog 2025-12-13 11:48:19 aa33a009-0764-4cfb-88c8-1257d5d8ac12
#> 15: papery_hog 2025-12-13 11:48:19 d0ee8a86-1a62-4686-a950-2ed9b6223c7c
#> 16: papery_hog 2025-12-13 11:48:19 eded5c84-6962-4927-9509-20724d08f1a5
#> 17: papery_hog 2025-12-13 11:48:19 83f5cae4-cd4b-4f92-ac2f-9aea0d710070
#> 18: papery_hog 2025-12-13 11:48:19 54db52c0-5cfa-41b0-91f8-03f616e18e93
#> 19: papery_hog 2025-12-13 11:48:19 0ca962ef-e539-4d6b-9f7d-98f8e6982c43
#> 20: papery_hog 2025-12-13 11:48:20 d065784c-edf1-43d8-953f-b39efd29524c
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
