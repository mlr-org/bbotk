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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-07-14 15:10:20
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-07-14 15:10:20
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-07-14 15:10:20
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-07-14 15:10:20
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-07-14 15:10:20
#>   6: finished -10.000000  0.5555556 -146.64198 2026-07-14 15:10:20
#>   7: finished -10.000000  1.6666667 -155.77778 2026-07-14 15:10:20
#>   8: finished -10.000000  2.7777778 -167.38272 2026-07-14 15:10:20
#>   9: finished -10.000000  3.8888889 -181.45679 2026-07-14 15:10:20
#>  10: finished -10.000000  5.0000000 -198.00000 2026-07-14 15:10:20
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-07-14 15:10:20
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-07-14 15:10:20
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-07-14 15:10:20
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-07-14 15:10:20
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-07-14 15:10:20
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-07-14 15:10:20
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-07-14 15:10:20
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-07-14 15:10:20
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-07-14 15:10:20
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-07-14 15:10:20
#>  21:   failed  10.000000  5.0000000         NA 2026-07-14 15:10:20
#>  22:   failed  10.000000  3.8888889         NA 2026-07-14 15:10:20
#>  23:   failed  10.000000  2.7777778         NA 2026-07-14 15:10:20
#>  24:   failed  10.000000  1.6666667         NA 2026-07-14 15:10:20
#>  25:   failed  10.000000  0.5555556         NA 2026-07-14 15:10:20
#>  26:   failed  10.000000 -0.5555556         NA 2026-07-14 15:10:20
#>  27:   failed  10.000000 -1.6666667         NA 2026-07-14 15:10:20
#>  28:   failed  10.000000 -2.7777778         NA 2026-07-14 15:10:20
#>  29:   failed  10.000000 -3.8888889         NA 2026-07-14 15:10:20
#>  30:   failed  10.000000 -5.0000000         NA 2026-07-14 15:10:20
#>  31:   failed   7.777778  5.0000000         NA 2026-07-14 15:10:20
#>  32:   failed   7.777778  3.8888889         NA 2026-07-14 15:10:20
#>  33:   failed   7.777778  2.7777778         NA 2026-07-14 15:10:20
#>  34:   failed   7.777778  1.6666667         NA 2026-07-14 15:10:20
#>  35:   failed   7.777778  0.5555556         NA 2026-07-14 15:10:20
#>  36:   failed   7.777778 -0.5555556         NA 2026-07-14 15:10:20
#>  37:   failed   7.777778 -1.6666667         NA 2026-07-14 15:10:20
#>  38:   failed   7.777778 -2.7777778         NA 2026-07-14 15:10:20
#>  39:   failed   7.777778 -3.8888889         NA 2026-07-14 15:10:20
#>  40:   failed   7.777778 -5.0000000         NA 2026-07-14 15:10:20
#>  41:   failed   5.555556  5.0000000         NA 2026-07-14 15:10:20
#>  42:   failed   5.555556  3.8888889         NA 2026-07-14 15:10:20
#>  43:   failed   5.555556  2.7777778         NA 2026-07-14 15:10:20
#>  44:   failed   5.555556  1.6666667         NA 2026-07-14 15:10:20
#>  45:   failed   5.555556  0.5555556         NA 2026-07-14 15:10:20
#>  46:   failed   5.555556 -0.5555556         NA 2026-07-14 15:10:20
#>  47:   failed   5.555556 -1.6666667         NA 2026-07-14 15:10:20
#>  48:   failed   5.555556 -2.7777778         NA 2026-07-14 15:10:20
#>  49:   failed   5.555556 -3.8888889         NA 2026-07-14 15:10:20
#>  50:   failed   5.555556 -5.0000000         NA 2026-07-14 15:10:20
#>  51:   failed   3.333333  5.0000000         NA 2026-07-14 15:10:20
#>  52:   failed   3.333333  3.8888889         NA 2026-07-14 15:10:20
#>  53:   failed   3.333333  2.7777778         NA 2026-07-14 15:10:20
#>  54:   failed   3.333333  1.6666667         NA 2026-07-14 15:10:20
#>  55:   failed   3.333333  0.5555556         NA 2026-07-14 15:10:20
#>  56:   failed   3.333333 -0.5555556         NA 2026-07-14 15:10:20
#>  57:   failed   3.333333 -1.6666667         NA 2026-07-14 15:10:20
#>  58:   failed   3.333333 -2.7777778         NA 2026-07-14 15:10:20
#>  59:   failed   3.333333 -3.8888889         NA 2026-07-14 15:10:20
#>  60:   failed   3.333333 -5.0000000         NA 2026-07-14 15:10:20
#>  61:   failed   1.111111  5.0000000         NA 2026-07-14 15:10:20
#>  62:   failed   1.111111  3.8888889         NA 2026-07-14 15:10:20
#>  63:   failed   1.111111  2.7777778         NA 2026-07-14 15:10:20
#>  64:   failed   1.111111  1.6666667         NA 2026-07-14 15:10:20
#>  65:   failed   1.111111  0.5555556         NA 2026-07-14 15:10:20
#>  66:   failed   1.111111 -0.5555556         NA 2026-07-14 15:10:20
#>  67:   failed   1.111111 -1.6666667         NA 2026-07-14 15:10:20
#>  68:   failed   1.111111 -2.7777778         NA 2026-07-14 15:10:20
#>  69:   failed   1.111111 -3.8888889         NA 2026-07-14 15:10:20
#>  70:   failed   1.111111 -5.0000000         NA 2026-07-14 15:10:20
#>  71:   failed  -1.111111  5.0000000         NA 2026-07-14 15:10:20
#>  72:   failed  -1.111111  3.8888889         NA 2026-07-14 15:10:20
#>  73:   failed  -1.111111  2.7777778         NA 2026-07-14 15:10:20
#>  74:   failed  -1.111111  1.6666667         NA 2026-07-14 15:10:20
#>  75:   failed  -1.111111  0.5555556         NA 2026-07-14 15:10:20
#>  76:   failed  -1.111111 -0.5555556         NA 2026-07-14 15:10:20
#>  77:   failed  -1.111111 -1.6666667         NA 2026-07-14 15:10:20
#>  78:   failed  -1.111111 -2.7777778         NA 2026-07-14 15:10:20
#>  79:   failed  -1.111111 -3.8888889         NA 2026-07-14 15:10:20
#>  80:   failed  -1.111111 -5.0000000         NA 2026-07-14 15:10:20
#>  81:   failed  -3.333333  5.0000000         NA 2026-07-14 15:10:20
#>  82:   failed  -3.333333  3.8888889         NA 2026-07-14 15:10:20
#>  83:   failed  -3.333333  2.7777778         NA 2026-07-14 15:10:20
#>  84:   failed  -3.333333  1.6666667         NA 2026-07-14 15:10:20
#>  85:   failed  -3.333333  0.5555556         NA 2026-07-14 15:10:20
#>  86:   failed  -3.333333 -0.5555556         NA 2026-07-14 15:10:20
#>  87:   failed  -3.333333 -1.6666667         NA 2026-07-14 15:10:20
#>  88:   failed  -3.333333 -2.7777778         NA 2026-07-14 15:10:20
#>  89:   failed  -3.333333 -3.8888889         NA 2026-07-14 15:10:20
#>  90:   failed  -3.333333 -5.0000000         NA 2026-07-14 15:10:20
#>  91:   failed  -5.555556  5.0000000         NA 2026-07-14 15:10:20
#>  92:   failed  -5.555556  3.8888889         NA 2026-07-14 15:10:20
#>  93:   failed  -5.555556  2.7777778         NA 2026-07-14 15:10:20
#>  94:   failed  -5.555556  1.6666667         NA 2026-07-14 15:10:20
#>  95:   failed  -5.555556  0.5555556         NA 2026-07-14 15:10:20
#>  96:   failed  -5.555556 -0.5555556         NA 2026-07-14 15:10:20
#>  97:   failed  -5.555556 -1.6666667         NA 2026-07-14 15:10:20
#>  98:   failed  -5.555556 -2.7777778         NA 2026-07-14 15:10:20
#>  99:   failed  -5.555556 -3.8888889         NA 2026-07-14 15:10:20
#> 100:   failed  -5.555556 -5.0000000         NA 2026-07-14 15:10:20
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>   2: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>   3: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>   4: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>   5: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>   6: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>   7: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>   8: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>   9: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>  10: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>  11: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>  12: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>  13: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>  14: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>  15: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>  16: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>  17: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>  18: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>  19: sinking_raccoon_2b7a95d0 2026-07-14 15:10:21
#>  20: sinking_raccoon_2b7a95d0 2026-07-14 15:10:22
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
#>   1: 64f1a2ad-73d7-44c6-8109-0b7e2879b317    [NULL]  -10.000000  -5.0000000
#>   2: 9eeb503d-4a95-4fc6-9624-08e4046e0c55    [NULL]  -10.000000  -3.8888889
#>   3: d84c30ca-97a5-4503-830c-dc4056f0b40b    [NULL]  -10.000000  -2.7777778
#>   4: d8b354de-e1f1-4b20-a88f-7c2367fe908c    [NULL]  -10.000000  -1.6666667
#>   5: d481c228-a3e6-40ad-a4b0-ff74015df6db    [NULL]  -10.000000  -0.5555556
#>   6: e0deac83-b497-4eae-ab9a-2e6f7c2c067b    [NULL]  -10.000000   0.5555556
#>   7: 516860ed-cb2a-41bf-841e-c35d81be5ede    [NULL]  -10.000000   1.6666667
#>   8: 6e0aabb5-6dc3-4719-ba6f-50f146905a1b    [NULL]  -10.000000   2.7777778
#>   9: 1da43a46-befb-48e5-b117-28cb2aa8f6bd    [NULL]  -10.000000   3.8888889
#>  10: 9788e782-4a50-450c-97c6-88da0ac614d7    [NULL]  -10.000000   5.0000000
#>  11: 885eb32f-8d80-4f67-a9d5-be6dd5aad50d    [NULL]   -7.777778  -5.0000000
#>  12: 274e209e-d9e3-4c11-bc38-788134379374    [NULL]   -7.777778  -3.8888889
#>  13: 3f34dfb4-5540-4ea6-970e-41ec54d9e1f5    [NULL]   -7.777778  -2.7777778
#>  14: 63568c77-7f2e-442c-a65e-448ff022653f    [NULL]   -7.777778  -1.6666667
#>  15: a01bc2ac-18c1-4a08-8eb8-d19702561f84    [NULL]   -7.777778  -0.5555556
#>  16: 43298a38-dec2-47b9-ae02-fd7318be410b    [NULL]   -7.777778   0.5555556
#>  17: 75a3ec4c-c5ed-41a7-aa27-32657bf6ecd3    [NULL]   -7.777778   1.6666667
#>  18: ef70c1b3-5ba9-4432-9aa7-cfb9d03778c3    [NULL]   -7.777778   2.7777778
#>  19: a66e36e5-dfe7-4990-8a3d-83821bf48e15    [NULL]   -7.777778   3.8888889
#>  20: 42b4a093-94dd-4634-a922-6fc1108f74ed    [NULL]   -7.777778   5.0000000
#>  21: 031b2339-1dc8-487d-844f-6b53c1724e81 <list[1]>          NA          NA
#>  22: 71a981db-4246-41ec-93c6-cb988d8c359e <list[1]>          NA          NA
#>  23: cd2a361a-bbba-4958-95f6-82bafe751b6b <list[1]>          NA          NA
#>  24: 52785fa3-4256-4f6a-b67e-54b5e0de6865 <list[1]>          NA          NA
#>  25: fb499357-b2d6-4ffc-95cc-815f6d004c24 <list[1]>          NA          NA
#>  26: a8d017f7-9bc9-489c-a36e-0c0f31dd18ee <list[1]>          NA          NA
#>  27: e896d3db-0c14-433d-8966-b7581ba8f1b7 <list[1]>          NA          NA
#>  28: 27514c46-1a62-45dd-8808-713d567f09de <list[1]>          NA          NA
#>  29: 940c1c50-a582-4745-a1c3-0e6298a690fb <list[1]>          NA          NA
#>  30: 6646312a-5248-4c50-a906-bf7f7d420b85 <list[1]>          NA          NA
#>  31: 424d584f-82c5-4c26-b81b-416e6a46d6bc <list[1]>          NA          NA
#>  32: 76bcaf1f-d820-484e-afc8-f6ac092774b9 <list[1]>          NA          NA
#>  33: e1756ce3-aedd-43a1-bd97-625223ae0ff6 <list[1]>          NA          NA
#>  34: cdbef6bf-32f0-4932-865d-fad417e4d3d0 <list[1]>          NA          NA
#>  35: 93f8861a-d681-4475-a7e1-dc6677882d54 <list[1]>          NA          NA
#>  36: 13b0f690-4016-446e-ad68-3a1a14c80637 <list[1]>          NA          NA
#>  37: 5ab87c92-73e3-42c6-8588-43a089a187b2 <list[1]>          NA          NA
#>  38: d17d8113-7162-4b0d-8830-db64666a2130 <list[1]>          NA          NA
#>  39: 103c03d5-e707-477b-93f3-cca123d4c176 <list[1]>          NA          NA
#>  40: 5909bc6b-78f0-4c05-b73b-46be20672b89 <list[1]>          NA          NA
#>  41: 9e7f6259-eba0-4a69-8ee3-df5311f2ac53 <list[1]>          NA          NA
#>  42: f59ad52e-33ff-4e8f-9b99-40c96c503cae <list[1]>          NA          NA
#>  43: 0f189689-b686-4670-b607-be99c337ce26 <list[1]>          NA          NA
#>  44: bf061446-5b7a-4116-af1c-dfa544ced919 <list[1]>          NA          NA
#>  45: 61fd44eb-5cdd-406d-a574-0f4f817169e0 <list[1]>          NA          NA
#>  46: e5c8a2d4-1fce-4262-aef0-5ced3beade83 <list[1]>          NA          NA
#>  47: fe9c0049-2d99-472b-a9e6-986aa170d769 <list[1]>          NA          NA
#>  48: 48a6597b-3165-4932-a928-15fd108ba288 <list[1]>          NA          NA
#>  49: fa4c8974-34e1-4bcc-bc53-a8d00320ab05 <list[1]>          NA          NA
#>  50: 72576c2c-2067-4758-a9c6-33df627fa4f1 <list[1]>          NA          NA
#>  51: e1f4fa08-061f-4f93-8de0-ab7345bb83b3 <list[1]>          NA          NA
#>  52: a14b5a51-5d33-4fae-8f90-c729a008a893 <list[1]>          NA          NA
#>  53: f07ada3a-701e-4f92-8f6f-5148cb2144a4 <list[1]>          NA          NA
#>  54: b75a8200-1a20-45f4-bf5f-587d83171994 <list[1]>          NA          NA
#>  55: 6157fd9e-e68b-43de-a48b-58a5cd16507b <list[1]>          NA          NA
#>  56: 1836ead5-5457-4afa-9ffc-b50c0871b24d <list[1]>          NA          NA
#>  57: d12ff0ec-f3ee-4b43-a0c4-0f8338b74933 <list[1]>          NA          NA
#>  58: 7cf4b522-7183-4e36-9438-58a23dd38fc2 <list[1]>          NA          NA
#>  59: 08848ad3-4d99-49af-8c14-6e341615f216 <list[1]>          NA          NA
#>  60: ba1e012b-a5d0-4a05-9c8c-4bbfbe126f3b <list[1]>          NA          NA
#>  61: 0348e90d-c9a9-43d3-97fc-b44dc3fd4cff <list[1]>          NA          NA
#>  62: 9e707743-8494-49c2-a75e-c2b7aeaf67ee <list[1]>          NA          NA
#>  63: cccebf72-30a2-4c24-8999-88d47bc939dd <list[1]>          NA          NA
#>  64: 8cdf0972-c265-486c-b745-a245806b5747 <list[1]>          NA          NA
#>  65: f1ee5e0a-d14c-4b37-bc77-b6344131b08d <list[1]>          NA          NA
#>  66: f97f088a-8973-4a6a-9a70-533d639e3518 <list[1]>          NA          NA
#>  67: 1cc1a74a-ec7d-4e61-9a7e-5ab1a5bbd46d <list[1]>          NA          NA
#>  68: d043f588-a439-470b-9e85-e81555936d98 <list[1]>          NA          NA
#>  69: a83556e4-81f8-449b-a3df-da8782720cd0 <list[1]>          NA          NA
#>  70: bb413394-4d03-4d29-b09f-48e36a9109ea <list[1]>          NA          NA
#>  71: f3bd968c-dfc1-4620-9b52-b1e2d658dbea <list[1]>          NA          NA
#>  72: 14d774b4-aef2-40bb-94a1-7c31eadfa3ad <list[1]>          NA          NA
#>  73: a5859887-dc53-4c6a-9713-0dfb46e3b090 <list[1]>          NA          NA
#>  74: 62e05b9f-a20e-405f-88be-34bb575b77da <list[1]>          NA          NA
#>  75: d4041ed0-473e-4014-bbaf-2e0e83fd4356 <list[1]>          NA          NA
#>  76: 3b926be2-6c88-4342-8501-0c0de1f765f7 <list[1]>          NA          NA
#>  77: c9b17141-dbe7-4da6-9217-0f6cca9c405f <list[1]>          NA          NA
#>  78: 0e668de8-d411-41a4-b0e4-ad094aca540b <list[1]>          NA          NA
#>  79: d7f885ab-6693-4491-9163-788c8975a5cc <list[1]>          NA          NA
#>  80: ab8ac699-f662-4f67-b79d-e3674a241f9f <list[1]>          NA          NA
#>  81: 46fe9b41-fc26-40c1-a06b-e30f0aed0ddd <list[1]>          NA          NA
#>  82: be337c70-a248-4548-a45f-4bf9fef5ba59 <list[1]>          NA          NA
#>  83: 310e3cbe-2c46-4de2-9d06-4b368dc87aec <list[1]>          NA          NA
#>  84: 954de75e-695b-4aef-9ad2-e463aacfd226 <list[1]>          NA          NA
#>  85: 0977a99e-1a73-4549-82fe-8282a5ab43e5 <list[1]>          NA          NA
#>  86: 827e0772-65b6-4284-b89d-af51f2ef7339 <list[1]>          NA          NA
#>  87: f3ac9f0e-0103-4fd5-a537-e5801cdde79d <list[1]>          NA          NA
#>  88: 2d38988a-c777-406b-b504-cf79cc30d790 <list[1]>          NA          NA
#>  89: 520fb02b-6fa6-46d2-87a4-a1d6180e6c95 <list[1]>          NA          NA
#>  90: f36fa39a-53c0-4501-a020-883ff64e98dc <list[1]>          NA          NA
#>  91: e187f78a-f1a1-457f-aa8a-68a8d5d5219c <list[1]>          NA          NA
#>  92: c971bd8f-003c-465c-8e00-e0682cb453bb <list[1]>          NA          NA
#>  93: 183792c7-6b39-4519-8d80-1b4fd1015826 <list[1]>          NA          NA
#>  94: e65400af-d039-4e14-b64f-c17e58af5706 <list[1]>          NA          NA
#>  95: 5caf63c2-1d19-42dc-83a0-8f9e6eb9047f <list[1]>          NA          NA
#>  96: 2fd2a743-fc1a-41b0-a516-7de1c61749f4 <list[1]>          NA          NA
#>  97: 949ca196-2f25-42ba-98ae-9b23473b5141 <list[1]>          NA          NA
#>  98: c05bc2a3-18e7-4de1-89f9-5d804f62591a <list[1]>          NA          NA
#>  99: 13bd5238-f1ee-4e29-b375-4f25a6da9cb3 <list[1]>          NA          NA
#> 100: 72292a8b-606d-408f-b28f-02b5e3d721f6 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
