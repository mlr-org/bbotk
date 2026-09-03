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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-03 11:40:12
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-03 11:40:12
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-03 11:40:12
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-03 11:40:12
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-03 11:40:12
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-03 11:40:12
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-03 11:40:12
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-03 11:40:12
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-03 11:40:12
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-03 11:40:12
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-03 11:40:12
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-03 11:40:12
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-03 11:40:12
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-03 11:40:12
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-03 11:40:12
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-03 11:40:12
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-03 11:40:12
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-03 11:40:12
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-03 11:40:12
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-03 11:40:12
#>  21:   failed  10.000000  5.0000000         NA 2026-09-03 11:40:12
#>  22:   failed  10.000000  3.8888889         NA 2026-09-03 11:40:12
#>  23:   failed  10.000000  2.7777778         NA 2026-09-03 11:40:12
#>  24:   failed  10.000000  1.6666667         NA 2026-09-03 11:40:12
#>  25:   failed  10.000000  0.5555556         NA 2026-09-03 11:40:12
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-03 11:40:12
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-03 11:40:12
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-03 11:40:12
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-03 11:40:12
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-03 11:40:12
#>  31:   failed   7.777778  5.0000000         NA 2026-09-03 11:40:12
#>  32:   failed   7.777778  3.8888889         NA 2026-09-03 11:40:12
#>  33:   failed   7.777778  2.7777778         NA 2026-09-03 11:40:12
#>  34:   failed   7.777778  1.6666667         NA 2026-09-03 11:40:12
#>  35:   failed   7.777778  0.5555556         NA 2026-09-03 11:40:12
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-03 11:40:12
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-03 11:40:12
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-03 11:40:12
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-03 11:40:12
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-03 11:40:12
#>  41:   failed   5.555556  5.0000000         NA 2026-09-03 11:40:12
#>  42:   failed   5.555556  3.8888889         NA 2026-09-03 11:40:12
#>  43:   failed   5.555556  2.7777778         NA 2026-09-03 11:40:12
#>  44:   failed   5.555556  1.6666667         NA 2026-09-03 11:40:12
#>  45:   failed   5.555556  0.5555556         NA 2026-09-03 11:40:12
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-03 11:40:12
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-03 11:40:12
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-03 11:40:12
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-03 11:40:12
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-03 11:40:12
#>  51:   failed   3.333333  5.0000000         NA 2026-09-03 11:40:12
#>  52:   failed   3.333333  3.8888889         NA 2026-09-03 11:40:12
#>  53:   failed   3.333333  2.7777778         NA 2026-09-03 11:40:12
#>  54:   failed   3.333333  1.6666667         NA 2026-09-03 11:40:12
#>  55:   failed   3.333333  0.5555556         NA 2026-09-03 11:40:12
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-03 11:40:12
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-03 11:40:12
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-03 11:40:12
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-03 11:40:12
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-03 11:40:12
#>  61:   failed   1.111111  5.0000000         NA 2026-09-03 11:40:12
#>  62:   failed   1.111111  3.8888889         NA 2026-09-03 11:40:12
#>  63:   failed   1.111111  2.7777778         NA 2026-09-03 11:40:12
#>  64:   failed   1.111111  1.6666667         NA 2026-09-03 11:40:12
#>  65:   failed   1.111111  0.5555556         NA 2026-09-03 11:40:12
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-03 11:40:12
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-03 11:40:12
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-03 11:40:12
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-03 11:40:12
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-03 11:40:12
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-03 11:40:12
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-03 11:40:12
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-03 11:40:12
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-03 11:40:12
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-03 11:40:12
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-03 11:40:12
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-03 11:40:12
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-03 11:40:12
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-03 11:40:12
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-03 11:40:12
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-03 11:40:12
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-03 11:40:12
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-03 11:40:12
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-03 11:40:12
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-03 11:40:12
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-03 11:40:12
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-03 11:40:12
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-03 11:40:12
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-03 11:40:12
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-03 11:40:12
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-03 11:40:12
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-03 11:40:12
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-03 11:40:12
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-03 11:40:12
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-03 11:40:12
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-03 11:40:12
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-03 11:40:12
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-03 11:40:12
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-03 11:40:12
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-03 11:40:12
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>   2: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>   3: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>   4: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>   5: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>   6: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>   7: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>   8: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>   9: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>  10: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>  11: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>  12: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>  13: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>  14: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>  15: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>  16: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>  17: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>  18: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>  19: sinking_raccoon_9191a15f 2026-09-03 11:40:13
#>  20: sinking_raccoon_9191a15f 2026-09-03 11:40:13
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
#>   1: b3d7a89c-4b8a-484b-afd1-665848dd975d    [NULL]  -10.000000  -5.0000000
#>   2: a8b01a5a-5499-4a9b-83c0-35de22ddb604    [NULL]  -10.000000  -3.8888889
#>   3: 23273869-a8a3-4f15-a95e-e478d84e4093    [NULL]  -10.000000  -2.7777778
#>   4: 7f479653-9b30-46ca-89fb-056e82d1638e    [NULL]  -10.000000  -1.6666667
#>   5: 8a174162-2193-4c37-92a9-63de1061a031    [NULL]  -10.000000  -0.5555556
#>   6: 99d4679d-efe8-4735-8831-f135ca5c88eb    [NULL]  -10.000000   0.5555556
#>   7: b14af0bf-0f5b-4b9c-bbe9-858763deb126    [NULL]  -10.000000   1.6666667
#>   8: 075c3bde-1226-4501-a0dd-89f3a9690e1f    [NULL]  -10.000000   2.7777778
#>   9: 60bcda31-ddec-4dfc-b03f-5eb163968d6b    [NULL]  -10.000000   3.8888889
#>  10: d94d9abf-c53f-4292-9fd7-d9d18063e514    [NULL]  -10.000000   5.0000000
#>  11: 62bb8cc4-b2e0-4674-a4c4-2194b977019a    [NULL]   -7.777778  -5.0000000
#>  12: 58b524de-4fb3-4b10-96b8-159825a319e9    [NULL]   -7.777778  -3.8888889
#>  13: 3587c2e7-5d39-4a67-8c81-d265644ea635    [NULL]   -7.777778  -2.7777778
#>  14: 5315eb12-21c3-45a6-b778-c913615fa33e    [NULL]   -7.777778  -1.6666667
#>  15: 6cd554ff-d08d-42b3-88b2-4d7dafa950a7    [NULL]   -7.777778  -0.5555556
#>  16: 398b7db5-1a8f-48a7-b43f-da836530aa11    [NULL]   -7.777778   0.5555556
#>  17: a0769728-6200-4acf-a2aa-725087c994ae    [NULL]   -7.777778   1.6666667
#>  18: 06aa155b-4522-4bb1-83d3-2c33cb023ed0    [NULL]   -7.777778   2.7777778
#>  19: a36dce41-672f-4279-a7ef-4bf6eb01c553    [NULL]   -7.777778   3.8888889
#>  20: 96725318-bdc5-46ca-8cd7-c2a12d3e688d    [NULL]   -7.777778   5.0000000
#>  21: d7cebb48-49a4-4516-ad2f-7897cee50ee4 <list[1]>          NA          NA
#>  22: 36e3308b-d545-471d-bfeb-fdfeb2affdc4 <list[1]>          NA          NA
#>  23: 85086b18-e666-4268-94e9-33f53711dae4 <list[1]>          NA          NA
#>  24: bac00e94-5e3b-433e-ace3-2d0e42975bb7 <list[1]>          NA          NA
#>  25: 9f209b0f-95b6-42c4-899f-ea008588d653 <list[1]>          NA          NA
#>  26: ded40575-3a92-4f56-9539-1ab78c0cabd1 <list[1]>          NA          NA
#>  27: 08f4672b-ac25-48b7-b681-125fd27f0fbc <list[1]>          NA          NA
#>  28: b44a5059-e13c-4c1c-bda8-da860147d637 <list[1]>          NA          NA
#>  29: d17f681b-3073-4fa1-96cf-8b82afe431e6 <list[1]>          NA          NA
#>  30: b8c06354-5ff3-4bbf-9396-1b3dad07210b <list[1]>          NA          NA
#>  31: 5a330093-7eab-4bcc-b166-df777df9ae34 <list[1]>          NA          NA
#>  32: 7db7e4f2-087b-4cb9-82c1-76ba5d56ec0d <list[1]>          NA          NA
#>  33: 8bb8b7a0-09fd-44ba-9bc5-55e5131ab123 <list[1]>          NA          NA
#>  34: 5f2d3f70-4230-4ffc-a3dc-4a7e06e5a8be <list[1]>          NA          NA
#>  35: aa70fefd-d579-4808-90d3-ca71f1e59d29 <list[1]>          NA          NA
#>  36: df747918-e66d-496b-b137-03756354edfc <list[1]>          NA          NA
#>  37: 88fde1f3-eaf8-4936-9a03-c7cf12c90927 <list[1]>          NA          NA
#>  38: b1c065ba-0e17-4e3b-8f03-7cd52c7b4d9f <list[1]>          NA          NA
#>  39: f38d68cb-495d-4592-a121-ee27e7692eb7 <list[1]>          NA          NA
#>  40: 1da1c41a-7929-45e6-89a9-81723edc64a2 <list[1]>          NA          NA
#>  41: 7dc3d090-82b8-4078-a4fd-220430838e52 <list[1]>          NA          NA
#>  42: 7f909359-873c-4a3d-8a33-018c12b4028e <list[1]>          NA          NA
#>  43: be5bd34a-2713-46f5-9087-bb5cb4f0d366 <list[1]>          NA          NA
#>  44: 5eb5543e-a811-445b-b3b1-602fde983c9a <list[1]>          NA          NA
#>  45: 90553acf-65af-42a6-ae9e-f2af55d2667c <list[1]>          NA          NA
#>  46: 763e94bf-4d46-4e67-9c63-ba2551b68743 <list[1]>          NA          NA
#>  47: 3fb24773-ad1a-4f83-bf9f-a7996146eaa7 <list[1]>          NA          NA
#>  48: 2a641d21-f9b3-4d6d-939a-fbe3246c4b1b <list[1]>          NA          NA
#>  49: df1189b7-e4d7-49a7-b39f-3ac8cecf29b8 <list[1]>          NA          NA
#>  50: 117b3c28-c83e-4f98-b8ea-1c56bd7c02ac <list[1]>          NA          NA
#>  51: 7e0e3175-cd3c-4038-8e36-f51224c5c009 <list[1]>          NA          NA
#>  52: f89e929c-99c2-42fb-bf89-e3fd9776304e <list[1]>          NA          NA
#>  53: 535ac5bf-ae13-40a0-b7a3-f7c6f75d6db7 <list[1]>          NA          NA
#>  54: 5618a4eb-56a3-485e-ac56-32b367ce8a0f <list[1]>          NA          NA
#>  55: c9697bad-6184-4f13-8232-bc6a6cf46389 <list[1]>          NA          NA
#>  56: 40450544-e24e-4275-9b28-3ac0fd22a15e <list[1]>          NA          NA
#>  57: 56c01044-896b-4a91-a62e-4a6b2e1430f9 <list[1]>          NA          NA
#>  58: 183abc07-dc91-4435-bbee-3b3da51b2b15 <list[1]>          NA          NA
#>  59: 44bad7fe-76b0-4fc8-8d7e-c64609b7035d <list[1]>          NA          NA
#>  60: f3302af8-7c9e-41e1-a6fd-c0b68dc42096 <list[1]>          NA          NA
#>  61: f7558bd8-0c34-486a-a16a-262392fd8098 <list[1]>          NA          NA
#>  62: 4518488a-7cd7-4d17-8383-dfff96ee2f04 <list[1]>          NA          NA
#>  63: 1aed5ea5-8abe-4389-9579-56262009d388 <list[1]>          NA          NA
#>  64: ae7f5947-8d55-46f2-a1c7-b4895250bebd <list[1]>          NA          NA
#>  65: 8597647f-960e-49de-8f47-e4ba6352f5b6 <list[1]>          NA          NA
#>  66: 9368a28b-a6a6-4411-bf2c-006c00d062c2 <list[1]>          NA          NA
#>  67: d5ec6a68-bb54-4e18-9228-e4b296c7f860 <list[1]>          NA          NA
#>  68: be7791c8-c47a-4b7f-aeef-7d80f9f4db11 <list[1]>          NA          NA
#>  69: ff0c1c4a-3722-46a3-9f32-1517c19f8229 <list[1]>          NA          NA
#>  70: 5d461d56-bbaa-4ce9-b626-5c3d491c2a3c <list[1]>          NA          NA
#>  71: 623b5f09-b51a-4128-89bf-277bbedaa145 <list[1]>          NA          NA
#>  72: a7180d56-346f-4930-bace-74619b3382f1 <list[1]>          NA          NA
#>  73: 0c214142-e7ed-4f0c-8710-eebee7e8f292 <list[1]>          NA          NA
#>  74: ae850202-eb27-45d3-9e15-4df219ec0290 <list[1]>          NA          NA
#>  75: 3c067b69-782d-4f6f-b1aa-141012f30725 <list[1]>          NA          NA
#>  76: 6cac8b16-b544-4613-a5b2-460f7cc06238 <list[1]>          NA          NA
#>  77: d066a84b-dbb1-46d9-8a90-f1ea5d70896e <list[1]>          NA          NA
#>  78: 6cd45ca4-cd59-4b1b-bdf3-7cdef87f9e4d <list[1]>          NA          NA
#>  79: b87fd391-2be7-4758-a2a2-08d30046718b <list[1]>          NA          NA
#>  80: 7cf9b89e-6874-423e-a757-f662844beebb <list[1]>          NA          NA
#>  81: 222b6508-ccf2-47cc-85d9-df6bac99ad0c <list[1]>          NA          NA
#>  82: ddb1f71d-30bc-45c7-a54b-6931c7d4fe9a <list[1]>          NA          NA
#>  83: 2946d913-7e02-4293-8041-f1a17c99af1c <list[1]>          NA          NA
#>  84: 97de01f8-552d-44d4-970d-2d59d7f78904 <list[1]>          NA          NA
#>  85: 3b51d3f8-0760-48d2-81b3-87b84e78b645 <list[1]>          NA          NA
#>  86: f2154923-6cb4-4574-83ab-cde0d1bd1bdb <list[1]>          NA          NA
#>  87: 9700f50a-e04e-46ad-9496-47f2d5498820 <list[1]>          NA          NA
#>  88: a4c45848-2cfa-431e-ba00-1b01b2ecc06e <list[1]>          NA          NA
#>  89: 178445b3-03d0-4a6d-9284-f1323e765635 <list[1]>          NA          NA
#>  90: 73c0416c-489f-4a03-bdeb-f003610cbaec <list[1]>          NA          NA
#>  91: 22727188-a7c7-4321-b6b1-bbffd4dae9dd <list[1]>          NA          NA
#>  92: 5e852b49-a792-4255-a769-1233b8814086 <list[1]>          NA          NA
#>  93: f6c782eb-377d-4e4c-88c6-9cec5921e5e6 <list[1]>          NA          NA
#>  94: c2661dd6-dc84-4dcf-9289-e4c404316a9c <list[1]>          NA          NA
#>  95: aa9b61ff-6f17-4c96-9b6e-967659e4b6f6 <list[1]>          NA          NA
#>  96: 46fc9993-a408-451b-8a40-738f282db295 <list[1]>          NA          NA
#>  97: 94f1d2bf-d58e-40d9-b608-a904eb9b2df7 <list[1]>          NA          NA
#>  98: c3639896-fe8b-4e78-9394-f77dd7a2e376 <list[1]>          NA          NA
#>  99: 5b104e06-8998-474c-83ec-96a90e291dfd <list[1]>          NA          NA
#> 100: 3adb6bf3-204f-4121-82ee-2fa827b09d32 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
