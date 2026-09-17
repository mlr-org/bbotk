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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-17 09:23:38
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-17 09:23:38
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-17 09:23:38
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-17 09:23:38
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-17 09:23:38
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-17 09:23:38
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-17 09:23:38
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-17 09:23:38
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-17 09:23:38
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-17 09:23:38
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-17 09:23:38
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-17 09:23:38
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-17 09:23:38
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-17 09:23:38
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-17 09:23:38
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-17 09:23:38
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-17 09:23:38
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-17 09:23:38
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-17 09:23:38
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-17 09:23:38
#>  21:   failed  10.000000  5.0000000         NA 2026-09-17 09:23:38
#>  22:   failed  10.000000  3.8888889         NA 2026-09-17 09:23:38
#>  23:   failed  10.000000  2.7777778         NA 2026-09-17 09:23:38
#>  24:   failed  10.000000  1.6666667         NA 2026-09-17 09:23:38
#>  25:   failed  10.000000  0.5555556         NA 2026-09-17 09:23:38
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-17 09:23:38
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-17 09:23:38
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-17 09:23:38
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-17 09:23:38
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-17 09:23:38
#>  31:   failed   7.777778  5.0000000         NA 2026-09-17 09:23:38
#>  32:   failed   7.777778  3.8888889         NA 2026-09-17 09:23:38
#>  33:   failed   7.777778  2.7777778         NA 2026-09-17 09:23:38
#>  34:   failed   7.777778  1.6666667         NA 2026-09-17 09:23:38
#>  35:   failed   7.777778  0.5555556         NA 2026-09-17 09:23:38
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-17 09:23:38
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-17 09:23:38
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-17 09:23:38
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-17 09:23:38
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-17 09:23:38
#>  41:   failed   5.555556  5.0000000         NA 2026-09-17 09:23:38
#>  42:   failed   5.555556  3.8888889         NA 2026-09-17 09:23:38
#>  43:   failed   5.555556  2.7777778         NA 2026-09-17 09:23:38
#>  44:   failed   5.555556  1.6666667         NA 2026-09-17 09:23:38
#>  45:   failed   5.555556  0.5555556         NA 2026-09-17 09:23:38
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-17 09:23:38
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-17 09:23:38
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-17 09:23:38
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-17 09:23:38
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-17 09:23:38
#>  51:   failed   3.333333  5.0000000         NA 2026-09-17 09:23:38
#>  52:   failed   3.333333  3.8888889         NA 2026-09-17 09:23:38
#>  53:   failed   3.333333  2.7777778         NA 2026-09-17 09:23:38
#>  54:   failed   3.333333  1.6666667         NA 2026-09-17 09:23:38
#>  55:   failed   3.333333  0.5555556         NA 2026-09-17 09:23:38
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-17 09:23:38
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-17 09:23:38
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-17 09:23:38
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-17 09:23:38
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-17 09:23:38
#>  61:   failed   1.111111  5.0000000         NA 2026-09-17 09:23:38
#>  62:   failed   1.111111  3.8888889         NA 2026-09-17 09:23:38
#>  63:   failed   1.111111  2.7777778         NA 2026-09-17 09:23:38
#>  64:   failed   1.111111  1.6666667         NA 2026-09-17 09:23:38
#>  65:   failed   1.111111  0.5555556         NA 2026-09-17 09:23:38
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-17 09:23:38
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-17 09:23:38
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-17 09:23:38
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-17 09:23:38
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-17 09:23:38
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-17 09:23:38
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-17 09:23:38
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-17 09:23:38
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-17 09:23:38
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-17 09:23:38
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-17 09:23:38
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-17 09:23:38
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-17 09:23:38
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-17 09:23:38
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-17 09:23:38
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-17 09:23:38
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-17 09:23:38
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-17 09:23:38
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-17 09:23:38
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-17 09:23:38
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-17 09:23:38
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-17 09:23:38
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-17 09:23:38
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-17 09:23:38
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-17 09:23:38
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-17 09:23:38
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-17 09:23:38
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-17 09:23:38
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-17 09:23:38
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-17 09:23:38
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-17 09:23:38
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-17 09:23:38
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-17 09:23:38
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-17 09:23:38
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-17 09:23:38
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>   2: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>   3: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>   4: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>   5: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>   6: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>   7: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>   8: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>   9: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>  10: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>  11: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>  12: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>  13: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>  14: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>  15: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>  16: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>  17: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>  18: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>  19: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
#>  20: sinking_raccoon_dc9f1fe9 2026-09-17 09:23:39
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
#>   1: 61c96ebf-8222-4d9f-83a7-f0baca2c81d4    [NULL]  -10.000000  -5.0000000
#>   2: a9f3beb9-5345-4238-9bd9-74f7394c3055    [NULL]  -10.000000  -3.8888889
#>   3: 244175a1-ad2a-48b3-b68c-f4fc15eb7c0c    [NULL]  -10.000000  -2.7777778
#>   4: ad3e31e3-8172-4364-9c31-aefd6c153744    [NULL]  -10.000000  -1.6666667
#>   5: 4c4e4281-4b97-4021-87b0-409d6ef0d531    [NULL]  -10.000000  -0.5555556
#>   6: 5d6dae7b-e718-426a-a79d-3efea98d83d8    [NULL]  -10.000000   0.5555556
#>   7: 352d6095-17be-4043-b05c-d641f719b8af    [NULL]  -10.000000   1.6666667
#>   8: 7eed506a-df3c-4309-97f8-7ecbdfaac619    [NULL]  -10.000000   2.7777778
#>   9: 4b2200ef-dfec-4790-8835-89974244daed    [NULL]  -10.000000   3.8888889
#>  10: d5d68c6a-1266-4b7c-9879-324144621f37    [NULL]  -10.000000   5.0000000
#>  11: 86a043f4-ec4b-4e0f-bc1b-3be0775c916a    [NULL]   -7.777778  -5.0000000
#>  12: 35b48750-cbc6-4ad8-8c50-6afc8f4e5015    [NULL]   -7.777778  -3.8888889
#>  13: 954be05f-103f-4bab-9682-48ec2ab9a41a    [NULL]   -7.777778  -2.7777778
#>  14: be4900bc-9b16-4d70-8170-9aa8af9d7c16    [NULL]   -7.777778  -1.6666667
#>  15: d67eb392-17f8-4182-ba0c-120e9aeb3619    [NULL]   -7.777778  -0.5555556
#>  16: d2373ac3-e1bb-460a-aeec-5d767435bfcf    [NULL]   -7.777778   0.5555556
#>  17: e5838cdd-338d-4f0d-981b-7e310a09af64    [NULL]   -7.777778   1.6666667
#>  18: a85c6d36-0a3f-4d6b-91b7-ef54c46d8026    [NULL]   -7.777778   2.7777778
#>  19: 52b3c661-a5fe-406f-8cb1-38475a77a7fa    [NULL]   -7.777778   3.8888889
#>  20: 21fdf251-5cb7-4cd8-8156-8373defa03a9    [NULL]   -7.777778   5.0000000
#>  21: 1a6bace0-354e-4f4b-8177-975fdc15095a <list[1]>          NA          NA
#>  22: 152c5552-0ec4-48c8-93ae-81b699cf4de2 <list[1]>          NA          NA
#>  23: 9e0609e7-7151-4581-9597-83b3515d982a <list[1]>          NA          NA
#>  24: ff80833b-01d1-4736-90ee-a8e01314fe97 <list[1]>          NA          NA
#>  25: 11ee107d-ecd8-402f-901c-2ccd9050622f <list[1]>          NA          NA
#>  26: e9dd2837-8a07-4982-a10a-edfdb9d6ec5d <list[1]>          NA          NA
#>  27: 5d097b78-8f2c-4e1f-a918-f287729d328f <list[1]>          NA          NA
#>  28: 8ea459f6-35d2-4eb6-ae51-a7001382255b <list[1]>          NA          NA
#>  29: d7026417-2300-4bd7-9a73-1c701009fb3f <list[1]>          NA          NA
#>  30: 19f0b6d8-cd4d-4020-b2eb-4f400896dfe2 <list[1]>          NA          NA
#>  31: 12db8cce-06b0-4847-8624-198356d29453 <list[1]>          NA          NA
#>  32: f08d4ee3-a09a-4908-9422-d1320aebe57b <list[1]>          NA          NA
#>  33: 5032bfdc-3391-4b74-a603-d9983588655b <list[1]>          NA          NA
#>  34: 1dccfb94-8bdb-4cd5-9c77-23d9da071931 <list[1]>          NA          NA
#>  35: 3b60165a-ab91-4cb2-b01c-ffcb4db187b2 <list[1]>          NA          NA
#>  36: 316c4722-b3cc-4a1c-badc-834342f2d8b0 <list[1]>          NA          NA
#>  37: 571ca23a-c18f-4c36-af49-6fcda3ac09a7 <list[1]>          NA          NA
#>  38: 3b830d75-7eb9-4fc6-ba46-ab48c986b3f4 <list[1]>          NA          NA
#>  39: b1ff38c2-c8d1-4a87-9f41-02a6e9a5ed5a <list[1]>          NA          NA
#>  40: 4d683e4c-50fd-4500-9b5f-5ba792949a70 <list[1]>          NA          NA
#>  41: 837c49c9-2a5c-4fe3-bccc-975315e88764 <list[1]>          NA          NA
#>  42: 5c7db38b-2028-4c36-9fc7-0774d286ec8f <list[1]>          NA          NA
#>  43: 5eae7598-e6a1-4d23-b381-5b2fff7994b0 <list[1]>          NA          NA
#>  44: 4e238fe8-05b5-494a-a4f5-cb6114e94c8a <list[1]>          NA          NA
#>  45: 9d08b4ae-8548-4723-b03d-e66a0d1398db <list[1]>          NA          NA
#>  46: 419e9098-5126-43f2-acc0-607772e7048a <list[1]>          NA          NA
#>  47: 57c226e2-0b85-4baa-a919-cdebfc7604e4 <list[1]>          NA          NA
#>  48: b63a854f-2d4a-444f-b078-952992cee8f5 <list[1]>          NA          NA
#>  49: 636af31c-951b-4d59-b810-14b57b095046 <list[1]>          NA          NA
#>  50: 5fb15433-296e-45fc-a7f1-bc250b144359 <list[1]>          NA          NA
#>  51: 01d80333-5e7a-46ec-ac83-f27a8f83b16d <list[1]>          NA          NA
#>  52: 95e36e1d-027d-4c97-999a-56d1de644c9d <list[1]>          NA          NA
#>  53: ce382d8f-c92d-4488-ac25-bf13c3b00e1d <list[1]>          NA          NA
#>  54: 4f278558-4632-4bd7-915b-7e6857b89d38 <list[1]>          NA          NA
#>  55: 662ab5a5-9b6a-4703-b239-c39329391ada <list[1]>          NA          NA
#>  56: 83c13587-318e-42f5-a9e6-09ee21dcec0f <list[1]>          NA          NA
#>  57: ac644d37-32d7-49a5-a2fc-1c4223c30044 <list[1]>          NA          NA
#>  58: ce4317d0-920c-47e1-b67b-8849b9035fd9 <list[1]>          NA          NA
#>  59: b482dd48-b85b-4514-803b-d0647c0a60aa <list[1]>          NA          NA
#>  60: 1f6244fb-a0ac-4903-9294-f1281767436f <list[1]>          NA          NA
#>  61: 67ab60ef-b23c-4b0e-a2d0-af1ff5e60a55 <list[1]>          NA          NA
#>  62: 557a7bf4-d370-40c3-b65a-fe0d654d90c4 <list[1]>          NA          NA
#>  63: 31101726-7c09-40e8-bd57-f3cb1a0911fe <list[1]>          NA          NA
#>  64: 0f4c57aa-a571-4464-bc8e-d85dfed42942 <list[1]>          NA          NA
#>  65: b0cac6c5-4c5e-4dd0-b3b1-1f432285b7ba <list[1]>          NA          NA
#>  66: 57412833-e555-4808-bc47-3148c5abb90e <list[1]>          NA          NA
#>  67: 12001cde-45a4-4705-a398-404395c986a5 <list[1]>          NA          NA
#>  68: 6324e449-ca2f-4124-bb81-394c42240af2 <list[1]>          NA          NA
#>  69: d3d740f9-ddb4-47f3-983b-946c81bd5a71 <list[1]>          NA          NA
#>  70: dd6d6311-70d6-41a8-87ec-348e80807624 <list[1]>          NA          NA
#>  71: 167e5d5e-e65f-45f6-b9c4-9633f2ee3710 <list[1]>          NA          NA
#>  72: 619938f2-3208-4735-8814-37ceed759f81 <list[1]>          NA          NA
#>  73: 6fc13ad6-864d-4369-bea1-74c525dcc3e3 <list[1]>          NA          NA
#>  74: b1ea6704-d550-4aea-97da-55090edd7c5d <list[1]>          NA          NA
#>  75: 9e5a0f78-ab98-4be6-b151-e14c8ef0af62 <list[1]>          NA          NA
#>  76: 0bef2bd8-cc97-410f-8a09-e66c6668b69a <list[1]>          NA          NA
#>  77: dbcf01ae-02b9-4517-bda6-a654082649ed <list[1]>          NA          NA
#>  78: dc0a5786-9206-4a60-8a56-4608e8bde46b <list[1]>          NA          NA
#>  79: 50aca29f-a851-42cb-9bed-851251a0f5fe <list[1]>          NA          NA
#>  80: 7b7cb0a1-8744-405c-9328-fb1ce881abd3 <list[1]>          NA          NA
#>  81: bcaab28a-665f-4c39-983b-5a3c95024558 <list[1]>          NA          NA
#>  82: 5bae9861-b037-4a9d-9f7b-393b32ea6ac2 <list[1]>          NA          NA
#>  83: 50bfa696-bcc0-4349-8663-9c7daae5299f <list[1]>          NA          NA
#>  84: fe823d0b-6064-49a0-b12d-29d1119a418b <list[1]>          NA          NA
#>  85: 0a0ee7a2-00a1-4bc8-8536-fb6d9f5ec390 <list[1]>          NA          NA
#>  86: 2e65bc5f-3fb0-4785-ad24-bd473c2817b1 <list[1]>          NA          NA
#>  87: 26ec8168-e9b4-4b81-be54-d40c23e4dde8 <list[1]>          NA          NA
#>  88: e6c48c2d-e2b9-4043-867e-498a5341f68a <list[1]>          NA          NA
#>  89: b6faa693-4f02-48f8-b41f-a6dbbc3892e8 <list[1]>          NA          NA
#>  90: cd341a35-4399-4761-913c-0a2a041ce459 <list[1]>          NA          NA
#>  91: 9d505298-d6d6-46ea-b59e-0e2be6043d23 <list[1]>          NA          NA
#>  92: 1f1938d8-f38f-4e0f-a2fd-099e315d0bea <list[1]>          NA          NA
#>  93: ddd50927-8726-413c-9187-a8e0d78d8f92 <list[1]>          NA          NA
#>  94: 5f2b2811-870f-42d8-8d70-75e83f44985e <list[1]>          NA          NA
#>  95: d4f6cfa0-d6c8-459f-9a4d-bbb55ba9492a <list[1]>          NA          NA
#>  96: 4155a91e-7c17-48f8-a46e-8dfffd4c572d <list[1]>          NA          NA
#>  97: 1ffef113-215c-4e9d-8e12-46324834fec8 <list[1]>          NA          NA
#>  98: 7d251e90-0c0b-410e-a1bb-2822b4fca3aa <list[1]>          NA          NA
#>  99: 7b69e7a8-bd6a-4b20-982b-1963164fd647 <list[1]>          NA          NA
#> 100: 921d70f3-625d-48df-8519-38c7f7078073 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
