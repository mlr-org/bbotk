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
rush::rush_plan(worker_type = "mirai")
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
#>        state         x1          x2           y        timestamp_xs
#>       <char>      <num>       <num>       <num>              <POSc>
#>  1: finished  7.0005899  0.64849173  -28.317391 2026-03-18 15:32:17
#>  2: finished -4.7273068  1.55118543  -55.969945 2026-03-18 15:32:17
#>  3: finished -8.3142357 -0.84808989 -101.014174 2026-03-18 15:32:17
#>  4: finished  7.4495551  2.57767647  -50.808126 2026-03-18 15:32:17
#>  5: finished  7.5065666  1.81294693  -43.486734 2026-03-18 15:32:17
#>  6: finished -9.8478251 -2.69770124 -130.462345 2026-03-18 15:32:17
#>  7: finished  0.3870992  2.09953629  -18.606719 2026-03-18 15:32:17
#>  8: finished  9.1887166  1.95032306  -66.183344 2026-03-18 15:32:17
#>  9: finished -6.7320590 -4.50562770  -68.515769 2026-03-18 15:32:17
#> 10: finished  0.9955564 -3.63495767    8.587922 2026-03-18 15:32:17
#> 11: finished  1.9339031  3.60780233  -33.667420 2026-03-18 15:32:17
#> 12: finished -3.6334861 -0.37274046  -28.638658 2026-03-18 15:32:17
#> 13: finished -1.3406191 -2.02690225   -2.106655 2026-03-18 15:32:17
#> 14: finished -5.8805572 -2.81415540  -52.137720 2026-03-18 15:32:17
#> 15: finished  6.5360563  4.77872294  -71.084338 2026-03-18 15:32:17
#> 16: finished -4.5197170 -2.02682984  -33.453771 2026-03-18 15:32:17
#> 17: finished  5.3688411  1.11764111  -18.304059 2026-03-18 15:32:17
#> 18: finished  2.5665792 -1.21875214    6.506144 2026-03-18 15:32:17
#> 19: finished -5.3691761 -0.01495275  -53.215263 2026-03-18 15:32:17
#> 20: finished -6.3526726  1.61537696  -81.068844 2026-03-18 15:32:17
#>        state         x1          x2           y        timestamp_xs
#>       <char>      <num>       <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-03-18 15:32:17
#>  2: narrow_xinjiangovenator 2026-03-18 15:32:17
#>  3: narrow_xinjiangovenator 2026-03-18 15:32:17
#>  4: narrow_xinjiangovenator 2026-03-18 15:32:17
#>  5: narrow_xinjiangovenator 2026-03-18 15:32:17
#>  6: narrow_xinjiangovenator 2026-03-18 15:32:17
#>  7: narrow_xinjiangovenator 2026-03-18 15:32:17
#>  8: narrow_xinjiangovenator 2026-03-18 15:32:17
#>  9: narrow_xinjiangovenator 2026-03-18 15:32:17
#> 10: narrow_xinjiangovenator 2026-03-18 15:32:17
#> 11: narrow_xinjiangovenator 2026-03-18 15:32:17
#> 12: narrow_xinjiangovenator 2026-03-18 15:32:17
#> 13: narrow_xinjiangovenator 2026-03-18 15:32:17
#> 14: narrow_xinjiangovenator 2026-03-18 15:32:17
#> 15: narrow_xinjiangovenator 2026-03-18 15:32:17
#> 16: narrow_xinjiangovenator 2026-03-18 15:32:17
#> 17: narrow_xinjiangovenator 2026-03-18 15:32:17
#> 18: narrow_xinjiangovenator 2026-03-18 15:32:17
#> 19: narrow_xinjiangovenator 2026-03-18 15:32:17
#> 20: narrow_xinjiangovenator 2026-03-18 15:32:18
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: d93775c8-ae65-4e3c-b841-18c5b618560f   7.0005899  0.64849173
#>  2: 1c7dca28-cd42-44d1-bc21-912567ec524a  -4.7273068  1.55118543
#>  3: 82f37bf3-af29-4070-8d9c-e17e7aa654c3  -8.3142357 -0.84808989
#>  4: b3a3c996-e24f-4394-90ea-10ffb4d262c5   7.4495551  2.57767647
#>  5: 6787b64c-6ed2-4819-b211-232eaa422709   7.5065666  1.81294693
#>  6: 8ada6a77-3f61-4e91-a818-4c701537eb40  -9.8478251 -2.69770124
#>  7: 22075997-5df9-4553-8c1a-c4436a34cbe3   0.3870992  2.09953629
#>  8: b5169876-043e-4b62-b9aa-655098c435d3   9.1887166  1.95032306
#>  9: c0300691-f763-4464-bdb3-22f451876fc8  -6.7320590 -4.50562770
#> 10: 7b6386ea-5241-4d14-a5b5-e04f7128231a   0.9955564 -3.63495767
#> 11: ea442108-4f10-41d0-a0e5-e0022dcdf762   1.9339031  3.60780233
#> 12: bdfa582d-ed3e-4c36-9974-5b80ed765222  -3.6334861 -0.37274046
#> 13: 96d4ed91-baa7-4726-82b9-b5021761f403  -1.3406191 -2.02690225
#> 14: 587595a7-8ef8-4def-95f8-35f84788573a  -5.8805572 -2.81415540
#> 15: f95eeb7a-1661-4c27-b9bb-599034345b89   6.5360563  4.77872294
#> 16: 1af4f21c-a959-48f5-ad0e-de988080ca99  -4.5197170 -2.02682984
#> 17: 86abcb0f-a1db-48e4-b6b9-ee5ff75d71ef   5.3688411  1.11764111
#> 18: 0f70fc58-1304-4178-a0a6-c1127beada24   2.5665792 -1.21875214
#> 19: 80c32a72-cddd-40be-9109-44d628fc9074  -5.3691761 -0.01495275
#> 20: bb0a6b94-0ae2-437b-b8f9-4c664e2703df  -6.3526726  1.61537696
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
