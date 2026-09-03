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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-03 11:02:55
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-03 11:02:55
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-03 11:02:55
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-03 11:02:55
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-03 11:02:55
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-03 11:02:55
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-03 11:02:55
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-03 11:02:55
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-03 11:02:55
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-03 11:02:55
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-03 11:02:55
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-03 11:02:55
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-03 11:02:55
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-03 11:02:55
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-03 11:02:55
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-03 11:02:55
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-03 11:02:55
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-03 11:02:55
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-03 11:02:55
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-03 11:02:55
#>  21:   failed  10.000000  5.0000000         NA 2026-09-03 11:02:55
#>  22:   failed  10.000000  3.8888889         NA 2026-09-03 11:02:55
#>  23:   failed  10.000000  2.7777778         NA 2026-09-03 11:02:55
#>  24:   failed  10.000000  1.6666667         NA 2026-09-03 11:02:55
#>  25:   failed  10.000000  0.5555556         NA 2026-09-03 11:02:55
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-03 11:02:55
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-03 11:02:55
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-03 11:02:55
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-03 11:02:55
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-03 11:02:55
#>  31:   failed   7.777778  5.0000000         NA 2026-09-03 11:02:55
#>  32:   failed   7.777778  3.8888889         NA 2026-09-03 11:02:55
#>  33:   failed   7.777778  2.7777778         NA 2026-09-03 11:02:55
#>  34:   failed   7.777778  1.6666667         NA 2026-09-03 11:02:55
#>  35:   failed   7.777778  0.5555556         NA 2026-09-03 11:02:55
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-03 11:02:55
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-03 11:02:55
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-03 11:02:55
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-03 11:02:55
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-03 11:02:55
#>  41:   failed   5.555556  5.0000000         NA 2026-09-03 11:02:55
#>  42:   failed   5.555556  3.8888889         NA 2026-09-03 11:02:55
#>  43:   failed   5.555556  2.7777778         NA 2026-09-03 11:02:55
#>  44:   failed   5.555556  1.6666667         NA 2026-09-03 11:02:55
#>  45:   failed   5.555556  0.5555556         NA 2026-09-03 11:02:55
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-03 11:02:55
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-03 11:02:55
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-03 11:02:55
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-03 11:02:55
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-03 11:02:55
#>  51:   failed   3.333333  5.0000000         NA 2026-09-03 11:02:55
#>  52:   failed   3.333333  3.8888889         NA 2026-09-03 11:02:55
#>  53:   failed   3.333333  2.7777778         NA 2026-09-03 11:02:55
#>  54:   failed   3.333333  1.6666667         NA 2026-09-03 11:02:55
#>  55:   failed   3.333333  0.5555556         NA 2026-09-03 11:02:55
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-03 11:02:55
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-03 11:02:55
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-03 11:02:55
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-03 11:02:55
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-03 11:02:55
#>  61:   failed   1.111111  5.0000000         NA 2026-09-03 11:02:55
#>  62:   failed   1.111111  3.8888889         NA 2026-09-03 11:02:55
#>  63:   failed   1.111111  2.7777778         NA 2026-09-03 11:02:55
#>  64:   failed   1.111111  1.6666667         NA 2026-09-03 11:02:55
#>  65:   failed   1.111111  0.5555556         NA 2026-09-03 11:02:55
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-03 11:02:55
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-03 11:02:55
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-03 11:02:55
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-03 11:02:55
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-03 11:02:55
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-03 11:02:55
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-03 11:02:55
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-03 11:02:55
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-03 11:02:55
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-03 11:02:55
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-03 11:02:55
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-03 11:02:55
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-03 11:02:55
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-03 11:02:55
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-03 11:02:55
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-03 11:02:55
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-03 11:02:55
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-03 11:02:55
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-03 11:02:55
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-03 11:02:55
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-03 11:02:55
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-03 11:02:55
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-03 11:02:55
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-03 11:02:55
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-03 11:02:55
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-03 11:02:55
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-03 11:02:55
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-03 11:02:55
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-03 11:02:55
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-03 11:02:55
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-03 11:02:55
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-03 11:02:55
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-03 11:02:55
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-03 11:02:55
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-03 11:02:55
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>   2: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>   3: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>   4: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>   5: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>   6: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>   7: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>   8: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>   9: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>  10: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>  11: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>  12: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>  13: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>  14: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>  15: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>  16: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>  17: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>  18: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>  19: sinking_raccoon_a0730408 2026-09-03 11:02:56
#>  20: sinking_raccoon_a0730408 2026-09-03 11:02:56
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
#>   1: dbd48a9a-b6c5-42db-bb68-86a85de693c1    [NULL]  -10.000000  -5.0000000
#>   2: 86c4b414-1f75-42fa-8660-aff91aeb6a82    [NULL]  -10.000000  -3.8888889
#>   3: 56658bf0-3cff-40c2-a24d-2dc1ac7f6547    [NULL]  -10.000000  -2.7777778
#>   4: 722f6169-139f-4b6a-a2b4-88e7bc3ace49    [NULL]  -10.000000  -1.6666667
#>   5: c580339d-9396-489f-9641-e0f2a5a60d69    [NULL]  -10.000000  -0.5555556
#>   6: 30149cf0-e621-4e62-b95a-926850c4a3d5    [NULL]  -10.000000   0.5555556
#>   7: 0634d58f-6e6c-4c50-9814-20c37e7d3a53    [NULL]  -10.000000   1.6666667
#>   8: 42e27a91-d5d9-44ef-bd49-403a4ddb2dab    [NULL]  -10.000000   2.7777778
#>   9: 5cd4341d-9544-412a-91cd-293af0eecc1f    [NULL]  -10.000000   3.8888889
#>  10: 5ff60a5d-e895-4d8f-9ae8-edc9adf5e108    [NULL]  -10.000000   5.0000000
#>  11: 957d1c0e-4ecf-45a2-9e6d-e856cb03941d    [NULL]   -7.777778  -5.0000000
#>  12: c6f75f3f-64fd-4e14-8b0c-f4cf90514151    [NULL]   -7.777778  -3.8888889
#>  13: 3f920b09-77f4-40b1-b494-0c8726332be4    [NULL]   -7.777778  -2.7777778
#>  14: b24b5bd4-5dc5-4e4c-9326-cda691ca701c    [NULL]   -7.777778  -1.6666667
#>  15: d9a97108-ea4e-493c-9e8b-a65142107db8    [NULL]   -7.777778  -0.5555556
#>  16: 7ac0d127-7568-4f8f-87b7-854db54b44b8    [NULL]   -7.777778   0.5555556
#>  17: 26ce7ca9-a729-43e1-9bcf-c43ba9f4ce6f    [NULL]   -7.777778   1.6666667
#>  18: 747d634b-a246-40c7-ab74-41d824f8a637    [NULL]   -7.777778   2.7777778
#>  19: 7996f9e4-651a-43de-8593-0189e3ca4adc    [NULL]   -7.777778   3.8888889
#>  20: b849c6f6-c14b-4103-8fc6-4b8cb3329e89    [NULL]   -7.777778   5.0000000
#>  21: 1ebfd4d3-3e2c-423d-8aef-3b022541ecf4 <list[1]>          NA          NA
#>  22: 43b019ed-a33f-43fa-a116-431d04017200 <list[1]>          NA          NA
#>  23: 65649c4d-1b38-4cd3-908f-844114e1ef86 <list[1]>          NA          NA
#>  24: e4fa76db-593d-4d7e-bfeb-7db7a0cff0f1 <list[1]>          NA          NA
#>  25: 55f4d572-403c-4432-a8f0-5b4b3d8543d0 <list[1]>          NA          NA
#>  26: 83d2203f-6b74-4ab7-be7b-e8b0a360b51a <list[1]>          NA          NA
#>  27: 01d6737e-26d4-4b6f-aa94-9bfb5da15ca8 <list[1]>          NA          NA
#>  28: 5a8ea6a3-8adb-40e1-8205-c0ae57645073 <list[1]>          NA          NA
#>  29: bcf585fe-dc49-4d51-a100-cdcf9e732386 <list[1]>          NA          NA
#>  30: 96542302-63d1-495a-966b-5062d5d2b746 <list[1]>          NA          NA
#>  31: 4a1b4668-cb06-44a3-bc49-f005284fa6f9 <list[1]>          NA          NA
#>  32: 565de571-2185-4324-9a8d-492e7a9d68f0 <list[1]>          NA          NA
#>  33: 7fb8ccf7-e076-4e6b-9565-af82bda60d94 <list[1]>          NA          NA
#>  34: c864e7b1-3a1c-45f5-a8b2-56ee09683ac1 <list[1]>          NA          NA
#>  35: dfd1bae2-e996-406d-bd54-fd4510cbbbd3 <list[1]>          NA          NA
#>  36: dc638e21-be22-49cc-8c7a-24b728480bfe <list[1]>          NA          NA
#>  37: 153137a5-51d3-4899-b4d7-9850e1b2698d <list[1]>          NA          NA
#>  38: c1b2f93a-e897-42ae-a5ac-9febd831e205 <list[1]>          NA          NA
#>  39: 02009901-34f0-4710-a1da-837549674b7c <list[1]>          NA          NA
#>  40: 33ee5f41-bdf7-4ef1-a7ea-88c35c643bd6 <list[1]>          NA          NA
#>  41: b3f7a44f-c10d-49ad-9aeb-823b723db743 <list[1]>          NA          NA
#>  42: 14153116-af1f-49e3-a485-0de8c504c425 <list[1]>          NA          NA
#>  43: 8fe17f0e-3aa5-46b0-8d88-4f3f090f888f <list[1]>          NA          NA
#>  44: c6f400fd-34e2-4e0e-a2b3-e85731aa7d14 <list[1]>          NA          NA
#>  45: b701f8f5-3af7-4bbd-bfbb-5aa7e88496bf <list[1]>          NA          NA
#>  46: 8dab3c01-bf83-4162-98d7-11d006cb6da3 <list[1]>          NA          NA
#>  47: 8a7070a6-ab51-415d-a987-51a366449595 <list[1]>          NA          NA
#>  48: f0f3515a-8a3b-4599-9792-ff3266c06559 <list[1]>          NA          NA
#>  49: 073b877f-24fc-4a15-8251-d7aebd21b334 <list[1]>          NA          NA
#>  50: 55296c58-3070-48df-b803-151cd70a19aa <list[1]>          NA          NA
#>  51: 2a0c5c8f-a0b7-487f-a7a4-88ea41303611 <list[1]>          NA          NA
#>  52: 37a57458-665d-4b5c-8516-6028cedcfdc0 <list[1]>          NA          NA
#>  53: 8f836037-a8dc-47dc-9d34-d73d176beae8 <list[1]>          NA          NA
#>  54: 130a383d-aa91-4c76-b210-8f6e0815f9e1 <list[1]>          NA          NA
#>  55: 88f34ce0-84ae-4ab2-bdd2-570d2b1a4973 <list[1]>          NA          NA
#>  56: 409dc322-6a75-4de8-ba0b-112b0c9b326d <list[1]>          NA          NA
#>  57: e01f1507-ec96-4525-afab-1b8965bf72e8 <list[1]>          NA          NA
#>  58: e4d5997d-ba8a-4c49-962b-90f8f1285361 <list[1]>          NA          NA
#>  59: 638b6234-ced1-4864-a739-7655bad53798 <list[1]>          NA          NA
#>  60: d18b5b35-95b8-4c0f-9016-09756ce86941 <list[1]>          NA          NA
#>  61: 04a01f99-5240-4c90-abef-b16855c6bd9a <list[1]>          NA          NA
#>  62: ccb69b47-9b69-4929-ba75-6b9e62996e5b <list[1]>          NA          NA
#>  63: c795aec7-368c-4e34-86e8-d1cc1760d253 <list[1]>          NA          NA
#>  64: 2889ac43-65b7-4412-9e36-b274257b7f90 <list[1]>          NA          NA
#>  65: b67fe0cd-16cb-4517-ad5a-4a223b078f7e <list[1]>          NA          NA
#>  66: a53518aa-7c8e-43d4-b63b-780573fa9711 <list[1]>          NA          NA
#>  67: 9bd3737a-ebfa-4087-8fa1-1bf4a3d3f87b <list[1]>          NA          NA
#>  68: b68a8302-2e7a-4827-b28b-5e33b056d0dd <list[1]>          NA          NA
#>  69: 3293804e-b2b4-4fca-b497-db4fd96c3735 <list[1]>          NA          NA
#>  70: 89e9fcc0-c55d-4f19-a8bf-bf20d7bd820f <list[1]>          NA          NA
#>  71: eb801105-cb8f-4800-b852-8320a01e2b00 <list[1]>          NA          NA
#>  72: 3a7ec982-4e56-4fc3-90ea-065e91a615cd <list[1]>          NA          NA
#>  73: ef6f927f-a4b7-4c69-9f1a-db9c83a0317c <list[1]>          NA          NA
#>  74: 21a14738-2a61-4d58-9cc6-f0f546488aa7 <list[1]>          NA          NA
#>  75: 8a3d3f5c-37f0-41ca-96e5-6067e6bb51cf <list[1]>          NA          NA
#>  76: 41561ccf-b457-4b70-b74e-c20f40064be0 <list[1]>          NA          NA
#>  77: 720cbdef-667c-49b3-b95b-e8d2af54e78a <list[1]>          NA          NA
#>  78: 69bd1d8d-98c5-4f52-bef2-d6f39f299b86 <list[1]>          NA          NA
#>  79: 5384d3d8-5232-4e42-9dc6-a9cf803562c6 <list[1]>          NA          NA
#>  80: ac0ece61-4adb-4ba8-9dc7-2a6759d5698d <list[1]>          NA          NA
#>  81: beaa34fe-d971-4b2d-8760-0f78763cbb22 <list[1]>          NA          NA
#>  82: d807aae0-2f5c-4327-8e5a-a465faddffec <list[1]>          NA          NA
#>  83: 76ca7c5c-c368-4cd6-b51c-995ba8b85289 <list[1]>          NA          NA
#>  84: 26cd2325-409d-44a8-be5b-58345d722604 <list[1]>          NA          NA
#>  85: 9e681830-f6c7-419e-bd37-ee67257633e3 <list[1]>          NA          NA
#>  86: 203adba0-810f-4dbf-b94b-049f131f09b4 <list[1]>          NA          NA
#>  87: 6550f967-e1b2-49cd-b409-f42996f6efdd <list[1]>          NA          NA
#>  88: 0b49ae4e-34f9-4446-b46c-4dea0f417bee <list[1]>          NA          NA
#>  89: cb4638aa-8533-453e-bbd5-44f8984e4fc1 <list[1]>          NA          NA
#>  90: 61305771-1afd-4ca4-aad7-7dab9f12a792 <list[1]>          NA          NA
#>  91: 9bad88d1-99c1-4a2b-b594-fbd27882535d <list[1]>          NA          NA
#>  92: 318675b4-81f0-404d-bb7f-2055c496468e <list[1]>          NA          NA
#>  93: 0ce89cb3-3a8c-48b9-85b7-1bf9f190589f <list[1]>          NA          NA
#>  94: 99319d04-20ee-466a-8c28-2faae70036ae <list[1]>          NA          NA
#>  95: 50293166-287e-4dcb-a460-2c1a919bc3da <list[1]>          NA          NA
#>  96: ed52f03d-b759-4a17-b51c-c98d556e0f6f <list[1]>          NA          NA
#>  97: f90740d7-d89d-473d-b70e-a92c8412e321 <list[1]>          NA          NA
#>  98: 5bd345ed-b207-4919-a855-68f5346da151 <list[1]>          NA          NA
#>  99: cbecb753-8311-4ec7-b6bc-0d9db4650263 <list[1]>          NA          NA
#> 100: ebafd020-4449-4f71-b6ae-571e6bddb999 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
