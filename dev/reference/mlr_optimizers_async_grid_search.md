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

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
-\>
[`bbotk::OptimizerAsync`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md)
-\> `OptimizerAsyncGridSearch`

## Methods

### Public methods

- [`OptimizerAsyncGridSearch$new()`](#method-OptimizerAsyncGridSearch-new)

- [`OptimizerAsyncGridSearch$optimize()`](#method-OptimizerAsyncGridSearch-optimize)

- [`OptimizerAsyncGridSearch$clone()`](#method-OptimizerAsyncGridSearch-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerAsyncGridSearch$new()

------------------------------------------------------------------------

### Method [`optimize()`](https://rdrr.io/r/stats/optimize.html)

Starts the asynchronous optimization.

#### Usage

    OptimizerAsyncGridSearch$optimize(inst)

#### Arguments

- `inst`:

  ([OptimInstance](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)).

#### Returns

[data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html).

------------------------------------------------------------------------

### Method `clone()`

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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-06-09 13:56:53
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-06-09 13:56:53
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-06-09 13:56:53
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-06-09 13:56:53
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-06-09 13:56:53
#>   6: finished -10.000000  0.5555556 -146.64198 2026-06-09 13:56:53
#>   7: finished -10.000000  1.6666667 -155.77778 2026-06-09 13:56:53
#>   8: finished -10.000000  2.7777778 -167.38272 2026-06-09 13:56:53
#>   9: finished -10.000000  3.8888889 -181.45679 2026-06-09 13:56:53
#>  10: finished -10.000000  5.0000000 -198.00000 2026-06-09 13:56:53
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-06-09 13:56:53
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-06-09 13:56:53
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-06-09 13:56:53
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-06-09 13:56:53
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-06-09 13:56:53
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-06-09 13:56:53
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-06-09 13:56:53
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-06-09 13:56:53
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-06-09 13:56:53
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-06-09 13:56:53
#>  21:   failed  10.000000  5.0000000         NA 2026-06-09 13:56:53
#>  22:   failed  10.000000  3.8888889         NA 2026-06-09 13:56:53
#>  23:   failed  10.000000  2.7777778         NA 2026-06-09 13:56:53
#>  24:   failed  10.000000  1.6666667         NA 2026-06-09 13:56:53
#>  25:   failed  10.000000  0.5555556         NA 2026-06-09 13:56:53
#>  26:   failed  10.000000 -0.5555556         NA 2026-06-09 13:56:53
#>  27:   failed  10.000000 -1.6666667         NA 2026-06-09 13:56:53
#>  28:   failed  10.000000 -2.7777778         NA 2026-06-09 13:56:53
#>  29:   failed  10.000000 -3.8888889         NA 2026-06-09 13:56:53
#>  30:   failed  10.000000 -5.0000000         NA 2026-06-09 13:56:53
#>  31:   failed   7.777778  5.0000000         NA 2026-06-09 13:56:53
#>  32:   failed   7.777778  3.8888889         NA 2026-06-09 13:56:53
#>  33:   failed   7.777778  2.7777778         NA 2026-06-09 13:56:53
#>  34:   failed   7.777778  1.6666667         NA 2026-06-09 13:56:53
#>  35:   failed   7.777778  0.5555556         NA 2026-06-09 13:56:53
#>  36:   failed   7.777778 -0.5555556         NA 2026-06-09 13:56:53
#>  37:   failed   7.777778 -1.6666667         NA 2026-06-09 13:56:53
#>  38:   failed   7.777778 -2.7777778         NA 2026-06-09 13:56:53
#>  39:   failed   7.777778 -3.8888889         NA 2026-06-09 13:56:53
#>  40:   failed   7.777778 -5.0000000         NA 2026-06-09 13:56:53
#>  41:   failed   5.555556  5.0000000         NA 2026-06-09 13:56:53
#>  42:   failed   5.555556  3.8888889         NA 2026-06-09 13:56:53
#>  43:   failed   5.555556  2.7777778         NA 2026-06-09 13:56:53
#>  44:   failed   5.555556  1.6666667         NA 2026-06-09 13:56:53
#>  45:   failed   5.555556  0.5555556         NA 2026-06-09 13:56:53
#>  46:   failed   5.555556 -0.5555556         NA 2026-06-09 13:56:53
#>  47:   failed   5.555556 -1.6666667         NA 2026-06-09 13:56:53
#>  48:   failed   5.555556 -2.7777778         NA 2026-06-09 13:56:53
#>  49:   failed   5.555556 -3.8888889         NA 2026-06-09 13:56:53
#>  50:   failed   5.555556 -5.0000000         NA 2026-06-09 13:56:53
#>  51:   failed   3.333333  5.0000000         NA 2026-06-09 13:56:53
#>  52:   failed   3.333333  3.8888889         NA 2026-06-09 13:56:53
#>  53:   failed   3.333333  2.7777778         NA 2026-06-09 13:56:53
#>  54:   failed   3.333333  1.6666667         NA 2026-06-09 13:56:53
#>  55:   failed   3.333333  0.5555556         NA 2026-06-09 13:56:53
#>  56:   failed   3.333333 -0.5555556         NA 2026-06-09 13:56:53
#>  57:   failed   3.333333 -1.6666667         NA 2026-06-09 13:56:53
#>  58:   failed   3.333333 -2.7777778         NA 2026-06-09 13:56:53
#>  59:   failed   3.333333 -3.8888889         NA 2026-06-09 13:56:53
#>  60:   failed   3.333333 -5.0000000         NA 2026-06-09 13:56:53
#>  61:   failed   1.111111  5.0000000         NA 2026-06-09 13:56:53
#>  62:   failed   1.111111  3.8888889         NA 2026-06-09 13:56:53
#>  63:   failed   1.111111  2.7777778         NA 2026-06-09 13:56:53
#>  64:   failed   1.111111  1.6666667         NA 2026-06-09 13:56:53
#>  65:   failed   1.111111  0.5555556         NA 2026-06-09 13:56:53
#>  66:   failed   1.111111 -0.5555556         NA 2026-06-09 13:56:53
#>  67:   failed   1.111111 -1.6666667         NA 2026-06-09 13:56:53
#>  68:   failed   1.111111 -2.7777778         NA 2026-06-09 13:56:53
#>  69:   failed   1.111111 -3.8888889         NA 2026-06-09 13:56:53
#>  70:   failed   1.111111 -5.0000000         NA 2026-06-09 13:56:53
#>  71:   failed  -1.111111  5.0000000         NA 2026-06-09 13:56:53
#>  72:   failed  -1.111111  3.8888889         NA 2026-06-09 13:56:53
#>  73:   failed  -1.111111  2.7777778         NA 2026-06-09 13:56:53
#>  74:   failed  -1.111111  1.6666667         NA 2026-06-09 13:56:53
#>  75:   failed  -1.111111  0.5555556         NA 2026-06-09 13:56:53
#>  76:   failed  -1.111111 -0.5555556         NA 2026-06-09 13:56:53
#>  77:   failed  -1.111111 -1.6666667         NA 2026-06-09 13:56:53
#>  78:   failed  -1.111111 -2.7777778         NA 2026-06-09 13:56:53
#>  79:   failed  -1.111111 -3.8888889         NA 2026-06-09 13:56:53
#>  80:   failed  -1.111111 -5.0000000         NA 2026-06-09 13:56:53
#>  81:   failed  -3.333333  5.0000000         NA 2026-06-09 13:56:53
#>  82:   failed  -3.333333  3.8888889         NA 2026-06-09 13:56:53
#>  83:   failed  -3.333333  2.7777778         NA 2026-06-09 13:56:53
#>  84:   failed  -3.333333  1.6666667         NA 2026-06-09 13:56:53
#>  85:   failed  -3.333333  0.5555556         NA 2026-06-09 13:56:53
#>  86:   failed  -3.333333 -0.5555556         NA 2026-06-09 13:56:53
#>  87:   failed  -3.333333 -1.6666667         NA 2026-06-09 13:56:53
#>  88:   failed  -3.333333 -2.7777778         NA 2026-06-09 13:56:53
#>  89:   failed  -3.333333 -3.8888889         NA 2026-06-09 13:56:53
#>  90:   failed  -3.333333 -5.0000000         NA 2026-06-09 13:56:53
#>  91:   failed  -5.555556  5.0000000         NA 2026-06-09 13:56:53
#>  92:   failed  -5.555556  3.8888889         NA 2026-06-09 13:56:53
#>  93:   failed  -5.555556  2.7777778         NA 2026-06-09 13:56:53
#>  94:   failed  -5.555556  1.6666667         NA 2026-06-09 13:56:53
#>  95:   failed  -5.555556  0.5555556         NA 2026-06-09 13:56:53
#>  96:   failed  -5.555556 -0.5555556         NA 2026-06-09 13:56:53
#>  97:   failed  -5.555556 -1.6666667         NA 2026-06-09 13:56:53
#>  98:   failed  -5.555556 -2.7777778         NA 2026-06-09 13:56:53
#>  99:   failed  -5.555556 -3.8888889         NA 2026-06-09 13:56:53
#> 100:   failed  -5.555556 -5.0000000         NA 2026-06-09 13:56:53
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-06-09 13:56:54 88ed3538-8dc0-4175-9771-d12f25742911
#>   2: sinking_raccoon 2026-06-09 13:56:54 1f6962e7-75c3-4c31-aaef-450f4c917e5f
#>   3: sinking_raccoon 2026-06-09 13:56:54 2a53bd5a-459a-40c0-b43b-4bc9d8aa2aea
#>   4: sinking_raccoon 2026-06-09 13:56:54 8a6b6c5d-f63c-41ad-b873-2cb4aedd910f
#>   5: sinking_raccoon 2026-06-09 13:56:54 376b637a-890b-4ebf-8621-6d63d443b45c
#>   6: sinking_raccoon 2026-06-09 13:56:54 9661a23d-9b44-47e0-ba23-1942ed44efa1
#>   7: sinking_raccoon 2026-06-09 13:56:54 1e03a767-688b-44e2-9990-e13fdc5bbc4d
#>   8: sinking_raccoon 2026-06-09 13:56:54 5bf395e7-209d-4f24-b53a-0cc218460eb1
#>   9: sinking_raccoon 2026-06-09 13:56:54 c95b47e1-ed8b-4124-9617-9b04ee5a92ee
#>  10: sinking_raccoon 2026-06-09 13:56:54 1e8fb07d-a076-43f6-bf45-e2a26311de41
#>  11: sinking_raccoon 2026-06-09 13:56:54 040a199e-645e-472c-b563-e3e22834691d
#>  12: sinking_raccoon 2026-06-09 13:56:54 488372b4-db71-444e-bc11-fc64593aa6f0
#>  13: sinking_raccoon 2026-06-09 13:56:54 7a2e35f2-179f-4022-a7f9-3166cbe9b7fb
#>  14: sinking_raccoon 2026-06-09 13:56:54 ea1f7f64-f01f-4164-9e19-cdc167f34ab3
#>  15: sinking_raccoon 2026-06-09 13:56:54 f7e0ce12-b219-49b1-8dcd-4859c4f32c4f
#>  16: sinking_raccoon 2026-06-09 13:56:54 c6a0ba24-243f-4ad5-a674-d1c833f96378
#>  17: sinking_raccoon 2026-06-09 13:56:54 2db45941-32fb-4b11-894b-ea6b7b501b9a
#>  18: sinking_raccoon 2026-06-09 13:56:54 b2d65710-c9b3-42cb-8a8a-2cc536951b6f
#>  19: sinking_raccoon 2026-06-09 13:56:54 ffcd4e35-2d21-47bd-9f77-4373a939d0d6
#>  20: sinking_raccoon 2026-06-09 13:56:54 adf4beeb-c3c4-4dc1-842e-f7facc9951ac
#>  21:            <NA>                <NA> fa2c5c10-8182-4502-a91a-b89ae02adbdb
#>  22:            <NA>                <NA> 5325c220-4179-48e7-b016-ccf1bcb83aa9
#>  23:            <NA>                <NA> 9fac23ef-8914-4b46-abdb-8d2389dca0b5
#>  24:            <NA>                <NA> d7ea4c38-a979-4bbc-a33b-0ae8038f13fb
#>  25:            <NA>                <NA> c4fbafd4-6388-44fd-a6a2-47907f32e299
#>  26:            <NA>                <NA> a18fb0ad-5241-4905-9e13-5ba973e1c2be
#>  27:            <NA>                <NA> cedcf491-201a-42d4-8595-ea4ebce837a2
#>  28:            <NA>                <NA> 83350df2-3939-4b00-b727-a544f3179d3a
#>  29:            <NA>                <NA> 66b4416f-29a3-41ea-821d-bcc926fdb76b
#>  30:            <NA>                <NA> f96b79e5-7920-4563-8f5e-a7bf24a060a1
#>  31:            <NA>                <NA> c028f253-6ea7-4c96-b574-93c2e7d5c9e4
#>  32:            <NA>                <NA> 0113735f-04d9-4536-a8ef-ab475860b5c5
#>  33:            <NA>                <NA> dc4a4d1f-17c9-4903-96b1-a0f7861a781f
#>  34:            <NA>                <NA> b032f3b0-09dc-49fc-b69a-336f84afb6c3
#>  35:            <NA>                <NA> 43b4172c-342b-43ed-bcf0-11b5b020a5a4
#>  36:            <NA>                <NA> 96a11a39-4f52-480b-a077-07ab762bfd07
#>  37:            <NA>                <NA> c46381bc-ade5-4dc8-98e2-bbe9ff351538
#>  38:            <NA>                <NA> 26309ff4-5f37-4c75-b077-7f9cea9af739
#>  39:            <NA>                <NA> 623e3cff-6858-4e63-822c-e3d26eefb4fc
#>  40:            <NA>                <NA> 495e4df0-2799-4d5a-a043-a7433ea82299
#>  41:            <NA>                <NA> 09a74009-9eb2-41a4-a39b-354740799e7d
#>  42:            <NA>                <NA> 2f5bb39c-f3e9-4ce8-9455-fd33711ce423
#>  43:            <NA>                <NA> 559e99bd-f868-4bf8-b18f-bdd91793175b
#>  44:            <NA>                <NA> 7e8b1cd4-dd11-4642-b18e-df2c0689df4b
#>  45:            <NA>                <NA> f4f103e3-3dc6-4158-a1b5-6c78e00b10c0
#>  46:            <NA>                <NA> 0abdf0ff-0e7a-4290-9e3e-4fca28fe5815
#>  47:            <NA>                <NA> 25b112e9-c9aa-4b94-8cbe-6bb27636ff29
#>  48:            <NA>                <NA> 14d224b6-10e8-4b81-b386-3de39ca41409
#>  49:            <NA>                <NA> d6a2cf81-924d-4e13-b175-6d8349448847
#>  50:            <NA>                <NA> 109052b6-49dd-4904-8564-be208dd6e7a1
#>  51:            <NA>                <NA> 002cc898-766f-4383-bfb4-f63df92ea751
#>  52:            <NA>                <NA> 98465f69-2530-4dad-baf5-0ef88708f89b
#>  53:            <NA>                <NA> ebaf7200-b917-40a5-a243-54a5306f5e86
#>  54:            <NA>                <NA> ed5ee17d-3292-4d16-84a5-4a23e4d6dbbb
#>  55:            <NA>                <NA> 414cede5-61fc-45af-a020-944339cf1ae9
#>  56:            <NA>                <NA> 391035be-813b-457a-97e3-1cb746596459
#>  57:            <NA>                <NA> a6c3937e-289b-4a86-b9c5-4009d1b7d26c
#>  58:            <NA>                <NA> 9a269814-442e-4d3f-88db-047391a03364
#>  59:            <NA>                <NA> d5ce08e4-200e-427e-b2de-12fd8a446ad1
#>  60:            <NA>                <NA> d35022ee-bdd9-4243-a98e-8ef12a4bded9
#>  61:            <NA>                <NA> 082f4db7-fab1-4f47-89ef-46b065e1efd5
#>  62:            <NA>                <NA> 075e960c-a85f-46c5-8aa0-2ae573aa1fe3
#>  63:            <NA>                <NA> c613ac29-e95f-4e42-a422-ea1c965fac1e
#>  64:            <NA>                <NA> 4c206c3e-9197-422c-8723-33d9bd026475
#>  65:            <NA>                <NA> e1e0fec9-0923-4175-a65a-dd0bbee6d8b0
#>  66:            <NA>                <NA> 83c601f3-baa1-40e8-afce-b9f32d24747d
#>  67:            <NA>                <NA> 25b0d250-f134-45d5-99b3-fb622db130e0
#>  68:            <NA>                <NA> 90835395-fd41-4082-bf07-994c7b30400f
#>  69:            <NA>                <NA> 8a9a87df-95c3-4eda-8598-095cd64f9f64
#>  70:            <NA>                <NA> 7d98dfbb-5a29-465b-bed0-caacc5832e78
#>  71:            <NA>                <NA> 7e6c4446-7a96-4322-b60d-0a3e6303defc
#>  72:            <NA>                <NA> f9b47cbd-939f-4a6f-9a26-6119f04f17a8
#>  73:            <NA>                <NA> da4a5575-41f8-4d86-8905-8c86ecd97429
#>  74:            <NA>                <NA> 0bd2d145-ca9e-4682-bd7c-654bc2e762bb
#>  75:            <NA>                <NA> ac6a8a1f-7e0d-499f-b0f2-184fd20af860
#>  76:            <NA>                <NA> 92fbffb9-d6b4-4d70-84ec-258bf3eb8011
#>  77:            <NA>                <NA> 82c726ac-65e3-41f9-af55-4a489c2d2ccb
#>  78:            <NA>                <NA> 3890d9f7-2732-412f-88d4-ec28333631f9
#>  79:            <NA>                <NA> 54cd155d-11ab-401c-9687-23ee8f5e86b5
#>  80:            <NA>                <NA> 313c22c0-2959-4767-8a36-06c190b1742e
#>  81:            <NA>                <NA> 5a90f712-61b5-4b1b-86b5-dce99fef6277
#>  82:            <NA>                <NA> bbcb95ee-e924-4858-8391-1cd80447c4ac
#>  83:            <NA>                <NA> a51235b0-aff5-4e57-a529-a5414b816bca
#>  84:            <NA>                <NA> 9a8ee919-a446-4124-99cb-4b4970a0d4fc
#>  85:            <NA>                <NA> a83f8b0c-99af-4aec-9f30-d28d4455f566
#>  86:            <NA>                <NA> dcdc9489-4054-4130-8cef-ac469776170b
#>  87:            <NA>                <NA> ac00038d-cde6-451b-9de5-de70ad10089b
#>  88:            <NA>                <NA> 93b923f2-98b0-49d3-b13b-1a1ecb35eee0
#>  89:            <NA>                <NA> 0328daa9-2067-4760-bd4c-135a979331f2
#>  90:            <NA>                <NA> 6575287d-4cd2-444a-9f3f-83510015c774
#>  91:            <NA>                <NA> ab8d9470-fdfa-4b94-8334-a8e77c7ed92a
#>  92:            <NA>                <NA> 4d519df9-a09c-4d5e-8a19-245b8b9d046a
#>  93:            <NA>                <NA> f71a9029-6af8-476d-841f-4cba51e9fc4b
#>  94:            <NA>                <NA> 57db6acc-0ec6-4198-91e6-630387ebf10d
#>  95:            <NA>                <NA> 1e4df176-1c12-4866-9464-40ff94f4b64b
#>  96:            <NA>                <NA> 4d5da196-5bd2-4d10-8c27-a445d1d4d32f
#>  97:            <NA>                <NA> 2549c8a1-28c1-4789-b660-07b17f047ba5
#>  98:            <NA>                <NA> f19a5b6b-f4d1-4654-a740-7ea925b762d4
#>  99:            <NA>                <NA> 34c7152c-c6dd-4abf-a838-9cb8051cefcf
#> 100:            <NA>                <NA> 445202e3-f487-4a7f-b036-141d91f676f2
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>                      message x_domain_x1 x_domain_x2
#>                       <char>       <num>       <num>
#>   1:                    <NA>  -10.000000  -5.0000000
#>   2:                    <NA>  -10.000000  -3.8888889
#>   3:                    <NA>  -10.000000  -2.7777778
#>   4:                    <NA>  -10.000000  -1.6666667
#>   5:                    <NA>  -10.000000  -0.5555556
#>   6:                    <NA>  -10.000000   0.5555556
#>   7:                    <NA>  -10.000000   1.6666667
#>   8:                    <NA>  -10.000000   2.7777778
#>   9:                    <NA>  -10.000000   3.8888889
#>  10:                    <NA>  -10.000000   5.0000000
#>  11:                    <NA>   -7.777778  -5.0000000
#>  12:                    <NA>   -7.777778  -3.8888889
#>  13:                    <NA>   -7.777778  -2.7777778
#>  14:                    <NA>   -7.777778  -1.6666667
#>  15:                    <NA>   -7.777778  -0.5555556
#>  16:                    <NA>   -7.777778   0.5555556
#>  17:                    <NA>   -7.777778   1.6666667
#>  18:                    <NA>   -7.777778   2.7777778
#>  19:                    <NA>   -7.777778   3.8888889
#>  20:                    <NA>   -7.777778   5.0000000
#>  21: Optimization terminated          NA          NA
#>  22: Optimization terminated          NA          NA
#>  23: Optimization terminated          NA          NA
#>  24: Optimization terminated          NA          NA
#>  25: Optimization terminated          NA          NA
#>  26: Optimization terminated          NA          NA
#>  27: Optimization terminated          NA          NA
#>  28: Optimization terminated          NA          NA
#>  29: Optimization terminated          NA          NA
#>  30: Optimization terminated          NA          NA
#>  31: Optimization terminated          NA          NA
#>  32: Optimization terminated          NA          NA
#>  33: Optimization terminated          NA          NA
#>  34: Optimization terminated          NA          NA
#>  35: Optimization terminated          NA          NA
#>  36: Optimization terminated          NA          NA
#>  37: Optimization terminated          NA          NA
#>  38: Optimization terminated          NA          NA
#>  39: Optimization terminated          NA          NA
#>  40: Optimization terminated          NA          NA
#>  41: Optimization terminated          NA          NA
#>  42: Optimization terminated          NA          NA
#>  43: Optimization terminated          NA          NA
#>  44: Optimization terminated          NA          NA
#>  45: Optimization terminated          NA          NA
#>  46: Optimization terminated          NA          NA
#>  47: Optimization terminated          NA          NA
#>  48: Optimization terminated          NA          NA
#>  49: Optimization terminated          NA          NA
#>  50: Optimization terminated          NA          NA
#>  51: Optimization terminated          NA          NA
#>  52: Optimization terminated          NA          NA
#>  53: Optimization terminated          NA          NA
#>  54: Optimization terminated          NA          NA
#>  55: Optimization terminated          NA          NA
#>  56: Optimization terminated          NA          NA
#>  57: Optimization terminated          NA          NA
#>  58: Optimization terminated          NA          NA
#>  59: Optimization terminated          NA          NA
#>  60: Optimization terminated          NA          NA
#>  61: Optimization terminated          NA          NA
#>  62: Optimization terminated          NA          NA
#>  63: Optimization terminated          NA          NA
#>  64: Optimization terminated          NA          NA
#>  65: Optimization terminated          NA          NA
#>  66: Optimization terminated          NA          NA
#>  67: Optimization terminated          NA          NA
#>  68: Optimization terminated          NA          NA
#>  69: Optimization terminated          NA          NA
#>  70: Optimization terminated          NA          NA
#>  71: Optimization terminated          NA          NA
#>  72: Optimization terminated          NA          NA
#>  73: Optimization terminated          NA          NA
#>  74: Optimization terminated          NA          NA
#>  75: Optimization terminated          NA          NA
#>  76: Optimization terminated          NA          NA
#>  77: Optimization terminated          NA          NA
#>  78: Optimization terminated          NA          NA
#>  79: Optimization terminated          NA          NA
#>  80: Optimization terminated          NA          NA
#>  81: Optimization terminated          NA          NA
#>  82: Optimization terminated          NA          NA
#>  83: Optimization terminated          NA          NA
#>  84: Optimization terminated          NA          NA
#>  85: Optimization terminated          NA          NA
#>  86: Optimization terminated          NA          NA
#>  87: Optimization terminated          NA          NA
#>  88: Optimization terminated          NA          NA
#>  89: Optimization terminated          NA          NA
#>  90: Optimization terminated          NA          NA
#>  91: Optimization terminated          NA          NA
#>  92: Optimization terminated          NA          NA
#>  93: Optimization terminated          NA          NA
#>  94: Optimization terminated          NA          NA
#>  95: Optimization terminated          NA          NA
#>  96: Optimization terminated          NA          NA
#>  97: Optimization terminated          NA          NA
#>  98: Optimization terminated          NA          NA
#>  99: Optimization terminated          NA          NA
#> 100: Optimization terminated          NA          NA
#>                      message x_domain_x1 x_domain_x2
#>                       <char>       <num>       <num>
```
