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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-06-26 10:07:59
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-06-26 10:07:59
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-06-26 10:07:59
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-06-26 10:07:59
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-06-26 10:07:59
#>   6: finished -10.000000  0.5555556 -146.64198 2026-06-26 10:07:59
#>   7: finished -10.000000  1.6666667 -155.77778 2026-06-26 10:07:59
#>   8: finished -10.000000  2.7777778 -167.38272 2026-06-26 10:07:59
#>   9: finished -10.000000  3.8888889 -181.45679 2026-06-26 10:07:59
#>  10: finished -10.000000  5.0000000 -198.00000 2026-06-26 10:07:59
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-06-26 10:07:59
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-06-26 10:07:59
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-06-26 10:07:59
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-06-26 10:07:59
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-06-26 10:07:59
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-06-26 10:07:59
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-06-26 10:07:59
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-06-26 10:07:59
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-06-26 10:07:59
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-06-26 10:07:59
#>  21:   failed  10.000000  5.0000000         NA 2026-06-26 10:07:59
#>  22:   failed  10.000000  3.8888889         NA 2026-06-26 10:07:59
#>  23:   failed  10.000000  2.7777778         NA 2026-06-26 10:07:59
#>  24:   failed  10.000000  1.6666667         NA 2026-06-26 10:07:59
#>  25:   failed  10.000000  0.5555556         NA 2026-06-26 10:07:59
#>  26:   failed  10.000000 -0.5555556         NA 2026-06-26 10:07:59
#>  27:   failed  10.000000 -1.6666667         NA 2026-06-26 10:07:59
#>  28:   failed  10.000000 -2.7777778         NA 2026-06-26 10:07:59
#>  29:   failed  10.000000 -3.8888889         NA 2026-06-26 10:07:59
#>  30:   failed  10.000000 -5.0000000         NA 2026-06-26 10:07:59
#>  31:   failed   7.777778  5.0000000         NA 2026-06-26 10:07:59
#>  32:   failed   7.777778  3.8888889         NA 2026-06-26 10:07:59
#>  33:   failed   7.777778  2.7777778         NA 2026-06-26 10:07:59
#>  34:   failed   7.777778  1.6666667         NA 2026-06-26 10:07:59
#>  35:   failed   7.777778  0.5555556         NA 2026-06-26 10:07:59
#>  36:   failed   7.777778 -0.5555556         NA 2026-06-26 10:07:59
#>  37:   failed   7.777778 -1.6666667         NA 2026-06-26 10:07:59
#>  38:   failed   7.777778 -2.7777778         NA 2026-06-26 10:07:59
#>  39:   failed   7.777778 -3.8888889         NA 2026-06-26 10:07:59
#>  40:   failed   7.777778 -5.0000000         NA 2026-06-26 10:07:59
#>  41:   failed   5.555556  5.0000000         NA 2026-06-26 10:07:59
#>  42:   failed   5.555556  3.8888889         NA 2026-06-26 10:07:59
#>  43:   failed   5.555556  2.7777778         NA 2026-06-26 10:07:59
#>  44:   failed   5.555556  1.6666667         NA 2026-06-26 10:07:59
#>  45:   failed   5.555556  0.5555556         NA 2026-06-26 10:07:59
#>  46:   failed   5.555556 -0.5555556         NA 2026-06-26 10:07:59
#>  47:   failed   5.555556 -1.6666667         NA 2026-06-26 10:07:59
#>  48:   failed   5.555556 -2.7777778         NA 2026-06-26 10:07:59
#>  49:   failed   5.555556 -3.8888889         NA 2026-06-26 10:07:59
#>  50:   failed   5.555556 -5.0000000         NA 2026-06-26 10:07:59
#>  51:   failed   3.333333  5.0000000         NA 2026-06-26 10:07:59
#>  52:   failed   3.333333  3.8888889         NA 2026-06-26 10:07:59
#>  53:   failed   3.333333  2.7777778         NA 2026-06-26 10:07:59
#>  54:   failed   3.333333  1.6666667         NA 2026-06-26 10:07:59
#>  55:   failed   3.333333  0.5555556         NA 2026-06-26 10:07:59
#>  56:   failed   3.333333 -0.5555556         NA 2026-06-26 10:07:59
#>  57:   failed   3.333333 -1.6666667         NA 2026-06-26 10:07:59
#>  58:   failed   3.333333 -2.7777778         NA 2026-06-26 10:07:59
#>  59:   failed   3.333333 -3.8888889         NA 2026-06-26 10:07:59
#>  60:   failed   3.333333 -5.0000000         NA 2026-06-26 10:07:59
#>  61:   failed   1.111111  5.0000000         NA 2026-06-26 10:07:59
#>  62:   failed   1.111111  3.8888889         NA 2026-06-26 10:07:59
#>  63:   failed   1.111111  2.7777778         NA 2026-06-26 10:07:59
#>  64:   failed   1.111111  1.6666667         NA 2026-06-26 10:07:59
#>  65:   failed   1.111111  0.5555556         NA 2026-06-26 10:07:59
#>  66:   failed   1.111111 -0.5555556         NA 2026-06-26 10:07:59
#>  67:   failed   1.111111 -1.6666667         NA 2026-06-26 10:07:59
#>  68:   failed   1.111111 -2.7777778         NA 2026-06-26 10:07:59
#>  69:   failed   1.111111 -3.8888889         NA 2026-06-26 10:07:59
#>  70:   failed   1.111111 -5.0000000         NA 2026-06-26 10:07:59
#>  71:   failed  -1.111111  5.0000000         NA 2026-06-26 10:07:59
#>  72:   failed  -1.111111  3.8888889         NA 2026-06-26 10:07:59
#>  73:   failed  -1.111111  2.7777778         NA 2026-06-26 10:07:59
#>  74:   failed  -1.111111  1.6666667         NA 2026-06-26 10:07:59
#>  75:   failed  -1.111111  0.5555556         NA 2026-06-26 10:07:59
#>  76:   failed  -1.111111 -0.5555556         NA 2026-06-26 10:07:59
#>  77:   failed  -1.111111 -1.6666667         NA 2026-06-26 10:07:59
#>  78:   failed  -1.111111 -2.7777778         NA 2026-06-26 10:07:59
#>  79:   failed  -1.111111 -3.8888889         NA 2026-06-26 10:07:59
#>  80:   failed  -1.111111 -5.0000000         NA 2026-06-26 10:07:59
#>  81:   failed  -3.333333  5.0000000         NA 2026-06-26 10:07:59
#>  82:   failed  -3.333333  3.8888889         NA 2026-06-26 10:07:59
#>  83:   failed  -3.333333  2.7777778         NA 2026-06-26 10:07:59
#>  84:   failed  -3.333333  1.6666667         NA 2026-06-26 10:07:59
#>  85:   failed  -3.333333  0.5555556         NA 2026-06-26 10:07:59
#>  86:   failed  -3.333333 -0.5555556         NA 2026-06-26 10:07:59
#>  87:   failed  -3.333333 -1.6666667         NA 2026-06-26 10:07:59
#>  88:   failed  -3.333333 -2.7777778         NA 2026-06-26 10:07:59
#>  89:   failed  -3.333333 -3.8888889         NA 2026-06-26 10:07:59
#>  90:   failed  -3.333333 -5.0000000         NA 2026-06-26 10:07:59
#>  91:   failed  -5.555556  5.0000000         NA 2026-06-26 10:07:59
#>  92:   failed  -5.555556  3.8888889         NA 2026-06-26 10:07:59
#>  93:   failed  -5.555556  2.7777778         NA 2026-06-26 10:07:59
#>  94:   failed  -5.555556  1.6666667         NA 2026-06-26 10:07:59
#>  95:   failed  -5.555556  0.5555556         NA 2026-06-26 10:07:59
#>  96:   failed  -5.555556 -0.5555556         NA 2026-06-26 10:07:59
#>  97:   failed  -5.555556 -1.6666667         NA 2026-06-26 10:07:59
#>  98:   failed  -5.555556 -2.7777778         NA 2026-06-26 10:07:59
#>  99:   failed  -5.555556 -3.8888889         NA 2026-06-26 10:07:59
#> 100:   failed  -5.555556 -5.0000000         NA 2026-06-26 10:07:59
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-06-26 10:08:00 07150b9b-d80d-4a02-a619-496d4267e5d0
#>   2: sinking_raccoon 2026-06-26 10:08:00 8236e637-bdb8-4160-b9ec-d4864664b12c
#>   3: sinking_raccoon 2026-06-26 10:08:00 880bdb6c-4fb5-41d0-b84d-04736d8225da
#>   4: sinking_raccoon 2026-06-26 10:08:00 5bba49f3-a4ed-47ce-be0b-d6822180362c
#>   5: sinking_raccoon 2026-06-26 10:08:00 63ec25e8-c3f1-4c21-b864-570c8c1cfb2b
#>   6: sinking_raccoon 2026-06-26 10:08:00 0787bc6c-2bd1-42b9-ac3d-22c6c860a675
#>   7: sinking_raccoon 2026-06-26 10:08:00 d96f80df-5145-4ebf-9377-f661c8e126e3
#>   8: sinking_raccoon 2026-06-26 10:08:00 b4e59fb0-930d-438a-a607-921d38328a0c
#>   9: sinking_raccoon 2026-06-26 10:08:00 5493ebfb-5513-4a96-ba8e-484b2d95244d
#>  10: sinking_raccoon 2026-06-26 10:08:00 4f1ed08e-db4b-4158-8828-18a4fcc1aa26
#>  11: sinking_raccoon 2026-06-26 10:08:00 b18421e3-b5fa-4845-a876-325963365c35
#>  12: sinking_raccoon 2026-06-26 10:08:00 610ec179-be98-4fe3-8e4f-591ca62ffe92
#>  13: sinking_raccoon 2026-06-26 10:08:00 ad0e1b9e-6b2d-4c28-b477-3a888a092193
#>  14: sinking_raccoon 2026-06-26 10:08:00 0a5c2ac7-a208-41c1-990b-0c9b08114df9
#>  15: sinking_raccoon 2026-06-26 10:08:00 6945773c-c27f-49b4-a5ea-4d3e540cd2f9
#>  16: sinking_raccoon 2026-06-26 10:08:00 71829b2d-853d-42b3-a6e4-65a8889c68f6
#>  17: sinking_raccoon 2026-06-26 10:08:00 696324d7-426d-4784-b06e-826f38f0a68d
#>  18: sinking_raccoon 2026-06-26 10:08:00 1b6595b0-547a-4ddf-a864-abad0d3edb4e
#>  19: sinking_raccoon 2026-06-26 10:08:00 0e643a03-6dba-49a8-8856-61aa1acf80ce
#>  20: sinking_raccoon 2026-06-26 10:08:00 0fb64c73-108a-41d5-8437-4f4de6332f8b
#>  21:            <NA>                <NA> de52fd77-16b3-4de0-8b20-a64ca8c2b148
#>  22:            <NA>                <NA> 1cc0ac49-7ab5-41d7-b67a-c119511879e8
#>  23:            <NA>                <NA> ef673d79-4579-44de-b90d-752462a65594
#>  24:            <NA>                <NA> 9f39e5b5-06be-4b8c-9e83-5654892dc968
#>  25:            <NA>                <NA> 0c0cbc35-1d11-4e44-8170-ac34f3886c2f
#>  26:            <NA>                <NA> 3769cafe-bcf5-43e6-9229-d9a17ee6a6eb
#>  27:            <NA>                <NA> 9c5132b3-9a6d-44a3-81a8-e770486bfe15
#>  28:            <NA>                <NA> ff011bc7-b6c2-47cc-8dc1-24c143023b77
#>  29:            <NA>                <NA> 28e7b6fc-3cb2-49ab-995e-65866b23d9f8
#>  30:            <NA>                <NA> 61cd7b7f-f000-4aad-b8e7-4ffe68c9c86e
#>  31:            <NA>                <NA> 89f6aaf1-1b64-43ef-af56-c8288a8e310c
#>  32:            <NA>                <NA> 67617827-227d-47f0-9be4-4d751f4116b3
#>  33:            <NA>                <NA> c9196b97-9e0d-463f-8232-c26248e82b3d
#>  34:            <NA>                <NA> 4eea432b-53b0-4380-9100-b0b4bd5650d9
#>  35:            <NA>                <NA> 7de34a3c-528b-4521-a1b2-6170ca7a1ef0
#>  36:            <NA>                <NA> 45364b99-2cb1-44c6-9b2f-d552488cdd31
#>  37:            <NA>                <NA> 7dfd701d-fedb-455f-b57f-3bed3be54553
#>  38:            <NA>                <NA> cf0a1f26-3d84-41a9-87b0-ed0d4420ec99
#>  39:            <NA>                <NA> 0a9cb26d-914c-4535-96ec-507ccb26c5d4
#>  40:            <NA>                <NA> 62086c00-607c-4e9b-afae-40e9c981f462
#>  41:            <NA>                <NA> 74bc1bf6-caf7-462e-9cdf-0019e6b31c0c
#>  42:            <NA>                <NA> 69b85ecc-6090-4c44-a1e6-cab3085e4ef3
#>  43:            <NA>                <NA> 3c07156b-c630-4e1b-a73d-712b654f790a
#>  44:            <NA>                <NA> 07dc4567-5f8e-4ce8-b52e-8380adeef379
#>  45:            <NA>                <NA> 164e7a9b-4462-4bad-94bb-1a86e7e2b4d4
#>  46:            <NA>                <NA> 98d827aa-135f-488f-b33c-f7a85fc60bc5
#>  47:            <NA>                <NA> 5a1dcb53-b2a6-49ab-9b37-fc2eef670c02
#>  48:            <NA>                <NA> 507b4c6b-ab0e-4c5d-951a-6aaf60c2ef3e
#>  49:            <NA>                <NA> c8d3cf7a-603b-4dc0-ade6-cb56eba1858a
#>  50:            <NA>                <NA> 46d89b23-4f42-42c9-931b-a0ac1ee74a08
#>  51:            <NA>                <NA> 7517d98e-52d2-4a26-be3a-87cf1c040e01
#>  52:            <NA>                <NA> c1ce30b1-d287-411d-808a-e2171c358dc9
#>  53:            <NA>                <NA> f7b6e62f-eafb-4422-8089-89228cc582d8
#>  54:            <NA>                <NA> ee630141-5060-41f9-a5fe-1f34e57d5948
#>  55:            <NA>                <NA> fa53747d-84ee-43a9-8477-34f44a1353b8
#>  56:            <NA>                <NA> 4a8b98f4-3022-48ce-8f8f-b2689dcab7fc
#>  57:            <NA>                <NA> dd1623b8-8d2f-4789-9d1c-47c86d3610d5
#>  58:            <NA>                <NA> c77cfdd4-a191-435b-a7da-d4f42180da94
#>  59:            <NA>                <NA> d9cf2667-a4bc-4ba2-b235-17ee3245822c
#>  60:            <NA>                <NA> e6d1e854-31d2-42dd-82fe-48401b42ba00
#>  61:            <NA>                <NA> 6aef1230-b841-48e2-b0ba-0e2966fd00cf
#>  62:            <NA>                <NA> ae2584bc-6208-4903-887e-a298878c0b8a
#>  63:            <NA>                <NA> 19e60cb9-112d-43de-ba77-99f9ecfabb6a
#>  64:            <NA>                <NA> 215c7969-5047-4fcd-8246-3b1817e1cbc1
#>  65:            <NA>                <NA> cd4c9dc1-b87a-4317-82ff-6fb22aa7165d
#>  66:            <NA>                <NA> 7b373145-def7-4899-a423-4b094909e687
#>  67:            <NA>                <NA> 87fcbee3-2a01-4d43-ba64-cd9b9dd66172
#>  68:            <NA>                <NA> 2313d025-a9bb-4d3c-ade9-c0df2e451f07
#>  69:            <NA>                <NA> 8fe213cd-6786-4fb3-8ec1-38a0728da245
#>  70:            <NA>                <NA> 683fa645-2de2-4527-8b36-ea0664d9ff45
#>  71:            <NA>                <NA> 8b7b491f-6326-4c28-922f-fd43ebe8b057
#>  72:            <NA>                <NA> 2da58f63-d260-4372-af75-9244ba0e9e24
#>  73:            <NA>                <NA> 984ad33f-ee78-4cc1-ab12-28f321b0f7a2
#>  74:            <NA>                <NA> d683cc30-bc06-457a-b3e4-67991f2af73c
#>  75:            <NA>                <NA> 6d3eedce-0019-4784-bd6d-39bea4a94d87
#>  76:            <NA>                <NA> 3ade5892-c46c-462e-9df7-05745590ecc6
#>  77:            <NA>                <NA> 54ae4975-994a-49a9-a7d6-6185649c4e9c
#>  78:            <NA>                <NA> 6713cb13-50bf-4548-8754-c1db48dc70a6
#>  79:            <NA>                <NA> aab0c224-cb0a-4be1-8009-d5b3780a8a25
#>  80:            <NA>                <NA> 589476e7-a071-4e03-bae8-82cef5d6485e
#>  81:            <NA>                <NA> d4cbab37-0341-43de-975b-54a7c4303ccd
#>  82:            <NA>                <NA> b9562ae8-3b92-433b-938c-dc8629d4878b
#>  83:            <NA>                <NA> 3dcead69-0ca2-4433-8ce4-125c03c72eb3
#>  84:            <NA>                <NA> 8bd19a51-227c-4728-81bd-47153d14d156
#>  85:            <NA>                <NA> 1ea34c93-25be-45c6-8fd2-174d9b9f15ff
#>  86:            <NA>                <NA> e2e42beb-8154-4678-9301-377b01e3e1af
#>  87:            <NA>                <NA> 14c81a18-9f73-4afd-bb14-f266263c7bb2
#>  88:            <NA>                <NA> 9f09dbf8-95aa-458d-a10d-e0c143f53e61
#>  89:            <NA>                <NA> 602805d4-047e-4b23-b235-b412a3e3b4a3
#>  90:            <NA>                <NA> 8634d748-66e7-4e0e-948a-86b9bc15f0ca
#>  91:            <NA>                <NA> 6526adeb-90e7-4eb4-899d-c28ce78a1e8b
#>  92:            <NA>                <NA> e2fd1e98-5b76-4119-8905-3eae4a6528c4
#>  93:            <NA>                <NA> f16ddf78-83eb-4508-b243-6767e1090916
#>  94:            <NA>                <NA> bc9144c9-b1f1-4246-bf1b-33b5ecabcf41
#>  95:            <NA>                <NA> 397a267f-f6d6-4aad-9390-48e0dc7a5aad
#>  96:            <NA>                <NA> b9eef239-5fdc-488b-99f1-5a83dd475cce
#>  97:            <NA>                <NA> 72b29a23-b597-48c1-b2d7-29b58a1ed360
#>  98:            <NA>                <NA> a992791f-f731-4f0f-91ec-7ea5caa4b467
#>  99:            <NA>                <NA> 88be2d45-905b-4e5b-a294-3d9d82261334
#> 100:            <NA>                <NA> 6225c6b5-7ed3-4519-9de9-60590833fea2
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
