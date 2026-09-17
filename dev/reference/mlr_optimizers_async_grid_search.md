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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-17 09:40:32
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-17 09:40:32
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-17 09:40:32
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-17 09:40:32
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-17 09:40:32
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-17 09:40:32
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-17 09:40:32
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-17 09:40:32
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-17 09:40:32
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-17 09:40:32
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-17 09:40:32
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-17 09:40:32
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-17 09:40:32
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-17 09:40:32
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-17 09:40:32
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-17 09:40:32
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-17 09:40:32
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-17 09:40:32
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-17 09:40:32
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-17 09:40:32
#>  21:   failed  10.000000  5.0000000         NA 2026-09-17 09:40:32
#>  22:   failed  10.000000  3.8888889         NA 2026-09-17 09:40:32
#>  23:   failed  10.000000  2.7777778         NA 2026-09-17 09:40:32
#>  24:   failed  10.000000  1.6666667         NA 2026-09-17 09:40:32
#>  25:   failed  10.000000  0.5555556         NA 2026-09-17 09:40:32
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-17 09:40:32
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-17 09:40:32
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-17 09:40:32
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-17 09:40:32
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-17 09:40:32
#>  31:   failed   7.777778  5.0000000         NA 2026-09-17 09:40:32
#>  32:   failed   7.777778  3.8888889         NA 2026-09-17 09:40:32
#>  33:   failed   7.777778  2.7777778         NA 2026-09-17 09:40:32
#>  34:   failed   7.777778  1.6666667         NA 2026-09-17 09:40:32
#>  35:   failed   7.777778  0.5555556         NA 2026-09-17 09:40:32
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-17 09:40:32
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-17 09:40:32
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-17 09:40:32
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-17 09:40:32
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-17 09:40:32
#>  41:   failed   5.555556  5.0000000         NA 2026-09-17 09:40:32
#>  42:   failed   5.555556  3.8888889         NA 2026-09-17 09:40:32
#>  43:   failed   5.555556  2.7777778         NA 2026-09-17 09:40:32
#>  44:   failed   5.555556  1.6666667         NA 2026-09-17 09:40:32
#>  45:   failed   5.555556  0.5555556         NA 2026-09-17 09:40:32
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-17 09:40:32
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-17 09:40:32
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-17 09:40:32
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-17 09:40:32
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-17 09:40:32
#>  51:   failed   3.333333  5.0000000         NA 2026-09-17 09:40:32
#>  52:   failed   3.333333  3.8888889         NA 2026-09-17 09:40:32
#>  53:   failed   3.333333  2.7777778         NA 2026-09-17 09:40:32
#>  54:   failed   3.333333  1.6666667         NA 2026-09-17 09:40:32
#>  55:   failed   3.333333  0.5555556         NA 2026-09-17 09:40:32
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-17 09:40:32
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-17 09:40:32
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-17 09:40:32
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-17 09:40:32
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-17 09:40:32
#>  61:   failed   1.111111  5.0000000         NA 2026-09-17 09:40:32
#>  62:   failed   1.111111  3.8888889         NA 2026-09-17 09:40:32
#>  63:   failed   1.111111  2.7777778         NA 2026-09-17 09:40:32
#>  64:   failed   1.111111  1.6666667         NA 2026-09-17 09:40:32
#>  65:   failed   1.111111  0.5555556         NA 2026-09-17 09:40:32
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-17 09:40:32
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-17 09:40:32
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-17 09:40:32
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-17 09:40:32
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-17 09:40:32
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-17 09:40:32
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-17 09:40:32
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-17 09:40:32
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-17 09:40:32
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-17 09:40:32
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-17 09:40:32
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-17 09:40:32
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-17 09:40:32
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-17 09:40:32
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-17 09:40:32
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-17 09:40:32
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-17 09:40:32
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-17 09:40:32
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-17 09:40:32
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-17 09:40:32
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-17 09:40:32
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-17 09:40:32
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-17 09:40:32
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-17 09:40:32
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-17 09:40:32
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-17 09:40:32
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-17 09:40:32
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-17 09:40:32
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-17 09:40:32
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-17 09:40:32
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-17 09:40:32
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-17 09:40:32
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-17 09:40:32
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-17 09:40:32
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-17 09:40:32
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>   2: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>   3: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>   4: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>   5: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>   6: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>   7: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>   8: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>   9: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>  10: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>  11: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>  12: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>  13: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>  14: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>  15: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>  16: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>  17: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>  18: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>  19: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
#>  20: sinking_raccoon_41ac22a6 2026-09-17 09:40:33
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
#>   1: 3f174fe0-ab51-4c76-86ad-c23c234a17f4    [NULL]  -10.000000  -5.0000000
#>   2: c20145ab-c804-419b-9fb4-b0f85bfdf09b    [NULL]  -10.000000  -3.8888889
#>   3: 2a95f70b-7a29-471e-b32a-a6b965c7aa07    [NULL]  -10.000000  -2.7777778
#>   4: 29fd8f71-e657-4cd1-b370-d1515164c9ba    [NULL]  -10.000000  -1.6666667
#>   5: e63d8529-0856-416f-a0c2-cb156d19a77d    [NULL]  -10.000000  -0.5555556
#>   6: 98413437-ab04-4e1a-8062-9acd537c53bb    [NULL]  -10.000000   0.5555556
#>   7: fd8c5d37-4700-444b-88bd-3531ba78cce9    [NULL]  -10.000000   1.6666667
#>   8: 32308cb5-c6c5-4aa9-b177-23eba522f2b7    [NULL]  -10.000000   2.7777778
#>   9: d29a6ad3-0a97-4fcb-b6bc-922d8ae9cdba    [NULL]  -10.000000   3.8888889
#>  10: c73ae5b7-355d-494b-8ff6-f2b0186879c5    [NULL]  -10.000000   5.0000000
#>  11: 44cb766d-beb9-4370-880d-1d1b09461b32    [NULL]   -7.777778  -5.0000000
#>  12: 080c4767-39d2-487a-b4f5-95f7f32e76e2    [NULL]   -7.777778  -3.8888889
#>  13: 0ea99745-4253-4d2b-83ce-6a31e2b3dea1    [NULL]   -7.777778  -2.7777778
#>  14: 8458ae17-ae20-4642-9f29-fb09698666d6    [NULL]   -7.777778  -1.6666667
#>  15: 143bb35c-8cd3-4468-81b7-b69c57186efb    [NULL]   -7.777778  -0.5555556
#>  16: 343e1825-b62d-4d21-b20b-557762d13794    [NULL]   -7.777778   0.5555556
#>  17: a15d68e0-6e80-4c74-b7fd-83bda1e3d982    [NULL]   -7.777778   1.6666667
#>  18: 77924b8d-6910-471a-83bf-fbccd415aa38    [NULL]   -7.777778   2.7777778
#>  19: 3ddeee7e-c55f-437b-8953-8146b4a6342b    [NULL]   -7.777778   3.8888889
#>  20: 12dbcd17-1d4a-488e-bf1a-ee2d31854e54    [NULL]   -7.777778   5.0000000
#>  21: 84fc4c24-a7ae-42a1-ae93-31caa01d19d4 <list[1]>          NA          NA
#>  22: a0c06e58-d02d-4a6b-bb1e-95427e8ef195 <list[1]>          NA          NA
#>  23: 6a56aa62-f9f7-4408-8487-c8bec3075f49 <list[1]>          NA          NA
#>  24: b7e93c09-08d2-4de1-beac-03c6cd315ad2 <list[1]>          NA          NA
#>  25: 2581d6af-f17f-441c-a9e7-f6901d46e9e9 <list[1]>          NA          NA
#>  26: 3355f488-73da-492e-8e33-e78b534cedae <list[1]>          NA          NA
#>  27: 70e91813-109f-48c7-9c43-d6625f244bb1 <list[1]>          NA          NA
#>  28: 2a5a6084-c40c-47ed-87ad-d4cd4c818cd4 <list[1]>          NA          NA
#>  29: 759ec828-ab2b-462b-9bc9-d6518ba12b9c <list[1]>          NA          NA
#>  30: 1970249f-c641-45b9-b2ac-11ab1f3dcb30 <list[1]>          NA          NA
#>  31: f71221c2-26d4-4151-8509-7ae7e8b74591 <list[1]>          NA          NA
#>  32: d199e41e-7b48-4114-9174-ad8a01c27172 <list[1]>          NA          NA
#>  33: 1ed0053c-5d30-493d-a6d3-f8bcc4400205 <list[1]>          NA          NA
#>  34: 4f26c8da-5723-417a-9c08-46344e15e520 <list[1]>          NA          NA
#>  35: 22cf0d31-b109-4fc4-a35a-34634471145e <list[1]>          NA          NA
#>  36: 8bf7cc38-e8ba-4638-9651-d1ff5b3240b6 <list[1]>          NA          NA
#>  37: 3e485dcf-ecfb-4a3c-a507-471f4bad5cb1 <list[1]>          NA          NA
#>  38: 22ef6504-9bcd-480c-b795-09eaa7349d3c <list[1]>          NA          NA
#>  39: 64f55172-3151-4c7d-842b-434f4e9f5dc5 <list[1]>          NA          NA
#>  40: 45485ec0-6e4e-4aa0-a6d4-b0c16de7fef4 <list[1]>          NA          NA
#>  41: 0f10c4fb-3498-4093-9b83-9da0ec83459d <list[1]>          NA          NA
#>  42: e5a8039e-2ff4-4373-ab32-a4eb17274629 <list[1]>          NA          NA
#>  43: 881fc2c4-876a-460b-932f-b9f4a124b3e5 <list[1]>          NA          NA
#>  44: 02b4869b-01a8-4569-a830-c1b08afcef6b <list[1]>          NA          NA
#>  45: 4d12afb6-6fed-4aa3-818d-44b9ba313ef1 <list[1]>          NA          NA
#>  46: 92f9afd5-0776-4861-ba04-46c24260e6c3 <list[1]>          NA          NA
#>  47: eaa4c6ad-071a-4a6f-8b0d-61d62143d19b <list[1]>          NA          NA
#>  48: 586e6113-8350-42ad-a8a8-b9451708b3a7 <list[1]>          NA          NA
#>  49: fa7be6e7-ea3c-4123-a748-d5dfbfd75802 <list[1]>          NA          NA
#>  50: b60a44be-7d88-4189-880b-67b4ca87a18b <list[1]>          NA          NA
#>  51: 40321965-983e-40e0-8efa-3e9306d83dff <list[1]>          NA          NA
#>  52: 22d928b3-f3d5-4a52-982c-1665b86c96e0 <list[1]>          NA          NA
#>  53: 00409887-a904-4a06-b663-6d4405c7fbe4 <list[1]>          NA          NA
#>  54: bfb06b50-e65e-4463-a0f6-6fa934c16f2c <list[1]>          NA          NA
#>  55: 9650365b-598d-404f-bf9a-9f12f6ae6436 <list[1]>          NA          NA
#>  56: ad5d0c3a-4895-4801-9d6a-bd558181082b <list[1]>          NA          NA
#>  57: 8268ca40-d1a9-40fb-93b2-89a59782c2e4 <list[1]>          NA          NA
#>  58: 77d9fa4e-4dcf-4923-9931-93db8000b6c6 <list[1]>          NA          NA
#>  59: b045afe1-464e-4a34-affb-c810d069ab0f <list[1]>          NA          NA
#>  60: 7d6609c1-54e2-4456-915b-b6d53a975bf7 <list[1]>          NA          NA
#>  61: d6de8549-be33-4b2d-87c2-2614a374b095 <list[1]>          NA          NA
#>  62: 372dda55-8faa-44ea-b17e-1a1fe35de742 <list[1]>          NA          NA
#>  63: 025fa407-23d4-4a65-beae-42abaa4e94b7 <list[1]>          NA          NA
#>  64: 6ed9cad3-f58c-47ee-803d-b4ddcd2d2e56 <list[1]>          NA          NA
#>  65: db38b111-4086-4108-a50d-ed07587c2645 <list[1]>          NA          NA
#>  66: 560beeb3-a503-4234-a20f-1a48bbca8ebf <list[1]>          NA          NA
#>  67: 918955f7-4048-4619-9d9f-59d75c2f8b95 <list[1]>          NA          NA
#>  68: 21e61da6-258b-49ca-b5b6-612f555c41e3 <list[1]>          NA          NA
#>  69: 59ee5ef5-35bb-489c-bdd3-0cbddbcf81d0 <list[1]>          NA          NA
#>  70: ebdd9f7d-b23d-4904-a1ae-0c757775e667 <list[1]>          NA          NA
#>  71: 7403b282-0a97-4004-b257-7e8f79170bb5 <list[1]>          NA          NA
#>  72: a8e11d85-4efd-4414-aec9-4a67417dc8a0 <list[1]>          NA          NA
#>  73: e2a1a887-7fb5-4a73-a100-c19ba1f7d447 <list[1]>          NA          NA
#>  74: 99caa201-34f0-40ed-84f6-88f314074396 <list[1]>          NA          NA
#>  75: 626d66d6-3c14-4322-90f4-a2f37178058e <list[1]>          NA          NA
#>  76: ac9229f8-6421-4b03-96a6-bae9498f21cd <list[1]>          NA          NA
#>  77: ecab0468-f94e-41fb-8c6e-f0c76f45b5a3 <list[1]>          NA          NA
#>  78: f0cb61cd-c495-41af-ac69-f73569c697dd <list[1]>          NA          NA
#>  79: d0c8020c-9329-4fcd-908d-7dc95df97f09 <list[1]>          NA          NA
#>  80: 9ffcd27c-8d1a-4ec8-9b64-5a4c24d006aa <list[1]>          NA          NA
#>  81: a2ce19ec-a042-45fa-b751-12120cfa0bc2 <list[1]>          NA          NA
#>  82: ff1d0bc3-4f80-4ad4-bb2d-e2020568984f <list[1]>          NA          NA
#>  83: 98f73bd5-b9d2-4602-a866-9abd13bdc814 <list[1]>          NA          NA
#>  84: c8660be7-044a-4767-b456-3f5babc6e7b9 <list[1]>          NA          NA
#>  85: 5d87d5d0-d5eb-4628-8e90-40bb6128bda3 <list[1]>          NA          NA
#>  86: d840b34f-441d-49f2-a290-732eb9a07f0f <list[1]>          NA          NA
#>  87: a35ad906-f7bb-4d0c-8ce4-cce01b54ad65 <list[1]>          NA          NA
#>  88: c02cf2a4-6c85-47b4-b4f1-5c75a18770fb <list[1]>          NA          NA
#>  89: 83013549-2375-4823-b2d7-87448714971e <list[1]>          NA          NA
#>  90: 48a1cca9-5578-43ef-821c-fc0367d5bd73 <list[1]>          NA          NA
#>  91: 9bc9a637-2379-44e2-a086-fef278032240 <list[1]>          NA          NA
#>  92: 3f541082-9e6d-450a-b2d3-c7ca5485af8a <list[1]>          NA          NA
#>  93: ab0471d0-41b4-4d10-92a2-29aa56173ef2 <list[1]>          NA          NA
#>  94: 955880fb-1186-4e16-bfec-79ac2da3744c <list[1]>          NA          NA
#>  95: 75e28cfd-38d3-4a27-bdaf-26dae9317f8f <list[1]>          NA          NA
#>  96: 1a21d75c-03d7-4ea6-9b69-dd661438b818 <list[1]>          NA          NA
#>  97: 30a7521b-1db2-4fac-8b7e-9830d877c0ad <list[1]>          NA          NA
#>  98: 2d82725e-bf7b-468b-91a6-fe1af0b6ef5e <list[1]>          NA          NA
#>  99: e8d44108-12bb-48a7-b1db-96ec6497188e <list[1]>          NA          NA
#> 100: d7c3f524-5a3e-44f0-addc-c7172f0f4498 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
