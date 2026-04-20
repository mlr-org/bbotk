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
#>  1: finished  7.0005899  0.64849173  -28.317391 2026-04-20 15:43:33
#>  2: finished -4.7273068  1.55118543  -55.969945 2026-04-20 15:43:33
#>  3: finished -8.3142357 -0.84808989 -101.014174 2026-04-20 15:43:33
#>  4: finished  7.4495551  2.57767647  -50.808126 2026-04-20 15:43:33
#>  5: finished  7.5065666  1.81294693  -43.486734 2026-04-20 15:43:33
#>  6: finished -9.8478251 -2.69770124 -130.462345 2026-04-20 15:43:33
#>  7: finished  0.3870992  2.09953629  -18.606719 2026-04-20 15:43:34
#>  8: finished  9.1887166  1.95032306  -66.183344 2026-04-20 15:43:34
#>  9: finished -6.7320590 -4.50562770  -68.515769 2026-04-20 15:43:34
#> 10: finished  0.9955564 -3.63495767    8.587922 2026-04-20 15:43:34
#> 11: finished  1.9339031  3.60780233  -33.667420 2026-04-20 15:43:34
#> 12: finished -3.6334861 -0.37274046  -28.638658 2026-04-20 15:43:34
#> 13: finished -1.3406191 -2.02690225   -2.106655 2026-04-20 15:43:34
#> 14: finished -5.8805572 -2.81415540  -52.137720 2026-04-20 15:43:34
#> 15: finished  6.5360563  4.77872294  -71.084338 2026-04-20 15:43:34
#> 16: finished -4.5197170 -2.02682984  -33.453771 2026-04-20 15:43:34
#> 17: finished  5.3688411  1.11764111  -18.304059 2026-04-20 15:43:34
#> 18: finished  2.5665792 -1.21875214    6.506144 2026-04-20 15:43:34
#> 19: finished -5.3691761 -0.01495275  -53.215263 2026-04-20 15:43:34
#> 20: finished -6.3526726  1.61537696  -81.068844 2026-04-20 15:43:34
#>        state         x1          x2           y        timestamp_xs
#>       <char>      <num>       <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-04-20 15:43:33
#>  2: narrow_xinjiangovenator 2026-04-20 15:43:33
#>  3: narrow_xinjiangovenator 2026-04-20 15:43:33
#>  4: narrow_xinjiangovenator 2026-04-20 15:43:33
#>  5: narrow_xinjiangovenator 2026-04-20 15:43:33
#>  6: narrow_xinjiangovenator 2026-04-20 15:43:33
#>  7: narrow_xinjiangovenator 2026-04-20 15:43:34
#>  8: narrow_xinjiangovenator 2026-04-20 15:43:34
#>  9: narrow_xinjiangovenator 2026-04-20 15:43:34
#> 10: narrow_xinjiangovenator 2026-04-20 15:43:34
#> 11: narrow_xinjiangovenator 2026-04-20 15:43:34
#> 12: narrow_xinjiangovenator 2026-04-20 15:43:34
#> 13: narrow_xinjiangovenator 2026-04-20 15:43:34
#> 14: narrow_xinjiangovenator 2026-04-20 15:43:34
#> 15: narrow_xinjiangovenator 2026-04-20 15:43:34
#> 16: narrow_xinjiangovenator 2026-04-20 15:43:34
#> 17: narrow_xinjiangovenator 2026-04-20 15:43:34
#> 18: narrow_xinjiangovenator 2026-04-20 15:43:34
#> 19: narrow_xinjiangovenator 2026-04-20 15:43:34
#> 20: narrow_xinjiangovenator 2026-04-20 15:43:34
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 48898b82-f542-4935-8279-e003eaa66f3c   7.0005899  0.64849173
#>  2: 0a9a8bc3-9f1b-4611-ac5d-1a961094a955  -4.7273068  1.55118543
#>  3: c52982e5-484a-4926-9aa2-671987ee2a92  -8.3142357 -0.84808989
#>  4: 9e4df58d-568a-4795-80d4-68be1950b4e1   7.4495551  2.57767647
#>  5: cea47ed1-6ed4-4b0d-b190-1e52f1e2638e   7.5065666  1.81294693
#>  6: ac1b2811-a014-41da-a4e2-307876d92eae  -9.8478251 -2.69770124
#>  7: f1b27f62-4250-4ef9-aa4a-6a7e750a629d   0.3870992  2.09953629
#>  8: c28d3d2f-6131-4377-8401-d560ae324a11   9.1887166  1.95032306
#>  9: dbca94a9-764c-42a1-8ad5-353ca5a15967  -6.7320590 -4.50562770
#> 10: f0965612-165e-482f-ba39-8c4b2a0ecf49   0.9955564 -3.63495767
#> 11: 7489c53f-3a9b-4953-8738-3cdc39de642b   1.9339031  3.60780233
#> 12: eb01bab9-fc27-4ed6-9452-6b300c0d48ee  -3.6334861 -0.37274046
#> 13: 8a1746f1-e6ef-40f9-bec9-b313092f2ee7  -1.3406191 -2.02690225
#> 14: 89bebf7b-dca8-47e5-a3d4-49528ff0fff2  -5.8805572 -2.81415540
#> 15: a5980fd2-032b-4319-a5db-ec49428b3f60   6.5360563  4.77872294
#> 16: 93c3c9e1-eff1-4d1d-b784-82b22685335a  -4.5197170 -2.02682984
#> 17: ce4ba62f-b9cc-48bf-bf04-bbd4dece6762   5.3688411  1.11764111
#> 18: c4515e64-9c3a-4ee4-99c9-504aa2905531   2.5665792 -1.21875214
#> 19: f163fdff-b784-433c-942d-7af08ee6d4cb  -5.3691761 -0.01495275
#> 20: 2936f982-a828-42c1-b6a7-30d84afe3baf  -6.3526726  1.61537696
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
