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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-06-27 12:50:17
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-06-27 12:50:17
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-06-27 12:50:17
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-06-27 12:50:17
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-06-27 12:50:17
#>   6: finished -10.000000  0.5555556 -146.64198 2026-06-27 12:50:17
#>   7: finished -10.000000  1.6666667 -155.77778 2026-06-27 12:50:17
#>   8: finished -10.000000  2.7777778 -167.38272 2026-06-27 12:50:17
#>   9: finished -10.000000  3.8888889 -181.45679 2026-06-27 12:50:17
#>  10: finished -10.000000  5.0000000 -198.00000 2026-06-27 12:50:17
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-06-27 12:50:17
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-06-27 12:50:17
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-06-27 12:50:17
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-06-27 12:50:17
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-06-27 12:50:17
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-06-27 12:50:17
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-06-27 12:50:17
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-06-27 12:50:17
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-06-27 12:50:17
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-06-27 12:50:17
#>  21:   failed  10.000000  5.0000000         NA 2026-06-27 12:50:17
#>  22:   failed  10.000000  3.8888889         NA 2026-06-27 12:50:17
#>  23:   failed  10.000000  2.7777778         NA 2026-06-27 12:50:17
#>  24:   failed  10.000000  1.6666667         NA 2026-06-27 12:50:17
#>  25:   failed  10.000000  0.5555556         NA 2026-06-27 12:50:17
#>  26:   failed  10.000000 -0.5555556         NA 2026-06-27 12:50:17
#>  27:   failed  10.000000 -1.6666667         NA 2026-06-27 12:50:17
#>  28:   failed  10.000000 -2.7777778         NA 2026-06-27 12:50:17
#>  29:   failed  10.000000 -3.8888889         NA 2026-06-27 12:50:17
#>  30:   failed  10.000000 -5.0000000         NA 2026-06-27 12:50:17
#>  31:   failed   7.777778  5.0000000         NA 2026-06-27 12:50:17
#>  32:   failed   7.777778  3.8888889         NA 2026-06-27 12:50:17
#>  33:   failed   7.777778  2.7777778         NA 2026-06-27 12:50:17
#>  34:   failed   7.777778  1.6666667         NA 2026-06-27 12:50:17
#>  35:   failed   7.777778  0.5555556         NA 2026-06-27 12:50:17
#>  36:   failed   7.777778 -0.5555556         NA 2026-06-27 12:50:17
#>  37:   failed   7.777778 -1.6666667         NA 2026-06-27 12:50:17
#>  38:   failed   7.777778 -2.7777778         NA 2026-06-27 12:50:17
#>  39:   failed   7.777778 -3.8888889         NA 2026-06-27 12:50:17
#>  40:   failed   7.777778 -5.0000000         NA 2026-06-27 12:50:17
#>  41:   failed   5.555556  5.0000000         NA 2026-06-27 12:50:17
#>  42:   failed   5.555556  3.8888889         NA 2026-06-27 12:50:17
#>  43:   failed   5.555556  2.7777778         NA 2026-06-27 12:50:17
#>  44:   failed   5.555556  1.6666667         NA 2026-06-27 12:50:17
#>  45:   failed   5.555556  0.5555556         NA 2026-06-27 12:50:17
#>  46:   failed   5.555556 -0.5555556         NA 2026-06-27 12:50:17
#>  47:   failed   5.555556 -1.6666667         NA 2026-06-27 12:50:17
#>  48:   failed   5.555556 -2.7777778         NA 2026-06-27 12:50:17
#>  49:   failed   5.555556 -3.8888889         NA 2026-06-27 12:50:17
#>  50:   failed   5.555556 -5.0000000         NA 2026-06-27 12:50:17
#>  51:   failed   3.333333  5.0000000         NA 2026-06-27 12:50:17
#>  52:   failed   3.333333  3.8888889         NA 2026-06-27 12:50:17
#>  53:   failed   3.333333  2.7777778         NA 2026-06-27 12:50:17
#>  54:   failed   3.333333  1.6666667         NA 2026-06-27 12:50:17
#>  55:   failed   3.333333  0.5555556         NA 2026-06-27 12:50:17
#>  56:   failed   3.333333 -0.5555556         NA 2026-06-27 12:50:17
#>  57:   failed   3.333333 -1.6666667         NA 2026-06-27 12:50:17
#>  58:   failed   3.333333 -2.7777778         NA 2026-06-27 12:50:17
#>  59:   failed   3.333333 -3.8888889         NA 2026-06-27 12:50:17
#>  60:   failed   3.333333 -5.0000000         NA 2026-06-27 12:50:17
#>  61:   failed   1.111111  5.0000000         NA 2026-06-27 12:50:17
#>  62:   failed   1.111111  3.8888889         NA 2026-06-27 12:50:17
#>  63:   failed   1.111111  2.7777778         NA 2026-06-27 12:50:17
#>  64:   failed   1.111111  1.6666667         NA 2026-06-27 12:50:17
#>  65:   failed   1.111111  0.5555556         NA 2026-06-27 12:50:17
#>  66:   failed   1.111111 -0.5555556         NA 2026-06-27 12:50:17
#>  67:   failed   1.111111 -1.6666667         NA 2026-06-27 12:50:17
#>  68:   failed   1.111111 -2.7777778         NA 2026-06-27 12:50:17
#>  69:   failed   1.111111 -3.8888889         NA 2026-06-27 12:50:17
#>  70:   failed   1.111111 -5.0000000         NA 2026-06-27 12:50:17
#>  71:   failed  -1.111111  5.0000000         NA 2026-06-27 12:50:17
#>  72:   failed  -1.111111  3.8888889         NA 2026-06-27 12:50:17
#>  73:   failed  -1.111111  2.7777778         NA 2026-06-27 12:50:17
#>  74:   failed  -1.111111  1.6666667         NA 2026-06-27 12:50:17
#>  75:   failed  -1.111111  0.5555556         NA 2026-06-27 12:50:17
#>  76:   failed  -1.111111 -0.5555556         NA 2026-06-27 12:50:17
#>  77:   failed  -1.111111 -1.6666667         NA 2026-06-27 12:50:17
#>  78:   failed  -1.111111 -2.7777778         NA 2026-06-27 12:50:17
#>  79:   failed  -1.111111 -3.8888889         NA 2026-06-27 12:50:17
#>  80:   failed  -1.111111 -5.0000000         NA 2026-06-27 12:50:17
#>  81:   failed  -3.333333  5.0000000         NA 2026-06-27 12:50:17
#>  82:   failed  -3.333333  3.8888889         NA 2026-06-27 12:50:17
#>  83:   failed  -3.333333  2.7777778         NA 2026-06-27 12:50:17
#>  84:   failed  -3.333333  1.6666667         NA 2026-06-27 12:50:17
#>  85:   failed  -3.333333  0.5555556         NA 2026-06-27 12:50:17
#>  86:   failed  -3.333333 -0.5555556         NA 2026-06-27 12:50:17
#>  87:   failed  -3.333333 -1.6666667         NA 2026-06-27 12:50:17
#>  88:   failed  -3.333333 -2.7777778         NA 2026-06-27 12:50:17
#>  89:   failed  -3.333333 -3.8888889         NA 2026-06-27 12:50:17
#>  90:   failed  -3.333333 -5.0000000         NA 2026-06-27 12:50:17
#>  91:   failed  -5.555556  5.0000000         NA 2026-06-27 12:50:17
#>  92:   failed  -5.555556  3.8888889         NA 2026-06-27 12:50:17
#>  93:   failed  -5.555556  2.7777778         NA 2026-06-27 12:50:17
#>  94:   failed  -5.555556  1.6666667         NA 2026-06-27 12:50:17
#>  95:   failed  -5.555556  0.5555556         NA 2026-06-27 12:50:17
#>  96:   failed  -5.555556 -0.5555556         NA 2026-06-27 12:50:17
#>  97:   failed  -5.555556 -1.6666667         NA 2026-06-27 12:50:17
#>  98:   failed  -5.555556 -2.7777778         NA 2026-06-27 12:50:17
#>  99:   failed  -5.555556 -3.8888889         NA 2026-06-27 12:50:17
#> 100:   failed  -5.555556 -5.0000000         NA 2026-06-27 12:50:17
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-06-27 12:50:18 0f0ae3ff-1d14-48e4-9fd8-80f19a329e7e
#>   2: sinking_raccoon 2026-06-27 12:50:18 8fff2ae3-a8c6-49f1-a129-32898a6fb90c
#>   3: sinking_raccoon 2026-06-27 12:50:18 935e8550-b3e1-4efa-8e84-118934e3e547
#>   4: sinking_raccoon 2026-06-27 12:50:18 a302cf48-5186-4cd8-8108-6dc9e49eb32f
#>   5: sinking_raccoon 2026-06-27 12:50:18 bf4eaad7-3f06-4aea-a96b-4dfd7f7ae59c
#>   6: sinking_raccoon 2026-06-27 12:50:18 132a431d-03f0-474b-8bf5-55a532caef31
#>   7: sinking_raccoon 2026-06-27 12:50:18 5798da1e-e05d-453b-8c7f-5ee1e87a1602
#>   8: sinking_raccoon 2026-06-27 12:50:18 f5458268-340c-4e38-a6c6-ba0fbfa34994
#>   9: sinking_raccoon 2026-06-27 12:50:18 095e3cf9-1dda-4f03-a579-97fcbb2ac6ea
#>  10: sinking_raccoon 2026-06-27 12:50:18 727417de-1b74-4677-b347-b9809da7557f
#>  11: sinking_raccoon 2026-06-27 12:50:18 2438a6bb-1b27-4ae5-9827-0b582ff41428
#>  12: sinking_raccoon 2026-06-27 12:50:18 b800cb94-aea8-40fa-b225-9b30259b9334
#>  13: sinking_raccoon 2026-06-27 12:50:18 86923a31-5aa1-42fb-aad1-67c5533552c1
#>  14: sinking_raccoon 2026-06-27 12:50:18 0e0ace64-a46d-41b4-8bd5-6b7f13a4ec6c
#>  15: sinking_raccoon 2026-06-27 12:50:18 6be8374b-c3ff-4ab1-96c3-fecf8ce4b2a0
#>  16: sinking_raccoon 2026-06-27 12:50:18 3111b0bf-5ebb-4447-bcf0-bde0d565d96f
#>  17: sinking_raccoon 2026-06-27 12:50:18 999643fe-7397-4ca5-80ba-344e5eb76a97
#>  18: sinking_raccoon 2026-06-27 12:50:18 c6a4bf46-22a4-486e-9206-6de4c770b1dc
#>  19: sinking_raccoon 2026-06-27 12:50:18 71542886-9fb6-45d3-bdbb-77b70e0a7497
#>  20: sinking_raccoon 2026-06-27 12:50:18 7b5741f2-9f44-48a1-9d66-0f8fdc7250d2
#>  21:            <NA>                <NA> 223345dc-d229-460c-a31f-42297077024b
#>  22:            <NA>                <NA> 7357f6eb-a8c5-4e88-aae2-a4c7525d1c76
#>  23:            <NA>                <NA> 2d290c34-6ccb-47c4-8359-d73b5217c97b
#>  24:            <NA>                <NA> 13cd0757-7759-4702-a2d4-11d61907cd34
#>  25:            <NA>                <NA> 8e44c1eb-2ccf-4137-8d45-196ba03464b9
#>  26:            <NA>                <NA> 122d4ea5-6c22-4680-8568-73057a609b86
#>  27:            <NA>                <NA> 4b721547-a69b-4f28-a2a0-bd04557818c4
#>  28:            <NA>                <NA> 40f8d4c7-ef8a-49aa-adf9-e13a4d9e36ed
#>  29:            <NA>                <NA> 335c7142-0dbd-4b4e-9708-574b7635def1
#>  30:            <NA>                <NA> 79a9b588-559b-4af0-a7be-95205dc09f7f
#>  31:            <NA>                <NA> 2021474f-28eb-40ce-a92f-404f9e7028b2
#>  32:            <NA>                <NA> b77f0f9d-e541-46bd-8dc1-4a257d99b073
#>  33:            <NA>                <NA> a82c7a05-ffd0-4e5c-b43e-a56f4fc7e0a7
#>  34:            <NA>                <NA> 52b0a580-fed8-4f48-b0cb-691b92c95e07
#>  35:            <NA>                <NA> 168b631e-134b-4577-ae96-8f915950be56
#>  36:            <NA>                <NA> 93475c99-b6a9-4d79-bbe3-1fa9df7db4e2
#>  37:            <NA>                <NA> 4715bd2e-9c9b-4a03-bf65-b76469ddc73e
#>  38:            <NA>                <NA> dab5b5aa-57e2-4769-be29-94e12a06e465
#>  39:            <NA>                <NA> 932c695f-9206-4061-bdf9-de2694f0a6f1
#>  40:            <NA>                <NA> 216a4518-54af-4e09-96c9-8ef16b1861f7
#>  41:            <NA>                <NA> 01755d3a-ecc6-4e6f-9941-93f50629e041
#>  42:            <NA>                <NA> 8d1c5d3c-08d3-4a5f-bffa-041dc4d60086
#>  43:            <NA>                <NA> 2397f3b6-a297-4197-b40d-9f4d84f01290
#>  44:            <NA>                <NA> 51b9754c-a99b-4d41-a88d-e4e3f73c63c6
#>  45:            <NA>                <NA> fe3d7201-7af4-425e-9676-d41ea08fc817
#>  46:            <NA>                <NA> 7af003bb-49c6-45ec-bfa3-328fabe03c7a
#>  47:            <NA>                <NA> bc2bcb1e-71d0-4e1f-a8b5-1c65cb4dcb60
#>  48:            <NA>                <NA> 941134ed-61a1-4122-baf2-a6e4b01a4a6e
#>  49:            <NA>                <NA> a4380dbc-1784-4fa5-a64c-84fe8dda38e3
#>  50:            <NA>                <NA> ff758245-2f73-40aa-ab71-1fd3f5c49b97
#>  51:            <NA>                <NA> dc1be490-e38c-491c-a066-6baef667134e
#>  52:            <NA>                <NA> bb9976cc-440b-4e48-8522-1aa90ffb2249
#>  53:            <NA>                <NA> 7fcedd6f-b36e-4861-b48c-2e3487e4b45b
#>  54:            <NA>                <NA> 5979a66b-4a27-4f66-8cd3-98f61ff35d36
#>  55:            <NA>                <NA> 9c7bd954-fe99-4df8-b843-4e399d210db4
#>  56:            <NA>                <NA> 909b95cd-7147-4bff-beec-b464e434699a
#>  57:            <NA>                <NA> 1f504dd7-212d-42d0-a72a-ecf211f25813
#>  58:            <NA>                <NA> f825817c-b11d-4567-9f19-d335780ff498
#>  59:            <NA>                <NA> d7f3858c-97dd-462c-99c5-160dc2c91f76
#>  60:            <NA>                <NA> 5dd16c59-89fa-4306-827e-e0437827f2f1
#>  61:            <NA>                <NA> fe7eaec9-9b03-4cce-801d-099764238bb1
#>  62:            <NA>                <NA> 169bb4b2-b458-480a-8410-e34a7d3f8d74
#>  63:            <NA>                <NA> 4446cc4e-4ae7-4508-8d9e-ec892b13caae
#>  64:            <NA>                <NA> cd32bfa5-e3de-4550-8a13-ed8754bbcb53
#>  65:            <NA>                <NA> 449aa0e0-4116-4436-b990-628e43f964f7
#>  66:            <NA>                <NA> 43f9de9b-d6b8-4afe-808e-439916798009
#>  67:            <NA>                <NA> 7dd160d0-e147-4224-b5c9-832b0cb4c4c5
#>  68:            <NA>                <NA> 8e489acc-a6cb-4952-9d09-0b90733050c0
#>  69:            <NA>                <NA> 5a91a53f-9514-4ae2-811e-7cba9d12482f
#>  70:            <NA>                <NA> bd37899c-2cdb-4a9b-8f34-1d33bae773b2
#>  71:            <NA>                <NA> 7284f75c-2917-42f2-93b3-f95317667037
#>  72:            <NA>                <NA> 48520ffd-6789-4aa1-8769-9368f5f02ba8
#>  73:            <NA>                <NA> f76f6d95-1b3d-4cc5-840b-e406bdec2815
#>  74:            <NA>                <NA> efedff68-d11a-40ff-9425-c53173383080
#>  75:            <NA>                <NA> 992e432e-0734-49f1-8385-1a3bff278c4d
#>  76:            <NA>                <NA> 27494359-46ce-48c3-a7a6-bd7e2ec28597
#>  77:            <NA>                <NA> 7e645339-eae7-44af-a685-83736c636c3e
#>  78:            <NA>                <NA> 0bfbad6f-946f-46ae-bbfd-27078372582a
#>  79:            <NA>                <NA> 6b22e58d-56a1-4a00-ba20-e15bc1481e20
#>  80:            <NA>                <NA> d3a260b9-618e-45a9-a95d-4632dd775598
#>  81:            <NA>                <NA> fcdd776d-7175-4279-aaa2-35eacd27f7a9
#>  82:            <NA>                <NA> b704552f-8233-40de-99d6-a86271d43ba7
#>  83:            <NA>                <NA> 0ebb72b4-463f-4ac5-b278-39b71b72ab60
#>  84:            <NA>                <NA> 3b7c5a5e-67ca-4425-b6bf-dec23b183369
#>  85:            <NA>                <NA> b0c9ed4b-b6e9-4179-8071-35887eb41530
#>  86:            <NA>                <NA> a0c20364-3a7e-439c-96d4-ebf470096e4a
#>  87:            <NA>                <NA> 89dc523c-b61c-4943-83cb-5a7194e32440
#>  88:            <NA>                <NA> ab7d2011-d0ac-4a58-a352-647d241f4b78
#>  89:            <NA>                <NA> 3f960e16-8d51-423f-8085-97134ec904a9
#>  90:            <NA>                <NA> ad0d7412-90a1-42cf-a5be-b50284da56bd
#>  91:            <NA>                <NA> 9219979b-738b-45db-9792-ebde64327c78
#>  92:            <NA>                <NA> 77ec4d1f-240f-4a9b-ba87-9e4fe17b1bb5
#>  93:            <NA>                <NA> 8024d748-02c4-4756-8274-5e57aa48de3e
#>  94:            <NA>                <NA> d119f53d-b5f3-41e1-b4c6-212e89426619
#>  95:            <NA>                <NA> 0645653b-7f81-4fab-ab52-0e3dd36bdb95
#>  96:            <NA>                <NA> 976047a8-2806-49b4-9ae3-22a7a5f81ed4
#>  97:            <NA>                <NA> fc24a023-1ccb-4104-997b-a881bd78ac19
#>  98:            <NA>                <NA> 613cec67-1842-40cb-9c0b-dee3f027a973
#>  99:            <NA>                <NA> 02d9f543-29dd-40e8-a2cf-f02e104ee462
#> 100:            <NA>                <NA> 4742e732-c6e1-4112-8b3c-cfd227922488
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>                 message x_domain_x1 x_domain_x2
#>                  <char>       <num>       <num>
#>   1:               <NA>  -10.000000  -5.0000000
#>   2:               <NA>  -10.000000  -3.8888889
#>   3:               <NA>  -10.000000  -2.7777778
#>   4:               <NA>  -10.000000  -1.6666667
#>   5:               <NA>  -10.000000  -0.5555556
#>   6:               <NA>  -10.000000   0.5555556
#>   7:               <NA>  -10.000000   1.6666667
#>   8:               <NA>  -10.000000   2.7777778
#>   9:               <NA>  -10.000000   3.8888889
#>  10:               <NA>  -10.000000   5.0000000
#>  11:               <NA>   -7.777778  -5.0000000
#>  12:               <NA>   -7.777778  -3.8888889
#>  13:               <NA>   -7.777778  -2.7777778
#>  14:               <NA>   -7.777778  -1.6666667
#>  15:               <NA>   -7.777778  -0.5555556
#>  16:               <NA>   -7.777778   0.5555556
#>  17:               <NA>   -7.777778   1.6666667
#>  18:               <NA>   -7.777778   2.7777778
#>  19:               <NA>   -7.777778   3.8888889
#>  20:               <NA>   -7.777778   5.0000000
#>  21: Removed from queue          NA          NA
#>  22: Removed from queue          NA          NA
#>  23: Removed from queue          NA          NA
#>  24: Removed from queue          NA          NA
#>  25: Removed from queue          NA          NA
#>  26: Removed from queue          NA          NA
#>  27: Removed from queue          NA          NA
#>  28: Removed from queue          NA          NA
#>  29: Removed from queue          NA          NA
#>  30: Removed from queue          NA          NA
#>  31: Removed from queue          NA          NA
#>  32: Removed from queue          NA          NA
#>  33: Removed from queue          NA          NA
#>  34: Removed from queue          NA          NA
#>  35: Removed from queue          NA          NA
#>  36: Removed from queue          NA          NA
#>  37: Removed from queue          NA          NA
#>  38: Removed from queue          NA          NA
#>  39: Removed from queue          NA          NA
#>  40: Removed from queue          NA          NA
#>  41: Removed from queue          NA          NA
#>  42: Removed from queue          NA          NA
#>  43: Removed from queue          NA          NA
#>  44: Removed from queue          NA          NA
#>  45: Removed from queue          NA          NA
#>  46: Removed from queue          NA          NA
#>  47: Removed from queue          NA          NA
#>  48: Removed from queue          NA          NA
#>  49: Removed from queue          NA          NA
#>  50: Removed from queue          NA          NA
#>  51: Removed from queue          NA          NA
#>  52: Removed from queue          NA          NA
#>  53: Removed from queue          NA          NA
#>  54: Removed from queue          NA          NA
#>  55: Removed from queue          NA          NA
#>  56: Removed from queue          NA          NA
#>  57: Removed from queue          NA          NA
#>  58: Removed from queue          NA          NA
#>  59: Removed from queue          NA          NA
#>  60: Removed from queue          NA          NA
#>  61: Removed from queue          NA          NA
#>  62: Removed from queue          NA          NA
#>  63: Removed from queue          NA          NA
#>  64: Removed from queue          NA          NA
#>  65: Removed from queue          NA          NA
#>  66: Removed from queue          NA          NA
#>  67: Removed from queue          NA          NA
#>  68: Removed from queue          NA          NA
#>  69: Removed from queue          NA          NA
#>  70: Removed from queue          NA          NA
#>  71: Removed from queue          NA          NA
#>  72: Removed from queue          NA          NA
#>  73: Removed from queue          NA          NA
#>  74: Removed from queue          NA          NA
#>  75: Removed from queue          NA          NA
#>  76: Removed from queue          NA          NA
#>  77: Removed from queue          NA          NA
#>  78: Removed from queue          NA          NA
#>  79: Removed from queue          NA          NA
#>  80: Removed from queue          NA          NA
#>  81: Removed from queue          NA          NA
#>  82: Removed from queue          NA          NA
#>  83: Removed from queue          NA          NA
#>  84: Removed from queue          NA          NA
#>  85: Removed from queue          NA          NA
#>  86: Removed from queue          NA          NA
#>  87: Removed from queue          NA          NA
#>  88: Removed from queue          NA          NA
#>  89: Removed from queue          NA          NA
#>  90: Removed from queue          NA          NA
#>  91: Removed from queue          NA          NA
#>  92: Removed from queue          NA          NA
#>  93: Removed from queue          NA          NA
#>  94: Removed from queue          NA          NA
#>  95: Removed from queue          NA          NA
#>  96: Removed from queue          NA          NA
#>  97: Removed from queue          NA          NA
#>  98: Removed from queue          NA          NA
#>  99: Removed from queue          NA          NA
#> 100: Removed from queue          NA          NA
#>                 message x_domain_x1 x_domain_x2
#>                  <char>       <num>       <num>
```
