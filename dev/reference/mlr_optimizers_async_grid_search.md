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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-03 11:36:34
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-03 11:36:34
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-03 11:36:34
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-03 11:36:34
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-03 11:36:34
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-03 11:36:34
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-03 11:36:34
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-03 11:36:34
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-03 11:36:34
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-03 11:36:34
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-03 11:36:34
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-03 11:36:34
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-03 11:36:34
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-03 11:36:34
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-03 11:36:34
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-03 11:36:34
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-03 11:36:34
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-03 11:36:34
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-03 11:36:34
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-03 11:36:34
#>  21:   failed  10.000000  5.0000000         NA 2026-09-03 11:36:34
#>  22:   failed  10.000000  3.8888889         NA 2026-09-03 11:36:34
#>  23:   failed  10.000000  2.7777778         NA 2026-09-03 11:36:34
#>  24:   failed  10.000000  1.6666667         NA 2026-09-03 11:36:34
#>  25:   failed  10.000000  0.5555556         NA 2026-09-03 11:36:34
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-03 11:36:34
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-03 11:36:34
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-03 11:36:34
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-03 11:36:34
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-03 11:36:34
#>  31:   failed   7.777778  5.0000000         NA 2026-09-03 11:36:34
#>  32:   failed   7.777778  3.8888889         NA 2026-09-03 11:36:34
#>  33:   failed   7.777778  2.7777778         NA 2026-09-03 11:36:34
#>  34:   failed   7.777778  1.6666667         NA 2026-09-03 11:36:34
#>  35:   failed   7.777778  0.5555556         NA 2026-09-03 11:36:34
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-03 11:36:34
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-03 11:36:34
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-03 11:36:34
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-03 11:36:34
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-03 11:36:34
#>  41:   failed   5.555556  5.0000000         NA 2026-09-03 11:36:34
#>  42:   failed   5.555556  3.8888889         NA 2026-09-03 11:36:34
#>  43:   failed   5.555556  2.7777778         NA 2026-09-03 11:36:34
#>  44:   failed   5.555556  1.6666667         NA 2026-09-03 11:36:34
#>  45:   failed   5.555556  0.5555556         NA 2026-09-03 11:36:34
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-03 11:36:34
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-03 11:36:34
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-03 11:36:34
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-03 11:36:34
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-03 11:36:34
#>  51:   failed   3.333333  5.0000000         NA 2026-09-03 11:36:34
#>  52:   failed   3.333333  3.8888889         NA 2026-09-03 11:36:34
#>  53:   failed   3.333333  2.7777778         NA 2026-09-03 11:36:34
#>  54:   failed   3.333333  1.6666667         NA 2026-09-03 11:36:34
#>  55:   failed   3.333333  0.5555556         NA 2026-09-03 11:36:34
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-03 11:36:34
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-03 11:36:34
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-03 11:36:34
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-03 11:36:34
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-03 11:36:34
#>  61:   failed   1.111111  5.0000000         NA 2026-09-03 11:36:34
#>  62:   failed   1.111111  3.8888889         NA 2026-09-03 11:36:34
#>  63:   failed   1.111111  2.7777778         NA 2026-09-03 11:36:34
#>  64:   failed   1.111111  1.6666667         NA 2026-09-03 11:36:34
#>  65:   failed   1.111111  0.5555556         NA 2026-09-03 11:36:34
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-03 11:36:34
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-03 11:36:34
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-03 11:36:34
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-03 11:36:34
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-03 11:36:34
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-03 11:36:34
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-03 11:36:34
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-03 11:36:34
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-03 11:36:34
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-03 11:36:34
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-03 11:36:34
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-03 11:36:34
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-03 11:36:34
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-03 11:36:34
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-03 11:36:34
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-03 11:36:34
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-03 11:36:34
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-03 11:36:34
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-03 11:36:34
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-03 11:36:34
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-03 11:36:34
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-03 11:36:34
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-03 11:36:34
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-03 11:36:34
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-03 11:36:34
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-03 11:36:34
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-03 11:36:34
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-03 11:36:34
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-03 11:36:34
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-03 11:36:34
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-03 11:36:34
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-03 11:36:34
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-03 11:36:34
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-03 11:36:34
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-03 11:36:34
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>   2: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>   3: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>   4: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>   5: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>   6: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>   7: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>   8: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>   9: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>  10: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>  11: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>  12: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>  13: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>  14: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>  15: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>  16: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>  17: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>  18: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>  19: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
#>  20: sinking_raccoon_8908f9c8 2026-09-03 11:36:35
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
#>   1: 84f78273-3651-40b4-871d-e22401e1170c    [NULL]  -10.000000  -5.0000000
#>   2: 92c40862-e370-4ab3-913a-584530961fd6    [NULL]  -10.000000  -3.8888889
#>   3: bafa524b-3cf3-4cb7-b928-973305728acd    [NULL]  -10.000000  -2.7777778
#>   4: f82a0daa-580e-4078-8b7a-bc969ba1e806    [NULL]  -10.000000  -1.6666667
#>   5: 17b73fb8-8636-48b2-85ea-bcfab15b7cb6    [NULL]  -10.000000  -0.5555556
#>   6: 14666553-a18e-48b3-a7c3-abe4ac0aaefc    [NULL]  -10.000000   0.5555556
#>   7: 976b8038-9bdb-448b-8693-9c442cf7b3e1    [NULL]  -10.000000   1.6666667
#>   8: 00878edd-c89d-4d33-8fa7-2cd95fba0983    [NULL]  -10.000000   2.7777778
#>   9: 87c0c14b-a108-4d1a-8a8b-60658c033bb7    [NULL]  -10.000000   3.8888889
#>  10: fa57c684-bf1f-4eca-8863-8b5034682a62    [NULL]  -10.000000   5.0000000
#>  11: 9a4feca6-f142-4bf7-be30-b3ec8992b69e    [NULL]   -7.777778  -5.0000000
#>  12: e63ed70f-2195-45ab-9bbe-29e93499855b    [NULL]   -7.777778  -3.8888889
#>  13: 9c88d0e9-999e-40e0-b361-472fb7b7fd51    [NULL]   -7.777778  -2.7777778
#>  14: ba25a686-420e-4bce-ae19-64be712166ed    [NULL]   -7.777778  -1.6666667
#>  15: 7cd0b572-0635-4243-837e-4ceef5c00d4e    [NULL]   -7.777778  -0.5555556
#>  16: c7924ac8-fb93-44ad-a9fb-f863b698dbef    [NULL]   -7.777778   0.5555556
#>  17: 3a99ccad-6f52-4c72-b6e0-dea7bb42d96c    [NULL]   -7.777778   1.6666667
#>  18: 35b81ff5-363c-4b9c-b03d-4fd9502fa010    [NULL]   -7.777778   2.7777778
#>  19: 24bbd887-b8a4-44a4-b823-f0fe336f1807    [NULL]   -7.777778   3.8888889
#>  20: 5dabce3a-a0a8-4a05-b8be-cd32ce469209    [NULL]   -7.777778   5.0000000
#>  21: eeb463cd-2d63-494e-ad2f-bc597e27dc8b <list[1]>          NA          NA
#>  22: 688bf506-50c7-441e-a383-da4edd88ac60 <list[1]>          NA          NA
#>  23: fd5e53b2-098a-4d2b-870d-44530b62bb1e <list[1]>          NA          NA
#>  24: a74c422a-626b-41bc-987e-43bab7a57d55 <list[1]>          NA          NA
#>  25: 6bb35bcc-25e9-4104-abb0-7a2fa3c3fb3f <list[1]>          NA          NA
#>  26: 5e00e8ed-e69e-4360-82fc-30d03425352c <list[1]>          NA          NA
#>  27: 5e99650c-0772-4fb0-80bb-1a00a6a4a2de <list[1]>          NA          NA
#>  28: f9d1722e-e86e-406d-a4c0-cf06be949b68 <list[1]>          NA          NA
#>  29: 13ec3860-b515-4e98-874d-d7c1ab04e15c <list[1]>          NA          NA
#>  30: 00ab41e7-8ab4-4267-a649-c8628062d35d <list[1]>          NA          NA
#>  31: f4674b59-1ffe-451a-acef-77d9d422f242 <list[1]>          NA          NA
#>  32: 5fba52bb-7cb2-425a-9ac6-1246fc58ff03 <list[1]>          NA          NA
#>  33: 2d995fa4-5f4d-4b36-9287-8ff6490d45a9 <list[1]>          NA          NA
#>  34: 565b2840-a44a-4400-8377-6e0973b07e83 <list[1]>          NA          NA
#>  35: eeb394da-2a95-44e5-b0d9-e4fe6fff76cc <list[1]>          NA          NA
#>  36: 73cb1dcb-c531-4d06-a0b8-c247ecf76af8 <list[1]>          NA          NA
#>  37: 98171936-9bcc-4267-b64f-ec6b46681bb7 <list[1]>          NA          NA
#>  38: 3f0917a7-2b43-41b1-b53b-c4b8025244e7 <list[1]>          NA          NA
#>  39: da2f523a-2891-40b1-bcf1-ddfd643a1e54 <list[1]>          NA          NA
#>  40: eee744b3-5fe2-41e3-954a-1a678fff0939 <list[1]>          NA          NA
#>  41: 8d038d74-26c5-4c86-b515-da7486e67f31 <list[1]>          NA          NA
#>  42: ea99b9f0-d18a-463d-ae3c-9361c19d11ab <list[1]>          NA          NA
#>  43: cfe20f83-2f9f-4a4e-a2cf-b3b51fd9603f <list[1]>          NA          NA
#>  44: 4040d942-9902-41a2-aa09-d096b503f7be <list[1]>          NA          NA
#>  45: df036111-d3b8-4122-bfd5-d1f8ef3a3567 <list[1]>          NA          NA
#>  46: 602186de-1ca5-4461-911b-6d43bf63f242 <list[1]>          NA          NA
#>  47: 023a95ad-4405-4680-ac1e-ec7e69f17ae0 <list[1]>          NA          NA
#>  48: a392823d-349f-45ec-a980-dd7c23474965 <list[1]>          NA          NA
#>  49: a6766858-e56a-498c-8350-3b75fd077d76 <list[1]>          NA          NA
#>  50: 804714d1-af0a-482f-a8f0-17fd61d72a36 <list[1]>          NA          NA
#>  51: 4aa79b2e-3022-4136-9c7f-35a2a7e8590d <list[1]>          NA          NA
#>  52: 8c0c661c-a029-4447-bf60-2d3926e9b105 <list[1]>          NA          NA
#>  53: 5ca5b738-0253-47f9-9bb8-652b4618d56f <list[1]>          NA          NA
#>  54: 970cc74d-045d-45a0-b19a-03885c709560 <list[1]>          NA          NA
#>  55: 7582cae9-91a8-4adc-9b4f-92519926d677 <list[1]>          NA          NA
#>  56: 272ead4d-1044-4f56-b75a-40af91d709a7 <list[1]>          NA          NA
#>  57: 02551f45-b56a-4160-ae06-88828fa3f5cc <list[1]>          NA          NA
#>  58: 5489fb75-1e19-496d-9535-f06264759752 <list[1]>          NA          NA
#>  59: 72d40139-b7c6-4ddf-8972-d87f3218e0b5 <list[1]>          NA          NA
#>  60: 34f4cebc-26f0-456b-99d5-20c95fb03d03 <list[1]>          NA          NA
#>  61: 62e0f861-4161-4f7f-ab75-fa64402cac2c <list[1]>          NA          NA
#>  62: e08e2e2d-d366-4d74-83ae-89ede75768b8 <list[1]>          NA          NA
#>  63: 7ad8d5ee-c699-4523-a6bf-4651f7dfcdf7 <list[1]>          NA          NA
#>  64: 5dd5442b-2513-40ad-9dd4-fdc6177f339c <list[1]>          NA          NA
#>  65: 3fdc1b3e-0764-411d-bdc8-6989b9eeb634 <list[1]>          NA          NA
#>  66: e88778bd-1719-4d7f-96a0-7201932b35a3 <list[1]>          NA          NA
#>  67: 89c717cb-94c0-4412-a138-7a42b328b703 <list[1]>          NA          NA
#>  68: 98c823bd-d215-4a8b-a19e-1cb1f963b485 <list[1]>          NA          NA
#>  69: 01a46c12-324f-4f70-9b2a-954e07b244ae <list[1]>          NA          NA
#>  70: 8031d6e6-2eff-4969-ad6b-3cf4754190be <list[1]>          NA          NA
#>  71: 5d4f7f84-3a1d-480c-97bb-11b8d3c4c4e2 <list[1]>          NA          NA
#>  72: 2cb14a0a-4f2c-4f10-bacc-baf24eaa9be5 <list[1]>          NA          NA
#>  73: a2d22a92-e80a-493e-83d3-9c77ec0506af <list[1]>          NA          NA
#>  74: 6549c35e-28e9-43d1-a78f-d10b8b061a2b <list[1]>          NA          NA
#>  75: c84209eb-60c3-4294-b069-dd640b778c53 <list[1]>          NA          NA
#>  76: a45a8eca-2e7e-4e67-ad6f-a76f06d6cf45 <list[1]>          NA          NA
#>  77: a2c334ce-f7d6-4de8-b22a-c63238a64d7f <list[1]>          NA          NA
#>  78: a9567011-f669-4ed7-aa37-4091de66174f <list[1]>          NA          NA
#>  79: 5690d318-8103-4377-b625-d3ec8d7873c3 <list[1]>          NA          NA
#>  80: a28f3873-f0a3-4118-84eb-03d99170f580 <list[1]>          NA          NA
#>  81: 63b23e9c-87fd-4634-af21-9abe5b4256a3 <list[1]>          NA          NA
#>  82: f1fe1122-e059-40b5-8ca0-f97b11d90aba <list[1]>          NA          NA
#>  83: 559ded5f-2ad3-480d-b07d-e6dfa6f71445 <list[1]>          NA          NA
#>  84: 859958eb-5101-4fe5-bbaf-fd5d1a290f01 <list[1]>          NA          NA
#>  85: 2e4c9b14-d979-4d5a-9fd9-4780a6a9eee8 <list[1]>          NA          NA
#>  86: 4cfaedd7-4d43-47c5-9a8c-19f723428127 <list[1]>          NA          NA
#>  87: c6c800c6-170c-433c-b608-628ff3a1e60b <list[1]>          NA          NA
#>  88: 3846b6eb-092a-4ba6-af30-e690fd845a82 <list[1]>          NA          NA
#>  89: 7904261d-49c7-4382-be3c-2488d8dd6a19 <list[1]>          NA          NA
#>  90: e7397ab4-19c1-4f34-a540-34b85e3d46fb <list[1]>          NA          NA
#>  91: 3dfae808-0a3e-47b1-a996-8e116a4b9364 <list[1]>          NA          NA
#>  92: 47246b23-002b-47bd-9a33-e586f14439af <list[1]>          NA          NA
#>  93: 459b4d08-5655-4c9e-b683-05d7591b7c45 <list[1]>          NA          NA
#>  94: fb7855d5-d8c9-4f24-8f62-7b0a1f4166e9 <list[1]>          NA          NA
#>  95: aec8c494-2fa2-4a12-9fd6-0ed3465dcf04 <list[1]>          NA          NA
#>  96: e9f8a52b-f559-487a-9133-1b0d8a525f00 <list[1]>          NA          NA
#>  97: 622ff5e3-8b5f-49ff-98a6-12ba0c3a7906 <list[1]>          NA          NA
#>  98: c63da3c4-45c1-43b8-9e88-dbb4b8fbba0c <list[1]>          NA          NA
#>  99: b03370fa-2f11-4987-8d88-0a8aff15928b <list[1]>          NA          NA
#> 100: 4f5df8ba-da1d-463d-942e-b559bb286e2d <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
