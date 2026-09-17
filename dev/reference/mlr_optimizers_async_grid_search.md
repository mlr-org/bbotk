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
#>         state                worker_id         x1         x2          y
#>        <char>                   <char>      <num>      <num>      <num>
#>   1: finished sinking_raccoon_faa72a3e -10.000000 -5.0000000 -138.00000
#>   2: finished sinking_raccoon_faa72a3e -10.000000 -3.8888889 -134.79012
#>   3: finished sinking_raccoon_faa72a3e -10.000000 -2.7777778 -134.04938
#>   4: finished sinking_raccoon_faa72a3e -10.000000 -1.6666667 -135.77778
#>   5: finished sinking_raccoon_faa72a3e -10.000000 -0.5555556 -139.97531
#>   6: finished sinking_raccoon_faa72a3e -10.000000  0.5555556 -146.64198
#>   7: finished sinking_raccoon_faa72a3e -10.000000  1.6666667 -155.77778
#>   8: finished sinking_raccoon_faa72a3e -10.000000  2.7777778 -167.38272
#>   9: finished sinking_raccoon_faa72a3e -10.000000  3.8888889 -181.45679
#>  10: finished sinking_raccoon_faa72a3e -10.000000  5.0000000 -198.00000
#>  11: finished sinking_raccoon_faa72a3e  -7.777778 -5.0000000  -89.60494
#>  12: finished sinking_raccoon_faa72a3e  -7.777778 -3.8888889  -86.39506
#>  13: finished sinking_raccoon_faa72a3e  -7.777778 -2.7777778  -85.65432
#>  14: finished sinking_raccoon_faa72a3e  -7.777778 -1.6666667  -87.38272
#>  15: finished sinking_raccoon_faa72a3e  -7.777778 -0.5555556  -91.58025
#>  16: finished sinking_raccoon_faa72a3e  -7.777778  0.5555556  -98.24691
#>  17: finished sinking_raccoon_faa72a3e  -7.777778  1.6666667 -107.38272
#>  18: finished sinking_raccoon_faa72a3e  -7.777778  2.7777778 -118.98765
#>  19: finished sinking_raccoon_faa72a3e  -7.777778  3.8888889 -133.06173
#>  20: finished sinking_raccoon_faa72a3e  -7.777778  5.0000000 -149.60494
#>  21:   failed                     <NA>  10.000000  5.0000000         NA
#>  22:   failed                     <NA>  10.000000  3.8888889         NA
#>  23:   failed                     <NA>  10.000000  2.7777778         NA
#>  24:   failed                     <NA>  10.000000  1.6666667         NA
#>  25:   failed                     <NA>  10.000000  0.5555556         NA
#>  26:   failed                     <NA>  10.000000 -0.5555556         NA
#>  27:   failed                     <NA>  10.000000 -1.6666667         NA
#>  28:   failed                     <NA>  10.000000 -2.7777778         NA
#>  29:   failed                     <NA>  10.000000 -3.8888889         NA
#>  30:   failed                     <NA>  10.000000 -5.0000000         NA
#>  31:   failed                     <NA>   7.777778  5.0000000         NA
#>  32:   failed                     <NA>   7.777778  3.8888889         NA
#>  33:   failed                     <NA>   7.777778  2.7777778         NA
#>  34:   failed                     <NA>   7.777778  1.6666667         NA
#>  35:   failed                     <NA>   7.777778  0.5555556         NA
#>  36:   failed                     <NA>   7.777778 -0.5555556         NA
#>  37:   failed                     <NA>   7.777778 -1.6666667         NA
#>  38:   failed                     <NA>   7.777778 -2.7777778         NA
#>  39:   failed                     <NA>   7.777778 -3.8888889         NA
#>  40:   failed                     <NA>   7.777778 -5.0000000         NA
#>  41:   failed                     <NA>   5.555556  5.0000000         NA
#>  42:   failed                     <NA>   5.555556  3.8888889         NA
#>  43:   failed                     <NA>   5.555556  2.7777778         NA
#>  44:   failed                     <NA>   5.555556  1.6666667         NA
#>  45:   failed                     <NA>   5.555556  0.5555556         NA
#>  46:   failed                     <NA>   5.555556 -0.5555556         NA
#>  47:   failed                     <NA>   5.555556 -1.6666667         NA
#>  48:   failed                     <NA>   5.555556 -2.7777778         NA
#>  49:   failed                     <NA>   5.555556 -3.8888889         NA
#>  50:   failed                     <NA>   5.555556 -5.0000000         NA
#>  51:   failed                     <NA>   3.333333  5.0000000         NA
#>  52:   failed                     <NA>   3.333333  3.8888889         NA
#>  53:   failed                     <NA>   3.333333  2.7777778         NA
#>  54:   failed                     <NA>   3.333333  1.6666667         NA
#>  55:   failed                     <NA>   3.333333  0.5555556         NA
#>  56:   failed                     <NA>   3.333333 -0.5555556         NA
#>  57:   failed                     <NA>   3.333333 -1.6666667         NA
#>  58:   failed                     <NA>   3.333333 -2.7777778         NA
#>  59:   failed                     <NA>   3.333333 -3.8888889         NA
#>  60:   failed                     <NA>   3.333333 -5.0000000         NA
#>  61:   failed                     <NA>   1.111111  5.0000000         NA
#>  62:   failed                     <NA>   1.111111  3.8888889         NA
#>  63:   failed                     <NA>   1.111111  2.7777778         NA
#>  64:   failed                     <NA>   1.111111  1.6666667         NA
#>  65:   failed                     <NA>   1.111111  0.5555556         NA
#>  66:   failed                     <NA>   1.111111 -0.5555556         NA
#>  67:   failed                     <NA>   1.111111 -1.6666667         NA
#>  68:   failed                     <NA>   1.111111 -2.7777778         NA
#>  69:   failed                     <NA>   1.111111 -3.8888889         NA
#>  70:   failed                     <NA>   1.111111 -5.0000000         NA
#>  71:   failed                     <NA>  -1.111111  5.0000000         NA
#>  72:   failed                     <NA>  -1.111111  3.8888889         NA
#>  73:   failed                     <NA>  -1.111111  2.7777778         NA
#>  74:   failed                     <NA>  -1.111111  1.6666667         NA
#>  75:   failed                     <NA>  -1.111111  0.5555556         NA
#>  76:   failed                     <NA>  -1.111111 -0.5555556         NA
#>  77:   failed                     <NA>  -1.111111 -1.6666667         NA
#>  78:   failed                     <NA>  -1.111111 -2.7777778         NA
#>  79:   failed                     <NA>  -1.111111 -3.8888889         NA
#>  80:   failed                     <NA>  -1.111111 -5.0000000         NA
#>  81:   failed                     <NA>  -3.333333  5.0000000         NA
#>  82:   failed                     <NA>  -3.333333  3.8888889         NA
#>  83:   failed                     <NA>  -3.333333  2.7777778         NA
#>  84:   failed                     <NA>  -3.333333  1.6666667         NA
#>  85:   failed                     <NA>  -3.333333  0.5555556         NA
#>  86:   failed                     <NA>  -3.333333 -0.5555556         NA
#>  87:   failed                     <NA>  -3.333333 -1.6666667         NA
#>  88:   failed                     <NA>  -3.333333 -2.7777778         NA
#>  89:   failed                     <NA>  -3.333333 -3.8888889         NA
#>  90:   failed                     <NA>  -3.333333 -5.0000000         NA
#>  91:   failed                     <NA>  -5.555556  5.0000000         NA
#>  92:   failed                     <NA>  -5.555556  3.8888889         NA
#>  93:   failed                     <NA>  -5.555556  2.7777778         NA
#>  94:   failed                     <NA>  -5.555556  1.6666667         NA
#>  95:   failed                     <NA>  -5.555556  0.5555556         NA
#>  96:   failed                     <NA>  -5.555556 -0.5555556         NA
#>  97:   failed                     <NA>  -5.555556 -1.6666667         NA
#>  98:   failed                     <NA>  -5.555556 -2.7777778         NA
#>  99:   failed                     <NA>  -5.555556 -3.8888889         NA
#> 100:   failed                     <NA>  -5.555556 -5.0000000         NA
#>         state                worker_id         x1         x2          y
#>        <char>                   <char>      <num>      <num>      <num>
#>             timestamp_xs        timestamp_ys
#>                   <POSc>              <POSc>
#>   1: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>   2: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>   3: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>   4: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>   5: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>   6: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>   7: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>   8: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>   9: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>  10: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>  11: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>  12: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>  13: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>  14: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>  15: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>  16: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>  17: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>  18: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>  19: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>  20: 2026-09-17 07:44:42 2026-09-17 07:44:42
#>  21: 2026-09-17 07:44:42                <NA>
#>  22: 2026-09-17 07:44:42                <NA>
#>  23: 2026-09-17 07:44:42                <NA>
#>  24: 2026-09-17 07:44:42                <NA>
#>  25: 2026-09-17 07:44:42                <NA>
#>  26: 2026-09-17 07:44:42                <NA>
#>  27: 2026-09-17 07:44:42                <NA>
#>  28: 2026-09-17 07:44:42                <NA>
#>  29: 2026-09-17 07:44:42                <NA>
#>  30: 2026-09-17 07:44:42                <NA>
#>  31: 2026-09-17 07:44:42                <NA>
#>  32: 2026-09-17 07:44:42                <NA>
#>  33: 2026-09-17 07:44:42                <NA>
#>  34: 2026-09-17 07:44:42                <NA>
#>  35: 2026-09-17 07:44:42                <NA>
#>  36: 2026-09-17 07:44:42                <NA>
#>  37: 2026-09-17 07:44:42                <NA>
#>  38: 2026-09-17 07:44:42                <NA>
#>  39: 2026-09-17 07:44:42                <NA>
#>  40: 2026-09-17 07:44:42                <NA>
#>  41: 2026-09-17 07:44:42                <NA>
#>  42: 2026-09-17 07:44:42                <NA>
#>  43: 2026-09-17 07:44:42                <NA>
#>  44: 2026-09-17 07:44:42                <NA>
#>  45: 2026-09-17 07:44:42                <NA>
#>  46: 2026-09-17 07:44:42                <NA>
#>  47: 2026-09-17 07:44:42                <NA>
#>  48: 2026-09-17 07:44:42                <NA>
#>  49: 2026-09-17 07:44:42                <NA>
#>  50: 2026-09-17 07:44:42                <NA>
#>  51: 2026-09-17 07:44:42                <NA>
#>  52: 2026-09-17 07:44:42                <NA>
#>  53: 2026-09-17 07:44:42                <NA>
#>  54: 2026-09-17 07:44:42                <NA>
#>  55: 2026-09-17 07:44:42                <NA>
#>  56: 2026-09-17 07:44:42                <NA>
#>  57: 2026-09-17 07:44:42                <NA>
#>  58: 2026-09-17 07:44:42                <NA>
#>  59: 2026-09-17 07:44:42                <NA>
#>  60: 2026-09-17 07:44:42                <NA>
#>  61: 2026-09-17 07:44:42                <NA>
#>  62: 2026-09-17 07:44:42                <NA>
#>  63: 2026-09-17 07:44:42                <NA>
#>  64: 2026-09-17 07:44:42                <NA>
#>  65: 2026-09-17 07:44:42                <NA>
#>  66: 2026-09-17 07:44:42                <NA>
#>  67: 2026-09-17 07:44:42                <NA>
#>  68: 2026-09-17 07:44:42                <NA>
#>  69: 2026-09-17 07:44:42                <NA>
#>  70: 2026-09-17 07:44:42                <NA>
#>  71: 2026-09-17 07:44:42                <NA>
#>  72: 2026-09-17 07:44:42                <NA>
#>  73: 2026-09-17 07:44:42                <NA>
#>  74: 2026-09-17 07:44:42                <NA>
#>  75: 2026-09-17 07:44:42                <NA>
#>  76: 2026-09-17 07:44:42                <NA>
#>  77: 2026-09-17 07:44:42                <NA>
#>  78: 2026-09-17 07:44:42                <NA>
#>  79: 2026-09-17 07:44:42                <NA>
#>  80: 2026-09-17 07:44:42                <NA>
#>  81: 2026-09-17 07:44:42                <NA>
#>  82: 2026-09-17 07:44:42                <NA>
#>  83: 2026-09-17 07:44:42                <NA>
#>  84: 2026-09-17 07:44:42                <NA>
#>  85: 2026-09-17 07:44:42                <NA>
#>  86: 2026-09-17 07:44:42                <NA>
#>  87: 2026-09-17 07:44:42                <NA>
#>  88: 2026-09-17 07:44:42                <NA>
#>  89: 2026-09-17 07:44:42                <NA>
#>  90: 2026-09-17 07:44:42                <NA>
#>  91: 2026-09-17 07:44:42                <NA>
#>  92: 2026-09-17 07:44:42                <NA>
#>  93: 2026-09-17 07:44:42                <NA>
#>  94: 2026-09-17 07:44:42                <NA>
#>  95: 2026-09-17 07:44:42                <NA>
#>  96: 2026-09-17 07:44:42                <NA>
#>  97: 2026-09-17 07:44:42                <NA>
#>  98: 2026-09-17 07:44:42                <NA>
#>  99: 2026-09-17 07:44:42                <NA>
#> 100: 2026-09-17 07:44:42                <NA>
#>             timestamp_xs        timestamp_ys
#>                   <POSc>              <POSc>
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
#>   1: 21e923c6-8a75-4cd5-afaf-38725d9545cb    [NULL]  -10.000000  -5.0000000
#>   2: 6da33e67-87d8-4b8b-960f-3c004066a1f4    [NULL]  -10.000000  -3.8888889
#>   3: b4dd45f4-a4b7-4e7a-a285-5896e18e4fde    [NULL]  -10.000000  -2.7777778
#>   4: e1107f69-0dbf-418c-b0a2-45e30b7ebae7    [NULL]  -10.000000  -1.6666667
#>   5: 6a83c3f6-837f-44b5-af46-6913ba14a85d    [NULL]  -10.000000  -0.5555556
#>   6: 956e7166-56d4-4562-838e-325d766a4679    [NULL]  -10.000000   0.5555556
#>   7: 9f9668b1-2655-4d7e-ae5e-3325ad6f20a9    [NULL]  -10.000000   1.6666667
#>   8: 6db9b659-febc-4ac5-bca9-a7ba21cc4736    [NULL]  -10.000000   2.7777778
#>   9: 992a0111-db4d-494c-82cb-a03acd59efa2    [NULL]  -10.000000   3.8888889
#>  10: 4ca7e19c-318b-48bd-8a9b-d80bdfe3f91e    [NULL]  -10.000000   5.0000000
#>  11: 37632757-88e0-4021-82f1-d324b35732ae    [NULL]   -7.777778  -5.0000000
#>  12: 91ccc45f-761d-43f6-aaac-41c8bc698f0c    [NULL]   -7.777778  -3.8888889
#>  13: f664cb6f-540a-4e05-8bdd-24e55b54f54f    [NULL]   -7.777778  -2.7777778
#>  14: 8433d5c5-8013-460b-afac-a98c5c6b8fcd    [NULL]   -7.777778  -1.6666667
#>  15: 22777bbb-343e-44e9-be00-27a756d69799    [NULL]   -7.777778  -0.5555556
#>  16: 25b942ef-4f60-4e31-8ead-762f7361e342    [NULL]   -7.777778   0.5555556
#>  17: ba650d7f-f4b9-4bda-b79d-b6fab5004378    [NULL]   -7.777778   1.6666667
#>  18: 0ec8a74a-cfb7-4528-94e2-4424a97be5a1    [NULL]   -7.777778   2.7777778
#>  19: d6e85009-8752-4bc2-941e-bbc43713ef05    [NULL]   -7.777778   3.8888889
#>  20: 0329f9c1-2002-4974-9bee-282bf3331402    [NULL]   -7.777778   5.0000000
#>  21: 683533b5-7332-44dd-b206-7fa35acd1e39 <list[1]>          NA          NA
#>  22: 3ace4916-ccc7-42f5-ab54-c748fcabd8f3 <list[1]>          NA          NA
#>  23: 4fec1cca-5586-4e40-a8ba-f5c4c69dbb8d <list[1]>          NA          NA
#>  24: 272b3a98-5b19-44a8-abfd-b4e3634cf031 <list[1]>          NA          NA
#>  25: 2411f040-ccd7-4f9a-91b4-0b9b04deb626 <list[1]>          NA          NA
#>  26: 4e81dedc-5b02-4e12-90e9-ab84db36846d <list[1]>          NA          NA
#>  27: 0e364989-fbf0-4c81-b01c-bc46490b3cfc <list[1]>          NA          NA
#>  28: 263be46b-a1f5-47f0-bece-9b4d2892f7d7 <list[1]>          NA          NA
#>  29: be47dc71-051c-41db-8362-90ded7d841a0 <list[1]>          NA          NA
#>  30: c4e26dbb-6e86-42b4-908d-bc475bfc2c14 <list[1]>          NA          NA
#>  31: 1b67a711-c3fc-47fc-b026-3918ff1c08c5 <list[1]>          NA          NA
#>  32: 0961b09b-6b48-4b8c-848c-32e66a575a13 <list[1]>          NA          NA
#>  33: b77407c4-163e-41d6-b71c-6737153a8466 <list[1]>          NA          NA
#>  34: 28178d93-91c9-4f42-b992-75d99ef303ed <list[1]>          NA          NA
#>  35: fbf475ef-2026-48cd-a8e2-4d8646fae922 <list[1]>          NA          NA
#>  36: 53e4202d-c397-420e-8977-4edcec804110 <list[1]>          NA          NA
#>  37: 9c23d2b5-2f47-497d-8803-62096a1a4a76 <list[1]>          NA          NA
#>  38: 17dda07c-6db4-46cc-b08e-120a45b9e361 <list[1]>          NA          NA
#>  39: 57507687-5b78-4fed-9a47-6e0b912c7b33 <list[1]>          NA          NA
#>  40: 024e5190-1ead-42ee-a0c4-99995d68a7dc <list[1]>          NA          NA
#>  41: 0d7b9055-33ac-4d53-bda7-9108a6e558d0 <list[1]>          NA          NA
#>  42: f147d2b3-422b-4c24-b232-ec7fe0068d22 <list[1]>          NA          NA
#>  43: 46a37cab-a432-4ddb-bc86-399f23a7e79a <list[1]>          NA          NA
#>  44: 0cdcda8c-c737-4b35-957b-d85151225e8a <list[1]>          NA          NA
#>  45: 2a1a6be3-f6e5-4d05-bad5-e24b5d96b294 <list[1]>          NA          NA
#>  46: 2a0e31d1-6c98-4bce-b8e0-f811d411b5ad <list[1]>          NA          NA
#>  47: 0efeb8ea-38a7-4241-ae70-573212fb4f9a <list[1]>          NA          NA
#>  48: d60ee318-ea4d-4659-a993-f0079e3b34f4 <list[1]>          NA          NA
#>  49: 2032359c-2c23-4f33-b735-d24e902460ec <list[1]>          NA          NA
#>  50: bb2a76ff-774d-4802-b72d-0e7e18f58c80 <list[1]>          NA          NA
#>  51: fc1b68b8-ec58-44c5-ad31-39be24c12e52 <list[1]>          NA          NA
#>  52: bc56cf9f-3193-461d-89b2-714331cb3523 <list[1]>          NA          NA
#>  53: fa1d4fe4-8663-4441-aef4-ef454772fb8e <list[1]>          NA          NA
#>  54: 03de9ff5-aa99-4083-b23d-8be0e4ee9ab3 <list[1]>          NA          NA
#>  55: a834e822-4388-4835-9175-6e0e03484ac2 <list[1]>          NA          NA
#>  56: 7528b54d-8080-4698-9171-6953f0d8756d <list[1]>          NA          NA
#>  57: 656f33f5-0b72-45b9-bfeb-0da056ba8033 <list[1]>          NA          NA
#>  58: d3d040d7-b25d-410c-877e-93001541496f <list[1]>          NA          NA
#>  59: 50cb4a07-2ac2-4b45-888d-b51adf5e68ed <list[1]>          NA          NA
#>  60: 77763f2e-ce3b-40ad-8371-b8c22f04859b <list[1]>          NA          NA
#>  61: fb9969d0-9a84-4dd5-b742-388a2a4edd09 <list[1]>          NA          NA
#>  62: ad3fddae-014f-40bc-a71e-c42eaf8ccf54 <list[1]>          NA          NA
#>  63: 62f21ec3-6799-47d7-9573-e9b62b59d1f9 <list[1]>          NA          NA
#>  64: 33d099fc-fd83-4617-b082-b8f6900440c3 <list[1]>          NA          NA
#>  65: 01664d4b-8aad-4856-b88d-30981d14c17c <list[1]>          NA          NA
#>  66: 55f43bee-8842-432f-9996-13999386bb5e <list[1]>          NA          NA
#>  67: e4b646ea-f9af-4eca-97ff-22ee0f9b4f44 <list[1]>          NA          NA
#>  68: 2a9bb7e1-6dd9-424d-8bc7-c4f4cd06beab <list[1]>          NA          NA
#>  69: c462c98e-6506-466d-8184-2f3785681975 <list[1]>          NA          NA
#>  70: 17e3216c-348b-4bbf-943c-d246f5b3f4e3 <list[1]>          NA          NA
#>  71: c05f3205-818f-474f-bead-3b422327449d <list[1]>          NA          NA
#>  72: 2e04685a-8eb0-4134-b177-8ecb5bcb8140 <list[1]>          NA          NA
#>  73: 607ad953-4d03-46cd-9918-952748f8c6e1 <list[1]>          NA          NA
#>  74: 0c575634-d57f-4d64-a746-a4aba2687235 <list[1]>          NA          NA
#>  75: d7952334-56cf-4aac-a27f-8776c2088b59 <list[1]>          NA          NA
#>  76: ec1c1ff3-73f9-4f4e-8961-56ab01205b1f <list[1]>          NA          NA
#>  77: db3a5738-3d00-458a-b127-3342342d5ced <list[1]>          NA          NA
#>  78: b236ea4e-e5ac-42c8-8fa4-274a7fc2f2e4 <list[1]>          NA          NA
#>  79: 8b348866-db66-46d6-a058-395ecd512901 <list[1]>          NA          NA
#>  80: ee06a8ce-24cb-44fb-bc2a-20a7ed4dc6d6 <list[1]>          NA          NA
#>  81: eb58ede6-6314-4d6c-81cb-58f225323303 <list[1]>          NA          NA
#>  82: 93457d38-4f06-4024-b001-22fefb9c9032 <list[1]>          NA          NA
#>  83: a0ba3c05-77f6-4584-b502-989891b66ab6 <list[1]>          NA          NA
#>  84: 775da030-364f-44c8-9b8c-28ae394af4d2 <list[1]>          NA          NA
#>  85: dc4df11a-886c-4c26-a758-279ec9d1d0e4 <list[1]>          NA          NA
#>  86: 6ff4bd94-2653-4f98-bb78-de5ff55cdcd2 <list[1]>          NA          NA
#>  87: bb119cc2-e3cb-49b6-870e-79e84f564f77 <list[1]>          NA          NA
#>  88: 4be2f695-82d2-4a68-a0f8-f1f028554e4f <list[1]>          NA          NA
#>  89: bd282d65-ba4b-46f3-82b9-7b5ab0207b05 <list[1]>          NA          NA
#>  90: 46ec20fd-5874-489e-97f1-e24af7c538fb <list[1]>          NA          NA
#>  91: 8a698d01-e262-4d1d-963e-ca63d4a36bae <list[1]>          NA          NA
#>  92: 185cdbcf-1a3d-482d-be4d-a3e2de91ecb6 <list[1]>          NA          NA
#>  93: cc03b820-0026-4352-8437-bf20420850ce <list[1]>          NA          NA
#>  94: c58a9950-569f-4812-bcdb-d37f33a8d746 <list[1]>          NA          NA
#>  95: f43e3da9-539f-482f-8b38-b9ea343ec2a7 <list[1]>          NA          NA
#>  96: ae32c813-4e2f-4e41-9ef0-ef6531d808ae <list[1]>          NA          NA
#>  97: 1eeb7b5d-131c-4d56-8bab-66e904bcc24f <list[1]>          NA          NA
#>  98: 56ca507c-bd3b-4a86-95f4-6f780769d498 <list[1]>          NA          NA
#>  99: 141a1cab-8b97-4494-b529-e752418ecf81 <list[1]>          NA          NA
#> 100: 4a303a0f-2ad0-4470-94cf-b113b7ac4448 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
