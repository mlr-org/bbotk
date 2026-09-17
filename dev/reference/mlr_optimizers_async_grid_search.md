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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-17 08:18:10
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-17 08:18:10
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-17 08:18:10
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-17 08:18:10
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-17 08:18:10
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-17 08:18:10
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-17 08:18:10
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-17 08:18:10
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-17 08:18:10
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-17 08:18:10
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-17 08:18:10
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-17 08:18:10
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-17 08:18:10
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-17 08:18:10
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-17 08:18:10
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-17 08:18:10
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-17 08:18:10
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-17 08:18:10
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-17 08:18:10
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-17 08:18:10
#>  21:   failed  10.000000  5.0000000         NA 2026-09-17 08:18:10
#>  22:   failed  10.000000  3.8888889         NA 2026-09-17 08:18:10
#>  23:   failed  10.000000  2.7777778         NA 2026-09-17 08:18:10
#>  24:   failed  10.000000  1.6666667         NA 2026-09-17 08:18:10
#>  25:   failed  10.000000  0.5555556         NA 2026-09-17 08:18:10
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-17 08:18:10
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-17 08:18:10
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-17 08:18:10
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-17 08:18:10
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-17 08:18:10
#>  31:   failed   7.777778  5.0000000         NA 2026-09-17 08:18:10
#>  32:   failed   7.777778  3.8888889         NA 2026-09-17 08:18:10
#>  33:   failed   7.777778  2.7777778         NA 2026-09-17 08:18:10
#>  34:   failed   7.777778  1.6666667         NA 2026-09-17 08:18:10
#>  35:   failed   7.777778  0.5555556         NA 2026-09-17 08:18:10
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-17 08:18:10
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-17 08:18:10
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-17 08:18:10
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-17 08:18:10
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-17 08:18:10
#>  41:   failed   5.555556  5.0000000         NA 2026-09-17 08:18:10
#>  42:   failed   5.555556  3.8888889         NA 2026-09-17 08:18:10
#>  43:   failed   5.555556  2.7777778         NA 2026-09-17 08:18:10
#>  44:   failed   5.555556  1.6666667         NA 2026-09-17 08:18:10
#>  45:   failed   5.555556  0.5555556         NA 2026-09-17 08:18:10
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-17 08:18:10
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-17 08:18:10
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-17 08:18:10
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-17 08:18:10
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-17 08:18:10
#>  51:   failed   3.333333  5.0000000         NA 2026-09-17 08:18:10
#>  52:   failed   3.333333  3.8888889         NA 2026-09-17 08:18:10
#>  53:   failed   3.333333  2.7777778         NA 2026-09-17 08:18:10
#>  54:   failed   3.333333  1.6666667         NA 2026-09-17 08:18:10
#>  55:   failed   3.333333  0.5555556         NA 2026-09-17 08:18:10
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-17 08:18:10
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-17 08:18:10
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-17 08:18:10
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-17 08:18:10
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-17 08:18:10
#>  61:   failed   1.111111  5.0000000         NA 2026-09-17 08:18:10
#>  62:   failed   1.111111  3.8888889         NA 2026-09-17 08:18:10
#>  63:   failed   1.111111  2.7777778         NA 2026-09-17 08:18:10
#>  64:   failed   1.111111  1.6666667         NA 2026-09-17 08:18:10
#>  65:   failed   1.111111  0.5555556         NA 2026-09-17 08:18:10
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-17 08:18:10
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-17 08:18:10
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-17 08:18:10
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-17 08:18:10
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-17 08:18:10
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-17 08:18:10
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-17 08:18:10
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-17 08:18:10
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-17 08:18:10
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-17 08:18:10
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-17 08:18:10
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-17 08:18:10
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-17 08:18:10
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-17 08:18:10
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-17 08:18:10
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-17 08:18:10
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-17 08:18:10
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-17 08:18:10
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-17 08:18:10
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-17 08:18:10
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-17 08:18:10
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-17 08:18:10
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-17 08:18:10
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-17 08:18:10
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-17 08:18:10
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-17 08:18:10
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-17 08:18:10
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-17 08:18:10
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-17 08:18:10
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-17 08:18:10
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-17 08:18:10
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-17 08:18:10
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-17 08:18:10
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-17 08:18:10
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-17 08:18:10
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>   2: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>   3: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>   4: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>   5: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>   6: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>   7: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>   8: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>   9: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>  10: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>  11: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>  12: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>  13: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>  14: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>  15: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>  16: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>  17: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>  18: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>  19: sinking_raccoon_07b215d7 2026-09-17 08:18:11
#>  20: sinking_raccoon_07b215d7 2026-09-17 08:18:11
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
#>   1: cb6a6f8c-91cb-469f-a4c6-108771fea527    [NULL]  -10.000000  -5.0000000
#>   2: 051e9eba-4ae4-475f-90f5-a15643ea3d37    [NULL]  -10.000000  -3.8888889
#>   3: de2cb059-826b-4016-a1b5-ddfd090d2f00    [NULL]  -10.000000  -2.7777778
#>   4: 8864f617-ccfe-4184-818c-12683b7d85bf    [NULL]  -10.000000  -1.6666667
#>   5: 44dd08c9-2dac-450e-af59-3c3d4acfae24    [NULL]  -10.000000  -0.5555556
#>   6: 6a4754ca-7e7f-45e6-b94d-282c6c25388b    [NULL]  -10.000000   0.5555556
#>   7: 8ddb5486-49be-4750-9ea5-da7d8df8688e    [NULL]  -10.000000   1.6666667
#>   8: 2214fcbd-48f8-4a2c-871d-489ddddf2f75    [NULL]  -10.000000   2.7777778
#>   9: c4889e2d-91cc-43f9-9aa5-2c8c25350774    [NULL]  -10.000000   3.8888889
#>  10: 4b5ab775-8faa-4ec8-83ec-75e3e5b52c06    [NULL]  -10.000000   5.0000000
#>  11: 61a8881e-3107-4b22-b2b7-0c260491626f    [NULL]   -7.777778  -5.0000000
#>  12: e0f24350-24ed-43ff-a132-9afb1d2d37e7    [NULL]   -7.777778  -3.8888889
#>  13: 25d49e00-68b6-482f-b30e-4fbcffc8cbad    [NULL]   -7.777778  -2.7777778
#>  14: cc1f2a0a-0f1a-4ec2-b8be-645e955848dd    [NULL]   -7.777778  -1.6666667
#>  15: 62efe643-b671-4ea9-b301-87a5cc467460    [NULL]   -7.777778  -0.5555556
#>  16: da0ad244-ea65-4ce7-b466-1d4f83ba8168    [NULL]   -7.777778   0.5555556
#>  17: 0a2c674c-384d-4f1b-9681-28d0bad3fc07    [NULL]   -7.777778   1.6666667
#>  18: 6db3a981-0463-4591-ad18-fae2e99b4e3b    [NULL]   -7.777778   2.7777778
#>  19: df13bd66-8af6-463b-a582-5c33d5c60ef3    [NULL]   -7.777778   3.8888889
#>  20: e89c29bc-3c39-4cb3-8ed3-9dbb1a90617b    [NULL]   -7.777778   5.0000000
#>  21: a97b3c1a-fb9d-4b3f-841d-9449bf12fb75 <list[1]>          NA          NA
#>  22: 96c14958-390c-45d8-9692-d58773666c83 <list[1]>          NA          NA
#>  23: 3e164729-e877-422b-b0cd-bff22c478ff8 <list[1]>          NA          NA
#>  24: cb89775b-f068-435b-ae47-9f3e1db621e3 <list[1]>          NA          NA
#>  25: 5eff5c84-1fdf-4401-adae-02ee8a61de58 <list[1]>          NA          NA
#>  26: ff4211aa-d2d8-4b02-a5bc-15deced6ca32 <list[1]>          NA          NA
#>  27: b6809337-ba89-45f4-bc76-b734934df9a1 <list[1]>          NA          NA
#>  28: 355d9d2c-9c46-4a0a-9aaf-bbe213ee96bd <list[1]>          NA          NA
#>  29: 1d054440-b5cc-4e9d-a389-c3096c4e7c6e <list[1]>          NA          NA
#>  30: 5e215f3e-d573-46f4-bdb2-25d8df657f9c <list[1]>          NA          NA
#>  31: e8922fe9-6299-4bda-8643-b8999a4e950d <list[1]>          NA          NA
#>  32: 5a5a198f-fb01-45d8-8668-39ac5ccca368 <list[1]>          NA          NA
#>  33: 0a0c0786-117e-43b6-a8b6-99171fe5a913 <list[1]>          NA          NA
#>  34: 362aca58-c169-4dbf-93f4-368c44b45be2 <list[1]>          NA          NA
#>  35: 0deab585-0e54-430d-a3e1-e8f5d4e80bc1 <list[1]>          NA          NA
#>  36: 1e857d96-c880-43ac-8b06-3af91ec4c3ce <list[1]>          NA          NA
#>  37: 81a73e10-a992-4f93-9e9e-db51850a2154 <list[1]>          NA          NA
#>  38: 0330c003-4875-4e27-8cb5-06a1ee185341 <list[1]>          NA          NA
#>  39: 64369d4c-f3fc-4c59-921f-3990e5456720 <list[1]>          NA          NA
#>  40: b86d7448-1079-41fb-a468-f59856ecf16a <list[1]>          NA          NA
#>  41: 5247f752-7667-4e1f-965e-f4d28a8879d9 <list[1]>          NA          NA
#>  42: b94dd529-0859-446f-ba5b-03e2bd39a963 <list[1]>          NA          NA
#>  43: 761ab234-59dd-46a2-9545-bf0a810337f4 <list[1]>          NA          NA
#>  44: bb1bef47-68d9-4159-861a-87e30d9aff63 <list[1]>          NA          NA
#>  45: 45254e3a-20da-4a3b-a5a8-7c6d55130f70 <list[1]>          NA          NA
#>  46: a164dfb9-f6c7-4494-80e9-0edd9105febf <list[1]>          NA          NA
#>  47: a2c3122a-1d2d-412f-8988-23febd913be8 <list[1]>          NA          NA
#>  48: c0b062f5-81b9-4766-9be7-9ca9d4f26225 <list[1]>          NA          NA
#>  49: 83ef8495-6e2b-416f-8e46-0ba19fda5ccb <list[1]>          NA          NA
#>  50: 214cced7-b8cf-456d-9bb6-a89d1cb499fa <list[1]>          NA          NA
#>  51: 8ab94036-5f55-4850-9905-3eb69d3867fd <list[1]>          NA          NA
#>  52: 706d2735-657c-4b6d-b4bb-1cc59f619c9e <list[1]>          NA          NA
#>  53: 6469ae4d-6d3b-4c61-8789-46936cf12d67 <list[1]>          NA          NA
#>  54: 3de8392d-1461-463e-be05-1af5531b0cd7 <list[1]>          NA          NA
#>  55: 202e6f9e-8c81-495a-8e44-3f8a00560b0f <list[1]>          NA          NA
#>  56: 433b4cbc-be30-4be9-aa94-9ff5f1bf8cc4 <list[1]>          NA          NA
#>  57: de4384ba-5a48-4860-8a68-f3538fbe83ac <list[1]>          NA          NA
#>  58: 419ece08-79b8-4d2f-bd20-45d26134e5f3 <list[1]>          NA          NA
#>  59: ba0c2c83-27e2-4198-980a-7839c38a7a3b <list[1]>          NA          NA
#>  60: 6accf769-4125-4350-95d8-dd4036795c44 <list[1]>          NA          NA
#>  61: 5f71c985-9337-497b-9692-147a5fa784d1 <list[1]>          NA          NA
#>  62: b0080dc1-9c1e-4f92-86cf-d49330e428dd <list[1]>          NA          NA
#>  63: 311c99ee-23c7-449e-8aca-b56abc11ca6d <list[1]>          NA          NA
#>  64: 22d6a868-c077-4c68-963a-742f3b2a3947 <list[1]>          NA          NA
#>  65: 76c1d212-38e7-44de-8b33-05868bb9c510 <list[1]>          NA          NA
#>  66: 0a51cb4d-54aa-46ec-9fb9-72e9efdd1057 <list[1]>          NA          NA
#>  67: ba4ebb0a-b2a1-4460-b9cf-c29f678bad75 <list[1]>          NA          NA
#>  68: 93ba93e8-4764-48f9-b75a-4be97aeedadd <list[1]>          NA          NA
#>  69: 3167809c-4c58-4632-8f96-2efc10047baa <list[1]>          NA          NA
#>  70: 4db994b6-7e8c-4b03-8af5-94586fc6d271 <list[1]>          NA          NA
#>  71: 1d7f279b-fd07-4921-ad2b-8282e114bce3 <list[1]>          NA          NA
#>  72: cc057048-ac4f-4f60-97e9-c3d85e5d7130 <list[1]>          NA          NA
#>  73: 49b3f91f-51fc-484f-8220-5b880d374f5c <list[1]>          NA          NA
#>  74: 16e013ba-4081-4dc0-bfd8-46a6e738b7ab <list[1]>          NA          NA
#>  75: 8de3be18-13c7-454d-8b7a-8a35b38051d3 <list[1]>          NA          NA
#>  76: 231e3296-c44a-4879-9c9a-64873952fecb <list[1]>          NA          NA
#>  77: 231ceec6-6201-4bf1-8541-e0e7096cf2c8 <list[1]>          NA          NA
#>  78: f453fb73-31d7-43c3-8200-101febc63d63 <list[1]>          NA          NA
#>  79: 32329d07-fb5b-46a4-b4ef-0d77d1178c04 <list[1]>          NA          NA
#>  80: 4c7ad458-2c9b-448c-877c-eca5380c996a <list[1]>          NA          NA
#>  81: cb1b603f-5c60-4801-b79b-c3fc378359a2 <list[1]>          NA          NA
#>  82: d57b4241-b48b-4569-9e96-c076a7c15136 <list[1]>          NA          NA
#>  83: 725f051b-19e2-4e96-8221-c744f4fa4b47 <list[1]>          NA          NA
#>  84: db00403d-82cc-4166-b571-f707e7e3dc61 <list[1]>          NA          NA
#>  85: 592d2871-95f8-44a2-b21b-878d793bbc93 <list[1]>          NA          NA
#>  86: 45a860ca-4b31-460f-bb50-17da982cfcc2 <list[1]>          NA          NA
#>  87: 69013109-3e2f-4a13-ad90-fb09bc75cf2d <list[1]>          NA          NA
#>  88: 74313ad7-8256-410f-90b3-1e83567d2c33 <list[1]>          NA          NA
#>  89: a2776982-9093-427f-b146-4632cde62720 <list[1]>          NA          NA
#>  90: 7428b036-e11c-47c7-9b71-ad2fdcd5e4c7 <list[1]>          NA          NA
#>  91: c649aedb-56bd-4603-b398-866e49317c59 <list[1]>          NA          NA
#>  92: b731f5ca-1c67-4669-8aa3-0354ac8625d4 <list[1]>          NA          NA
#>  93: 7baee500-d0f6-4754-872c-f327797bb8dc <list[1]>          NA          NA
#>  94: 624f9ce5-0dd4-4dfc-a122-4b026ccb03f3 <list[1]>          NA          NA
#>  95: ada524f7-8efa-4442-8a07-ff3292a457d5 <list[1]>          NA          NA
#>  96: 4a5ce680-34a5-40fd-bc87-0269a3a66469 <list[1]>          NA          NA
#>  97: 7830d060-3525-4d5b-be03-13d555f63e00 <list[1]>          NA          NA
#>  98: 1ee90e01-b956-4fa3-8299-a6aaa6d79e18 <list[1]>          NA          NA
#>  99: 233bd74d-e176-4041-b9fd-2b4f91013584 <list[1]>          NA          NA
#> 100: 59bda7b3-1af3-4ffc-bbc1-3647c0bfe5d2 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
