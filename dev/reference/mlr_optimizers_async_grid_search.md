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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-17 09:16:55
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-17 09:16:55
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-17 09:16:55
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-17 09:16:55
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-17 09:16:55
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-17 09:16:55
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-17 09:16:55
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-17 09:16:55
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-17 09:16:55
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-17 09:16:55
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-17 09:16:55
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-17 09:16:55
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-17 09:16:55
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-17 09:16:55
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-17 09:16:55
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-17 09:16:55
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-17 09:16:55
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-17 09:16:55
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-17 09:16:55
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-17 09:16:55
#>  21:   failed  10.000000  5.0000000         NA 2026-09-17 09:16:55
#>  22:   failed  10.000000  3.8888889         NA 2026-09-17 09:16:55
#>  23:   failed  10.000000  2.7777778         NA 2026-09-17 09:16:55
#>  24:   failed  10.000000  1.6666667         NA 2026-09-17 09:16:55
#>  25:   failed  10.000000  0.5555556         NA 2026-09-17 09:16:55
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-17 09:16:55
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-17 09:16:55
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-17 09:16:55
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-17 09:16:55
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-17 09:16:55
#>  31:   failed   7.777778  5.0000000         NA 2026-09-17 09:16:55
#>  32:   failed   7.777778  3.8888889         NA 2026-09-17 09:16:55
#>  33:   failed   7.777778  2.7777778         NA 2026-09-17 09:16:55
#>  34:   failed   7.777778  1.6666667         NA 2026-09-17 09:16:55
#>  35:   failed   7.777778  0.5555556         NA 2026-09-17 09:16:55
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-17 09:16:55
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-17 09:16:55
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-17 09:16:55
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-17 09:16:55
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-17 09:16:55
#>  41:   failed   5.555556  5.0000000         NA 2026-09-17 09:16:55
#>  42:   failed   5.555556  3.8888889         NA 2026-09-17 09:16:55
#>  43:   failed   5.555556  2.7777778         NA 2026-09-17 09:16:55
#>  44:   failed   5.555556  1.6666667         NA 2026-09-17 09:16:55
#>  45:   failed   5.555556  0.5555556         NA 2026-09-17 09:16:55
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-17 09:16:55
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-17 09:16:55
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-17 09:16:55
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-17 09:16:55
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-17 09:16:55
#>  51:   failed   3.333333  5.0000000         NA 2026-09-17 09:16:55
#>  52:   failed   3.333333  3.8888889         NA 2026-09-17 09:16:55
#>  53:   failed   3.333333  2.7777778         NA 2026-09-17 09:16:55
#>  54:   failed   3.333333  1.6666667         NA 2026-09-17 09:16:55
#>  55:   failed   3.333333  0.5555556         NA 2026-09-17 09:16:55
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-17 09:16:55
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-17 09:16:55
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-17 09:16:55
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-17 09:16:55
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-17 09:16:55
#>  61:   failed   1.111111  5.0000000         NA 2026-09-17 09:16:55
#>  62:   failed   1.111111  3.8888889         NA 2026-09-17 09:16:55
#>  63:   failed   1.111111  2.7777778         NA 2026-09-17 09:16:55
#>  64:   failed   1.111111  1.6666667         NA 2026-09-17 09:16:55
#>  65:   failed   1.111111  0.5555556         NA 2026-09-17 09:16:55
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-17 09:16:55
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-17 09:16:55
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-17 09:16:55
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-17 09:16:55
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-17 09:16:55
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-17 09:16:55
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-17 09:16:55
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-17 09:16:55
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-17 09:16:55
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-17 09:16:55
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-17 09:16:55
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-17 09:16:55
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-17 09:16:55
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-17 09:16:55
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-17 09:16:55
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-17 09:16:55
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-17 09:16:55
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-17 09:16:55
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-17 09:16:55
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-17 09:16:55
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-17 09:16:55
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-17 09:16:55
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-17 09:16:55
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-17 09:16:55
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-17 09:16:55
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-17 09:16:55
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-17 09:16:55
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-17 09:16:55
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-17 09:16:55
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-17 09:16:55
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-17 09:16:55
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-17 09:16:55
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-17 09:16:55
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-17 09:16:55
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-17 09:16:55
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>   2: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>   3: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>   4: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>   5: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>   6: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>   7: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>   8: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>   9: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>  10: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>  11: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>  12: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>  13: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>  14: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>  15: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>  16: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>  17: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>  18: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>  19: sinking_raccoon_b0455005 2026-09-17 09:16:56
#>  20: sinking_raccoon_b0455005 2026-09-17 09:16:56
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
#>   1: bb43a989-7a2e-46df-a978-83f5f044f743    [NULL]  -10.000000  -5.0000000
#>   2: 0b50b5d0-46e3-44b3-aa66-d73171eb0673    [NULL]  -10.000000  -3.8888889
#>   3: 629e9a5c-bb52-4a90-a9a4-f6babd2da1e1    [NULL]  -10.000000  -2.7777778
#>   4: 563c3603-050c-4347-aa1d-f412f856e5dd    [NULL]  -10.000000  -1.6666667
#>   5: 9ac34a4a-f973-47d7-9a68-7ee17df29560    [NULL]  -10.000000  -0.5555556
#>   6: c34c139d-ae18-4d7b-ba05-545057e2c016    [NULL]  -10.000000   0.5555556
#>   7: 5bc0bf57-8e80-4a18-b824-5edf138628f1    [NULL]  -10.000000   1.6666667
#>   8: 57018c97-6a76-41ad-9e8b-7adc1aacab42    [NULL]  -10.000000   2.7777778
#>   9: ef352051-1119-40b7-ae89-7cc657380209    [NULL]  -10.000000   3.8888889
#>  10: 17b150f4-3635-4cac-bcc4-bf01ad0068ed    [NULL]  -10.000000   5.0000000
#>  11: bd0b00ff-eb46-4140-b51b-0d142ad1615e    [NULL]   -7.777778  -5.0000000
#>  12: 0de67a98-ae85-4860-b33a-fc43edb0cdee    [NULL]   -7.777778  -3.8888889
#>  13: d9c34369-22c1-4418-9277-5ea0c3c1048e    [NULL]   -7.777778  -2.7777778
#>  14: 5b5b3e1e-e11d-4d55-887d-5c58d6a36e9c    [NULL]   -7.777778  -1.6666667
#>  15: 857f4e86-e86d-4b13-981c-4adedae32c06    [NULL]   -7.777778  -0.5555556
#>  16: 03414d7a-6daf-4b11-8638-98ffe3144379    [NULL]   -7.777778   0.5555556
#>  17: 95337344-0290-42ba-9ee1-ec4f257b6c42    [NULL]   -7.777778   1.6666667
#>  18: 9af1d757-7571-4c54-94dd-967c4cb7154c    [NULL]   -7.777778   2.7777778
#>  19: 1bca65ef-e26a-49a7-a16f-bd9942150c70    [NULL]   -7.777778   3.8888889
#>  20: 8676d4b6-f763-4436-8d5c-6c3e279490e4    [NULL]   -7.777778   5.0000000
#>  21: e6411039-992a-409d-94ab-78572d2b5581 <list[1]>          NA          NA
#>  22: 1a0d6e88-1a45-41de-8f13-788ff0846124 <list[1]>          NA          NA
#>  23: ddc301e0-8a86-450e-bb0d-1e240bf96320 <list[1]>          NA          NA
#>  24: f7f6e663-f7e4-4ee4-a153-e57af1403cbf <list[1]>          NA          NA
#>  25: ba43f3a7-6286-4335-9d15-aefd81439f40 <list[1]>          NA          NA
#>  26: f564e08e-711d-4b55-bc9c-f867fa1bd407 <list[1]>          NA          NA
#>  27: e7afd861-8376-44cc-b4ff-74800d6a91bd <list[1]>          NA          NA
#>  28: 39a83dc8-d4ff-4379-abe9-610ab5fdf955 <list[1]>          NA          NA
#>  29: 2f7d5afb-ebec-4644-a7bb-9d3e188864cd <list[1]>          NA          NA
#>  30: 0e9dfc2e-98ac-44b0-9822-4eea9c2e068c <list[1]>          NA          NA
#>  31: ee9b2565-fc9e-454f-a9a1-ed55252d465a <list[1]>          NA          NA
#>  32: 5c384e35-c2b9-403c-a62e-64684817226f <list[1]>          NA          NA
#>  33: 0bf424d0-626e-4998-9f38-ead49e6cbee1 <list[1]>          NA          NA
#>  34: 663ca4ff-8581-4b9e-bfd2-add83f190e6b <list[1]>          NA          NA
#>  35: 7889ae65-8fd3-458b-bc64-6458a4f7e338 <list[1]>          NA          NA
#>  36: 04910755-f79d-46fb-bfe4-2ad38b016dc3 <list[1]>          NA          NA
#>  37: 5c5fa609-ad1d-41c4-89b5-fb54d13c437d <list[1]>          NA          NA
#>  38: 3e02dac6-a209-4a7b-9095-5a37e1b4e610 <list[1]>          NA          NA
#>  39: 92604fc3-5731-48e9-b89a-5c9678c3b117 <list[1]>          NA          NA
#>  40: 5452edde-468d-4d40-a7f0-a359d2f665c8 <list[1]>          NA          NA
#>  41: cfb19918-4b3e-4377-9bad-ead4b6e3dad2 <list[1]>          NA          NA
#>  42: 71dff00c-19ac-491c-b8f0-22668c49a50a <list[1]>          NA          NA
#>  43: 520f4b5e-7b5c-4ccd-8b0e-38c58ec6f226 <list[1]>          NA          NA
#>  44: 79540145-36b9-4487-ad0f-a3cfa34efef9 <list[1]>          NA          NA
#>  45: 0b274546-a5d0-4829-a662-1b17b6a88709 <list[1]>          NA          NA
#>  46: e1179ef7-81d6-4033-8990-73bc603e6bd0 <list[1]>          NA          NA
#>  47: ff4b6775-8d36-405b-bc72-59cbe0c15bb3 <list[1]>          NA          NA
#>  48: b1ee631e-87fe-4273-888f-088011884741 <list[1]>          NA          NA
#>  49: 0d9eab08-f0a8-4983-812f-f30bc19535e4 <list[1]>          NA          NA
#>  50: 9324bd94-3da3-4535-aaf4-703655bf9c3d <list[1]>          NA          NA
#>  51: d91e6aac-e7b2-4723-8808-ac2daa3e8310 <list[1]>          NA          NA
#>  52: 899015d8-2656-40fe-a744-e9ef7150196f <list[1]>          NA          NA
#>  53: be8d9d7a-9794-4bc1-94dc-f2d9febc2a9f <list[1]>          NA          NA
#>  54: ccc3ac2b-5d45-446b-9ec3-4043647219e3 <list[1]>          NA          NA
#>  55: 82ad72a9-503c-4e0d-a2ef-4a585798f563 <list[1]>          NA          NA
#>  56: 983dd233-f278-4c57-8eeb-8a6e81c948bd <list[1]>          NA          NA
#>  57: aa1a6d22-fad9-4290-86c0-46077306f666 <list[1]>          NA          NA
#>  58: c9f3073c-49b6-42b4-9bbc-662d6e07363b <list[1]>          NA          NA
#>  59: 57b4181c-7a98-4b1c-a915-b7e0c2eff88e <list[1]>          NA          NA
#>  60: 08b6d5a7-61ff-46e6-9493-ea286cef7999 <list[1]>          NA          NA
#>  61: a0fb2522-aef0-481b-9ec9-6e330739cde4 <list[1]>          NA          NA
#>  62: 10cf47b9-0f0a-47d5-af2a-9c39c7cdeec6 <list[1]>          NA          NA
#>  63: c8891123-3e0d-4608-a889-6d0a7c7d85a4 <list[1]>          NA          NA
#>  64: e3e790b8-95da-4b30-9a43-f45d922b5893 <list[1]>          NA          NA
#>  65: e5dddb11-3cce-4a4c-acc0-51e2424b9358 <list[1]>          NA          NA
#>  66: 5107fd29-8369-4ecc-998b-2ffd45013c5a <list[1]>          NA          NA
#>  67: 340b6268-2c59-4b17-8f2b-d7ac846cae33 <list[1]>          NA          NA
#>  68: ab68473f-15bf-47bb-9465-78f2b97d5ca5 <list[1]>          NA          NA
#>  69: a34a0cf2-64b4-4dd3-a26f-039a0436a533 <list[1]>          NA          NA
#>  70: 5525d4c7-df54-40da-8c7c-4948cc08cdf0 <list[1]>          NA          NA
#>  71: b87edf55-f295-4e44-b005-60a8f263839b <list[1]>          NA          NA
#>  72: 6d3fa829-ffe0-4d15-a86f-a074a11aaba9 <list[1]>          NA          NA
#>  73: db334440-5cec-40bb-b384-1ee22c78ea04 <list[1]>          NA          NA
#>  74: 270f1d4e-0003-422c-b88d-520afe132f10 <list[1]>          NA          NA
#>  75: 9fc3e3ad-a1e7-4d58-9948-b36e7b6fbee3 <list[1]>          NA          NA
#>  76: b10a115f-3da0-4eb1-8277-7e0fb4e8d940 <list[1]>          NA          NA
#>  77: aef09b78-0feb-48d9-bf6b-d75314b2690f <list[1]>          NA          NA
#>  78: fa900bb4-7838-4100-9f6d-7436954e53f0 <list[1]>          NA          NA
#>  79: 813d6dc8-b9dc-478c-9f0c-16932a7d1268 <list[1]>          NA          NA
#>  80: 1d0c65e4-304e-4a20-b24f-523d6a3cfc24 <list[1]>          NA          NA
#>  81: f55fad44-8be4-4c66-83c8-9f6635f62f33 <list[1]>          NA          NA
#>  82: 86f526e9-e315-44e5-ba65-11ef71a3f581 <list[1]>          NA          NA
#>  83: 5472936a-c8f8-4c0d-a1b6-73b9354cd027 <list[1]>          NA          NA
#>  84: a58e61fa-889e-494e-98b0-1d591ed6dfd4 <list[1]>          NA          NA
#>  85: 54303df1-aa9d-4ba3-aa9e-51ba3a38b37d <list[1]>          NA          NA
#>  86: f95176a1-82c2-43fe-b8cf-389ba3dffbd5 <list[1]>          NA          NA
#>  87: 701bf2ee-9ec2-47e0-ab8f-1af47e3366b0 <list[1]>          NA          NA
#>  88: afe148da-ceda-48e8-b121-df7acfdffe54 <list[1]>          NA          NA
#>  89: 88926b5f-f874-4874-8804-a96faaa1610f <list[1]>          NA          NA
#>  90: af444c6a-9ebf-4a7c-9f63-dcafae6bc483 <list[1]>          NA          NA
#>  91: 4d1aa276-59e3-4b52-843e-b098da7c645b <list[1]>          NA          NA
#>  92: 373a4ffe-ea59-4ff1-b122-2aa06496d034 <list[1]>          NA          NA
#>  93: 0e0157e8-e79e-4fa8-ac9d-68229a93adbf <list[1]>          NA          NA
#>  94: 774a5d87-e733-4b15-bc46-be6bdd320b17 <list[1]>          NA          NA
#>  95: 8c4cb1cd-ecee-44aa-a6c5-3da50ffdb493 <list[1]>          NA          NA
#>  96: c72a574a-e5bf-48da-99ee-298b454b486c <list[1]>          NA          NA
#>  97: 20119852-59d6-4fcd-b7df-7b3c72449979 <list[1]>          NA          NA
#>  98: bc2888f2-64d4-44e5-b636-2c9c29e2dd89 <list[1]>          NA          NA
#>  99: 09403c58-dd28-4a70-85e0-39a821c645a7 <list[1]>          NA          NA
#> 100: f1103bdf-0d3b-4ca6-86d0-c3c90327bd3e <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
