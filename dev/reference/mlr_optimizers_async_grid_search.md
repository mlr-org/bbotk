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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-08-20 10:53:16
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-08-20 10:53:16
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-08-20 10:53:16
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-08-20 10:53:16
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-08-20 10:53:16
#>   6: finished -10.000000  0.5555556 -146.64198 2026-08-20 10:53:16
#>   7: finished -10.000000  1.6666667 -155.77778 2026-08-20 10:53:16
#>   8: finished -10.000000  2.7777778 -167.38272 2026-08-20 10:53:16
#>   9: finished -10.000000  3.8888889 -181.45679 2026-08-20 10:53:16
#>  10: finished -10.000000  5.0000000 -198.00000 2026-08-20 10:53:16
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-08-20 10:53:16
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-08-20 10:53:16
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-08-20 10:53:16
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-08-20 10:53:16
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-08-20 10:53:16
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-08-20 10:53:16
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-08-20 10:53:16
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-08-20 10:53:16
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-08-20 10:53:16
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-08-20 10:53:16
#>  21:   failed  10.000000  5.0000000         NA 2026-08-20 10:53:16
#>  22:   failed  10.000000  3.8888889         NA 2026-08-20 10:53:16
#>  23:   failed  10.000000  2.7777778         NA 2026-08-20 10:53:16
#>  24:   failed  10.000000  1.6666667         NA 2026-08-20 10:53:16
#>  25:   failed  10.000000  0.5555556         NA 2026-08-20 10:53:16
#>  26:   failed  10.000000 -0.5555556         NA 2026-08-20 10:53:16
#>  27:   failed  10.000000 -1.6666667         NA 2026-08-20 10:53:16
#>  28:   failed  10.000000 -2.7777778         NA 2026-08-20 10:53:16
#>  29:   failed  10.000000 -3.8888889         NA 2026-08-20 10:53:16
#>  30:   failed  10.000000 -5.0000000         NA 2026-08-20 10:53:16
#>  31:   failed   7.777778  5.0000000         NA 2026-08-20 10:53:16
#>  32:   failed   7.777778  3.8888889         NA 2026-08-20 10:53:16
#>  33:   failed   7.777778  2.7777778         NA 2026-08-20 10:53:16
#>  34:   failed   7.777778  1.6666667         NA 2026-08-20 10:53:16
#>  35:   failed   7.777778  0.5555556         NA 2026-08-20 10:53:16
#>  36:   failed   7.777778 -0.5555556         NA 2026-08-20 10:53:16
#>  37:   failed   7.777778 -1.6666667         NA 2026-08-20 10:53:16
#>  38:   failed   7.777778 -2.7777778         NA 2026-08-20 10:53:16
#>  39:   failed   7.777778 -3.8888889         NA 2026-08-20 10:53:16
#>  40:   failed   7.777778 -5.0000000         NA 2026-08-20 10:53:16
#>  41:   failed   5.555556  5.0000000         NA 2026-08-20 10:53:16
#>  42:   failed   5.555556  3.8888889         NA 2026-08-20 10:53:16
#>  43:   failed   5.555556  2.7777778         NA 2026-08-20 10:53:16
#>  44:   failed   5.555556  1.6666667         NA 2026-08-20 10:53:16
#>  45:   failed   5.555556  0.5555556         NA 2026-08-20 10:53:16
#>  46:   failed   5.555556 -0.5555556         NA 2026-08-20 10:53:16
#>  47:   failed   5.555556 -1.6666667         NA 2026-08-20 10:53:16
#>  48:   failed   5.555556 -2.7777778         NA 2026-08-20 10:53:16
#>  49:   failed   5.555556 -3.8888889         NA 2026-08-20 10:53:16
#>  50:   failed   5.555556 -5.0000000         NA 2026-08-20 10:53:16
#>  51:   failed   3.333333  5.0000000         NA 2026-08-20 10:53:16
#>  52:   failed   3.333333  3.8888889         NA 2026-08-20 10:53:16
#>  53:   failed   3.333333  2.7777778         NA 2026-08-20 10:53:16
#>  54:   failed   3.333333  1.6666667         NA 2026-08-20 10:53:16
#>  55:   failed   3.333333  0.5555556         NA 2026-08-20 10:53:16
#>  56:   failed   3.333333 -0.5555556         NA 2026-08-20 10:53:16
#>  57:   failed   3.333333 -1.6666667         NA 2026-08-20 10:53:16
#>  58:   failed   3.333333 -2.7777778         NA 2026-08-20 10:53:16
#>  59:   failed   3.333333 -3.8888889         NA 2026-08-20 10:53:16
#>  60:   failed   3.333333 -5.0000000         NA 2026-08-20 10:53:16
#>  61:   failed   1.111111  5.0000000         NA 2026-08-20 10:53:16
#>  62:   failed   1.111111  3.8888889         NA 2026-08-20 10:53:16
#>  63:   failed   1.111111  2.7777778         NA 2026-08-20 10:53:16
#>  64:   failed   1.111111  1.6666667         NA 2026-08-20 10:53:16
#>  65:   failed   1.111111  0.5555556         NA 2026-08-20 10:53:16
#>  66:   failed   1.111111 -0.5555556         NA 2026-08-20 10:53:16
#>  67:   failed   1.111111 -1.6666667         NA 2026-08-20 10:53:16
#>  68:   failed   1.111111 -2.7777778         NA 2026-08-20 10:53:16
#>  69:   failed   1.111111 -3.8888889         NA 2026-08-20 10:53:16
#>  70:   failed   1.111111 -5.0000000         NA 2026-08-20 10:53:16
#>  71:   failed  -1.111111  5.0000000         NA 2026-08-20 10:53:16
#>  72:   failed  -1.111111  3.8888889         NA 2026-08-20 10:53:16
#>  73:   failed  -1.111111  2.7777778         NA 2026-08-20 10:53:16
#>  74:   failed  -1.111111  1.6666667         NA 2026-08-20 10:53:16
#>  75:   failed  -1.111111  0.5555556         NA 2026-08-20 10:53:16
#>  76:   failed  -1.111111 -0.5555556         NA 2026-08-20 10:53:16
#>  77:   failed  -1.111111 -1.6666667         NA 2026-08-20 10:53:16
#>  78:   failed  -1.111111 -2.7777778         NA 2026-08-20 10:53:16
#>  79:   failed  -1.111111 -3.8888889         NA 2026-08-20 10:53:16
#>  80:   failed  -1.111111 -5.0000000         NA 2026-08-20 10:53:16
#>  81:   failed  -3.333333  5.0000000         NA 2026-08-20 10:53:16
#>  82:   failed  -3.333333  3.8888889         NA 2026-08-20 10:53:16
#>  83:   failed  -3.333333  2.7777778         NA 2026-08-20 10:53:16
#>  84:   failed  -3.333333  1.6666667         NA 2026-08-20 10:53:16
#>  85:   failed  -3.333333  0.5555556         NA 2026-08-20 10:53:16
#>  86:   failed  -3.333333 -0.5555556         NA 2026-08-20 10:53:16
#>  87:   failed  -3.333333 -1.6666667         NA 2026-08-20 10:53:16
#>  88:   failed  -3.333333 -2.7777778         NA 2026-08-20 10:53:16
#>  89:   failed  -3.333333 -3.8888889         NA 2026-08-20 10:53:16
#>  90:   failed  -3.333333 -5.0000000         NA 2026-08-20 10:53:16
#>  91:   failed  -5.555556  5.0000000         NA 2026-08-20 10:53:16
#>  92:   failed  -5.555556  3.8888889         NA 2026-08-20 10:53:16
#>  93:   failed  -5.555556  2.7777778         NA 2026-08-20 10:53:16
#>  94:   failed  -5.555556  1.6666667         NA 2026-08-20 10:53:16
#>  95:   failed  -5.555556  0.5555556         NA 2026-08-20 10:53:16
#>  96:   failed  -5.555556 -0.5555556         NA 2026-08-20 10:53:16
#>  97:   failed  -5.555556 -1.6666667         NA 2026-08-20 10:53:16
#>  98:   failed  -5.555556 -2.7777778         NA 2026-08-20 10:53:16
#>  99:   failed  -5.555556 -3.8888889         NA 2026-08-20 10:53:16
#> 100:   failed  -5.555556 -5.0000000         NA 2026-08-20 10:53:16
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>   2: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>   3: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>   4: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>   5: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>   6: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>   7: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>   8: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>   9: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>  10: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>  11: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>  12: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>  13: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>  14: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>  15: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>  16: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>  17: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>  18: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>  19: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
#>  20: sinking_raccoon_3409dbdc 2026-08-20 10:53:17
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
#>   1: db9e78c8-94e4-4098-9f65-c8702b7d874c    [NULL]  -10.000000  -5.0000000
#>   2: 1edf6a2c-ee81-4437-be28-bb4467a43961    [NULL]  -10.000000  -3.8888889
#>   3: 152b6855-186d-4d6c-b257-c7cc77fb6e4e    [NULL]  -10.000000  -2.7777778
#>   4: 7181e36a-154c-4770-a126-258784c8cb14    [NULL]  -10.000000  -1.6666667
#>   5: 0d822859-4f18-4f18-806f-201eaac34bf8    [NULL]  -10.000000  -0.5555556
#>   6: c0d36eee-9e48-48e1-9b20-a27563fcfcaa    [NULL]  -10.000000   0.5555556
#>   7: c6361fe0-6668-4b53-9098-af34ef71ee31    [NULL]  -10.000000   1.6666667
#>   8: 899d37d6-8033-4161-8abe-495eeb924c65    [NULL]  -10.000000   2.7777778
#>   9: e0718264-4d3b-4d6e-bb0a-8a5c5d040265    [NULL]  -10.000000   3.8888889
#>  10: 06d73546-f886-419b-960a-9476a975f491    [NULL]  -10.000000   5.0000000
#>  11: 350c5137-43c0-4733-8cb7-6748db0a89da    [NULL]   -7.777778  -5.0000000
#>  12: b18186c9-2d4e-4d60-9ce1-bfe10adc1b17    [NULL]   -7.777778  -3.8888889
#>  13: c1c42d72-9d9e-4ac1-969e-130abb8a6e51    [NULL]   -7.777778  -2.7777778
#>  14: 5490bb85-6456-4b19-ac0e-0b64bb23c5ca    [NULL]   -7.777778  -1.6666667
#>  15: dba0be05-a7e7-4601-b2fb-5ae211783a27    [NULL]   -7.777778  -0.5555556
#>  16: 01631bd7-e072-482f-8413-b0a4b5019935    [NULL]   -7.777778   0.5555556
#>  17: 9013cdd8-07e6-42e6-aaf1-b1189fc907ec    [NULL]   -7.777778   1.6666667
#>  18: 8787ded4-c39d-402e-8605-ed12a6ff7a01    [NULL]   -7.777778   2.7777778
#>  19: 95d3fb67-d962-47da-822a-b27ab3ec24c3    [NULL]   -7.777778   3.8888889
#>  20: 1834a9af-f2b5-40e4-becd-b72f4ca15220    [NULL]   -7.777778   5.0000000
#>  21: 99170b7b-a54e-4b1a-a1a7-17542adbbf94 <list[1]>          NA          NA
#>  22: a5c98358-08dc-4a27-b3ac-df487a2b1d43 <list[1]>          NA          NA
#>  23: f0d5b8f5-1a05-4b90-8f8b-7bb97a8cd11d <list[1]>          NA          NA
#>  24: 8d59b355-7c18-4026-826b-8acd052d6eee <list[1]>          NA          NA
#>  25: 7c194527-6a9f-4ecc-b8c4-fe47b6ffc590 <list[1]>          NA          NA
#>  26: e16f8d4d-3034-4f05-b0f6-4024738313ad <list[1]>          NA          NA
#>  27: d2becd61-c20d-47d9-9d11-3c9a61427f6d <list[1]>          NA          NA
#>  28: 4fee215b-b729-474d-a96b-26b7a817235e <list[1]>          NA          NA
#>  29: 2c415016-6792-4a08-9d93-4e9bbf4e8437 <list[1]>          NA          NA
#>  30: 1475659f-9516-49ee-adbc-2338d757ca17 <list[1]>          NA          NA
#>  31: d98b8687-fbe8-462c-bd96-70697f8d2674 <list[1]>          NA          NA
#>  32: 82da7f0c-7513-4ea3-8b69-8c12bcdc1ac8 <list[1]>          NA          NA
#>  33: 4dde418a-924c-4fe0-8607-2e434ba0cb33 <list[1]>          NA          NA
#>  34: a4b57f4c-0887-47a8-a3c0-d598be64e965 <list[1]>          NA          NA
#>  35: 5b07f47e-3534-44bb-8ece-f1c9755be84f <list[1]>          NA          NA
#>  36: c8ae8675-939c-40c6-a952-382bbaffe6fc <list[1]>          NA          NA
#>  37: a1bb1b3a-93f0-4fcd-b940-a8a66234add7 <list[1]>          NA          NA
#>  38: a1d36fc1-8a3f-4f64-9753-4c0906b35410 <list[1]>          NA          NA
#>  39: bed65df2-7b52-435a-9f3e-6950234c83a0 <list[1]>          NA          NA
#>  40: b6f1dbd3-b852-47c7-85e5-2c8d4b30e50a <list[1]>          NA          NA
#>  41: fe428957-bbda-4dc5-a8d0-a5643363f9db <list[1]>          NA          NA
#>  42: d193c869-f24a-4fbb-8631-e9e0fe4d9ddd <list[1]>          NA          NA
#>  43: f64d48bb-9b94-40f6-9993-866004ce77f7 <list[1]>          NA          NA
#>  44: d6af71b0-7fe3-4cd6-8782-1947353489c2 <list[1]>          NA          NA
#>  45: 00caf4cc-dbf2-4a33-abd2-ca44e4b36247 <list[1]>          NA          NA
#>  46: 890c912a-a91c-45b5-b20f-f3d83efb4ad6 <list[1]>          NA          NA
#>  47: 95888766-9fa1-446c-8700-813ed7ea0d72 <list[1]>          NA          NA
#>  48: 1714d04c-5039-4c82-b655-00726a8fe545 <list[1]>          NA          NA
#>  49: fcf14cbf-809b-47aa-8e5d-c320ec5341cd <list[1]>          NA          NA
#>  50: bf71c73c-1afb-4729-8977-6fc799a0e1c8 <list[1]>          NA          NA
#>  51: e1cf432c-a908-40e4-adf7-93496ea20aa6 <list[1]>          NA          NA
#>  52: 17bdc884-94f8-48ca-bc64-c7f7546fce2c <list[1]>          NA          NA
#>  53: b2d039e4-f536-45f3-a54b-5e4fd174ee08 <list[1]>          NA          NA
#>  54: f0044734-c219-4811-b51f-50d7732a376b <list[1]>          NA          NA
#>  55: f29b814f-1232-4dad-add3-1838da1727e8 <list[1]>          NA          NA
#>  56: 47cacc44-d154-468f-a8de-12fe3fb5bc25 <list[1]>          NA          NA
#>  57: b3b25e92-43cb-4db1-a5ad-cf4876fc31bc <list[1]>          NA          NA
#>  58: 5aeb28bd-cd6e-487a-acaa-ac4047521740 <list[1]>          NA          NA
#>  59: 3a076f00-8921-41fa-990f-b2d6d634b794 <list[1]>          NA          NA
#>  60: a7e0a2f3-9cf1-4e59-b94e-37d80d0cff15 <list[1]>          NA          NA
#>  61: bc71a8ec-18c1-4ae2-8a84-d8c6ec3717d7 <list[1]>          NA          NA
#>  62: d4c6c194-3af9-44b2-a2b6-7f48d251d473 <list[1]>          NA          NA
#>  63: b8795210-36a3-4ab3-b7d0-518e29ad3098 <list[1]>          NA          NA
#>  64: 3886a96a-95f9-4711-9c91-2b3b1a4fcb24 <list[1]>          NA          NA
#>  65: 66bb54db-9110-4baf-9ecb-c34534005fb3 <list[1]>          NA          NA
#>  66: c913b668-d12a-4a62-9ee2-bdf869b14365 <list[1]>          NA          NA
#>  67: 103c181f-5b8f-4777-a816-b2cdb609aad9 <list[1]>          NA          NA
#>  68: e3193a08-91e6-446a-9e4b-2cbab1acbb46 <list[1]>          NA          NA
#>  69: 9bca8bb7-e9c2-42ec-a999-69342ea41866 <list[1]>          NA          NA
#>  70: 1b38c71f-4f8b-4a7e-a035-82707e686e62 <list[1]>          NA          NA
#>  71: 11360f5f-e8b2-46f0-b077-424fc9b9dd37 <list[1]>          NA          NA
#>  72: cdc5e06c-e46c-42f2-85f8-82b601efe3ad <list[1]>          NA          NA
#>  73: 158caff7-4c55-40c0-b428-2466ebe4e5e3 <list[1]>          NA          NA
#>  74: ba55d717-53a3-4a06-b810-a8fa9414f5af <list[1]>          NA          NA
#>  75: 82cd2b11-69f2-4d3e-b8ed-d7e4940a3568 <list[1]>          NA          NA
#>  76: 60d14934-34ca-4635-8aad-b82cf3265cae <list[1]>          NA          NA
#>  77: 1e9d4628-623e-430a-86ba-d83425e77f6b <list[1]>          NA          NA
#>  78: 2a2265f7-2a93-48af-a1bf-440b0dbc3a90 <list[1]>          NA          NA
#>  79: 5f7b4a32-a72b-4430-803a-d9c6421d062d <list[1]>          NA          NA
#>  80: c4a7d27c-8754-4c8f-a916-080395a7051d <list[1]>          NA          NA
#>  81: 454b0536-3cc8-4dfc-aa50-bed9feb556b4 <list[1]>          NA          NA
#>  82: 5102f0c5-673e-43fa-9862-8c27a18bb6e9 <list[1]>          NA          NA
#>  83: cd7b0f21-9d6f-4646-a29e-fbcc944bbea0 <list[1]>          NA          NA
#>  84: 0358eda8-cf2d-47ec-ba75-485ef20d528a <list[1]>          NA          NA
#>  85: ae259120-f278-46b1-a08a-9c6c12d1d0ea <list[1]>          NA          NA
#>  86: c979b2cb-437c-4649-8b2d-e9461d1802d9 <list[1]>          NA          NA
#>  87: b6bc7dfe-06bd-4da5-bf0a-b30a6b0868ad <list[1]>          NA          NA
#>  88: c5f3f6c0-e256-4181-b27e-179d1321d1a4 <list[1]>          NA          NA
#>  89: 4b362de9-41da-4334-8f70-789b3340fcd2 <list[1]>          NA          NA
#>  90: ef383863-c7d7-430c-a357-9871fcaeff19 <list[1]>          NA          NA
#>  91: 6096dac3-bec4-4c75-a499-a1b77e8d01d4 <list[1]>          NA          NA
#>  92: 859f1a41-b7c3-4cec-836c-b393ed2ecd6c <list[1]>          NA          NA
#>  93: 7c39c6af-dd1f-48a0-b0ad-5036fa36b126 <list[1]>          NA          NA
#>  94: 85097210-ac50-4442-8589-d40dda8af173 <list[1]>          NA          NA
#>  95: be2ee895-db65-435a-8cf0-7b97d9d2cd67 <list[1]>          NA          NA
#>  96: a0039436-50db-4388-a9ac-9d1025865efc <list[1]>          NA          NA
#>  97: f9250ee1-74ed-4db7-a6be-879b416dc86d <list[1]>          NA          NA
#>  98: 5564fbff-dee5-4edc-8a62-516ff8af542c <list[1]>          NA          NA
#>  99: b0e47caf-3067-43dc-90c9-bb62f7f9c0a4 <list[1]>          NA          NA
#> 100: 211cf0f0-78a5-4dd0-add6-d2700533f707 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
