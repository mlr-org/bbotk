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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-06-11 08:56:16
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-06-11 08:56:16
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-06-11 08:56:16
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-06-11 08:56:16
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-06-11 08:56:16
#>   6: finished -10.000000  0.5555556 -146.64198 2026-06-11 08:56:16
#>   7: finished -10.000000  1.6666667 -155.77778 2026-06-11 08:56:16
#>   8: finished -10.000000  2.7777778 -167.38272 2026-06-11 08:56:16
#>   9: finished -10.000000  3.8888889 -181.45679 2026-06-11 08:56:16
#>  10: finished -10.000000  5.0000000 -198.00000 2026-06-11 08:56:16
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-06-11 08:56:16
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-06-11 08:56:16
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-06-11 08:56:16
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-06-11 08:56:16
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-06-11 08:56:16
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-06-11 08:56:16
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-06-11 08:56:16
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-06-11 08:56:16
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-06-11 08:56:16
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-06-11 08:56:16
#>  21:   failed  10.000000  5.0000000         NA 2026-06-11 08:56:16
#>  22:   failed  10.000000  3.8888889         NA 2026-06-11 08:56:16
#>  23:   failed  10.000000  2.7777778         NA 2026-06-11 08:56:16
#>  24:   failed  10.000000  1.6666667         NA 2026-06-11 08:56:16
#>  25:   failed  10.000000  0.5555556         NA 2026-06-11 08:56:16
#>  26:   failed  10.000000 -0.5555556         NA 2026-06-11 08:56:16
#>  27:   failed  10.000000 -1.6666667         NA 2026-06-11 08:56:16
#>  28:   failed  10.000000 -2.7777778         NA 2026-06-11 08:56:16
#>  29:   failed  10.000000 -3.8888889         NA 2026-06-11 08:56:16
#>  30:   failed  10.000000 -5.0000000         NA 2026-06-11 08:56:16
#>  31:   failed   7.777778  5.0000000         NA 2026-06-11 08:56:16
#>  32:   failed   7.777778  3.8888889         NA 2026-06-11 08:56:16
#>  33:   failed   7.777778  2.7777778         NA 2026-06-11 08:56:16
#>  34:   failed   7.777778  1.6666667         NA 2026-06-11 08:56:16
#>  35:   failed   7.777778  0.5555556         NA 2026-06-11 08:56:16
#>  36:   failed   7.777778 -0.5555556         NA 2026-06-11 08:56:16
#>  37:   failed   7.777778 -1.6666667         NA 2026-06-11 08:56:16
#>  38:   failed   7.777778 -2.7777778         NA 2026-06-11 08:56:16
#>  39:   failed   7.777778 -3.8888889         NA 2026-06-11 08:56:16
#>  40:   failed   7.777778 -5.0000000         NA 2026-06-11 08:56:16
#>  41:   failed   5.555556  5.0000000         NA 2026-06-11 08:56:16
#>  42:   failed   5.555556  3.8888889         NA 2026-06-11 08:56:16
#>  43:   failed   5.555556  2.7777778         NA 2026-06-11 08:56:16
#>  44:   failed   5.555556  1.6666667         NA 2026-06-11 08:56:16
#>  45:   failed   5.555556  0.5555556         NA 2026-06-11 08:56:16
#>  46:   failed   5.555556 -0.5555556         NA 2026-06-11 08:56:16
#>  47:   failed   5.555556 -1.6666667         NA 2026-06-11 08:56:16
#>  48:   failed   5.555556 -2.7777778         NA 2026-06-11 08:56:16
#>  49:   failed   5.555556 -3.8888889         NA 2026-06-11 08:56:16
#>  50:   failed   5.555556 -5.0000000         NA 2026-06-11 08:56:16
#>  51:   failed   3.333333  5.0000000         NA 2026-06-11 08:56:16
#>  52:   failed   3.333333  3.8888889         NA 2026-06-11 08:56:16
#>  53:   failed   3.333333  2.7777778         NA 2026-06-11 08:56:16
#>  54:   failed   3.333333  1.6666667         NA 2026-06-11 08:56:16
#>  55:   failed   3.333333  0.5555556         NA 2026-06-11 08:56:16
#>  56:   failed   3.333333 -0.5555556         NA 2026-06-11 08:56:16
#>  57:   failed   3.333333 -1.6666667         NA 2026-06-11 08:56:16
#>  58:   failed   3.333333 -2.7777778         NA 2026-06-11 08:56:16
#>  59:   failed   3.333333 -3.8888889         NA 2026-06-11 08:56:16
#>  60:   failed   3.333333 -5.0000000         NA 2026-06-11 08:56:16
#>  61:   failed   1.111111  5.0000000         NA 2026-06-11 08:56:16
#>  62:   failed   1.111111  3.8888889         NA 2026-06-11 08:56:16
#>  63:   failed   1.111111  2.7777778         NA 2026-06-11 08:56:16
#>  64:   failed   1.111111  1.6666667         NA 2026-06-11 08:56:16
#>  65:   failed   1.111111  0.5555556         NA 2026-06-11 08:56:16
#>  66:   failed   1.111111 -0.5555556         NA 2026-06-11 08:56:16
#>  67:   failed   1.111111 -1.6666667         NA 2026-06-11 08:56:16
#>  68:   failed   1.111111 -2.7777778         NA 2026-06-11 08:56:16
#>  69:   failed   1.111111 -3.8888889         NA 2026-06-11 08:56:16
#>  70:   failed   1.111111 -5.0000000         NA 2026-06-11 08:56:16
#>  71:   failed  -1.111111  5.0000000         NA 2026-06-11 08:56:16
#>  72:   failed  -1.111111  3.8888889         NA 2026-06-11 08:56:16
#>  73:   failed  -1.111111  2.7777778         NA 2026-06-11 08:56:16
#>  74:   failed  -1.111111  1.6666667         NA 2026-06-11 08:56:16
#>  75:   failed  -1.111111  0.5555556         NA 2026-06-11 08:56:16
#>  76:   failed  -1.111111 -0.5555556         NA 2026-06-11 08:56:16
#>  77:   failed  -1.111111 -1.6666667         NA 2026-06-11 08:56:16
#>  78:   failed  -1.111111 -2.7777778         NA 2026-06-11 08:56:16
#>  79:   failed  -1.111111 -3.8888889         NA 2026-06-11 08:56:16
#>  80:   failed  -1.111111 -5.0000000         NA 2026-06-11 08:56:16
#>  81:   failed  -3.333333  5.0000000         NA 2026-06-11 08:56:16
#>  82:   failed  -3.333333  3.8888889         NA 2026-06-11 08:56:16
#>  83:   failed  -3.333333  2.7777778         NA 2026-06-11 08:56:16
#>  84:   failed  -3.333333  1.6666667         NA 2026-06-11 08:56:16
#>  85:   failed  -3.333333  0.5555556         NA 2026-06-11 08:56:16
#>  86:   failed  -3.333333 -0.5555556         NA 2026-06-11 08:56:16
#>  87:   failed  -3.333333 -1.6666667         NA 2026-06-11 08:56:16
#>  88:   failed  -3.333333 -2.7777778         NA 2026-06-11 08:56:16
#>  89:   failed  -3.333333 -3.8888889         NA 2026-06-11 08:56:16
#>  90:   failed  -3.333333 -5.0000000         NA 2026-06-11 08:56:16
#>  91:   failed  -5.555556  5.0000000         NA 2026-06-11 08:56:16
#>  92:   failed  -5.555556  3.8888889         NA 2026-06-11 08:56:16
#>  93:   failed  -5.555556  2.7777778         NA 2026-06-11 08:56:16
#>  94:   failed  -5.555556  1.6666667         NA 2026-06-11 08:56:16
#>  95:   failed  -5.555556  0.5555556         NA 2026-06-11 08:56:16
#>  96:   failed  -5.555556 -0.5555556         NA 2026-06-11 08:56:16
#>  97:   failed  -5.555556 -1.6666667         NA 2026-06-11 08:56:16
#>  98:   failed  -5.555556 -2.7777778         NA 2026-06-11 08:56:16
#>  99:   failed  -5.555556 -3.8888889         NA 2026-06-11 08:56:16
#> 100:   failed  -5.555556 -5.0000000         NA 2026-06-11 08:56:16
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-06-11 08:56:17 83e1fbcf-df60-4265-a9e2-98cd9b34d049
#>   2: sinking_raccoon 2026-06-11 08:56:17 b369782c-9fda-4ee9-b763-3668db4d13f7
#>   3: sinking_raccoon 2026-06-11 08:56:17 82561366-46b8-4adf-bc3a-dbf477345586
#>   4: sinking_raccoon 2026-06-11 08:56:17 5569eb21-205e-41df-a802-58faa96be9d3
#>   5: sinking_raccoon 2026-06-11 08:56:17 25b99be8-c4d8-44a7-84e4-8c6855282470
#>   6: sinking_raccoon 2026-06-11 08:56:17 7d74044d-e3f7-484c-bfa0-4d187d45132c
#>   7: sinking_raccoon 2026-06-11 08:56:17 ebe5919e-2dc3-40a3-b611-057ed82ed53d
#>   8: sinking_raccoon 2026-06-11 08:56:17 19c1c8cd-7555-426d-88a2-a54aeb1f3bbb
#>   9: sinking_raccoon 2026-06-11 08:56:17 e8e9fa32-8754-4e17-b31b-7648c861ae1c
#>  10: sinking_raccoon 2026-06-11 08:56:17 43d31fff-d112-4a0f-b2fa-597ea9e108d3
#>  11: sinking_raccoon 2026-06-11 08:56:17 3d00d004-8843-458b-92da-394888f5f77f
#>  12: sinking_raccoon 2026-06-11 08:56:17 a2339dd6-91ac-4f75-ac69-c7837e61626b
#>  13: sinking_raccoon 2026-06-11 08:56:17 60d2e470-51b7-402f-8165-3e47a2f9b1c9
#>  14: sinking_raccoon 2026-06-11 08:56:17 5a78d3e7-d96d-4fc0-9b7c-fe7a647ecae2
#>  15: sinking_raccoon 2026-06-11 08:56:17 6a8afd1f-1610-4e79-a34e-47d018746f98
#>  16: sinking_raccoon 2026-06-11 08:56:17 e55cd16e-1a2d-43d9-8c57-646b52d5934c
#>  17: sinking_raccoon 2026-06-11 08:56:17 a182a2ea-7dcd-4c90-b4f4-69f112a8abd6
#>  18: sinking_raccoon 2026-06-11 08:56:17 e43d3c70-bd85-40ae-9786-9a0480e5da2c
#>  19: sinking_raccoon 2026-06-11 08:56:17 9456c9b7-1470-4c07-aeac-1baf872addd9
#>  20: sinking_raccoon 2026-06-11 08:56:17 d3a7c6d7-3fc4-49d1-8479-bbd6bb0028da
#>  21:            <NA>                <NA> da3b248b-a05e-4bf0-8549-9157af6547cc
#>  22:            <NA>                <NA> 81e4aab4-0cd8-4946-ad35-1f92652a29fa
#>  23:            <NA>                <NA> e1245834-0f69-4792-a603-a927ab37a418
#>  24:            <NA>                <NA> 4e0ba767-3607-49f6-9008-bcb6f4d23efd
#>  25:            <NA>                <NA> 8cf2b292-d343-42a5-9358-a9e37a56b5bf
#>  26:            <NA>                <NA> f5f58036-8da4-43e2-9115-761ce195aeff
#>  27:            <NA>                <NA> 9cf07f71-b54f-4204-bb53-5a358446ea18
#>  28:            <NA>                <NA> e7445a63-b4b2-4b8a-b255-747a68640a32
#>  29:            <NA>                <NA> 7716bf5f-6cea-4f02-af13-ec6e3a2cce28
#>  30:            <NA>                <NA> b061813f-d567-4ce0-9692-f5371547bea8
#>  31:            <NA>                <NA> 0173d140-14d1-4c76-bcdc-cc35c8362cdb
#>  32:            <NA>                <NA> 4186cbee-c430-43f0-a3b7-8cc2a6ffee17
#>  33:            <NA>                <NA> e84a13a1-230c-49d7-81f8-6a11ec7813f5
#>  34:            <NA>                <NA> dc4b41d9-a7b4-47ef-a958-8e000f0a12c0
#>  35:            <NA>                <NA> 6d24c260-e03c-42e9-9eab-8d931e360fa7
#>  36:            <NA>                <NA> eaadda54-1011-498b-aeb8-6d1c19236b39
#>  37:            <NA>                <NA> ceeead32-22e5-4a39-b999-1f9138d1f324
#>  38:            <NA>                <NA> 36c44b36-7717-4202-80b5-8433e6f42ca8
#>  39:            <NA>                <NA> dfd44cbf-8ec7-427f-9fbc-5bfe7ee3318a
#>  40:            <NA>                <NA> d2d0cecb-d0dc-4128-963f-30d768155b8c
#>  41:            <NA>                <NA> c6117fe6-094d-47a0-b012-93de6076c406
#>  42:            <NA>                <NA> 1ed0dcac-cda5-444f-ac13-ddbb3b1ef6a3
#>  43:            <NA>                <NA> f883208b-b1e1-4b8f-8e5d-ff60ca74d43f
#>  44:            <NA>                <NA> 42013cde-bca4-4b8f-b683-71e952f03b5c
#>  45:            <NA>                <NA> abcba54f-8a32-4ddb-a9d0-fed6f33576e9
#>  46:            <NA>                <NA> baea9d83-b62d-4629-8ee9-bf16d57b3bda
#>  47:            <NA>                <NA> e9cbb0c8-903c-4d2b-b195-687a7e1c0e3b
#>  48:            <NA>                <NA> 8064d0c4-db29-45dc-8189-ad60f461f679
#>  49:            <NA>                <NA> 720855d3-365a-411d-a7b3-c8d6fffa73e6
#>  50:            <NA>                <NA> 2572279f-3615-456b-b2f7-69d540a9c18b
#>  51:            <NA>                <NA> a464eea4-7bb5-4ce2-9218-22f82b28a610
#>  52:            <NA>                <NA> 2c9de803-60ef-48c1-933e-83bea676a71d
#>  53:            <NA>                <NA> 673fe0c1-bad6-4d5e-88a6-72deb59b2a85
#>  54:            <NA>                <NA> 75649873-2776-4e4f-a36e-8138f106d762
#>  55:            <NA>                <NA> ffd2b1a1-0285-469f-8c53-0997f587becd
#>  56:            <NA>                <NA> 1c94d15b-4cc6-4f11-99f3-b1ae652e1fd6
#>  57:            <NA>                <NA> 81e66057-6ad3-47b0-8df5-1d91b8793cf1
#>  58:            <NA>                <NA> c383ec5c-203c-49e7-b400-b871bb29d670
#>  59:            <NA>                <NA> 1dfce2cd-a328-462f-a5a7-eb4946e8e8b1
#>  60:            <NA>                <NA> 4c68c654-0520-45cb-8af8-fb41637fe306
#>  61:            <NA>                <NA> 72a49ff8-de62-459b-a493-ad88149dff0f
#>  62:            <NA>                <NA> 28ffe752-b147-4d2f-a739-5c44df8ff04c
#>  63:            <NA>                <NA> 655df6e5-9cff-4c4c-8ade-98cd9a63f466
#>  64:            <NA>                <NA> 4a985c10-1dda-4296-a5ce-b5af8281e58a
#>  65:            <NA>                <NA> 5dc4b649-5b61-4ac1-93b3-e0a9f7d6f84c
#>  66:            <NA>                <NA> 8572844d-9424-4970-804a-e7172091b740
#>  67:            <NA>                <NA> d84dfd9f-521a-46af-b301-871b3ef2ab8c
#>  68:            <NA>                <NA> 174c8fda-c4a4-441f-8998-8625e3ed4f42
#>  69:            <NA>                <NA> 7450d919-71cf-4019-a127-1fc5249d1fb4
#>  70:            <NA>                <NA> 4a06ddf4-ead9-4907-a5fe-e5baa4ca4934
#>  71:            <NA>                <NA> 60c25676-403e-4a40-9946-e0bac20ae6f8
#>  72:            <NA>                <NA> 3f19d876-a563-4a2a-80ae-0413e37c68e6
#>  73:            <NA>                <NA> 6d0bb15b-6593-458a-83e7-4fd5205fd529
#>  74:            <NA>                <NA> c910a2ed-4899-4a87-b199-d8a17d229e58
#>  75:            <NA>                <NA> 2c9613b2-f298-41ad-828e-26cf4f521a86
#>  76:            <NA>                <NA> fa32b93f-59da-49e5-8d68-3307d3c3b625
#>  77:            <NA>                <NA> e8e2b2c8-8bc4-4df1-9825-3bb8a413a127
#>  78:            <NA>                <NA> 9cca42ae-bbc6-4b4b-ac35-69c963c751b0
#>  79:            <NA>                <NA> c8128db5-7855-4d7a-a63a-4d2f846a9453
#>  80:            <NA>                <NA> dad43376-8a1f-49b2-873b-7dadaa4b42b9
#>  81:            <NA>                <NA> c2e038f5-4677-4135-a2a8-2e59509b1d49
#>  82:            <NA>                <NA> e165ac73-ed21-4d4d-af4d-3783a27fa645
#>  83:            <NA>                <NA> 9b258651-5f1d-4c4a-8c22-0215060e38f2
#>  84:            <NA>                <NA> 898279ed-8ff1-429c-833a-609b5c7ae556
#>  85:            <NA>                <NA> afd14102-5e99-4281-b335-56692165b92a
#>  86:            <NA>                <NA> 1779fc13-260e-4f61-8dcb-9ef11c0f0950
#>  87:            <NA>                <NA> d7d9c05e-3ed4-4486-8dee-5b9d7689f129
#>  88:            <NA>                <NA> 7c465d90-1564-4a8b-8c10-37f840f12ad4
#>  89:            <NA>                <NA> 8b9dd1e2-d3b9-4176-9ed8-c3ab6f4f320c
#>  90:            <NA>                <NA> 4bb1992b-4ca8-417e-a6e8-5de4224fcd83
#>  91:            <NA>                <NA> 57ff8301-f8d4-40dc-bef6-f2c28dadfbd2
#>  92:            <NA>                <NA> 0262884e-d3ad-4fd5-9a0f-ae4fe4a99752
#>  93:            <NA>                <NA> fbf06278-c03f-4a2a-80c5-98d7ea5408f9
#>  94:            <NA>                <NA> 700a2727-2ff0-4e37-aeb8-1c1adaf5cae5
#>  95:            <NA>                <NA> c9403277-6a40-4019-b642-e0955166181b
#>  96:            <NA>                <NA> af731a28-5bd5-4b90-8eae-2daa01855325
#>  97:            <NA>                <NA> 98741543-4f27-4acc-bd05-2c87542636bb
#>  98:            <NA>                <NA> 8fd93ed0-e799-4e91-b317-70f253275715
#>  99:            <NA>                <NA> 9870fafa-de1b-4b49-9866-ec9d2d6b361f
#> 100:            <NA>                <NA> 75c62572-0e69-4eb2-acc7-2f97eb929f28
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
