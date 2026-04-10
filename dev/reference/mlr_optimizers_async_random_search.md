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
#>  1: finished  7.0005899  0.64849173  -28.317391 2026-04-10 10:49:13
#>  2: finished -4.7273068  1.55118543  -55.969945 2026-04-10 10:49:13
#>  3: finished -8.3142357 -0.84808989 -101.014174 2026-04-10 10:49:13
#>  4: finished  7.4495551  2.57767647  -50.808126 2026-04-10 10:49:13
#>  5: finished  7.5065666  1.81294693  -43.486734 2026-04-10 10:49:13
#>  6: finished -9.8478251 -2.69770124 -130.462345 2026-04-10 10:49:14
#>  7: finished  0.3870992  2.09953629  -18.606719 2026-04-10 10:49:14
#>  8: finished  9.1887166  1.95032306  -66.183344 2026-04-10 10:49:14
#>  9: finished -6.7320590 -4.50562770  -68.515769 2026-04-10 10:49:14
#> 10: finished  0.9955564 -3.63495767    8.587922 2026-04-10 10:49:14
#> 11: finished  1.9339031  3.60780233  -33.667420 2026-04-10 10:49:14
#> 12: finished -3.6334861 -0.37274046  -28.638658 2026-04-10 10:49:14
#> 13: finished -1.3406191 -2.02690225   -2.106655 2026-04-10 10:49:14
#> 14: finished -5.8805572 -2.81415540  -52.137720 2026-04-10 10:49:14
#> 15: finished  6.5360563  4.77872294  -71.084338 2026-04-10 10:49:14
#> 16: finished -4.5197170 -2.02682984  -33.453771 2026-04-10 10:49:14
#> 17: finished  5.3688411  1.11764111  -18.304059 2026-04-10 10:49:14
#> 18: finished  2.5665792 -1.21875214    6.506144 2026-04-10 10:49:14
#> 19: finished -5.3691761 -0.01495275  -53.215263 2026-04-10 10:49:14
#> 20: finished -6.3526726  1.61537696  -81.068844 2026-04-10 10:49:14
#>        state         x1          x2           y        timestamp_xs
#>       <char>      <num>       <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-04-10 10:49:13
#>  2: narrow_xinjiangovenator 2026-04-10 10:49:13
#>  3: narrow_xinjiangovenator 2026-04-10 10:49:13
#>  4: narrow_xinjiangovenator 2026-04-10 10:49:13
#>  5: narrow_xinjiangovenator 2026-04-10 10:49:13
#>  6: narrow_xinjiangovenator 2026-04-10 10:49:14
#>  7: narrow_xinjiangovenator 2026-04-10 10:49:14
#>  8: narrow_xinjiangovenator 2026-04-10 10:49:14
#>  9: narrow_xinjiangovenator 2026-04-10 10:49:14
#> 10: narrow_xinjiangovenator 2026-04-10 10:49:14
#> 11: narrow_xinjiangovenator 2026-04-10 10:49:14
#> 12: narrow_xinjiangovenator 2026-04-10 10:49:14
#> 13: narrow_xinjiangovenator 2026-04-10 10:49:14
#> 14: narrow_xinjiangovenator 2026-04-10 10:49:14
#> 15: narrow_xinjiangovenator 2026-04-10 10:49:14
#> 16: narrow_xinjiangovenator 2026-04-10 10:49:14
#> 17: narrow_xinjiangovenator 2026-04-10 10:49:14
#> 18: narrow_xinjiangovenator 2026-04-10 10:49:14
#> 19: narrow_xinjiangovenator 2026-04-10 10:49:14
#> 20: narrow_xinjiangovenator 2026-04-10 10:49:14
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: e01b8ae4-ec81-42c4-9e95-b3de528d75b7   7.0005899  0.64849173
#>  2: 86f43932-75d1-47ec-a897-b0720e7bafa5  -4.7273068  1.55118543
#>  3: f029dc7a-be34-47ae-bc6c-b40b01c17a45  -8.3142357 -0.84808989
#>  4: 3e776777-dfe5-4081-a9ee-461019447361   7.4495551  2.57767647
#>  5: 8ae44da3-18f3-4ef7-a957-a3022c4b64b6   7.5065666  1.81294693
#>  6: 4ade519d-5e9c-48a4-bfbe-d0f17becaa2d  -9.8478251 -2.69770124
#>  7: 6ac952be-7176-4610-8483-1424bc21e01c   0.3870992  2.09953629
#>  8: a0900fb4-ea09-40b1-a02b-8d6b905caabb   9.1887166  1.95032306
#>  9: 9fc47297-0c69-4db6-a48a-69dc18f86170  -6.7320590 -4.50562770
#> 10: 2e84124b-d79c-4dc4-a987-fd4d455ba85d   0.9955564 -3.63495767
#> 11: 4df27278-ba11-45ef-8836-9663ec34a6d2   1.9339031  3.60780233
#> 12: c18d7c53-7e7c-4b64-b3ca-36fc862910df  -3.6334861 -0.37274046
#> 13: 6da44322-db87-41e7-a3ff-d1ece6420130  -1.3406191 -2.02690225
#> 14: 92c6f4d0-4594-4474-986f-b075b05d9e69  -5.8805572 -2.81415540
#> 15: ed04c057-2b8e-4548-849e-590703323f6f   6.5360563  4.77872294
#> 16: 946719bd-084c-4d2b-9cdf-3c508b0c02a1  -4.5197170 -2.02682984
#> 17: bef51a87-2cee-43d3-b9bb-70e12b8b306c   5.3688411  1.11764111
#> 18: 7171bebf-2f6c-4101-b5da-64fe8a536c9b   2.5665792 -1.21875214
#> 19: 6f4bba48-da67-4201-b89c-f1a31a69db97  -5.3691761 -0.01495275
#> 20: 6f3be329-8f42-4cec-8194-9f987c14927c  -6.3526726  1.61537696
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
