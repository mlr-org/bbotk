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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-07-02 15:49:04
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-07-02 15:49:04
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-07-02 15:49:04
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-07-02 15:49:04
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-07-02 15:49:04
#>   6: finished -10.000000  0.5555556 -146.64198 2026-07-02 15:49:04
#>   7: finished -10.000000  1.6666667 -155.77778 2026-07-02 15:49:04
#>   8: finished -10.000000  2.7777778 -167.38272 2026-07-02 15:49:04
#>   9: finished -10.000000  3.8888889 -181.45679 2026-07-02 15:49:04
#>  10: finished -10.000000  5.0000000 -198.00000 2026-07-02 15:49:04
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-07-02 15:49:04
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-07-02 15:49:04
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-07-02 15:49:04
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-07-02 15:49:04
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-07-02 15:49:04
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-07-02 15:49:04
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-07-02 15:49:04
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-07-02 15:49:04
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-07-02 15:49:04
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-07-02 15:49:04
#>  21:   failed  10.000000  5.0000000         NA 2026-07-02 15:49:04
#>  22:   failed  10.000000  3.8888889         NA 2026-07-02 15:49:04
#>  23:   failed  10.000000  2.7777778         NA 2026-07-02 15:49:04
#>  24:   failed  10.000000  1.6666667         NA 2026-07-02 15:49:04
#>  25:   failed  10.000000  0.5555556         NA 2026-07-02 15:49:04
#>  26:   failed  10.000000 -0.5555556         NA 2026-07-02 15:49:04
#>  27:   failed  10.000000 -1.6666667         NA 2026-07-02 15:49:04
#>  28:   failed  10.000000 -2.7777778         NA 2026-07-02 15:49:04
#>  29:   failed  10.000000 -3.8888889         NA 2026-07-02 15:49:04
#>  30:   failed  10.000000 -5.0000000         NA 2026-07-02 15:49:04
#>  31:   failed   7.777778  5.0000000         NA 2026-07-02 15:49:04
#>  32:   failed   7.777778  3.8888889         NA 2026-07-02 15:49:04
#>  33:   failed   7.777778  2.7777778         NA 2026-07-02 15:49:04
#>  34:   failed   7.777778  1.6666667         NA 2026-07-02 15:49:04
#>  35:   failed   7.777778  0.5555556         NA 2026-07-02 15:49:04
#>  36:   failed   7.777778 -0.5555556         NA 2026-07-02 15:49:04
#>  37:   failed   7.777778 -1.6666667         NA 2026-07-02 15:49:04
#>  38:   failed   7.777778 -2.7777778         NA 2026-07-02 15:49:04
#>  39:   failed   7.777778 -3.8888889         NA 2026-07-02 15:49:04
#>  40:   failed   7.777778 -5.0000000         NA 2026-07-02 15:49:04
#>  41:   failed   5.555556  5.0000000         NA 2026-07-02 15:49:04
#>  42:   failed   5.555556  3.8888889         NA 2026-07-02 15:49:04
#>  43:   failed   5.555556  2.7777778         NA 2026-07-02 15:49:04
#>  44:   failed   5.555556  1.6666667         NA 2026-07-02 15:49:04
#>  45:   failed   5.555556  0.5555556         NA 2026-07-02 15:49:04
#>  46:   failed   5.555556 -0.5555556         NA 2026-07-02 15:49:04
#>  47:   failed   5.555556 -1.6666667         NA 2026-07-02 15:49:04
#>  48:   failed   5.555556 -2.7777778         NA 2026-07-02 15:49:04
#>  49:   failed   5.555556 -3.8888889         NA 2026-07-02 15:49:04
#>  50:   failed   5.555556 -5.0000000         NA 2026-07-02 15:49:04
#>  51:   failed   3.333333  5.0000000         NA 2026-07-02 15:49:04
#>  52:   failed   3.333333  3.8888889         NA 2026-07-02 15:49:04
#>  53:   failed   3.333333  2.7777778         NA 2026-07-02 15:49:04
#>  54:   failed   3.333333  1.6666667         NA 2026-07-02 15:49:04
#>  55:   failed   3.333333  0.5555556         NA 2026-07-02 15:49:04
#>  56:   failed   3.333333 -0.5555556         NA 2026-07-02 15:49:04
#>  57:   failed   3.333333 -1.6666667         NA 2026-07-02 15:49:04
#>  58:   failed   3.333333 -2.7777778         NA 2026-07-02 15:49:04
#>  59:   failed   3.333333 -3.8888889         NA 2026-07-02 15:49:04
#>  60:   failed   3.333333 -5.0000000         NA 2026-07-02 15:49:04
#>  61:   failed   1.111111  5.0000000         NA 2026-07-02 15:49:04
#>  62:   failed   1.111111  3.8888889         NA 2026-07-02 15:49:04
#>  63:   failed   1.111111  2.7777778         NA 2026-07-02 15:49:04
#>  64:   failed   1.111111  1.6666667         NA 2026-07-02 15:49:04
#>  65:   failed   1.111111  0.5555556         NA 2026-07-02 15:49:04
#>  66:   failed   1.111111 -0.5555556         NA 2026-07-02 15:49:04
#>  67:   failed   1.111111 -1.6666667         NA 2026-07-02 15:49:04
#>  68:   failed   1.111111 -2.7777778         NA 2026-07-02 15:49:04
#>  69:   failed   1.111111 -3.8888889         NA 2026-07-02 15:49:04
#>  70:   failed   1.111111 -5.0000000         NA 2026-07-02 15:49:04
#>  71:   failed  -1.111111  5.0000000         NA 2026-07-02 15:49:04
#>  72:   failed  -1.111111  3.8888889         NA 2026-07-02 15:49:04
#>  73:   failed  -1.111111  2.7777778         NA 2026-07-02 15:49:04
#>  74:   failed  -1.111111  1.6666667         NA 2026-07-02 15:49:04
#>  75:   failed  -1.111111  0.5555556         NA 2026-07-02 15:49:04
#>  76:   failed  -1.111111 -0.5555556         NA 2026-07-02 15:49:04
#>  77:   failed  -1.111111 -1.6666667         NA 2026-07-02 15:49:04
#>  78:   failed  -1.111111 -2.7777778         NA 2026-07-02 15:49:04
#>  79:   failed  -1.111111 -3.8888889         NA 2026-07-02 15:49:04
#>  80:   failed  -1.111111 -5.0000000         NA 2026-07-02 15:49:04
#>  81:   failed  -3.333333  5.0000000         NA 2026-07-02 15:49:04
#>  82:   failed  -3.333333  3.8888889         NA 2026-07-02 15:49:04
#>  83:   failed  -3.333333  2.7777778         NA 2026-07-02 15:49:04
#>  84:   failed  -3.333333  1.6666667         NA 2026-07-02 15:49:04
#>  85:   failed  -3.333333  0.5555556         NA 2026-07-02 15:49:04
#>  86:   failed  -3.333333 -0.5555556         NA 2026-07-02 15:49:04
#>  87:   failed  -3.333333 -1.6666667         NA 2026-07-02 15:49:04
#>  88:   failed  -3.333333 -2.7777778         NA 2026-07-02 15:49:04
#>  89:   failed  -3.333333 -3.8888889         NA 2026-07-02 15:49:04
#>  90:   failed  -3.333333 -5.0000000         NA 2026-07-02 15:49:04
#>  91:   failed  -5.555556  5.0000000         NA 2026-07-02 15:49:04
#>  92:   failed  -5.555556  3.8888889         NA 2026-07-02 15:49:04
#>  93:   failed  -5.555556  2.7777778         NA 2026-07-02 15:49:04
#>  94:   failed  -5.555556  1.6666667         NA 2026-07-02 15:49:04
#>  95:   failed  -5.555556  0.5555556         NA 2026-07-02 15:49:04
#>  96:   failed  -5.555556 -0.5555556         NA 2026-07-02 15:49:04
#>  97:   failed  -5.555556 -1.6666667         NA 2026-07-02 15:49:04
#>  98:   failed  -5.555556 -2.7777778         NA 2026-07-02 15:49:04
#>  99:   failed  -5.555556 -3.8888889         NA 2026-07-02 15:49:04
#> 100:   failed  -5.555556 -5.0000000         NA 2026-07-02 15:49:04
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-07-02 15:49:05 c090a207-64b5-42f5-9665-401f16557aee
#>   2: sinking_raccoon 2026-07-02 15:49:05 2f15e537-aabc-4417-9b2c-6e9a84bbc589
#>   3: sinking_raccoon 2026-07-02 15:49:05 4c44bc13-4a21-4974-9e97-e50bfb2b98b2
#>   4: sinking_raccoon 2026-07-02 15:49:05 026432bd-022b-4cd6-866a-5e95986c8754
#>   5: sinking_raccoon 2026-07-02 15:49:05 7bbe65db-e7f7-489f-8288-37492c674032
#>   6: sinking_raccoon 2026-07-02 15:49:05 9f3e9009-d261-4da9-9fb7-13d6a1096315
#>   7: sinking_raccoon 2026-07-02 15:49:05 e7ddbe97-4d0c-4a57-8893-50cb1f9c5744
#>   8: sinking_raccoon 2026-07-02 15:49:05 7bbebdcc-fd0f-4582-9ce6-bf029f5032b7
#>   9: sinking_raccoon 2026-07-02 15:49:05 eb5614be-77dc-4e77-ac63-beaabbb23cf8
#>  10: sinking_raccoon 2026-07-02 15:49:05 97e984a4-584e-4957-9d87-319fdc425e65
#>  11: sinking_raccoon 2026-07-02 15:49:05 d625e386-ca9d-46ab-8196-073b56c70dfa
#>  12: sinking_raccoon 2026-07-02 15:49:05 f6d7d02a-4d39-4535-9aa0-6c070a4f701c
#>  13: sinking_raccoon 2026-07-02 15:49:05 82796110-665a-4a4e-8053-1ca9d753c709
#>  14: sinking_raccoon 2026-07-02 15:49:05 8fb4aae8-f7ea-456e-8cd7-03da0520f16b
#>  15: sinking_raccoon 2026-07-02 15:49:05 4d73619c-1aa7-463f-82fa-cc1f916fe86e
#>  16: sinking_raccoon 2026-07-02 15:49:05 76281cbd-147f-4f0d-918a-520e17ce0247
#>  17: sinking_raccoon 2026-07-02 15:49:05 6950f4ca-5fd0-4b98-914c-ff67e892bafd
#>  18: sinking_raccoon 2026-07-02 15:49:05 83cb33f8-4a56-41d7-a7aa-b3ad8d33e119
#>  19: sinking_raccoon 2026-07-02 15:49:05 dc282834-d745-4def-a5dc-05e1d3b1bc92
#>  20: sinking_raccoon 2026-07-02 15:49:05 60d560d9-fbba-4305-a97c-3964e0465e68
#>  21:            <NA>                <NA> 22e8bd3a-8f45-470c-9e4c-27aa57e6121c
#>  22:            <NA>                <NA> ce45b95e-9c82-4d5c-8e39-44ae0016592d
#>  23:            <NA>                <NA> 9c212d44-ab1a-4231-aac1-3c16b5dab80f
#>  24:            <NA>                <NA> 5c649a12-d53e-4a6e-8657-d3e495e5c6fa
#>  25:            <NA>                <NA> 1badedf4-89d8-4dad-a00b-15e4cba81e7b
#>  26:            <NA>                <NA> 0d9660af-970f-4f34-a248-12fd664dfe9c
#>  27:            <NA>                <NA> 818b2d38-9c10-4c90-b1aa-9ca7615230f3
#>  28:            <NA>                <NA> d5400178-e86c-4581-a63c-c97a772c17ea
#>  29:            <NA>                <NA> 5423745a-4a53-4ed7-b6e1-a479404cb38d
#>  30:            <NA>                <NA> e1190afb-cf16-41da-b2cb-147c63fa2a07
#>  31:            <NA>                <NA> 04edfa8a-6d21-422e-bdcc-fcae2f3224b7
#>  32:            <NA>                <NA> 3c30a4a6-89cf-4acc-96ee-dd69b675c7bb
#>  33:            <NA>                <NA> dca18b79-3c4b-4bc3-898d-232b6565ae94
#>  34:            <NA>                <NA> 724a5906-c5a4-48b0-b90e-2319888bbe9c
#>  35:            <NA>                <NA> 9e814304-f607-49e3-96dc-6ea9dcdc9e93
#>  36:            <NA>                <NA> 214b408b-84c5-4603-bbd7-69e8597af244
#>  37:            <NA>                <NA> c39f4caa-9368-4241-984b-69394c891e2f
#>  38:            <NA>                <NA> 12547907-a960-4ae8-b97e-4cd10605c458
#>  39:            <NA>                <NA> 1a885374-5e35-4e66-8b08-081c3dc0b3af
#>  40:            <NA>                <NA> 6626cfa3-cbef-48bd-aec0-bb6008886635
#>  41:            <NA>                <NA> a0e0e48c-a267-483f-96e8-05b4c24bf5c4
#>  42:            <NA>                <NA> 69859510-d89a-40e1-86b5-52c5508c9b4b
#>  43:            <NA>                <NA> 80a549c0-3e22-4ce5-8b63-18e75f6b3e89
#>  44:            <NA>                <NA> 162dd1ea-150c-4418-a00d-a3664993b609
#>  45:            <NA>                <NA> 5f994823-ca8a-4dea-b4fe-f8c76023fd47
#>  46:            <NA>                <NA> 45365656-2f82-41fd-9917-0b0557eca7bf
#>  47:            <NA>                <NA> df0e9221-7220-4fc6-a71d-43212ba894ea
#>  48:            <NA>                <NA> b3b57a3f-76bd-4e5c-8f14-cea12e97ab1f
#>  49:            <NA>                <NA> 9f942bb5-14c0-42be-82e0-639bff52e473
#>  50:            <NA>                <NA> 1a4c1a7f-22ad-4a74-9293-b3694ab243d2
#>  51:            <NA>                <NA> 2078f979-ee77-48d7-acbc-0a84b76a1140
#>  52:            <NA>                <NA> 8ec495b4-aecb-4966-8578-b620b84aa9b5
#>  53:            <NA>                <NA> b06d42ef-8eeb-4d06-b457-125d60e0d780
#>  54:            <NA>                <NA> dd0a4ab8-60ae-46c1-ba7e-b83609d7a9c4
#>  55:            <NA>                <NA> d5065f79-a7c3-450e-ac72-af8d70f4bc84
#>  56:            <NA>                <NA> 224d7230-e06f-4d2d-b09e-5b13bb01cd06
#>  57:            <NA>                <NA> 8bafc285-e5ff-4aed-a067-4e7da77baca3
#>  58:            <NA>                <NA> 9f5911fb-62df-4a9e-a458-03e8ea864639
#>  59:            <NA>                <NA> 82be4d6e-80a9-4fdd-9476-e70d74ab8ed8
#>  60:            <NA>                <NA> f8f1b993-328c-4d2f-ba40-767f4da74bbf
#>  61:            <NA>                <NA> 0647b108-6e63-42cb-acab-b25eacf98ec4
#>  62:            <NA>                <NA> 174d9dc3-6e31-4790-bfc1-e013e9f1dec4
#>  63:            <NA>                <NA> 9f7f22b7-388f-42a0-8425-9ae38d00a1f3
#>  64:            <NA>                <NA> 3784f168-2de4-4408-9a0a-d7b08677dfa2
#>  65:            <NA>                <NA> f1a4e9dd-0d5d-44a0-b2ca-4e1019b36a3e
#>  66:            <NA>                <NA> 05a373ff-c632-4364-a9cd-a1479c5b2a0b
#>  67:            <NA>                <NA> 07fdfef7-4ac6-4df5-8782-a520b8ba8557
#>  68:            <NA>                <NA> 7331a597-bf5b-4935-89cb-6d10336ac198
#>  69:            <NA>                <NA> a468b28a-268b-4985-b27b-cd8614a8c1d9
#>  70:            <NA>                <NA> d9ded7eb-1504-4336-8bfc-b09a48b1cac4
#>  71:            <NA>                <NA> 19b5fc6a-b2e7-4c4b-821d-67a1e61bfac0
#>  72:            <NA>                <NA> e8b641d2-47bb-41ad-8b00-cc9dc6c47d5e
#>  73:            <NA>                <NA> 60721d2a-7b24-4de5-9141-e3cc203c26b2
#>  74:            <NA>                <NA> d2f2b23b-c509-420e-8a9f-9199a23ec453
#>  75:            <NA>                <NA> c592912d-fa4c-425b-85b3-5e707741ca82
#>  76:            <NA>                <NA> 8b8da61d-d14c-4f22-9ac0-06a8ade80d59
#>  77:            <NA>                <NA> c7eaa754-1d96-4cab-a5ec-dbbbd434e8cf
#>  78:            <NA>                <NA> 750c03b3-23fd-48f4-9ce1-f1137886a1ec
#>  79:            <NA>                <NA> a83eb11a-207f-4378-b791-776e14d17d75
#>  80:            <NA>                <NA> fd9ed055-dd0c-4785-b496-3b39a34dabd0
#>  81:            <NA>                <NA> 511b5024-f003-452e-a403-7bd1bf2fe09a
#>  82:            <NA>                <NA> caec84aa-c774-41b0-a739-298014afcd84
#>  83:            <NA>                <NA> 9d0beb86-f4d7-4e48-bc42-58e22dba953d
#>  84:            <NA>                <NA> 4f25fce1-6681-40a6-9645-72b7167c1943
#>  85:            <NA>                <NA> 567cf5cc-bf91-4be1-881c-b2cb3145cdc1
#>  86:            <NA>                <NA> 9c4fbaa0-a8a5-479d-b07f-6b6037e56e00
#>  87:            <NA>                <NA> e33a81e5-1fff-42ac-a56e-836a1d290e8b
#>  88:            <NA>                <NA> 641a31a4-0778-4fc8-99c2-5f1953b9ef94
#>  89:            <NA>                <NA> b24fa894-0162-404d-8cdb-1685f6acf7f7
#>  90:            <NA>                <NA> 021db601-b1c3-493e-ad38-dcdd1da49a52
#>  91:            <NA>                <NA> 80431146-afac-4888-a66e-2cc315756a63
#>  92:            <NA>                <NA> 60349aed-a0b2-4323-ae87-138c42d6b98b
#>  93:            <NA>                <NA> baf237fd-c647-40cf-8942-1257dda3b07d
#>  94:            <NA>                <NA> 3d4c4411-219e-4feb-bad9-14489965495e
#>  95:            <NA>                <NA> 0a39a6f5-4c61-4093-8500-6b1b9920a2f8
#>  96:            <NA>                <NA> 27cb91ff-a932-4475-80c5-443cad179d46
#>  97:            <NA>                <NA> 36319c72-9736-4ae1-8cf6-c8005d164c81
#>  98:            <NA>                <NA> 4a47a6ec-dea7-4618-b955-abee70449e4e
#>  99:            <NA>                <NA> cae65940-eec3-4f1b-a0b3-1af49a1a00a1
#> 100:            <NA>                <NA> 063c23c9-a8c9-41a9-ba4b-07526cdfdc22
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
