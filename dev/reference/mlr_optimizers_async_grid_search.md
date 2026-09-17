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
#>   1: finished sinking_raccoon_91bc3ef2 -10.000000 -5.0000000 -138.00000
#>   2: finished sinking_raccoon_91bc3ef2 -10.000000 -3.8888889 -134.79012
#>   3: finished sinking_raccoon_91bc3ef2 -10.000000 -2.7777778 -134.04938
#>   4: finished sinking_raccoon_91bc3ef2 -10.000000 -1.6666667 -135.77778
#>   5: finished sinking_raccoon_91bc3ef2 -10.000000 -0.5555556 -139.97531
#>   6: finished sinking_raccoon_91bc3ef2 -10.000000  0.5555556 -146.64198
#>   7: finished sinking_raccoon_91bc3ef2 -10.000000  1.6666667 -155.77778
#>   8: finished sinking_raccoon_91bc3ef2 -10.000000  2.7777778 -167.38272
#>   9: finished sinking_raccoon_91bc3ef2 -10.000000  3.8888889 -181.45679
#>  10: finished sinking_raccoon_91bc3ef2 -10.000000  5.0000000 -198.00000
#>  11: finished sinking_raccoon_91bc3ef2  -7.777778 -5.0000000  -89.60494
#>  12: finished sinking_raccoon_91bc3ef2  -7.777778 -3.8888889  -86.39506
#>  13: finished sinking_raccoon_91bc3ef2  -7.777778 -2.7777778  -85.65432
#>  14: finished sinking_raccoon_91bc3ef2  -7.777778 -1.6666667  -87.38272
#>  15: finished sinking_raccoon_91bc3ef2  -7.777778 -0.5555556  -91.58025
#>  16: finished sinking_raccoon_91bc3ef2  -7.777778  0.5555556  -98.24691
#>  17: finished sinking_raccoon_91bc3ef2  -7.777778  1.6666667 -107.38272
#>  18: finished sinking_raccoon_91bc3ef2  -7.777778  2.7777778 -118.98765
#>  19: finished sinking_raccoon_91bc3ef2  -7.777778  3.8888889 -133.06173
#>  20: finished sinking_raccoon_91bc3ef2  -7.777778  5.0000000 -149.60494
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
#>   1: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>   2: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>   3: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>   4: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>   5: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>   6: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>   7: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>   8: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>   9: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>  10: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>  11: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>  12: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>  13: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>  14: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>  15: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>  16: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>  17: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>  18: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>  19: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>  20: 2026-09-17 12:33:43 2026-09-17 12:33:44
#>  21: 2026-09-17 12:33:43                <NA>
#>  22: 2026-09-17 12:33:43                <NA>
#>  23: 2026-09-17 12:33:43                <NA>
#>  24: 2026-09-17 12:33:43                <NA>
#>  25: 2026-09-17 12:33:43                <NA>
#>  26: 2026-09-17 12:33:43                <NA>
#>  27: 2026-09-17 12:33:43                <NA>
#>  28: 2026-09-17 12:33:43                <NA>
#>  29: 2026-09-17 12:33:43                <NA>
#>  30: 2026-09-17 12:33:43                <NA>
#>  31: 2026-09-17 12:33:43                <NA>
#>  32: 2026-09-17 12:33:43                <NA>
#>  33: 2026-09-17 12:33:43                <NA>
#>  34: 2026-09-17 12:33:43                <NA>
#>  35: 2026-09-17 12:33:43                <NA>
#>  36: 2026-09-17 12:33:43                <NA>
#>  37: 2026-09-17 12:33:43                <NA>
#>  38: 2026-09-17 12:33:43                <NA>
#>  39: 2026-09-17 12:33:43                <NA>
#>  40: 2026-09-17 12:33:43                <NA>
#>  41: 2026-09-17 12:33:43                <NA>
#>  42: 2026-09-17 12:33:43                <NA>
#>  43: 2026-09-17 12:33:43                <NA>
#>  44: 2026-09-17 12:33:43                <NA>
#>  45: 2026-09-17 12:33:43                <NA>
#>  46: 2026-09-17 12:33:43                <NA>
#>  47: 2026-09-17 12:33:43                <NA>
#>  48: 2026-09-17 12:33:43                <NA>
#>  49: 2026-09-17 12:33:43                <NA>
#>  50: 2026-09-17 12:33:43                <NA>
#>  51: 2026-09-17 12:33:43                <NA>
#>  52: 2026-09-17 12:33:43                <NA>
#>  53: 2026-09-17 12:33:43                <NA>
#>  54: 2026-09-17 12:33:43                <NA>
#>  55: 2026-09-17 12:33:43                <NA>
#>  56: 2026-09-17 12:33:43                <NA>
#>  57: 2026-09-17 12:33:43                <NA>
#>  58: 2026-09-17 12:33:43                <NA>
#>  59: 2026-09-17 12:33:43                <NA>
#>  60: 2026-09-17 12:33:43                <NA>
#>  61: 2026-09-17 12:33:43                <NA>
#>  62: 2026-09-17 12:33:43                <NA>
#>  63: 2026-09-17 12:33:43                <NA>
#>  64: 2026-09-17 12:33:43                <NA>
#>  65: 2026-09-17 12:33:43                <NA>
#>  66: 2026-09-17 12:33:43                <NA>
#>  67: 2026-09-17 12:33:43                <NA>
#>  68: 2026-09-17 12:33:43                <NA>
#>  69: 2026-09-17 12:33:43                <NA>
#>  70: 2026-09-17 12:33:43                <NA>
#>  71: 2026-09-17 12:33:43                <NA>
#>  72: 2026-09-17 12:33:43                <NA>
#>  73: 2026-09-17 12:33:43                <NA>
#>  74: 2026-09-17 12:33:43                <NA>
#>  75: 2026-09-17 12:33:43                <NA>
#>  76: 2026-09-17 12:33:43                <NA>
#>  77: 2026-09-17 12:33:43                <NA>
#>  78: 2026-09-17 12:33:43                <NA>
#>  79: 2026-09-17 12:33:43                <NA>
#>  80: 2026-09-17 12:33:43                <NA>
#>  81: 2026-09-17 12:33:43                <NA>
#>  82: 2026-09-17 12:33:43                <NA>
#>  83: 2026-09-17 12:33:43                <NA>
#>  84: 2026-09-17 12:33:43                <NA>
#>  85: 2026-09-17 12:33:43                <NA>
#>  86: 2026-09-17 12:33:43                <NA>
#>  87: 2026-09-17 12:33:43                <NA>
#>  88: 2026-09-17 12:33:43                <NA>
#>  89: 2026-09-17 12:33:43                <NA>
#>  90: 2026-09-17 12:33:43                <NA>
#>  91: 2026-09-17 12:33:43                <NA>
#>  92: 2026-09-17 12:33:43                <NA>
#>  93: 2026-09-17 12:33:43                <NA>
#>  94: 2026-09-17 12:33:43                <NA>
#>  95: 2026-09-17 12:33:43                <NA>
#>  96: 2026-09-17 12:33:43                <NA>
#>  97: 2026-09-17 12:33:43                <NA>
#>  98: 2026-09-17 12:33:43                <NA>
#>  99: 2026-09-17 12:33:43                <NA>
#> 100: 2026-09-17 12:33:43                <NA>
#>             timestamp_xs        timestamp_ys
#>                   <POSc>              <POSc>
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
#>   1: ac30c726-2126-478f-b925-80cced38a10d    [NULL]  -10.000000  -5.0000000
#>   2: 52428105-5495-4c9f-b67a-a9dd403daba6    [NULL]  -10.000000  -3.8888889
#>   3: f6cfeaf4-b147-46da-be22-ac86085d8d7c    [NULL]  -10.000000  -2.7777778
#>   4: 758e3468-ae13-4027-8951-046090e4c26e    [NULL]  -10.000000  -1.6666667
#>   5: b7956c67-601c-420c-8cfe-cc925f9ba5b8    [NULL]  -10.000000  -0.5555556
#>   6: 1cc34842-79e6-4279-84f2-1dafff4e4854    [NULL]  -10.000000   0.5555556
#>   7: 22208ca2-5378-4353-bb9d-0f5ea50b0fe2    [NULL]  -10.000000   1.6666667
#>   8: c038e1ab-329b-405b-a8d4-9699672ff83c    [NULL]  -10.000000   2.7777778
#>   9: adbe8bf3-9d3c-4b29-b638-77519b87c960    [NULL]  -10.000000   3.8888889
#>  10: dd12a241-344c-4c68-9028-5651840100bd    [NULL]  -10.000000   5.0000000
#>  11: 728d038a-f7ff-4264-b694-76a079b120fe    [NULL]   -7.777778  -5.0000000
#>  12: 8c146a56-d8ed-466d-bf8a-7acb5d5733b5    [NULL]   -7.777778  -3.8888889
#>  13: 83d87ca5-7f5a-4dee-bda5-d09a2c8c8377    [NULL]   -7.777778  -2.7777778
#>  14: e1783797-d3e5-48c1-a72c-97be3b59f891    [NULL]   -7.777778  -1.6666667
#>  15: 5a8b6a5a-998b-4245-b6de-24abbcc62c8d    [NULL]   -7.777778  -0.5555556
#>  16: 47e06813-2356-470e-b556-08c4dcd77564    [NULL]   -7.777778   0.5555556
#>  17: d2452b64-cb8f-4dfe-9ca1-9c48e564cf14    [NULL]   -7.777778   1.6666667
#>  18: 9b56cd5d-a8c6-4e8c-b033-842de9a7b47f    [NULL]   -7.777778   2.7777778
#>  19: f61e6869-4345-474e-8606-4e5968c03557    [NULL]   -7.777778   3.8888889
#>  20: 696f2d18-1c11-4d1e-8edc-5a04a1f00dd0    [NULL]   -7.777778   5.0000000
#>  21: 769035ee-deb5-4b8a-bfad-968b5a71d9e0 <list[1]>          NA          NA
#>  22: c7878407-41bb-41a3-b698-adc21e578882 <list[1]>          NA          NA
#>  23: a1eeac0d-0093-4d68-8115-f511655aef7c <list[1]>          NA          NA
#>  24: a06ff5cf-35c4-4eb4-8288-d178132c650b <list[1]>          NA          NA
#>  25: 6dd4b532-eca7-411d-9890-cc02bbf88d56 <list[1]>          NA          NA
#>  26: aaba1477-1831-42b2-8937-ab83c0b5b8d7 <list[1]>          NA          NA
#>  27: 240374a4-1256-4c87-bf2f-b460c7673996 <list[1]>          NA          NA
#>  28: 01387e58-11cd-4a10-a427-c5c8a0d3472f <list[1]>          NA          NA
#>  29: d8fe4dbf-6007-41d8-b6e5-802736031910 <list[1]>          NA          NA
#>  30: 2f788605-6c5f-4b6e-b897-322cb76d42ac <list[1]>          NA          NA
#>  31: c7367ede-c53a-480a-9c31-40f4ddccbeff <list[1]>          NA          NA
#>  32: ab9e07c9-c061-4391-8113-45a70f101632 <list[1]>          NA          NA
#>  33: ce22fed0-e192-45e7-96d3-64ec7129e31a <list[1]>          NA          NA
#>  34: b5dd9985-6ec6-4840-a7d5-4b5319a485cc <list[1]>          NA          NA
#>  35: a77bf14a-4ed3-4392-8fb4-ad9108f3fd9e <list[1]>          NA          NA
#>  36: 0919a81b-599e-4393-a62a-ddc5a963f82a <list[1]>          NA          NA
#>  37: d74d2cc1-540a-4673-a9e7-db9979d67866 <list[1]>          NA          NA
#>  38: f1eda7b7-0465-4824-906a-d2a02b4eb940 <list[1]>          NA          NA
#>  39: 59c53373-1387-41d9-90de-26b1c532ca4e <list[1]>          NA          NA
#>  40: f6c45b2f-250e-4722-bfcd-7b8130a37872 <list[1]>          NA          NA
#>  41: 08153d18-9b26-4e1a-bb04-dfdcbbf09acb <list[1]>          NA          NA
#>  42: 0fe60de8-69fc-4ae8-94ec-ae1f00febadb <list[1]>          NA          NA
#>  43: e1526dba-dca6-429c-b9d9-387b197c7ac0 <list[1]>          NA          NA
#>  44: c1b3e209-c252-40e2-ab2c-b45fb15d1c7c <list[1]>          NA          NA
#>  45: f50d3061-9917-47a9-a908-82de885083cc <list[1]>          NA          NA
#>  46: e600dbcf-ada6-486a-97c2-f49aec85f8d8 <list[1]>          NA          NA
#>  47: f0d255b0-125a-4a1b-95ff-263828bd9feb <list[1]>          NA          NA
#>  48: ef45b6cb-977c-48b7-9254-4ed65f576a8a <list[1]>          NA          NA
#>  49: 27e53d0e-f82b-47a9-9efb-d18f9fd8d8c0 <list[1]>          NA          NA
#>  50: 2c5ccfdf-2165-4946-a5cf-f0647f6d0066 <list[1]>          NA          NA
#>  51: 7b8a8048-99c4-4079-81b8-a39db1fd0e29 <list[1]>          NA          NA
#>  52: a4e6dfe8-3aa3-42eb-a79a-08d701ef1d96 <list[1]>          NA          NA
#>  53: 7278c561-7247-435f-8f77-b63d55ed7421 <list[1]>          NA          NA
#>  54: 3cb4f58d-bbeb-4510-a1ee-8ff26e92d91f <list[1]>          NA          NA
#>  55: 1e2e32b9-dff6-4999-b191-29fd16719d16 <list[1]>          NA          NA
#>  56: ce2608b1-e510-47a9-aa46-28a877c18485 <list[1]>          NA          NA
#>  57: 38e91faa-20a8-4d6c-b46b-17ffcecc1f6b <list[1]>          NA          NA
#>  58: 1417616c-10e2-4d5c-9057-403c17244c1f <list[1]>          NA          NA
#>  59: 66bf5b84-89ac-4a07-86ba-d35c08aebfd7 <list[1]>          NA          NA
#>  60: eebf88d8-63d7-4390-9a2a-0eb74200995d <list[1]>          NA          NA
#>  61: fd7539a4-fa6f-46f0-a489-9602cbb18f5e <list[1]>          NA          NA
#>  62: 30427882-cafa-4d4f-8bfa-e37c86e69c41 <list[1]>          NA          NA
#>  63: 3e40028f-82d8-40be-b9fa-f1a2ead6c1ac <list[1]>          NA          NA
#>  64: 3b7e3705-14ae-4a78-a0aa-fcb6cf7be422 <list[1]>          NA          NA
#>  65: 66ec4d5c-b754-4a58-8b55-e8efe70120dd <list[1]>          NA          NA
#>  66: b7568926-4fc5-4727-a7ae-7e84d293308f <list[1]>          NA          NA
#>  67: 1c84dfcf-6504-4c62-bc2f-126719c837a7 <list[1]>          NA          NA
#>  68: d142e547-935d-4ea7-ba53-b6fdb5d39bc3 <list[1]>          NA          NA
#>  69: f91c0029-dc0a-4a5c-9a33-664b4b8e9f1a <list[1]>          NA          NA
#>  70: 76a56790-da13-4213-b53d-a6aafc37abf9 <list[1]>          NA          NA
#>  71: 3b40415e-4e7c-4577-9039-73e06601fd74 <list[1]>          NA          NA
#>  72: 51a1e32e-48a4-4004-bcde-b20852290830 <list[1]>          NA          NA
#>  73: 8600c1ab-1759-4fa6-a0d4-2ca5b329d054 <list[1]>          NA          NA
#>  74: c8b689aa-7140-492a-b1ee-27f763966bd7 <list[1]>          NA          NA
#>  75: b6465992-fe56-444d-a620-a4fbb8f4679f <list[1]>          NA          NA
#>  76: 4490e6a2-120b-4c0e-9fc3-ba27fd6c0802 <list[1]>          NA          NA
#>  77: aa69defd-604e-49b2-ba54-1b92a453994c <list[1]>          NA          NA
#>  78: c584eda0-36e1-4471-a5d1-c748e1e12710 <list[1]>          NA          NA
#>  79: 291daea1-815d-48b8-940b-ab1d7c37e843 <list[1]>          NA          NA
#>  80: 0caddf29-f09e-4e78-bdf0-3875aec86c7d <list[1]>          NA          NA
#>  81: 054b849d-4fb0-47fb-ba5f-b135e52aaa2f <list[1]>          NA          NA
#>  82: e4ce1245-2083-4376-8054-69f99966214e <list[1]>          NA          NA
#>  83: a32f664f-3e66-435c-9b5e-a7863f207175 <list[1]>          NA          NA
#>  84: 4113fe32-cada-4156-b441-7b0111b69a9c <list[1]>          NA          NA
#>  85: d156e57f-54e0-444d-b086-9b82dbcf9917 <list[1]>          NA          NA
#>  86: 65140824-e2aa-4128-bd6d-afddf05e3919 <list[1]>          NA          NA
#>  87: a5e18075-3432-4268-91ff-ab209ee31a41 <list[1]>          NA          NA
#>  88: bdf1378c-a2d8-42d5-a1f4-0c50f2689e0c <list[1]>          NA          NA
#>  89: 79c2b85a-5bf8-493b-8e8f-b5636eff04fa <list[1]>          NA          NA
#>  90: 6e7bff69-a098-4611-9710-fa73bbea66c4 <list[1]>          NA          NA
#>  91: 00cc2710-a669-46a5-a53b-61e7eee98e5b <list[1]>          NA          NA
#>  92: 69b03354-9778-4a20-8c67-ad56b69a17e6 <list[1]>          NA          NA
#>  93: 8386a7b3-720a-4fdf-96dd-b14f1d5aafa6 <list[1]>          NA          NA
#>  94: cf58ad11-f2ef-43c9-a7f0-133df0564077 <list[1]>          NA          NA
#>  95: b5fb641c-08ac-4a62-af75-2ff060b26f62 <list[1]>          NA          NA
#>  96: 4397d2cf-4d86-468c-9331-8e9998cb8d72 <list[1]>          NA          NA
#>  97: f888018b-d2b9-4962-9f74-606acf31cfc7 <list[1]>          NA          NA
#>  98: f281f8dc-c2e2-44c0-9f75-28c2b60280fc <list[1]>          NA          NA
#>  99: a202d9fc-e8bf-4359-acc5-aa60c9dc8ed2 <list[1]>          NA          NA
#> 100: 7da6c7bc-3b3f-4e60-8ce0-a08926ef3004 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
