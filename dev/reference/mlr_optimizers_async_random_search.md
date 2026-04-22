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
#>  1: finished  7.0005899  0.64849173  -28.317391 2026-04-22 10:04:36
#>  2: finished -4.7273068  1.55118543  -55.969945 2026-04-22 10:04:36
#>  3: finished -8.3142357 -0.84808989 -101.014174 2026-04-22 10:04:36
#>  4: finished  7.4495551  2.57767647  -50.808126 2026-04-22 10:04:36
#>  5: finished  7.5065666  1.81294693  -43.486734 2026-04-22 10:04:36
#>  6: finished -9.8478251 -2.69770124 -130.462345 2026-04-22 10:04:36
#>  7: finished  0.3870992  2.09953629  -18.606719 2026-04-22 10:04:36
#>  8: finished  9.1887166  1.95032306  -66.183344 2026-04-22 10:04:36
#>  9: finished -6.7320590 -4.50562770  -68.515769 2026-04-22 10:04:36
#> 10: finished  0.9955564 -3.63495767    8.587922 2026-04-22 10:04:36
#> 11: finished  1.9339031  3.60780233  -33.667420 2026-04-22 10:04:36
#> 12: finished -3.6334861 -0.37274046  -28.638658 2026-04-22 10:04:36
#> 13: finished -1.3406191 -2.02690225   -2.106655 2026-04-22 10:04:36
#> 14: finished -5.8805572 -2.81415540  -52.137720 2026-04-22 10:04:36
#> 15: finished  6.5360563  4.77872294  -71.084338 2026-04-22 10:04:36
#> 16: finished -4.5197170 -2.02682984  -33.453771 2026-04-22 10:04:36
#> 17: finished  5.3688411  1.11764111  -18.304059 2026-04-22 10:04:36
#> 18: finished  2.5665792 -1.21875214    6.506144 2026-04-22 10:04:36
#> 19: finished -5.3691761 -0.01495275  -53.215263 2026-04-22 10:04:36
#> 20: finished -6.3526726  1.61537696  -81.068844 2026-04-22 10:04:36
#>        state         x1          x2           y        timestamp_xs
#>       <char>      <num>       <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-04-22 10:04:36
#>  2: narrow_xinjiangovenator 2026-04-22 10:04:36
#>  3: narrow_xinjiangovenator 2026-04-22 10:04:36
#>  4: narrow_xinjiangovenator 2026-04-22 10:04:36
#>  5: narrow_xinjiangovenator 2026-04-22 10:04:36
#>  6: narrow_xinjiangovenator 2026-04-22 10:04:36
#>  7: narrow_xinjiangovenator 2026-04-22 10:04:36
#>  8: narrow_xinjiangovenator 2026-04-22 10:04:36
#>  9: narrow_xinjiangovenator 2026-04-22 10:04:36
#> 10: narrow_xinjiangovenator 2026-04-22 10:04:36
#> 11: narrow_xinjiangovenator 2026-04-22 10:04:36
#> 12: narrow_xinjiangovenator 2026-04-22 10:04:36
#> 13: narrow_xinjiangovenator 2026-04-22 10:04:36
#> 14: narrow_xinjiangovenator 2026-04-22 10:04:36
#> 15: narrow_xinjiangovenator 2026-04-22 10:04:36
#> 16: narrow_xinjiangovenator 2026-04-22 10:04:36
#> 17: narrow_xinjiangovenator 2026-04-22 10:04:36
#> 18: narrow_xinjiangovenator 2026-04-22 10:04:36
#> 19: narrow_xinjiangovenator 2026-04-22 10:04:36
#> 20: narrow_xinjiangovenator 2026-04-22 10:04:36
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: e54ca42d-557c-43e6-910b-24af880f72af   7.0005899  0.64849173
#>  2: 2d80ad50-bde7-4d54-b8dd-ff420948a87f  -4.7273068  1.55118543
#>  3: f81e6a54-15d0-4fdf-b490-1b44e5f0e1a8  -8.3142357 -0.84808989
#>  4: f2a67787-32df-41a5-9916-20a393e6bb6e   7.4495551  2.57767647
#>  5: 831f9840-383c-46b9-b7c4-959ada83c8ec   7.5065666  1.81294693
#>  6: c89d3466-08f1-4cbe-9a2b-2cffb2abc150  -9.8478251 -2.69770124
#>  7: 158ecc4b-cb82-4bc9-9008-c9b21a9eb5c4   0.3870992  2.09953629
#>  8: 902797e1-d24b-4a3a-9539-ca42cf8971b4   9.1887166  1.95032306
#>  9: f13264bf-9880-4e1c-9025-25274287ac59  -6.7320590 -4.50562770
#> 10: aa08a15c-f6b2-4be0-a7b2-649fcb56cb97   0.9955564 -3.63495767
#> 11: 70d8fa42-2a04-4b9f-a33e-81f81af83e29   1.9339031  3.60780233
#> 12: dc24b0a3-5640-4f81-9b86-5cc9e625022d  -3.6334861 -0.37274046
#> 13: 7d9ccad6-acd5-4697-aa4b-dbc3f4eca130  -1.3406191 -2.02690225
#> 14: a665f36e-47d4-487b-8f8f-df74fd5c5d20  -5.8805572 -2.81415540
#> 15: c5fff5cd-4e71-40b7-96eb-b0f4932bc22b   6.5360563  4.77872294
#> 16: e22cb770-2260-4b25-9b06-7e3e1e645d26  -4.5197170 -2.02682984
#> 17: 61eab7d1-d620-4dab-addd-ad2b1f04f07d   5.3688411  1.11764111
#> 18: 8badcc56-42b6-4f82-9f1d-0b6834b5cccc   2.5665792 -1.21875214
#> 19: b1dda4e2-1fbf-4a90-a5a2-64b358e44d59  -5.3691761 -0.01495275
#> 20: 86d50818-a003-4d7f-b571-85e4838ab597  -6.3526726  1.61537696
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
