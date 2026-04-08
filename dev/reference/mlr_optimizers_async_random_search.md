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
#>  1: finished  7.0005899  0.64849173  -28.317391 2026-04-08 06:06:01
#>  2: finished -4.7273068  1.55118543  -55.969945 2026-04-08 06:06:01
#>  3: finished -8.3142357 -0.84808989 -101.014174 2026-04-08 06:06:01
#>  4: finished  7.4495551  2.57767647  -50.808126 2026-04-08 06:06:01
#>  5: finished  7.5065666  1.81294693  -43.486734 2026-04-08 06:06:01
#>  6: finished -9.8478251 -2.69770124 -130.462345 2026-04-08 06:06:01
#>  7: finished  0.3870992  2.09953629  -18.606719 2026-04-08 06:06:01
#>  8: finished  9.1887166  1.95032306  -66.183344 2026-04-08 06:06:01
#>  9: finished -6.7320590 -4.50562770  -68.515769 2026-04-08 06:06:01
#> 10: finished  0.9955564 -3.63495767    8.587922 2026-04-08 06:06:01
#> 11: finished  1.9339031  3.60780233  -33.667420 2026-04-08 06:06:01
#> 12: finished -3.6334861 -0.37274046  -28.638658 2026-04-08 06:06:01
#> 13: finished -1.3406191 -2.02690225   -2.106655 2026-04-08 06:06:01
#> 14: finished -5.8805572 -2.81415540  -52.137720 2026-04-08 06:06:01
#> 15: finished  6.5360563  4.77872294  -71.084338 2026-04-08 06:06:01
#> 16: finished -4.5197170 -2.02682984  -33.453771 2026-04-08 06:06:01
#> 17: finished  5.3688411  1.11764111  -18.304059 2026-04-08 06:06:01
#> 18: finished  2.5665792 -1.21875214    6.506144 2026-04-08 06:06:01
#> 19: finished -5.3691761 -0.01495275  -53.215263 2026-04-08 06:06:01
#> 20: finished -6.3526726  1.61537696  -81.068844 2026-04-08 06:06:01
#>        state         x1          x2           y        timestamp_xs
#>       <char>      <num>       <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-04-08 06:06:01
#>  2: narrow_xinjiangovenator 2026-04-08 06:06:01
#>  3: narrow_xinjiangovenator 2026-04-08 06:06:01
#>  4: narrow_xinjiangovenator 2026-04-08 06:06:01
#>  5: narrow_xinjiangovenator 2026-04-08 06:06:01
#>  6: narrow_xinjiangovenator 2026-04-08 06:06:01
#>  7: narrow_xinjiangovenator 2026-04-08 06:06:01
#>  8: narrow_xinjiangovenator 2026-04-08 06:06:01
#>  9: narrow_xinjiangovenator 2026-04-08 06:06:01
#> 10: narrow_xinjiangovenator 2026-04-08 06:06:01
#> 11: narrow_xinjiangovenator 2026-04-08 06:06:01
#> 12: narrow_xinjiangovenator 2026-04-08 06:06:01
#> 13: narrow_xinjiangovenator 2026-04-08 06:06:01
#> 14: narrow_xinjiangovenator 2026-04-08 06:06:01
#> 15: narrow_xinjiangovenator 2026-04-08 06:06:01
#> 16: narrow_xinjiangovenator 2026-04-08 06:06:01
#> 17: narrow_xinjiangovenator 2026-04-08 06:06:01
#> 18: narrow_xinjiangovenator 2026-04-08 06:06:01
#> 19: narrow_xinjiangovenator 2026-04-08 06:06:01
#> 20: narrow_xinjiangovenator 2026-04-08 06:06:01
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 88ef2bd8-13c0-48c9-8d36-50ca0d9cb0dc   7.0005899  0.64849173
#>  2: 13b155f0-a809-4fb7-9144-94467e09f4a8  -4.7273068  1.55118543
#>  3: 322f0acc-4c08-4b8e-a61d-b9177a8cae20  -8.3142357 -0.84808989
#>  4: 6db0bfd8-f78c-41db-9eb9-7258fa60e758   7.4495551  2.57767647
#>  5: cd36f282-3f9e-46fc-9ce1-1c6b44e3bd3c   7.5065666  1.81294693
#>  6: 932571f3-4853-4834-8859-29c5f5680384  -9.8478251 -2.69770124
#>  7: ff4d71ae-f82a-45da-b3b4-520a1301291d   0.3870992  2.09953629
#>  8: 7b2330ca-17e1-4250-bc20-301eb1982998   9.1887166  1.95032306
#>  9: 7cc10d4c-3c0f-42ac-ba21-818047b8c0a9  -6.7320590 -4.50562770
#> 10: ae823596-31bc-474c-a5a5-64db624fc6b2   0.9955564 -3.63495767
#> 11: 4178d3a1-d392-437f-b968-73bf58e2283d   1.9339031  3.60780233
#> 12: 90b0fc40-f016-4b0d-ba55-5d2f22a718e2  -3.6334861 -0.37274046
#> 13: e4c82768-9861-45e4-a3c5-c1463a3efaec  -1.3406191 -2.02690225
#> 14: d9a01475-ead3-4302-8de7-111598461fef  -5.8805572 -2.81415540
#> 15: c8c4e523-b630-436e-b6cf-5b239237058f   6.5360563  4.77872294
#> 16: f68acbf4-013d-4139-8b00-8c20b318ecd1  -4.5197170 -2.02682984
#> 17: 9ea00b3b-8cc9-4cf0-9954-15ce59aa2866   5.3688411  1.11764111
#> 18: 873e87da-5ca2-4d06-a7ae-bc3fde6a7942   2.5665792 -1.21875214
#> 19: 95a7f015-a537-47ee-87f5-34b97d7cba5e  -5.3691761 -0.01495275
#> 20: 52137e28-663f-451a-99d7-ebe64a3205d7  -6.3526726  1.61537696
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
