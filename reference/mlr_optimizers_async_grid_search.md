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

This [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md) can
be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/reference/opt.md):

    mlr_optimizers$get("async_grid_search")
    opt("async_grid_search")

## Parameters

- `batch_size`:

  `integer(1)`  
  Maximum number of points to try in a batch.

## Super classes

[`Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md) -\>
[`OptimizerAsync`](https://bbotk.mlr-org.com/reference/OptimizerAsync.md)
-\> `OptimizerAsyncGridSearch`

## Methods

### Public methods

- [`OptimizerAsyncGridSearch$new()`](#method-OptimizerAsyncGridSearch-initialize)

- [`OptimizerAsyncGridSearch$optimize()`](#method-OptimizerAsyncGridSearch-optimize)

- [`OptimizerAsyncGridSearch$clone()`](#method-OptimizerAsyncGridSearch-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-help)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-print)

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

  ([OptimInstance](https://bbotk.mlr-org.com/reference/OptimInstance.md)).

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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-07-20 08:44:11
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-07-20 08:44:11
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-07-20 08:44:11
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-07-20 08:44:11
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-07-20 08:44:11
#>   6: finished -10.000000  0.5555556 -146.64198 2026-07-20 08:44:11
#>   7: finished -10.000000  1.6666667 -155.77778 2026-07-20 08:44:11
#>   8: finished -10.000000  2.7777778 -167.38272 2026-07-20 08:44:11
#>   9: finished -10.000000  3.8888889 -181.45679 2026-07-20 08:44:11
#>  10: finished -10.000000  5.0000000 -198.00000 2026-07-20 08:44:11
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-07-20 08:44:11
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-07-20 08:44:11
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-07-20 08:44:11
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-07-20 08:44:11
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-07-20 08:44:11
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-07-20 08:44:11
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-07-20 08:44:11
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-07-20 08:44:11
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-07-20 08:44:11
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-07-20 08:44:11
#>  21:   failed  10.000000  5.0000000         NA 2026-07-20 08:44:11
#>  22:   failed  10.000000  3.8888889         NA 2026-07-20 08:44:11
#>  23:   failed  10.000000  2.7777778         NA 2026-07-20 08:44:11
#>  24:   failed  10.000000  1.6666667         NA 2026-07-20 08:44:11
#>  25:   failed  10.000000  0.5555556         NA 2026-07-20 08:44:11
#>  26:   failed  10.000000 -0.5555556         NA 2026-07-20 08:44:11
#>  27:   failed  10.000000 -1.6666667         NA 2026-07-20 08:44:11
#>  28:   failed  10.000000 -2.7777778         NA 2026-07-20 08:44:11
#>  29:   failed  10.000000 -3.8888889         NA 2026-07-20 08:44:11
#>  30:   failed  10.000000 -5.0000000         NA 2026-07-20 08:44:11
#>  31:   failed   7.777778  5.0000000         NA 2026-07-20 08:44:11
#>  32:   failed   7.777778  3.8888889         NA 2026-07-20 08:44:11
#>  33:   failed   7.777778  2.7777778         NA 2026-07-20 08:44:11
#>  34:   failed   7.777778  1.6666667         NA 2026-07-20 08:44:11
#>  35:   failed   7.777778  0.5555556         NA 2026-07-20 08:44:11
#>  36:   failed   7.777778 -0.5555556         NA 2026-07-20 08:44:11
#>  37:   failed   7.777778 -1.6666667         NA 2026-07-20 08:44:11
#>  38:   failed   7.777778 -2.7777778         NA 2026-07-20 08:44:11
#>  39:   failed   7.777778 -3.8888889         NA 2026-07-20 08:44:11
#>  40:   failed   7.777778 -5.0000000         NA 2026-07-20 08:44:11
#>  41:   failed   5.555556  5.0000000         NA 2026-07-20 08:44:11
#>  42:   failed   5.555556  3.8888889         NA 2026-07-20 08:44:11
#>  43:   failed   5.555556  2.7777778         NA 2026-07-20 08:44:11
#>  44:   failed   5.555556  1.6666667         NA 2026-07-20 08:44:11
#>  45:   failed   5.555556  0.5555556         NA 2026-07-20 08:44:11
#>  46:   failed   5.555556 -0.5555556         NA 2026-07-20 08:44:11
#>  47:   failed   5.555556 -1.6666667         NA 2026-07-20 08:44:11
#>  48:   failed   5.555556 -2.7777778         NA 2026-07-20 08:44:11
#>  49:   failed   5.555556 -3.8888889         NA 2026-07-20 08:44:11
#>  50:   failed   5.555556 -5.0000000         NA 2026-07-20 08:44:11
#>  51:   failed   3.333333  5.0000000         NA 2026-07-20 08:44:11
#>  52:   failed   3.333333  3.8888889         NA 2026-07-20 08:44:11
#>  53:   failed   3.333333  2.7777778         NA 2026-07-20 08:44:11
#>  54:   failed   3.333333  1.6666667         NA 2026-07-20 08:44:11
#>  55:   failed   3.333333  0.5555556         NA 2026-07-20 08:44:11
#>  56:   failed   3.333333 -0.5555556         NA 2026-07-20 08:44:11
#>  57:   failed   3.333333 -1.6666667         NA 2026-07-20 08:44:11
#>  58:   failed   3.333333 -2.7777778         NA 2026-07-20 08:44:11
#>  59:   failed   3.333333 -3.8888889         NA 2026-07-20 08:44:11
#>  60:   failed   3.333333 -5.0000000         NA 2026-07-20 08:44:11
#>  61:   failed   1.111111  5.0000000         NA 2026-07-20 08:44:11
#>  62:   failed   1.111111  3.8888889         NA 2026-07-20 08:44:11
#>  63:   failed   1.111111  2.7777778         NA 2026-07-20 08:44:11
#>  64:   failed   1.111111  1.6666667         NA 2026-07-20 08:44:11
#>  65:   failed   1.111111  0.5555556         NA 2026-07-20 08:44:11
#>  66:   failed   1.111111 -0.5555556         NA 2026-07-20 08:44:11
#>  67:   failed   1.111111 -1.6666667         NA 2026-07-20 08:44:11
#>  68:   failed   1.111111 -2.7777778         NA 2026-07-20 08:44:11
#>  69:   failed   1.111111 -3.8888889         NA 2026-07-20 08:44:11
#>  70:   failed   1.111111 -5.0000000         NA 2026-07-20 08:44:11
#>  71:   failed  -1.111111  5.0000000         NA 2026-07-20 08:44:11
#>  72:   failed  -1.111111  3.8888889         NA 2026-07-20 08:44:11
#>  73:   failed  -1.111111  2.7777778         NA 2026-07-20 08:44:11
#>  74:   failed  -1.111111  1.6666667         NA 2026-07-20 08:44:11
#>  75:   failed  -1.111111  0.5555556         NA 2026-07-20 08:44:11
#>  76:   failed  -1.111111 -0.5555556         NA 2026-07-20 08:44:11
#>  77:   failed  -1.111111 -1.6666667         NA 2026-07-20 08:44:11
#>  78:   failed  -1.111111 -2.7777778         NA 2026-07-20 08:44:11
#>  79:   failed  -1.111111 -3.8888889         NA 2026-07-20 08:44:11
#>  80:   failed  -1.111111 -5.0000000         NA 2026-07-20 08:44:11
#>  81:   failed  -3.333333  5.0000000         NA 2026-07-20 08:44:11
#>  82:   failed  -3.333333  3.8888889         NA 2026-07-20 08:44:11
#>  83:   failed  -3.333333  2.7777778         NA 2026-07-20 08:44:11
#>  84:   failed  -3.333333  1.6666667         NA 2026-07-20 08:44:11
#>  85:   failed  -3.333333  0.5555556         NA 2026-07-20 08:44:11
#>  86:   failed  -3.333333 -0.5555556         NA 2026-07-20 08:44:11
#>  87:   failed  -3.333333 -1.6666667         NA 2026-07-20 08:44:11
#>  88:   failed  -3.333333 -2.7777778         NA 2026-07-20 08:44:11
#>  89:   failed  -3.333333 -3.8888889         NA 2026-07-20 08:44:11
#>  90:   failed  -3.333333 -5.0000000         NA 2026-07-20 08:44:11
#>  91:   failed  -5.555556  5.0000000         NA 2026-07-20 08:44:11
#>  92:   failed  -5.555556  3.8888889         NA 2026-07-20 08:44:11
#>  93:   failed  -5.555556  2.7777778         NA 2026-07-20 08:44:11
#>  94:   failed  -5.555556  1.6666667         NA 2026-07-20 08:44:11
#>  95:   failed  -5.555556  0.5555556         NA 2026-07-20 08:44:11
#>  96:   failed  -5.555556 -0.5555556         NA 2026-07-20 08:44:11
#>  97:   failed  -5.555556 -1.6666667         NA 2026-07-20 08:44:11
#>  98:   failed  -5.555556 -2.7777778         NA 2026-07-20 08:44:11
#>  99:   failed  -5.555556 -3.8888889         NA 2026-07-20 08:44:11
#> 100:   failed  -5.555556 -5.0000000         NA 2026-07-20 08:44:11
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_e9196fd6 2026-07-20 08:44:12
#>   2: sinking_raccoon_e9196fd6 2026-07-20 08:44:12
#>   3: sinking_raccoon_e9196fd6 2026-07-20 08:44:12
#>   4: sinking_raccoon_e9196fd6 2026-07-20 08:44:12
#>   5: sinking_raccoon_e9196fd6 2026-07-20 08:44:12
#>   6: sinking_raccoon_e9196fd6 2026-07-20 08:44:12
#>   7: sinking_raccoon_e9196fd6 2026-07-20 08:44:12
#>   8: sinking_raccoon_e9196fd6 2026-07-20 08:44:12
#>   9: sinking_raccoon_e9196fd6 2026-07-20 08:44:12
#>  10: sinking_raccoon_e9196fd6 2026-07-20 08:44:12
#>  11: sinking_raccoon_e9196fd6 2026-07-20 08:44:12
#>  12: sinking_raccoon_e9196fd6 2026-07-20 08:44:12
#>  13: sinking_raccoon_e9196fd6 2026-07-20 08:44:13
#>  14: sinking_raccoon_e9196fd6 2026-07-20 08:44:13
#>  15: sinking_raccoon_e9196fd6 2026-07-20 08:44:13
#>  16: sinking_raccoon_e9196fd6 2026-07-20 08:44:13
#>  17: sinking_raccoon_e9196fd6 2026-07-20 08:44:13
#>  18: sinking_raccoon_e9196fd6 2026-07-20 08:44:13
#>  19: sinking_raccoon_e9196fd6 2026-07-20 08:44:13
#>  20: sinking_raccoon_e9196fd6 2026-07-20 08:44:13
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
#>   1: 055474d1-0de5-42d3-bf2f-7f9faf74d38c    [NULL]  -10.000000  -5.0000000
#>   2: e3ec90ee-317b-467d-b869-703d80161e5c    [NULL]  -10.000000  -3.8888889
#>   3: 6720d7c1-5a95-4b3e-a798-6f949f773fea    [NULL]  -10.000000  -2.7777778
#>   4: 6ca89999-f83c-4073-9dca-23392e95ced7    [NULL]  -10.000000  -1.6666667
#>   5: 78859dee-8355-40fd-a65f-72a1dcc69132    [NULL]  -10.000000  -0.5555556
#>   6: 0e33e466-926a-42e2-bf9d-ba0fb5de4e76    [NULL]  -10.000000   0.5555556
#>   7: 72dda408-5663-4521-a887-98cdf55d56b9    [NULL]  -10.000000   1.6666667
#>   8: 9a9ddf84-4d0e-4543-ae1d-48f74e70fff9    [NULL]  -10.000000   2.7777778
#>   9: ad7e7e6a-e2c4-42e0-a07a-12f32780bf87    [NULL]  -10.000000   3.8888889
#>  10: fc695ae7-86f6-4f51-828a-54ba860e4c11    [NULL]  -10.000000   5.0000000
#>  11: fb302aa5-4591-42d0-8a08-655234379da6    [NULL]   -7.777778  -5.0000000
#>  12: 84042d63-bf43-47da-809d-16f304e54ba1    [NULL]   -7.777778  -3.8888889
#>  13: 46f512a4-d244-4360-aa29-00e868d8352f    [NULL]   -7.777778  -2.7777778
#>  14: 85a59fa5-4661-4cac-aaca-689665461dc4    [NULL]   -7.777778  -1.6666667
#>  15: a916545b-1cb4-4da9-8bc1-0446710ad4b8    [NULL]   -7.777778  -0.5555556
#>  16: edc71da8-61af-449e-a973-f4ab233646f4    [NULL]   -7.777778   0.5555556
#>  17: e8edcc9f-d467-47f6-b912-4bfe4115ba04    [NULL]   -7.777778   1.6666667
#>  18: c7ecd38a-261c-4d6e-8b32-128fcf53d367    [NULL]   -7.777778   2.7777778
#>  19: 38de630f-80a7-4b30-aac4-9343d40db246    [NULL]   -7.777778   3.8888889
#>  20: b2c9767e-0277-48f4-8249-987a91a12f1b    [NULL]   -7.777778   5.0000000
#>  21: deb90f20-4a57-4464-b2cc-fa6930f18ab9 <list[1]>          NA          NA
#>  22: 90f8e9b3-8715-4353-8cb9-d61116436362 <list[1]>          NA          NA
#>  23: bba5b328-5441-4404-91e9-f7994cad0f02 <list[1]>          NA          NA
#>  24: 7a5973bd-6fa0-4ff9-9216-5bfd042afdd4 <list[1]>          NA          NA
#>  25: 316b5f84-d968-4d1e-b0ef-4bb61b0e6350 <list[1]>          NA          NA
#>  26: f4d38ddc-4976-4441-be5a-bd67a05c42ff <list[1]>          NA          NA
#>  27: 2452c631-dcba-41ea-84f3-b5a8c7ed2497 <list[1]>          NA          NA
#>  28: ee50b4a2-2b8c-44b6-9c4c-d892d200a9d9 <list[1]>          NA          NA
#>  29: 7396ca66-cac0-444a-9acb-9e76b7d3c435 <list[1]>          NA          NA
#>  30: 53ad7986-369c-447d-a198-00c0d407fb45 <list[1]>          NA          NA
#>  31: a6f4fbb8-42a7-4f46-8adc-8950655967f9 <list[1]>          NA          NA
#>  32: 457d657c-895a-460b-ae22-53b1c55c833b <list[1]>          NA          NA
#>  33: 47363bac-ad7d-42fe-8278-27c4adf647fc <list[1]>          NA          NA
#>  34: 2c49a996-295c-4e4e-a318-c9d2efb854cc <list[1]>          NA          NA
#>  35: 880f586e-9b45-4752-ab57-31a59219bb8b <list[1]>          NA          NA
#>  36: b34365fb-b168-46bb-912a-a2bf542361ae <list[1]>          NA          NA
#>  37: 84603f43-2f34-451e-a43c-eb42436d536e <list[1]>          NA          NA
#>  38: 33927653-fc3e-4fd9-8f58-b3dbe498279d <list[1]>          NA          NA
#>  39: 55fb8b0b-be77-4fe9-ba8d-a3271274f025 <list[1]>          NA          NA
#>  40: d55765a9-9162-457b-8057-1d5c5bec5bf9 <list[1]>          NA          NA
#>  41: ab6e2347-c03a-4a99-830d-01f65917ea31 <list[1]>          NA          NA
#>  42: ea032fc7-a96f-48dd-8ae8-cb760abeae6c <list[1]>          NA          NA
#>  43: 27b77e42-d460-4c7b-86ad-f8a5358fe8df <list[1]>          NA          NA
#>  44: 8f3c528e-3b3f-4631-81de-ad83f87ff45d <list[1]>          NA          NA
#>  45: 024c2820-2dac-42dd-96eb-16fa462eff8c <list[1]>          NA          NA
#>  46: e45e50e0-7a5a-4f37-95e1-ee101dae8ff6 <list[1]>          NA          NA
#>  47: 604aafb1-ba47-4665-9939-75cb2003a264 <list[1]>          NA          NA
#>  48: 5132e790-f361-4042-92b5-0317364fec32 <list[1]>          NA          NA
#>  49: 8476a266-2ac4-49c3-b713-0c4ef4b2cd69 <list[1]>          NA          NA
#>  50: 9283c45c-b2ca-4c5e-95d1-110bfba877ca <list[1]>          NA          NA
#>  51: e3d9b019-4c0f-48c5-9714-3ffdca1d1dc1 <list[1]>          NA          NA
#>  52: 01f047aa-475c-4789-80e8-9f03652e4814 <list[1]>          NA          NA
#>  53: 20a0964e-e5f8-4eb1-bc38-9e65b49f047c <list[1]>          NA          NA
#>  54: 01bbcbdf-1fd2-4ed4-ab9a-656569a1df16 <list[1]>          NA          NA
#>  55: c11a84eb-73eb-41a1-addc-eda29e3ce168 <list[1]>          NA          NA
#>  56: e605e56e-6b64-4ab0-acb0-3d3b2887c611 <list[1]>          NA          NA
#>  57: 6b6e3f74-0aef-4c1d-9da3-7d97f51e0ad6 <list[1]>          NA          NA
#>  58: 072d6658-7f80-4dea-8906-8a5fd1f9bd3a <list[1]>          NA          NA
#>  59: 6fbb2ccc-cd83-4e63-be44-1021086b1fcf <list[1]>          NA          NA
#>  60: 67dc7bb6-4d07-4150-bdc1-34326e11ef67 <list[1]>          NA          NA
#>  61: b78752cf-a93b-48d5-a682-175ca87f7026 <list[1]>          NA          NA
#>  62: 53f6a28e-5c17-4816-8d19-b2dced9e6393 <list[1]>          NA          NA
#>  63: 9bc02df8-793c-41cf-a76d-feed81752920 <list[1]>          NA          NA
#>  64: 26c4d53e-293c-421c-b44a-9d07f8a08dd2 <list[1]>          NA          NA
#>  65: bb4914b5-0ffd-4b84-842c-923ede05df0f <list[1]>          NA          NA
#>  66: 4597dbf6-b6e7-482a-b753-7b7096843d96 <list[1]>          NA          NA
#>  67: 3a4a273e-c820-431b-8a99-6f3de1eeed22 <list[1]>          NA          NA
#>  68: e32e4f79-cad8-4e73-8171-c5a6015a4af0 <list[1]>          NA          NA
#>  69: e7706c16-ecae-421f-9e17-9933ae87b6c6 <list[1]>          NA          NA
#>  70: 77f3f13b-aac7-4c3f-877f-ab2538b8d768 <list[1]>          NA          NA
#>  71: b5f190c0-6a22-460f-88f3-a5a89234dd17 <list[1]>          NA          NA
#>  72: 22c4a543-babe-494d-acb6-80441d44d738 <list[1]>          NA          NA
#>  73: 2c687d87-2fa6-4882-b103-4420cc375765 <list[1]>          NA          NA
#>  74: 051fedf6-f34a-4f7e-8e65-e626aaa7dd8d <list[1]>          NA          NA
#>  75: 873f0ee8-9d0e-4a4c-95eb-3e6c470c54f7 <list[1]>          NA          NA
#>  76: 858c5c28-75e4-4595-b121-70ee6ac2aa2f <list[1]>          NA          NA
#>  77: 08cd50bf-d171-4a41-813e-074ea6c67549 <list[1]>          NA          NA
#>  78: cdad6ba7-9d32-4fc2-bcc2-c89fd9efb730 <list[1]>          NA          NA
#>  79: 06f65332-130c-4166-8d2c-29673838c427 <list[1]>          NA          NA
#>  80: 2fe75891-de02-453f-8d17-c46694d7d8a2 <list[1]>          NA          NA
#>  81: 390a1053-07d0-417b-8b6b-245e55487995 <list[1]>          NA          NA
#>  82: 5f3da5ba-3af0-4ed0-a6e9-519d6672a1fe <list[1]>          NA          NA
#>  83: 9afaa70c-db66-4cbb-8581-77fb9033c413 <list[1]>          NA          NA
#>  84: d13ee6af-b836-4b6a-98fb-545c81682cb3 <list[1]>          NA          NA
#>  85: ba99d5fe-c0f4-4fe4-9af3-77e3518cbb1f <list[1]>          NA          NA
#>  86: 0852562c-0ab4-43eb-b15c-5dd55c6b85df <list[1]>          NA          NA
#>  87: 12720c0a-a525-4267-a981-b343bc1c7c11 <list[1]>          NA          NA
#>  88: af26ee81-87cb-421b-9632-86dc969dc8ee <list[1]>          NA          NA
#>  89: e9882c16-020b-4e47-9bc6-e6a84d79025a <list[1]>          NA          NA
#>  90: a29f2013-f8f5-4be6-9145-285b7a0c303f <list[1]>          NA          NA
#>  91: ab76f7cc-4fe4-4e5c-b61e-eed3b2099eff <list[1]>          NA          NA
#>  92: 32eed242-678b-430c-9c6c-c814113d7a99 <list[1]>          NA          NA
#>  93: 82396544-4435-4022-a436-c65c81f994e7 <list[1]>          NA          NA
#>  94: 87739260-eb46-4b1e-948e-16c01dde91ee <list[1]>          NA          NA
#>  95: 2648984e-3387-4e57-b832-5b335f0a690b <list[1]>          NA          NA
#>  96: 96828c23-2fd0-4bfc-ba56-df276370d653 <list[1]>          NA          NA
#>  97: 117fef08-079d-4771-b96c-1d4a082f655a <list[1]>          NA          NA
#>  98: 6039c1f9-0358-46a6-9728-c370bccb8c96 <list[1]>          NA          NA
#>  99: f63ddb91-a1b5-490a-8eff-5e5443220d2e <list[1]>          NA          NA
#> 100: dcd7b671-3c4d-45a9-bbdb-adccc24ee141 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
