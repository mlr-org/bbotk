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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-06-10 12:15:34
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-06-10 12:15:34
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-06-10 12:15:34
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-06-10 12:15:34
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-06-10 12:15:34
#>   6: finished -10.000000  0.5555556 -146.64198 2026-06-10 12:15:34
#>   7: finished -10.000000  1.6666667 -155.77778 2026-06-10 12:15:34
#>   8: finished -10.000000  2.7777778 -167.38272 2026-06-10 12:15:34
#>   9: finished -10.000000  3.8888889 -181.45679 2026-06-10 12:15:34
#>  10: finished -10.000000  5.0000000 -198.00000 2026-06-10 12:15:34
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-06-10 12:15:34
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-06-10 12:15:34
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-06-10 12:15:34
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-06-10 12:15:34
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-06-10 12:15:34
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-06-10 12:15:34
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-06-10 12:15:34
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-06-10 12:15:34
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-06-10 12:15:34
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-06-10 12:15:34
#>  21:   failed  10.000000  5.0000000         NA 2026-06-10 12:15:34
#>  22:   failed  10.000000  3.8888889         NA 2026-06-10 12:15:34
#>  23:   failed  10.000000  2.7777778         NA 2026-06-10 12:15:34
#>  24:   failed  10.000000  1.6666667         NA 2026-06-10 12:15:34
#>  25:   failed  10.000000  0.5555556         NA 2026-06-10 12:15:34
#>  26:   failed  10.000000 -0.5555556         NA 2026-06-10 12:15:34
#>  27:   failed  10.000000 -1.6666667         NA 2026-06-10 12:15:34
#>  28:   failed  10.000000 -2.7777778         NA 2026-06-10 12:15:34
#>  29:   failed  10.000000 -3.8888889         NA 2026-06-10 12:15:34
#>  30:   failed  10.000000 -5.0000000         NA 2026-06-10 12:15:34
#>  31:   failed   7.777778  5.0000000         NA 2026-06-10 12:15:34
#>  32:   failed   7.777778  3.8888889         NA 2026-06-10 12:15:34
#>  33:   failed   7.777778  2.7777778         NA 2026-06-10 12:15:34
#>  34:   failed   7.777778  1.6666667         NA 2026-06-10 12:15:34
#>  35:   failed   7.777778  0.5555556         NA 2026-06-10 12:15:34
#>  36:   failed   7.777778 -0.5555556         NA 2026-06-10 12:15:34
#>  37:   failed   7.777778 -1.6666667         NA 2026-06-10 12:15:34
#>  38:   failed   7.777778 -2.7777778         NA 2026-06-10 12:15:34
#>  39:   failed   7.777778 -3.8888889         NA 2026-06-10 12:15:34
#>  40:   failed   7.777778 -5.0000000         NA 2026-06-10 12:15:34
#>  41:   failed   5.555556  5.0000000         NA 2026-06-10 12:15:34
#>  42:   failed   5.555556  3.8888889         NA 2026-06-10 12:15:34
#>  43:   failed   5.555556  2.7777778         NA 2026-06-10 12:15:34
#>  44:   failed   5.555556  1.6666667         NA 2026-06-10 12:15:34
#>  45:   failed   5.555556  0.5555556         NA 2026-06-10 12:15:34
#>  46:   failed   5.555556 -0.5555556         NA 2026-06-10 12:15:34
#>  47:   failed   5.555556 -1.6666667         NA 2026-06-10 12:15:34
#>  48:   failed   5.555556 -2.7777778         NA 2026-06-10 12:15:34
#>  49:   failed   5.555556 -3.8888889         NA 2026-06-10 12:15:34
#>  50:   failed   5.555556 -5.0000000         NA 2026-06-10 12:15:34
#>  51:   failed   3.333333  5.0000000         NA 2026-06-10 12:15:34
#>  52:   failed   3.333333  3.8888889         NA 2026-06-10 12:15:34
#>  53:   failed   3.333333  2.7777778         NA 2026-06-10 12:15:34
#>  54:   failed   3.333333  1.6666667         NA 2026-06-10 12:15:34
#>  55:   failed   3.333333  0.5555556         NA 2026-06-10 12:15:34
#>  56:   failed   3.333333 -0.5555556         NA 2026-06-10 12:15:34
#>  57:   failed   3.333333 -1.6666667         NA 2026-06-10 12:15:34
#>  58:   failed   3.333333 -2.7777778         NA 2026-06-10 12:15:34
#>  59:   failed   3.333333 -3.8888889         NA 2026-06-10 12:15:34
#>  60:   failed   3.333333 -5.0000000         NA 2026-06-10 12:15:34
#>  61:   failed   1.111111  5.0000000         NA 2026-06-10 12:15:34
#>  62:   failed   1.111111  3.8888889         NA 2026-06-10 12:15:34
#>  63:   failed   1.111111  2.7777778         NA 2026-06-10 12:15:34
#>  64:   failed   1.111111  1.6666667         NA 2026-06-10 12:15:34
#>  65:   failed   1.111111  0.5555556         NA 2026-06-10 12:15:34
#>  66:   failed   1.111111 -0.5555556         NA 2026-06-10 12:15:34
#>  67:   failed   1.111111 -1.6666667         NA 2026-06-10 12:15:34
#>  68:   failed   1.111111 -2.7777778         NA 2026-06-10 12:15:34
#>  69:   failed   1.111111 -3.8888889         NA 2026-06-10 12:15:34
#>  70:   failed   1.111111 -5.0000000         NA 2026-06-10 12:15:34
#>  71:   failed  -1.111111  5.0000000         NA 2026-06-10 12:15:34
#>  72:   failed  -1.111111  3.8888889         NA 2026-06-10 12:15:34
#>  73:   failed  -1.111111  2.7777778         NA 2026-06-10 12:15:34
#>  74:   failed  -1.111111  1.6666667         NA 2026-06-10 12:15:34
#>  75:   failed  -1.111111  0.5555556         NA 2026-06-10 12:15:34
#>  76:   failed  -1.111111 -0.5555556         NA 2026-06-10 12:15:34
#>  77:   failed  -1.111111 -1.6666667         NA 2026-06-10 12:15:34
#>  78:   failed  -1.111111 -2.7777778         NA 2026-06-10 12:15:34
#>  79:   failed  -1.111111 -3.8888889         NA 2026-06-10 12:15:34
#>  80:   failed  -1.111111 -5.0000000         NA 2026-06-10 12:15:34
#>  81:   failed  -3.333333  5.0000000         NA 2026-06-10 12:15:34
#>  82:   failed  -3.333333  3.8888889         NA 2026-06-10 12:15:34
#>  83:   failed  -3.333333  2.7777778         NA 2026-06-10 12:15:34
#>  84:   failed  -3.333333  1.6666667         NA 2026-06-10 12:15:34
#>  85:   failed  -3.333333  0.5555556         NA 2026-06-10 12:15:34
#>  86:   failed  -3.333333 -0.5555556         NA 2026-06-10 12:15:34
#>  87:   failed  -3.333333 -1.6666667         NA 2026-06-10 12:15:34
#>  88:   failed  -3.333333 -2.7777778         NA 2026-06-10 12:15:34
#>  89:   failed  -3.333333 -3.8888889         NA 2026-06-10 12:15:34
#>  90:   failed  -3.333333 -5.0000000         NA 2026-06-10 12:15:34
#>  91:   failed  -5.555556  5.0000000         NA 2026-06-10 12:15:34
#>  92:   failed  -5.555556  3.8888889         NA 2026-06-10 12:15:34
#>  93:   failed  -5.555556  2.7777778         NA 2026-06-10 12:15:34
#>  94:   failed  -5.555556  1.6666667         NA 2026-06-10 12:15:34
#>  95:   failed  -5.555556  0.5555556         NA 2026-06-10 12:15:34
#>  96:   failed  -5.555556 -0.5555556         NA 2026-06-10 12:15:34
#>  97:   failed  -5.555556 -1.6666667         NA 2026-06-10 12:15:34
#>  98:   failed  -5.555556 -2.7777778         NA 2026-06-10 12:15:34
#>  99:   failed  -5.555556 -3.8888889         NA 2026-06-10 12:15:34
#> 100:   failed  -5.555556 -5.0000000         NA 2026-06-10 12:15:34
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-06-10 12:15:35 2be0c1bc-acf1-4bcc-9ccb-319aca7c382a
#>   2: sinking_raccoon 2026-06-10 12:15:35 8bcafbac-a038-4fed-99d5-1e7165b19b8b
#>   3: sinking_raccoon 2026-06-10 12:15:35 b4ab2867-b52f-4286-8e40-b07fe2f890a4
#>   4: sinking_raccoon 2026-06-10 12:15:35 43a6ee33-95a7-4137-87f5-01ef96ded2c3
#>   5: sinking_raccoon 2026-06-10 12:15:35 53caae53-f72a-4f62-9c26-4453ebe5d6fb
#>   6: sinking_raccoon 2026-06-10 12:15:35 5a1fe4d6-e89c-4ffd-99d4-a8372fe5f608
#>   7: sinking_raccoon 2026-06-10 12:15:35 6da860aa-f78a-4300-8626-22918123357e
#>   8: sinking_raccoon 2026-06-10 12:15:35 382dadef-cdd0-4003-8899-c82696ba70c1
#>   9: sinking_raccoon 2026-06-10 12:15:35 b8865ec2-247e-4854-95e2-23a8feecede3
#>  10: sinking_raccoon 2026-06-10 12:15:35 2594fe2e-cd57-48f0-96c4-2288308e4007
#>  11: sinking_raccoon 2026-06-10 12:15:35 d6506e06-137f-4349-88f8-4de499c2bbbf
#>  12: sinking_raccoon 2026-06-10 12:15:35 88f80244-9054-4243-a8c2-b795518daf1a
#>  13: sinking_raccoon 2026-06-10 12:15:35 c035a2c4-5e0f-4a18-abfd-361657f7551a
#>  14: sinking_raccoon 2026-06-10 12:15:35 c7b9bdf6-436d-473b-80c2-8e7e705cbe27
#>  15: sinking_raccoon 2026-06-10 12:15:35 5175f9c9-474e-4cab-99dc-095974067ed3
#>  16: sinking_raccoon 2026-06-10 12:15:35 087751d8-9ab6-4756-9475-ad9f635bf933
#>  17: sinking_raccoon 2026-06-10 12:15:35 10c4f5c8-5de2-4f5d-b5b4-32c37163918e
#>  18: sinking_raccoon 2026-06-10 12:15:35 c5c87f5e-3cc1-4541-ac20-e626c9eb7ad6
#>  19: sinking_raccoon 2026-06-10 12:15:35 4a2f19be-c98a-4052-a60b-d99590489356
#>  20: sinking_raccoon 2026-06-10 12:15:35 c44a8142-f415-45db-b568-8f9798eb6afa
#>  21:            <NA>                <NA> a2365994-bc22-42b3-b830-426a3e237494
#>  22:            <NA>                <NA> 57640489-bed2-46ed-9983-6f3acc4c7185
#>  23:            <NA>                <NA> 7a93e134-3c87-48c6-9f23-b56fbfda5576
#>  24:            <NA>                <NA> 5216259c-d8b7-491b-8a61-dadce5f74c54
#>  25:            <NA>                <NA> afa26662-d17f-415d-b48d-69e22c5f1b2d
#>  26:            <NA>                <NA> 0db5777c-42d8-4f4f-9c49-6a5f7e73a215
#>  27:            <NA>                <NA> d2bb94c3-4d00-46bb-8790-0fb6863c09be
#>  28:            <NA>                <NA> 1c765309-8827-430b-a0a2-146a223ddcec
#>  29:            <NA>                <NA> ee165136-ca2f-41e3-96c0-ca89d324f7b3
#>  30:            <NA>                <NA> 593f6314-4844-4164-8de5-7782ed0d0e65
#>  31:            <NA>                <NA> 68ac1034-a989-4515-b896-ed3173c368a1
#>  32:            <NA>                <NA> d08869fa-4185-4c48-94a3-436f6c7eb952
#>  33:            <NA>                <NA> c2cbfb91-5b91-4614-be84-92dec4107b27
#>  34:            <NA>                <NA> 1dce8fba-d0b5-4563-af05-7da49a6c5149
#>  35:            <NA>                <NA> 0c51d315-c705-488a-be34-7ef66320f7da
#>  36:            <NA>                <NA> 79d91eec-aea4-4532-b5bb-32b013d9b9ed
#>  37:            <NA>                <NA> 7aaafbfa-cf1b-4487-94b8-72654ef50d22
#>  38:            <NA>                <NA> 55273f34-5468-4e18-a31e-a89e2bcede00
#>  39:            <NA>                <NA> f7edfe36-c207-483b-b254-d98239221ef3
#>  40:            <NA>                <NA> 66337048-404d-4449-adcf-84b313a6802f
#>  41:            <NA>                <NA> e6347a10-bee5-486d-9e2d-ff3606027891
#>  42:            <NA>                <NA> 4c962963-ec0e-4306-8c79-e1eba9fe024e
#>  43:            <NA>                <NA> 2c5e51fc-3003-4a16-8632-96c8defe75ea
#>  44:            <NA>                <NA> d275002f-ed02-42d5-bc3d-459ec79a4eba
#>  45:            <NA>                <NA> dc62e445-55c7-4fe3-a96e-fdbe68ec16e2
#>  46:            <NA>                <NA> 7d41ab7c-f97d-48fb-b926-dd9953604b94
#>  47:            <NA>                <NA> f61f1834-a682-4ce5-abd6-3bee1c2b0d79
#>  48:            <NA>                <NA> 393ac809-affc-4b88-b2be-014e19ac9e38
#>  49:            <NA>                <NA> 4ba813f2-a56a-4378-b692-d1a9784c2da6
#>  50:            <NA>                <NA> cb19151b-a645-4f98-aed2-abe30f791b71
#>  51:            <NA>                <NA> 9a67031d-9093-41ae-9e73-8327e4431eea
#>  52:            <NA>                <NA> 45b35942-21aa-40ca-bc77-fb640305adda
#>  53:            <NA>                <NA> c470ded3-eae1-4fd3-9a49-637562341d81
#>  54:            <NA>                <NA> ef1b94bf-fa83-4f4d-818e-c59d64db7397
#>  55:            <NA>                <NA> a7c91680-f32d-40ee-b288-70e583184ddf
#>  56:            <NA>                <NA> 1fc2c395-0652-47b8-8e8d-6afd6a1a21e6
#>  57:            <NA>                <NA> c5c515db-d8cc-4389-8328-a77e41734594
#>  58:            <NA>                <NA> bc1470b9-5568-4bfb-ac1d-55bec7374e5c
#>  59:            <NA>                <NA> a97068ff-fba6-40d9-a6a4-0ea865bd9788
#>  60:            <NA>                <NA> af3e1692-ffb0-4867-bebc-e6b8f29bb533
#>  61:            <NA>                <NA> 1b3f0721-5ac8-4c14-b367-2bce03e6bffd
#>  62:            <NA>                <NA> 44b98245-95cc-43dc-bdc2-a88d530be26d
#>  63:            <NA>                <NA> 2e3a6d81-b2c0-4d26-99c4-a7bacde14218
#>  64:            <NA>                <NA> f2100f44-6e65-4158-8717-a318614bbc94
#>  65:            <NA>                <NA> ef1abdb3-49c3-4373-ad9d-633bef563f67
#>  66:            <NA>                <NA> 728b9795-4108-4df8-99d0-9613612d1c5f
#>  67:            <NA>                <NA> de064d6d-320b-4c32-9ab6-7396e6bd0d8f
#>  68:            <NA>                <NA> ac75558d-c1c3-442c-a853-e01506c3157e
#>  69:            <NA>                <NA> daab6f13-d788-4e57-9772-87b31677ab43
#>  70:            <NA>                <NA> 2a481a6d-313e-4906-9432-2fba4391d61e
#>  71:            <NA>                <NA> 68b3d575-b148-4355-aef7-1b721f3e0ad8
#>  72:            <NA>                <NA> b471959e-72a3-4dff-ad08-44b35378067c
#>  73:            <NA>                <NA> 69e47b7e-0948-4a30-b342-7ba50a106763
#>  74:            <NA>                <NA> e0ac95d8-67c5-4499-9e9b-f2934aa58fec
#>  75:            <NA>                <NA> c790ce4e-f40b-4c8f-8d70-2d6188a2e940
#>  76:            <NA>                <NA> a1209643-9285-44ff-a291-d712e7e733d2
#>  77:            <NA>                <NA> 26f283e2-1208-47ff-8c21-97520e09afb4
#>  78:            <NA>                <NA> f158fb53-6306-410a-bda5-f812cb4e7674
#>  79:            <NA>                <NA> 4b3e1cc1-df43-4586-9161-0f0479e22bbb
#>  80:            <NA>                <NA> 5d16e327-0bbd-4723-baad-3d26d11f3ada
#>  81:            <NA>                <NA> 3213a624-5951-40f4-a432-21eeab738376
#>  82:            <NA>                <NA> 8d776215-20e3-43cb-b56e-4685d6902a39
#>  83:            <NA>                <NA> 8ad0e2dd-25b8-4305-abe0-297e61bec38a
#>  84:            <NA>                <NA> abd4817f-b49e-4f61-b227-f41ef27595ca
#>  85:            <NA>                <NA> cd1e8f46-cd1f-42bf-8455-dcc4d263b0e1
#>  86:            <NA>                <NA> a3e876e0-0245-41b7-8d43-d15f1d6ef61c
#>  87:            <NA>                <NA> 1c1b0a9e-9b45-42bb-9679-94daa7ab3fcb
#>  88:            <NA>                <NA> b82afff0-83ed-4ed0-8ebf-e2821933c203
#>  89:            <NA>                <NA> bad820ba-3f2d-4fef-bb2c-7749199d8336
#>  90:            <NA>                <NA> edd00302-12b6-4876-96ec-33402fa157f5
#>  91:            <NA>                <NA> c85a494a-b1ad-4c30-8612-5cf41e46b325
#>  92:            <NA>                <NA> ce8a443d-55a5-463b-b8cd-4628e2a205a2
#>  93:            <NA>                <NA> 647e2b84-9972-4c45-8d1c-03878b28e8f9
#>  94:            <NA>                <NA> df5f4f10-4364-4ba4-99e2-54d31bdbec38
#>  95:            <NA>                <NA> d64fa1c4-3176-4f7b-970b-c221453e3a6a
#>  96:            <NA>                <NA> 7eab6c5e-3ace-4226-a8ca-12ee4cb867b3
#>  97:            <NA>                <NA> a2d1cd57-09d4-426e-a548-cd95ac85eecb
#>  98:            <NA>                <NA> f9408990-13d7-4850-9275-5fb14b7e40ee
#>  99:            <NA>                <NA> 5c935e21-f622-4bb2-8152-e6a8286d6b6e
#> 100:            <NA>                <NA> 65544efe-50cc-446f-bceb-b708ad303a05
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
