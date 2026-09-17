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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-17 09:27:13
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-17 09:27:13
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-17 09:27:13
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-17 09:27:13
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-17 09:27:13
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-17 09:27:13
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-17 09:27:13
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-17 09:27:13
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-17 09:27:13
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-17 09:27:13
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-17 09:27:13
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-17 09:27:13
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-17 09:27:13
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-17 09:27:13
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-17 09:27:13
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-17 09:27:13
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-17 09:27:13
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-17 09:27:13
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-17 09:27:13
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-17 09:27:13
#>  21:   failed  10.000000  5.0000000         NA 2026-09-17 09:27:13
#>  22:   failed  10.000000  3.8888889         NA 2026-09-17 09:27:13
#>  23:   failed  10.000000  2.7777778         NA 2026-09-17 09:27:13
#>  24:   failed  10.000000  1.6666667         NA 2026-09-17 09:27:13
#>  25:   failed  10.000000  0.5555556         NA 2026-09-17 09:27:13
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-17 09:27:13
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-17 09:27:13
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-17 09:27:13
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-17 09:27:13
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-17 09:27:13
#>  31:   failed   7.777778  5.0000000         NA 2026-09-17 09:27:13
#>  32:   failed   7.777778  3.8888889         NA 2026-09-17 09:27:13
#>  33:   failed   7.777778  2.7777778         NA 2026-09-17 09:27:13
#>  34:   failed   7.777778  1.6666667         NA 2026-09-17 09:27:13
#>  35:   failed   7.777778  0.5555556         NA 2026-09-17 09:27:13
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-17 09:27:13
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-17 09:27:13
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-17 09:27:13
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-17 09:27:13
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-17 09:27:13
#>  41:   failed   5.555556  5.0000000         NA 2026-09-17 09:27:13
#>  42:   failed   5.555556  3.8888889         NA 2026-09-17 09:27:13
#>  43:   failed   5.555556  2.7777778         NA 2026-09-17 09:27:13
#>  44:   failed   5.555556  1.6666667         NA 2026-09-17 09:27:13
#>  45:   failed   5.555556  0.5555556         NA 2026-09-17 09:27:13
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-17 09:27:13
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-17 09:27:13
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-17 09:27:13
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-17 09:27:13
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-17 09:27:13
#>  51:   failed   3.333333  5.0000000         NA 2026-09-17 09:27:13
#>  52:   failed   3.333333  3.8888889         NA 2026-09-17 09:27:13
#>  53:   failed   3.333333  2.7777778         NA 2026-09-17 09:27:13
#>  54:   failed   3.333333  1.6666667         NA 2026-09-17 09:27:13
#>  55:   failed   3.333333  0.5555556         NA 2026-09-17 09:27:13
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-17 09:27:13
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-17 09:27:13
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-17 09:27:13
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-17 09:27:13
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-17 09:27:13
#>  61:   failed   1.111111  5.0000000         NA 2026-09-17 09:27:13
#>  62:   failed   1.111111  3.8888889         NA 2026-09-17 09:27:13
#>  63:   failed   1.111111  2.7777778         NA 2026-09-17 09:27:13
#>  64:   failed   1.111111  1.6666667         NA 2026-09-17 09:27:13
#>  65:   failed   1.111111  0.5555556         NA 2026-09-17 09:27:13
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-17 09:27:13
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-17 09:27:13
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-17 09:27:13
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-17 09:27:13
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-17 09:27:13
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-17 09:27:13
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-17 09:27:13
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-17 09:27:13
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-17 09:27:13
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-17 09:27:13
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-17 09:27:13
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-17 09:27:13
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-17 09:27:13
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-17 09:27:13
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-17 09:27:13
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-17 09:27:13
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-17 09:27:13
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-17 09:27:13
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-17 09:27:13
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-17 09:27:13
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-17 09:27:13
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-17 09:27:13
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-17 09:27:13
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-17 09:27:13
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-17 09:27:13
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-17 09:27:13
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-17 09:27:13
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-17 09:27:13
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-17 09:27:13
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-17 09:27:13
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-17 09:27:13
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-17 09:27:13
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-17 09:27:13
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-17 09:27:13
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-17 09:27:13
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>   2: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>   3: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>   4: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>   5: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>   6: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>   7: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>   8: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>   9: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>  10: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>  11: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>  12: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>  13: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>  14: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>  15: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>  16: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>  17: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>  18: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>  19: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
#>  20: sinking_raccoon_b1ea0fbd 2026-09-17 09:27:14
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
#>   1: b07f1f84-1c0f-499d-baa1-850d5bd75689    [NULL]  -10.000000  -5.0000000
#>   2: 65ad9862-4682-425f-96c4-592def3e1771    [NULL]  -10.000000  -3.8888889
#>   3: 78ba256f-677b-4cb7-8e4c-762a2ff557a2    [NULL]  -10.000000  -2.7777778
#>   4: 4735bf4d-3f6e-4108-9c5d-29da6803f561    [NULL]  -10.000000  -1.6666667
#>   5: 2c2fdd00-da78-4d72-ad06-fcdec2be102d    [NULL]  -10.000000  -0.5555556
#>   6: 7944bb63-0b2f-4502-b6b1-da98ff39d748    [NULL]  -10.000000   0.5555556
#>   7: 3cf92dff-b1ce-485c-9733-21dcb86279e6    [NULL]  -10.000000   1.6666667
#>   8: 2b14d828-8c95-4b0c-a3cd-a2ad71764f70    [NULL]  -10.000000   2.7777778
#>   9: a4693da6-9336-4fb9-b869-54293831a2a5    [NULL]  -10.000000   3.8888889
#>  10: f067e510-7804-44ca-8558-57d800bc4177    [NULL]  -10.000000   5.0000000
#>  11: 16a0d3b8-a01c-438c-aa93-bb0ae3c30cbe    [NULL]   -7.777778  -5.0000000
#>  12: 885e341d-aca8-43ca-895a-3bfb85139110    [NULL]   -7.777778  -3.8888889
#>  13: 5ec64302-c763-48b9-a92d-ac4962304920    [NULL]   -7.777778  -2.7777778
#>  14: da70de79-27de-45f1-8c02-9169563c9877    [NULL]   -7.777778  -1.6666667
#>  15: 628b42ea-078e-4e78-ba6a-c5ff07bf72fb    [NULL]   -7.777778  -0.5555556
#>  16: c63db71f-36c3-4f07-94a0-c89416c24ca6    [NULL]   -7.777778   0.5555556
#>  17: d7db3a33-b8e4-4610-9626-871ca5fd75fa    [NULL]   -7.777778   1.6666667
#>  18: 732dc43e-17ac-44d8-966f-cfb78f5474e3    [NULL]   -7.777778   2.7777778
#>  19: 5cab5499-c39d-4a2f-85da-ec2b248fb2da    [NULL]   -7.777778   3.8888889
#>  20: f0ea0e60-e280-423f-baa2-a3d280fa19af    [NULL]   -7.777778   5.0000000
#>  21: acb22504-1ba1-4ea5-8bc9-497207290baf <list[1]>          NA          NA
#>  22: 43437f44-ef69-4736-82de-7994f0e1be30 <list[1]>          NA          NA
#>  23: 7ef97f5c-a35e-4c3f-a748-20aaaf0f9862 <list[1]>          NA          NA
#>  24: e3bc3418-a7fe-4862-8bab-1f22ad92bfbb <list[1]>          NA          NA
#>  25: b9c8876c-6fb6-4efa-bd36-605378c85994 <list[1]>          NA          NA
#>  26: a660e24b-2e9a-45e9-8330-c6125d289452 <list[1]>          NA          NA
#>  27: e1780c86-c92f-4840-a8c3-770a69c98d50 <list[1]>          NA          NA
#>  28: 2abda9b9-69fe-41a8-869c-645cc989706e <list[1]>          NA          NA
#>  29: d9f53a71-aae3-4a74-b9cc-2778fe5fa805 <list[1]>          NA          NA
#>  30: be9a1eaf-3481-4119-a625-e1c4eecd88df <list[1]>          NA          NA
#>  31: aa32562c-71da-4bd1-b500-b4f9288fe5ef <list[1]>          NA          NA
#>  32: 2d0582b1-0000-4e77-963a-50f80f2cc885 <list[1]>          NA          NA
#>  33: b6395358-ba9a-4bd5-9160-54fb8485aae1 <list[1]>          NA          NA
#>  34: 299acb8d-dd0c-43f3-8f52-140580c51e75 <list[1]>          NA          NA
#>  35: 39de7b6b-ae45-47d2-b928-a0cf80af8a44 <list[1]>          NA          NA
#>  36: c7b2b448-d552-4bc2-b830-13f933b48841 <list[1]>          NA          NA
#>  37: 24aaf257-faa5-46c7-8456-98c60dc665c9 <list[1]>          NA          NA
#>  38: ee0d6c4b-434b-4758-bb4f-7ddc9256b5b6 <list[1]>          NA          NA
#>  39: d41fd4e0-e585-40d0-b144-b90c197e8500 <list[1]>          NA          NA
#>  40: 5ab4cd16-85e1-4dc7-91f4-6241a27efead <list[1]>          NA          NA
#>  41: ee24ce30-3440-4621-a3d8-7219a3d8a007 <list[1]>          NA          NA
#>  42: b35022a2-25bc-4055-b90a-5c00f9fe1ecc <list[1]>          NA          NA
#>  43: 8283924e-28a0-4479-b86a-ed59c857085e <list[1]>          NA          NA
#>  44: bfdc26d0-71cc-49ae-987d-b0ad481586dd <list[1]>          NA          NA
#>  45: bde2c8ea-946d-4ef8-938d-e08dc2de604d <list[1]>          NA          NA
#>  46: 0691c293-2a4b-46d1-aae0-422709db441f <list[1]>          NA          NA
#>  47: 90db999d-b260-4e0d-bcc9-2c21bbf5e98b <list[1]>          NA          NA
#>  48: ad1439aa-8584-4341-86ca-d3eb66549cb7 <list[1]>          NA          NA
#>  49: 5c67a3fc-d371-457a-8116-ff2b7f9a46f6 <list[1]>          NA          NA
#>  50: dc06fcb7-e904-4e4a-b96e-4652f7d0d704 <list[1]>          NA          NA
#>  51: 423be9df-3de5-46f0-9478-e67b43aeacef <list[1]>          NA          NA
#>  52: a754f84e-09c5-428b-bda6-2fab9a251665 <list[1]>          NA          NA
#>  53: 53bec8af-597f-4184-b6e7-28ef26503cbd <list[1]>          NA          NA
#>  54: 690ac9ba-0b5d-4b9c-b584-dda63bf82d4b <list[1]>          NA          NA
#>  55: f1caf5ef-43d1-4dff-abd4-ca9d4eba83a5 <list[1]>          NA          NA
#>  56: 7eb8c836-1604-4ac9-9f6e-4d53c1ec3548 <list[1]>          NA          NA
#>  57: 3216419f-6b3c-4703-a257-784b1a8ab394 <list[1]>          NA          NA
#>  58: 5f4d7a72-b252-44ee-813c-59ef914318b8 <list[1]>          NA          NA
#>  59: a433e75f-0d08-4876-b8e3-faa76d64c848 <list[1]>          NA          NA
#>  60: 603f670f-881a-4c5e-903a-0fdd668c15bb <list[1]>          NA          NA
#>  61: 69a7d443-24b2-4543-98b3-8465f2b3b120 <list[1]>          NA          NA
#>  62: 4f50cc17-83b6-47a0-868d-c808e7a42514 <list[1]>          NA          NA
#>  63: 77e05b68-e4c0-4d33-96a6-78a92829d09c <list[1]>          NA          NA
#>  64: 8ba9c2cc-0ebd-4135-80cb-5a1a9123ef56 <list[1]>          NA          NA
#>  65: d6f0ebc8-1587-4ac0-b3ea-08a6e0187ba1 <list[1]>          NA          NA
#>  66: 996724c2-a044-4196-8501-31f4d48556b7 <list[1]>          NA          NA
#>  67: 40655228-01e6-4cec-a1ee-2572a45ea46a <list[1]>          NA          NA
#>  68: 68a7180d-2cf7-4d1d-bd2c-b6488dd6438b <list[1]>          NA          NA
#>  69: 02821151-3343-423c-b185-3fe134ffcc61 <list[1]>          NA          NA
#>  70: 6156398a-a6af-44db-acd8-853705f03857 <list[1]>          NA          NA
#>  71: a86435f6-9f16-421e-bdb8-60772af89960 <list[1]>          NA          NA
#>  72: a499d17a-7b6c-4f0d-872d-7f9847ac69e1 <list[1]>          NA          NA
#>  73: 4495da93-57c2-42a3-989a-19243c9af62a <list[1]>          NA          NA
#>  74: 48982fc8-5024-4bf4-b738-faba78c81fce <list[1]>          NA          NA
#>  75: c68df180-d90c-48a2-a647-f3e655c67a5f <list[1]>          NA          NA
#>  76: 90f6330b-a3d1-421d-99b5-b9a4e3f3d521 <list[1]>          NA          NA
#>  77: 3fbce201-20f6-4e52-af7f-84dfd4d8a477 <list[1]>          NA          NA
#>  78: e2d8a401-533c-4281-93c6-b3481f301990 <list[1]>          NA          NA
#>  79: 366f8bea-eead-4d4e-bce5-c3c789504130 <list[1]>          NA          NA
#>  80: 60b20d26-d2c8-4b9b-a76d-443d22780832 <list[1]>          NA          NA
#>  81: 10b15166-b5e5-4ba3-aa67-b0c17e828f08 <list[1]>          NA          NA
#>  82: 3b47cd22-6844-4f1a-9592-e02234c2a6d7 <list[1]>          NA          NA
#>  83: d4eb5935-b061-430a-bb2d-11686b21cde3 <list[1]>          NA          NA
#>  84: 6034f999-4ad9-447c-9d40-97ef05435da1 <list[1]>          NA          NA
#>  85: fe024b40-2892-418d-af2c-bf0405390c0b <list[1]>          NA          NA
#>  86: 05e8a20e-8f37-4aaf-b4c1-58305fb5039c <list[1]>          NA          NA
#>  87: cccc1754-2ca6-4e52-b2fa-bb93697cf5bd <list[1]>          NA          NA
#>  88: 1b157041-e2e5-4fc2-8a5b-144601f44773 <list[1]>          NA          NA
#>  89: 1b9bcbdb-70ee-4ae3-95a9-7b3d836ad51c <list[1]>          NA          NA
#>  90: 9eb7f2bd-0b53-4fb7-a2ac-09eb7debe4b0 <list[1]>          NA          NA
#>  91: e481c715-bf2f-4596-bff7-a325d2f91c1a <list[1]>          NA          NA
#>  92: 3febeefe-43f8-45f3-8c79-2e493c340432 <list[1]>          NA          NA
#>  93: cca3572b-2662-4d2f-b79e-2b2b03030f64 <list[1]>          NA          NA
#>  94: d669b67a-ed86-4d65-95a3-32cf88c7adf8 <list[1]>          NA          NA
#>  95: bb615262-4a9a-4a43-9c57-47cfb60e7916 <list[1]>          NA          NA
#>  96: 013ad719-1436-4179-ae23-f04ac9adf3f0 <list[1]>          NA          NA
#>  97: f622fa21-eb41-4ac3-8f0a-6dee3ff81b81 <list[1]>          NA          NA
#>  98: b384dd94-c991-44a9-95b8-6ce0f39d7907 <list[1]>          NA          NA
#>  99: eb6d97d7-a1cc-4ced-be25-7d0520e395e8 <list[1]>          NA          NA
#> 100: 69c40cd6-f25c-469e-b60f-c20aead2a85f <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
