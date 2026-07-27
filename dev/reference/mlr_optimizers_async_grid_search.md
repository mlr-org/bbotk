# Asynchronous Optimization via Grid Search

`OptimizerAsyncGridSearch` class that implements a grid search. The grid
is constructed as a Cartesian product over discretized values per
parameter, see
[`paradox::generate_design_grid()`](https://paradox.mlr-org.com/reference/generate_design_grid.html).
The points of the grid are evaluated in a random order.

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

    mlr_optimizers$get("async_grid_search")
    opt("async_grid_search")

## Parameters

- `batch_size`:

  `integer(1)`  
  Maximum number of points to try in a batch.

## Super classes

[`Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md) -\>
[`OptimizerAsync`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md)
-\> `OptimizerAsyncGridSearch`

## Methods

### Public methods

- [`OptimizerAsyncGridSearch$new()`](#method-OptimizerAsyncGridSearch-initialize)

- [`OptimizerAsyncGridSearch$optimize()`](#method-OptimizerAsyncGridSearch-optimize)

- [`OptimizerAsyncGridSearch$clone()`](#method-OptimizerAsyncGridSearch-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)

------------------------------------------------------------------------

### `OptimizerAsyncGridSearch$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerAsyncGridSearch$new()

------------------------------------------------------------------------

### `OptimizerAsyncGridSearch$optimize()`

Starts the asynchronous optimization.

#### Usage

    OptimizerAsyncGridSearch$optimize(inst)

#### Arguments

- `inst`:

  ([OptimInstance](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)).

#### Returns

[data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html).

------------------------------------------------------------------------

### `OptimizerAsyncGridSearch$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerAsyncGridSearch$clone(deep = FALSE)

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
optimizer = opt("async_grid_search", resolution = 10)

# trigger optimization
optimizer$optimize(instance)

# all evaluated configurations
instance$archive

# best performing configuration
instance$archive$best()

# covert to data.table
as.data.table(instance$archive)
}
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-07-27 09:00:43
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-07-27 09:00:43
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-07-27 09:00:43
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-07-27 09:00:43
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-07-27 09:00:43
#>   6: finished -10.000000  0.5555556 -146.64198 2026-07-27 09:00:43
#>   7: finished -10.000000  1.6666667 -155.77778 2026-07-27 09:00:43
#>   8: finished -10.000000  2.7777778 -167.38272 2026-07-27 09:00:43
#>   9: finished -10.000000  3.8888889 -181.45679 2026-07-27 09:00:43
#>  10: finished -10.000000  5.0000000 -198.00000 2026-07-27 09:00:43
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-07-27 09:00:43
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-07-27 09:00:43
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-07-27 09:00:43
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-07-27 09:00:43
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-07-27 09:00:43
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-07-27 09:00:43
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-07-27 09:00:43
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-07-27 09:00:43
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-07-27 09:00:43
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-07-27 09:00:43
#>  21:   failed  10.000000  5.0000000         NA 2026-07-27 09:00:43
#>  22:   failed  10.000000  3.8888889         NA 2026-07-27 09:00:43
#>  23:   failed  10.000000  2.7777778         NA 2026-07-27 09:00:43
#>  24:   failed  10.000000  1.6666667         NA 2026-07-27 09:00:43
#>  25:   failed  10.000000  0.5555556         NA 2026-07-27 09:00:43
#>  26:   failed  10.000000 -0.5555556         NA 2026-07-27 09:00:43
#>  27:   failed  10.000000 -1.6666667         NA 2026-07-27 09:00:43
#>  28:   failed  10.000000 -2.7777778         NA 2026-07-27 09:00:43
#>  29:   failed  10.000000 -3.8888889         NA 2026-07-27 09:00:43
#>  30:   failed  10.000000 -5.0000000         NA 2026-07-27 09:00:43
#>  31:   failed   7.777778  5.0000000         NA 2026-07-27 09:00:43
#>  32:   failed   7.777778  3.8888889         NA 2026-07-27 09:00:43
#>  33:   failed   7.777778  2.7777778         NA 2026-07-27 09:00:43
#>  34:   failed   7.777778  1.6666667         NA 2026-07-27 09:00:43
#>  35:   failed   7.777778  0.5555556         NA 2026-07-27 09:00:43
#>  36:   failed   7.777778 -0.5555556         NA 2026-07-27 09:00:43
#>  37:   failed   7.777778 -1.6666667         NA 2026-07-27 09:00:43
#>  38:   failed   7.777778 -2.7777778         NA 2026-07-27 09:00:43
#>  39:   failed   7.777778 -3.8888889         NA 2026-07-27 09:00:43
#>  40:   failed   7.777778 -5.0000000         NA 2026-07-27 09:00:43
#>  41:   failed   5.555556  5.0000000         NA 2026-07-27 09:00:43
#>  42:   failed   5.555556  3.8888889         NA 2026-07-27 09:00:43
#>  43:   failed   5.555556  2.7777778         NA 2026-07-27 09:00:43
#>  44:   failed   5.555556  1.6666667         NA 2026-07-27 09:00:43
#>  45:   failed   5.555556  0.5555556         NA 2026-07-27 09:00:43
#>  46:   failed   5.555556 -0.5555556         NA 2026-07-27 09:00:43
#>  47:   failed   5.555556 -1.6666667         NA 2026-07-27 09:00:43
#>  48:   failed   5.555556 -2.7777778         NA 2026-07-27 09:00:43
#>  49:   failed   5.555556 -3.8888889         NA 2026-07-27 09:00:43
#>  50:   failed   5.555556 -5.0000000         NA 2026-07-27 09:00:43
#>  51:   failed   3.333333  5.0000000         NA 2026-07-27 09:00:43
#>  52:   failed   3.333333  3.8888889         NA 2026-07-27 09:00:43
#>  53:   failed   3.333333  2.7777778         NA 2026-07-27 09:00:43
#>  54:   failed   3.333333  1.6666667         NA 2026-07-27 09:00:43
#>  55:   failed   3.333333  0.5555556         NA 2026-07-27 09:00:43
#>  56:   failed   3.333333 -0.5555556         NA 2026-07-27 09:00:43
#>  57:   failed   3.333333 -1.6666667         NA 2026-07-27 09:00:43
#>  58:   failed   3.333333 -2.7777778         NA 2026-07-27 09:00:43
#>  59:   failed   3.333333 -3.8888889         NA 2026-07-27 09:00:43
#>  60:   failed   3.333333 -5.0000000         NA 2026-07-27 09:00:43
#>  61:   failed   1.111111  5.0000000         NA 2026-07-27 09:00:43
#>  62:   failed   1.111111  3.8888889         NA 2026-07-27 09:00:43
#>  63:   failed   1.111111  2.7777778         NA 2026-07-27 09:00:43
#>  64:   failed   1.111111  1.6666667         NA 2026-07-27 09:00:43
#>  65:   failed   1.111111  0.5555556         NA 2026-07-27 09:00:43
#>  66:   failed   1.111111 -0.5555556         NA 2026-07-27 09:00:43
#>  67:   failed   1.111111 -1.6666667         NA 2026-07-27 09:00:43
#>  68:   failed   1.111111 -2.7777778         NA 2026-07-27 09:00:43
#>  69:   failed   1.111111 -3.8888889         NA 2026-07-27 09:00:43
#>  70:   failed   1.111111 -5.0000000         NA 2026-07-27 09:00:43
#>  71:   failed  -1.111111  5.0000000         NA 2026-07-27 09:00:43
#>  72:   failed  -1.111111  3.8888889         NA 2026-07-27 09:00:43
#>  73:   failed  -1.111111  2.7777778         NA 2026-07-27 09:00:43
#>  74:   failed  -1.111111  1.6666667         NA 2026-07-27 09:00:43
#>  75:   failed  -1.111111  0.5555556         NA 2026-07-27 09:00:43
#>  76:   failed  -1.111111 -0.5555556         NA 2026-07-27 09:00:43
#>  77:   failed  -1.111111 -1.6666667         NA 2026-07-27 09:00:43
#>  78:   failed  -1.111111 -2.7777778         NA 2026-07-27 09:00:43
#>  79:   failed  -1.111111 -3.8888889         NA 2026-07-27 09:00:43
#>  80:   failed  -1.111111 -5.0000000         NA 2026-07-27 09:00:43
#>  81:   failed  -3.333333  5.0000000         NA 2026-07-27 09:00:43
#>  82:   failed  -3.333333  3.8888889         NA 2026-07-27 09:00:43
#>  83:   failed  -3.333333  2.7777778         NA 2026-07-27 09:00:43
#>  84:   failed  -3.333333  1.6666667         NA 2026-07-27 09:00:43
#>  85:   failed  -3.333333  0.5555556         NA 2026-07-27 09:00:43
#>  86:   failed  -3.333333 -0.5555556         NA 2026-07-27 09:00:43
#>  87:   failed  -3.333333 -1.6666667         NA 2026-07-27 09:00:43
#>  88:   failed  -3.333333 -2.7777778         NA 2026-07-27 09:00:43
#>  89:   failed  -3.333333 -3.8888889         NA 2026-07-27 09:00:43
#>  90:   failed  -3.333333 -5.0000000         NA 2026-07-27 09:00:43
#>  91:   failed  -5.555556  5.0000000         NA 2026-07-27 09:00:43
#>  92:   failed  -5.555556  3.8888889         NA 2026-07-27 09:00:43
#>  93:   failed  -5.555556  2.7777778         NA 2026-07-27 09:00:43
#>  94:   failed  -5.555556  1.6666667         NA 2026-07-27 09:00:43
#>  95:   failed  -5.555556  0.5555556         NA 2026-07-27 09:00:43
#>  96:   failed  -5.555556 -0.5555556         NA 2026-07-27 09:00:43
#>  97:   failed  -5.555556 -1.6666667         NA 2026-07-27 09:00:43
#>  98:   failed  -5.555556 -2.7777778         NA 2026-07-27 09:00:43
#>  99:   failed  -5.555556 -3.8888889         NA 2026-07-27 09:00:43
#> 100:   failed  -5.555556 -5.0000000         NA 2026-07-27 09:00:43
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>   2: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>   3: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>   4: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>   5: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>   6: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>   7: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>   8: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>   9: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>  10: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>  11: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>  12: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>  13: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>  14: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>  15: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>  16: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>  17: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>  18: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>  19: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>  20: sinking_raccoon_f3bad890 2026-07-27 09:00:44
#>  21:                     <NA>                <NA>
#>  22:                     <NA>                <NA>
#>  23:                     <NA>                <NA>
#>  24:                     <NA>                <NA>
#>  25:                     <NA>                <NA>
#>  26:                     <NA>                <NA>
#>  27:                     <NA>                <NA>
#>  28:                     <NA>                <NA>
#>  29:                     <NA>                <NA>
#>  30:                     <NA>                <NA>
#>  31:                     <NA>                <NA>
#>  32:                     <NA>                <NA>
#>  33:                     <NA>                <NA>
#>  34:                     <NA>                <NA>
#>  35:                     <NA>                <NA>
#>  36:                     <NA>                <NA>
#>  37:                     <NA>                <NA>
#>  38:                     <NA>                <NA>
#>  39:                     <NA>                <NA>
#>  40:                     <NA>                <NA>
#>  41:                     <NA>                <NA>
#>  42:                     <NA>                <NA>
#>  43:                     <NA>                <NA>
#>  44:                     <NA>                <NA>
#>  45:                     <NA>                <NA>
#>  46:                     <NA>                <NA>
#>  47:                     <NA>                <NA>
#>  48:                     <NA>                <NA>
#>  49:                     <NA>                <NA>
#>  50:                     <NA>                <NA>
#>  51:                     <NA>                <NA>
#>  52:                     <NA>                <NA>
#>  53:                     <NA>                <NA>
#>  54:                     <NA>                <NA>
#>  55:                     <NA>                <NA>
#>  56:                     <NA>                <NA>
#>  57:                     <NA>                <NA>
#>  58:                     <NA>                <NA>
#>  59:                     <NA>                <NA>
#>  60:                     <NA>                <NA>
#>  61:                     <NA>                <NA>
#>  62:                     <NA>                <NA>
#>  63:                     <NA>                <NA>
#>  64:                     <NA>                <NA>
#>  65:                     <NA>                <NA>
#>  66:                     <NA>                <NA>
#>  67:                     <NA>                <NA>
#>  68:                     <NA>                <NA>
#>  69:                     <NA>                <NA>
#>  70:                     <NA>                <NA>
#>  71:                     <NA>                <NA>
#>  72:                     <NA>                <NA>
#>  73:                     <NA>                <NA>
#>  74:                     <NA>                <NA>
#>  75:                     <NA>                <NA>
#>  76:                     <NA>                <NA>
#>  77:                     <NA>                <NA>
#>  78:                     <NA>                <NA>
#>  79:                     <NA>                <NA>
#>  80:                     <NA>                <NA>
#>  81:                     <NA>                <NA>
#>  82:                     <NA>                <NA>
#>  83:                     <NA>                <NA>
#>  84:                     <NA>                <NA>
#>  85:                     <NA>                <NA>
#>  86:                     <NA>                <NA>
#>  87:                     <NA>                <NA>
#>  88:                     <NA>                <NA>
#>  89:                     <NA>                <NA>
#>  90:                     <NA>                <NA>
#>  91:                     <NA>                <NA>
#>  92:                     <NA>                <NA>
#>  93:                     <NA>                <NA>
#>  94:                     <NA>                <NA>
#>  95:                     <NA>                <NA>
#>  96:                     <NA>                <NA>
#>  97:                     <NA>                <NA>
#>  98:                     <NA>                <NA>
#>  99:                     <NA>                <NA>
#> 100:                     <NA>                <NA>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
#>   1: 1ab81b58-dff4-43ad-8f04-3a11d86be835    [NULL]  -10.000000  -5.0000000
#>   2: c50c9264-349a-4e90-8629-92f25f55a063    [NULL]  -10.000000  -3.8888889
#>   3: 2b276d25-9364-4001-a414-4ab2bbcfabfc    [NULL]  -10.000000  -2.7777778
#>   4: 313f5cb7-9767-4781-8f76-61c3dd862701    [NULL]  -10.000000  -1.6666667
#>   5: 3648645e-a224-49ce-98c3-487affe3442f    [NULL]  -10.000000  -0.5555556
#>   6: f7b4d9f4-d056-4280-8970-0e5da742d1c1    [NULL]  -10.000000   0.5555556
#>   7: c62cebd9-7909-4792-8335-ee7c36bcc5ee    [NULL]  -10.000000   1.6666667
#>   8: cb5a8940-5610-4984-8034-6c508cf5d1eb    [NULL]  -10.000000   2.7777778
#>   9: c4ef3483-ba23-4532-aee2-e006b220f660    [NULL]  -10.000000   3.8888889
#>  10: 8bcb0109-c730-4dc1-9c11-4e59188155f4    [NULL]  -10.000000   5.0000000
#>  11: 7f39aefb-68a4-4d76-9859-3a55c02519a6    [NULL]   -7.777778  -5.0000000
#>  12: 4f7d7319-4b47-42d2-b747-21e84c4abcbb    [NULL]   -7.777778  -3.8888889
#>  13: 2696a513-43f1-4167-87ed-0ee8512cccbc    [NULL]   -7.777778  -2.7777778
#>  14: 19ccb0cb-7e52-4f92-bc7c-500b8a0a7f2f    [NULL]   -7.777778  -1.6666667
#>  15: 3f0ec48f-ace5-4e9b-9191-6d110b93f051    [NULL]   -7.777778  -0.5555556
#>  16: 348194b0-3dac-43b0-aef2-a76e482c8e61    [NULL]   -7.777778   0.5555556
#>  17: 9f345624-8775-42c1-8d3c-29486b9b802b    [NULL]   -7.777778   1.6666667
#>  18: 44ce7c67-22bc-4f02-83ee-650e20cffba2    [NULL]   -7.777778   2.7777778
#>  19: 5bbe4fb0-3ec3-4423-9838-b48205d12743    [NULL]   -7.777778   3.8888889
#>  20: 60cead29-3985-456b-93f2-dcd0c753de9b    [NULL]   -7.777778   5.0000000
#>  21: c2e4d1e0-85bb-4529-a759-0ed7541b622b <list[1]>          NA          NA
#>  22: 2651c3dd-c255-4f8a-ad9e-9875007d44e0 <list[1]>          NA          NA
#>  23: 86d47696-7885-4c81-b138-73e73fc34eb9 <list[1]>          NA          NA
#>  24: 04d10c88-3673-4a5f-9b4e-55bba901a816 <list[1]>          NA          NA
#>  25: 808ff6b1-1eed-40d9-9c15-99425436097f <list[1]>          NA          NA
#>  26: 11a89972-7703-40c6-8a92-0a9f95b96f02 <list[1]>          NA          NA
#>  27: 939ae21f-7397-4a02-abd2-a725268373a1 <list[1]>          NA          NA
#>  28: 5b5e4e53-817a-43d4-90c3-0685a9862d24 <list[1]>          NA          NA
#>  29: e24cc875-b39f-4c8b-b8fa-273c79fa6099 <list[1]>          NA          NA
#>  30: dfed5bc3-fd4a-4271-84ec-cc1a54886e23 <list[1]>          NA          NA
#>  31: fcc416de-e7d3-4c85-9bde-434831b6682b <list[1]>          NA          NA
#>  32: dc4beef9-db08-4fed-acee-2d09e4991c85 <list[1]>          NA          NA
#>  33: aa06c5a4-896d-4be1-a732-0684f03b1a65 <list[1]>          NA          NA
#>  34: 50cd7d1e-eb6c-44d0-9d61-e64125fde277 <list[1]>          NA          NA
#>  35: 3872d8c8-999c-45f7-baa3-fe28a064831b <list[1]>          NA          NA
#>  36: 2f340f50-e96e-4d8a-b487-fdf62723340a <list[1]>          NA          NA
#>  37: d4d98de0-5a25-48e7-8b6b-e7ae888c73d2 <list[1]>          NA          NA
#>  38: 6b4e9353-ead0-4ce5-b263-20cde1f24d59 <list[1]>          NA          NA
#>  39: f031bf72-e1e6-4fb0-9363-4fb6e6664b99 <list[1]>          NA          NA
#>  40: fe13154a-d0f5-4cf8-8e30-a4e6e4134579 <list[1]>          NA          NA
#>  41: 8dca4315-1d99-43a7-b27b-a0128dad5f12 <list[1]>          NA          NA
#>  42: 484c6a3f-e515-4ec8-bbaf-28b3d20d3b04 <list[1]>          NA          NA
#>  43: a6b977c5-b524-438c-8689-bd6288d32c7b <list[1]>          NA          NA
#>  44: 106c3640-ac3d-42d9-8d5d-f04684fde728 <list[1]>          NA          NA
#>  45: cf4ca5e1-7bc8-4d04-9a46-ed56e3a65f5c <list[1]>          NA          NA
#>  46: 15a17b5a-2324-4eb3-a070-3e29d7eb3f09 <list[1]>          NA          NA
#>  47: eb5d307b-8960-4fce-8188-3e56d133989e <list[1]>          NA          NA
#>  48: 91f2b51f-e97c-4013-8f93-686986a97739 <list[1]>          NA          NA
#>  49: b6dfba91-ea5c-4b58-9b20-9cabf4ccf4df <list[1]>          NA          NA
#>  50: 7016cf0f-a329-40a7-8bac-a0a18f6dc41b <list[1]>          NA          NA
#>  51: 4b8464b4-2a32-454a-872d-be8e10783211 <list[1]>          NA          NA
#>  52: 86be0aed-136d-45c3-bb8a-5067b30d7005 <list[1]>          NA          NA
#>  53: 15cc91b9-3b6f-470c-b157-dae745f3e218 <list[1]>          NA          NA
#>  54: 7d806e72-8a92-4ccb-8ee4-826137c3426e <list[1]>          NA          NA
#>  55: 103b7854-8957-4721-a775-bae10545ec13 <list[1]>          NA          NA
#>  56: cd9f0ede-32ca-438a-88ec-4c9d1267296a <list[1]>          NA          NA
#>  57: 94f0ee1f-ecad-4932-a2d3-968f50992732 <list[1]>          NA          NA
#>  58: f6fb8760-e864-4700-bcc1-e3b010c8f75c <list[1]>          NA          NA
#>  59: c70204d4-f0fa-429b-846b-10e0e75fd31d <list[1]>          NA          NA
#>  60: 6202e664-c95c-4833-951f-23a6b5e5be81 <list[1]>          NA          NA
#>  61: 3615ad5c-a5a9-4450-af4e-30c58ddeaf15 <list[1]>          NA          NA
#>  62: 1de4d7b1-95dc-4829-bf35-51781eb48814 <list[1]>          NA          NA
#>  63: e3033da0-a604-4869-b973-b4ae72807db4 <list[1]>          NA          NA
#>  64: f861ed63-68d4-4bca-bc51-2ca233ae9dd2 <list[1]>          NA          NA
#>  65: b4248419-6fd2-48ca-82a4-5cfea774bd5e <list[1]>          NA          NA
#>  66: 8c9abe44-4180-4743-9b17-7333f2da6d69 <list[1]>          NA          NA
#>  67: 09ebfaa8-566c-44f7-ad37-fa8dd273dad5 <list[1]>          NA          NA
#>  68: af22874c-c28d-4d63-ad53-5fd5803c7f2f <list[1]>          NA          NA
#>  69: 9eac07cb-e64f-44e4-b9e2-45e1065c8497 <list[1]>          NA          NA
#>  70: edbb337d-f7d9-4f3a-a3aa-d1a780f79ee5 <list[1]>          NA          NA
#>  71: 697ccf04-1a64-4090-95bf-21887ba77117 <list[1]>          NA          NA
#>  72: 3f9dc621-5591-42b9-8dfb-02315f09a113 <list[1]>          NA          NA
#>  73: 6a0f9d71-c83e-4a6a-b2fc-9ee30e36fbfc <list[1]>          NA          NA
#>  74: 894893d0-133e-4b66-8547-2958ae4fbf80 <list[1]>          NA          NA
#>  75: f5aba863-b342-44cf-82c0-870c4cd8f857 <list[1]>          NA          NA
#>  76: d86febc2-1f09-4c4c-8c72-461a985bc26f <list[1]>          NA          NA
#>  77: 965cb81a-4b0a-49de-b7e0-2e8631fe0433 <list[1]>          NA          NA
#>  78: 403a4ae6-ba69-4cc3-9e34-c924f98cd470 <list[1]>          NA          NA
#>  79: 959b5273-9eaf-45c2-a245-502ef0c0a2cc <list[1]>          NA          NA
#>  80: e442e400-b6e2-4b62-ae73-cb16204d5326 <list[1]>          NA          NA
#>  81: 3f4662f6-1333-4963-baa5-5ebcdb908299 <list[1]>          NA          NA
#>  82: a35d02a7-fb73-4f0d-b60a-815bf343a26a <list[1]>          NA          NA
#>  83: fb08d5e2-e154-4ba0-8600-bb77c7eaf3b9 <list[1]>          NA          NA
#>  84: 07524064-8464-4858-bfd9-b336d9adab14 <list[1]>          NA          NA
#>  85: a81ad28c-aef2-401b-bef1-e0045ad5df14 <list[1]>          NA          NA
#>  86: 0b814953-6e09-49e3-a55a-0a2952115846 <list[1]>          NA          NA
#>  87: e84526db-a2c1-447d-af31-5c66105bbc20 <list[1]>          NA          NA
#>  88: 8f730e42-a351-41cf-8914-c0448cb6bf57 <list[1]>          NA          NA
#>  89: 37dd3e2f-5e24-4511-be27-162352ef42ea <list[1]>          NA          NA
#>  90: 64d34222-9975-4857-bfc4-775213d5aa34 <list[1]>          NA          NA
#>  91: 14ea7dbc-44e7-4dc0-8128-b10b2b709f8a <list[1]>          NA          NA
#>  92: 1ddfbcba-a454-4996-b4b0-59ac9c21de9a <list[1]>          NA          NA
#>  93: 913a2e9c-7c2e-4c83-8411-1095f2bb2acc <list[1]>          NA          NA
#>  94: 27c46d7c-502f-4a66-8c2d-58e60bf4b709 <list[1]>          NA          NA
#>  95: 47dde6f6-b335-4424-bcb7-c58145429e53 <list[1]>          NA          NA
#>  96: cabd414d-6510-4874-9867-e69e1585c62c <list[1]>          NA          NA
#>  97: 568a91cf-e167-4b5f-89e0-108bd33892d1 <list[1]>          NA          NA
#>  98: 8f9edca3-976e-4064-8be9-598ead805034 <list[1]>          NA          NA
#>  99: 21df6cbf-9419-4a2c-9dec-038f6a1b5633 <list[1]>          NA          NA
#> 100: c0f97ad0-e6f5-4f01-8ea2-d08bdd316de9 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
