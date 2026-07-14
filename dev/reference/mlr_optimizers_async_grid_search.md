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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-07-14 14:48:14
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-07-14 14:48:14
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-07-14 14:48:14
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-07-14 14:48:14
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-07-14 14:48:14
#>   6: finished -10.000000  0.5555556 -146.64198 2026-07-14 14:48:14
#>   7: finished -10.000000  1.6666667 -155.77778 2026-07-14 14:48:14
#>   8: finished -10.000000  2.7777778 -167.38272 2026-07-14 14:48:14
#>   9: finished -10.000000  3.8888889 -181.45679 2026-07-14 14:48:14
#>  10: finished -10.000000  5.0000000 -198.00000 2026-07-14 14:48:14
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-07-14 14:48:14
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-07-14 14:48:14
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-07-14 14:48:14
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-07-14 14:48:14
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-07-14 14:48:14
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-07-14 14:48:14
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-07-14 14:48:14
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-07-14 14:48:14
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-07-14 14:48:14
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-07-14 14:48:14
#>  21:   failed  10.000000  5.0000000         NA 2026-07-14 14:48:14
#>  22:   failed  10.000000  3.8888889         NA 2026-07-14 14:48:14
#>  23:   failed  10.000000  2.7777778         NA 2026-07-14 14:48:14
#>  24:   failed  10.000000  1.6666667         NA 2026-07-14 14:48:14
#>  25:   failed  10.000000  0.5555556         NA 2026-07-14 14:48:14
#>  26:   failed  10.000000 -0.5555556         NA 2026-07-14 14:48:14
#>  27:   failed  10.000000 -1.6666667         NA 2026-07-14 14:48:14
#>  28:   failed  10.000000 -2.7777778         NA 2026-07-14 14:48:14
#>  29:   failed  10.000000 -3.8888889         NA 2026-07-14 14:48:14
#>  30:   failed  10.000000 -5.0000000         NA 2026-07-14 14:48:14
#>  31:   failed   7.777778  5.0000000         NA 2026-07-14 14:48:14
#>  32:   failed   7.777778  3.8888889         NA 2026-07-14 14:48:14
#>  33:   failed   7.777778  2.7777778         NA 2026-07-14 14:48:14
#>  34:   failed   7.777778  1.6666667         NA 2026-07-14 14:48:14
#>  35:   failed   7.777778  0.5555556         NA 2026-07-14 14:48:14
#>  36:   failed   7.777778 -0.5555556         NA 2026-07-14 14:48:14
#>  37:   failed   7.777778 -1.6666667         NA 2026-07-14 14:48:14
#>  38:   failed   7.777778 -2.7777778         NA 2026-07-14 14:48:14
#>  39:   failed   7.777778 -3.8888889         NA 2026-07-14 14:48:14
#>  40:   failed   7.777778 -5.0000000         NA 2026-07-14 14:48:14
#>  41:   failed   5.555556  5.0000000         NA 2026-07-14 14:48:14
#>  42:   failed   5.555556  3.8888889         NA 2026-07-14 14:48:14
#>  43:   failed   5.555556  2.7777778         NA 2026-07-14 14:48:14
#>  44:   failed   5.555556  1.6666667         NA 2026-07-14 14:48:14
#>  45:   failed   5.555556  0.5555556         NA 2026-07-14 14:48:14
#>  46:   failed   5.555556 -0.5555556         NA 2026-07-14 14:48:14
#>  47:   failed   5.555556 -1.6666667         NA 2026-07-14 14:48:14
#>  48:   failed   5.555556 -2.7777778         NA 2026-07-14 14:48:14
#>  49:   failed   5.555556 -3.8888889         NA 2026-07-14 14:48:14
#>  50:   failed   5.555556 -5.0000000         NA 2026-07-14 14:48:14
#>  51:   failed   3.333333  5.0000000         NA 2026-07-14 14:48:14
#>  52:   failed   3.333333  3.8888889         NA 2026-07-14 14:48:14
#>  53:   failed   3.333333  2.7777778         NA 2026-07-14 14:48:14
#>  54:   failed   3.333333  1.6666667         NA 2026-07-14 14:48:14
#>  55:   failed   3.333333  0.5555556         NA 2026-07-14 14:48:14
#>  56:   failed   3.333333 -0.5555556         NA 2026-07-14 14:48:14
#>  57:   failed   3.333333 -1.6666667         NA 2026-07-14 14:48:14
#>  58:   failed   3.333333 -2.7777778         NA 2026-07-14 14:48:14
#>  59:   failed   3.333333 -3.8888889         NA 2026-07-14 14:48:14
#>  60:   failed   3.333333 -5.0000000         NA 2026-07-14 14:48:14
#>  61:   failed   1.111111  5.0000000         NA 2026-07-14 14:48:14
#>  62:   failed   1.111111  3.8888889         NA 2026-07-14 14:48:14
#>  63:   failed   1.111111  2.7777778         NA 2026-07-14 14:48:14
#>  64:   failed   1.111111  1.6666667         NA 2026-07-14 14:48:14
#>  65:   failed   1.111111  0.5555556         NA 2026-07-14 14:48:14
#>  66:   failed   1.111111 -0.5555556         NA 2026-07-14 14:48:14
#>  67:   failed   1.111111 -1.6666667         NA 2026-07-14 14:48:14
#>  68:   failed   1.111111 -2.7777778         NA 2026-07-14 14:48:14
#>  69:   failed   1.111111 -3.8888889         NA 2026-07-14 14:48:14
#>  70:   failed   1.111111 -5.0000000         NA 2026-07-14 14:48:14
#>  71:   failed  -1.111111  5.0000000         NA 2026-07-14 14:48:14
#>  72:   failed  -1.111111  3.8888889         NA 2026-07-14 14:48:14
#>  73:   failed  -1.111111  2.7777778         NA 2026-07-14 14:48:14
#>  74:   failed  -1.111111  1.6666667         NA 2026-07-14 14:48:14
#>  75:   failed  -1.111111  0.5555556         NA 2026-07-14 14:48:14
#>  76:   failed  -1.111111 -0.5555556         NA 2026-07-14 14:48:14
#>  77:   failed  -1.111111 -1.6666667         NA 2026-07-14 14:48:14
#>  78:   failed  -1.111111 -2.7777778         NA 2026-07-14 14:48:14
#>  79:   failed  -1.111111 -3.8888889         NA 2026-07-14 14:48:14
#>  80:   failed  -1.111111 -5.0000000         NA 2026-07-14 14:48:14
#>  81:   failed  -3.333333  5.0000000         NA 2026-07-14 14:48:14
#>  82:   failed  -3.333333  3.8888889         NA 2026-07-14 14:48:14
#>  83:   failed  -3.333333  2.7777778         NA 2026-07-14 14:48:14
#>  84:   failed  -3.333333  1.6666667         NA 2026-07-14 14:48:14
#>  85:   failed  -3.333333  0.5555556         NA 2026-07-14 14:48:14
#>  86:   failed  -3.333333 -0.5555556         NA 2026-07-14 14:48:14
#>  87:   failed  -3.333333 -1.6666667         NA 2026-07-14 14:48:14
#>  88:   failed  -3.333333 -2.7777778         NA 2026-07-14 14:48:14
#>  89:   failed  -3.333333 -3.8888889         NA 2026-07-14 14:48:14
#>  90:   failed  -3.333333 -5.0000000         NA 2026-07-14 14:48:14
#>  91:   failed  -5.555556  5.0000000         NA 2026-07-14 14:48:14
#>  92:   failed  -5.555556  3.8888889         NA 2026-07-14 14:48:14
#>  93:   failed  -5.555556  2.7777778         NA 2026-07-14 14:48:14
#>  94:   failed  -5.555556  1.6666667         NA 2026-07-14 14:48:14
#>  95:   failed  -5.555556  0.5555556         NA 2026-07-14 14:48:14
#>  96:   failed  -5.555556 -0.5555556         NA 2026-07-14 14:48:14
#>  97:   failed  -5.555556 -1.6666667         NA 2026-07-14 14:48:14
#>  98:   failed  -5.555556 -2.7777778         NA 2026-07-14 14:48:14
#>  99:   failed  -5.555556 -3.8888889         NA 2026-07-14 14:48:14
#> 100:   failed  -5.555556 -5.0000000         NA 2026-07-14 14:48:14
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>   2: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>   3: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>   4: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>   5: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>   6: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>   7: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>   8: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>   9: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>  10: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>  11: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>  12: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>  13: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>  14: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>  15: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>  16: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>  17: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>  18: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>  19: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
#>  20: sinking_raccoon_9cb6ab83 2026-07-14 14:48:15
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
#>   1: c8d53799-bad9-453b-ae47-ec76c0c852e5    [NULL]  -10.000000  -5.0000000
#>   2: 57e6cc20-5ec5-4c78-928c-65f918e7eff9    [NULL]  -10.000000  -3.8888889
#>   3: 1763faee-c8b4-4aa6-b42b-651159bdd2a0    [NULL]  -10.000000  -2.7777778
#>   4: 1763a8e2-6cdc-478f-bdbf-68890a21c417    [NULL]  -10.000000  -1.6666667
#>   5: bc94e6f5-b6f6-47fe-9032-814bfe164fe9    [NULL]  -10.000000  -0.5555556
#>   6: a0e3f6e8-fd56-40a7-a72d-697f1354acb5    [NULL]  -10.000000   0.5555556
#>   7: 04048fe3-9790-4839-b640-4ba68ed1ac48    [NULL]  -10.000000   1.6666667
#>   8: 63cd5936-bb2b-4ab6-9ef2-0fa58b5ebf0b    [NULL]  -10.000000   2.7777778
#>   9: ecf1adc5-21e1-4d82-80b3-bc5fd9b2adcd    [NULL]  -10.000000   3.8888889
#>  10: ba4fd2c2-06b2-48a5-bdef-4540af88a028    [NULL]  -10.000000   5.0000000
#>  11: cea9a70f-c1a8-4c3b-8070-84c4f7db7e26    [NULL]   -7.777778  -5.0000000
#>  12: cc038953-d5af-4130-bc9c-325f7997af4a    [NULL]   -7.777778  -3.8888889
#>  13: e539705a-d679-4c96-b451-1b4ce04c657b    [NULL]   -7.777778  -2.7777778
#>  14: a2c7fd81-2fa7-4ba9-9b6a-61f3a1623be6    [NULL]   -7.777778  -1.6666667
#>  15: dab93eab-9979-4d18-bd00-8df581b4a574    [NULL]   -7.777778  -0.5555556
#>  16: 2f8482c5-9d09-4aae-95c4-71ba4470cb2e    [NULL]   -7.777778   0.5555556
#>  17: ddfbf1ac-a394-4f76-8285-380124280a5f    [NULL]   -7.777778   1.6666667
#>  18: d3bd04eb-c473-40e4-821a-1de6f49e0f2e    [NULL]   -7.777778   2.7777778
#>  19: df670413-7eee-430b-a438-c98e32addca6    [NULL]   -7.777778   3.8888889
#>  20: e5b6803a-1a2f-4e5d-87c3-c08c5756c4df    [NULL]   -7.777778   5.0000000
#>  21: 33798a68-98f5-48c6-ab9e-8ff36cbca9a6 <list[1]>          NA          NA
#>  22: e26df2f0-4b75-49b9-adce-37caa9b943a7 <list[1]>          NA          NA
#>  23: 51465655-3b3c-4f7b-85f7-7b65d676f26b <list[1]>          NA          NA
#>  24: 753b2228-b81e-4d0f-86fb-a2608b2e12cc <list[1]>          NA          NA
#>  25: e700e167-ddf8-4a16-914f-4a4a643f5247 <list[1]>          NA          NA
#>  26: 56db493d-ca73-406d-b1b7-d8b2506d54d3 <list[1]>          NA          NA
#>  27: f8548783-c321-45be-81e4-faea414a292d <list[1]>          NA          NA
#>  28: 58498a92-8949-498b-bdd2-463afe4ed9d7 <list[1]>          NA          NA
#>  29: a4981cec-ec30-4189-81ae-9be060584dae <list[1]>          NA          NA
#>  30: d61d3732-1e19-4c35-8e02-2085466ffc9c <list[1]>          NA          NA
#>  31: 70d91bfb-f72f-43a9-9818-f9a8b763911a <list[1]>          NA          NA
#>  32: d068ddd1-d62a-40ff-b56d-65ef0e55dcb2 <list[1]>          NA          NA
#>  33: 738fc027-e8b6-454c-a265-b61510dbac43 <list[1]>          NA          NA
#>  34: 5c3fb9da-b41c-4300-beb1-f638e0352def <list[1]>          NA          NA
#>  35: 0e14d89f-f358-4a1d-844d-a680861ab5a5 <list[1]>          NA          NA
#>  36: 68dad7e8-60ac-48bd-9c8e-5c6f4ea369bd <list[1]>          NA          NA
#>  37: faa2adff-2ff1-4e7b-986d-4a661745e3d0 <list[1]>          NA          NA
#>  38: 0013e0ad-6ded-4011-92fb-fbe95c31b316 <list[1]>          NA          NA
#>  39: 45030f23-ece7-4f2f-8d12-3aa5a78e18c4 <list[1]>          NA          NA
#>  40: ec9f3799-d588-4b4e-abe3-7dda17fa9e85 <list[1]>          NA          NA
#>  41: dab223b8-3a12-4bc8-bf83-69cde8d14965 <list[1]>          NA          NA
#>  42: 8e5e2a77-1690-4c75-865b-ef575f7fc51d <list[1]>          NA          NA
#>  43: c462c671-6d5c-43bd-817a-7d9ec34140be <list[1]>          NA          NA
#>  44: b35b9872-e100-44a2-9e92-992a8c4d4633 <list[1]>          NA          NA
#>  45: b32adde8-38f9-4bcf-9e5c-86e53b519866 <list[1]>          NA          NA
#>  46: 044dbd0b-2ed8-4d00-aa41-45b162fcc376 <list[1]>          NA          NA
#>  47: 3c74edd8-92bb-4b81-bb62-b23f50ecd69c <list[1]>          NA          NA
#>  48: d499b59f-c38d-4ed1-880c-69d4336b5416 <list[1]>          NA          NA
#>  49: 5e0478d5-2a62-44c7-93a9-c7f4bc2dde83 <list[1]>          NA          NA
#>  50: 45a04d57-9aae-458e-9bfd-4294fd429321 <list[1]>          NA          NA
#>  51: 38d7936c-cc97-4e5c-a468-ee2497436112 <list[1]>          NA          NA
#>  52: fea0bfe7-47f2-44b5-93d7-078ed2ec4703 <list[1]>          NA          NA
#>  53: 62fd5f15-1cb6-43dd-97af-20432dc093a6 <list[1]>          NA          NA
#>  54: 90042d39-1c15-4e00-807c-93110b050977 <list[1]>          NA          NA
#>  55: 49b3bdb6-7b9f-4360-9ee4-73245a78ac45 <list[1]>          NA          NA
#>  56: c6621c4f-c21e-4773-8905-8d1d1281b3a5 <list[1]>          NA          NA
#>  57: 11527bff-cd78-4cde-8e5f-227505e81f42 <list[1]>          NA          NA
#>  58: a1220ba3-1a41-4628-95e5-010bb5d1c783 <list[1]>          NA          NA
#>  59: 68326bbc-391d-417c-8eef-2c94c336de05 <list[1]>          NA          NA
#>  60: 407d6529-bdb5-4813-83e0-cf5f4d4dca4d <list[1]>          NA          NA
#>  61: d84ace14-5f1e-42eb-87a8-1d5ac26fe87b <list[1]>          NA          NA
#>  62: 51a4cffc-78c2-4b4f-98d1-b63b7953319e <list[1]>          NA          NA
#>  63: 73a0e2e3-17e2-4bdf-aae4-0f6b441d67e3 <list[1]>          NA          NA
#>  64: a7f81ed0-fb7c-4eef-be65-639758ea5815 <list[1]>          NA          NA
#>  65: 7d418e64-52e1-45cd-b744-cf3e87b66b29 <list[1]>          NA          NA
#>  66: cabd6696-2211-4395-93a3-28f2865a8867 <list[1]>          NA          NA
#>  67: 85aac515-3d64-4aa7-9685-0304d9693eeb <list[1]>          NA          NA
#>  68: dabbf35f-cf1f-4594-9cfb-1aff7c0d6e1c <list[1]>          NA          NA
#>  69: b8e45674-8d5f-4c13-a7d2-6e784491dfef <list[1]>          NA          NA
#>  70: a301718a-1413-48cf-a9dd-4a97b71f31b2 <list[1]>          NA          NA
#>  71: 74a27ea3-6e2b-4b00-b4bc-f5ca631f88a6 <list[1]>          NA          NA
#>  72: e3923d1d-d341-481b-89fb-a731f99f74c3 <list[1]>          NA          NA
#>  73: a546b388-18a3-4b94-91b7-ab9e0e60aa0f <list[1]>          NA          NA
#>  74: c72da84a-afbc-4c13-87f8-87cb7883080e <list[1]>          NA          NA
#>  75: fae5b0df-d58a-4fbf-a9a7-09c11a29d47f <list[1]>          NA          NA
#>  76: e8889588-08d3-46b6-b8f0-890d4d2ba467 <list[1]>          NA          NA
#>  77: 2326aaf7-705d-4d62-81ec-848fbdfe1ac0 <list[1]>          NA          NA
#>  78: 67f9b921-083e-4d93-86a2-950916dfb0b9 <list[1]>          NA          NA
#>  79: b8078da1-59e5-41a3-9f64-f37a90c7f5f0 <list[1]>          NA          NA
#>  80: df2a7168-717e-43b3-af36-cc59f66b1512 <list[1]>          NA          NA
#>  81: b5ea2284-5927-4b8e-8f7a-ca69768e40c9 <list[1]>          NA          NA
#>  82: 9dc4c6c0-f3da-43a8-8d36-1b8846a9a228 <list[1]>          NA          NA
#>  83: 2145c89f-0b71-4304-bcbc-fcba5c249845 <list[1]>          NA          NA
#>  84: 23a3e402-2f2b-4b6c-bd05-21ad7079c90e <list[1]>          NA          NA
#>  85: b5f4d39c-2740-4e9e-a386-043f3144ae99 <list[1]>          NA          NA
#>  86: 2cc26a0a-62a3-4c2d-8e3f-a4e2f9d3866f <list[1]>          NA          NA
#>  87: e814fd77-8ae5-4677-b8f2-9775c632c6e3 <list[1]>          NA          NA
#>  88: ea29fc86-6fe2-4c4a-a07a-d2f5016ebbf3 <list[1]>          NA          NA
#>  89: d7030947-6059-4978-a964-73c479e6867c <list[1]>          NA          NA
#>  90: 742d0ab7-2d3e-4f47-b680-554491b74a01 <list[1]>          NA          NA
#>  91: 93bb9c21-554c-46c7-be28-24c014b27837 <list[1]>          NA          NA
#>  92: 1df89fd7-37bb-4850-9b2d-fd5a10c254bc <list[1]>          NA          NA
#>  93: e019a5c4-e883-4b17-9f62-0082c4ef8136 <list[1]>          NA          NA
#>  94: b84844ba-26bc-4c1c-9ab2-fc544ca1c40e <list[1]>          NA          NA
#>  95: 91f55997-ed3e-4410-9b93-134198eea3f4 <list[1]>          NA          NA
#>  96: 1b9b0817-074d-4dc5-a477-c1cd7c7715d7 <list[1]>          NA          NA
#>  97: 2bf6401a-be19-4eb0-80c8-6ad725f87098 <list[1]>          NA          NA
#>  98: 5a2d68fc-c03f-4c4b-a446-c2fe05e2581a <list[1]>          NA          NA
#>  99: 43188f8b-0e37-40be-b56c-6b16c1e9e922 <list[1]>          NA          NA
#> 100: c336ff81-8f42-44de-9d63-6cb728cc2697 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
