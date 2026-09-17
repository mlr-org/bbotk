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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-17 07:54:52
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-17 07:54:52
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-17 07:54:52
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-17 07:54:52
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-17 07:54:52
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-17 07:54:52
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-17 07:54:52
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-17 07:54:52
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-17 07:54:52
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-17 07:54:52
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-17 07:54:52
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-17 07:54:52
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-17 07:54:52
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-17 07:54:52
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-17 07:54:52
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-17 07:54:52
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-17 07:54:52
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-17 07:54:52
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-17 07:54:52
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-17 07:54:52
#>  21:   failed  10.000000  5.0000000         NA 2026-09-17 07:54:52
#>  22:   failed  10.000000  3.8888889         NA 2026-09-17 07:54:52
#>  23:   failed  10.000000  2.7777778         NA 2026-09-17 07:54:52
#>  24:   failed  10.000000  1.6666667         NA 2026-09-17 07:54:52
#>  25:   failed  10.000000  0.5555556         NA 2026-09-17 07:54:52
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-17 07:54:52
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-17 07:54:52
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-17 07:54:52
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-17 07:54:52
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-17 07:54:52
#>  31:   failed   7.777778  5.0000000         NA 2026-09-17 07:54:52
#>  32:   failed   7.777778  3.8888889         NA 2026-09-17 07:54:52
#>  33:   failed   7.777778  2.7777778         NA 2026-09-17 07:54:52
#>  34:   failed   7.777778  1.6666667         NA 2026-09-17 07:54:52
#>  35:   failed   7.777778  0.5555556         NA 2026-09-17 07:54:52
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-17 07:54:52
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-17 07:54:52
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-17 07:54:52
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-17 07:54:52
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-17 07:54:52
#>  41:   failed   5.555556  5.0000000         NA 2026-09-17 07:54:52
#>  42:   failed   5.555556  3.8888889         NA 2026-09-17 07:54:52
#>  43:   failed   5.555556  2.7777778         NA 2026-09-17 07:54:52
#>  44:   failed   5.555556  1.6666667         NA 2026-09-17 07:54:52
#>  45:   failed   5.555556  0.5555556         NA 2026-09-17 07:54:52
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-17 07:54:52
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-17 07:54:52
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-17 07:54:52
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-17 07:54:52
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-17 07:54:52
#>  51:   failed   3.333333  5.0000000         NA 2026-09-17 07:54:52
#>  52:   failed   3.333333  3.8888889         NA 2026-09-17 07:54:52
#>  53:   failed   3.333333  2.7777778         NA 2026-09-17 07:54:52
#>  54:   failed   3.333333  1.6666667         NA 2026-09-17 07:54:52
#>  55:   failed   3.333333  0.5555556         NA 2026-09-17 07:54:52
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-17 07:54:52
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-17 07:54:52
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-17 07:54:52
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-17 07:54:52
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-17 07:54:52
#>  61:   failed   1.111111  5.0000000         NA 2026-09-17 07:54:52
#>  62:   failed   1.111111  3.8888889         NA 2026-09-17 07:54:52
#>  63:   failed   1.111111  2.7777778         NA 2026-09-17 07:54:52
#>  64:   failed   1.111111  1.6666667         NA 2026-09-17 07:54:52
#>  65:   failed   1.111111  0.5555556         NA 2026-09-17 07:54:52
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-17 07:54:52
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-17 07:54:52
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-17 07:54:52
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-17 07:54:52
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-17 07:54:52
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-17 07:54:52
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-17 07:54:52
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-17 07:54:52
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-17 07:54:52
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-17 07:54:52
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-17 07:54:52
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-17 07:54:52
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-17 07:54:52
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-17 07:54:52
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-17 07:54:52
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-17 07:54:52
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-17 07:54:52
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-17 07:54:52
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-17 07:54:52
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-17 07:54:52
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-17 07:54:52
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-17 07:54:52
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-17 07:54:52
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-17 07:54:52
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-17 07:54:52
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-17 07:54:52
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-17 07:54:52
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-17 07:54:52
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-17 07:54:52
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-17 07:54:52
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-17 07:54:52
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-17 07:54:52
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-17 07:54:52
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-17 07:54:52
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-17 07:54:52
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>   2: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>   3: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>   4: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>   5: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>   6: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>   7: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>   8: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>   9: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>  10: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>  11: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>  12: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>  13: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>  14: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>  15: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>  16: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>  17: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>  18: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>  19: sinking_raccoon_01b8f260 2026-09-17 07:54:53
#>  20: sinking_raccoon_01b8f260 2026-09-17 07:54:53
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
#>   1: d611b4c8-4a02-411d-ac3d-fa52f9263216    [NULL]  -10.000000  -5.0000000
#>   2: 5219723f-f3ff-4ecb-8eb5-8071b8c9313d    [NULL]  -10.000000  -3.8888889
#>   3: 35c8a5a8-8dc0-4959-b76b-d78f92c50896    [NULL]  -10.000000  -2.7777778
#>   4: b5579686-43ea-4770-8a32-afc4c67deeab    [NULL]  -10.000000  -1.6666667
#>   5: 0498cac0-c744-4294-ad62-35302688bd5f    [NULL]  -10.000000  -0.5555556
#>   6: a3eb8b09-9cfa-4933-a9e0-fc3983d37e06    [NULL]  -10.000000   0.5555556
#>   7: 1ddd39a5-b0d7-4969-9273-86566f46fd53    [NULL]  -10.000000   1.6666667
#>   8: 254dd033-eb92-4af9-8857-61f6790ef6b8    [NULL]  -10.000000   2.7777778
#>   9: 9202cda0-5f38-4e0b-923a-276a7536f71e    [NULL]  -10.000000   3.8888889
#>  10: 7f5ba0f2-1271-4c8f-a587-e06f6f8bf5f9    [NULL]  -10.000000   5.0000000
#>  11: dfc8c3d4-13bc-4b05-b967-a1e33bffc2ae    [NULL]   -7.777778  -5.0000000
#>  12: 91f69355-6149-4b03-8bc3-e72f854dc08a    [NULL]   -7.777778  -3.8888889
#>  13: a9a06750-f1f1-4a19-a1dd-dcdcc0b0d549    [NULL]   -7.777778  -2.7777778
#>  14: cde0f0b8-98ab-49c5-9698-3dafbd5c8ad7    [NULL]   -7.777778  -1.6666667
#>  15: 76c2021a-b00a-4630-94b6-396ca1715433    [NULL]   -7.777778  -0.5555556
#>  16: e96c86d6-b0d8-420b-8f52-485dcd61af91    [NULL]   -7.777778   0.5555556
#>  17: a1486935-78a0-48b2-9b4b-bca4dfd63653    [NULL]   -7.777778   1.6666667
#>  18: 52a4093f-bb80-4e10-8310-ad74e9fe87f9    [NULL]   -7.777778   2.7777778
#>  19: acbb735c-0998-421d-b67e-10ad11978ec5    [NULL]   -7.777778   3.8888889
#>  20: 3b9c3709-4a1f-4f19-b25e-42be08ca6eda    [NULL]   -7.777778   5.0000000
#>  21: a85076b4-4349-4c74-9f5e-b2bdf1125b59 <list[1]>          NA          NA
#>  22: a0865f89-9ef9-41f5-89dc-1a9cf97d1e5f <list[1]>          NA          NA
#>  23: 9a061a27-712b-4708-8895-462e01ef30b2 <list[1]>          NA          NA
#>  24: ce9b791f-f062-4b5f-a55c-d2f96a78f68d <list[1]>          NA          NA
#>  25: 33326724-c53d-4f03-9b39-b1c20ecf1421 <list[1]>          NA          NA
#>  26: 45505057-28f5-4b4a-b994-a4ec9f7b6e6e <list[1]>          NA          NA
#>  27: 0b20a728-a2b7-4d74-8fc1-17f15b42a8d1 <list[1]>          NA          NA
#>  28: 5e8c0957-f55b-489d-b489-bd647d3d19b7 <list[1]>          NA          NA
#>  29: 1c5413fc-83cc-4453-a965-c667bbca30c8 <list[1]>          NA          NA
#>  30: a548bb43-6380-4abf-b446-96c777987d8d <list[1]>          NA          NA
#>  31: b8a24b09-7579-4f99-a36e-73802d9db200 <list[1]>          NA          NA
#>  32: 324be248-d693-4855-99cc-1db093453a5b <list[1]>          NA          NA
#>  33: 957c19c5-e828-4c24-9b83-9c1054528fa4 <list[1]>          NA          NA
#>  34: 6a3baad1-178d-4f1e-ab70-f879f418e29a <list[1]>          NA          NA
#>  35: 028c7faa-e9c1-4632-a07e-c17d5d049d59 <list[1]>          NA          NA
#>  36: c3f7ac1b-ddf8-4ad6-bd82-79eb2d9c5a48 <list[1]>          NA          NA
#>  37: 2515a20b-724a-4710-bd94-e79a5831bd14 <list[1]>          NA          NA
#>  38: 587e74b3-23b8-453d-ad16-5734915b791f <list[1]>          NA          NA
#>  39: 4a5a3211-b83d-4296-ab1f-dba595115528 <list[1]>          NA          NA
#>  40: f0a1b5ef-8360-4fe3-8ddc-daae8ed0362c <list[1]>          NA          NA
#>  41: d305edf2-bcb5-4ba8-8c3d-5bbc470f6be4 <list[1]>          NA          NA
#>  42: 4fa941d0-5160-4876-9ac1-581eb27439e5 <list[1]>          NA          NA
#>  43: 4537af30-8561-4370-81e5-2444cdca29ed <list[1]>          NA          NA
#>  44: b6e1e177-d833-4a27-9710-ef360d8152ca <list[1]>          NA          NA
#>  45: d5c21e52-be29-454a-b42f-1ff5bf65eaaf <list[1]>          NA          NA
#>  46: 81e832cb-6784-4225-bb81-326466171048 <list[1]>          NA          NA
#>  47: df4b28bb-9e37-490c-b6d4-c04c05bcfc2c <list[1]>          NA          NA
#>  48: 092d0821-6c55-420c-a086-80d56cc981c9 <list[1]>          NA          NA
#>  49: e6fa6c68-9037-4f78-be68-bb08b38e421a <list[1]>          NA          NA
#>  50: b8065e01-76ae-4f47-9980-baf03571e1d3 <list[1]>          NA          NA
#>  51: 27230c81-119d-46c1-a78d-242c2a85d7b0 <list[1]>          NA          NA
#>  52: 4df991dc-8731-4e5d-9719-8b3092767c48 <list[1]>          NA          NA
#>  53: 88a40cd5-b78b-47f5-a577-e120d90cbdd6 <list[1]>          NA          NA
#>  54: dc7dd669-edc4-434f-8b01-60da2cbe09f9 <list[1]>          NA          NA
#>  55: d12d2247-ab2b-4253-be90-c55818c4cbc5 <list[1]>          NA          NA
#>  56: d22cc192-7dfc-4831-bf47-0327445697b7 <list[1]>          NA          NA
#>  57: 6e955e30-758b-4c5a-ac10-0e699fa2e6a5 <list[1]>          NA          NA
#>  58: 42c18d3f-c087-4870-a401-26221a96733a <list[1]>          NA          NA
#>  59: f9d0978b-8b6a-4fff-830e-9d129023e2ec <list[1]>          NA          NA
#>  60: 2c917f3e-2e40-4b13-a481-2f884e91e1fa <list[1]>          NA          NA
#>  61: 69a4d70b-b878-4adf-8204-007a37bc8964 <list[1]>          NA          NA
#>  62: ca1312ad-8606-4f3b-b36b-2cfb0533f90a <list[1]>          NA          NA
#>  63: b5e74866-1212-4e11-8209-4f6c79083af2 <list[1]>          NA          NA
#>  64: d96ca735-17da-40d0-9739-247da05be06b <list[1]>          NA          NA
#>  65: ecd53bb8-e221-46e5-ade2-58e97e1bf134 <list[1]>          NA          NA
#>  66: 79f9afdb-ba97-45b5-b354-8de49f8fe726 <list[1]>          NA          NA
#>  67: c11cd0a7-5750-4050-a60c-c741cb884209 <list[1]>          NA          NA
#>  68: 4b9f1af2-60f1-4107-8746-a29382f30106 <list[1]>          NA          NA
#>  69: c2c6d2df-a1ac-4164-a95b-a7eceb0233a7 <list[1]>          NA          NA
#>  70: da7359d1-1c34-4ac5-ac2d-66949d38de3f <list[1]>          NA          NA
#>  71: e05cf85e-c22e-4202-81d0-385f752fdc38 <list[1]>          NA          NA
#>  72: 8fff87c4-1cec-4572-80e7-e7aa7c1b28bb <list[1]>          NA          NA
#>  73: 2058574c-0a55-4fe5-8972-bfff5a001561 <list[1]>          NA          NA
#>  74: ba59936b-c26f-4f77-a198-1cfd76ad7a54 <list[1]>          NA          NA
#>  75: fc2cbb65-8123-4d02-8dfd-79d2d755d40a <list[1]>          NA          NA
#>  76: 63babb85-d1ae-4b84-aac3-e5bf34fe1dca <list[1]>          NA          NA
#>  77: b7a30b26-23ca-428f-8024-d01669605936 <list[1]>          NA          NA
#>  78: 5714384f-bcf2-4aaf-8491-bd951f3a8d63 <list[1]>          NA          NA
#>  79: 08cb81bc-9147-4598-95ef-5d16dd5e9fe6 <list[1]>          NA          NA
#>  80: 095ea77f-2871-4a3f-9e2d-3147f38f9288 <list[1]>          NA          NA
#>  81: cabe0eb3-bdc1-45e3-a31e-e954fe0537da <list[1]>          NA          NA
#>  82: 2e9ba10f-9a89-4a5c-bbe7-bf9579161042 <list[1]>          NA          NA
#>  83: 4b1e8dbf-2c59-4e86-a035-7ed992299553 <list[1]>          NA          NA
#>  84: 9d407224-8fd1-43d8-ad18-efa54934b8f1 <list[1]>          NA          NA
#>  85: 8818b607-c620-4726-9f8d-2cdfec62ecff <list[1]>          NA          NA
#>  86: 0a50f640-802b-4236-a7fd-e95db9b14c43 <list[1]>          NA          NA
#>  87: df8d6009-1766-4f06-9185-8e70761e0adc <list[1]>          NA          NA
#>  88: 09ce849a-79a5-4a54-97ee-893ffef11496 <list[1]>          NA          NA
#>  89: 6edcfef9-8b40-4602-800b-22175b6449ab <list[1]>          NA          NA
#>  90: c1bea484-248a-4844-a5a5-2df32f095c65 <list[1]>          NA          NA
#>  91: 0b922e48-090a-4933-8753-0df557609030 <list[1]>          NA          NA
#>  92: 201fbf4d-d9d0-41ce-9b19-2950ab8fdee7 <list[1]>          NA          NA
#>  93: b1e3ebdf-47d2-4da0-8a7d-559f0f54a4c5 <list[1]>          NA          NA
#>  94: b961fbea-ff30-4b37-9599-e6c0d5a7aa2d <list[1]>          NA          NA
#>  95: f0b51133-eef4-4ed5-af9f-368162774f26 <list[1]>          NA          NA
#>  96: f7539c61-0181-4c38-abbe-c3028b270a2a <list[1]>          NA          NA
#>  97: 6ce5d983-5387-4bc2-b6c5-42a95b3d2ade <list[1]>          NA          NA
#>  98: 8d603f74-8ef5-479f-a702-593544949ba0 <list[1]>          NA          NA
#>  99: e862563f-cf1d-447c-a920-5110ed6fcb53 <list[1]>          NA          NA
#> 100: 846fdc10-7f12-43b0-a85a-a1364f6f05f9 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
