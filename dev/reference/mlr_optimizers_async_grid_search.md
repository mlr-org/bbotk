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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-17 09:43:38
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-17 09:43:38
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-17 09:43:38
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-17 09:43:38
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-17 09:43:38
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-17 09:43:38
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-17 09:43:38
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-17 09:43:38
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-17 09:43:38
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-17 09:43:38
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-17 09:43:38
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-17 09:43:38
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-17 09:43:38
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-17 09:43:38
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-17 09:43:38
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-17 09:43:38
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-17 09:43:38
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-17 09:43:38
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-17 09:43:38
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-17 09:43:38
#>  21:   failed  10.000000  5.0000000         NA 2026-09-17 09:43:38
#>  22:   failed  10.000000  3.8888889         NA 2026-09-17 09:43:38
#>  23:   failed  10.000000  2.7777778         NA 2026-09-17 09:43:38
#>  24:   failed  10.000000  1.6666667         NA 2026-09-17 09:43:38
#>  25:   failed  10.000000  0.5555556         NA 2026-09-17 09:43:38
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-17 09:43:38
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-17 09:43:38
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-17 09:43:38
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-17 09:43:38
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-17 09:43:38
#>  31:   failed   7.777778  5.0000000         NA 2026-09-17 09:43:38
#>  32:   failed   7.777778  3.8888889         NA 2026-09-17 09:43:38
#>  33:   failed   7.777778  2.7777778         NA 2026-09-17 09:43:38
#>  34:   failed   7.777778  1.6666667         NA 2026-09-17 09:43:38
#>  35:   failed   7.777778  0.5555556         NA 2026-09-17 09:43:38
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-17 09:43:38
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-17 09:43:38
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-17 09:43:38
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-17 09:43:38
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-17 09:43:38
#>  41:   failed   5.555556  5.0000000         NA 2026-09-17 09:43:38
#>  42:   failed   5.555556  3.8888889         NA 2026-09-17 09:43:38
#>  43:   failed   5.555556  2.7777778         NA 2026-09-17 09:43:38
#>  44:   failed   5.555556  1.6666667         NA 2026-09-17 09:43:38
#>  45:   failed   5.555556  0.5555556         NA 2026-09-17 09:43:38
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-17 09:43:38
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-17 09:43:38
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-17 09:43:38
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-17 09:43:38
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-17 09:43:38
#>  51:   failed   3.333333  5.0000000         NA 2026-09-17 09:43:38
#>  52:   failed   3.333333  3.8888889         NA 2026-09-17 09:43:38
#>  53:   failed   3.333333  2.7777778         NA 2026-09-17 09:43:38
#>  54:   failed   3.333333  1.6666667         NA 2026-09-17 09:43:38
#>  55:   failed   3.333333  0.5555556         NA 2026-09-17 09:43:38
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-17 09:43:38
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-17 09:43:38
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-17 09:43:38
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-17 09:43:38
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-17 09:43:38
#>  61:   failed   1.111111  5.0000000         NA 2026-09-17 09:43:38
#>  62:   failed   1.111111  3.8888889         NA 2026-09-17 09:43:38
#>  63:   failed   1.111111  2.7777778         NA 2026-09-17 09:43:38
#>  64:   failed   1.111111  1.6666667         NA 2026-09-17 09:43:38
#>  65:   failed   1.111111  0.5555556         NA 2026-09-17 09:43:38
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-17 09:43:38
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-17 09:43:38
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-17 09:43:38
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-17 09:43:38
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-17 09:43:38
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-17 09:43:38
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-17 09:43:38
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-17 09:43:38
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-17 09:43:38
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-17 09:43:38
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-17 09:43:38
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-17 09:43:38
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-17 09:43:38
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-17 09:43:38
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-17 09:43:38
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-17 09:43:38
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-17 09:43:38
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-17 09:43:38
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-17 09:43:38
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-17 09:43:38
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-17 09:43:38
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-17 09:43:38
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-17 09:43:38
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-17 09:43:38
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-17 09:43:38
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-17 09:43:38
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-17 09:43:38
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-17 09:43:38
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-17 09:43:38
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-17 09:43:38
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-17 09:43:38
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-17 09:43:38
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-17 09:43:38
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-17 09:43:38
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-17 09:43:38
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>   2: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>   3: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>   4: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>   5: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>   6: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>   7: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>   8: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>   9: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>  10: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>  11: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>  12: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>  13: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>  14: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>  15: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>  16: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>  17: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>  18: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>  19: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
#>  20: sinking_raccoon_d0d13f2b 2026-09-17 09:43:39
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
#>   1: 0bfe35a7-a7e8-451b-a6f3-0593858a73d6    [NULL]  -10.000000  -5.0000000
#>   2: 7f322355-f90d-4523-8c28-d0c03147d7e0    [NULL]  -10.000000  -3.8888889
#>   3: ae2dce77-8a44-47a1-aafc-e2bc263b3d9d    [NULL]  -10.000000  -2.7777778
#>   4: ba3edeb0-75c7-4659-95a3-d24978b002b7    [NULL]  -10.000000  -1.6666667
#>   5: 2fa8f731-08fa-4d78-8fd2-61084956a540    [NULL]  -10.000000  -0.5555556
#>   6: 7bbed7a7-d500-428d-a0cf-6f2f28dbb3a4    [NULL]  -10.000000   0.5555556
#>   7: b09b0a21-87e5-4985-800e-f16690689401    [NULL]  -10.000000   1.6666667
#>   8: 867244e4-26c0-4024-9c73-719feb8d786c    [NULL]  -10.000000   2.7777778
#>   9: 66dd5fba-4945-4cf2-a7cb-7193963d9e3d    [NULL]  -10.000000   3.8888889
#>  10: c7441a84-281f-4aa4-b2d1-73ee54fd1ac3    [NULL]  -10.000000   5.0000000
#>  11: 004616f0-7d9f-46e7-9b33-c00f57c42f80    [NULL]   -7.777778  -5.0000000
#>  12: 3188f736-7b98-413a-9c19-5fd7a80ef38e    [NULL]   -7.777778  -3.8888889
#>  13: 67422759-263a-4100-995b-e9865bcbcfc0    [NULL]   -7.777778  -2.7777778
#>  14: bcf9e7e4-ed3b-4d0f-af9e-14addeb76b58    [NULL]   -7.777778  -1.6666667
#>  15: b01a526d-fef4-41ac-b43b-e630490669ab    [NULL]   -7.777778  -0.5555556
#>  16: 14dbf340-0800-4dd4-811e-8f97483e480c    [NULL]   -7.777778   0.5555556
#>  17: c25b7b57-d7d1-4e30-892f-8b1ebf649f22    [NULL]   -7.777778   1.6666667
#>  18: bd75dbc7-8bdf-45ab-ad50-bc364c798006    [NULL]   -7.777778   2.7777778
#>  19: bbea9ad6-cd03-4e0c-80ee-852d8820e7e7    [NULL]   -7.777778   3.8888889
#>  20: dff387b7-be7d-4e8a-9da3-f77c23c71235    [NULL]   -7.777778   5.0000000
#>  21: 94b9e024-beb6-4a9f-a98d-6a08cbdd73d8 <list[1]>          NA          NA
#>  22: 82932e3d-7500-49cb-8860-785a2305abe1 <list[1]>          NA          NA
#>  23: e246630e-303e-407f-9d9a-ecf7a7473727 <list[1]>          NA          NA
#>  24: 92ccc718-d7ec-42ab-b830-4f431c9c9e47 <list[1]>          NA          NA
#>  25: c536b5c4-3b45-4e06-bb4a-12c8fe45e5c6 <list[1]>          NA          NA
#>  26: 3c07b897-797d-4f63-bcaa-9a0a51ac7252 <list[1]>          NA          NA
#>  27: 6ebbe1ba-24e7-4153-8ac4-959a320909b5 <list[1]>          NA          NA
#>  28: de02dc71-3742-4a40-b054-e68b324be9bd <list[1]>          NA          NA
#>  29: 55871354-1b5f-4a38-aabe-78729af0c0ad <list[1]>          NA          NA
#>  30: 9133eea7-e2c1-4f4d-bd68-bdacca633c7f <list[1]>          NA          NA
#>  31: c78c8c70-8363-4d17-9331-9ada4ce1438d <list[1]>          NA          NA
#>  32: 023c894f-757d-430f-a7d7-b1c88a8961c5 <list[1]>          NA          NA
#>  33: 7b4c6a8b-8956-46d2-8f89-17fa0d3234ce <list[1]>          NA          NA
#>  34: f7522bd0-6966-436b-8969-5b5a1268bf26 <list[1]>          NA          NA
#>  35: 208b7fef-8287-42f4-b006-b96cb327c709 <list[1]>          NA          NA
#>  36: 45f203f6-2aa8-43aa-b416-612214ad2681 <list[1]>          NA          NA
#>  37: adc58ce9-ae1e-4d40-97ef-4df249f9cf37 <list[1]>          NA          NA
#>  38: ce61720f-701b-481c-9a9c-55a146f92acb <list[1]>          NA          NA
#>  39: 5a24fca9-3725-4d5b-ad7b-d61457230a42 <list[1]>          NA          NA
#>  40: 7661a7f1-4b4f-4f2e-82d7-ee18cec955e7 <list[1]>          NA          NA
#>  41: df0ad73b-ee7f-4262-9850-0afe24c527d1 <list[1]>          NA          NA
#>  42: ef910ca1-e944-4312-ad72-6e39a5deb18e <list[1]>          NA          NA
#>  43: 405c6c34-9ce1-40c4-9964-58774c31f118 <list[1]>          NA          NA
#>  44: 05f07bb3-ae56-4811-81b4-292603f1b541 <list[1]>          NA          NA
#>  45: 19e75e9a-4f02-4b9f-8880-aee6cb946d50 <list[1]>          NA          NA
#>  46: ccbbeab4-473e-4b14-a3a8-d8b3e35cb762 <list[1]>          NA          NA
#>  47: 0fe4bfed-781e-44f1-82b6-d75ff9e3fd74 <list[1]>          NA          NA
#>  48: 48283e2d-7d68-4384-93b4-8b498658529a <list[1]>          NA          NA
#>  49: f72e8380-9c59-481d-984c-8e34df68b32d <list[1]>          NA          NA
#>  50: 98aa6414-dd05-4a1b-8f7a-4388cf8b09a1 <list[1]>          NA          NA
#>  51: 6a159a3d-fb7b-4823-aade-9afa65ff8cc6 <list[1]>          NA          NA
#>  52: 84572437-68a6-4b7c-b843-a7f84e8d7422 <list[1]>          NA          NA
#>  53: ea087a41-4907-4962-8daa-c8e7c232e640 <list[1]>          NA          NA
#>  54: 1f6333c9-3fa0-4abf-9a9c-d5ad8b54ecd0 <list[1]>          NA          NA
#>  55: 6f371fdb-ec46-4662-8f11-c29ceb2574eb <list[1]>          NA          NA
#>  56: 45d92a41-b92b-4fd9-8efa-453ea636693d <list[1]>          NA          NA
#>  57: b525fe5f-1fe7-4cf5-a8d9-d194b1f93cd9 <list[1]>          NA          NA
#>  58: fa0618a5-875e-4768-b0c4-fead768b2647 <list[1]>          NA          NA
#>  59: b8a1ecd5-10e5-480e-854d-a3719fe1e817 <list[1]>          NA          NA
#>  60: ff71acc8-0fa1-4cc5-9f33-b8bf1c9bcee5 <list[1]>          NA          NA
#>  61: 4b31bfd3-b532-4db3-9e17-a20f8a2455be <list[1]>          NA          NA
#>  62: 547bd98e-9c74-4ba5-af9c-58339f27661b <list[1]>          NA          NA
#>  63: 7c84fbdc-8591-4015-888f-e86f46d405cf <list[1]>          NA          NA
#>  64: 0493e57b-7df1-4dcf-91d5-d316f386912b <list[1]>          NA          NA
#>  65: 62b42c23-886d-4542-918c-9efdf27c9f50 <list[1]>          NA          NA
#>  66: d5407c7f-119a-4f52-9049-b6bd7be10640 <list[1]>          NA          NA
#>  67: c9f7d16f-e87a-4d48-bfce-9f316017fcab <list[1]>          NA          NA
#>  68: c7662973-bbbf-4e35-a1a1-56f90c73e3b3 <list[1]>          NA          NA
#>  69: 9e2d4a7b-bb37-4a31-a7d6-20913938a380 <list[1]>          NA          NA
#>  70: dd57a165-f698-45bc-a61e-fea8e055337c <list[1]>          NA          NA
#>  71: cb2b1483-c4d7-40bd-87e7-ae79ac49327c <list[1]>          NA          NA
#>  72: 420c8082-40ec-4b43-bece-4f086a0b35ea <list[1]>          NA          NA
#>  73: 04e04227-3581-4442-af81-62c858d1d659 <list[1]>          NA          NA
#>  74: b09bdb22-eaad-4c9e-81d8-eebd3ab9300e <list[1]>          NA          NA
#>  75: 3a6e1a0e-2e90-4efc-812f-cf1fafa71700 <list[1]>          NA          NA
#>  76: 7db4bfa7-4d77-484a-a097-b7bfec00242c <list[1]>          NA          NA
#>  77: 2add24e5-8c7d-46c5-ae0f-e156034e1877 <list[1]>          NA          NA
#>  78: 3db87b97-17cb-4b3f-8bde-097a258313b7 <list[1]>          NA          NA
#>  79: 09bfaeb0-2d47-4fb6-9396-282d8aaec0b8 <list[1]>          NA          NA
#>  80: 4edfdde9-9e59-4220-8f8f-5c68bc2bda73 <list[1]>          NA          NA
#>  81: de9dcb1c-f00f-4761-8066-28ebac8eb330 <list[1]>          NA          NA
#>  82: 49678c10-9495-4d48-823e-bde17b59ea6b <list[1]>          NA          NA
#>  83: ba9a238f-1841-4d0a-8d97-2506432cac29 <list[1]>          NA          NA
#>  84: 867cb29d-063f-4fa6-824a-ec93c3ebe1d2 <list[1]>          NA          NA
#>  85: 202b3913-945c-45f7-8aca-310baa9f4df7 <list[1]>          NA          NA
#>  86: 1d9d79ff-ee43-48ab-8d4e-f37fdf6bf34a <list[1]>          NA          NA
#>  87: 9029e918-41d1-4385-babe-da5db4c9b943 <list[1]>          NA          NA
#>  88: a016c7d8-d9a0-4c1c-b703-fb16e544cc5e <list[1]>          NA          NA
#>  89: 5b4ef860-aa0e-44ff-9dab-1a44f92829f4 <list[1]>          NA          NA
#>  90: 37829466-5100-46e9-b2dd-77bf228ab15b <list[1]>          NA          NA
#>  91: 3d56347f-2fee-4a4d-b59b-4059e4acdd08 <list[1]>          NA          NA
#>  92: b2f12bfb-896c-4d1d-bc0f-04ef4134de25 <list[1]>          NA          NA
#>  93: 21aecc25-a899-4996-aa6d-c5478b3b5324 <list[1]>          NA          NA
#>  94: 23e978d5-ff67-460c-8992-d6422a841a32 <list[1]>          NA          NA
#>  95: eb7c26ee-c032-491e-837e-97c0292fb01e <list[1]>          NA          NA
#>  96: 4f244ef6-c184-4366-9454-ef643863cfd7 <list[1]>          NA          NA
#>  97: f53d336d-5186-43c9-a98d-d0d8223068fb <list[1]>          NA          NA
#>  98: 5ba3368a-8c06-495c-bb44-6df2cf43c1e0 <list[1]>          NA          NA
#>  99: ffb3021d-a684-4246-9868-35b9eac2b423 <list[1]>          NA          NA
#> 100: b1845481-12af-4daa-9bfb-a20378370dbb <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
