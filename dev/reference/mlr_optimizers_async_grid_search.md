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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-07-24 14:14:23
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-07-24 14:14:23
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-07-24 14:14:23
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-07-24 14:14:23
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-07-24 14:14:23
#>   6: finished -10.000000  0.5555556 -146.64198 2026-07-24 14:14:23
#>   7: finished -10.000000  1.6666667 -155.77778 2026-07-24 14:14:23
#>   8: finished -10.000000  2.7777778 -167.38272 2026-07-24 14:14:23
#>   9: finished -10.000000  3.8888889 -181.45679 2026-07-24 14:14:23
#>  10: finished -10.000000  5.0000000 -198.00000 2026-07-24 14:14:23
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-07-24 14:14:23
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-07-24 14:14:23
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-07-24 14:14:23
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-07-24 14:14:23
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-07-24 14:14:23
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-07-24 14:14:23
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-07-24 14:14:23
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-07-24 14:14:23
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-07-24 14:14:23
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-07-24 14:14:23
#>  21:   failed  10.000000  5.0000000         NA 2026-07-24 14:14:23
#>  22:   failed  10.000000  3.8888889         NA 2026-07-24 14:14:23
#>  23:   failed  10.000000  2.7777778         NA 2026-07-24 14:14:23
#>  24:   failed  10.000000  1.6666667         NA 2026-07-24 14:14:23
#>  25:   failed  10.000000  0.5555556         NA 2026-07-24 14:14:23
#>  26:   failed  10.000000 -0.5555556         NA 2026-07-24 14:14:23
#>  27:   failed  10.000000 -1.6666667         NA 2026-07-24 14:14:23
#>  28:   failed  10.000000 -2.7777778         NA 2026-07-24 14:14:23
#>  29:   failed  10.000000 -3.8888889         NA 2026-07-24 14:14:23
#>  30:   failed  10.000000 -5.0000000         NA 2026-07-24 14:14:23
#>  31:   failed   7.777778  5.0000000         NA 2026-07-24 14:14:23
#>  32:   failed   7.777778  3.8888889         NA 2026-07-24 14:14:23
#>  33:   failed   7.777778  2.7777778         NA 2026-07-24 14:14:23
#>  34:   failed   7.777778  1.6666667         NA 2026-07-24 14:14:23
#>  35:   failed   7.777778  0.5555556         NA 2026-07-24 14:14:23
#>  36:   failed   7.777778 -0.5555556         NA 2026-07-24 14:14:23
#>  37:   failed   7.777778 -1.6666667         NA 2026-07-24 14:14:23
#>  38:   failed   7.777778 -2.7777778         NA 2026-07-24 14:14:23
#>  39:   failed   7.777778 -3.8888889         NA 2026-07-24 14:14:23
#>  40:   failed   7.777778 -5.0000000         NA 2026-07-24 14:14:23
#>  41:   failed   5.555556  5.0000000         NA 2026-07-24 14:14:23
#>  42:   failed   5.555556  3.8888889         NA 2026-07-24 14:14:23
#>  43:   failed   5.555556  2.7777778         NA 2026-07-24 14:14:23
#>  44:   failed   5.555556  1.6666667         NA 2026-07-24 14:14:23
#>  45:   failed   5.555556  0.5555556         NA 2026-07-24 14:14:23
#>  46:   failed   5.555556 -0.5555556         NA 2026-07-24 14:14:23
#>  47:   failed   5.555556 -1.6666667         NA 2026-07-24 14:14:23
#>  48:   failed   5.555556 -2.7777778         NA 2026-07-24 14:14:23
#>  49:   failed   5.555556 -3.8888889         NA 2026-07-24 14:14:23
#>  50:   failed   5.555556 -5.0000000         NA 2026-07-24 14:14:23
#>  51:   failed   3.333333  5.0000000         NA 2026-07-24 14:14:23
#>  52:   failed   3.333333  3.8888889         NA 2026-07-24 14:14:23
#>  53:   failed   3.333333  2.7777778         NA 2026-07-24 14:14:23
#>  54:   failed   3.333333  1.6666667         NA 2026-07-24 14:14:23
#>  55:   failed   3.333333  0.5555556         NA 2026-07-24 14:14:23
#>  56:   failed   3.333333 -0.5555556         NA 2026-07-24 14:14:23
#>  57:   failed   3.333333 -1.6666667         NA 2026-07-24 14:14:23
#>  58:   failed   3.333333 -2.7777778         NA 2026-07-24 14:14:23
#>  59:   failed   3.333333 -3.8888889         NA 2026-07-24 14:14:23
#>  60:   failed   3.333333 -5.0000000         NA 2026-07-24 14:14:23
#>  61:   failed   1.111111  5.0000000         NA 2026-07-24 14:14:23
#>  62:   failed   1.111111  3.8888889         NA 2026-07-24 14:14:23
#>  63:   failed   1.111111  2.7777778         NA 2026-07-24 14:14:23
#>  64:   failed   1.111111  1.6666667         NA 2026-07-24 14:14:23
#>  65:   failed   1.111111  0.5555556         NA 2026-07-24 14:14:23
#>  66:   failed   1.111111 -0.5555556         NA 2026-07-24 14:14:23
#>  67:   failed   1.111111 -1.6666667         NA 2026-07-24 14:14:23
#>  68:   failed   1.111111 -2.7777778         NA 2026-07-24 14:14:23
#>  69:   failed   1.111111 -3.8888889         NA 2026-07-24 14:14:23
#>  70:   failed   1.111111 -5.0000000         NA 2026-07-24 14:14:23
#>  71:   failed  -1.111111  5.0000000         NA 2026-07-24 14:14:23
#>  72:   failed  -1.111111  3.8888889         NA 2026-07-24 14:14:23
#>  73:   failed  -1.111111  2.7777778         NA 2026-07-24 14:14:23
#>  74:   failed  -1.111111  1.6666667         NA 2026-07-24 14:14:23
#>  75:   failed  -1.111111  0.5555556         NA 2026-07-24 14:14:23
#>  76:   failed  -1.111111 -0.5555556         NA 2026-07-24 14:14:23
#>  77:   failed  -1.111111 -1.6666667         NA 2026-07-24 14:14:23
#>  78:   failed  -1.111111 -2.7777778         NA 2026-07-24 14:14:23
#>  79:   failed  -1.111111 -3.8888889         NA 2026-07-24 14:14:23
#>  80:   failed  -1.111111 -5.0000000         NA 2026-07-24 14:14:23
#>  81:   failed  -3.333333  5.0000000         NA 2026-07-24 14:14:23
#>  82:   failed  -3.333333  3.8888889         NA 2026-07-24 14:14:23
#>  83:   failed  -3.333333  2.7777778         NA 2026-07-24 14:14:23
#>  84:   failed  -3.333333  1.6666667         NA 2026-07-24 14:14:23
#>  85:   failed  -3.333333  0.5555556         NA 2026-07-24 14:14:23
#>  86:   failed  -3.333333 -0.5555556         NA 2026-07-24 14:14:23
#>  87:   failed  -3.333333 -1.6666667         NA 2026-07-24 14:14:23
#>  88:   failed  -3.333333 -2.7777778         NA 2026-07-24 14:14:23
#>  89:   failed  -3.333333 -3.8888889         NA 2026-07-24 14:14:23
#>  90:   failed  -3.333333 -5.0000000         NA 2026-07-24 14:14:23
#>  91:   failed  -5.555556  5.0000000         NA 2026-07-24 14:14:23
#>  92:   failed  -5.555556  3.8888889         NA 2026-07-24 14:14:23
#>  93:   failed  -5.555556  2.7777778         NA 2026-07-24 14:14:23
#>  94:   failed  -5.555556  1.6666667         NA 2026-07-24 14:14:23
#>  95:   failed  -5.555556  0.5555556         NA 2026-07-24 14:14:23
#>  96:   failed  -5.555556 -0.5555556         NA 2026-07-24 14:14:23
#>  97:   failed  -5.555556 -1.6666667         NA 2026-07-24 14:14:23
#>  98:   failed  -5.555556 -2.7777778         NA 2026-07-24 14:14:23
#>  99:   failed  -5.555556 -3.8888889         NA 2026-07-24 14:14:23
#> 100:   failed  -5.555556 -5.0000000         NA 2026-07-24 14:14:23
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>   2: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>   3: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>   4: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>   5: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>   6: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>   7: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>   8: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>   9: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>  10: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>  11: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>  12: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>  13: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>  14: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>  15: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>  16: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>  17: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>  18: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>  19: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
#>  20: sinking_raccoon_7bfe72ed 2026-07-24 14:14:24
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
#>   1: 7186717d-1c0f-4f4b-80d9-9978e977284d    [NULL]  -10.000000  -5.0000000
#>   2: 9b3bad4f-bb77-41ac-ba03-fa5bd75a9cd4    [NULL]  -10.000000  -3.8888889
#>   3: 1609232a-d0ac-444b-9804-34b620253eac    [NULL]  -10.000000  -2.7777778
#>   4: b9f17acf-e7a0-4100-a843-09f947ed6f60    [NULL]  -10.000000  -1.6666667
#>   5: 11935e67-9901-436a-b98d-d37cd970ac8a    [NULL]  -10.000000  -0.5555556
#>   6: 56055203-dc9e-406e-8020-efa2a128cbda    [NULL]  -10.000000   0.5555556
#>   7: 82cbb4c6-ee68-42a9-bdd1-5bafcc0d051f    [NULL]  -10.000000   1.6666667
#>   8: 8cc06b02-1dc1-44f0-8441-332fe363c659    [NULL]  -10.000000   2.7777778
#>   9: 303ec8c4-7715-45c0-9abd-c45fb1974b77    [NULL]  -10.000000   3.8888889
#>  10: bb97a071-c3e7-4b45-b811-878289046114    [NULL]  -10.000000   5.0000000
#>  11: 895a7576-07f5-49fb-b6cb-baa8df85a0b8    [NULL]   -7.777778  -5.0000000
#>  12: ee827e3e-84fb-47a7-ab54-61b87ced70c8    [NULL]   -7.777778  -3.8888889
#>  13: 570549e3-fe06-435b-9ad0-93dc4ffddcc6    [NULL]   -7.777778  -2.7777778
#>  14: 696b22ca-dc73-4470-930b-777ec985d884    [NULL]   -7.777778  -1.6666667
#>  15: 80d1bb87-a88d-4025-b47b-6db1b1d911ef    [NULL]   -7.777778  -0.5555556
#>  16: 110c62bf-a05c-4d8d-b82b-bed0f0c56d85    [NULL]   -7.777778   0.5555556
#>  17: 1142b404-c0eb-4d95-93fc-ae6c07c9e757    [NULL]   -7.777778   1.6666667
#>  18: 6d966156-9f3f-4ec9-a790-92c4e3d79d0b    [NULL]   -7.777778   2.7777778
#>  19: 9e7c0284-7e96-42f0-84f4-7e68b8ac0353    [NULL]   -7.777778   3.8888889
#>  20: ce25e730-950c-49cc-a25f-5d42bff655c0    [NULL]   -7.777778   5.0000000
#>  21: 86eba6e3-39fb-4c8b-b8fb-2ff9940e5d2d <list[1]>          NA          NA
#>  22: 2905dd47-9174-4aca-bcee-e1fd57779ab0 <list[1]>          NA          NA
#>  23: c27d7058-2eb1-4063-88c2-34d3a3342f0c <list[1]>          NA          NA
#>  24: 95a396ab-a968-4488-9c2d-583b228c4e4f <list[1]>          NA          NA
#>  25: 2031e7cb-332d-4106-8b0f-760d1d58f154 <list[1]>          NA          NA
#>  26: edc08cca-0701-4234-b867-eb2064db3812 <list[1]>          NA          NA
#>  27: 88616604-1ebc-4bcb-a70b-4073c6a02347 <list[1]>          NA          NA
#>  28: f493609a-76c7-47f4-8dbb-64d491d06399 <list[1]>          NA          NA
#>  29: ab948188-ef74-4d4b-9c9d-53cc68c9e88d <list[1]>          NA          NA
#>  30: f274d320-a4c0-42c5-bc91-b3c2373037d1 <list[1]>          NA          NA
#>  31: 06456ae5-d8d4-44c8-9cf7-97d3f8ce4f15 <list[1]>          NA          NA
#>  32: 62db0583-4611-4a6a-a1d1-836ed66f5df3 <list[1]>          NA          NA
#>  33: 0ff3414c-ad0b-463a-983c-6683bb942c9f <list[1]>          NA          NA
#>  34: 1a67d17e-1588-4dde-b427-c88e50adb2c3 <list[1]>          NA          NA
#>  35: ea7e4cbe-c867-4176-8b2d-d73f2e8e1a3b <list[1]>          NA          NA
#>  36: 80685cdc-2336-42be-a29a-d7cc7ad740c4 <list[1]>          NA          NA
#>  37: 2182dc33-7189-4df7-bfa5-1cacc2f022cb <list[1]>          NA          NA
#>  38: 4990a988-98dd-4a4a-acfe-eef1c48b4b08 <list[1]>          NA          NA
#>  39: 462ce47d-0af7-4945-877e-28f98529492a <list[1]>          NA          NA
#>  40: e8a7df4a-2eaa-433c-947a-863af2884d42 <list[1]>          NA          NA
#>  41: 187c055a-a1a1-44b1-ba46-3bcd052c0274 <list[1]>          NA          NA
#>  42: 867810d9-a258-4723-b2b6-4372cf03cfc9 <list[1]>          NA          NA
#>  43: 4d8b5a07-f1cc-4add-a5c6-b9509272daab <list[1]>          NA          NA
#>  44: 6bdf914f-98f6-413f-90b9-ec31242c1d10 <list[1]>          NA          NA
#>  45: 03b21f51-9f5d-4a56-b0a8-e8d435c3021d <list[1]>          NA          NA
#>  46: fa92faa8-5ce6-46e4-8854-5274aab0d02d <list[1]>          NA          NA
#>  47: 6e1ddf92-c0a1-4518-80c3-60deccf208fc <list[1]>          NA          NA
#>  48: d773647c-982c-481a-9fdd-fe0ade7d9704 <list[1]>          NA          NA
#>  49: e73f0e3a-4402-494f-a6d8-a8156dad1381 <list[1]>          NA          NA
#>  50: e4520e82-c3d7-4ad1-a7a5-db4a047ffe23 <list[1]>          NA          NA
#>  51: f024b1b8-8cca-4fe2-aa95-b1ade60b7f34 <list[1]>          NA          NA
#>  52: 687f10a7-8159-44dc-9ce3-1be6122f01a9 <list[1]>          NA          NA
#>  53: c6db80e4-e42c-4c8f-b67d-aa7af748d595 <list[1]>          NA          NA
#>  54: 3dc34f7f-6679-40db-8e55-b22e07025a59 <list[1]>          NA          NA
#>  55: c9d8b2c7-9261-44a4-8d97-dfd134b724f9 <list[1]>          NA          NA
#>  56: fcd83c6a-f08b-4f5a-a7e0-f90158fec822 <list[1]>          NA          NA
#>  57: f68dd12e-f27e-475d-bab2-a42269511caf <list[1]>          NA          NA
#>  58: 383a4611-1363-41b6-bbeb-d36cd8fe0366 <list[1]>          NA          NA
#>  59: 7b4cfb49-a609-4efa-86d5-c93c29e07a9e <list[1]>          NA          NA
#>  60: e2711919-2267-4e20-bc9f-1a61fd59c761 <list[1]>          NA          NA
#>  61: ab02cc2b-2669-4db3-933f-646df3273b0b <list[1]>          NA          NA
#>  62: 0abc2799-89f5-4f82-b635-b90ce1016219 <list[1]>          NA          NA
#>  63: df7f872d-9af2-46d9-8fa2-50cc2005e663 <list[1]>          NA          NA
#>  64: e90ecff6-8369-4aef-bc84-645aa5e9203c <list[1]>          NA          NA
#>  65: ab288fa8-96a5-4636-9f11-d553841c8569 <list[1]>          NA          NA
#>  66: e9bd18c3-d8e0-4b4f-9e17-f6a153bafa05 <list[1]>          NA          NA
#>  67: 18f35811-f2eb-4fb4-9380-4bb052b05259 <list[1]>          NA          NA
#>  68: a1f46990-7d55-4c9b-8180-0cebbd01a055 <list[1]>          NA          NA
#>  69: 833e1d4f-8778-409f-a1a4-3079c37dcf77 <list[1]>          NA          NA
#>  70: 295f21a7-050d-4289-99f5-77c5f526a7d7 <list[1]>          NA          NA
#>  71: c3ed5b4b-2a31-40cb-bfcc-9efebf8d264b <list[1]>          NA          NA
#>  72: f122ec81-6c43-4aac-8b12-999c45a0494b <list[1]>          NA          NA
#>  73: 8dfbe85e-0433-4629-a730-f288dfc32e30 <list[1]>          NA          NA
#>  74: b0540075-f1aa-46c2-b481-86efe6251669 <list[1]>          NA          NA
#>  75: b611a413-42f5-49ee-a258-c9816d6d28bd <list[1]>          NA          NA
#>  76: 3185b1f8-111e-46b7-a79e-2c06c2a4d4cd <list[1]>          NA          NA
#>  77: f1d791bd-8032-4249-904a-0b4da3213f41 <list[1]>          NA          NA
#>  78: 8860852f-127a-498d-b207-80c8f7111985 <list[1]>          NA          NA
#>  79: 11a7efb3-aa4f-4920-9cdc-cd34dff6fe0a <list[1]>          NA          NA
#>  80: 67fe3eb4-17d3-47f4-9301-22d606f2204c <list[1]>          NA          NA
#>  81: a74d00a5-c684-4449-8dcf-c45a158c8adf <list[1]>          NA          NA
#>  82: b8bf7d91-2603-4ff0-8400-2c04ab275011 <list[1]>          NA          NA
#>  83: 1de93826-e989-4bf9-a654-ca04a21d5e77 <list[1]>          NA          NA
#>  84: e30be432-2956-4672-8bba-22c1785522cf <list[1]>          NA          NA
#>  85: af5d4ea2-cab6-49bd-a960-ee198a372dbf <list[1]>          NA          NA
#>  86: 9c180483-7bbb-4c4b-8d88-6fa05cb974ef <list[1]>          NA          NA
#>  87: 67ac7d5f-2cd8-4b0b-9cd4-d440f0fe6f5e <list[1]>          NA          NA
#>  88: cfb8f213-6d81-470f-bacb-f7e47b39b0c5 <list[1]>          NA          NA
#>  89: 0415dc01-95dc-4e8e-9c22-374c10b3e287 <list[1]>          NA          NA
#>  90: 42f62539-d279-4cec-bee9-1ff96f5c66f1 <list[1]>          NA          NA
#>  91: 2192fa98-86d1-4245-b42e-a400a40284fd <list[1]>          NA          NA
#>  92: 8133d860-a7f6-428e-a34b-26301acb0889 <list[1]>          NA          NA
#>  93: 9248f9ab-47ad-4b88-9947-bad5fb809532 <list[1]>          NA          NA
#>  94: a30aa55a-de47-4e9c-b7ea-37db785e75dc <list[1]>          NA          NA
#>  95: 0015994e-14a7-4d83-9f31-653a287bcfa4 <list[1]>          NA          NA
#>  96: cada48fc-4d56-4837-9fea-e347db9c8f61 <list[1]>          NA          NA
#>  97: 8351c5a6-0b6f-4033-a7c0-a15a4f769e13 <list[1]>          NA          NA
#>  98: 68c4763a-05f1-48cd-a7dd-408542c7b9db <list[1]>          NA          NA
#>  99: acd46d38-8e7d-4fad-aa11-5364e716538f <list[1]>          NA          NA
#> 100: 3789bbda-b1ef-418e-97a1-16352562bac8 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
