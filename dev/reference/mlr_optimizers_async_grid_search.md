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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-03 11:08:16
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-03 11:08:16
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-03 11:08:16
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-03 11:08:16
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-03 11:08:16
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-03 11:08:16
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-03 11:08:16
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-03 11:08:16
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-03 11:08:16
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-03 11:08:16
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-03 11:08:16
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-03 11:08:16
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-03 11:08:16
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-03 11:08:16
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-03 11:08:16
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-03 11:08:16
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-03 11:08:16
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-03 11:08:16
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-03 11:08:16
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-03 11:08:16
#>  21:   failed  10.000000  5.0000000         NA 2026-09-03 11:08:16
#>  22:   failed  10.000000  3.8888889         NA 2026-09-03 11:08:16
#>  23:   failed  10.000000  2.7777778         NA 2026-09-03 11:08:16
#>  24:   failed  10.000000  1.6666667         NA 2026-09-03 11:08:16
#>  25:   failed  10.000000  0.5555556         NA 2026-09-03 11:08:16
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-03 11:08:16
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-03 11:08:16
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-03 11:08:16
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-03 11:08:16
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-03 11:08:16
#>  31:   failed   7.777778  5.0000000         NA 2026-09-03 11:08:16
#>  32:   failed   7.777778  3.8888889         NA 2026-09-03 11:08:16
#>  33:   failed   7.777778  2.7777778         NA 2026-09-03 11:08:16
#>  34:   failed   7.777778  1.6666667         NA 2026-09-03 11:08:16
#>  35:   failed   7.777778  0.5555556         NA 2026-09-03 11:08:16
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-03 11:08:16
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-03 11:08:16
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-03 11:08:16
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-03 11:08:16
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-03 11:08:16
#>  41:   failed   5.555556  5.0000000         NA 2026-09-03 11:08:16
#>  42:   failed   5.555556  3.8888889         NA 2026-09-03 11:08:16
#>  43:   failed   5.555556  2.7777778         NA 2026-09-03 11:08:16
#>  44:   failed   5.555556  1.6666667         NA 2026-09-03 11:08:16
#>  45:   failed   5.555556  0.5555556         NA 2026-09-03 11:08:16
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-03 11:08:16
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-03 11:08:16
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-03 11:08:16
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-03 11:08:16
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-03 11:08:16
#>  51:   failed   3.333333  5.0000000         NA 2026-09-03 11:08:16
#>  52:   failed   3.333333  3.8888889         NA 2026-09-03 11:08:16
#>  53:   failed   3.333333  2.7777778         NA 2026-09-03 11:08:16
#>  54:   failed   3.333333  1.6666667         NA 2026-09-03 11:08:16
#>  55:   failed   3.333333  0.5555556         NA 2026-09-03 11:08:16
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-03 11:08:16
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-03 11:08:16
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-03 11:08:16
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-03 11:08:16
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-03 11:08:16
#>  61:   failed   1.111111  5.0000000         NA 2026-09-03 11:08:16
#>  62:   failed   1.111111  3.8888889         NA 2026-09-03 11:08:16
#>  63:   failed   1.111111  2.7777778         NA 2026-09-03 11:08:16
#>  64:   failed   1.111111  1.6666667         NA 2026-09-03 11:08:16
#>  65:   failed   1.111111  0.5555556         NA 2026-09-03 11:08:16
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-03 11:08:16
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-03 11:08:16
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-03 11:08:16
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-03 11:08:16
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-03 11:08:16
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-03 11:08:16
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-03 11:08:16
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-03 11:08:16
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-03 11:08:16
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-03 11:08:16
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-03 11:08:16
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-03 11:08:16
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-03 11:08:16
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-03 11:08:16
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-03 11:08:16
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-03 11:08:16
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-03 11:08:16
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-03 11:08:16
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-03 11:08:16
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-03 11:08:16
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-03 11:08:16
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-03 11:08:16
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-03 11:08:16
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-03 11:08:16
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-03 11:08:16
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-03 11:08:16
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-03 11:08:16
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-03 11:08:16
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-03 11:08:16
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-03 11:08:16
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-03 11:08:16
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-03 11:08:16
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-03 11:08:16
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-03 11:08:16
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-03 11:08:16
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>   2: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>   3: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>   4: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>   5: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>   6: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>   7: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>   8: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>   9: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>  10: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>  11: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>  12: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>  13: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>  14: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>  15: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>  16: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>  17: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>  18: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>  19: sinking_raccoon_28a590ae 2026-09-03 11:08:17
#>  20: sinking_raccoon_28a590ae 2026-09-03 11:08:17
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
#>   1: 5799ecb0-7e96-48fc-88b8-316319a765b3    [NULL]  -10.000000  -5.0000000
#>   2: 798e6d80-d9a4-44fa-9482-5d2973396b48    [NULL]  -10.000000  -3.8888889
#>   3: 5ac993d3-c750-4265-87a0-423a456df8bf    [NULL]  -10.000000  -2.7777778
#>   4: 777d52ae-e3e0-456c-bfdb-a90b8408684f    [NULL]  -10.000000  -1.6666667
#>   5: 5528a195-be33-40ab-a5d6-f58f315b43e5    [NULL]  -10.000000  -0.5555556
#>   6: 65a9249a-a22a-4ce4-9bb5-13be9d93d7bd    [NULL]  -10.000000   0.5555556
#>   7: ab6e01ac-01c7-48ad-a331-346290c6135d    [NULL]  -10.000000   1.6666667
#>   8: ce6d97f6-8a3a-4502-a328-3cc553c69227    [NULL]  -10.000000   2.7777778
#>   9: d0233899-fb57-439c-9224-ac1701181c87    [NULL]  -10.000000   3.8888889
#>  10: 03731feb-b7cf-427c-a15d-034b48e27137    [NULL]  -10.000000   5.0000000
#>  11: 98f3fcc2-68d8-4501-9f2b-6fa910867b75    [NULL]   -7.777778  -5.0000000
#>  12: 9431e0a6-b2d2-4421-934b-1f5a2f795775    [NULL]   -7.777778  -3.8888889
#>  13: 8f777507-537c-49ec-8568-fb8616400da8    [NULL]   -7.777778  -2.7777778
#>  14: 7a16ce6c-1a03-4e06-8e78-dafe32f5cac1    [NULL]   -7.777778  -1.6666667
#>  15: c8e547ed-7667-40bc-9c1a-22ee37f3f2bc    [NULL]   -7.777778  -0.5555556
#>  16: 918cb707-bdf2-435d-a0ec-274f6d172877    [NULL]   -7.777778   0.5555556
#>  17: fe57f08c-6651-4168-ae19-eb3d10842790    [NULL]   -7.777778   1.6666667
#>  18: 24132f19-0e6a-4109-b51a-23396f428cd8    [NULL]   -7.777778   2.7777778
#>  19: 2c97f8ab-b576-463b-a4f8-a2dcbffd1c7e    [NULL]   -7.777778   3.8888889
#>  20: c3a206c6-c30c-4c60-b4ef-029d44110c07    [NULL]   -7.777778   5.0000000
#>  21: cf279716-3d0c-429f-9ec0-52e1259ec0d4 <list[1]>          NA          NA
#>  22: f5aa0d5e-80aa-4720-b96b-75e4cf53915f <list[1]>          NA          NA
#>  23: 80ef8098-5db3-4abd-83c6-bced7f51937f <list[1]>          NA          NA
#>  24: 122c333c-6a53-45a4-86df-b2f60ac6fe97 <list[1]>          NA          NA
#>  25: 4b811ac2-489b-40fb-a852-00aa570ca292 <list[1]>          NA          NA
#>  26: 457d08cd-7934-439f-806e-247fb85ff943 <list[1]>          NA          NA
#>  27: acbe42dc-a0b7-4033-b9b4-e53d8ed4d8ce <list[1]>          NA          NA
#>  28: 3fdb8cb7-926e-4c2b-bcc1-20fe0edd2d41 <list[1]>          NA          NA
#>  29: cbc5eeb9-b800-4614-8506-59d92c803db1 <list[1]>          NA          NA
#>  30: 8e10fc18-380f-42ea-8bd2-ff7faa14e763 <list[1]>          NA          NA
#>  31: a31e8bfd-7057-4aba-9610-939da8644731 <list[1]>          NA          NA
#>  32: ffd23731-5bad-42cf-97ed-89b9e7a8859c <list[1]>          NA          NA
#>  33: 19f9e721-41c5-4a99-8773-acf205a0f67b <list[1]>          NA          NA
#>  34: afc9ae34-9b25-470a-84da-d75d6fa8e363 <list[1]>          NA          NA
#>  35: a4e04542-03e4-4fb4-82aa-4776bdb0dea9 <list[1]>          NA          NA
#>  36: edb103e2-fcf9-44e4-8b6d-4c87c2bf63ee <list[1]>          NA          NA
#>  37: d6270bc5-4382-4f7e-b27a-e2243c94c705 <list[1]>          NA          NA
#>  38: c77285ef-1af6-450c-8268-e19c5b6d056d <list[1]>          NA          NA
#>  39: e60f5933-80b7-4bcb-9a17-043c6f1fc95d <list[1]>          NA          NA
#>  40: 6d59f28c-0633-425f-9f05-441ff29d3b16 <list[1]>          NA          NA
#>  41: 0ef8d03d-c28e-4df0-af69-b80349da0165 <list[1]>          NA          NA
#>  42: b95d28f5-7f34-4103-8424-c0335be75b65 <list[1]>          NA          NA
#>  43: 69d00bcc-2d7d-4aa2-9c42-157c81284bff <list[1]>          NA          NA
#>  44: 64a166ed-dcbf-4f8c-90e2-ea034c7cac7b <list[1]>          NA          NA
#>  45: bcc1fcd4-c8f9-4616-83e3-fec0a26e06bc <list[1]>          NA          NA
#>  46: f8d2acf9-110a-43c2-954e-e27199593d96 <list[1]>          NA          NA
#>  47: 569c94b6-4264-4faa-983b-f559f9e866eb <list[1]>          NA          NA
#>  48: 00c3d8d4-32e5-456f-9800-43db0b2dc436 <list[1]>          NA          NA
#>  49: 5e859d1a-4d8a-4c51-a3dd-76a1ac273608 <list[1]>          NA          NA
#>  50: 091e71fe-47d3-41af-a6dd-acdebcf73ac8 <list[1]>          NA          NA
#>  51: 30409185-71bc-41fc-892a-f3848d8540ea <list[1]>          NA          NA
#>  52: 62b36dc5-59b0-4729-b46d-16968b2e1873 <list[1]>          NA          NA
#>  53: 71e9031f-4e12-4f78-864a-d923bde31208 <list[1]>          NA          NA
#>  54: db957470-75cd-4e1b-812e-8d668ca72ec0 <list[1]>          NA          NA
#>  55: bebd8ea3-7c98-4832-ad26-43bf6101f4de <list[1]>          NA          NA
#>  56: 7202b197-289b-4d21-9b0f-64d2f4b1da6d <list[1]>          NA          NA
#>  57: f2fdb9cf-0db7-4aa3-820a-dcfff04695f5 <list[1]>          NA          NA
#>  58: 72d58308-1f98-485a-b1de-861adecfc1d9 <list[1]>          NA          NA
#>  59: d1f0f091-834d-4d3e-b02e-62550d3967e1 <list[1]>          NA          NA
#>  60: 440e61a7-b418-4f2c-a1c0-b7c4a34942d1 <list[1]>          NA          NA
#>  61: b31e13a7-52ce-4b4c-a4ad-00bb2f97da4e <list[1]>          NA          NA
#>  62: 703e38fe-41b6-41e6-acf4-db3bfac50966 <list[1]>          NA          NA
#>  63: 0f6789fc-f06d-4037-b15f-c381a4db7097 <list[1]>          NA          NA
#>  64: 01eaa68c-1164-4055-b78a-6d41da60459c <list[1]>          NA          NA
#>  65: 6419cb85-2402-4f3f-bfb8-08fd13290fdf <list[1]>          NA          NA
#>  66: dd38b490-f8af-4146-b122-a64de536fdc8 <list[1]>          NA          NA
#>  67: 9f95c556-a616-4433-b549-e1e2d1ec208e <list[1]>          NA          NA
#>  68: 3119d581-3d52-4725-a003-870b0cbea0e0 <list[1]>          NA          NA
#>  69: 410391c8-ed24-4f01-a0a4-d4f30cd2f67b <list[1]>          NA          NA
#>  70: eeb6fd9b-711a-4438-aafa-0c4b5e80ccc2 <list[1]>          NA          NA
#>  71: ff64ae1a-2087-4a88-8df4-b11e970875e4 <list[1]>          NA          NA
#>  72: d3be5642-a346-4523-a8eb-99eb4c903b28 <list[1]>          NA          NA
#>  73: 391aaef2-3749-441b-ab4b-f98d0125f314 <list[1]>          NA          NA
#>  74: 6deb9d7a-d35c-44c6-a81c-a99da896adb7 <list[1]>          NA          NA
#>  75: 69d92712-6d22-45f6-8e4e-401d5cfea092 <list[1]>          NA          NA
#>  76: 89c6e9d9-34ea-4db0-9455-aaa1cdf96784 <list[1]>          NA          NA
#>  77: 5d06f853-7427-449b-9be2-aeea0321d0c7 <list[1]>          NA          NA
#>  78: 06ab1258-f6fb-4f77-993d-bad620c92dfd <list[1]>          NA          NA
#>  79: c02d6d53-25f7-48ea-89f0-24a5ec992a4d <list[1]>          NA          NA
#>  80: 85ae56d5-3eb1-4cb7-89e7-20bfdc23fa20 <list[1]>          NA          NA
#>  81: 8fa88662-05b9-4320-9297-c566b158a01f <list[1]>          NA          NA
#>  82: dfd6f83f-d2a8-4eca-87f8-54dd2998e67f <list[1]>          NA          NA
#>  83: 9c98483c-1ace-4cc7-b748-732960172117 <list[1]>          NA          NA
#>  84: bf17494a-608b-44c4-bd5f-9314e5cc1e70 <list[1]>          NA          NA
#>  85: e929403a-ce6a-4e8d-93df-4b90b6cb2289 <list[1]>          NA          NA
#>  86: a03ad1eb-a1db-4b60-b97f-e6dd13b7ae9a <list[1]>          NA          NA
#>  87: f8ebcdaa-dccb-4658-b6d8-ac742195564a <list[1]>          NA          NA
#>  88: f3225926-3e24-42dc-8d90-e73eacddc34a <list[1]>          NA          NA
#>  89: 905c22a7-3945-4256-a912-da2966fc7fde <list[1]>          NA          NA
#>  90: 63f3436c-39be-44a9-af56-c6230c17fbaf <list[1]>          NA          NA
#>  91: 2527fb02-98a6-4808-8ef7-1a1b4cdcce5f <list[1]>          NA          NA
#>  92: 43bc57c8-e001-4ef6-9278-fab6638e4f33 <list[1]>          NA          NA
#>  93: 4a589eb5-ea93-4297-b06b-225acbe3691b <list[1]>          NA          NA
#>  94: 7d3ff2e8-22d4-41fb-9125-ad1c96a3cae6 <list[1]>          NA          NA
#>  95: a3866c95-9e48-432f-b1f3-054b70bbc45b <list[1]>          NA          NA
#>  96: fa16de1d-41ee-4402-8c0f-45d68cb64094 <list[1]>          NA          NA
#>  97: ee058511-8ad0-4d00-8215-b0bc01b8d05b <list[1]>          NA          NA
#>  98: 700f528a-c3da-4b49-acfc-b06282e5becd <list[1]>          NA          NA
#>  99: 49e59594-6cf2-4a80-bca3-6a3eea6724e6 <list[1]>          NA          NA
#> 100: 41aeb9a0-eb82-4b53-8c9d-60575493bef1 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
