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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-17 09:13:46
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-17 09:13:46
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-17 09:13:46
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-17 09:13:46
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-17 09:13:46
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-17 09:13:46
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-17 09:13:46
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-17 09:13:46
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-17 09:13:46
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-17 09:13:46
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-17 09:13:46
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-17 09:13:46
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-17 09:13:46
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-17 09:13:46
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-17 09:13:46
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-17 09:13:46
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-17 09:13:46
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-17 09:13:46
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-17 09:13:46
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-17 09:13:46
#>  21:   failed  10.000000  5.0000000         NA 2026-09-17 09:13:46
#>  22:   failed  10.000000  3.8888889         NA 2026-09-17 09:13:46
#>  23:   failed  10.000000  2.7777778         NA 2026-09-17 09:13:46
#>  24:   failed  10.000000  1.6666667         NA 2026-09-17 09:13:46
#>  25:   failed  10.000000  0.5555556         NA 2026-09-17 09:13:46
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-17 09:13:46
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-17 09:13:46
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-17 09:13:46
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-17 09:13:46
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-17 09:13:46
#>  31:   failed   7.777778  5.0000000         NA 2026-09-17 09:13:46
#>  32:   failed   7.777778  3.8888889         NA 2026-09-17 09:13:46
#>  33:   failed   7.777778  2.7777778         NA 2026-09-17 09:13:46
#>  34:   failed   7.777778  1.6666667         NA 2026-09-17 09:13:46
#>  35:   failed   7.777778  0.5555556         NA 2026-09-17 09:13:46
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-17 09:13:46
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-17 09:13:46
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-17 09:13:46
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-17 09:13:46
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-17 09:13:46
#>  41:   failed   5.555556  5.0000000         NA 2026-09-17 09:13:46
#>  42:   failed   5.555556  3.8888889         NA 2026-09-17 09:13:46
#>  43:   failed   5.555556  2.7777778         NA 2026-09-17 09:13:46
#>  44:   failed   5.555556  1.6666667         NA 2026-09-17 09:13:46
#>  45:   failed   5.555556  0.5555556         NA 2026-09-17 09:13:46
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-17 09:13:46
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-17 09:13:46
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-17 09:13:46
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-17 09:13:46
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-17 09:13:46
#>  51:   failed   3.333333  5.0000000         NA 2026-09-17 09:13:46
#>  52:   failed   3.333333  3.8888889         NA 2026-09-17 09:13:46
#>  53:   failed   3.333333  2.7777778         NA 2026-09-17 09:13:46
#>  54:   failed   3.333333  1.6666667         NA 2026-09-17 09:13:46
#>  55:   failed   3.333333  0.5555556         NA 2026-09-17 09:13:46
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-17 09:13:46
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-17 09:13:46
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-17 09:13:46
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-17 09:13:46
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-17 09:13:46
#>  61:   failed   1.111111  5.0000000         NA 2026-09-17 09:13:46
#>  62:   failed   1.111111  3.8888889         NA 2026-09-17 09:13:46
#>  63:   failed   1.111111  2.7777778         NA 2026-09-17 09:13:46
#>  64:   failed   1.111111  1.6666667         NA 2026-09-17 09:13:46
#>  65:   failed   1.111111  0.5555556         NA 2026-09-17 09:13:46
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-17 09:13:46
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-17 09:13:46
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-17 09:13:46
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-17 09:13:46
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-17 09:13:46
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-17 09:13:46
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-17 09:13:46
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-17 09:13:46
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-17 09:13:46
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-17 09:13:46
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-17 09:13:46
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-17 09:13:46
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-17 09:13:46
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-17 09:13:46
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-17 09:13:46
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-17 09:13:46
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-17 09:13:46
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-17 09:13:46
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-17 09:13:46
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-17 09:13:46
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-17 09:13:46
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-17 09:13:46
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-17 09:13:46
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-17 09:13:46
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-17 09:13:46
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-17 09:13:46
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-17 09:13:46
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-17 09:13:46
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-17 09:13:46
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-17 09:13:46
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-17 09:13:46
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-17 09:13:46
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-17 09:13:46
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-17 09:13:46
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-17 09:13:46
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>   2: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>   3: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>   4: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>   5: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>   6: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>   7: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>   8: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>   9: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>  10: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>  11: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>  12: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>  13: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>  14: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>  15: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>  16: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>  17: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>  18: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>  19: sinking_raccoon_33829c3a 2026-09-17 09:13:47
#>  20: sinking_raccoon_33829c3a 2026-09-17 09:13:47
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
#>   1: 1d2c9b9b-e3cb-438f-9641-995af24da6c4    [NULL]  -10.000000  -5.0000000
#>   2: f5cbcc13-5dda-4573-922e-63d8e265dc87    [NULL]  -10.000000  -3.8888889
#>   3: 62249c40-91be-4fae-955a-7cdfe647c7aa    [NULL]  -10.000000  -2.7777778
#>   4: db717632-66b4-4836-a4ed-677db5fe2fbd    [NULL]  -10.000000  -1.6666667
#>   5: 3bb6c5fb-c860-4654-9f3b-3c6fff7dc8a5    [NULL]  -10.000000  -0.5555556
#>   6: ed050a31-d4c0-46a3-9bdc-f55681d49a1d    [NULL]  -10.000000   0.5555556
#>   7: ad463dd6-0cb3-498b-b2b5-c17890c917de    [NULL]  -10.000000   1.6666667
#>   8: 1df7c8e0-d6a6-4378-881c-aeadfebacb0d    [NULL]  -10.000000   2.7777778
#>   9: ecebdde6-31d5-44de-9c60-a15671e62f6d    [NULL]  -10.000000   3.8888889
#>  10: a4471107-d648-4b48-b7aa-27406c998b4f    [NULL]  -10.000000   5.0000000
#>  11: 876a14f6-aef2-4edf-b16f-15b21a1846b8    [NULL]   -7.777778  -5.0000000
#>  12: c2f03b56-c94f-4936-bbb0-43087405d67e    [NULL]   -7.777778  -3.8888889
#>  13: ac0cf2f3-2148-40c1-895b-2225acb9dcf6    [NULL]   -7.777778  -2.7777778
#>  14: f7402446-6024-478c-a750-ce1626f0197b    [NULL]   -7.777778  -1.6666667
#>  15: 67981114-2c1d-45bf-9f3d-174dbdd135c7    [NULL]   -7.777778  -0.5555556
#>  16: ac56f2d2-3f58-4a69-bccd-bb44bb57d604    [NULL]   -7.777778   0.5555556
#>  17: 3ed394bd-c535-4369-89aa-f1b9d32d5824    [NULL]   -7.777778   1.6666667
#>  18: 6fba5a0b-29c8-4c43-884e-0b68746836d8    [NULL]   -7.777778   2.7777778
#>  19: 372bea69-4bdc-4a6b-8e9c-1ddf927dacdc    [NULL]   -7.777778   3.8888889
#>  20: 538dbf7e-1991-4cbb-aa71-889e8d0c6792    [NULL]   -7.777778   5.0000000
#>  21: 651f096b-db5a-49c0-90b3-dbe071f399bd <list[1]>          NA          NA
#>  22: c9e6dbc1-47ed-428a-9af1-e87f2153a992 <list[1]>          NA          NA
#>  23: 59e099eb-34f9-4608-bb8d-32a1eb0a696a <list[1]>          NA          NA
#>  24: e2d03e70-32b6-4800-b032-e1e64b20e424 <list[1]>          NA          NA
#>  25: d85ce841-9b0a-4373-b4e0-6eb645caaed6 <list[1]>          NA          NA
#>  26: c7732c44-cfb3-447c-9861-45826e0d458d <list[1]>          NA          NA
#>  27: cd2bd5b8-ebd7-4b14-bd12-74f5a820c00e <list[1]>          NA          NA
#>  28: c08b8e38-b857-47da-96b6-d1e31edea71a <list[1]>          NA          NA
#>  29: 3a71a013-c83c-457d-b557-4f31e044d6ae <list[1]>          NA          NA
#>  30: d9f5f28b-10c6-484e-ab68-388fef3e87b5 <list[1]>          NA          NA
#>  31: 2c4d4f5c-13af-404b-b97b-18e561550194 <list[1]>          NA          NA
#>  32: 9d688a15-8bfd-4037-a985-e08b734aecb8 <list[1]>          NA          NA
#>  33: 609e73a6-9407-4f71-953e-bc0961b671da <list[1]>          NA          NA
#>  34: b307588e-31ed-4390-8631-7cd869b53f98 <list[1]>          NA          NA
#>  35: f19d1c44-3508-4d5c-90c8-cbb58da1bda0 <list[1]>          NA          NA
#>  36: 4eac79e7-ce0c-4ebe-90b6-c807337d1f1e <list[1]>          NA          NA
#>  37: 91d6470e-dfbc-41ad-bb23-319ef247bafe <list[1]>          NA          NA
#>  38: 7a6c917b-3ef4-40c5-9e89-7b7145f83fb0 <list[1]>          NA          NA
#>  39: 0dc67664-3271-4324-b61a-3d3350ba0fff <list[1]>          NA          NA
#>  40: a9fa3c85-0fb4-4de2-966a-7744f619fbf9 <list[1]>          NA          NA
#>  41: ed33394c-c50f-4918-854d-88fd595d594a <list[1]>          NA          NA
#>  42: 3e71d8a6-818f-43ba-8e03-66734d84237d <list[1]>          NA          NA
#>  43: 1029f0ad-0227-4618-86e4-9f4010841e38 <list[1]>          NA          NA
#>  44: 6b88e24f-e006-49e8-9882-1017e1c9a14b <list[1]>          NA          NA
#>  45: 781753b7-be0c-400a-9722-5da44c776018 <list[1]>          NA          NA
#>  46: b056db4d-eea3-44fb-86ac-09f2bcb8ed91 <list[1]>          NA          NA
#>  47: 7c1dc022-5b49-4b1a-804a-81faad7056eb <list[1]>          NA          NA
#>  48: 900ed334-0337-49c1-91ef-51d06047fe6e <list[1]>          NA          NA
#>  49: ed8b8e8d-22c3-4749-9735-7bc9b748d229 <list[1]>          NA          NA
#>  50: dcd7ef17-2091-4f57-80ad-e8315bab84e3 <list[1]>          NA          NA
#>  51: 3c85c447-bc3d-4bf8-812c-9ca2b55b99ab <list[1]>          NA          NA
#>  52: 6bb97ba5-4f17-4183-acdb-8cfdd9de16a6 <list[1]>          NA          NA
#>  53: 7c7638c2-fbdb-4d1e-ad64-b784344dccb7 <list[1]>          NA          NA
#>  54: 9f30ac33-b8b1-4670-871a-2ed23d3ffcae <list[1]>          NA          NA
#>  55: fcca5fd5-df8e-44c6-8fe6-761bd7dbb12c <list[1]>          NA          NA
#>  56: c1022088-d141-4598-b296-9e5552b868c3 <list[1]>          NA          NA
#>  57: cf993cee-ed4e-4bdf-949d-e93706d5a14b <list[1]>          NA          NA
#>  58: 112e97f2-8297-404e-95a1-c26ff3d735d9 <list[1]>          NA          NA
#>  59: 11765992-a7a2-4500-8f32-f437a0d0cf75 <list[1]>          NA          NA
#>  60: 36cc1899-d2c5-49ab-91a5-4de330ac1347 <list[1]>          NA          NA
#>  61: 1c86d9bc-44d1-44cd-a4cc-b7524497dca0 <list[1]>          NA          NA
#>  62: 56a9231d-b607-47fa-81e6-bc486d788ec3 <list[1]>          NA          NA
#>  63: 63ff0232-77f4-41ab-b047-fc50ffccb5c9 <list[1]>          NA          NA
#>  64: ec186bd5-a882-418f-b0fb-4a70be181262 <list[1]>          NA          NA
#>  65: e0e1e6bb-d9dc-4405-8d4f-37e252feb19b <list[1]>          NA          NA
#>  66: d4bd75c9-a8e4-41b0-8188-fe814ad493cd <list[1]>          NA          NA
#>  67: 4b0c3c98-3c94-43ba-951a-bb9788040fdc <list[1]>          NA          NA
#>  68: 3e689ea0-7005-4d7e-95bf-447074738e74 <list[1]>          NA          NA
#>  69: 196fa3c0-c38b-4c99-8880-5b7e460af5bd <list[1]>          NA          NA
#>  70: b861ba4f-f07e-43ec-9da1-41d743fb802b <list[1]>          NA          NA
#>  71: 765ab7b1-b796-4bdb-8255-6b0ca763779d <list[1]>          NA          NA
#>  72: d2fd3977-5516-4e35-830d-f5b175de2948 <list[1]>          NA          NA
#>  73: 25e9ba27-18da-4b31-9a36-0ad9c75a8e3f <list[1]>          NA          NA
#>  74: c174d0e2-5c68-40bb-81be-bd2cd98a69fb <list[1]>          NA          NA
#>  75: 0e5e6935-c620-47fd-8ebc-dc255c3b6858 <list[1]>          NA          NA
#>  76: 8215cf5b-83b6-41ee-834b-4275e50642e3 <list[1]>          NA          NA
#>  77: 6c783749-4589-4c28-b8ce-8c41ec5a5de7 <list[1]>          NA          NA
#>  78: 6bf7f2b8-5fc0-4215-92a6-a8c546e3f7e0 <list[1]>          NA          NA
#>  79: ba05e522-5de0-4627-b449-51a664e3efab <list[1]>          NA          NA
#>  80: 95ea3eb6-9f7d-49d6-8301-802641cb969e <list[1]>          NA          NA
#>  81: 310d4f12-98a2-4e8d-a484-5db5e179e5a3 <list[1]>          NA          NA
#>  82: 3f2dcb01-abd7-4611-a58a-92fba6062c4f <list[1]>          NA          NA
#>  83: e93c7edd-dc13-4784-9b7f-c52c8a877ac8 <list[1]>          NA          NA
#>  84: 0973b41f-41ca-4c80-b826-64c014381d03 <list[1]>          NA          NA
#>  85: fbe86b80-ed25-4449-8bd5-f76592176215 <list[1]>          NA          NA
#>  86: f513318e-5eea-468a-aa1c-7d0a73291032 <list[1]>          NA          NA
#>  87: 41ee8de0-20c7-4a65-88b3-72af1bf9e993 <list[1]>          NA          NA
#>  88: 9337336c-445f-45a7-aa9e-2ddf0fb677ac <list[1]>          NA          NA
#>  89: 9e7a0296-d698-4c5a-98e2-58eca7ea99a7 <list[1]>          NA          NA
#>  90: 32d2f8f2-f097-496b-af00-866562d2c49e <list[1]>          NA          NA
#>  91: 12c31b65-d974-4fc2-8af6-c841fd763230 <list[1]>          NA          NA
#>  92: e5c00f58-43a4-4730-902b-a484b00dc851 <list[1]>          NA          NA
#>  93: a833399c-f10e-4120-869d-a861d452d38b <list[1]>          NA          NA
#>  94: 9441a967-67f8-4f1a-a451-821519836209 <list[1]>          NA          NA
#>  95: afb26ff5-6568-4074-9e79-151d1daa32a3 <list[1]>          NA          NA
#>  96: f0ee5ee0-915f-4668-b0ad-7093ce1a0814 <list[1]>          NA          NA
#>  97: 9f684031-e800-42b5-85f8-9cfce736bd8a <list[1]>          NA          NA
#>  98: 6d4f028d-06bd-4f1c-a30c-d7be0f42f1a2 <list[1]>          NA          NA
#>  99: 0a2a24c1-ac38-4102-ac4b-1fe3ad924436 <list[1]>          NA          NA
#> 100: 5da3f10a-64ca-4c46-94d0-c095b847b962 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
