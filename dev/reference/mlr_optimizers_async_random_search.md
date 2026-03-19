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
#>  1: finished  7.0005899  0.64849173  -28.317391 2026-03-19 07:59:23
#>  2: finished -4.7273068  1.55118543  -55.969945 2026-03-19 07:59:23
#>  3: finished -8.3142357 -0.84808989 -101.014174 2026-03-19 07:59:23
#>  4: finished  7.4495551  2.57767647  -50.808126 2026-03-19 07:59:23
#>  5: finished  7.5065666  1.81294693  -43.486734 2026-03-19 07:59:24
#>  6: finished -9.8478251 -2.69770124 -130.462345 2026-03-19 07:59:24
#>  7: finished  0.3870992  2.09953629  -18.606719 2026-03-19 07:59:24
#>  8: finished  9.1887166  1.95032306  -66.183344 2026-03-19 07:59:24
#>  9: finished -6.7320590 -4.50562770  -68.515769 2026-03-19 07:59:24
#> 10: finished  0.9955564 -3.63495767    8.587922 2026-03-19 07:59:24
#> 11: finished  1.9339031  3.60780233  -33.667420 2026-03-19 07:59:24
#> 12: finished -3.6334861 -0.37274046  -28.638658 2026-03-19 07:59:24
#> 13: finished -1.3406191 -2.02690225   -2.106655 2026-03-19 07:59:24
#> 14: finished -5.8805572 -2.81415540  -52.137720 2026-03-19 07:59:24
#> 15: finished  6.5360563  4.77872294  -71.084338 2026-03-19 07:59:24
#> 16: finished -4.5197170 -2.02682984  -33.453771 2026-03-19 07:59:24
#> 17: finished  5.3688411  1.11764111  -18.304059 2026-03-19 07:59:24
#> 18: finished  2.5665792 -1.21875214    6.506144 2026-03-19 07:59:24
#> 19: finished -5.3691761 -0.01495275  -53.215263 2026-03-19 07:59:24
#> 20: finished -6.3526726  1.61537696  -81.068844 2026-03-19 07:59:24
#>        state         x1          x2           y        timestamp_xs
#>       <char>      <num>       <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-03-19 07:59:23
#>  2: narrow_xinjiangovenator 2026-03-19 07:59:23
#>  3: narrow_xinjiangovenator 2026-03-19 07:59:23
#>  4: narrow_xinjiangovenator 2026-03-19 07:59:24
#>  5: narrow_xinjiangovenator 2026-03-19 07:59:24
#>  6: narrow_xinjiangovenator 2026-03-19 07:59:24
#>  7: narrow_xinjiangovenator 2026-03-19 07:59:24
#>  8: narrow_xinjiangovenator 2026-03-19 07:59:24
#>  9: narrow_xinjiangovenator 2026-03-19 07:59:24
#> 10: narrow_xinjiangovenator 2026-03-19 07:59:24
#> 11: narrow_xinjiangovenator 2026-03-19 07:59:24
#> 12: narrow_xinjiangovenator 2026-03-19 07:59:24
#> 13: narrow_xinjiangovenator 2026-03-19 07:59:24
#> 14: narrow_xinjiangovenator 2026-03-19 07:59:24
#> 15: narrow_xinjiangovenator 2026-03-19 07:59:24
#> 16: narrow_xinjiangovenator 2026-03-19 07:59:24
#> 17: narrow_xinjiangovenator 2026-03-19 07:59:24
#> 18: narrow_xinjiangovenator 2026-03-19 07:59:24
#> 19: narrow_xinjiangovenator 2026-03-19 07:59:24
#> 20: narrow_xinjiangovenator 2026-03-19 07:59:24
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 3600dd94-20dc-476e-b6eb-0f890783220a   7.0005899  0.64849173
#>  2: 29e91179-2a90-4392-a92a-fdba2e429f35  -4.7273068  1.55118543
#>  3: 34001bfb-d4cf-4a5d-b4a7-52b9193a6d6e  -8.3142357 -0.84808989
#>  4: f70e55dd-1534-48a7-949f-b969c5ef74c4   7.4495551  2.57767647
#>  5: 0851c107-b13b-4a5d-b95e-9599aa367f31   7.5065666  1.81294693
#>  6: fe9ee987-4200-458f-964d-3f9a13f247f0  -9.8478251 -2.69770124
#>  7: 2b1e9211-57b7-49cc-b2a3-49adf9b24202   0.3870992  2.09953629
#>  8: 87acef91-68ed-46f3-a2ff-42486f867feb   9.1887166  1.95032306
#>  9: cdbe3049-7f7b-40b1-8369-0dda1e1c5195  -6.7320590 -4.50562770
#> 10: ea52c11a-41d8-4408-bab8-d5ba063d09ba   0.9955564 -3.63495767
#> 11: c59e788e-d3e6-42b0-adb9-da0752ccde90   1.9339031  3.60780233
#> 12: 876a33c5-bc43-47fe-9912-d1eef9761f48  -3.6334861 -0.37274046
#> 13: 57599392-4d89-4ad7-a726-797626ebbb29  -1.3406191 -2.02690225
#> 14: 17daded6-b19f-4991-bb61-0872de6376bb  -5.8805572 -2.81415540
#> 15: 85e513f4-abe4-4af5-a4fd-14f44c894640   6.5360563  4.77872294
#> 16: ef8d0bd4-2b00-4930-bd4b-01db61291f38  -4.5197170 -2.02682984
#> 17: ea9f1c34-e209-4ef5-874a-0fb0dd91acc0   5.3688411  1.11764111
#> 18: 13e783b0-f031-415b-8b6a-151baa1c845d   2.5665792 -1.21875214
#> 19: 43fa4f80-17f5-4341-aaec-2a72157dc609  -5.3691761 -0.01495275
#> 20: edff176c-8e75-4e8e-9e52-288b511ee64b  -6.3526726  1.61537696
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
