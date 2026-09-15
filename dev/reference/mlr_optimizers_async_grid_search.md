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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-15 16:14:47
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-15 16:14:47
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-15 16:14:47
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-15 16:14:47
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-15 16:14:47
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-15 16:14:47
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-15 16:14:47
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-15 16:14:47
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-15 16:14:47
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-15 16:14:47
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-15 16:14:47
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-15 16:14:47
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-15 16:14:47
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-15 16:14:47
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-15 16:14:47
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-15 16:14:47
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-15 16:14:47
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-15 16:14:47
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-15 16:14:47
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-15 16:14:47
#>  21:   failed  10.000000  5.0000000         NA 2026-09-15 16:14:47
#>  22:   failed  10.000000  3.8888889         NA 2026-09-15 16:14:47
#>  23:   failed  10.000000  2.7777778         NA 2026-09-15 16:14:47
#>  24:   failed  10.000000  1.6666667         NA 2026-09-15 16:14:47
#>  25:   failed  10.000000  0.5555556         NA 2026-09-15 16:14:47
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-15 16:14:47
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-15 16:14:47
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-15 16:14:47
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-15 16:14:47
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-15 16:14:47
#>  31:   failed   7.777778  5.0000000         NA 2026-09-15 16:14:47
#>  32:   failed   7.777778  3.8888889         NA 2026-09-15 16:14:47
#>  33:   failed   7.777778  2.7777778         NA 2026-09-15 16:14:47
#>  34:   failed   7.777778  1.6666667         NA 2026-09-15 16:14:47
#>  35:   failed   7.777778  0.5555556         NA 2026-09-15 16:14:47
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-15 16:14:47
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-15 16:14:47
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-15 16:14:47
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-15 16:14:47
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-15 16:14:47
#>  41:   failed   5.555556  5.0000000         NA 2026-09-15 16:14:47
#>  42:   failed   5.555556  3.8888889         NA 2026-09-15 16:14:47
#>  43:   failed   5.555556  2.7777778         NA 2026-09-15 16:14:47
#>  44:   failed   5.555556  1.6666667         NA 2026-09-15 16:14:47
#>  45:   failed   5.555556  0.5555556         NA 2026-09-15 16:14:47
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-15 16:14:47
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-15 16:14:47
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-15 16:14:47
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-15 16:14:47
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-15 16:14:47
#>  51:   failed   3.333333  5.0000000         NA 2026-09-15 16:14:47
#>  52:   failed   3.333333  3.8888889         NA 2026-09-15 16:14:47
#>  53:   failed   3.333333  2.7777778         NA 2026-09-15 16:14:47
#>  54:   failed   3.333333  1.6666667         NA 2026-09-15 16:14:47
#>  55:   failed   3.333333  0.5555556         NA 2026-09-15 16:14:47
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-15 16:14:47
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-15 16:14:47
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-15 16:14:47
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-15 16:14:47
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-15 16:14:47
#>  61:   failed   1.111111  5.0000000         NA 2026-09-15 16:14:47
#>  62:   failed   1.111111  3.8888889         NA 2026-09-15 16:14:47
#>  63:   failed   1.111111  2.7777778         NA 2026-09-15 16:14:47
#>  64:   failed   1.111111  1.6666667         NA 2026-09-15 16:14:47
#>  65:   failed   1.111111  0.5555556         NA 2026-09-15 16:14:47
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-15 16:14:47
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-15 16:14:47
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-15 16:14:47
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-15 16:14:47
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-15 16:14:47
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-15 16:14:47
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-15 16:14:47
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-15 16:14:47
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-15 16:14:47
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-15 16:14:47
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-15 16:14:47
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-15 16:14:47
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-15 16:14:47
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-15 16:14:47
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-15 16:14:47
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-15 16:14:47
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-15 16:14:47
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-15 16:14:47
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-15 16:14:47
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-15 16:14:47
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-15 16:14:47
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-15 16:14:47
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-15 16:14:47
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-15 16:14:47
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-15 16:14:47
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-15 16:14:47
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-15 16:14:47
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-15 16:14:47
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-15 16:14:47
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-15 16:14:47
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-15 16:14:47
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-15 16:14:47
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-15 16:14:47
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-15 16:14:47
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-15 16:14:47
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>   2: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>   3: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>   4: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>   5: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>   6: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>   7: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>   8: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>   9: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>  10: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>  11: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>  12: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>  13: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>  14: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>  15: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>  16: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>  17: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>  18: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>  19: sinking_raccoon_28367cfb 2026-09-15 16:14:48
#>  20: sinking_raccoon_28367cfb 2026-09-15 16:14:48
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
#>   1: 9c2b1348-7662-4cba-b3a4-3d8171ff0aec    [NULL]  -10.000000  -5.0000000
#>   2: 546a5f79-96f1-46a8-bc38-ea0cfbb78b8f    [NULL]  -10.000000  -3.8888889
#>   3: d33e6c01-8d27-449d-86bf-0ecc5351776b    [NULL]  -10.000000  -2.7777778
#>   4: 84b599a9-0403-423c-945e-b5c7db3a5fce    [NULL]  -10.000000  -1.6666667
#>   5: 6e2f29e8-1331-442e-80a5-3dff8642d8f1    [NULL]  -10.000000  -0.5555556
#>   6: 7c9d9af7-ceff-4af7-9fbc-11ede8b4640c    [NULL]  -10.000000   0.5555556
#>   7: 763d6f05-34cd-45a9-b9a8-2b43149de4f1    [NULL]  -10.000000   1.6666667
#>   8: 17be6ecd-bca7-4b56-9f1d-84234c4e2d0d    [NULL]  -10.000000   2.7777778
#>   9: aa9cbff0-c72d-4fd5-979f-e31d1d85de3e    [NULL]  -10.000000   3.8888889
#>  10: 2019e88d-a7eb-4adc-af55-e0fbf35b8acf    [NULL]  -10.000000   5.0000000
#>  11: 3378d801-7e65-45ad-8dee-f9523b0b3f21    [NULL]   -7.777778  -5.0000000
#>  12: 613cf6d2-dd91-4628-8d61-c65d40352f37    [NULL]   -7.777778  -3.8888889
#>  13: ec3d4c41-b120-4bba-b6d2-afe36a54b972    [NULL]   -7.777778  -2.7777778
#>  14: 45f6db8a-29a8-4db0-b6de-95e2a63644a4    [NULL]   -7.777778  -1.6666667
#>  15: f5264aae-3853-4d57-a418-86409c1d6872    [NULL]   -7.777778  -0.5555556
#>  16: 8bf00ea5-f8f0-48ca-a609-b885a158013b    [NULL]   -7.777778   0.5555556
#>  17: be6790ce-86d5-4835-895b-7efab8b1b73d    [NULL]   -7.777778   1.6666667
#>  18: a1b700c1-1bc4-4b4c-a6c8-9ed516ebb403    [NULL]   -7.777778   2.7777778
#>  19: 44191d6c-a231-466b-85bd-a40cbee9cf98    [NULL]   -7.777778   3.8888889
#>  20: fc00717a-cd65-4d5d-80e2-87dcdb85163e    [NULL]   -7.777778   5.0000000
#>  21: 5911b72a-30dd-484d-a0a5-0f51292ee3e7 <list[1]>          NA          NA
#>  22: e7867039-6d77-42d2-ad7e-ea45d61beed6 <list[1]>          NA          NA
#>  23: 1a104dc9-d008-40c7-a52d-085991c4f458 <list[1]>          NA          NA
#>  24: 3ee74ed6-9c12-4c58-8ccc-ef3f7d33838f <list[1]>          NA          NA
#>  25: cb299406-b14b-480d-a702-ea2a79adcd78 <list[1]>          NA          NA
#>  26: 266c76c1-c5c2-4cf8-85bf-9b9809a308b3 <list[1]>          NA          NA
#>  27: 4634bf65-4cc5-4633-b631-6b7f5e8d8b55 <list[1]>          NA          NA
#>  28: f8a33ef7-d374-45ed-9012-a4423be37f6d <list[1]>          NA          NA
#>  29: 7e188430-adff-4c4c-bdd5-a60ecbdf7faf <list[1]>          NA          NA
#>  30: 19e1a3c3-98b4-4d2d-8c72-fd95b47d32b3 <list[1]>          NA          NA
#>  31: 562e5066-1af4-4217-bffa-83a3000e63a5 <list[1]>          NA          NA
#>  32: 6c0dbd12-9761-4fe7-a598-e542c1dd14dc <list[1]>          NA          NA
#>  33: 832105bc-2877-4ac1-97b9-f2780ab2ed1a <list[1]>          NA          NA
#>  34: 84fcafc7-29a5-43f3-8f7f-c9f8854b918b <list[1]>          NA          NA
#>  35: fe947d0b-09e5-40d6-9384-6f6c45f45583 <list[1]>          NA          NA
#>  36: d7614831-7403-4ee9-bc4b-40f108e64e77 <list[1]>          NA          NA
#>  37: 9669babb-a9da-4cb2-9ec8-e3fe7241af40 <list[1]>          NA          NA
#>  38: b8136cd1-6463-4144-a5a4-22e2ceaed1d5 <list[1]>          NA          NA
#>  39: 7d0de7b1-052f-47f4-96ce-d9affdbcefe4 <list[1]>          NA          NA
#>  40: 0d1fab26-1b91-44e9-87be-e7a2c7955da7 <list[1]>          NA          NA
#>  41: a50130ab-2e3c-477e-b93a-38f9ee0e3bf8 <list[1]>          NA          NA
#>  42: 247c42aa-c91f-4147-b4a5-27520656cf6e <list[1]>          NA          NA
#>  43: 2875959d-b1df-4c27-8481-7c0deaeda49e <list[1]>          NA          NA
#>  44: c457310c-0c3d-4085-84f7-452fb749c99e <list[1]>          NA          NA
#>  45: 0312c57f-24b5-4829-8bb2-9a9c95f8572b <list[1]>          NA          NA
#>  46: 131393c1-5b0c-4ee2-a4ff-f243284a920d <list[1]>          NA          NA
#>  47: 20cb72a1-d139-4acd-9cf7-9c5f968318b5 <list[1]>          NA          NA
#>  48: e2d2a8f2-9b5e-4f59-842b-8144998c2dd1 <list[1]>          NA          NA
#>  49: 7f997431-d110-4ace-95e9-8a9047b12dc3 <list[1]>          NA          NA
#>  50: 9ff571c2-5b8e-4b64-8bda-e2172750039b <list[1]>          NA          NA
#>  51: e435589f-e374-4b15-90f1-1175857bfa96 <list[1]>          NA          NA
#>  52: 6e4ecb48-64f2-4272-befd-eb473b5dfe3b <list[1]>          NA          NA
#>  53: 46c2e75c-2be9-4e25-8c89-51d66765dfe6 <list[1]>          NA          NA
#>  54: d35f7fc9-e2d3-454b-ad1d-054c344a1c0f <list[1]>          NA          NA
#>  55: b81af458-c709-4fcf-a133-fcdfda81686f <list[1]>          NA          NA
#>  56: ef2c322e-31b0-4861-adc7-fa169b34a234 <list[1]>          NA          NA
#>  57: 62082903-eaeb-47e8-b621-1fe04e77cc21 <list[1]>          NA          NA
#>  58: 0e961237-997b-4aed-b9de-8535238442f3 <list[1]>          NA          NA
#>  59: b121a5c6-8547-4d27-803f-0f9748a39f19 <list[1]>          NA          NA
#>  60: 1ed620be-1cd5-45f3-8e04-36107d4264f1 <list[1]>          NA          NA
#>  61: 2eedd3e8-65f8-4e52-a787-4c39fc04c3e5 <list[1]>          NA          NA
#>  62: 3a77543f-992d-448f-a9d4-5e29e74be217 <list[1]>          NA          NA
#>  63: bf8d3a32-255c-4dda-8dd7-42810e855626 <list[1]>          NA          NA
#>  64: ce307a75-d7f9-4a7d-aa5e-e00cd0f88727 <list[1]>          NA          NA
#>  65: 3efcd976-7cee-47c1-8178-c81061708f82 <list[1]>          NA          NA
#>  66: 2676c434-095b-4f53-83e3-dc64458d3a71 <list[1]>          NA          NA
#>  67: c537d2d8-e96e-4fc9-a21f-ec093b9b0997 <list[1]>          NA          NA
#>  68: 2661f139-3547-421b-978b-a2ef98ad9a1d <list[1]>          NA          NA
#>  69: 5551a6d6-9318-485e-9f43-18b2dc97817b <list[1]>          NA          NA
#>  70: 21a3db9e-99de-4f60-9537-94eb7de42651 <list[1]>          NA          NA
#>  71: 5d60a5ef-17b8-490f-9d81-7d4077afa30a <list[1]>          NA          NA
#>  72: 768fb71d-7c84-495e-9c3f-b674f5933f42 <list[1]>          NA          NA
#>  73: a14efd1e-a2a4-40c1-8b84-fa4b6e3aeeee <list[1]>          NA          NA
#>  74: 80e57ab0-a470-4210-85d8-d3ef0e7996b4 <list[1]>          NA          NA
#>  75: 8c872dfa-ea8e-4d5e-a72a-ae7fa1bf1c9c <list[1]>          NA          NA
#>  76: 75ee2595-5b4c-4f37-8966-fd097405f491 <list[1]>          NA          NA
#>  77: 0b8213e4-ce33-4a11-9977-bfb2f749ca28 <list[1]>          NA          NA
#>  78: c2df0fcc-fcab-46ac-9f7f-f038052f4a8c <list[1]>          NA          NA
#>  79: 3988dc93-fd34-4e1b-8a11-2330ad09f9e3 <list[1]>          NA          NA
#>  80: a7766fcb-c0a7-44b2-ad30-da3840be3079 <list[1]>          NA          NA
#>  81: fab6cbe2-e5ba-430f-9679-2c4bd0eb327b <list[1]>          NA          NA
#>  82: 73b4a302-bc3a-42f7-8e29-efaaa92657e7 <list[1]>          NA          NA
#>  83: eefeca39-ddee-47fd-813e-1306ae93640b <list[1]>          NA          NA
#>  84: 7eaf82d0-3b36-4a98-a8e1-3e24abdc9e54 <list[1]>          NA          NA
#>  85: bfb86ee2-0fbb-4296-a648-7946f210424b <list[1]>          NA          NA
#>  86: cc8b54d3-b542-4468-b0c0-8fc61b1abe51 <list[1]>          NA          NA
#>  87: 27159523-ad2d-4cfd-9374-f831dfa4fe04 <list[1]>          NA          NA
#>  88: 2d413708-3b90-4716-a011-b2a14d51e164 <list[1]>          NA          NA
#>  89: 954b5d5f-210b-4464-8ec8-d3c5c357dbeb <list[1]>          NA          NA
#>  90: 6e9237a6-1eef-4cff-b945-836543b4dc3d <list[1]>          NA          NA
#>  91: 3ad9c628-5bd1-4916-87a2-90adbeb93de5 <list[1]>          NA          NA
#>  92: 10bf12c2-c0ae-4426-825c-1b9c5a775d48 <list[1]>          NA          NA
#>  93: 467ab32e-f2b5-4f74-aa4d-df8594206594 <list[1]>          NA          NA
#>  94: 2bec29c5-73ee-44e6-bccf-85162bd172b5 <list[1]>          NA          NA
#>  95: eb97e509-4ba8-4d74-95ff-efe753ada945 <list[1]>          NA          NA
#>  96: 8fedf1d2-aba9-447f-bbe3-d2511da627dd <list[1]>          NA          NA
#>  97: 0a3c6b9b-a204-45b5-ac3e-760186602818 <list[1]>          NA          NA
#>  98: 4d4641fa-41c7-4613-863e-aa83c8fd7dc9 <list[1]>          NA          NA
#>  99: 78a5dda7-eed3-4d5e-8a09-0fb0b993451a <list[1]>          NA          NA
#> 100: b4bb1211-c3ac-4967-9288-5615e5fdd9e9 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
