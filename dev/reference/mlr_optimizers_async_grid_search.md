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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-17 09:50:16
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-17 09:50:16
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-17 09:50:16
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-17 09:50:16
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-17 09:50:16
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-17 09:50:16
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-17 09:50:16
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-17 09:50:16
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-17 09:50:16
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-17 09:50:16
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-17 09:50:16
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-17 09:50:16
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-17 09:50:16
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-17 09:50:16
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-17 09:50:16
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-17 09:50:16
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-17 09:50:16
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-17 09:50:16
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-17 09:50:16
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-17 09:50:16
#>  21:   failed  10.000000  5.0000000         NA 2026-09-17 09:50:16
#>  22:   failed  10.000000  3.8888889         NA 2026-09-17 09:50:16
#>  23:   failed  10.000000  2.7777778         NA 2026-09-17 09:50:16
#>  24:   failed  10.000000  1.6666667         NA 2026-09-17 09:50:16
#>  25:   failed  10.000000  0.5555556         NA 2026-09-17 09:50:16
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-17 09:50:16
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-17 09:50:16
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-17 09:50:16
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-17 09:50:16
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-17 09:50:16
#>  31:   failed   7.777778  5.0000000         NA 2026-09-17 09:50:16
#>  32:   failed   7.777778  3.8888889         NA 2026-09-17 09:50:16
#>  33:   failed   7.777778  2.7777778         NA 2026-09-17 09:50:16
#>  34:   failed   7.777778  1.6666667         NA 2026-09-17 09:50:16
#>  35:   failed   7.777778  0.5555556         NA 2026-09-17 09:50:16
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-17 09:50:16
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-17 09:50:16
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-17 09:50:16
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-17 09:50:16
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-17 09:50:16
#>  41:   failed   5.555556  5.0000000         NA 2026-09-17 09:50:16
#>  42:   failed   5.555556  3.8888889         NA 2026-09-17 09:50:16
#>  43:   failed   5.555556  2.7777778         NA 2026-09-17 09:50:16
#>  44:   failed   5.555556  1.6666667         NA 2026-09-17 09:50:16
#>  45:   failed   5.555556  0.5555556         NA 2026-09-17 09:50:16
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-17 09:50:16
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-17 09:50:16
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-17 09:50:16
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-17 09:50:16
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-17 09:50:16
#>  51:   failed   3.333333  5.0000000         NA 2026-09-17 09:50:16
#>  52:   failed   3.333333  3.8888889         NA 2026-09-17 09:50:16
#>  53:   failed   3.333333  2.7777778         NA 2026-09-17 09:50:16
#>  54:   failed   3.333333  1.6666667         NA 2026-09-17 09:50:16
#>  55:   failed   3.333333  0.5555556         NA 2026-09-17 09:50:16
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-17 09:50:16
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-17 09:50:16
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-17 09:50:16
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-17 09:50:16
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-17 09:50:16
#>  61:   failed   1.111111  5.0000000         NA 2026-09-17 09:50:16
#>  62:   failed   1.111111  3.8888889         NA 2026-09-17 09:50:16
#>  63:   failed   1.111111  2.7777778         NA 2026-09-17 09:50:16
#>  64:   failed   1.111111  1.6666667         NA 2026-09-17 09:50:16
#>  65:   failed   1.111111  0.5555556         NA 2026-09-17 09:50:16
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-17 09:50:16
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-17 09:50:16
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-17 09:50:16
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-17 09:50:16
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-17 09:50:16
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-17 09:50:16
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-17 09:50:16
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-17 09:50:16
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-17 09:50:16
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-17 09:50:16
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-17 09:50:16
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-17 09:50:16
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-17 09:50:16
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-17 09:50:16
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-17 09:50:16
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-17 09:50:16
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-17 09:50:16
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-17 09:50:16
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-17 09:50:16
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-17 09:50:16
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-17 09:50:16
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-17 09:50:16
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-17 09:50:16
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-17 09:50:16
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-17 09:50:16
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-17 09:50:16
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-17 09:50:16
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-17 09:50:16
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-17 09:50:16
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-17 09:50:16
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-17 09:50:16
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-17 09:50:16
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-17 09:50:16
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-17 09:50:16
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-17 09:50:16
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>   2: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>   3: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>   4: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>   5: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>   6: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>   7: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>   8: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>   9: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>  10: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>  11: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>  12: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>  13: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>  14: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>  15: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>  16: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>  17: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>  18: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>  19: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
#>  20: sinking_raccoon_241aa2c5 2026-09-17 09:50:17
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
#>   1: dde4454b-c832-4bd0-bb3e-650125029152    [NULL]  -10.000000  -5.0000000
#>   2: 26865316-a518-4799-9e1f-56904f54e03a    [NULL]  -10.000000  -3.8888889
#>   3: b3d34833-3552-4c33-94e7-7b6604f36e40    [NULL]  -10.000000  -2.7777778
#>   4: e9c268f5-f326-4dbc-b874-769affa2fe68    [NULL]  -10.000000  -1.6666667
#>   5: 6603b31e-c7e6-4507-9c7c-8b750f28f145    [NULL]  -10.000000  -0.5555556
#>   6: 85000ac7-072c-40f9-b2e7-8f382ee6bc22    [NULL]  -10.000000   0.5555556
#>   7: 54de28e6-291e-4374-bd9b-559b72629562    [NULL]  -10.000000   1.6666667
#>   8: de6159b5-5375-497c-93a8-523323dc04c7    [NULL]  -10.000000   2.7777778
#>   9: d925a87a-4072-4499-86b3-b83846866a1a    [NULL]  -10.000000   3.8888889
#>  10: 9ad179b8-bf93-482b-9dda-a3d7fe91c6b3    [NULL]  -10.000000   5.0000000
#>  11: a244afbd-fc1c-4b70-bd87-507e433559c8    [NULL]   -7.777778  -5.0000000
#>  12: 5b731125-475f-4036-b51b-0fc05ee41ad9    [NULL]   -7.777778  -3.8888889
#>  13: 1adf96a1-bf76-4cfb-b33e-a9200f53a5dd    [NULL]   -7.777778  -2.7777778
#>  14: cb367e7d-1a9f-4caf-b743-016d5b645e3d    [NULL]   -7.777778  -1.6666667
#>  15: cf20c36d-b51b-4c13-a07e-a494b2509d43    [NULL]   -7.777778  -0.5555556
#>  16: 0df04ba2-040d-4c74-b3dc-5f99ab6929df    [NULL]   -7.777778   0.5555556
#>  17: d3c6f17b-244e-4dd6-8100-f3d30c6e8917    [NULL]   -7.777778   1.6666667
#>  18: e60f8f95-2fe7-4dc4-9a70-0fd2b17f8e06    [NULL]   -7.777778   2.7777778
#>  19: 835c8ee8-4237-4161-a81b-24c1a995be3c    [NULL]   -7.777778   3.8888889
#>  20: 7edfcaf9-540f-417a-8f90-6a3f712ce9cc    [NULL]   -7.777778   5.0000000
#>  21: 9b02208a-134b-4f49-a7c4-3c36259cd3ec <list[1]>          NA          NA
#>  22: b004f280-35c5-45f5-855b-469b9b065b75 <list[1]>          NA          NA
#>  23: 893f39f8-0740-4916-b2fe-87728ee8e115 <list[1]>          NA          NA
#>  24: 803a0b59-4d52-4218-9393-3ab47b835032 <list[1]>          NA          NA
#>  25: ca3afda3-f1af-458c-b582-f3ecd493c40e <list[1]>          NA          NA
#>  26: 0693ae60-cf98-45b5-91cd-f2fdaeb7f3ae <list[1]>          NA          NA
#>  27: 6d6c0da7-0478-4973-a06e-9dfe77e50f85 <list[1]>          NA          NA
#>  28: dd1110af-f88d-4135-920b-09c89756bd42 <list[1]>          NA          NA
#>  29: 4006d87e-62ef-4da7-8e73-5906b0862087 <list[1]>          NA          NA
#>  30: 58e1fdf6-42d3-4e9e-8040-656806990572 <list[1]>          NA          NA
#>  31: 39881e40-0d30-4e94-a46c-c5b85220a884 <list[1]>          NA          NA
#>  32: f67d50f6-3f8d-4ff5-afb1-5f090ab96ae7 <list[1]>          NA          NA
#>  33: d82caacf-a36b-43eb-818e-fb4336524f87 <list[1]>          NA          NA
#>  34: e816b208-b4bc-4a2a-bedf-552fefcb13c4 <list[1]>          NA          NA
#>  35: f22167b7-02ee-4977-bb0f-3fa1c9477d90 <list[1]>          NA          NA
#>  36: 26f6e88d-a2e0-4542-b459-db88c92ddaa5 <list[1]>          NA          NA
#>  37: b7d86d9c-eca0-4c20-8da6-e355ffe64d66 <list[1]>          NA          NA
#>  38: b7e2180f-7466-46f8-9e97-b9de686fa220 <list[1]>          NA          NA
#>  39: 52417f8c-b298-4b76-b50f-25d2c970faa2 <list[1]>          NA          NA
#>  40: c2e92433-2346-4282-aa32-5cbea2d7bbb3 <list[1]>          NA          NA
#>  41: 2f383bf7-30cf-4160-a062-a4cc62d8a959 <list[1]>          NA          NA
#>  42: b3e354f3-0746-4b14-9f99-97ddc373b7a9 <list[1]>          NA          NA
#>  43: f671005f-738b-4db3-83c1-ed773a1f3b08 <list[1]>          NA          NA
#>  44: 56b5a719-1a8c-454c-95ab-f09de90284bf <list[1]>          NA          NA
#>  45: 7b82e6ba-552c-4d67-80e2-6071bcdc6fb8 <list[1]>          NA          NA
#>  46: 46a30c75-4f89-4111-a041-8e989cdf7416 <list[1]>          NA          NA
#>  47: a97728bb-a029-4e17-bb4e-7574f3d96911 <list[1]>          NA          NA
#>  48: 70d37efa-7e26-4425-a576-b25cb7d767dd <list[1]>          NA          NA
#>  49: 8a5b3d06-13b2-4ce8-9350-b095695aaa0f <list[1]>          NA          NA
#>  50: 2c8fc7f6-5fbf-4516-be58-71af3c771652 <list[1]>          NA          NA
#>  51: 9bcd965e-243a-48e7-a6e6-05eaf7b4f4f7 <list[1]>          NA          NA
#>  52: 2ca1054a-4093-46a5-acd1-253010115239 <list[1]>          NA          NA
#>  53: 29d00dc6-d5dc-4ff8-a174-07a5228a72af <list[1]>          NA          NA
#>  54: 53ba049e-9d34-456b-940d-4304cdde099b <list[1]>          NA          NA
#>  55: bfab2a32-0f1a-488e-8a8b-52a477dbc2c1 <list[1]>          NA          NA
#>  56: 8bccb27f-acfc-4581-a129-c5ee5fc9d553 <list[1]>          NA          NA
#>  57: 334eaa1a-6106-40a8-899a-69a8ed85bba7 <list[1]>          NA          NA
#>  58: 1c812f1f-a3e3-4fbc-8c80-dcf7699f719c <list[1]>          NA          NA
#>  59: 2b92a77a-c4fb-4737-83cf-b87c0ff51a3b <list[1]>          NA          NA
#>  60: 3a4a1fa1-47a9-4162-ac30-d1a21afacffb <list[1]>          NA          NA
#>  61: 08431155-eb5d-4304-86b4-e93a7e5553e8 <list[1]>          NA          NA
#>  62: 8eede42c-fe28-467a-b4f3-905fcf50a983 <list[1]>          NA          NA
#>  63: f61ef40b-69ca-43a3-b909-ac77510e08aa <list[1]>          NA          NA
#>  64: 31add4ca-4bd3-4a30-8503-5608fe29e3f5 <list[1]>          NA          NA
#>  65: 45670819-e156-448e-be6d-1e96614e7b1c <list[1]>          NA          NA
#>  66: d2bd9d6d-710d-4e79-a8e3-413f36a893cf <list[1]>          NA          NA
#>  67: 9b1cf46d-d188-4693-b3db-00a8e5a595f4 <list[1]>          NA          NA
#>  68: e2e214d1-20bd-4b29-b9ea-661e269e4e2e <list[1]>          NA          NA
#>  69: 7cf5df49-990e-4f77-9c3e-4798421c9e01 <list[1]>          NA          NA
#>  70: c37a8958-0229-45ad-8c48-32a52da40ea2 <list[1]>          NA          NA
#>  71: dcc9758e-f1b3-4efd-9373-fa00c8103bde <list[1]>          NA          NA
#>  72: 64bf83a7-c163-4d57-8670-45aa1df507e6 <list[1]>          NA          NA
#>  73: 70fdeb51-621f-44d8-a1cf-42109c6a47c5 <list[1]>          NA          NA
#>  74: f5509287-19df-450f-9bf0-4a9a56e2ebd4 <list[1]>          NA          NA
#>  75: bdb2d09c-0df1-4236-a682-9a75e7428d23 <list[1]>          NA          NA
#>  76: 8aaba8c4-a75e-42a3-9336-676a0fff96e6 <list[1]>          NA          NA
#>  77: 7a8a6dcd-dc64-483c-846a-982aacf91dd1 <list[1]>          NA          NA
#>  78: 546e98a4-ba72-42ba-8bde-33c2828ae329 <list[1]>          NA          NA
#>  79: a6d06517-f9d0-4b48-9f5e-ca2f1e543bc9 <list[1]>          NA          NA
#>  80: a5c3fff7-2fd5-4d72-b356-66639a7202b2 <list[1]>          NA          NA
#>  81: 8c71f34e-6981-41a5-98b0-c3a39a6a810f <list[1]>          NA          NA
#>  82: fdc80489-64cf-4af5-abe8-50dd950cdb41 <list[1]>          NA          NA
#>  83: 5c4c16c4-e6b1-4815-8476-b5c75a61f2d1 <list[1]>          NA          NA
#>  84: 126127cf-ec87-4423-8754-42dc5f594a20 <list[1]>          NA          NA
#>  85: 1b15ea42-3e97-4ce6-a737-778e91332fb3 <list[1]>          NA          NA
#>  86: a07aae9a-feca-420c-a7ec-59101fc7b06c <list[1]>          NA          NA
#>  87: 55b4c24b-6522-46bc-b7e8-94c6a892ea9b <list[1]>          NA          NA
#>  88: 9a6f2a32-76e5-4158-a3a4-1cbd8ca1df11 <list[1]>          NA          NA
#>  89: 4032658e-ca0c-4517-92cc-e5960667b9ea <list[1]>          NA          NA
#>  90: 7f345fbf-f085-492d-b520-c53d3781f041 <list[1]>          NA          NA
#>  91: 99921126-cd2b-4016-9580-bb0fb965184d <list[1]>          NA          NA
#>  92: 9e724683-638f-4680-9f1d-76ec3ed37064 <list[1]>          NA          NA
#>  93: 35fabfd2-ce01-47af-8004-4a0d7e154e25 <list[1]>          NA          NA
#>  94: 57344726-7981-4ec9-ade4-403ddfd9e53a <list[1]>          NA          NA
#>  95: 110a9ac9-4d5d-4c10-babe-665dffa3cb6d <list[1]>          NA          NA
#>  96: e21773dd-62a8-433f-8474-09125dbe4ea5 <list[1]>          NA          NA
#>  97: d4b4d39c-6cb9-4058-a14a-2cbb0b49208f <list[1]>          NA          NA
#>  98: 83d76325-6cc9-442b-ba96-880e1d9dcd80 <list[1]>          NA          NA
#>  99: 60f35365-7090-4385-8323-1c05be6ac4c3 <list[1]>          NA          NA
#> 100: fa4d7989-3aa8-45e2-b68c-6ccc614f3aac <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
