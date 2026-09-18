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

This [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md) can
be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/reference/opt.md):

    mlr_optimizers$get("async_grid_search")
    opt("async_grid_search")

## Parameters

- `batch_size`:

  `integer(1)`  
  Maximum number of points to try in a batch.

## Super classes

[`Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md) -\>
[`OptimizerAsync`](https://bbotk.mlr-org.com/reference/OptimizerAsync.md)
-\> `OptimizerAsyncGridSearch`

## Methods

### Public methods

- [`OptimizerAsyncGridSearch$new()`](#method-OptimizerAsyncGridSearch-initialize)

- [`OptimizerAsyncGridSearch$optimize()`](#method-OptimizerAsyncGridSearch-optimize)

- [`OptimizerAsyncGridSearch$clone()`](#method-OptimizerAsyncGridSearch-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-help)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-print)

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

  ([OptimInstance](https://bbotk.mlr-org.com/reference/OptimInstance.md)).

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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-18 09:12:12
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-18 09:12:12
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-18 09:12:12
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-18 09:12:12
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-18 09:12:12
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-18 09:12:12
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-18 09:12:12
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-18 09:12:12
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-18 09:12:12
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-18 09:12:12
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-18 09:12:12
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-18 09:12:12
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-18 09:12:12
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-18 09:12:12
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-18 09:12:12
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-18 09:12:12
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-18 09:12:12
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-18 09:12:12
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-18 09:12:12
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-18 09:12:12
#>  21:   failed  10.000000  5.0000000         NA 2026-09-18 09:12:12
#>  22:   failed  10.000000  3.8888889         NA 2026-09-18 09:12:12
#>  23:   failed  10.000000  2.7777778         NA 2026-09-18 09:12:12
#>  24:   failed  10.000000  1.6666667         NA 2026-09-18 09:12:12
#>  25:   failed  10.000000  0.5555556         NA 2026-09-18 09:12:12
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-18 09:12:12
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-18 09:12:12
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-18 09:12:12
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-18 09:12:12
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-18 09:12:12
#>  31:   failed   7.777778  5.0000000         NA 2026-09-18 09:12:12
#>  32:   failed   7.777778  3.8888889         NA 2026-09-18 09:12:12
#>  33:   failed   7.777778  2.7777778         NA 2026-09-18 09:12:12
#>  34:   failed   7.777778  1.6666667         NA 2026-09-18 09:12:12
#>  35:   failed   7.777778  0.5555556         NA 2026-09-18 09:12:12
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-18 09:12:12
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-18 09:12:12
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-18 09:12:12
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-18 09:12:12
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-18 09:12:12
#>  41:   failed   5.555556  5.0000000         NA 2026-09-18 09:12:12
#>  42:   failed   5.555556  3.8888889         NA 2026-09-18 09:12:12
#>  43:   failed   5.555556  2.7777778         NA 2026-09-18 09:12:12
#>  44:   failed   5.555556  1.6666667         NA 2026-09-18 09:12:12
#>  45:   failed   5.555556  0.5555556         NA 2026-09-18 09:12:12
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-18 09:12:12
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-18 09:12:12
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-18 09:12:12
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-18 09:12:12
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-18 09:12:12
#>  51:   failed   3.333333  5.0000000         NA 2026-09-18 09:12:12
#>  52:   failed   3.333333  3.8888889         NA 2026-09-18 09:12:12
#>  53:   failed   3.333333  2.7777778         NA 2026-09-18 09:12:12
#>  54:   failed   3.333333  1.6666667         NA 2026-09-18 09:12:12
#>  55:   failed   3.333333  0.5555556         NA 2026-09-18 09:12:12
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-18 09:12:12
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-18 09:12:12
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-18 09:12:12
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-18 09:12:12
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-18 09:12:12
#>  61:   failed   1.111111  5.0000000         NA 2026-09-18 09:12:12
#>  62:   failed   1.111111  3.8888889         NA 2026-09-18 09:12:12
#>  63:   failed   1.111111  2.7777778         NA 2026-09-18 09:12:12
#>  64:   failed   1.111111  1.6666667         NA 2026-09-18 09:12:12
#>  65:   failed   1.111111  0.5555556         NA 2026-09-18 09:12:12
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-18 09:12:12
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-18 09:12:12
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-18 09:12:12
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-18 09:12:12
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-18 09:12:12
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-18 09:12:12
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-18 09:12:12
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-18 09:12:12
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-18 09:12:12
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-18 09:12:12
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-18 09:12:12
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-18 09:12:12
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-18 09:12:12
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-18 09:12:12
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-18 09:12:12
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-18 09:12:12
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-18 09:12:12
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-18 09:12:12
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-18 09:12:12
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-18 09:12:12
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-18 09:12:12
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-18 09:12:12
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-18 09:12:12
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-18 09:12:12
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-18 09:12:12
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-18 09:12:12
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-18 09:12:12
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-18 09:12:12
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-18 09:12:12
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-18 09:12:12
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-18 09:12:12
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-18 09:12:12
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-18 09:12:12
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-18 09:12:12
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-18 09:12:12
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>   2: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>   3: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>   4: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>   5: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>   6: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>   7: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>   8: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>   9: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>  10: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>  11: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>  12: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>  13: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>  14: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>  15: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>  16: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>  17: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>  18: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>  19: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
#>  20: sinking_raccoon_d3c1b1b7 2026-09-18 09:12:13
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
#>   1: a14d4001-d4a6-433c-9574-0ba2ce8d7ed7    [NULL]  -10.000000  -5.0000000
#>   2: ace3658a-7202-439b-8f9a-ebc60f51c340    [NULL]  -10.000000  -3.8888889
#>   3: f8840263-e121-4cbd-b7a4-ceab8c892501    [NULL]  -10.000000  -2.7777778
#>   4: 583ef2a0-56e3-418a-8f7c-2b7d788a8781    [NULL]  -10.000000  -1.6666667
#>   5: 7d512c82-708b-42c5-9371-afe9cc7f410a    [NULL]  -10.000000  -0.5555556
#>   6: d912c9fb-e2c2-4547-bbbb-ffb49c8a033f    [NULL]  -10.000000   0.5555556
#>   7: e9f2a440-4a2b-4786-ab84-729d2492f86b    [NULL]  -10.000000   1.6666667
#>   8: 97547404-07df-4b32-a9cb-601b88b0cf29    [NULL]  -10.000000   2.7777778
#>   9: 9c02c0e4-b085-43d4-9fd7-1ce9bfc40c88    [NULL]  -10.000000   3.8888889
#>  10: 4d025688-6f79-4cb7-b344-97ec319e602a    [NULL]  -10.000000   5.0000000
#>  11: 55f34acd-cf9c-4370-8c9a-ad0f6ae6f86a    [NULL]   -7.777778  -5.0000000
#>  12: 64da7f59-5773-4c0a-9107-4e3944870a02    [NULL]   -7.777778  -3.8888889
#>  13: 742811a3-ab5d-484b-9c53-b268798c1c0b    [NULL]   -7.777778  -2.7777778
#>  14: 2a22941c-0f2c-4a15-a552-b015fae9da40    [NULL]   -7.777778  -1.6666667
#>  15: e1074e2c-befd-4269-a6f8-73fb2d8bcb2d    [NULL]   -7.777778  -0.5555556
#>  16: 7d93204c-4bce-4cd3-8b02-6941516c1cca    [NULL]   -7.777778   0.5555556
#>  17: b33cc064-f6cc-41b2-bc6c-8bc5a91f25e0    [NULL]   -7.777778   1.6666667
#>  18: d76aa5c6-413a-4ac7-b50e-a6926056ea9c    [NULL]   -7.777778   2.7777778
#>  19: 404fa3dd-5545-4be6-89b3-d2b5ef7ec612    [NULL]   -7.777778   3.8888889
#>  20: debba328-a516-44b0-915b-fc453dcc8840    [NULL]   -7.777778   5.0000000
#>  21: df2a4086-bccc-4d64-83e1-09176e1d8dcf <list[1]>          NA          NA
#>  22: d6ed518a-f6ff-4c0b-916e-913e5a76d12c <list[1]>          NA          NA
#>  23: 7192b5e7-0709-4ace-aa2f-b2a496f66b6f <list[1]>          NA          NA
#>  24: 624a930e-41dc-4090-8b6c-d9c6fcdd8992 <list[1]>          NA          NA
#>  25: 5b0f6f76-52f2-401c-a280-06fb7d4e8ca0 <list[1]>          NA          NA
#>  26: 17d50907-08cf-4ad7-bef0-ddbdb8134126 <list[1]>          NA          NA
#>  27: a28ca16a-3461-430a-b2e9-52c1ea516d98 <list[1]>          NA          NA
#>  28: 08c209cb-034f-42ad-86b3-3a9980ca7399 <list[1]>          NA          NA
#>  29: 91095958-f032-4519-a66e-2705c9526707 <list[1]>          NA          NA
#>  30: 6b799481-7249-4977-80fe-54a1e312aa0c <list[1]>          NA          NA
#>  31: 4fdb6109-5a0a-4fb7-806e-ec7d9084b9d4 <list[1]>          NA          NA
#>  32: 0436b92d-c865-4f7a-8158-a9d500dc2866 <list[1]>          NA          NA
#>  33: d5c627c7-d4c1-412b-bbbd-4728b9e03fd8 <list[1]>          NA          NA
#>  34: e6c15003-6166-400a-a346-2da84611df48 <list[1]>          NA          NA
#>  35: 2723ac5c-fb37-4e3a-ad63-9730640d0cad <list[1]>          NA          NA
#>  36: e5a53919-ecbd-4c08-b4a2-d1b80dc5ec4d <list[1]>          NA          NA
#>  37: 1f95f2cb-2ccd-416e-b3cf-bb74d66274de <list[1]>          NA          NA
#>  38: 3de5500d-5273-4e21-bbb7-813b9bbd1c3e <list[1]>          NA          NA
#>  39: 208511b9-cf71-4635-8a3f-85a90f91159b <list[1]>          NA          NA
#>  40: db247497-8fd1-4f7d-92af-e81113375000 <list[1]>          NA          NA
#>  41: bfe032f5-2a81-4a57-b2d9-d39ee460c0f5 <list[1]>          NA          NA
#>  42: 51a5b243-a275-452c-8aab-68bc00414b05 <list[1]>          NA          NA
#>  43: 867fab83-3598-43a8-b7bd-7c12a6c515a4 <list[1]>          NA          NA
#>  44: cc569968-fe16-4e96-9207-e63be90ab431 <list[1]>          NA          NA
#>  45: e6598e90-4a1e-4e02-abda-420366481146 <list[1]>          NA          NA
#>  46: 2b4cd1e7-4285-4786-b017-1fe9ffab5eb9 <list[1]>          NA          NA
#>  47: d95cc66f-735b-4392-bf05-e7b0e4b65803 <list[1]>          NA          NA
#>  48: 16d40c95-5344-4721-a456-833b684f7c4f <list[1]>          NA          NA
#>  49: 5274e0c1-a63c-4f62-bbf7-12f4ef7e609a <list[1]>          NA          NA
#>  50: 1861f75e-5e05-44bd-a927-c5003f74aa6c <list[1]>          NA          NA
#>  51: bd557fd0-b69b-4920-9008-6c75cb78c6d5 <list[1]>          NA          NA
#>  52: 0d266fe0-ba63-4995-a320-4e73837095ea <list[1]>          NA          NA
#>  53: 8f619f8b-af0c-4fbe-a4b5-a4bc974e668f <list[1]>          NA          NA
#>  54: 825f54f0-da7a-40e0-9c05-f4a3bef25aab <list[1]>          NA          NA
#>  55: a10db1f0-6b54-47a1-9c0b-f04ebdf6dfe1 <list[1]>          NA          NA
#>  56: 15f68890-81a4-4be3-a918-2fcc9c465c31 <list[1]>          NA          NA
#>  57: 3444c9a2-9553-45ac-94a5-29e273a38ead <list[1]>          NA          NA
#>  58: c9195e50-88c4-4947-bef2-b55a472316ca <list[1]>          NA          NA
#>  59: 0ffa7beb-92c7-423b-913f-5f2d194d92d6 <list[1]>          NA          NA
#>  60: 4fbb400b-a164-40d1-b1ce-9284826fd6b7 <list[1]>          NA          NA
#>  61: b2296644-18ff-4614-91b0-33b72717d55b <list[1]>          NA          NA
#>  62: 76383d9f-68ec-4510-b7b3-0306ca331101 <list[1]>          NA          NA
#>  63: 3b721605-9b99-4884-b9cd-c2efde30eef4 <list[1]>          NA          NA
#>  64: b908f733-c511-4370-b791-f1b30a335b7f <list[1]>          NA          NA
#>  65: 320077fa-fa4b-424c-bef2-27e35fc8613a <list[1]>          NA          NA
#>  66: 5c1a826b-23b3-4f38-8cc1-bd424ac5290b <list[1]>          NA          NA
#>  67: ffe0b9d3-9408-4fde-ace5-e63c2d8ee0d1 <list[1]>          NA          NA
#>  68: 4ad62486-7afc-4c53-af4a-7c5a3e024c73 <list[1]>          NA          NA
#>  69: 439a4fb2-838f-4a20-8492-88c19314b87d <list[1]>          NA          NA
#>  70: 9e109bce-fc8a-4f2e-8961-75b193820d34 <list[1]>          NA          NA
#>  71: e97ff450-73c4-4fc3-ba26-7ece4c96d1ff <list[1]>          NA          NA
#>  72: b2f5e5b3-67ba-4137-9fa8-f2a964214f38 <list[1]>          NA          NA
#>  73: 67bbdb8b-0c62-4505-abf8-d5baab86bb40 <list[1]>          NA          NA
#>  74: 1afad288-60b6-4590-8ed5-42b311f934e9 <list[1]>          NA          NA
#>  75: f9149622-6f47-4983-bde2-73e9d4366467 <list[1]>          NA          NA
#>  76: 6e11830f-101d-4994-a828-6c60dfe7fb4b <list[1]>          NA          NA
#>  77: 6d4120e3-2ffc-4067-b1b5-f94966ebe392 <list[1]>          NA          NA
#>  78: 888d542b-efd6-41f5-b572-2092e61f343e <list[1]>          NA          NA
#>  79: d1b74a20-9c6e-4916-9caa-265a5d0e297a <list[1]>          NA          NA
#>  80: 7bbcb551-4d87-4f2a-972e-0c38338abcc5 <list[1]>          NA          NA
#>  81: fbd70291-fa59-45e8-a090-ffe5c17ff07f <list[1]>          NA          NA
#>  82: f68e27b9-3d15-4154-87ba-637b36be2547 <list[1]>          NA          NA
#>  83: 96367892-0b46-48b1-bdfd-b739b1bb4852 <list[1]>          NA          NA
#>  84: 585e1b57-f2b9-4d37-9970-b4339af5985c <list[1]>          NA          NA
#>  85: 7a902d88-6f29-4a6b-9c6a-cb3421b96e56 <list[1]>          NA          NA
#>  86: edd0e7a6-70df-4556-889f-b8c0faa90d63 <list[1]>          NA          NA
#>  87: 5608411a-081c-4919-a6cc-81a210210413 <list[1]>          NA          NA
#>  88: d14f640c-84e4-4ee0-96d9-beae521ca3d8 <list[1]>          NA          NA
#>  89: c2168b98-c82d-45a2-b6c5-42a821b4e152 <list[1]>          NA          NA
#>  90: 145bfa29-34c7-48eb-ad6f-6f3d6955be13 <list[1]>          NA          NA
#>  91: bf5ff7f4-2ba1-4115-95bb-716451860852 <list[1]>          NA          NA
#>  92: 4a4933de-f58d-4713-a4af-d5e02d5f85c3 <list[1]>          NA          NA
#>  93: 376f874c-79ce-4e52-a488-ed56df0e510c <list[1]>          NA          NA
#>  94: 92af6058-7564-476b-8eee-234bc19b8020 <list[1]>          NA          NA
#>  95: 2e2f2a3a-a264-4d34-a94f-af34b6079fef <list[1]>          NA          NA
#>  96: 3d18f300-d966-4c4a-8e20-b8434be24536 <list[1]>          NA          NA
#>  97: 8a23832b-8fa7-4aa4-81dc-84d4f1c311dc <list[1]>          NA          NA
#>  98: 662f159a-df8c-4a39-a731-8369565b8fb6 <list[1]>          NA          NA
#>  99: 6c2838e3-d5e8-4f95-bc52-20cd60d75da2 <list[1]>          NA          NA
#> 100: f166883b-9a11-4fad-b442-356c47a04197 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
