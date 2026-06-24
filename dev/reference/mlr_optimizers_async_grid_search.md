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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-06-24 06:31:46
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-06-24 06:31:46
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-06-24 06:31:46
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-06-24 06:31:46
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-06-24 06:31:46
#>   6: finished -10.000000  0.5555556 -146.64198 2026-06-24 06:31:46
#>   7: finished -10.000000  1.6666667 -155.77778 2026-06-24 06:31:46
#>   8: finished -10.000000  2.7777778 -167.38272 2026-06-24 06:31:46
#>   9: finished -10.000000  3.8888889 -181.45679 2026-06-24 06:31:46
#>  10: finished -10.000000  5.0000000 -198.00000 2026-06-24 06:31:46
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-06-24 06:31:46
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-06-24 06:31:46
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-06-24 06:31:46
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-06-24 06:31:46
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-06-24 06:31:46
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-06-24 06:31:46
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-06-24 06:31:46
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-06-24 06:31:46
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-06-24 06:31:46
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-06-24 06:31:46
#>  21:   failed  10.000000  5.0000000         NA 2026-06-24 06:31:46
#>  22:   failed  10.000000  3.8888889         NA 2026-06-24 06:31:46
#>  23:   failed  10.000000  2.7777778         NA 2026-06-24 06:31:46
#>  24:   failed  10.000000  1.6666667         NA 2026-06-24 06:31:46
#>  25:   failed  10.000000  0.5555556         NA 2026-06-24 06:31:46
#>  26:   failed  10.000000 -0.5555556         NA 2026-06-24 06:31:46
#>  27:   failed  10.000000 -1.6666667         NA 2026-06-24 06:31:46
#>  28:   failed  10.000000 -2.7777778         NA 2026-06-24 06:31:46
#>  29:   failed  10.000000 -3.8888889         NA 2026-06-24 06:31:46
#>  30:   failed  10.000000 -5.0000000         NA 2026-06-24 06:31:46
#>  31:   failed   7.777778  5.0000000         NA 2026-06-24 06:31:46
#>  32:   failed   7.777778  3.8888889         NA 2026-06-24 06:31:46
#>  33:   failed   7.777778  2.7777778         NA 2026-06-24 06:31:46
#>  34:   failed   7.777778  1.6666667         NA 2026-06-24 06:31:46
#>  35:   failed   7.777778  0.5555556         NA 2026-06-24 06:31:46
#>  36:   failed   7.777778 -0.5555556         NA 2026-06-24 06:31:46
#>  37:   failed   7.777778 -1.6666667         NA 2026-06-24 06:31:46
#>  38:   failed   7.777778 -2.7777778         NA 2026-06-24 06:31:46
#>  39:   failed   7.777778 -3.8888889         NA 2026-06-24 06:31:46
#>  40:   failed   7.777778 -5.0000000         NA 2026-06-24 06:31:46
#>  41:   failed   5.555556  5.0000000         NA 2026-06-24 06:31:46
#>  42:   failed   5.555556  3.8888889         NA 2026-06-24 06:31:46
#>  43:   failed   5.555556  2.7777778         NA 2026-06-24 06:31:46
#>  44:   failed   5.555556  1.6666667         NA 2026-06-24 06:31:46
#>  45:   failed   5.555556  0.5555556         NA 2026-06-24 06:31:46
#>  46:   failed   5.555556 -0.5555556         NA 2026-06-24 06:31:46
#>  47:   failed   5.555556 -1.6666667         NA 2026-06-24 06:31:46
#>  48:   failed   5.555556 -2.7777778         NA 2026-06-24 06:31:46
#>  49:   failed   5.555556 -3.8888889         NA 2026-06-24 06:31:46
#>  50:   failed   5.555556 -5.0000000         NA 2026-06-24 06:31:46
#>  51:   failed   3.333333  5.0000000         NA 2026-06-24 06:31:46
#>  52:   failed   3.333333  3.8888889         NA 2026-06-24 06:31:46
#>  53:   failed   3.333333  2.7777778         NA 2026-06-24 06:31:46
#>  54:   failed   3.333333  1.6666667         NA 2026-06-24 06:31:46
#>  55:   failed   3.333333  0.5555556         NA 2026-06-24 06:31:46
#>  56:   failed   3.333333 -0.5555556         NA 2026-06-24 06:31:46
#>  57:   failed   3.333333 -1.6666667         NA 2026-06-24 06:31:46
#>  58:   failed   3.333333 -2.7777778         NA 2026-06-24 06:31:46
#>  59:   failed   3.333333 -3.8888889         NA 2026-06-24 06:31:46
#>  60:   failed   3.333333 -5.0000000         NA 2026-06-24 06:31:46
#>  61:   failed   1.111111  5.0000000         NA 2026-06-24 06:31:46
#>  62:   failed   1.111111  3.8888889         NA 2026-06-24 06:31:46
#>  63:   failed   1.111111  2.7777778         NA 2026-06-24 06:31:46
#>  64:   failed   1.111111  1.6666667         NA 2026-06-24 06:31:46
#>  65:   failed   1.111111  0.5555556         NA 2026-06-24 06:31:46
#>  66:   failed   1.111111 -0.5555556         NA 2026-06-24 06:31:46
#>  67:   failed   1.111111 -1.6666667         NA 2026-06-24 06:31:46
#>  68:   failed   1.111111 -2.7777778         NA 2026-06-24 06:31:46
#>  69:   failed   1.111111 -3.8888889         NA 2026-06-24 06:31:46
#>  70:   failed   1.111111 -5.0000000         NA 2026-06-24 06:31:46
#>  71:   failed  -1.111111  5.0000000         NA 2026-06-24 06:31:46
#>  72:   failed  -1.111111  3.8888889         NA 2026-06-24 06:31:46
#>  73:   failed  -1.111111  2.7777778         NA 2026-06-24 06:31:46
#>  74:   failed  -1.111111  1.6666667         NA 2026-06-24 06:31:46
#>  75:   failed  -1.111111  0.5555556         NA 2026-06-24 06:31:46
#>  76:   failed  -1.111111 -0.5555556         NA 2026-06-24 06:31:46
#>  77:   failed  -1.111111 -1.6666667         NA 2026-06-24 06:31:46
#>  78:   failed  -1.111111 -2.7777778         NA 2026-06-24 06:31:46
#>  79:   failed  -1.111111 -3.8888889         NA 2026-06-24 06:31:46
#>  80:   failed  -1.111111 -5.0000000         NA 2026-06-24 06:31:46
#>  81:   failed  -3.333333  5.0000000         NA 2026-06-24 06:31:46
#>  82:   failed  -3.333333  3.8888889         NA 2026-06-24 06:31:46
#>  83:   failed  -3.333333  2.7777778         NA 2026-06-24 06:31:46
#>  84:   failed  -3.333333  1.6666667         NA 2026-06-24 06:31:46
#>  85:   failed  -3.333333  0.5555556         NA 2026-06-24 06:31:46
#>  86:   failed  -3.333333 -0.5555556         NA 2026-06-24 06:31:46
#>  87:   failed  -3.333333 -1.6666667         NA 2026-06-24 06:31:46
#>  88:   failed  -3.333333 -2.7777778         NA 2026-06-24 06:31:46
#>  89:   failed  -3.333333 -3.8888889         NA 2026-06-24 06:31:46
#>  90:   failed  -3.333333 -5.0000000         NA 2026-06-24 06:31:46
#>  91:   failed  -5.555556  5.0000000         NA 2026-06-24 06:31:46
#>  92:   failed  -5.555556  3.8888889         NA 2026-06-24 06:31:46
#>  93:   failed  -5.555556  2.7777778         NA 2026-06-24 06:31:46
#>  94:   failed  -5.555556  1.6666667         NA 2026-06-24 06:31:46
#>  95:   failed  -5.555556  0.5555556         NA 2026-06-24 06:31:46
#>  96:   failed  -5.555556 -0.5555556         NA 2026-06-24 06:31:46
#>  97:   failed  -5.555556 -1.6666667         NA 2026-06-24 06:31:46
#>  98:   failed  -5.555556 -2.7777778         NA 2026-06-24 06:31:46
#>  99:   failed  -5.555556 -3.8888889         NA 2026-06-24 06:31:46
#> 100:   failed  -5.555556 -5.0000000         NA 2026-06-24 06:31:46
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-06-24 06:31:47 65c1a710-3096-4790-b79f-8b1f5a8fd26e
#>   2: sinking_raccoon 2026-06-24 06:31:47 b758a75f-3f81-421c-b252-9c6a1da70afa
#>   3: sinking_raccoon 2026-06-24 06:31:47 430a7fe6-84a2-4b86-a431-3fe75782e09c
#>   4: sinking_raccoon 2026-06-24 06:31:47 efa9453f-ee6b-4537-8cce-bfcc86c07128
#>   5: sinking_raccoon 2026-06-24 06:31:47 3529cc7a-1227-49a4-a4cb-b2b923e1ca84
#>   6: sinking_raccoon 2026-06-24 06:31:47 e9615f35-2888-44e9-93d7-08cb8116ff01
#>   7: sinking_raccoon 2026-06-24 06:31:47 b3d1c4a4-a459-4aca-997f-8ac5619e87db
#>   8: sinking_raccoon 2026-06-24 06:31:47 9a019b30-ae6f-4675-9696-8c51bc244413
#>   9: sinking_raccoon 2026-06-24 06:31:47 529de3f0-de25-4b8a-a371-a1dd58b25ab4
#>  10: sinking_raccoon 2026-06-24 06:31:47 0d447e42-e3f4-4fcb-9928-755b97fe59b3
#>  11: sinking_raccoon 2026-06-24 06:31:47 5cbd7d2b-c6f9-4c26-ba6c-e20da9d7bdde
#>  12: sinking_raccoon 2026-06-24 06:31:47 b3a5282c-bff5-42d8-b691-d8824290c9f3
#>  13: sinking_raccoon 2026-06-24 06:31:47 c5023160-0345-481a-afd8-ea681bfbb88b
#>  14: sinking_raccoon 2026-06-24 06:31:47 6dc8b38c-a0e4-4d09-8684-f88c747a9bd4
#>  15: sinking_raccoon 2026-06-24 06:31:47 afd79c7f-c624-450e-b00c-869f9d480536
#>  16: sinking_raccoon 2026-06-24 06:31:47 6cdc32b4-6d85-41f2-82ed-6edbaa0cb556
#>  17: sinking_raccoon 2026-06-24 06:31:47 26d6ea61-8bc8-43c2-9d6d-4229d1455bdb
#>  18: sinking_raccoon 2026-06-24 06:31:47 b4c8f0bc-34be-47f0-8d88-6b2e7babd168
#>  19: sinking_raccoon 2026-06-24 06:31:47 8a891136-0141-43dd-85bd-6c1bc2684bef
#>  20: sinking_raccoon 2026-06-24 06:31:47 d98a63a7-7613-4d71-820c-67500e356963
#>  21:            <NA>                <NA> ec92a433-e624-4669-9925-f1b8ccfd25b6
#>  22:            <NA>                <NA> 7b63f9c1-68b4-42c6-aeed-08aa91f82931
#>  23:            <NA>                <NA> 0983407a-b9d1-4636-89cd-4262fb861d02
#>  24:            <NA>                <NA> 823ea179-95cf-4186-bd48-38add1b473da
#>  25:            <NA>                <NA> 70c5b3fb-b0a7-4738-95e3-952c0b8047e1
#>  26:            <NA>                <NA> 90d1e4e3-8693-4491-92b6-c9617cd572f1
#>  27:            <NA>                <NA> d0bd209b-bc85-4d8a-a987-5584e4413213
#>  28:            <NA>                <NA> 464e1639-449c-46f9-b37d-281e9a9833bb
#>  29:            <NA>                <NA> 64d80f30-1b5f-41b4-98b1-a73bff16b71f
#>  30:            <NA>                <NA> a37b464e-c0a1-4a4f-a618-20272e3a3468
#>  31:            <NA>                <NA> ab65d249-e734-4503-a33a-b42054661c92
#>  32:            <NA>                <NA> 60e04d93-56a1-448d-9be7-4a8e23e510e1
#>  33:            <NA>                <NA> af430994-5063-42eb-bd40-9c6649dd8c39
#>  34:            <NA>                <NA> fbd25947-82c7-4678-95cf-d22b0020377a
#>  35:            <NA>                <NA> 372cc6e5-86ff-40a8-9f56-95d4b3f0e9ec
#>  36:            <NA>                <NA> 86fa2e60-38a7-4e6e-a9e3-a550a93fcd90
#>  37:            <NA>                <NA> 543aafba-d79f-4d3d-94cd-879e96c7140c
#>  38:            <NA>                <NA> 64f4eec5-e8f7-4cc3-b19b-151856b959bd
#>  39:            <NA>                <NA> 0e6e06f7-934e-4ffc-95d8-26166e97214a
#>  40:            <NA>                <NA> 5c6ffd2b-2deb-4453-9a3f-e23bd5368434
#>  41:            <NA>                <NA> b27d3116-4f70-4e3d-8f8e-fbdc6704333c
#>  42:            <NA>                <NA> e69498cd-286c-4507-a7ab-6b1da88c413d
#>  43:            <NA>                <NA> 4aff8edb-fd1d-46f5-a574-4890b899b886
#>  44:            <NA>                <NA> 4e15e43b-6bfb-4067-ac22-be6d8bdb1ac6
#>  45:            <NA>                <NA> 981d71d8-6003-4912-a7a3-4a925aa95f84
#>  46:            <NA>                <NA> 7d96a2f0-ea4b-4d71-8bec-e147e66444e0
#>  47:            <NA>                <NA> 7f898869-57ad-4fa9-b8b7-cdb90439da01
#>  48:            <NA>                <NA> 8da83abe-2f45-4f4f-9189-afec2391d2b2
#>  49:            <NA>                <NA> f92499a9-55fa-49fe-9d57-171410fe78e9
#>  50:            <NA>                <NA> 7aaaecac-671b-4f53-b413-2110f111ecc0
#>  51:            <NA>                <NA> 7d89c621-0e79-4783-94b8-ab2cfcb42f82
#>  52:            <NA>                <NA> cd802a25-00ec-49e4-90d1-158ee45f3c37
#>  53:            <NA>                <NA> e2e95d80-c25f-46d1-93bb-589b1f859cf8
#>  54:            <NA>                <NA> 29ce77a0-a015-4c0d-a4eb-6f0b75139a2b
#>  55:            <NA>                <NA> 446e49fd-f3f6-43ce-9316-ba8b23a07152
#>  56:            <NA>                <NA> e0c88990-fa2f-4d65-b3d0-60e0916b9a7c
#>  57:            <NA>                <NA> eb711f3a-aea9-411e-b1b2-b81728eb850b
#>  58:            <NA>                <NA> 60865630-88e5-4605-a015-e94dae49526c
#>  59:            <NA>                <NA> d40d6453-d93a-470b-9864-c42cfbdca66a
#>  60:            <NA>                <NA> ccad5570-8c24-460e-8e08-aad83db261d3
#>  61:            <NA>                <NA> bcf6e3ec-8a5c-4719-8b0c-b89c979a0027
#>  62:            <NA>                <NA> 0166d4d1-45b6-4cc6-a269-4c76f3dac872
#>  63:            <NA>                <NA> a5310e1a-9604-4538-b701-25624d8b66dc
#>  64:            <NA>                <NA> 0c310f13-de54-4099-90f6-4b570a315a0b
#>  65:            <NA>                <NA> 8409065e-d17c-4126-b9c2-e30d34a4841a
#>  66:            <NA>                <NA> 64d3766c-f763-4289-bffa-be9387e1e0b0
#>  67:            <NA>                <NA> 5993448f-3c8d-4875-81c2-cea2df56dad3
#>  68:            <NA>                <NA> f9b8937d-3505-4880-8fc0-40863ff7e6d6
#>  69:            <NA>                <NA> b0137143-e984-45f3-ad37-a708f89ec896
#>  70:            <NA>                <NA> 15343894-8350-478c-99ee-5d7cf752d14c
#>  71:            <NA>                <NA> 608d32f7-d549-4ffb-be0b-54dad43f9c7a
#>  72:            <NA>                <NA> d22740cc-5a0f-40ce-8efb-88f4ac7750dd
#>  73:            <NA>                <NA> 7ffbf885-7aa4-4c05-87a6-b9736a99b65c
#>  74:            <NA>                <NA> 6c85ee29-c4ae-4b49-9eb7-40d0b9b0752c
#>  75:            <NA>                <NA> 216426ce-ea69-44a7-b704-05bc6007681f
#>  76:            <NA>                <NA> 4f958937-c701-41ac-96c1-1d091f20987b
#>  77:            <NA>                <NA> a6726548-0561-4e91-ad4f-4460de2b898e
#>  78:            <NA>                <NA> 403b6b36-4b47-40a2-8948-c30a73a2d42a
#>  79:            <NA>                <NA> 2f9c707e-c6f2-4d74-b0a2-9fd4110f6b40
#>  80:            <NA>                <NA> 86b0dd36-5a65-4abf-83bd-c1d2ac878c37
#>  81:            <NA>                <NA> ed617388-8a5f-4b54-ab5f-685337e9152e
#>  82:            <NA>                <NA> a6f1f754-6094-4f59-9ec2-0dc9642d149d
#>  83:            <NA>                <NA> d680fcf1-4f5c-4f7a-96f5-d3bb2e56651f
#>  84:            <NA>                <NA> 148e04eb-103e-4d0f-800c-bbb3f98af0e5
#>  85:            <NA>                <NA> 4a5f90b9-906d-4449-9cc8-647136b40e9b
#>  86:            <NA>                <NA> 6d223c67-eada-496b-a17d-2a855c691aed
#>  87:            <NA>                <NA> 0c97514f-c81c-43c6-a541-5a87cb81336c
#>  88:            <NA>                <NA> 31dc2d8f-f817-408e-9456-5f6b572502f0
#>  89:            <NA>                <NA> dc74d437-f944-474e-bc2e-de894e7c3f5d
#>  90:            <NA>                <NA> 33017034-a9f3-4206-b1d5-0ee98ac5846e
#>  91:            <NA>                <NA> 427c38af-179d-4040-9c41-eca1289b1310
#>  92:            <NA>                <NA> 634a5719-9091-434b-bdf3-68c04ad09750
#>  93:            <NA>                <NA> 03618720-8927-49fc-a370-c2b19488a982
#>  94:            <NA>                <NA> f523b67f-ad8c-4111-8ec8-2e0f451c8607
#>  95:            <NA>                <NA> 29223e94-6d22-4fb3-83fc-0a26d143f832
#>  96:            <NA>                <NA> a8d54835-2c26-41aa-b15a-4e6142b04a7a
#>  97:            <NA>                <NA> 80f58ed8-e8fd-4fca-b6c9-524ef665dfc9
#>  98:            <NA>                <NA> edfca094-fc33-4c89-a69e-2c3aaf57bc47
#>  99:            <NA>                <NA> d6f63636-278e-44c3-a8a6-69f933c871c8
#> 100:            <NA>                <NA> 1252cc41-5206-46e1-90ca-831ecd217960
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
