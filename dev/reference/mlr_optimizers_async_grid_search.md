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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-17 09:30:24
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-17 09:30:24
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-17 09:30:24
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-17 09:30:24
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-17 09:30:24
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-17 09:30:24
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-17 09:30:24
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-17 09:30:24
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-17 09:30:24
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-17 09:30:24
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-17 09:30:24
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-17 09:30:24
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-17 09:30:24
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-17 09:30:24
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-17 09:30:24
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-17 09:30:24
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-17 09:30:24
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-17 09:30:24
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-17 09:30:24
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-17 09:30:24
#>  21:   failed  10.000000  5.0000000         NA 2026-09-17 09:30:24
#>  22:   failed  10.000000  3.8888889         NA 2026-09-17 09:30:24
#>  23:   failed  10.000000  2.7777778         NA 2026-09-17 09:30:24
#>  24:   failed  10.000000  1.6666667         NA 2026-09-17 09:30:24
#>  25:   failed  10.000000  0.5555556         NA 2026-09-17 09:30:24
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-17 09:30:24
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-17 09:30:24
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-17 09:30:24
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-17 09:30:24
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-17 09:30:24
#>  31:   failed   7.777778  5.0000000         NA 2026-09-17 09:30:24
#>  32:   failed   7.777778  3.8888889         NA 2026-09-17 09:30:24
#>  33:   failed   7.777778  2.7777778         NA 2026-09-17 09:30:24
#>  34:   failed   7.777778  1.6666667         NA 2026-09-17 09:30:24
#>  35:   failed   7.777778  0.5555556         NA 2026-09-17 09:30:24
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-17 09:30:24
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-17 09:30:24
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-17 09:30:24
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-17 09:30:24
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-17 09:30:24
#>  41:   failed   5.555556  5.0000000         NA 2026-09-17 09:30:24
#>  42:   failed   5.555556  3.8888889         NA 2026-09-17 09:30:24
#>  43:   failed   5.555556  2.7777778         NA 2026-09-17 09:30:24
#>  44:   failed   5.555556  1.6666667         NA 2026-09-17 09:30:24
#>  45:   failed   5.555556  0.5555556         NA 2026-09-17 09:30:24
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-17 09:30:24
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-17 09:30:24
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-17 09:30:24
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-17 09:30:24
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-17 09:30:24
#>  51:   failed   3.333333  5.0000000         NA 2026-09-17 09:30:24
#>  52:   failed   3.333333  3.8888889         NA 2026-09-17 09:30:24
#>  53:   failed   3.333333  2.7777778         NA 2026-09-17 09:30:24
#>  54:   failed   3.333333  1.6666667         NA 2026-09-17 09:30:24
#>  55:   failed   3.333333  0.5555556         NA 2026-09-17 09:30:24
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-17 09:30:24
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-17 09:30:24
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-17 09:30:24
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-17 09:30:24
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-17 09:30:24
#>  61:   failed   1.111111  5.0000000         NA 2026-09-17 09:30:24
#>  62:   failed   1.111111  3.8888889         NA 2026-09-17 09:30:24
#>  63:   failed   1.111111  2.7777778         NA 2026-09-17 09:30:24
#>  64:   failed   1.111111  1.6666667         NA 2026-09-17 09:30:24
#>  65:   failed   1.111111  0.5555556         NA 2026-09-17 09:30:24
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-17 09:30:24
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-17 09:30:24
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-17 09:30:24
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-17 09:30:24
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-17 09:30:24
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-17 09:30:24
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-17 09:30:24
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-17 09:30:24
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-17 09:30:24
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-17 09:30:24
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-17 09:30:24
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-17 09:30:24
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-17 09:30:24
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-17 09:30:24
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-17 09:30:24
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-17 09:30:24
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-17 09:30:24
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-17 09:30:24
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-17 09:30:24
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-17 09:30:24
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-17 09:30:24
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-17 09:30:24
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-17 09:30:24
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-17 09:30:24
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-17 09:30:24
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-17 09:30:24
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-17 09:30:24
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-17 09:30:24
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-17 09:30:24
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-17 09:30:24
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-17 09:30:24
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-17 09:30:24
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-17 09:30:24
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-17 09:30:24
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-17 09:30:24
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>   2: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>   3: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>   4: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>   5: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>   6: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>   7: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>   8: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>   9: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>  10: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>  11: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>  12: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>  13: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>  14: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>  15: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>  16: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>  17: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>  18: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>  19: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
#>  20: sinking_raccoon_ef6738ad 2026-09-17 09:30:25
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
#>   1: be412ec5-c046-4d26-8ca0-489f347280b6    [NULL]  -10.000000  -5.0000000
#>   2: c6573660-8a88-4ab6-b2ae-3faa68c3c448    [NULL]  -10.000000  -3.8888889
#>   3: b01bb0ae-83df-4db1-a8de-920de2cf81be    [NULL]  -10.000000  -2.7777778
#>   4: ce4ff1a6-96f6-450b-b729-47951425cc60    [NULL]  -10.000000  -1.6666667
#>   5: 840b2618-96cb-4e5e-93f0-a429ec78e771    [NULL]  -10.000000  -0.5555556
#>   6: 816639ad-3d8c-47d1-87b1-9f4caf7aeffe    [NULL]  -10.000000   0.5555556
#>   7: da6de204-6ad2-46e8-90a0-573f489b9476    [NULL]  -10.000000   1.6666667
#>   8: 27285dcc-5aa5-47c5-a2e4-05361a77ef93    [NULL]  -10.000000   2.7777778
#>   9: 5b78c4e8-b5a2-498e-bd30-5bab07e7322a    [NULL]  -10.000000   3.8888889
#>  10: b956999b-ffd2-4bfc-9ba2-d612a9c12d6c    [NULL]  -10.000000   5.0000000
#>  11: b82c8bce-7ce5-4bba-8457-3add7eea8361    [NULL]   -7.777778  -5.0000000
#>  12: 8668aee8-a36f-4a74-ac02-01e8ccfe781f    [NULL]   -7.777778  -3.8888889
#>  13: 6ab0d387-7fbf-4ba2-a608-bc50416a59dc    [NULL]   -7.777778  -2.7777778
#>  14: 55e9edb6-a951-49bc-97ed-deffd8c7dd6e    [NULL]   -7.777778  -1.6666667
#>  15: 5988dce8-f0bf-4b27-9e62-11a1861cccae    [NULL]   -7.777778  -0.5555556
#>  16: 3d04cabc-0e36-4000-875c-371af07f7d82    [NULL]   -7.777778   0.5555556
#>  17: 559f7d2f-2404-4d5a-95c4-0dd85a5967a1    [NULL]   -7.777778   1.6666667
#>  18: 57bacf74-ae34-439e-8e15-079a53c044db    [NULL]   -7.777778   2.7777778
#>  19: fb910c18-18e3-445b-ae7e-6e0e5f05a454    [NULL]   -7.777778   3.8888889
#>  20: 3bd2d337-82ca-4b0a-b17b-097709a6e625    [NULL]   -7.777778   5.0000000
#>  21: b0f21d63-9a81-4eb1-8db5-15f0956f2c09 <list[1]>          NA          NA
#>  22: a92154be-738e-4ed3-9a72-d6951d392056 <list[1]>          NA          NA
#>  23: 3901d882-365b-4147-b572-7233f18d551f <list[1]>          NA          NA
#>  24: 75c3bcfe-d0e0-4b79-a751-452ce71d1968 <list[1]>          NA          NA
#>  25: ab4ab92b-3ddc-469a-9a6e-474d9d02e6be <list[1]>          NA          NA
#>  26: 27bd28af-26b2-4b25-8eb6-e6c90ecfd4e1 <list[1]>          NA          NA
#>  27: 85b1b140-72bc-455f-b18e-a0f45e9b55fb <list[1]>          NA          NA
#>  28: b04aea79-9a7e-4d91-b4b1-23b71419371b <list[1]>          NA          NA
#>  29: ea351567-b0e9-4233-902f-0046390897fc <list[1]>          NA          NA
#>  30: 4964e22f-fe42-420d-b3e7-4bf207af135a <list[1]>          NA          NA
#>  31: 8056029f-e625-4c02-89cd-4b8c2d9718bf <list[1]>          NA          NA
#>  32: 56266c7c-b676-45b7-936d-a7995cbdfcc2 <list[1]>          NA          NA
#>  33: b0e7a531-510a-4886-879d-641b3d0d1a1b <list[1]>          NA          NA
#>  34: 66562de8-0476-4f09-aa6b-50125f403ce2 <list[1]>          NA          NA
#>  35: 03a2bf92-da9b-44e8-9e16-3a281bae1ab7 <list[1]>          NA          NA
#>  36: f72ee128-cc1b-4503-86f0-fbc3de3c76e8 <list[1]>          NA          NA
#>  37: 2ee2c902-587c-4259-bf29-1c80bf348606 <list[1]>          NA          NA
#>  38: 1e92f67d-09ee-4a92-a17f-82badf93f216 <list[1]>          NA          NA
#>  39: fffd720d-28b1-47fd-9f30-6432187edc7d <list[1]>          NA          NA
#>  40: cad8781f-1d75-479d-9c35-8af4353c3ace <list[1]>          NA          NA
#>  41: 1a7981e2-7c91-473a-a920-f271b9c83c5a <list[1]>          NA          NA
#>  42: bf7972ea-74da-4eb2-a82b-286532671814 <list[1]>          NA          NA
#>  43: aa05f4dc-987f-4ce9-b601-c1ed898a862b <list[1]>          NA          NA
#>  44: 4db9a031-340c-475e-96b5-2be362c700b2 <list[1]>          NA          NA
#>  45: 64a6a4ab-446c-41ed-805a-57703778aded <list[1]>          NA          NA
#>  46: 96854b7c-0f0d-485c-82df-471e94a6c86c <list[1]>          NA          NA
#>  47: 0ebebd2a-1711-4ed6-8f20-144b208bae38 <list[1]>          NA          NA
#>  48: 88c0773d-a393-4202-b91c-b95dba5ed15f <list[1]>          NA          NA
#>  49: bc142d99-38a6-430a-958e-3ee84b67976e <list[1]>          NA          NA
#>  50: 425440b1-fcd9-4c12-a332-984e907c2e54 <list[1]>          NA          NA
#>  51: 92403888-9ee9-41c7-b81f-7383f376acd2 <list[1]>          NA          NA
#>  52: 204c162d-8582-42ae-a45b-614fa3c63a58 <list[1]>          NA          NA
#>  53: 207b921c-fc6c-4224-96ad-6e39e3cfeb5e <list[1]>          NA          NA
#>  54: 5f7d8d6e-5043-42ec-9d16-f886f8cc0f75 <list[1]>          NA          NA
#>  55: 6d32fed9-f182-4174-8412-cf47de1df070 <list[1]>          NA          NA
#>  56: e8c56d55-af56-4ffd-b28e-1241db02e014 <list[1]>          NA          NA
#>  57: f6786d1d-0b3a-4898-ac68-ddd77c6b7a1a <list[1]>          NA          NA
#>  58: 963150f1-2ea6-48d8-886d-0e71ce44c2ab <list[1]>          NA          NA
#>  59: 0393630d-d0b7-4e5c-8d64-9257472ff9ad <list[1]>          NA          NA
#>  60: 51f760da-1ad4-44f2-8f08-53a0083ce3e7 <list[1]>          NA          NA
#>  61: e36d78d1-2d98-4149-a979-90309abbe9fc <list[1]>          NA          NA
#>  62: 34582fb8-b3bc-4046-9ba2-cc835fc77dc6 <list[1]>          NA          NA
#>  63: 874855dc-fabd-4306-bdae-8bc0d56d8fce <list[1]>          NA          NA
#>  64: b5b29084-687d-4934-beed-595d55f6fe3c <list[1]>          NA          NA
#>  65: 5db919fb-c453-4593-8443-f6afbfe9bf56 <list[1]>          NA          NA
#>  66: b1e361a6-e6fc-48f4-a495-8b369abeae16 <list[1]>          NA          NA
#>  67: 311056bf-47c3-47ec-8f64-182420799473 <list[1]>          NA          NA
#>  68: fd8be96e-2f30-428a-b98d-65867facd3e7 <list[1]>          NA          NA
#>  69: c7d37ae0-b2ce-494b-a396-b9964441a848 <list[1]>          NA          NA
#>  70: bd21404f-1715-420b-a1d7-9b451f6d582d <list[1]>          NA          NA
#>  71: c5273767-778c-4903-a2bb-69abebd7e994 <list[1]>          NA          NA
#>  72: 14b08ad9-678c-47c3-a141-e25fa426a6f8 <list[1]>          NA          NA
#>  73: ff55956e-db0f-4fbe-b349-4500742c0254 <list[1]>          NA          NA
#>  74: f22d76cc-3495-4d4b-a76f-0f0c7e1cae30 <list[1]>          NA          NA
#>  75: 099a650f-3309-4022-819f-d72c2ce300fc <list[1]>          NA          NA
#>  76: d6eb33a6-97ce-4b56-8095-38d39a4010b7 <list[1]>          NA          NA
#>  77: f2a810d9-866a-4bcf-8b6f-84b2faea2dbe <list[1]>          NA          NA
#>  78: 2b5a965a-8fbb-4e80-8904-135db29fb92d <list[1]>          NA          NA
#>  79: cfea9a9e-c7e9-4277-866a-da8bbab0c186 <list[1]>          NA          NA
#>  80: b0450a13-c00b-4a69-bf32-0c9fc978869b <list[1]>          NA          NA
#>  81: e6cc1b46-6a58-439c-8306-e57dc0259604 <list[1]>          NA          NA
#>  82: 01e1d660-571c-443f-a385-2c2388957a83 <list[1]>          NA          NA
#>  83: 122733a2-8c9f-48d1-b4ce-05dc18364004 <list[1]>          NA          NA
#>  84: 59d847b0-6a3f-4ead-9d6b-f9d7d4969397 <list[1]>          NA          NA
#>  85: aa45f915-6368-4044-8bc6-069fe7624266 <list[1]>          NA          NA
#>  86: 06eab65f-e073-4138-b165-6b14e1fbb0c5 <list[1]>          NA          NA
#>  87: 110ffecb-5849-44e3-a06a-82415c6a0b98 <list[1]>          NA          NA
#>  88: f291947e-9cab-4f52-af3d-08ae664bd5f5 <list[1]>          NA          NA
#>  89: 6f1d355d-ee45-4e57-8fd8-26b5a149feb3 <list[1]>          NA          NA
#>  90: 04aa336a-e80b-465d-9f47-35733b4a09ca <list[1]>          NA          NA
#>  91: c41e4e59-c662-42e5-902e-0659db418716 <list[1]>          NA          NA
#>  92: 54523c46-d6bb-45f8-9e2a-0d7db3a39fc5 <list[1]>          NA          NA
#>  93: 3e6f6adf-1047-41f9-babc-03e881a81d90 <list[1]>          NA          NA
#>  94: 0733cc95-a132-41b8-9baa-fc39a9fcb6b3 <list[1]>          NA          NA
#>  95: e14871cd-acbe-477e-83fb-f8e4c005ebe6 <list[1]>          NA          NA
#>  96: 256b1c8b-9e85-49b9-9508-8464fd4caeff <list[1]>          NA          NA
#>  97: 43bb9126-3659-4ed0-9f07-382cb0ca9881 <list[1]>          NA          NA
#>  98: 5b4bf51c-8425-48e5-a195-c22583ec96b6 <list[1]>          NA          NA
#>  99: 500cbaea-7660-4944-ab2b-185046677286 <list[1]>          NA          NA
#> 100: c8d25e66-7d1e-40fe-8699-d96cb3213446 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
