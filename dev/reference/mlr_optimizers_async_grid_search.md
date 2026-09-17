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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-17 09:53:27
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-17 09:53:27
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-17 09:53:27
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-17 09:53:27
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-17 09:53:27
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-17 09:53:27
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-17 09:53:27
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-17 09:53:27
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-17 09:53:27
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-17 09:53:27
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-17 09:53:27
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-17 09:53:27
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-17 09:53:27
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-17 09:53:27
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-17 09:53:27
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-17 09:53:27
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-17 09:53:27
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-17 09:53:27
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-17 09:53:27
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-17 09:53:27
#>  21:   failed  10.000000  5.0000000         NA 2026-09-17 09:53:27
#>  22:   failed  10.000000  3.8888889         NA 2026-09-17 09:53:27
#>  23:   failed  10.000000  2.7777778         NA 2026-09-17 09:53:27
#>  24:   failed  10.000000  1.6666667         NA 2026-09-17 09:53:27
#>  25:   failed  10.000000  0.5555556         NA 2026-09-17 09:53:27
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-17 09:53:27
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-17 09:53:27
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-17 09:53:27
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-17 09:53:27
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-17 09:53:27
#>  31:   failed   7.777778  5.0000000         NA 2026-09-17 09:53:27
#>  32:   failed   7.777778  3.8888889         NA 2026-09-17 09:53:27
#>  33:   failed   7.777778  2.7777778         NA 2026-09-17 09:53:27
#>  34:   failed   7.777778  1.6666667         NA 2026-09-17 09:53:27
#>  35:   failed   7.777778  0.5555556         NA 2026-09-17 09:53:27
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-17 09:53:27
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-17 09:53:27
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-17 09:53:27
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-17 09:53:27
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-17 09:53:27
#>  41:   failed   5.555556  5.0000000         NA 2026-09-17 09:53:27
#>  42:   failed   5.555556  3.8888889         NA 2026-09-17 09:53:27
#>  43:   failed   5.555556  2.7777778         NA 2026-09-17 09:53:27
#>  44:   failed   5.555556  1.6666667         NA 2026-09-17 09:53:27
#>  45:   failed   5.555556  0.5555556         NA 2026-09-17 09:53:27
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-17 09:53:27
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-17 09:53:27
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-17 09:53:27
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-17 09:53:27
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-17 09:53:27
#>  51:   failed   3.333333  5.0000000         NA 2026-09-17 09:53:27
#>  52:   failed   3.333333  3.8888889         NA 2026-09-17 09:53:27
#>  53:   failed   3.333333  2.7777778         NA 2026-09-17 09:53:27
#>  54:   failed   3.333333  1.6666667         NA 2026-09-17 09:53:27
#>  55:   failed   3.333333  0.5555556         NA 2026-09-17 09:53:27
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-17 09:53:27
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-17 09:53:27
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-17 09:53:27
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-17 09:53:27
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-17 09:53:27
#>  61:   failed   1.111111  5.0000000         NA 2026-09-17 09:53:27
#>  62:   failed   1.111111  3.8888889         NA 2026-09-17 09:53:27
#>  63:   failed   1.111111  2.7777778         NA 2026-09-17 09:53:27
#>  64:   failed   1.111111  1.6666667         NA 2026-09-17 09:53:27
#>  65:   failed   1.111111  0.5555556         NA 2026-09-17 09:53:27
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-17 09:53:27
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-17 09:53:27
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-17 09:53:27
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-17 09:53:27
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-17 09:53:27
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-17 09:53:27
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-17 09:53:27
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-17 09:53:27
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-17 09:53:27
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-17 09:53:27
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-17 09:53:27
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-17 09:53:27
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-17 09:53:27
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-17 09:53:27
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-17 09:53:27
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-17 09:53:27
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-17 09:53:27
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-17 09:53:27
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-17 09:53:27
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-17 09:53:27
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-17 09:53:27
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-17 09:53:27
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-17 09:53:27
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-17 09:53:27
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-17 09:53:27
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-17 09:53:27
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-17 09:53:27
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-17 09:53:27
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-17 09:53:27
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-17 09:53:27
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-17 09:53:27
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-17 09:53:27
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-17 09:53:27
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-17 09:53:27
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-17 09:53:27
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>   2: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>   3: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>   4: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>   5: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>   6: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>   7: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>   8: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>   9: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>  10: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>  11: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>  12: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>  13: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>  14: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>  15: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>  16: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>  17: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>  18: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>  19: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
#>  20: sinking_raccoon_a09c30c8 2026-09-17 09:53:28
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
#>   1: 40636753-dc83-438f-a9c9-1fa9303a9f27    [NULL]  -10.000000  -5.0000000
#>   2: 08065860-d5ab-485f-96cd-25886debf21c    [NULL]  -10.000000  -3.8888889
#>   3: c729967f-a64a-4b56-9698-871f144e0c9e    [NULL]  -10.000000  -2.7777778
#>   4: d5b87040-29a8-44c9-bb47-30737bc60f14    [NULL]  -10.000000  -1.6666667
#>   5: 6a72c363-6be4-4d2f-9562-54243b3b6fc2    [NULL]  -10.000000  -0.5555556
#>   6: ce877e54-b904-4cc0-a2b7-20a89048b5ae    [NULL]  -10.000000   0.5555556
#>   7: 8c674de5-1941-4d87-95dd-6a8405dfaea5    [NULL]  -10.000000   1.6666667
#>   8: 31385e20-fbee-414e-89eb-942113f7a3b4    [NULL]  -10.000000   2.7777778
#>   9: 28780713-da73-422d-b640-ced7446f83f4    [NULL]  -10.000000   3.8888889
#>  10: 8ec42333-4a7a-4fee-942a-6716ecfa4a9e    [NULL]  -10.000000   5.0000000
#>  11: f18970dd-25bf-456c-a6ee-3d267f3fdfdd    [NULL]   -7.777778  -5.0000000
#>  12: 7cb826be-af76-45c9-aaf1-7bbaa60acb6f    [NULL]   -7.777778  -3.8888889
#>  13: 12795df0-0a1d-4ed1-b6ee-428fc876402f    [NULL]   -7.777778  -2.7777778
#>  14: 84fd605e-48df-447d-8c8e-0265d612eaa1    [NULL]   -7.777778  -1.6666667
#>  15: 9693303a-2001-410e-a2ea-e4629e5460f5    [NULL]   -7.777778  -0.5555556
#>  16: 921b1c13-deb6-4860-9339-6cccadb40164    [NULL]   -7.777778   0.5555556
#>  17: c63a5753-68da-467f-874b-734421a22140    [NULL]   -7.777778   1.6666667
#>  18: c322b815-0a2f-4315-b18b-1371e0de4f0d    [NULL]   -7.777778   2.7777778
#>  19: 53e2f5aa-f872-4a4d-91e8-ce16b6de2694    [NULL]   -7.777778   3.8888889
#>  20: a2131991-b544-494c-ac5a-645e12c73809    [NULL]   -7.777778   5.0000000
#>  21: 781b2360-ab8f-4446-99d7-0a3a816b4610 <list[1]>          NA          NA
#>  22: 3cde0f7d-f87a-4326-8919-60b9bf5d68be <list[1]>          NA          NA
#>  23: 3968f2ad-c1cc-4b30-ae4e-5e2efe95a052 <list[1]>          NA          NA
#>  24: 0c9e8121-f216-40e8-86ed-57cff800581b <list[1]>          NA          NA
#>  25: 121e7774-e776-4969-a0ba-446f7ebc4b73 <list[1]>          NA          NA
#>  26: 15951ca5-b56a-4c7d-901d-34390a982e91 <list[1]>          NA          NA
#>  27: 434b295f-6fc5-49fa-afeb-d45b2a1a7985 <list[1]>          NA          NA
#>  28: f8b84f08-3766-4fa1-9a47-28bfc1c6b83c <list[1]>          NA          NA
#>  29: 7b343ba1-e6f4-401e-b753-a5d3e024db9d <list[1]>          NA          NA
#>  30: 31ebf233-b712-4ed1-9a9c-cab487673b7f <list[1]>          NA          NA
#>  31: 0ea1eb6b-d7d2-40ee-b912-1cb391fd6431 <list[1]>          NA          NA
#>  32: dc5ac2e2-bc8f-4b2c-9ca2-81eac4923441 <list[1]>          NA          NA
#>  33: 872923a1-4d35-4b02-9900-39badab86805 <list[1]>          NA          NA
#>  34: bdb72f21-7ad4-48ee-be13-ecad7467a64d <list[1]>          NA          NA
#>  35: 62c84cda-5057-4a6f-8c51-44f51bd28c9a <list[1]>          NA          NA
#>  36: c144f8a8-8064-41c8-a7a8-ec47c959b70a <list[1]>          NA          NA
#>  37: af0c54fb-dd9b-4096-aad1-6f063ea16786 <list[1]>          NA          NA
#>  38: 410da8ea-5dbb-4083-ac37-481871a8e5be <list[1]>          NA          NA
#>  39: 0825735d-b1b2-40ca-bd4f-c7e8a724c523 <list[1]>          NA          NA
#>  40: 8334d978-f12b-46b6-9c7c-f048e14ccd17 <list[1]>          NA          NA
#>  41: 5c2a8df3-28b0-4e62-a875-d5c70fb8db10 <list[1]>          NA          NA
#>  42: 48a245ad-9108-4535-b336-55a4e0a68b27 <list[1]>          NA          NA
#>  43: e7baef45-3942-4919-9e7f-939353bac02b <list[1]>          NA          NA
#>  44: 3c874dd8-dd11-4e0e-86cb-0596e66a355f <list[1]>          NA          NA
#>  45: 49e9ade8-ae8d-4af3-aa41-f0cb2a57a48a <list[1]>          NA          NA
#>  46: 5204f005-b355-4831-a91d-5fc6e6f8a180 <list[1]>          NA          NA
#>  47: ccd02768-a8c0-4528-be9e-3abe99c9f965 <list[1]>          NA          NA
#>  48: 98145cb2-d0cd-4096-b1d0-6ac0c3d53258 <list[1]>          NA          NA
#>  49: 59f7a68e-9a1e-4143-b51d-c3d29174f389 <list[1]>          NA          NA
#>  50: b321c928-7419-430e-b3e3-bf7178267fa5 <list[1]>          NA          NA
#>  51: 1c79a95a-2128-4cba-ae1f-4abc5338e7d6 <list[1]>          NA          NA
#>  52: 7795ecb9-b9e8-407e-b512-8be5934d428f <list[1]>          NA          NA
#>  53: e2ca66b0-f412-4873-9798-a7fc3f3d21d8 <list[1]>          NA          NA
#>  54: 129cb71a-6d09-4c31-a26e-474818bc2053 <list[1]>          NA          NA
#>  55: fc816532-3bdf-458e-86d6-262a9a8b2a96 <list[1]>          NA          NA
#>  56: 234ffa28-0c57-4947-83b4-5e12808f6ee5 <list[1]>          NA          NA
#>  57: b3bcbfde-3e93-42c2-9562-91dd2e74f232 <list[1]>          NA          NA
#>  58: bf334b4e-c1cd-4da2-9d8a-e892a4e7a5ba <list[1]>          NA          NA
#>  59: be0586b3-8136-45d9-8ae1-a42f9ac6023b <list[1]>          NA          NA
#>  60: 6991fbcf-628c-4957-b8a4-7e56033350d2 <list[1]>          NA          NA
#>  61: 28de2529-79f7-4f4b-813e-53af49dacce2 <list[1]>          NA          NA
#>  62: b2de1424-9163-4971-a089-98f2c0d1e530 <list[1]>          NA          NA
#>  63: 0bff81fe-28a3-45b1-906a-302c7121aead <list[1]>          NA          NA
#>  64: 25585fab-3146-4aba-9d55-a5a8b8074702 <list[1]>          NA          NA
#>  65: 8acf554c-b54c-41cc-81cc-dd850f10e358 <list[1]>          NA          NA
#>  66: a8b3bddf-ff8d-4249-b49c-ae6e4e0412f2 <list[1]>          NA          NA
#>  67: 8fa4a782-4087-4a99-9754-e7660aa868a5 <list[1]>          NA          NA
#>  68: 605fc44d-9091-4316-bf6b-3d027cb5c6f8 <list[1]>          NA          NA
#>  69: f9ba70c6-dccf-4f41-a0ce-e9b32867f0df <list[1]>          NA          NA
#>  70: b6681f19-70c2-4fa2-9992-85b46c9095d3 <list[1]>          NA          NA
#>  71: c21b3af3-67ac-4923-ae5e-083649e0199e <list[1]>          NA          NA
#>  72: d7b4555d-7617-4e17-944f-2c8e27dcfdde <list[1]>          NA          NA
#>  73: 0092a6a1-731d-445e-a59a-bf40de44f48c <list[1]>          NA          NA
#>  74: 56266c3c-3c32-41cc-ac1f-ffc46dfa8e74 <list[1]>          NA          NA
#>  75: d4dbbada-48e9-43ed-8ba4-a442f8b22f83 <list[1]>          NA          NA
#>  76: fcb2202d-ff5b-4c3d-beed-74f0688bfe09 <list[1]>          NA          NA
#>  77: 81e34b8d-cff7-431e-8da4-ff2826a0ed4f <list[1]>          NA          NA
#>  78: 8a6ee63c-646f-43d4-a85b-417f7711e999 <list[1]>          NA          NA
#>  79: 5c2d4f8d-e003-48e1-9e86-e3ecb7d117f2 <list[1]>          NA          NA
#>  80: a4954757-0ba8-448c-ba8e-abb5a29fb739 <list[1]>          NA          NA
#>  81: 02bd5476-77fa-412f-9258-5fa3c71f2c0a <list[1]>          NA          NA
#>  82: 9117f418-56c0-4d95-8d9c-91e8f0e6ba1f <list[1]>          NA          NA
#>  83: 199d2268-8e38-46de-ba9b-03e180c10daa <list[1]>          NA          NA
#>  84: 2ec247af-34d5-47ee-9121-2a8d68185c61 <list[1]>          NA          NA
#>  85: 3d63b678-c8bd-4196-862c-4f8b417c2d66 <list[1]>          NA          NA
#>  86: 680693b0-03a8-40f8-8424-2cce55ddb811 <list[1]>          NA          NA
#>  87: 519b07f3-9f80-4edd-8081-6d3ee74405a7 <list[1]>          NA          NA
#>  88: 125a8643-ab4b-42a2-8b06-36476ad48984 <list[1]>          NA          NA
#>  89: 37a11759-63b1-43d4-aaa6-2063b458c5be <list[1]>          NA          NA
#>  90: 96732580-8792-4194-87fd-2e38db3853ae <list[1]>          NA          NA
#>  91: 30c0ca4e-e7be-4c3f-aacb-07287482e142 <list[1]>          NA          NA
#>  92: d8581e8c-34ba-4072-9e28-be5046aca0fa <list[1]>          NA          NA
#>  93: 42e32103-3818-49a6-be4a-f8243d64197c <list[1]>          NA          NA
#>  94: c61e366a-2c84-47ac-aca8-4be7be898f17 <list[1]>          NA          NA
#>  95: eb8a857c-3a12-4848-96af-daf1af47f3ee <list[1]>          NA          NA
#>  96: 12621fd4-abad-4d5c-a7ea-43dc252c9de3 <list[1]>          NA          NA
#>  97: b5128dd6-a99d-47c8-892a-5218aa7f1da1 <list[1]>          NA          NA
#>  98: 3ef19112-2df0-4d1b-a76c-caa9f0b5f63c <list[1]>          NA          NA
#>  99: 4a07be81-dc0d-4c94-9791-077d741a8523 <list[1]>          NA          NA
#> 100: 403bf6ba-f136-423d-8e27-003d0649b87b <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
