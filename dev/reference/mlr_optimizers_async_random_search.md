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
#>  1: finished  7.0005899  0.64849173  -28.317391 2026-04-07 07:08:05
#>  2: finished -4.7273068  1.55118543  -55.969945 2026-04-07 07:08:06
#>  3: finished -8.3142357 -0.84808989 -101.014174 2026-04-07 07:08:06
#>  4: finished  7.4495551  2.57767647  -50.808126 2026-04-07 07:08:06
#>  5: finished  7.5065666  1.81294693  -43.486734 2026-04-07 07:08:06
#>  6: finished -9.8478251 -2.69770124 -130.462345 2026-04-07 07:08:06
#>  7: finished  0.3870992  2.09953629  -18.606719 2026-04-07 07:08:06
#>  8: finished  9.1887166  1.95032306  -66.183344 2026-04-07 07:08:06
#>  9: finished -6.7320590 -4.50562770  -68.515769 2026-04-07 07:08:06
#> 10: finished  0.9955564 -3.63495767    8.587922 2026-04-07 07:08:06
#> 11: finished  1.9339031  3.60780233  -33.667420 2026-04-07 07:08:06
#> 12: finished -3.6334861 -0.37274046  -28.638658 2026-04-07 07:08:06
#> 13: finished -1.3406191 -2.02690225   -2.106655 2026-04-07 07:08:06
#> 14: finished -5.8805572 -2.81415540  -52.137720 2026-04-07 07:08:06
#> 15: finished  6.5360563  4.77872294  -71.084338 2026-04-07 07:08:06
#> 16: finished -4.5197170 -2.02682984  -33.453771 2026-04-07 07:08:06
#> 17: finished  5.3688411  1.11764111  -18.304059 2026-04-07 07:08:06
#> 18: finished  2.5665792 -1.21875214    6.506144 2026-04-07 07:08:06
#> 19: finished -5.3691761 -0.01495275  -53.215263 2026-04-07 07:08:06
#> 20: finished -6.3526726  1.61537696  -81.068844 2026-04-07 07:08:06
#>        state         x1          x2           y        timestamp_xs
#>       <char>      <num>       <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-04-07 07:08:05
#>  2: narrow_xinjiangovenator 2026-04-07 07:08:06
#>  3: narrow_xinjiangovenator 2026-04-07 07:08:06
#>  4: narrow_xinjiangovenator 2026-04-07 07:08:06
#>  5: narrow_xinjiangovenator 2026-04-07 07:08:06
#>  6: narrow_xinjiangovenator 2026-04-07 07:08:06
#>  7: narrow_xinjiangovenator 2026-04-07 07:08:06
#>  8: narrow_xinjiangovenator 2026-04-07 07:08:06
#>  9: narrow_xinjiangovenator 2026-04-07 07:08:06
#> 10: narrow_xinjiangovenator 2026-04-07 07:08:06
#> 11: narrow_xinjiangovenator 2026-04-07 07:08:06
#> 12: narrow_xinjiangovenator 2026-04-07 07:08:06
#> 13: narrow_xinjiangovenator 2026-04-07 07:08:06
#> 14: narrow_xinjiangovenator 2026-04-07 07:08:06
#> 15: narrow_xinjiangovenator 2026-04-07 07:08:06
#> 16: narrow_xinjiangovenator 2026-04-07 07:08:06
#> 17: narrow_xinjiangovenator 2026-04-07 07:08:06
#> 18: narrow_xinjiangovenator 2026-04-07 07:08:06
#> 19: narrow_xinjiangovenator 2026-04-07 07:08:06
#> 20: narrow_xinjiangovenator 2026-04-07 07:08:06
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 41d25a4d-1513-4dea-b500-de30cc0e203d   7.0005899  0.64849173
#>  2: c5578dd1-88a7-41ba-a034-d1dde43934e9  -4.7273068  1.55118543
#>  3: b6316167-23b3-45e1-9100-ee092a974a73  -8.3142357 -0.84808989
#>  4: 28e45735-d6f2-404f-ad21-4db77fa3406d   7.4495551  2.57767647
#>  5: 6e9b8f2a-dfc1-488a-a846-107f93c8004e   7.5065666  1.81294693
#>  6: 5a10bc20-9de5-467d-a6d0-8cb6058d3bd3  -9.8478251 -2.69770124
#>  7: a94df43f-e471-42c0-82bd-ba73669e886b   0.3870992  2.09953629
#>  8: 8b7a38bf-96bc-4988-a4cf-5aa58961d860   9.1887166  1.95032306
#>  9: d0a46784-1d62-46b4-92a0-4070d74f8f2c  -6.7320590 -4.50562770
#> 10: 44b0ad0e-c5f8-4c69-a8a7-d3eae0718b4a   0.9955564 -3.63495767
#> 11: 6c3ff701-3956-4211-bea8-c0b75cb7242e   1.9339031  3.60780233
#> 12: 4a02ee65-212b-4c15-86ad-5b9809d54079  -3.6334861 -0.37274046
#> 13: 2f12d070-0894-4cdb-8a3e-aff56b17c462  -1.3406191 -2.02690225
#> 14: fc261930-dcc9-4549-961b-c5e30c72bdd2  -5.8805572 -2.81415540
#> 15: a5db8926-a65b-47be-ac81-92d1a9605d69   6.5360563  4.77872294
#> 16: ba2d688e-f103-4e6c-9d39-b4b19d1f1f09  -4.5197170 -2.02682984
#> 17: ed2ae38f-5c5e-4fc6-98cd-2c439ecd0da3   5.3688411  1.11764111
#> 18: ea6b47fb-b3c6-4923-b689-7cd0f9d53095   2.5665792 -1.21875214
#> 19: d5156dbe-b9dc-4ea1-a536-d2a1dde759df  -5.3691761 -0.01495275
#> 20: cb986058-8aea-403e-a112-1971dabc6068  -6.3526726  1.61537696
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
