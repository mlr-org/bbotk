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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-08-20 09:00:59
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-08-20 09:00:59
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-08-20 09:00:59
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-08-20 09:00:59
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-08-20 09:00:59
#>   6: finished -10.000000  0.5555556 -146.64198 2026-08-20 09:00:59
#>   7: finished -10.000000  1.6666667 -155.77778 2026-08-20 09:00:59
#>   8: finished -10.000000  2.7777778 -167.38272 2026-08-20 09:00:59
#>   9: finished -10.000000  3.8888889 -181.45679 2026-08-20 09:00:59
#>  10: finished -10.000000  5.0000000 -198.00000 2026-08-20 09:00:59
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-08-20 09:00:59
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-08-20 09:00:59
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-08-20 09:00:59
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-08-20 09:00:59
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-08-20 09:00:59
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-08-20 09:00:59
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-08-20 09:00:59
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-08-20 09:00:59
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-08-20 09:00:59
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-08-20 09:00:59
#>  21:   failed  10.000000  5.0000000         NA 2026-08-20 09:00:59
#>  22:   failed  10.000000  3.8888889         NA 2026-08-20 09:00:59
#>  23:   failed  10.000000  2.7777778         NA 2026-08-20 09:00:59
#>  24:   failed  10.000000  1.6666667         NA 2026-08-20 09:00:59
#>  25:   failed  10.000000  0.5555556         NA 2026-08-20 09:00:59
#>  26:   failed  10.000000 -0.5555556         NA 2026-08-20 09:00:59
#>  27:   failed  10.000000 -1.6666667         NA 2026-08-20 09:00:59
#>  28:   failed  10.000000 -2.7777778         NA 2026-08-20 09:00:59
#>  29:   failed  10.000000 -3.8888889         NA 2026-08-20 09:00:59
#>  30:   failed  10.000000 -5.0000000         NA 2026-08-20 09:00:59
#>  31:   failed   7.777778  5.0000000         NA 2026-08-20 09:00:59
#>  32:   failed   7.777778  3.8888889         NA 2026-08-20 09:00:59
#>  33:   failed   7.777778  2.7777778         NA 2026-08-20 09:00:59
#>  34:   failed   7.777778  1.6666667         NA 2026-08-20 09:00:59
#>  35:   failed   7.777778  0.5555556         NA 2026-08-20 09:00:59
#>  36:   failed   7.777778 -0.5555556         NA 2026-08-20 09:00:59
#>  37:   failed   7.777778 -1.6666667         NA 2026-08-20 09:00:59
#>  38:   failed   7.777778 -2.7777778         NA 2026-08-20 09:00:59
#>  39:   failed   7.777778 -3.8888889         NA 2026-08-20 09:00:59
#>  40:   failed   7.777778 -5.0000000         NA 2026-08-20 09:00:59
#>  41:   failed   5.555556  5.0000000         NA 2026-08-20 09:00:59
#>  42:   failed   5.555556  3.8888889         NA 2026-08-20 09:00:59
#>  43:   failed   5.555556  2.7777778         NA 2026-08-20 09:00:59
#>  44:   failed   5.555556  1.6666667         NA 2026-08-20 09:00:59
#>  45:   failed   5.555556  0.5555556         NA 2026-08-20 09:00:59
#>  46:   failed   5.555556 -0.5555556         NA 2026-08-20 09:00:59
#>  47:   failed   5.555556 -1.6666667         NA 2026-08-20 09:00:59
#>  48:   failed   5.555556 -2.7777778         NA 2026-08-20 09:00:59
#>  49:   failed   5.555556 -3.8888889         NA 2026-08-20 09:00:59
#>  50:   failed   5.555556 -5.0000000         NA 2026-08-20 09:00:59
#>  51:   failed   3.333333  5.0000000         NA 2026-08-20 09:00:59
#>  52:   failed   3.333333  3.8888889         NA 2026-08-20 09:00:59
#>  53:   failed   3.333333  2.7777778         NA 2026-08-20 09:00:59
#>  54:   failed   3.333333  1.6666667         NA 2026-08-20 09:00:59
#>  55:   failed   3.333333  0.5555556         NA 2026-08-20 09:00:59
#>  56:   failed   3.333333 -0.5555556         NA 2026-08-20 09:00:59
#>  57:   failed   3.333333 -1.6666667         NA 2026-08-20 09:00:59
#>  58:   failed   3.333333 -2.7777778         NA 2026-08-20 09:00:59
#>  59:   failed   3.333333 -3.8888889         NA 2026-08-20 09:00:59
#>  60:   failed   3.333333 -5.0000000         NA 2026-08-20 09:00:59
#>  61:   failed   1.111111  5.0000000         NA 2026-08-20 09:00:59
#>  62:   failed   1.111111  3.8888889         NA 2026-08-20 09:00:59
#>  63:   failed   1.111111  2.7777778         NA 2026-08-20 09:00:59
#>  64:   failed   1.111111  1.6666667         NA 2026-08-20 09:00:59
#>  65:   failed   1.111111  0.5555556         NA 2026-08-20 09:00:59
#>  66:   failed   1.111111 -0.5555556         NA 2026-08-20 09:00:59
#>  67:   failed   1.111111 -1.6666667         NA 2026-08-20 09:00:59
#>  68:   failed   1.111111 -2.7777778         NA 2026-08-20 09:00:59
#>  69:   failed   1.111111 -3.8888889         NA 2026-08-20 09:00:59
#>  70:   failed   1.111111 -5.0000000         NA 2026-08-20 09:00:59
#>  71:   failed  -1.111111  5.0000000         NA 2026-08-20 09:00:59
#>  72:   failed  -1.111111  3.8888889         NA 2026-08-20 09:00:59
#>  73:   failed  -1.111111  2.7777778         NA 2026-08-20 09:00:59
#>  74:   failed  -1.111111  1.6666667         NA 2026-08-20 09:00:59
#>  75:   failed  -1.111111  0.5555556         NA 2026-08-20 09:00:59
#>  76:   failed  -1.111111 -0.5555556         NA 2026-08-20 09:00:59
#>  77:   failed  -1.111111 -1.6666667         NA 2026-08-20 09:00:59
#>  78:   failed  -1.111111 -2.7777778         NA 2026-08-20 09:00:59
#>  79:   failed  -1.111111 -3.8888889         NA 2026-08-20 09:00:59
#>  80:   failed  -1.111111 -5.0000000         NA 2026-08-20 09:00:59
#>  81:   failed  -3.333333  5.0000000         NA 2026-08-20 09:00:59
#>  82:   failed  -3.333333  3.8888889         NA 2026-08-20 09:00:59
#>  83:   failed  -3.333333  2.7777778         NA 2026-08-20 09:00:59
#>  84:   failed  -3.333333  1.6666667         NA 2026-08-20 09:00:59
#>  85:   failed  -3.333333  0.5555556         NA 2026-08-20 09:00:59
#>  86:   failed  -3.333333 -0.5555556         NA 2026-08-20 09:00:59
#>  87:   failed  -3.333333 -1.6666667         NA 2026-08-20 09:00:59
#>  88:   failed  -3.333333 -2.7777778         NA 2026-08-20 09:00:59
#>  89:   failed  -3.333333 -3.8888889         NA 2026-08-20 09:00:59
#>  90:   failed  -3.333333 -5.0000000         NA 2026-08-20 09:00:59
#>  91:   failed  -5.555556  5.0000000         NA 2026-08-20 09:00:59
#>  92:   failed  -5.555556  3.8888889         NA 2026-08-20 09:00:59
#>  93:   failed  -5.555556  2.7777778         NA 2026-08-20 09:00:59
#>  94:   failed  -5.555556  1.6666667         NA 2026-08-20 09:00:59
#>  95:   failed  -5.555556  0.5555556         NA 2026-08-20 09:00:59
#>  96:   failed  -5.555556 -0.5555556         NA 2026-08-20 09:00:59
#>  97:   failed  -5.555556 -1.6666667         NA 2026-08-20 09:00:59
#>  98:   failed  -5.555556 -2.7777778         NA 2026-08-20 09:00:59
#>  99:   failed  -5.555556 -3.8888889         NA 2026-08-20 09:00:59
#> 100:   failed  -5.555556 -5.0000000         NA 2026-08-20 09:00:59
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>   2: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>   3: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>   4: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>   5: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>   6: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>   7: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>   8: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>   9: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>  10: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>  11: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>  12: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>  13: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>  14: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>  15: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>  16: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>  17: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>  18: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>  19: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
#>  20: sinking_raccoon_3aec7f64 2026-08-20 09:01:00
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
#>   1: 8e79e2ae-3797-4de8-a2b5-a12e70459d57    [NULL]  -10.000000  -5.0000000
#>   2: 8742c381-7970-4850-b097-7411697077a0    [NULL]  -10.000000  -3.8888889
#>   3: c804ab12-ce40-4fbb-ae65-01de02429f43    [NULL]  -10.000000  -2.7777778
#>   4: eae49a24-8d8a-41f0-abfd-6e5e40f68f1b    [NULL]  -10.000000  -1.6666667
#>   5: de0b210f-84e1-472b-9774-4a10239479d7    [NULL]  -10.000000  -0.5555556
#>   6: b6b7229b-c1be-47ff-bf21-823922cec7c2    [NULL]  -10.000000   0.5555556
#>   7: 681913c1-4805-4a8e-a6fd-b282da37da37    [NULL]  -10.000000   1.6666667
#>   8: 86d9bb4a-8c00-4eeb-86ad-4be14fb667e7    [NULL]  -10.000000   2.7777778
#>   9: 860d5185-07c6-4c6d-b091-8da6237f0e14    [NULL]  -10.000000   3.8888889
#>  10: 5627f37e-6e9f-4522-99d1-932fc7b924fa    [NULL]  -10.000000   5.0000000
#>  11: cd00d712-6415-4166-8d77-e5789c3e5ea7    [NULL]   -7.777778  -5.0000000
#>  12: 43b16c27-7096-487f-be32-1a37ff338fef    [NULL]   -7.777778  -3.8888889
#>  13: 3db4d73b-9132-41a8-bc63-f5bf22083862    [NULL]   -7.777778  -2.7777778
#>  14: 36a27aef-15bb-4a72-9c3e-21f525877bdb    [NULL]   -7.777778  -1.6666667
#>  15: 3cf408d1-3548-4c82-95b5-ac84d5fe3431    [NULL]   -7.777778  -0.5555556
#>  16: 497aa53d-cb5e-4155-b5e5-4e0595e964eb    [NULL]   -7.777778   0.5555556
#>  17: 844cad02-b748-4431-9887-9f4bf624cbb0    [NULL]   -7.777778   1.6666667
#>  18: 474f306a-4c42-4b3c-b5da-7800c3bca1f6    [NULL]   -7.777778   2.7777778
#>  19: ccd65001-339a-402a-b209-23f8343ce1d1    [NULL]   -7.777778   3.8888889
#>  20: affc2b39-dbdc-4167-bd1b-aed4badc0bbe    [NULL]   -7.777778   5.0000000
#>  21: 99ebfbff-5231-4356-bd2f-bc9e8d09b0a3 <list[1]>          NA          NA
#>  22: 8fae6063-dbd5-43ec-bef6-928c62f0891d <list[1]>          NA          NA
#>  23: 2085d142-ad47-4a83-b21e-70ba40ef62d8 <list[1]>          NA          NA
#>  24: 07c912af-79ab-4533-867a-e4c7d89bbdb3 <list[1]>          NA          NA
#>  25: b8d9c5c3-92c1-4fcc-8b1f-5ff859326932 <list[1]>          NA          NA
#>  26: 4bec9340-63c5-49cc-a43e-4598dd959147 <list[1]>          NA          NA
#>  27: 78128392-23f1-4563-a091-bf06eb7bac52 <list[1]>          NA          NA
#>  28: cd295ed0-77e5-4691-92d6-48f603c78360 <list[1]>          NA          NA
#>  29: c3b91c17-b202-4feb-91eb-1aec2c0ebe58 <list[1]>          NA          NA
#>  30: 6f94b873-2b02-4d3a-80d1-341c0c517b33 <list[1]>          NA          NA
#>  31: 28b61b85-1e76-4191-851f-d27d10e566ee <list[1]>          NA          NA
#>  32: 604b0291-e4c3-4f1f-a40e-8d229b9c2df1 <list[1]>          NA          NA
#>  33: 00a8e36b-95a2-45bc-89f1-0218ab3767b0 <list[1]>          NA          NA
#>  34: b3e84a2b-7116-4345-890f-75f87ccd9aff <list[1]>          NA          NA
#>  35: 58604f05-df0d-4e57-80cd-2234662e47a0 <list[1]>          NA          NA
#>  36: 2413cc7d-c7a6-4263-a091-f3656524a628 <list[1]>          NA          NA
#>  37: 167116f8-e757-459e-adaf-43de7c73fc6f <list[1]>          NA          NA
#>  38: 46c30016-24f3-4328-960c-814bb3ce0d44 <list[1]>          NA          NA
#>  39: 0fa82eef-5a4b-40a6-85de-c588d3c88c00 <list[1]>          NA          NA
#>  40: a636f883-342a-4873-b4b5-9bdee3e086b2 <list[1]>          NA          NA
#>  41: cfd122a8-a03f-4816-98fc-3c6e057d6ba9 <list[1]>          NA          NA
#>  42: 5644e934-a8d9-4cdb-8b0a-ed1aa0ab634e <list[1]>          NA          NA
#>  43: 45406716-88dc-4679-b9cc-ed2535e4b6b4 <list[1]>          NA          NA
#>  44: 4abdd048-c3bf-4c7f-a99e-1441abee34bf <list[1]>          NA          NA
#>  45: 4b11a9a9-d6ed-4792-add3-7418e8eaa415 <list[1]>          NA          NA
#>  46: 5cdc7967-ad85-425c-9aad-e483f186f3f8 <list[1]>          NA          NA
#>  47: ce7f2c49-e491-4edf-9748-28ba0da261c4 <list[1]>          NA          NA
#>  48: 48e3a97a-b2d6-4285-819e-1dc76987c932 <list[1]>          NA          NA
#>  49: cd08b335-2614-4e1a-a4d7-533d7259b83d <list[1]>          NA          NA
#>  50: 2611c23d-4199-4635-abb2-4871143d929c <list[1]>          NA          NA
#>  51: 9782fad8-2b51-4342-b7cd-664f948ac330 <list[1]>          NA          NA
#>  52: f2cae9a8-710c-4952-a044-98216629fdf3 <list[1]>          NA          NA
#>  53: add40064-a697-492b-a0ec-3e6adaefadc1 <list[1]>          NA          NA
#>  54: fb4b4303-e6e9-4139-a216-a52823ccdae8 <list[1]>          NA          NA
#>  55: 358190de-9a46-40be-bc9e-eccf97e00be3 <list[1]>          NA          NA
#>  56: 5dfee71b-9a23-427b-8e53-4cdec64f9769 <list[1]>          NA          NA
#>  57: 4f14ded6-2f7e-4c8b-a85e-7958364eae77 <list[1]>          NA          NA
#>  58: e2467b35-31b8-4df7-b6e3-dc41f948efd8 <list[1]>          NA          NA
#>  59: e320fe8c-0682-4e05-b1b4-0c7e8e1ab32c <list[1]>          NA          NA
#>  60: 49a5b2ba-7214-47a2-829a-183694464991 <list[1]>          NA          NA
#>  61: 54540fe2-3e6c-4ad9-83c2-0c9463b4c844 <list[1]>          NA          NA
#>  62: 062a388e-38d9-4e1c-b908-ae5d66cd1d69 <list[1]>          NA          NA
#>  63: 76d5ae75-fc42-4ba3-991c-014c09f74b92 <list[1]>          NA          NA
#>  64: 4e4647dc-702c-47d1-a678-4903956410c7 <list[1]>          NA          NA
#>  65: 169b6834-fb33-4d76-8ca0-529cfd7a76ba <list[1]>          NA          NA
#>  66: 753e5769-1e69-4f8f-9144-c0ca139198d5 <list[1]>          NA          NA
#>  67: 4bebf61c-b9ac-441a-8319-7f6f2c67f2f4 <list[1]>          NA          NA
#>  68: d902f397-2d3b-4a43-ae9a-0faae4507b33 <list[1]>          NA          NA
#>  69: 6c4e87d7-6ad5-4c56-a299-93c8a486c21c <list[1]>          NA          NA
#>  70: 2ba1f2d2-edf4-4362-8e33-7f698e460347 <list[1]>          NA          NA
#>  71: 4486591b-2e67-46a1-bc2b-cd9dcfddb00a <list[1]>          NA          NA
#>  72: 85eea757-9917-43cd-a8a9-c6d8dacc62a6 <list[1]>          NA          NA
#>  73: 6601ca29-75f3-4b6b-814c-ce98e6807e4c <list[1]>          NA          NA
#>  74: d75c8827-4dd2-4780-ba04-b242e06bb069 <list[1]>          NA          NA
#>  75: f3ac1a81-387f-49eb-8a8b-fa0c05453cec <list[1]>          NA          NA
#>  76: de8d47c6-f866-40d7-9ad4-c6bc0335e68e <list[1]>          NA          NA
#>  77: 2fc7ab2e-c948-48fd-9a8f-a3363ff61a79 <list[1]>          NA          NA
#>  78: 11e99fad-bd3a-4c83-8f9a-6dd7fb2d4057 <list[1]>          NA          NA
#>  79: 91d88fce-5241-494c-a515-5a549db24838 <list[1]>          NA          NA
#>  80: 42a20f45-573b-45a6-95d3-532bf39b1708 <list[1]>          NA          NA
#>  81: 29e85799-1fb2-45b6-a985-c364dffb304d <list[1]>          NA          NA
#>  82: 5de5b3de-a670-4376-9262-fbb73ce54ac9 <list[1]>          NA          NA
#>  83: 4a6abdbb-39fe-4720-8b2a-b5e6e8a787f0 <list[1]>          NA          NA
#>  84: 7e4c7617-2b7d-4e58-b43c-d0bf053d11c3 <list[1]>          NA          NA
#>  85: 298f41df-80f9-4db4-8cb3-4f63ac37b4a8 <list[1]>          NA          NA
#>  86: 6d3ae753-a001-46a5-9a64-e2406238f6e8 <list[1]>          NA          NA
#>  87: a9591974-52a5-44fa-b121-66601c1005f0 <list[1]>          NA          NA
#>  88: 5f3a8602-94af-4d14-b03e-9241d68b37fb <list[1]>          NA          NA
#>  89: e6a2d1c2-c597-4523-af64-1e5e0f223d04 <list[1]>          NA          NA
#>  90: 55feffbf-c8af-4f46-ab0a-85ffd9d7ae2a <list[1]>          NA          NA
#>  91: 7f082b10-2aaf-43ea-b6b4-93e53830e5bf <list[1]>          NA          NA
#>  92: 2d1b8d14-5477-46ba-a185-aa94ca807d28 <list[1]>          NA          NA
#>  93: 3b0e15f2-2894-4284-b575-b76bc1446aa9 <list[1]>          NA          NA
#>  94: 6a085482-0634-456a-83a7-f6cc5ce34f7a <list[1]>          NA          NA
#>  95: d49d4c85-7c3b-456f-9b2f-cd9985e1dd06 <list[1]>          NA          NA
#>  96: 2250d5c0-3f6e-4f9c-9678-2c79777a4e6a <list[1]>          NA          NA
#>  97: 1c7fc0d2-fce0-47ca-acaa-d0ff8c32126f <list[1]>          NA          NA
#>  98: f30ec48c-b8f3-4ef2-af5a-b06dc686cda7 <list[1]>          NA          NA
#>  99: 4fa1662c-e84f-4dec-8dec-9fa0c9381617 <list[1]>          NA          NA
#> 100: d00db4c0-55c0-44f9-9c68-a61e09331fea <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
