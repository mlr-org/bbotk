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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-17 09:57:36
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-17 09:57:36
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-17 09:57:36
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-17 09:57:36
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-17 09:57:36
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-17 09:57:36
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-17 09:57:36
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-17 09:57:36
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-17 09:57:36
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-17 09:57:36
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-17 09:57:36
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-17 09:57:36
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-17 09:57:36
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-17 09:57:36
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-17 09:57:36
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-17 09:57:36
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-17 09:57:36
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-17 09:57:36
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-17 09:57:36
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-17 09:57:36
#>  21:   failed  10.000000  5.0000000         NA 2026-09-17 09:57:36
#>  22:   failed  10.000000  3.8888889         NA 2026-09-17 09:57:36
#>  23:   failed  10.000000  2.7777778         NA 2026-09-17 09:57:36
#>  24:   failed  10.000000  1.6666667         NA 2026-09-17 09:57:36
#>  25:   failed  10.000000  0.5555556         NA 2026-09-17 09:57:36
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-17 09:57:36
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-17 09:57:36
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-17 09:57:36
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-17 09:57:36
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-17 09:57:36
#>  31:   failed   7.777778  5.0000000         NA 2026-09-17 09:57:36
#>  32:   failed   7.777778  3.8888889         NA 2026-09-17 09:57:36
#>  33:   failed   7.777778  2.7777778         NA 2026-09-17 09:57:36
#>  34:   failed   7.777778  1.6666667         NA 2026-09-17 09:57:36
#>  35:   failed   7.777778  0.5555556         NA 2026-09-17 09:57:36
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-17 09:57:36
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-17 09:57:36
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-17 09:57:36
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-17 09:57:36
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-17 09:57:36
#>  41:   failed   5.555556  5.0000000         NA 2026-09-17 09:57:36
#>  42:   failed   5.555556  3.8888889         NA 2026-09-17 09:57:36
#>  43:   failed   5.555556  2.7777778         NA 2026-09-17 09:57:36
#>  44:   failed   5.555556  1.6666667         NA 2026-09-17 09:57:36
#>  45:   failed   5.555556  0.5555556         NA 2026-09-17 09:57:36
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-17 09:57:36
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-17 09:57:36
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-17 09:57:36
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-17 09:57:36
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-17 09:57:36
#>  51:   failed   3.333333  5.0000000         NA 2026-09-17 09:57:36
#>  52:   failed   3.333333  3.8888889         NA 2026-09-17 09:57:36
#>  53:   failed   3.333333  2.7777778         NA 2026-09-17 09:57:36
#>  54:   failed   3.333333  1.6666667         NA 2026-09-17 09:57:36
#>  55:   failed   3.333333  0.5555556         NA 2026-09-17 09:57:36
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-17 09:57:36
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-17 09:57:36
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-17 09:57:36
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-17 09:57:36
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-17 09:57:36
#>  61:   failed   1.111111  5.0000000         NA 2026-09-17 09:57:36
#>  62:   failed   1.111111  3.8888889         NA 2026-09-17 09:57:36
#>  63:   failed   1.111111  2.7777778         NA 2026-09-17 09:57:36
#>  64:   failed   1.111111  1.6666667         NA 2026-09-17 09:57:36
#>  65:   failed   1.111111  0.5555556         NA 2026-09-17 09:57:36
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-17 09:57:36
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-17 09:57:36
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-17 09:57:36
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-17 09:57:36
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-17 09:57:36
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-17 09:57:36
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-17 09:57:36
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-17 09:57:36
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-17 09:57:36
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-17 09:57:36
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-17 09:57:36
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-17 09:57:36
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-17 09:57:36
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-17 09:57:36
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-17 09:57:36
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-17 09:57:36
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-17 09:57:36
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-17 09:57:36
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-17 09:57:36
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-17 09:57:36
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-17 09:57:36
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-17 09:57:36
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-17 09:57:36
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-17 09:57:36
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-17 09:57:36
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-17 09:57:36
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-17 09:57:36
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-17 09:57:36
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-17 09:57:36
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-17 09:57:36
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-17 09:57:36
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-17 09:57:36
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-17 09:57:36
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-17 09:57:36
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-17 09:57:36
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>   2: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>   3: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>   4: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>   5: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>   6: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>   7: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>   8: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>   9: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>  10: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>  11: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>  12: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>  13: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>  14: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>  15: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>  16: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>  17: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>  18: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>  19: sinking_raccoon_0add2326 2026-09-17 09:57:37
#>  20: sinking_raccoon_0add2326 2026-09-17 09:57:37
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
#>   1: 73598d49-70e2-4460-a895-b105d1200b20    [NULL]  -10.000000  -5.0000000
#>   2: 1ced7f75-ec8a-4f8d-81a5-74bfaa2af82d    [NULL]  -10.000000  -3.8888889
#>   3: cc26c8a2-d614-4113-a37b-00fa915a5f4d    [NULL]  -10.000000  -2.7777778
#>   4: f4653276-6a9b-4768-a023-ea487a2503d1    [NULL]  -10.000000  -1.6666667
#>   5: 216845ce-a5b7-49ff-95ea-2872440de9ca    [NULL]  -10.000000  -0.5555556
#>   6: a363c503-c74f-4161-a532-35d330db13a8    [NULL]  -10.000000   0.5555556
#>   7: f006d6f5-fe58-4200-9907-8fdcc66ddc1f    [NULL]  -10.000000   1.6666667
#>   8: d36cf618-6752-4779-b9f5-d8b3c5c96d94    [NULL]  -10.000000   2.7777778
#>   9: a631d192-3829-418c-8691-fe85bc3ff4cb    [NULL]  -10.000000   3.8888889
#>  10: bef30664-caab-4666-a802-dc1eba8c8b5e    [NULL]  -10.000000   5.0000000
#>  11: e678dc9d-05f2-491b-9f6e-3d7b64e7f564    [NULL]   -7.777778  -5.0000000
#>  12: c4b3981c-8390-40b8-9923-7266dfb4a688    [NULL]   -7.777778  -3.8888889
#>  13: 91b6a9b6-df3a-4875-b821-d9ec4f4a567a    [NULL]   -7.777778  -2.7777778
#>  14: e7d969dd-99b4-42f5-b1df-cae17340b83d    [NULL]   -7.777778  -1.6666667
#>  15: aadbc6e6-d655-4e96-b1dd-6a8acd7b63d9    [NULL]   -7.777778  -0.5555556
#>  16: d55ad610-4004-4e0d-92fa-a8d6a7a90651    [NULL]   -7.777778   0.5555556
#>  17: b8dc4c58-dec7-4688-953b-33a81e459abd    [NULL]   -7.777778   1.6666667
#>  18: 4c14001a-da71-411e-84c4-95ce203ce13d    [NULL]   -7.777778   2.7777778
#>  19: e63c5cbc-20bf-4ce3-8b5d-7d3730b863ea    [NULL]   -7.777778   3.8888889
#>  20: 1f184200-b448-45e4-821a-3f6d854b6329    [NULL]   -7.777778   5.0000000
#>  21: 4d5c4618-2176-4155-8fdf-82f3f306a189 <list[1]>          NA          NA
#>  22: 4e25befd-4f9e-443a-9ac4-b0ab13ac999f <list[1]>          NA          NA
#>  23: fd8545b8-ec22-4e95-bcc5-e5669bd566c9 <list[1]>          NA          NA
#>  24: a3ca8bca-7576-4941-a400-0069276b71d4 <list[1]>          NA          NA
#>  25: 422ad5ea-ebe9-4ace-a241-ce4471a24e64 <list[1]>          NA          NA
#>  26: 9c2f45dc-e92c-47a8-b6ee-341c36657318 <list[1]>          NA          NA
#>  27: 4d362345-65dd-43ac-9b7a-5db7aacde3c3 <list[1]>          NA          NA
#>  28: da4a4e52-a398-48ca-9700-9dc320b9ad5e <list[1]>          NA          NA
#>  29: 23506eb0-d951-4990-802b-afbfa59bfcda <list[1]>          NA          NA
#>  30: 204f2f6c-eb58-4df9-a744-254d36e1cfe6 <list[1]>          NA          NA
#>  31: 0ced94bc-bff4-4d82-9a40-d1c3fe2d83f2 <list[1]>          NA          NA
#>  32: a1108996-f8bd-4839-92e9-d54b3c665fcc <list[1]>          NA          NA
#>  33: 3972069d-bda3-476e-a06e-f125ce625b6c <list[1]>          NA          NA
#>  34: 8dd43b0f-08e5-48a1-9382-d70fb085b59d <list[1]>          NA          NA
#>  35: deb3117b-742b-4b47-a26f-d0aecb65251e <list[1]>          NA          NA
#>  36: 274ae670-589c-4fe4-a536-1fd478f8cee5 <list[1]>          NA          NA
#>  37: b08aa238-dd5e-48ee-b12d-4dbc6eeae79b <list[1]>          NA          NA
#>  38: c0d2d633-84ee-4e16-b450-3d2f8810a12a <list[1]>          NA          NA
#>  39: 91a52558-5c85-4fdf-819a-a23fe8343ba5 <list[1]>          NA          NA
#>  40: 207159c7-e6f3-4a8b-b522-d1a9f3c89f36 <list[1]>          NA          NA
#>  41: ecea0c6e-a161-4f8f-9b2e-6b4228f698c3 <list[1]>          NA          NA
#>  42: 1a782f74-cf00-49f5-b026-09456122f322 <list[1]>          NA          NA
#>  43: 29d1b1d3-2555-451a-8ffc-0f4d0c605331 <list[1]>          NA          NA
#>  44: ae98557b-e63d-46bf-8b81-cc697b1b607c <list[1]>          NA          NA
#>  45: 31aed66b-53de-4aba-ae3d-6785d5c36389 <list[1]>          NA          NA
#>  46: 03ed73e9-4307-4459-8e88-92907cea5cb9 <list[1]>          NA          NA
#>  47: 6f4ba48d-ee2a-43a8-9eda-23dfdfc1db6c <list[1]>          NA          NA
#>  48: 9984cc3c-b17b-4646-9106-060c61bea305 <list[1]>          NA          NA
#>  49: eeb4c8d9-d928-42d0-9f68-6f36b17d7ca4 <list[1]>          NA          NA
#>  50: 186630ed-9751-4e91-9e2b-8e82cf13a06c <list[1]>          NA          NA
#>  51: 29786e09-776d-4507-b209-e9d4ee4bb86a <list[1]>          NA          NA
#>  52: 9e3d69a2-da37-4496-9d08-319aebd942b9 <list[1]>          NA          NA
#>  53: 95590968-8f19-489f-a934-755a9ba7dde7 <list[1]>          NA          NA
#>  54: 22f0fc74-d06f-4fd1-952f-b22fb907c276 <list[1]>          NA          NA
#>  55: c6cb465f-957a-488a-ae38-c319728acda3 <list[1]>          NA          NA
#>  56: d98d2413-c50f-4dad-88f6-0c7454a3c0ab <list[1]>          NA          NA
#>  57: caaa0213-ddb7-4a5a-967d-bc085becf010 <list[1]>          NA          NA
#>  58: a13dbfcf-3143-4a7e-ab25-806dd103aa95 <list[1]>          NA          NA
#>  59: a871307b-7edb-4b3e-8d7b-dc071a13744f <list[1]>          NA          NA
#>  60: c78c2627-ee96-4b64-8476-cf2aa0c7b2a9 <list[1]>          NA          NA
#>  61: 8fa4e800-a506-4175-9879-5e29eea7ca10 <list[1]>          NA          NA
#>  62: 8e526d2a-c90c-4dd0-8fd5-b1c622c3598b <list[1]>          NA          NA
#>  63: cf972ea4-58d4-4627-8407-07e7dd5eea2e <list[1]>          NA          NA
#>  64: 29c9ed2e-e31a-4d4d-b115-017c319d1fc0 <list[1]>          NA          NA
#>  65: e61ce39c-853b-4d26-9aae-7dff75f8f772 <list[1]>          NA          NA
#>  66: fa500e08-e8d9-48fd-94b3-05484823d30b <list[1]>          NA          NA
#>  67: ec52c50b-5fad-416b-9a84-4cd4ed92b414 <list[1]>          NA          NA
#>  68: 1ba16026-cc1f-4d58-9252-51505dbbd456 <list[1]>          NA          NA
#>  69: ffab4f22-7249-4066-b4ce-f042b45aaf4a <list[1]>          NA          NA
#>  70: 3d90a1b1-092e-45a9-9cab-92ea27999d2e <list[1]>          NA          NA
#>  71: 39200d48-0b0f-432e-91d0-5c3fdfb578f7 <list[1]>          NA          NA
#>  72: 5558ef6d-c0af-4ae3-81bd-5bdc5eab16c6 <list[1]>          NA          NA
#>  73: fee25881-538f-4c41-b4f5-f75b1d4134bd <list[1]>          NA          NA
#>  74: afb3f635-2ba3-425b-aed5-2245a8bb2894 <list[1]>          NA          NA
#>  75: b9920ba1-3cde-4f0e-8eef-d209f6cece9a <list[1]>          NA          NA
#>  76: b37ff50b-f7c3-424c-8073-f512cdd94ae4 <list[1]>          NA          NA
#>  77: f55941af-61f6-4c50-b777-e964a7199503 <list[1]>          NA          NA
#>  78: 644d70fb-702c-495b-92c2-28d6f7641cf1 <list[1]>          NA          NA
#>  79: 09d4535a-1ed9-4b97-8b81-e45d834ef2c9 <list[1]>          NA          NA
#>  80: 6df13611-73df-4ac5-8bda-e7a91f3052d1 <list[1]>          NA          NA
#>  81: 7d908e84-888e-4b59-9e03-7a66001b0229 <list[1]>          NA          NA
#>  82: 6e059244-d4dc-48a2-a6ea-66f17c3ecea4 <list[1]>          NA          NA
#>  83: 51852e95-e71f-4854-9f95-94904ef704aa <list[1]>          NA          NA
#>  84: 4ae4faf5-7584-419a-a8fd-c2da38c4c278 <list[1]>          NA          NA
#>  85: 728f77f4-1481-45eb-9535-e857e746ef73 <list[1]>          NA          NA
#>  86: 59179d14-62a2-4672-9ed5-95e38d2f1465 <list[1]>          NA          NA
#>  87: c2bfb135-aacb-4cce-869f-a221a87bfd67 <list[1]>          NA          NA
#>  88: 3898269b-ebfc-4468-b7ea-b6aae464af78 <list[1]>          NA          NA
#>  89: f63aef9b-0a18-44af-9d53-d9362ccae950 <list[1]>          NA          NA
#>  90: 904445d2-6add-4a8a-a0e2-3e114ec6e07d <list[1]>          NA          NA
#>  91: fc432db6-544a-40d8-b8eb-cb600c028804 <list[1]>          NA          NA
#>  92: ad6f87f5-205f-4f31-a0cb-957653e51006 <list[1]>          NA          NA
#>  93: a004c442-d776-4af6-adfe-12a1fb12840e <list[1]>          NA          NA
#>  94: 2b2b662d-160e-4664-88e8-9482b771d0e0 <list[1]>          NA          NA
#>  95: 7c25e602-14c0-4603-a089-0ed9dedeb494 <list[1]>          NA          NA
#>  96: a3c3e4a7-ecff-4f60-9c8d-43aa9078d4a8 <list[1]>          NA          NA
#>  97: 18585e6e-f6be-4ce3-b457-c4a1c328cade <list[1]>          NA          NA
#>  98: df9d09c9-2379-4ba3-a6a9-dce54e3bc9ea <list[1]>          NA          NA
#>  99: 9eed9a30-6b0b-45c6-91d4-d1bdb3b07ff8 <list[1]>          NA          NA
#> 100: fd68755e-648b-4310-b591-7a1fdec95f76 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
