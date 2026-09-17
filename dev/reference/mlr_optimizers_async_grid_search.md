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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-17 07:48:00
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-17 07:48:00
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-17 07:48:00
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-17 07:48:00
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-17 07:48:00
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-17 07:48:00
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-17 07:48:00
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-17 07:48:00
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-17 07:48:00
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-17 07:48:00
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-17 07:48:00
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-17 07:48:00
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-17 07:48:00
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-17 07:48:00
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-17 07:48:00
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-17 07:48:00
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-17 07:48:00
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-17 07:48:00
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-17 07:48:00
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-17 07:48:00
#>  21:   failed  10.000000  5.0000000         NA 2026-09-17 07:48:00
#>  22:   failed  10.000000  3.8888889         NA 2026-09-17 07:48:00
#>  23:   failed  10.000000  2.7777778         NA 2026-09-17 07:48:00
#>  24:   failed  10.000000  1.6666667         NA 2026-09-17 07:48:00
#>  25:   failed  10.000000  0.5555556         NA 2026-09-17 07:48:00
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-17 07:48:00
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-17 07:48:00
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-17 07:48:00
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-17 07:48:00
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-17 07:48:00
#>  31:   failed   7.777778  5.0000000         NA 2026-09-17 07:48:00
#>  32:   failed   7.777778  3.8888889         NA 2026-09-17 07:48:00
#>  33:   failed   7.777778  2.7777778         NA 2026-09-17 07:48:00
#>  34:   failed   7.777778  1.6666667         NA 2026-09-17 07:48:00
#>  35:   failed   7.777778  0.5555556         NA 2026-09-17 07:48:00
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-17 07:48:00
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-17 07:48:00
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-17 07:48:00
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-17 07:48:00
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-17 07:48:00
#>  41:   failed   5.555556  5.0000000         NA 2026-09-17 07:48:00
#>  42:   failed   5.555556  3.8888889         NA 2026-09-17 07:48:00
#>  43:   failed   5.555556  2.7777778         NA 2026-09-17 07:48:00
#>  44:   failed   5.555556  1.6666667         NA 2026-09-17 07:48:00
#>  45:   failed   5.555556  0.5555556         NA 2026-09-17 07:48:00
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-17 07:48:00
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-17 07:48:00
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-17 07:48:00
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-17 07:48:00
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-17 07:48:00
#>  51:   failed   3.333333  5.0000000         NA 2026-09-17 07:48:00
#>  52:   failed   3.333333  3.8888889         NA 2026-09-17 07:48:00
#>  53:   failed   3.333333  2.7777778         NA 2026-09-17 07:48:00
#>  54:   failed   3.333333  1.6666667         NA 2026-09-17 07:48:00
#>  55:   failed   3.333333  0.5555556         NA 2026-09-17 07:48:00
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-17 07:48:00
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-17 07:48:00
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-17 07:48:00
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-17 07:48:00
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-17 07:48:00
#>  61:   failed   1.111111  5.0000000         NA 2026-09-17 07:48:00
#>  62:   failed   1.111111  3.8888889         NA 2026-09-17 07:48:00
#>  63:   failed   1.111111  2.7777778         NA 2026-09-17 07:48:00
#>  64:   failed   1.111111  1.6666667         NA 2026-09-17 07:48:00
#>  65:   failed   1.111111  0.5555556         NA 2026-09-17 07:48:00
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-17 07:48:00
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-17 07:48:00
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-17 07:48:00
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-17 07:48:00
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-17 07:48:00
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-17 07:48:00
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-17 07:48:00
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-17 07:48:00
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-17 07:48:00
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-17 07:48:00
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-17 07:48:00
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-17 07:48:00
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-17 07:48:00
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-17 07:48:00
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-17 07:48:00
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-17 07:48:00
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-17 07:48:00
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-17 07:48:00
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-17 07:48:00
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-17 07:48:00
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-17 07:48:00
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-17 07:48:00
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-17 07:48:00
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-17 07:48:00
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-17 07:48:00
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-17 07:48:00
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-17 07:48:00
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-17 07:48:00
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-17 07:48:00
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-17 07:48:00
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-17 07:48:00
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-17 07:48:00
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-17 07:48:00
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-17 07:48:00
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-17 07:48:00
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>   2: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>   3: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>   4: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>   5: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>   6: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>   7: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>   8: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>   9: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>  10: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>  11: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>  12: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>  13: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>  14: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>  15: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>  16: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>  17: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>  18: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>  19: sinking_raccoon_c121b202 2026-09-17 07:48:01
#>  20: sinking_raccoon_c121b202 2026-09-17 07:48:01
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
#>   1: 368199f9-d852-4e51-b543-4816f256aad9    [NULL]  -10.000000  -5.0000000
#>   2: a1ab766b-448a-4224-a9c6-296543bbfc54    [NULL]  -10.000000  -3.8888889
#>   3: 86728f34-e5e2-4ca8-994b-d7fb5e528a0e    [NULL]  -10.000000  -2.7777778
#>   4: 8594b204-ad61-4746-bd45-348aab66d483    [NULL]  -10.000000  -1.6666667
#>   5: c156b4ab-cdb8-4c88-a653-79f613355d59    [NULL]  -10.000000  -0.5555556
#>   6: e6d51be5-88dd-4077-a629-020a42b77744    [NULL]  -10.000000   0.5555556
#>   7: db846c77-f751-4dec-b0ae-a89e3f17f0c3    [NULL]  -10.000000   1.6666667
#>   8: 41c52d10-450a-41db-90e5-0dbcbdccb30b    [NULL]  -10.000000   2.7777778
#>   9: 4cc69706-0452-43c3-87d9-d14e0e9634e5    [NULL]  -10.000000   3.8888889
#>  10: dfe92778-c960-46ac-8ab3-83fa8e3619b1    [NULL]  -10.000000   5.0000000
#>  11: b3f51b43-288b-4f2f-9ad7-961e5f547886    [NULL]   -7.777778  -5.0000000
#>  12: afabb66e-a5ef-4d05-a1b6-5782ad3898ce    [NULL]   -7.777778  -3.8888889
#>  13: 4ab2f7ef-75be-4e91-a13b-c060bb361c6a    [NULL]   -7.777778  -2.7777778
#>  14: 1b6eb70c-b2cc-466e-93de-fabe083baf38    [NULL]   -7.777778  -1.6666667
#>  15: f9c6b1b5-9747-44a5-ae73-716e770d4996    [NULL]   -7.777778  -0.5555556
#>  16: 9ff94073-3bdd-4f61-9fa3-a2eb0df77166    [NULL]   -7.777778   0.5555556
#>  17: ae03861d-c367-4952-81d3-a4083fea8d32    [NULL]   -7.777778   1.6666667
#>  18: 690550ed-e14f-43d3-b50e-0bd179f79d68    [NULL]   -7.777778   2.7777778
#>  19: fdab466b-8cb2-4d6e-a906-dde518d42853    [NULL]   -7.777778   3.8888889
#>  20: 32e4abfd-a00b-4256-a469-bb79ec9d749f    [NULL]   -7.777778   5.0000000
#>  21: 31fe827a-fad2-43b5-977f-55490a6412bd <list[1]>          NA          NA
#>  22: ca970dfc-c808-4afe-b063-657c58d7f5bf <list[1]>          NA          NA
#>  23: 3de8252b-c452-46f1-bbaf-afe9a2baaf20 <list[1]>          NA          NA
#>  24: 7eb280a9-4f1e-4fb9-b6db-e703a0fc1c38 <list[1]>          NA          NA
#>  25: f1a00090-13a1-455a-96ed-28c5a8ca7c6e <list[1]>          NA          NA
#>  26: 668f895a-f295-4200-9c7f-01b2fca1616f <list[1]>          NA          NA
#>  27: 07cc8dd5-f9f0-46ef-af5a-9063f1a3f352 <list[1]>          NA          NA
#>  28: 49eaa740-5877-4f2a-8b26-716a07e63b3e <list[1]>          NA          NA
#>  29: 95847d70-60bb-44bf-8e44-9d7f6f7d486b <list[1]>          NA          NA
#>  30: 051f7d2e-87cf-433c-9b54-0bb2e45fa86f <list[1]>          NA          NA
#>  31: eb05efc2-2324-416e-bafa-12af171bb14f <list[1]>          NA          NA
#>  32: 82a42ade-f8a5-4214-81d1-ba12186e5b55 <list[1]>          NA          NA
#>  33: fff78849-d571-4f36-b6f8-e89bf4856c3e <list[1]>          NA          NA
#>  34: 0a5da3cf-203f-4f37-b2dd-173dbda3bd68 <list[1]>          NA          NA
#>  35: c2eb1805-14a8-4f9e-b84d-e5251506541a <list[1]>          NA          NA
#>  36: 017b6f8d-c64b-4d27-9f39-ff3207a0ca4b <list[1]>          NA          NA
#>  37: fd1c4562-c609-4add-b7d1-3331b11997db <list[1]>          NA          NA
#>  38: c0336fab-904a-48c7-a460-727273fd35b1 <list[1]>          NA          NA
#>  39: de48f0d8-d235-40c4-91bb-c2d6f2288d95 <list[1]>          NA          NA
#>  40: 47a3e217-2b72-4e40-a5e4-c0302ed019ec <list[1]>          NA          NA
#>  41: f161888c-5bb8-43fd-931d-f18b4c414793 <list[1]>          NA          NA
#>  42: 266dc291-16ce-45fb-aa1b-50b4066f431e <list[1]>          NA          NA
#>  43: 40a93287-f80a-45de-a7b9-09297acc06b1 <list[1]>          NA          NA
#>  44: dbc39391-8e23-467f-964c-e18ecff35703 <list[1]>          NA          NA
#>  45: 88aeb39d-8f59-429f-99f4-fb4589bbef61 <list[1]>          NA          NA
#>  46: 73d39398-20ec-4fe6-a589-70a593fb6854 <list[1]>          NA          NA
#>  47: 44914af4-6117-48a9-9a58-f795dcb34cf9 <list[1]>          NA          NA
#>  48: ab25c541-2cb5-45fa-b9af-6a7a51c31fb5 <list[1]>          NA          NA
#>  49: 90513cdd-74c2-4e7c-8fa0-d9ee13be8b5c <list[1]>          NA          NA
#>  50: 83aec391-9118-4cbb-b844-0ebdcb28edeb <list[1]>          NA          NA
#>  51: 7f37ed3d-01b6-48cb-bf98-a7029771e58d <list[1]>          NA          NA
#>  52: 87ac3f31-fb86-4e06-b0af-cbf117316623 <list[1]>          NA          NA
#>  53: 89353afd-4272-4e5c-a278-c905e047103c <list[1]>          NA          NA
#>  54: 8e1aafcc-d14a-45a7-a0c4-37369deb5f7f <list[1]>          NA          NA
#>  55: b3b36286-e42e-46ee-bcd1-6ff5512bc56a <list[1]>          NA          NA
#>  56: c2ae5192-1f7d-493b-913a-e83ca0f1d4f0 <list[1]>          NA          NA
#>  57: 535ae725-f050-414f-a236-17d6451bfba2 <list[1]>          NA          NA
#>  58: b926add2-09ee-4ccb-b5fe-e0ea9197442a <list[1]>          NA          NA
#>  59: 6b6f4b67-8d17-478e-a0c0-55018e5ae246 <list[1]>          NA          NA
#>  60: 5971ec73-c4e8-405e-a05e-1d47aae992be <list[1]>          NA          NA
#>  61: 89ca5313-a8f4-4d2d-87f1-aa70b49f159a <list[1]>          NA          NA
#>  62: 96249a07-f3f8-49b9-a8cc-e50e1fb1bc80 <list[1]>          NA          NA
#>  63: 59f148de-40ba-4740-8260-4d11741a33cb <list[1]>          NA          NA
#>  64: fbcafaa5-c534-4e8b-aa60-9cef53e78f5e <list[1]>          NA          NA
#>  65: f4504cc6-21d9-4e4a-893e-fbc80f3f1c12 <list[1]>          NA          NA
#>  66: 50792441-27a6-4d47-90a9-b49de52a5caf <list[1]>          NA          NA
#>  67: 946ceff0-c316-46b1-9406-eec2f65291a5 <list[1]>          NA          NA
#>  68: b46f9078-1480-4152-8cfe-e5ce89e2d035 <list[1]>          NA          NA
#>  69: ba7411a2-96a7-4211-a024-ac42104a2bff <list[1]>          NA          NA
#>  70: fc4e600b-54c3-4874-947c-93ecb6284733 <list[1]>          NA          NA
#>  71: 2aa49d26-28a6-44b2-9548-19bb74a084a7 <list[1]>          NA          NA
#>  72: 3ba31a18-8611-4922-aaac-556a113010ae <list[1]>          NA          NA
#>  73: 0ece70ee-ceb3-4a48-ab3b-3b262902bf7b <list[1]>          NA          NA
#>  74: e91fcf6f-c809-47ec-a62d-f6f8eebda878 <list[1]>          NA          NA
#>  75: 2ceebf36-9061-4e21-a856-c7644e8af88e <list[1]>          NA          NA
#>  76: 1c5736f7-27aa-49f5-a86a-2eb1502070bd <list[1]>          NA          NA
#>  77: 9f8bc4f4-f754-44eb-92d8-bf2dd2d322b4 <list[1]>          NA          NA
#>  78: 6cb1e066-421f-4fc5-b6c3-f05142a775f2 <list[1]>          NA          NA
#>  79: 7a1ac047-d84c-4b74-ae9d-304597bb8380 <list[1]>          NA          NA
#>  80: e947e563-a0b0-4afb-97b1-63a0d87894bd <list[1]>          NA          NA
#>  81: 02307e20-382d-4f30-ac99-bc7172e9ec75 <list[1]>          NA          NA
#>  82: 0564a795-93a9-4ce0-942d-4567985d0003 <list[1]>          NA          NA
#>  83: 360fb7f6-5e7c-4f62-9633-ba2c8749f73f <list[1]>          NA          NA
#>  84: 0ed7c132-2132-4e59-8076-72710b855541 <list[1]>          NA          NA
#>  85: 9e3b2937-2899-4845-b68c-b038ff4ebb79 <list[1]>          NA          NA
#>  86: be368735-c084-41f1-80b7-f4d60e633d48 <list[1]>          NA          NA
#>  87: 26feaecc-39e5-4fca-a961-f5a913164b1c <list[1]>          NA          NA
#>  88: ba745aae-88da-47a2-a7b9-3692ddeed487 <list[1]>          NA          NA
#>  89: 23b1580b-d966-494c-9ff6-006ade96e9a5 <list[1]>          NA          NA
#>  90: 89469094-4c8d-406c-ae94-dd9b1a7bacfe <list[1]>          NA          NA
#>  91: b5466f82-eaf9-4684-b35f-1b972579e2b4 <list[1]>          NA          NA
#>  92: 913d1451-7a69-49eb-8be7-b04dcffeffe0 <list[1]>          NA          NA
#>  93: d2dcee6c-09e2-4fff-a788-0d1e3085c14b <list[1]>          NA          NA
#>  94: 47bb257d-22af-43be-a7f7-7ad3fd187ddb <list[1]>          NA          NA
#>  95: 0f70d5be-687c-43c9-bc98-0f807e1fa583 <list[1]>          NA          NA
#>  96: 0f3cefb6-da70-47df-95f2-0ce2ae0552ee <list[1]>          NA          NA
#>  97: 98541c08-02da-4c8b-8ada-d4f0725ebf4e <list[1]>          NA          NA
#>  98: b8ed9aa7-57bd-4a84-9279-4d4b09715235 <list[1]>          NA          NA
#>  99: e2a43ba1-34e5-4069-abb9-dd8f3191eb52 <list[1]>          NA          NA
#> 100: ec95a43d-a002-478b-90de-baca85b642ab <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
