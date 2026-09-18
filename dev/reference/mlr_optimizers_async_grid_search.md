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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-18 09:19:21
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-18 09:19:21
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-18 09:19:21
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-18 09:19:21
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-18 09:19:21
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-18 09:19:21
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-18 09:19:21
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-18 09:19:21
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-18 09:19:21
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-18 09:19:21
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-18 09:19:21
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-18 09:19:21
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-18 09:19:21
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-18 09:19:21
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-18 09:19:21
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-18 09:19:21
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-18 09:19:21
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-18 09:19:21
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-18 09:19:21
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-18 09:19:21
#>  21:   failed  10.000000  5.0000000         NA 2026-09-18 09:19:21
#>  22:   failed  10.000000  3.8888889         NA 2026-09-18 09:19:21
#>  23:   failed  10.000000  2.7777778         NA 2026-09-18 09:19:21
#>  24:   failed  10.000000  1.6666667         NA 2026-09-18 09:19:21
#>  25:   failed  10.000000  0.5555556         NA 2026-09-18 09:19:21
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-18 09:19:21
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-18 09:19:21
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-18 09:19:21
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-18 09:19:21
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-18 09:19:21
#>  31:   failed   7.777778  5.0000000         NA 2026-09-18 09:19:21
#>  32:   failed   7.777778  3.8888889         NA 2026-09-18 09:19:21
#>  33:   failed   7.777778  2.7777778         NA 2026-09-18 09:19:21
#>  34:   failed   7.777778  1.6666667         NA 2026-09-18 09:19:21
#>  35:   failed   7.777778  0.5555556         NA 2026-09-18 09:19:21
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-18 09:19:21
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-18 09:19:21
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-18 09:19:21
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-18 09:19:21
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-18 09:19:21
#>  41:   failed   5.555556  5.0000000         NA 2026-09-18 09:19:21
#>  42:   failed   5.555556  3.8888889         NA 2026-09-18 09:19:21
#>  43:   failed   5.555556  2.7777778         NA 2026-09-18 09:19:21
#>  44:   failed   5.555556  1.6666667         NA 2026-09-18 09:19:21
#>  45:   failed   5.555556  0.5555556         NA 2026-09-18 09:19:21
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-18 09:19:21
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-18 09:19:21
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-18 09:19:21
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-18 09:19:21
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-18 09:19:21
#>  51:   failed   3.333333  5.0000000         NA 2026-09-18 09:19:21
#>  52:   failed   3.333333  3.8888889         NA 2026-09-18 09:19:21
#>  53:   failed   3.333333  2.7777778         NA 2026-09-18 09:19:21
#>  54:   failed   3.333333  1.6666667         NA 2026-09-18 09:19:21
#>  55:   failed   3.333333  0.5555556         NA 2026-09-18 09:19:21
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-18 09:19:21
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-18 09:19:21
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-18 09:19:21
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-18 09:19:21
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-18 09:19:21
#>  61:   failed   1.111111  5.0000000         NA 2026-09-18 09:19:21
#>  62:   failed   1.111111  3.8888889         NA 2026-09-18 09:19:21
#>  63:   failed   1.111111  2.7777778         NA 2026-09-18 09:19:21
#>  64:   failed   1.111111  1.6666667         NA 2026-09-18 09:19:21
#>  65:   failed   1.111111  0.5555556         NA 2026-09-18 09:19:21
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-18 09:19:21
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-18 09:19:21
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-18 09:19:21
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-18 09:19:21
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-18 09:19:21
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-18 09:19:21
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-18 09:19:21
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-18 09:19:21
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-18 09:19:21
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-18 09:19:21
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-18 09:19:21
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-18 09:19:21
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-18 09:19:21
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-18 09:19:21
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-18 09:19:21
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-18 09:19:21
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-18 09:19:21
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-18 09:19:21
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-18 09:19:21
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-18 09:19:21
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-18 09:19:21
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-18 09:19:21
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-18 09:19:21
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-18 09:19:21
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-18 09:19:21
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-18 09:19:21
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-18 09:19:21
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-18 09:19:21
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-18 09:19:21
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-18 09:19:21
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-18 09:19:21
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-18 09:19:21
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-18 09:19:21
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-18 09:19:21
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-18 09:19:21
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>   2: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>   3: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>   4: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>   5: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>   6: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>   7: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>   8: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>   9: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>  10: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>  11: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>  12: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>  13: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>  14: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>  15: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>  16: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>  17: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>  18: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>  19: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
#>  20: sinking_raccoon_c37a0e1b 2026-09-18 09:19:22
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
#>   1: b01383ff-1c73-4201-aad3-31630c1b8c1f    [NULL]  -10.000000  -5.0000000
#>   2: 6cde7055-cb14-412c-8164-0a731c96e618    [NULL]  -10.000000  -3.8888889
#>   3: b728784c-f7d8-4c86-a88c-9b3261d73e8c    [NULL]  -10.000000  -2.7777778
#>   4: 1bf2e8b2-be16-48be-a7b8-7ae26974e7b8    [NULL]  -10.000000  -1.6666667
#>   5: 96ea4d14-0214-43fd-ab61-acf615e2c27c    [NULL]  -10.000000  -0.5555556
#>   6: c527b05a-74df-49d3-a4f7-6f11d1a7ec11    [NULL]  -10.000000   0.5555556
#>   7: 59fd6da1-784a-412b-a841-2bd07273dc68    [NULL]  -10.000000   1.6666667
#>   8: b9f7e12e-36fb-4c24-8139-84bf07ea6a3b    [NULL]  -10.000000   2.7777778
#>   9: 886dd32e-a420-428d-8586-70f0fc8583e7    [NULL]  -10.000000   3.8888889
#>  10: 9de296bb-1a99-4c51-a376-fd219d235dd9    [NULL]  -10.000000   5.0000000
#>  11: fe6bf510-e0d4-4316-99ca-3e597622d73f    [NULL]   -7.777778  -5.0000000
#>  12: ea9468cc-5ade-4d80-b4e9-3e7263cd19d4    [NULL]   -7.777778  -3.8888889
#>  13: f710278a-a39d-4328-b2f0-00be5caa8b4e    [NULL]   -7.777778  -2.7777778
#>  14: d387c6ca-ffdd-475c-8e67-df5ccb9c4f90    [NULL]   -7.777778  -1.6666667
#>  15: 294d7288-7557-49bf-afc0-813383169395    [NULL]   -7.777778  -0.5555556
#>  16: a57e8c6d-7a99-40b7-ad7b-6202aeaf7b24    [NULL]   -7.777778   0.5555556
#>  17: 3b171fb4-9864-40bc-aefb-840a393c299b    [NULL]   -7.777778   1.6666667
#>  18: b1069e9a-ce66-4a3a-8bc2-c67715e5c4fa    [NULL]   -7.777778   2.7777778
#>  19: 24c584f3-d292-455a-b8ca-f8acbb46b113    [NULL]   -7.777778   3.8888889
#>  20: 8f8aae56-0203-401e-8e5b-a7e3cdbbf042    [NULL]   -7.777778   5.0000000
#>  21: 92943993-b31a-4e7d-9533-bcf181cdc9e6 <list[1]>          NA          NA
#>  22: 93226eb6-06f3-415e-aabf-3cdb33213e60 <list[1]>          NA          NA
#>  23: 07a45ccb-a352-4a27-961e-dae22eb52dde <list[1]>          NA          NA
#>  24: 82a0c447-7523-46e1-a431-8e727eb38a07 <list[1]>          NA          NA
#>  25: 3c3c1b05-98ec-4309-a381-83e188862597 <list[1]>          NA          NA
#>  26: 43b9b3cf-33df-4bcd-ae29-1d66c6e9ce03 <list[1]>          NA          NA
#>  27: ab57f1e0-093b-41e9-8afb-94b3053d1546 <list[1]>          NA          NA
#>  28: 5e0344be-d7c9-4c10-8ba1-43d6301b6fcb <list[1]>          NA          NA
#>  29: a6addb69-7219-4bed-8936-6c2f27aab909 <list[1]>          NA          NA
#>  30: 4155cf52-792b-4206-b20b-ad4bbc7f89a1 <list[1]>          NA          NA
#>  31: cffe1945-f181-4d57-92fb-d26d7eb0defe <list[1]>          NA          NA
#>  32: 002daee4-261c-4512-afaa-4f44f3ffbbc2 <list[1]>          NA          NA
#>  33: 3ea84b19-8b34-4fcf-81d9-bf29c74d8459 <list[1]>          NA          NA
#>  34: 84497a34-99c5-4ebf-888e-c80c2325dde5 <list[1]>          NA          NA
#>  35: bd06e25d-61b1-49e9-8f71-0f60e59a4b11 <list[1]>          NA          NA
#>  36: 149aff25-e7d4-4096-9d5a-b0d28e9d688c <list[1]>          NA          NA
#>  37: 1c2c56f3-e892-4628-99c0-e788294f10ec <list[1]>          NA          NA
#>  38: 7dcfd702-9e96-4e18-ab87-6c6e50fe524b <list[1]>          NA          NA
#>  39: 2b7e5e1f-9702-4ec7-8609-0b0c9c7dd675 <list[1]>          NA          NA
#>  40: f5951a02-e6e3-42f6-b970-cd9ee2590870 <list[1]>          NA          NA
#>  41: fe46b269-0b9b-456b-9c0a-e95cd4c8bbcf <list[1]>          NA          NA
#>  42: fcfb1bec-f17a-4eac-a7ca-274b9e22a267 <list[1]>          NA          NA
#>  43: 97b1a858-2516-4e1f-bc7d-854b87c7cece <list[1]>          NA          NA
#>  44: f544a08e-17bd-4f3a-97b6-e8ed1e29f30c <list[1]>          NA          NA
#>  45: 47b53624-0f8f-4810-bbe0-45d0c6708435 <list[1]>          NA          NA
#>  46: 30f427bf-939c-4250-af03-a7d2749f4623 <list[1]>          NA          NA
#>  47: ebb1ecaf-19a3-48b4-8027-53f79367857e <list[1]>          NA          NA
#>  48: 637f9edb-90a6-4275-a3ad-8710a3d2ca68 <list[1]>          NA          NA
#>  49: 5ca428ba-bf68-4000-875e-a86df1ba855a <list[1]>          NA          NA
#>  50: 4f5d7927-fda6-4024-8ac9-8ddf1e6ed0bd <list[1]>          NA          NA
#>  51: 0520b703-dca6-47cb-82a8-602f1b4e0462 <list[1]>          NA          NA
#>  52: 80ad9f91-9750-4b18-ba57-da1d5e9ceaa9 <list[1]>          NA          NA
#>  53: a62507ad-73ba-48a6-a28c-76c0701403c7 <list[1]>          NA          NA
#>  54: 2c5e678e-836a-43a8-8cbd-eb2887e8c392 <list[1]>          NA          NA
#>  55: bab0e39f-2150-495b-a527-91839a83e744 <list[1]>          NA          NA
#>  56: 68789e58-b398-4ea3-b0dc-d00290cec20e <list[1]>          NA          NA
#>  57: 239eb26f-8b12-431a-a781-5482bad585f2 <list[1]>          NA          NA
#>  58: 23242689-eab1-4c91-b8b5-95a118a6a4f2 <list[1]>          NA          NA
#>  59: 13e2204c-ca59-4958-a037-792370b34306 <list[1]>          NA          NA
#>  60: e40a7e4f-42fc-4aa1-b1fc-305fe3be7866 <list[1]>          NA          NA
#>  61: 993b659d-73d2-4741-9a18-8baab1003655 <list[1]>          NA          NA
#>  62: 465977b1-cd6c-4349-816d-80b252c2b4c5 <list[1]>          NA          NA
#>  63: 73c1bfce-868d-4658-be3b-561e5a8bce11 <list[1]>          NA          NA
#>  64: 8972583a-6804-48b9-aefd-5aebf31a5a7a <list[1]>          NA          NA
#>  65: c7986088-4b34-42e3-b77b-f051a12a6fab <list[1]>          NA          NA
#>  66: 27b63b81-ce92-4ddc-b508-9f49f7fcb243 <list[1]>          NA          NA
#>  67: 292e76e9-fefd-4725-b5d4-6876b5315a23 <list[1]>          NA          NA
#>  68: daa538e7-32e2-4c64-933a-aa92d56de4a0 <list[1]>          NA          NA
#>  69: dbbedc99-d067-4700-beb6-4d220e22d430 <list[1]>          NA          NA
#>  70: 479338b4-b7d0-4105-92fe-de98a9d1878b <list[1]>          NA          NA
#>  71: 2553c39b-4ab9-451f-b8ae-397bfd214b72 <list[1]>          NA          NA
#>  72: fe6851ab-0249-4996-830a-3aef7441a44a <list[1]>          NA          NA
#>  73: bb218094-644a-46a9-9485-141af5599e85 <list[1]>          NA          NA
#>  74: cd470d1d-a40d-4a5d-99fb-e6be017bd9ef <list[1]>          NA          NA
#>  75: 15828035-d790-4faa-bca3-5d4039a80217 <list[1]>          NA          NA
#>  76: 93d61970-1c07-4b97-886a-340367f890a6 <list[1]>          NA          NA
#>  77: 47b25034-b345-49e0-a952-26ade7ad5f9d <list[1]>          NA          NA
#>  78: 86360866-19e2-48a3-afae-90d6ab5fd7c1 <list[1]>          NA          NA
#>  79: c30534f1-186b-442b-a894-bca8441f86cb <list[1]>          NA          NA
#>  80: 91729f1c-d34c-4475-ab0f-dc1cdb1bd185 <list[1]>          NA          NA
#>  81: 1b5decc7-072f-4e45-a48e-6edbaf827830 <list[1]>          NA          NA
#>  82: 1f6e61d2-2fe3-4ee8-aba5-1f903b1c2db9 <list[1]>          NA          NA
#>  83: 45854293-c25f-45dd-b94c-3f528f660765 <list[1]>          NA          NA
#>  84: 39ec3828-395e-4794-8fe4-198e9b78f5ee <list[1]>          NA          NA
#>  85: da4ae828-5f74-4182-bd0d-0fb948cef940 <list[1]>          NA          NA
#>  86: e9c4381e-cd76-49da-907d-685b67033d1b <list[1]>          NA          NA
#>  87: 104f4ddd-061d-48f8-aca6-ec92baec4a80 <list[1]>          NA          NA
#>  88: d120b54b-514d-4c10-ad51-38c24af740b5 <list[1]>          NA          NA
#>  89: a54bda44-1816-4664-8836-396cb0c414d6 <list[1]>          NA          NA
#>  90: b7ec91fe-c2c8-4b51-885c-8cd1b248295c <list[1]>          NA          NA
#>  91: c7f8feb9-9ed0-412f-9d9b-c4cb278af74d <list[1]>          NA          NA
#>  92: b7d514f9-bb47-4bee-ab18-93f1b8a51f81 <list[1]>          NA          NA
#>  93: 1fc6c7b4-5b2f-44ac-8052-a39b41390e53 <list[1]>          NA          NA
#>  94: 82ffa948-905a-492b-9cdc-2bf68b306780 <list[1]>          NA          NA
#>  95: 6c29384f-69b7-4565-9661-3fb67e778cda <list[1]>          NA          NA
#>  96: 3319ad01-7039-4699-b686-30aa641dc53b <list[1]>          NA          NA
#>  97: 9e9f42cc-7e4d-4796-a5a0-3f0a83988b15 <list[1]>          NA          NA
#>  98: 773ead91-6e57-4cc7-a27e-67079fe94fbe <list[1]>          NA          NA
#>  99: 9b7022e5-6535-4e94-8a84-8e8e19577a51 <list[1]>          NA          NA
#> 100: 42191015-2b2a-485b-a216-41d6d9e7e961 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
