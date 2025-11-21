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
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2025-11-21 18:13:59 28789
#>  2: finished  2.6451261 -0.47433125    3.20480965 2025-11-21 18:13:59 28789
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2025-11-21 18:13:59 28789
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2025-11-21 18:13:59 28789
#>  5: finished -4.2982254  4.20337792  -81.55629675 2025-11-21 18:13:59 28789
#>  6: finished -5.3318011  3.07859096  -80.70457510 2025-11-21 18:13:59 28789
#>  7: finished -1.2947935  4.44486001  -56.28160502 2025-11-21 18:13:59 28789
#>  8: finished  4.4867714 -4.92985296    0.09163568 2025-11-21 18:13:59 28789
#>  9: finished -4.1477403  2.28072295  -55.68074611 2025-11-21 18:14:00 28789
#> 10: finished -5.6137151  4.91263287 -110.57841706 2025-11-21 18:14:00 28789
#> 11: finished  0.5407374 -0.53103894    1.77478382 2025-11-21 18:14:00 28789
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2025-11-21 18:14:00 28789
#> 13: finished -8.4307422  4.47890861 -154.73445725 2025-11-21 18:14:00 28789
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2025-11-21 18:14:00 28789
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2025-11-21 18:14:00 28789
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2025-11-21 18:14:00 28789
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2025-11-21 18:14:00 28789
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2025-11-21 18:14:00 28789
#> 19: finished -2.3908942  0.02101378  -18.40647620 2025-11-21 18:14:00 28789
#> 20: finished  0.8103813  4.51596998  -47.90499748 2025-11-21 18:14:00 28789
#>        state         x1          x2             y        timestamp_xs   pid
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2025-11-21 18:13:59 0acb1052-3fb8-4c95-9206-a2bea8756108
#>  2: papery_hog 2025-11-21 18:13:59 9f02e14b-218c-4e93-8d76-3f9e5ec50ebc
#>  3: papery_hog 2025-11-21 18:13:59 a72a345e-ba9e-420b-9758-987909e01ef4
#>  4: papery_hog 2025-11-21 18:13:59 cac1cf4b-ab1f-47ce-82f2-a666f23639c2
#>  5: papery_hog 2025-11-21 18:13:59 ca3c9217-b3c3-4090-a183-2f4b77231f17
#>  6: papery_hog 2025-11-21 18:13:59 b09a03b3-939a-463d-9762-f8030bfc175a
#>  7: papery_hog 2025-11-21 18:13:59 4b041cba-5795-41db-92ab-98f162a8239c
#>  8: papery_hog 2025-11-21 18:13:59 58d0d56a-055d-44a8-ab83-7bbb7c4c55ab
#>  9: papery_hog 2025-11-21 18:14:00 03271cf6-fe7f-4888-96bc-8448c53dc105
#> 10: papery_hog 2025-11-21 18:14:00 5b29bea5-d321-4ef7-9109-d24da05a2a09
#> 11: papery_hog 2025-11-21 18:14:00 ff2a0fbe-dd8e-49dd-b2c1-6beae70bba0e
#> 12: papery_hog 2025-11-21 18:14:00 c784f14b-39b7-4f98-a462-f454fcd36ebd
#> 13: papery_hog 2025-11-21 18:14:00 eb5b25c5-81da-438b-8691-09bf54ca0296
#> 14: papery_hog 2025-11-21 18:14:00 0753372f-f730-49ba-9d31-62c4b37c8846
#> 15: papery_hog 2025-11-21 18:14:00 b62390f2-9b4f-457e-a060-2f4f9553aa19
#> 16: papery_hog 2025-11-21 18:14:00 ef9c68d6-6da5-4027-893e-4d483a107463
#> 17: papery_hog 2025-11-21 18:14:00 0687a887-3a58-46e5-bfdd-d1c41dd74919
#> 18: papery_hog 2025-11-21 18:14:00 694f6223-890f-43b1-a2b8-ac45efaa6cc3
#> 19: papery_hog 2025-11-21 18:14:00 26e81b5b-0baf-4ab9-975c-70f70de353f1
#> 20: papery_hog 2025-11-21 18:14:00 b9e134ed-c076-4f1f-8d3a-cd6dc8150759
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
