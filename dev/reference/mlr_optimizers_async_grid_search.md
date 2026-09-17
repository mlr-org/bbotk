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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-17 08:22:40
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-17 08:22:40
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-17 08:22:40
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-17 08:22:40
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-17 08:22:40
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-17 08:22:40
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-17 08:22:40
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-17 08:22:40
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-17 08:22:40
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-17 08:22:40
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-17 08:22:40
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-17 08:22:40
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-17 08:22:40
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-17 08:22:40
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-17 08:22:40
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-17 08:22:40
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-17 08:22:40
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-17 08:22:40
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-17 08:22:40
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-17 08:22:40
#>  21:   failed  10.000000  5.0000000         NA 2026-09-17 08:22:40
#>  22:   failed  10.000000  3.8888889         NA 2026-09-17 08:22:40
#>  23:   failed  10.000000  2.7777778         NA 2026-09-17 08:22:40
#>  24:   failed  10.000000  1.6666667         NA 2026-09-17 08:22:40
#>  25:   failed  10.000000  0.5555556         NA 2026-09-17 08:22:40
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-17 08:22:40
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-17 08:22:40
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-17 08:22:40
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-17 08:22:40
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-17 08:22:40
#>  31:   failed   7.777778  5.0000000         NA 2026-09-17 08:22:40
#>  32:   failed   7.777778  3.8888889         NA 2026-09-17 08:22:40
#>  33:   failed   7.777778  2.7777778         NA 2026-09-17 08:22:40
#>  34:   failed   7.777778  1.6666667         NA 2026-09-17 08:22:40
#>  35:   failed   7.777778  0.5555556         NA 2026-09-17 08:22:40
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-17 08:22:40
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-17 08:22:40
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-17 08:22:40
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-17 08:22:40
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-17 08:22:40
#>  41:   failed   5.555556  5.0000000         NA 2026-09-17 08:22:40
#>  42:   failed   5.555556  3.8888889         NA 2026-09-17 08:22:40
#>  43:   failed   5.555556  2.7777778         NA 2026-09-17 08:22:40
#>  44:   failed   5.555556  1.6666667         NA 2026-09-17 08:22:40
#>  45:   failed   5.555556  0.5555556         NA 2026-09-17 08:22:40
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-17 08:22:40
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-17 08:22:40
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-17 08:22:40
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-17 08:22:40
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-17 08:22:40
#>  51:   failed   3.333333  5.0000000         NA 2026-09-17 08:22:40
#>  52:   failed   3.333333  3.8888889         NA 2026-09-17 08:22:40
#>  53:   failed   3.333333  2.7777778         NA 2026-09-17 08:22:40
#>  54:   failed   3.333333  1.6666667         NA 2026-09-17 08:22:40
#>  55:   failed   3.333333  0.5555556         NA 2026-09-17 08:22:40
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-17 08:22:40
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-17 08:22:40
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-17 08:22:40
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-17 08:22:40
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-17 08:22:40
#>  61:   failed   1.111111  5.0000000         NA 2026-09-17 08:22:40
#>  62:   failed   1.111111  3.8888889         NA 2026-09-17 08:22:40
#>  63:   failed   1.111111  2.7777778         NA 2026-09-17 08:22:40
#>  64:   failed   1.111111  1.6666667         NA 2026-09-17 08:22:40
#>  65:   failed   1.111111  0.5555556         NA 2026-09-17 08:22:40
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-17 08:22:40
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-17 08:22:40
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-17 08:22:40
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-17 08:22:40
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-17 08:22:40
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-17 08:22:40
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-17 08:22:40
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-17 08:22:40
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-17 08:22:40
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-17 08:22:40
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-17 08:22:40
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-17 08:22:40
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-17 08:22:40
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-17 08:22:40
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-17 08:22:40
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-17 08:22:40
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-17 08:22:40
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-17 08:22:40
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-17 08:22:40
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-17 08:22:40
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-17 08:22:40
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-17 08:22:40
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-17 08:22:40
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-17 08:22:40
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-17 08:22:40
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-17 08:22:40
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-17 08:22:40
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-17 08:22:40
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-17 08:22:40
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-17 08:22:40
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-17 08:22:40
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-17 08:22:40
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-17 08:22:40
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-17 08:22:40
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-17 08:22:40
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>   2: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>   3: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>   4: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>   5: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>   6: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>   7: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>   8: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>   9: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>  10: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>  11: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>  12: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>  13: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>  14: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>  15: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>  16: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>  17: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>  18: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>  19: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
#>  20: sinking_raccoon_f1f8d5c0 2026-09-17 08:22:41
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
#>   1: 991bf325-1d3f-4f3c-9df7-640d4f09135c    [NULL]  -10.000000  -5.0000000
#>   2: 0f871ebd-66e3-4a85-b697-194a2e189c3c    [NULL]  -10.000000  -3.8888889
#>   3: 71d4eb47-990a-48bd-9216-3f9d064dae62    [NULL]  -10.000000  -2.7777778
#>   4: 9bfdd548-f61c-425d-bbfe-507588fec7e9    [NULL]  -10.000000  -1.6666667
#>   5: 3853a67a-35dc-4dbe-b8c0-0840476bc6c4    [NULL]  -10.000000  -0.5555556
#>   6: 14111166-93e2-4c95-be7b-ab053b58fc85    [NULL]  -10.000000   0.5555556
#>   7: 94b5b943-a669-4d1e-b2dd-825ddfe9d1f1    [NULL]  -10.000000   1.6666667
#>   8: 05d31f16-b492-411d-ac8b-f3817fcee095    [NULL]  -10.000000   2.7777778
#>   9: 194e3b2e-890d-4d71-ac45-ea752f71d425    [NULL]  -10.000000   3.8888889
#>  10: 518a0afb-5af8-416a-9996-0ac1315d0330    [NULL]  -10.000000   5.0000000
#>  11: 4f4a136c-eace-439c-99b6-90cec8027496    [NULL]   -7.777778  -5.0000000
#>  12: dc71dd19-a9a3-4311-a81b-00ff72cc3666    [NULL]   -7.777778  -3.8888889
#>  13: 4592a361-030d-4861-a896-ce123de8ad27    [NULL]   -7.777778  -2.7777778
#>  14: df3bac54-a894-44d8-93a3-62f857c0649e    [NULL]   -7.777778  -1.6666667
#>  15: b32f992e-c861-485c-8f3d-09b949a67c0a    [NULL]   -7.777778  -0.5555556
#>  16: c7163acc-9b1a-48ee-9926-ff5a922dc473    [NULL]   -7.777778   0.5555556
#>  17: 0f2dacea-c045-49ea-be3b-c38bee7aa57f    [NULL]   -7.777778   1.6666667
#>  18: 067d46c1-4678-4ad1-8778-c00a2c24cf32    [NULL]   -7.777778   2.7777778
#>  19: bce398a2-7673-4cbb-9529-2ad2dede3ac0    [NULL]   -7.777778   3.8888889
#>  20: 85096121-1e4d-4708-83d9-4f584b4a3e11    [NULL]   -7.777778   5.0000000
#>  21: e8c575c6-42d2-4526-8e11-8b50426c7bd5 <list[1]>          NA          NA
#>  22: 224a7a2a-1c45-4937-8347-609c8cf98cd1 <list[1]>          NA          NA
#>  23: 14ae322d-8402-451a-a66a-be34d96d8b41 <list[1]>          NA          NA
#>  24: dee55100-957f-4cf4-b647-e7fcbaa6436b <list[1]>          NA          NA
#>  25: 056a393b-8ba5-47fe-85f8-7d81f4620b57 <list[1]>          NA          NA
#>  26: dab3e117-88da-4481-af98-17f260fe6e91 <list[1]>          NA          NA
#>  27: d25cb434-79e7-44ac-8f14-79e7af482cee <list[1]>          NA          NA
#>  28: d519e7f8-5438-4679-afe0-fd4fea20fe7d <list[1]>          NA          NA
#>  29: b21c78b8-af2b-49d5-9d30-9223200ac618 <list[1]>          NA          NA
#>  30: 494aa762-cb5d-4a1e-af51-0ab188d94313 <list[1]>          NA          NA
#>  31: c84ac197-a157-43ac-bbeb-2655a0782046 <list[1]>          NA          NA
#>  32: 75d69e6e-ec34-4aa4-91c4-7ea1c2d1b47c <list[1]>          NA          NA
#>  33: 329b10a8-c2a5-4e91-929c-2a2d84323789 <list[1]>          NA          NA
#>  34: 8ed0c3c8-c814-47c7-b010-32a65105c61d <list[1]>          NA          NA
#>  35: 1d231701-9c73-4552-9ab1-dfe66de40000 <list[1]>          NA          NA
#>  36: 2e4d41d1-9480-419d-8be5-e93ced08e81e <list[1]>          NA          NA
#>  37: ea44f9d6-7377-4e91-a58e-6deadc5781e7 <list[1]>          NA          NA
#>  38: 9d358fd0-a36b-460a-a709-a34a06c422f0 <list[1]>          NA          NA
#>  39: bc813e06-3bf4-4e61-b151-d1d5c547e0d7 <list[1]>          NA          NA
#>  40: 6afbb0cc-4aca-4795-b616-e4287b76c868 <list[1]>          NA          NA
#>  41: 2f343cf1-1397-4cd1-94a4-3bda06d45974 <list[1]>          NA          NA
#>  42: 480382ba-00b4-4ce8-8710-3dd63dd51d97 <list[1]>          NA          NA
#>  43: 008008e2-845d-4260-b707-9ea6118e68b9 <list[1]>          NA          NA
#>  44: 4eb0fc74-2390-4c44-b02c-1779be16ee21 <list[1]>          NA          NA
#>  45: c47ae679-aecc-4709-9ed2-e8173879408a <list[1]>          NA          NA
#>  46: e8af930d-ed7f-42e5-83b6-d93996a82893 <list[1]>          NA          NA
#>  47: 6d40a330-33e9-4e3e-9524-f9cdf7594e86 <list[1]>          NA          NA
#>  48: e95edd0c-b6e5-42a9-b314-358b5a835086 <list[1]>          NA          NA
#>  49: a89afe33-9a2a-441f-afd8-fca996f9398b <list[1]>          NA          NA
#>  50: 4e781d28-7bf3-46eb-89dc-5c68b3f7e318 <list[1]>          NA          NA
#>  51: ae6a5b4a-7ff8-4f3a-9c3c-0fc13327a008 <list[1]>          NA          NA
#>  52: bca54f6d-4294-42eb-8d16-1b3beb6f15f6 <list[1]>          NA          NA
#>  53: 2d781c0a-f13f-4d81-9e02-aae6eb165ae0 <list[1]>          NA          NA
#>  54: 0ad1e4f8-f37a-4dcb-9fcd-80aa070fcadd <list[1]>          NA          NA
#>  55: 5dae270c-8da3-42a6-8082-d4027cba894a <list[1]>          NA          NA
#>  56: 9e987ee3-1bd6-4d36-aec1-293a44ef8ec4 <list[1]>          NA          NA
#>  57: 13bc6935-862b-4546-82d4-21b8f4819a7b <list[1]>          NA          NA
#>  58: 1e5a81ce-7f65-4ef6-9b33-78969e3a3100 <list[1]>          NA          NA
#>  59: c90de8cd-f1bf-4a95-b01e-3475f44ee964 <list[1]>          NA          NA
#>  60: 5bbdeab6-a56b-4dd1-8b44-b82ec7b1f59a <list[1]>          NA          NA
#>  61: c8b98c8b-8f2a-496c-a854-4e72279f2ebe <list[1]>          NA          NA
#>  62: 40911683-6091-4a8e-8f62-9c3b4b9b7ea8 <list[1]>          NA          NA
#>  63: 978045c5-a62a-47f6-94f7-a6fd1b653bc8 <list[1]>          NA          NA
#>  64: a94e7693-cd10-4484-a12c-f71a613a8582 <list[1]>          NA          NA
#>  65: 3c41e99e-c550-4545-bcd4-6097b7715206 <list[1]>          NA          NA
#>  66: f1b870c6-3a6b-4351-bf29-3ca59c14e559 <list[1]>          NA          NA
#>  67: 8fd39600-b50b-481b-8c13-6b7eff0afc11 <list[1]>          NA          NA
#>  68: 80b06206-ad72-4f44-a643-025f7fa54811 <list[1]>          NA          NA
#>  69: 7559dc81-c4a7-4ab9-9886-723b7819b3dd <list[1]>          NA          NA
#>  70: f4115f77-5a7e-4a6c-8364-35b1d52c8578 <list[1]>          NA          NA
#>  71: fc9f0dbb-c01b-4ce3-b5f0-35527bdee327 <list[1]>          NA          NA
#>  72: 2bcce0f6-34fd-443b-97d0-41fe997a55cf <list[1]>          NA          NA
#>  73: 4b372da9-a1b2-467a-8fe0-3cb6eb8710d7 <list[1]>          NA          NA
#>  74: e55c19fc-e8d7-489a-b92b-b6f3dc6477d4 <list[1]>          NA          NA
#>  75: b7b5f3da-92a7-4178-be61-2d2286857bda <list[1]>          NA          NA
#>  76: 8456cb51-6883-4944-b52e-e256df6fdd8d <list[1]>          NA          NA
#>  77: f72dac8e-dce6-4273-8197-2a35de95667d <list[1]>          NA          NA
#>  78: 37c83cff-419f-433f-86f9-c97983365053 <list[1]>          NA          NA
#>  79: aa856c08-dc86-4056-87a9-debef3296b78 <list[1]>          NA          NA
#>  80: ea091015-0a01-4f59-9668-cb06ee3302f7 <list[1]>          NA          NA
#>  81: 0cce01f9-8c0b-4b50-a7b4-34e33c1558a1 <list[1]>          NA          NA
#>  82: 93e8ca56-e824-42ac-a4cd-aabe161cf2ff <list[1]>          NA          NA
#>  83: 78c777bf-3405-49fb-b6e2-08d72d87b4f3 <list[1]>          NA          NA
#>  84: f6a70fe9-2162-41ae-8962-2bd2169f2978 <list[1]>          NA          NA
#>  85: 38556840-0a0b-462a-9116-a4ad2e7e7ea5 <list[1]>          NA          NA
#>  86: 5d079680-b26e-4dc5-884b-f97eebb20729 <list[1]>          NA          NA
#>  87: f436534f-ca98-4f24-aac3-487ccbab4463 <list[1]>          NA          NA
#>  88: 04ec3bd8-bc21-4f43-a8a2-3c41ea1eccd8 <list[1]>          NA          NA
#>  89: cb949ab5-fb02-4fba-8037-fc26812fe07e <list[1]>          NA          NA
#>  90: 213bc4a8-621c-47ef-bb62-74262cc601d4 <list[1]>          NA          NA
#>  91: 0063cfa3-6d32-4bbc-ab20-f6f140f33e64 <list[1]>          NA          NA
#>  92: f75f31dd-9847-46db-ad51-6866126db05c <list[1]>          NA          NA
#>  93: 198ae5e9-5b58-44fc-bc01-7200fe284962 <list[1]>          NA          NA
#>  94: 5349b7f0-a7b2-4218-8989-c5f18cef594e <list[1]>          NA          NA
#>  95: 8115fa5c-8eff-4b0a-9389-c48476d58221 <list[1]>          NA          NA
#>  96: 3be6143e-0004-4803-b19e-2f5be7f70736 <list[1]>          NA          NA
#>  97: 18486424-a481-4d6a-8f68-edde1993a5f5 <list[1]>          NA          NA
#>  98: 6213aef6-8fe6-4e9f-ac94-5df87edf8cbb <list[1]>          NA          NA
#>  99: 70a5d922-8219-40c3-847a-465a3630d631 <list[1]>          NA          NA
#> 100: f9a25ff9-a08f-418a-a257-520bf51f76cf <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
