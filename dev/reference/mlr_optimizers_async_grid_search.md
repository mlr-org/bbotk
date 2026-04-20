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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-04-20 15:43:29
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-04-20 15:43:29
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-04-20 15:43:29
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-04-20 15:43:29
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-04-20 15:43:29
#>   6: finished -10.000000  0.5555556 -146.64198 2026-04-20 15:43:29
#>   7: finished -10.000000  1.6666667 -155.77778 2026-04-20 15:43:29
#>   8: finished -10.000000  2.7777778 -167.38272 2026-04-20 15:43:29
#>   9: finished -10.000000  3.8888889 -181.45679 2026-04-20 15:43:29
#>  10: finished -10.000000  5.0000000 -198.00000 2026-04-20 15:43:29
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-04-20 15:43:29
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-04-20 15:43:29
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-04-20 15:43:29
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-04-20 15:43:29
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-04-20 15:43:29
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-04-20 15:43:29
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-04-20 15:43:29
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-04-20 15:43:29
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-04-20 15:43:29
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-04-20 15:43:29
#>  21:   failed  10.000000  5.0000000         NA 2026-04-20 15:43:29
#>  22:   failed  10.000000  3.8888889         NA 2026-04-20 15:43:29
#>  23:   failed  10.000000  2.7777778         NA 2026-04-20 15:43:29
#>  24:   failed  10.000000  1.6666667         NA 2026-04-20 15:43:29
#>  25:   failed  10.000000  0.5555556         NA 2026-04-20 15:43:29
#>  26:   failed  10.000000 -0.5555556         NA 2026-04-20 15:43:29
#>  27:   failed  10.000000 -1.6666667         NA 2026-04-20 15:43:29
#>  28:   failed  10.000000 -2.7777778         NA 2026-04-20 15:43:29
#>  29:   failed  10.000000 -3.8888889         NA 2026-04-20 15:43:29
#>  30:   failed  10.000000 -5.0000000         NA 2026-04-20 15:43:29
#>  31:   failed   7.777778  5.0000000         NA 2026-04-20 15:43:29
#>  32:   failed   7.777778  3.8888889         NA 2026-04-20 15:43:29
#>  33:   failed   7.777778  2.7777778         NA 2026-04-20 15:43:29
#>  34:   failed   7.777778  1.6666667         NA 2026-04-20 15:43:29
#>  35:   failed   7.777778  0.5555556         NA 2026-04-20 15:43:29
#>  36:   failed   7.777778 -0.5555556         NA 2026-04-20 15:43:29
#>  37:   failed   7.777778 -1.6666667         NA 2026-04-20 15:43:29
#>  38:   failed   7.777778 -2.7777778         NA 2026-04-20 15:43:29
#>  39:   failed   7.777778 -3.8888889         NA 2026-04-20 15:43:29
#>  40:   failed   7.777778 -5.0000000         NA 2026-04-20 15:43:29
#>  41:   failed   5.555556  5.0000000         NA 2026-04-20 15:43:29
#>  42:   failed   5.555556  3.8888889         NA 2026-04-20 15:43:29
#>  43:   failed   5.555556  2.7777778         NA 2026-04-20 15:43:29
#>  44:   failed   5.555556  1.6666667         NA 2026-04-20 15:43:29
#>  45:   failed   5.555556  0.5555556         NA 2026-04-20 15:43:29
#>  46:   failed   5.555556 -0.5555556         NA 2026-04-20 15:43:29
#>  47:   failed   5.555556 -1.6666667         NA 2026-04-20 15:43:29
#>  48:   failed   5.555556 -2.7777778         NA 2026-04-20 15:43:29
#>  49:   failed   5.555556 -3.8888889         NA 2026-04-20 15:43:29
#>  50:   failed   5.555556 -5.0000000         NA 2026-04-20 15:43:29
#>  51:   failed   3.333333  5.0000000         NA 2026-04-20 15:43:29
#>  52:   failed   3.333333  3.8888889         NA 2026-04-20 15:43:29
#>  53:   failed   3.333333  2.7777778         NA 2026-04-20 15:43:29
#>  54:   failed   3.333333  1.6666667         NA 2026-04-20 15:43:29
#>  55:   failed   3.333333  0.5555556         NA 2026-04-20 15:43:29
#>  56:   failed   3.333333 -0.5555556         NA 2026-04-20 15:43:29
#>  57:   failed   3.333333 -1.6666667         NA 2026-04-20 15:43:29
#>  58:   failed   3.333333 -2.7777778         NA 2026-04-20 15:43:29
#>  59:   failed   3.333333 -3.8888889         NA 2026-04-20 15:43:29
#>  60:   failed   3.333333 -5.0000000         NA 2026-04-20 15:43:29
#>  61:   failed   1.111111  5.0000000         NA 2026-04-20 15:43:29
#>  62:   failed   1.111111  3.8888889         NA 2026-04-20 15:43:29
#>  63:   failed   1.111111  2.7777778         NA 2026-04-20 15:43:29
#>  64:   failed   1.111111  1.6666667         NA 2026-04-20 15:43:29
#>  65:   failed   1.111111  0.5555556         NA 2026-04-20 15:43:29
#>  66:   failed   1.111111 -0.5555556         NA 2026-04-20 15:43:29
#>  67:   failed   1.111111 -1.6666667         NA 2026-04-20 15:43:29
#>  68:   failed   1.111111 -2.7777778         NA 2026-04-20 15:43:29
#>  69:   failed   1.111111 -3.8888889         NA 2026-04-20 15:43:29
#>  70:   failed   1.111111 -5.0000000         NA 2026-04-20 15:43:29
#>  71:   failed  -1.111111  5.0000000         NA 2026-04-20 15:43:29
#>  72:   failed  -1.111111  3.8888889         NA 2026-04-20 15:43:29
#>  73:   failed  -1.111111  2.7777778         NA 2026-04-20 15:43:29
#>  74:   failed  -1.111111  1.6666667         NA 2026-04-20 15:43:29
#>  75:   failed  -1.111111  0.5555556         NA 2026-04-20 15:43:29
#>  76:   failed  -1.111111 -0.5555556         NA 2026-04-20 15:43:29
#>  77:   failed  -1.111111 -1.6666667         NA 2026-04-20 15:43:29
#>  78:   failed  -1.111111 -2.7777778         NA 2026-04-20 15:43:29
#>  79:   failed  -1.111111 -3.8888889         NA 2026-04-20 15:43:29
#>  80:   failed  -1.111111 -5.0000000         NA 2026-04-20 15:43:29
#>  81:   failed  -3.333333  5.0000000         NA 2026-04-20 15:43:29
#>  82:   failed  -3.333333  3.8888889         NA 2026-04-20 15:43:29
#>  83:   failed  -3.333333  2.7777778         NA 2026-04-20 15:43:29
#>  84:   failed  -3.333333  1.6666667         NA 2026-04-20 15:43:29
#>  85:   failed  -3.333333  0.5555556         NA 2026-04-20 15:43:29
#>  86:   failed  -3.333333 -0.5555556         NA 2026-04-20 15:43:29
#>  87:   failed  -3.333333 -1.6666667         NA 2026-04-20 15:43:29
#>  88:   failed  -3.333333 -2.7777778         NA 2026-04-20 15:43:29
#>  89:   failed  -3.333333 -3.8888889         NA 2026-04-20 15:43:29
#>  90:   failed  -3.333333 -5.0000000         NA 2026-04-20 15:43:29
#>  91:   failed  -5.555556  5.0000000         NA 2026-04-20 15:43:29
#>  92:   failed  -5.555556  3.8888889         NA 2026-04-20 15:43:29
#>  93:   failed  -5.555556  2.7777778         NA 2026-04-20 15:43:29
#>  94:   failed  -5.555556  1.6666667         NA 2026-04-20 15:43:29
#>  95:   failed  -5.555556  0.5555556         NA 2026-04-20 15:43:29
#>  96:   failed  -5.555556 -0.5555556         NA 2026-04-20 15:43:29
#>  97:   failed  -5.555556 -1.6666667         NA 2026-04-20 15:43:29
#>  98:   failed  -5.555556 -2.7777778         NA 2026-04-20 15:43:29
#>  99:   failed  -5.555556 -3.8888889         NA 2026-04-20 15:43:29
#> 100:   failed  -5.555556 -5.0000000         NA 2026-04-20 15:43:29
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-04-20 15:43:30 6497a73c-4a5b-4c91-993f-b9e2a66dd80c
#>   2: sinking_raccoon 2026-04-20 15:43:30 ebc14efa-fcc7-4107-92c8-f2e289d608f4
#>   3: sinking_raccoon 2026-04-20 15:43:30 7aa71de9-babf-4fae-82a5-9d4158c28145
#>   4: sinking_raccoon 2026-04-20 15:43:30 fb51512b-ac15-43fe-b041-fb6069f392b5
#>   5: sinking_raccoon 2026-04-20 15:43:30 36a3b72e-082a-489f-b34d-363d0a1ce639
#>   6: sinking_raccoon 2026-04-20 15:43:30 7d32b835-16ac-4cdd-a4bb-eabfc144bb67
#>   7: sinking_raccoon 2026-04-20 15:43:30 57c1c128-f506-4edd-b3ba-35e82a4057d6
#>   8: sinking_raccoon 2026-04-20 15:43:30 bed8a366-0b3e-4bd8-ad6f-cc30eb9a2437
#>   9: sinking_raccoon 2026-04-20 15:43:30 746b1d61-01d5-46b8-99fa-4cb5df21b9a3
#>  10: sinking_raccoon 2026-04-20 15:43:30 12041e2d-0ded-46ae-b978-78f1b1ce80ab
#>  11: sinking_raccoon 2026-04-20 15:43:30 e284de85-578b-4a59-bdf2-5d75d40597f2
#>  12: sinking_raccoon 2026-04-20 15:43:30 94761080-31a1-47d9-b814-186d51957c25
#>  13: sinking_raccoon 2026-04-20 15:43:30 a606c70a-b89a-452f-94f2-a22d51d123ca
#>  14: sinking_raccoon 2026-04-20 15:43:30 0b41599e-1e9b-48a1-891c-0de0f63b80ab
#>  15: sinking_raccoon 2026-04-20 15:43:30 51d4efb8-b72a-4b70-9ac1-43bf3da817c9
#>  16: sinking_raccoon 2026-04-20 15:43:30 b85a7cee-5b57-49e5-9356-405a8fa4a2a7
#>  17: sinking_raccoon 2026-04-20 15:43:30 51168a36-565d-4991-a8ec-030a66c8378a
#>  18: sinking_raccoon 2026-04-20 15:43:30 a973f8de-1c1f-4e15-9ac6-11f0f0939ec7
#>  19: sinking_raccoon 2026-04-20 15:43:30 5214ed69-414a-4e31-b12d-655a9ddd04b3
#>  20: sinking_raccoon 2026-04-20 15:43:30 80b77c9b-ab27-4837-875b-9e408642d50e
#>  21:            <NA>                <NA> 0e5055d5-62d6-44a3-87f1-f830b3241ac8
#>  22:            <NA>                <NA> 2801d615-7c6d-4a85-a828-512c8117ae89
#>  23:            <NA>                <NA> db3bf637-cbf4-4019-b7e5-8cb5b1021e44
#>  24:            <NA>                <NA> 13233246-904f-458a-86cb-6c3e6a1bc964
#>  25:            <NA>                <NA> bd630039-64b2-4c36-9316-95e441e514ff
#>  26:            <NA>                <NA> c6338df4-1ae2-40cc-bb92-1d0c1eb60a4f
#>  27:            <NA>                <NA> 08d7c38a-08f3-4b10-bb4a-2aaa1b69e1a1
#>  28:            <NA>                <NA> 32b86c38-eece-4cef-8794-925ef836e6b9
#>  29:            <NA>                <NA> 9053dff8-ac3d-4fac-8808-68f9f94bf502
#>  30:            <NA>                <NA> 6845b91b-19de-4b5e-bd12-4bc62aeb506d
#>  31:            <NA>                <NA> 6c6b1e4b-c1cb-41cb-bd15-79b4ec76cc3c
#>  32:            <NA>                <NA> ceddf782-58bd-44c4-ac65-272f4ee614e1
#>  33:            <NA>                <NA> 191c7f54-362e-4d8d-bfd4-b3b5653943c0
#>  34:            <NA>                <NA> a1fd4f2d-ed94-4dd9-82f3-9f8f0df8cb4b
#>  35:            <NA>                <NA> 61ab2e38-202f-4587-af11-c86d42f30c5a
#>  36:            <NA>                <NA> edb53e4c-d5ca-468b-a3b9-c7a9d8d7080d
#>  37:            <NA>                <NA> 3ec60229-3c3f-4f74-8b71-b99af27f2253
#>  38:            <NA>                <NA> 953bd948-92c5-49d3-b035-1ecb4d5c7762
#>  39:            <NA>                <NA> dd14308a-02e2-4ec9-8a4c-d5c49134b160
#>  40:            <NA>                <NA> 20268613-4072-48ba-a90f-8e392cc10394
#>  41:            <NA>                <NA> ac8f0c25-6eaf-4175-84ee-663e7b84675e
#>  42:            <NA>                <NA> 66af0e68-1f99-4d83-9361-1f7eca1ac234
#>  43:            <NA>                <NA> 53f76129-26e8-4046-8859-1f0b414b387b
#>  44:            <NA>                <NA> 80db09b6-92f3-431c-8c9f-62469e7be5b2
#>  45:            <NA>                <NA> c41f813f-8a03-47ba-879b-bc43f6fcd8c2
#>  46:            <NA>                <NA> 3196180a-71cc-4ec0-851f-a6ff3e2eb2db
#>  47:            <NA>                <NA> ffca27be-0a09-4ce7-809c-327139e7dbc3
#>  48:            <NA>                <NA> fe14bb44-9ecd-469b-976b-856497efba87
#>  49:            <NA>                <NA> 94fe9052-4724-4949-9c8b-4e6f9f22ed1a
#>  50:            <NA>                <NA> e332e1c4-5b97-401a-8b1b-18a10219ee8f
#>  51:            <NA>                <NA> 6a71a911-e91a-43bd-aed7-0611de02fe28
#>  52:            <NA>                <NA> 07986279-bd86-4c58-9a6a-9527a18a4067
#>  53:            <NA>                <NA> 2cd9ed49-bf68-4ff7-8720-5250dc91bce2
#>  54:            <NA>                <NA> 80c3a486-ada1-4017-bd25-b70819bc76a9
#>  55:            <NA>                <NA> 9be0857f-4fc7-4fe8-bc57-26dae8d45c1c
#>  56:            <NA>                <NA> e8f32f14-4d01-4695-9b6b-eab052b303df
#>  57:            <NA>                <NA> ce7ba30e-6897-4815-b46e-ac88621260cc
#>  58:            <NA>                <NA> 49b47d59-34c7-4346-ad14-c6560a593c58
#>  59:            <NA>                <NA> a325763a-8268-4ad0-9aaa-69dc2a44c8ce
#>  60:            <NA>                <NA> 8fafb43a-9539-492c-b631-f3c8fc19d5bb
#>  61:            <NA>                <NA> f2e836fa-ea8b-4d16-bd77-06dffdf82ad7
#>  62:            <NA>                <NA> 843ee020-16ca-4525-b318-dab8b09386b9
#>  63:            <NA>                <NA> b286d3a9-e7e3-41b2-8bb4-03d4430fa4a1
#>  64:            <NA>                <NA> c114b7d2-c5be-415c-ac2d-e8417afbc787
#>  65:            <NA>                <NA> c4064316-8809-4fdc-a127-e3cf7bfe6677
#>  66:            <NA>                <NA> ddde3c7a-7f13-4f6a-94a2-d0b96ce98f54
#>  67:            <NA>                <NA> 52b30a1d-e42d-494c-bc0a-31edfe2a31e5
#>  68:            <NA>                <NA> c8777455-601f-4027-adce-c26fa0dab4a4
#>  69:            <NA>                <NA> 1ee0ce4d-254b-4de9-a682-8400d9b4f33f
#>  70:            <NA>                <NA> c17d26b1-92ae-4fdd-9551-48da5048f8a5
#>  71:            <NA>                <NA> f463e96d-9072-4833-b3ae-f8e25ee72904
#>  72:            <NA>                <NA> 0f36fa57-83d5-4403-901f-3a3bf2633af8
#>  73:            <NA>                <NA> 7eb6e01c-16d8-4047-a468-44fdb0146a50
#>  74:            <NA>                <NA> dc890372-45ce-4d7b-a95d-920206cb7db2
#>  75:            <NA>                <NA> b00707ad-a35a-4181-be76-bbd53bc88261
#>  76:            <NA>                <NA> d0ae3c3c-2366-4bfa-8fcb-e29c4b098fba
#>  77:            <NA>                <NA> 3accf658-ec61-40f5-bc34-d6e694b85938
#>  78:            <NA>                <NA> c609282b-c717-4fe8-b096-15f55f1d0b07
#>  79:            <NA>                <NA> b2ab11ad-7d64-4e31-95aa-6ca4b69d97a3
#>  80:            <NA>                <NA> f5f9e123-ad89-4ddf-bf74-a47dd32d2c73
#>  81:            <NA>                <NA> c751cad4-77c5-4a62-a64c-af9b5090223b
#>  82:            <NA>                <NA> ddcf747e-9347-4cd1-927c-e5517bee772b
#>  83:            <NA>                <NA> 7d9fb7cd-66dd-44ba-ab4b-fe2213665a3e
#>  84:            <NA>                <NA> e902f3b2-d36b-40a4-b574-83194bc6bfe4
#>  85:            <NA>                <NA> 9bb57ca7-4f78-49f1-bb1c-765a02746674
#>  86:            <NA>                <NA> 5706638a-2999-42b4-aaae-17cee96631da
#>  87:            <NA>                <NA> e681e959-f67c-4402-9a67-464c17ea3ff1
#>  88:            <NA>                <NA> 7622d4cf-9fe7-4c5d-9799-e8eef29cffc4
#>  89:            <NA>                <NA> d5125d3e-479a-4d71-8f38-a66a0a47a3fe
#>  90:            <NA>                <NA> f2871b6b-8cbd-49a3-9bf3-af1571c4d4cd
#>  91:            <NA>                <NA> e6de3817-dda8-4dae-844b-ac5d45b11736
#>  92:            <NA>                <NA> a427ed41-c26b-4d46-8b4c-2d532d3aa669
#>  93:            <NA>                <NA> db13daed-284b-40b1-ab41-415f685453d9
#>  94:            <NA>                <NA> afa7916c-bcae-4169-a6f4-b269b54aff96
#>  95:            <NA>                <NA> e2a13b3f-9ac6-4c27-9640-014f0ab44d2f
#>  96:            <NA>                <NA> 6dce29a6-560c-4d90-ab1d-008ba8acc369
#>  97:            <NA>                <NA> 4fbfd965-b572-4138-890a-2ed3856f3017
#>  98:            <NA>                <NA> 3feac66f-8c44-4bbc-aba1-010b7819551e
#>  99:            <NA>                <NA> 4c41625f-5e3d-4a92-a828-c22d121a70b0
#> 100:            <NA>                <NA> c0e7cbb1-7b04-48cf-b95a-42a30c32b48a
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
