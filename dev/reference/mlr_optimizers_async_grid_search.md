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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-03-18 14:00:44
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-03-18 14:00:44
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-03-18 14:00:44
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-03-18 14:00:44
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-03-18 14:00:44
#>   6: finished -10.000000  0.5555556 -146.64198 2026-03-18 14:00:44
#>   7: finished -10.000000  1.6666667 -155.77778 2026-03-18 14:00:44
#>   8: finished -10.000000  2.7777778 -167.38272 2026-03-18 14:00:44
#>   9: finished -10.000000  3.8888889 -181.45679 2026-03-18 14:00:44
#>  10: finished -10.000000  5.0000000 -198.00000 2026-03-18 14:00:44
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-03-18 14:00:44
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-03-18 14:00:44
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-03-18 14:00:44
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-03-18 14:00:44
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-03-18 14:00:44
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-03-18 14:00:44
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-03-18 14:00:44
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-03-18 14:00:44
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-03-18 14:00:44
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-03-18 14:00:44
#>  21:   failed  10.000000  5.0000000         NA 2026-03-18 14:00:44
#>  22:   failed  10.000000  3.8888889         NA 2026-03-18 14:00:44
#>  23:   failed  10.000000  2.7777778         NA 2026-03-18 14:00:44
#>  24:   failed  10.000000  1.6666667         NA 2026-03-18 14:00:44
#>  25:   failed  10.000000  0.5555556         NA 2026-03-18 14:00:44
#>  26:   failed  10.000000 -0.5555556         NA 2026-03-18 14:00:44
#>  27:   failed  10.000000 -1.6666667         NA 2026-03-18 14:00:44
#>  28:   failed  10.000000 -2.7777778         NA 2026-03-18 14:00:44
#>  29:   failed  10.000000 -3.8888889         NA 2026-03-18 14:00:44
#>  30:   failed  10.000000 -5.0000000         NA 2026-03-18 14:00:44
#>  31:   failed   7.777778  5.0000000         NA 2026-03-18 14:00:44
#>  32:   failed   7.777778  3.8888889         NA 2026-03-18 14:00:44
#>  33:   failed   7.777778  2.7777778         NA 2026-03-18 14:00:44
#>  34:   failed   7.777778  1.6666667         NA 2026-03-18 14:00:44
#>  35:   failed   7.777778  0.5555556         NA 2026-03-18 14:00:44
#>  36:   failed   7.777778 -0.5555556         NA 2026-03-18 14:00:44
#>  37:   failed   7.777778 -1.6666667         NA 2026-03-18 14:00:44
#>  38:   failed   7.777778 -2.7777778         NA 2026-03-18 14:00:44
#>  39:   failed   7.777778 -3.8888889         NA 2026-03-18 14:00:44
#>  40:   failed   7.777778 -5.0000000         NA 2026-03-18 14:00:44
#>  41:   failed   5.555556  5.0000000         NA 2026-03-18 14:00:44
#>  42:   failed   5.555556  3.8888889         NA 2026-03-18 14:00:44
#>  43:   failed   5.555556  2.7777778         NA 2026-03-18 14:00:44
#>  44:   failed   5.555556  1.6666667         NA 2026-03-18 14:00:44
#>  45:   failed   5.555556  0.5555556         NA 2026-03-18 14:00:44
#>  46:   failed   5.555556 -0.5555556         NA 2026-03-18 14:00:44
#>  47:   failed   5.555556 -1.6666667         NA 2026-03-18 14:00:44
#>  48:   failed   5.555556 -2.7777778         NA 2026-03-18 14:00:44
#>  49:   failed   5.555556 -3.8888889         NA 2026-03-18 14:00:44
#>  50:   failed   5.555556 -5.0000000         NA 2026-03-18 14:00:44
#>  51:   failed   3.333333  5.0000000         NA 2026-03-18 14:00:44
#>  52:   failed   3.333333  3.8888889         NA 2026-03-18 14:00:44
#>  53:   failed   3.333333  2.7777778         NA 2026-03-18 14:00:44
#>  54:   failed   3.333333  1.6666667         NA 2026-03-18 14:00:44
#>  55:   failed   3.333333  0.5555556         NA 2026-03-18 14:00:44
#>  56:   failed   3.333333 -0.5555556         NA 2026-03-18 14:00:44
#>  57:   failed   3.333333 -1.6666667         NA 2026-03-18 14:00:44
#>  58:   failed   3.333333 -2.7777778         NA 2026-03-18 14:00:44
#>  59:   failed   3.333333 -3.8888889         NA 2026-03-18 14:00:44
#>  60:   failed   3.333333 -5.0000000         NA 2026-03-18 14:00:44
#>  61:   failed   1.111111  5.0000000         NA 2026-03-18 14:00:44
#>  62:   failed   1.111111  3.8888889         NA 2026-03-18 14:00:44
#>  63:   failed   1.111111  2.7777778         NA 2026-03-18 14:00:44
#>  64:   failed   1.111111  1.6666667         NA 2026-03-18 14:00:44
#>  65:   failed   1.111111  0.5555556         NA 2026-03-18 14:00:44
#>  66:   failed   1.111111 -0.5555556         NA 2026-03-18 14:00:44
#>  67:   failed   1.111111 -1.6666667         NA 2026-03-18 14:00:44
#>  68:   failed   1.111111 -2.7777778         NA 2026-03-18 14:00:44
#>  69:   failed   1.111111 -3.8888889         NA 2026-03-18 14:00:44
#>  70:   failed   1.111111 -5.0000000         NA 2026-03-18 14:00:44
#>  71:   failed  -1.111111  5.0000000         NA 2026-03-18 14:00:44
#>  72:   failed  -1.111111  3.8888889         NA 2026-03-18 14:00:44
#>  73:   failed  -1.111111  2.7777778         NA 2026-03-18 14:00:44
#>  74:   failed  -1.111111  1.6666667         NA 2026-03-18 14:00:44
#>  75:   failed  -1.111111  0.5555556         NA 2026-03-18 14:00:44
#>  76:   failed  -1.111111 -0.5555556         NA 2026-03-18 14:00:44
#>  77:   failed  -1.111111 -1.6666667         NA 2026-03-18 14:00:44
#>  78:   failed  -1.111111 -2.7777778         NA 2026-03-18 14:00:44
#>  79:   failed  -1.111111 -3.8888889         NA 2026-03-18 14:00:44
#>  80:   failed  -1.111111 -5.0000000         NA 2026-03-18 14:00:44
#>  81:   failed  -3.333333  5.0000000         NA 2026-03-18 14:00:44
#>  82:   failed  -3.333333  3.8888889         NA 2026-03-18 14:00:44
#>  83:   failed  -3.333333  2.7777778         NA 2026-03-18 14:00:44
#>  84:   failed  -3.333333  1.6666667         NA 2026-03-18 14:00:44
#>  85:   failed  -3.333333  0.5555556         NA 2026-03-18 14:00:44
#>  86:   failed  -3.333333 -0.5555556         NA 2026-03-18 14:00:44
#>  87:   failed  -3.333333 -1.6666667         NA 2026-03-18 14:00:44
#>  88:   failed  -3.333333 -2.7777778         NA 2026-03-18 14:00:44
#>  89:   failed  -3.333333 -3.8888889         NA 2026-03-18 14:00:44
#>  90:   failed  -3.333333 -5.0000000         NA 2026-03-18 14:00:44
#>  91:   failed  -5.555556  5.0000000         NA 2026-03-18 14:00:44
#>  92:   failed  -5.555556  3.8888889         NA 2026-03-18 14:00:44
#>  93:   failed  -5.555556  2.7777778         NA 2026-03-18 14:00:44
#>  94:   failed  -5.555556  1.6666667         NA 2026-03-18 14:00:44
#>  95:   failed  -5.555556  0.5555556         NA 2026-03-18 14:00:44
#>  96:   failed  -5.555556 -0.5555556         NA 2026-03-18 14:00:44
#>  97:   failed  -5.555556 -1.6666667         NA 2026-03-18 14:00:44
#>  98:   failed  -5.555556 -2.7777778         NA 2026-03-18 14:00:44
#>  99:   failed  -5.555556 -3.8888889         NA 2026-03-18 14:00:44
#> 100:   failed  -5.555556 -5.0000000         NA 2026-03-18 14:00:44
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-03-18 14:00:45 fa6ae5bd-135d-4827-a585-f1c63c551f4e
#>   2: sinking_raccoon 2026-03-18 14:00:45 8f4c19b1-b660-4e09-964f-f6e671f8904a
#>   3: sinking_raccoon 2026-03-18 14:00:45 3c6f63cf-4245-4101-a308-323c6b81d281
#>   4: sinking_raccoon 2026-03-18 14:00:45 6586f291-beff-485e-84ce-20f5403f2aeb
#>   5: sinking_raccoon 2026-03-18 14:00:45 b7e4e36b-12d0-471b-96ac-769e6372deda
#>   6: sinking_raccoon 2026-03-18 14:00:45 c02ec6c3-b7cd-41ff-b5e5-425c4e12d385
#>   7: sinking_raccoon 2026-03-18 14:00:45 501750b0-7399-418a-a831-e68a7ac6b486
#>   8: sinking_raccoon 2026-03-18 14:00:45 d8f6129c-7ea1-4e96-8a52-b887adbc32ec
#>   9: sinking_raccoon 2026-03-18 14:00:45 a6df9fe4-1045-430a-be88-6776cb7a2989
#>  10: sinking_raccoon 2026-03-18 14:00:45 85b6dd91-0ab4-4570-9d38-9cbedd350a06
#>  11: sinking_raccoon 2026-03-18 14:00:45 9abaf824-a1d3-4be6-8593-da273c725d4f
#>  12: sinking_raccoon 2026-03-18 14:00:45 052eeeab-9dc2-4889-bbf6-8f24ccdf9fcf
#>  13: sinking_raccoon 2026-03-18 14:00:45 640f99d5-f19e-4fc5-bd82-4d18e40afa2c
#>  14: sinking_raccoon 2026-03-18 14:00:45 6f63985c-d747-4321-b5ce-1360fdcbb792
#>  15: sinking_raccoon 2026-03-18 14:00:45 e1c89835-f50a-4639-b395-8d4bb6787535
#>  16: sinking_raccoon 2026-03-18 14:00:45 e61b481d-cab1-4ba5-b7d0-c78baa02af51
#>  17: sinking_raccoon 2026-03-18 14:00:45 0ae37f59-18d4-425b-9f5b-751b172e8ba4
#>  18: sinking_raccoon 2026-03-18 14:00:45 c6a2eae6-be76-4697-9588-2b1274852544
#>  19: sinking_raccoon 2026-03-18 14:00:45 01f213ee-0d4c-4e31-9b65-c0af24a80bb7
#>  20: sinking_raccoon 2026-03-18 14:00:45 2c55fa52-4e95-45b2-80f5-fa9cf3280f45
#>  21:            <NA>                <NA> 9c82f3f7-f392-44c8-b91b-47daaf440752
#>  22:            <NA>                <NA> c15ec5d8-9e0d-40f7-bee3-c8dc07fa65a7
#>  23:            <NA>                <NA> 10a452bf-2423-4053-8a3f-7fd6aafb93ec
#>  24:            <NA>                <NA> 66012a01-f521-4244-80c2-5e7b09a17b95
#>  25:            <NA>                <NA> 7b318147-beae-426f-a4ab-e32e5e314a4e
#>  26:            <NA>                <NA> 380faddf-9e0a-4650-b530-6e5ab3b4d7f5
#>  27:            <NA>                <NA> 75034711-c315-4fab-aba2-962cfe25be10
#>  28:            <NA>                <NA> 9c7cd5b1-e2e0-40d5-950c-641894bff92a
#>  29:            <NA>                <NA> 93764d38-ac83-4089-b547-4852d691ab9c
#>  30:            <NA>                <NA> 00a891fe-06a6-4774-9f61-eef630a85bfd
#>  31:            <NA>                <NA> c9dd49de-1b0b-4619-8356-2f3f373624a4
#>  32:            <NA>                <NA> ca99026a-b3da-41c1-811c-fc70b06fd5c6
#>  33:            <NA>                <NA> d7b5b85f-a0b9-4dd4-bc82-327c4007b1cf
#>  34:            <NA>                <NA> c57960dd-4fc3-41cf-ab62-44a95907577f
#>  35:            <NA>                <NA> 1b49a863-65c1-4d0c-9f87-ab599c25a168
#>  36:            <NA>                <NA> 0a595749-3b95-4bd4-b5e4-1ab1ad1f8648
#>  37:            <NA>                <NA> a233e2be-3564-401c-a501-099369ddd850
#>  38:            <NA>                <NA> 1078b2d3-d7cb-4e84-b2a8-f7e6d9b6b575
#>  39:            <NA>                <NA> 991fc928-017b-4a86-a96d-062fea6b72d9
#>  40:            <NA>                <NA> 8ebe680a-6322-4960-a35a-22f23b670e7c
#>  41:            <NA>                <NA> aa670804-7c94-458e-a299-cfe2f31ebfa2
#>  42:            <NA>                <NA> 27497307-aa39-4521-902a-4c882c599739
#>  43:            <NA>                <NA> 307f5202-3b54-42b1-af25-3deac8744290
#>  44:            <NA>                <NA> cfa2fb5c-bb45-401a-9439-adb8d19b8717
#>  45:            <NA>                <NA> 6e1df744-a1c8-496d-b97a-f633a4960935
#>  46:            <NA>                <NA> 81c0eb46-7845-40dd-9b0f-a6f1ff911ada
#>  47:            <NA>                <NA> 2859404d-4e2f-4ca8-867b-36ffe6d207e3
#>  48:            <NA>                <NA> b7b764eb-3ae5-4b5b-bd66-0d067e8a3142
#>  49:            <NA>                <NA> 3219f3c1-ce2e-4b2f-8bca-621250e76730
#>  50:            <NA>                <NA> f6d4a1d7-911e-4c6d-a2b0-654cba317d6f
#>  51:            <NA>                <NA> 2015e90e-86ae-48df-90e2-bbd39ea770c3
#>  52:            <NA>                <NA> a9f173e9-14af-4646-abcc-26241d413d00
#>  53:            <NA>                <NA> c9a8848d-b403-4875-812b-781efebfbebc
#>  54:            <NA>                <NA> 28cb358f-d5e8-48ec-8a64-d6068f93bfc8
#>  55:            <NA>                <NA> c7450248-32bd-4205-b143-a36340b34541
#>  56:            <NA>                <NA> 7c46e52c-fe72-4d28-b960-f94f10ed59e3
#>  57:            <NA>                <NA> d0c8e9e1-a91b-4bfc-b60f-484f5ff3f851
#>  58:            <NA>                <NA> 65b394d8-3690-4d06-b595-e1a865fece3c
#>  59:            <NA>                <NA> 94d4e3a5-95d0-49e5-9748-1d728f567349
#>  60:            <NA>                <NA> 69e17007-35c7-494c-8a07-915d43ca991c
#>  61:            <NA>                <NA> 6158698b-de34-44de-8e62-926aee90fa5e
#>  62:            <NA>                <NA> b56fbc2e-379f-4fd1-91ac-104ecd435c1c
#>  63:            <NA>                <NA> a7760501-d6a0-4bef-a87e-e56a255e53ac
#>  64:            <NA>                <NA> 18a0d0b2-46a1-4654-b444-00a44556d25a
#>  65:            <NA>                <NA> 6d6c5760-ea75-45d0-99db-79451692860f
#>  66:            <NA>                <NA> 0c37f170-2b1a-43a0-8788-5221444d0047
#>  67:            <NA>                <NA> 3cc4cd3e-3189-44d7-932d-8f3da4532e83
#>  68:            <NA>                <NA> 68753326-9d37-4ee8-8993-a1307d43a522
#>  69:            <NA>                <NA> ff743fd3-7950-4136-8595-31c0b45572c3
#>  70:            <NA>                <NA> 404ece5a-e6c6-4478-a5ea-ba9b76520efc
#>  71:            <NA>                <NA> 7d16e5a6-683a-4809-8622-323d524fab68
#>  72:            <NA>                <NA> 4125de54-5a20-4ee4-9fae-303713db6e47
#>  73:            <NA>                <NA> 12d9a7cd-858a-4bac-b161-fa92a1ccb28b
#>  74:            <NA>                <NA> f7267c34-4d08-41fe-8045-df61e86a1f69
#>  75:            <NA>                <NA> 4213c88d-e82b-4afa-8402-812d16b84020
#>  76:            <NA>                <NA> 04976375-422d-4457-a374-7e27d116c65b
#>  77:            <NA>                <NA> 9efbaae0-38ad-4cd0-bc40-4a231df0a997
#>  78:            <NA>                <NA> 1ee85897-d633-41b6-ac52-696a6b3acb4e
#>  79:            <NA>                <NA> d93320b9-6f96-45db-9346-5dc1fce920fa
#>  80:            <NA>                <NA> 22868de3-f2b8-4bb3-8bf9-304f496989aa
#>  81:            <NA>                <NA> 0a188ea5-8e67-499f-b920-730ca6592b54
#>  82:            <NA>                <NA> a04383ed-52b3-4cec-9922-ed1c8b800d1f
#>  83:            <NA>                <NA> 071aa0eb-d559-4d87-a722-fc9de3b610b2
#>  84:            <NA>                <NA> cebe8f09-07f2-436a-9cc1-430e366f9de9
#>  85:            <NA>                <NA> b896b413-e5dc-460c-956b-aac83bffd164
#>  86:            <NA>                <NA> 68d74295-d073-4fe6-acbe-8e31064d011c
#>  87:            <NA>                <NA> 0caabc3d-9d7e-47d0-9e5a-276aa219947e
#>  88:            <NA>                <NA> a0a5a4a3-88bc-4656-823c-a1cda784ba7f
#>  89:            <NA>                <NA> a26caae4-4231-4682-862e-ee0420b01346
#>  90:            <NA>                <NA> 1b0269d7-4821-4805-a2e7-867256f2b927
#>  91:            <NA>                <NA> 3665be72-9f1e-49e1-9215-186bffbea652
#>  92:            <NA>                <NA> 0469f12c-35c1-4270-80d8-2d689994cd10
#>  93:            <NA>                <NA> 09e2aef1-b02a-4711-92c9-fc8a913a1a62
#>  94:            <NA>                <NA> 1e995008-e90e-4ae7-b12d-87b8d6f274c8
#>  95:            <NA>                <NA> 9ebf9b39-5dc9-4840-a7ab-e44c8e229c13
#>  96:            <NA>                <NA> f99b4788-c7b8-439b-9e71-fccdc40e7d88
#>  97:            <NA>                <NA> bb449ccd-3ff9-4d0b-92ce-5c60ffa73e7b
#>  98:            <NA>                <NA> 5de5d2db-84e5-4581-80da-180ad10ec0a9
#>  99:            <NA>                <NA> e00c1ba8-b956-4b53-8b19-98b60669fcf5
#> 100:            <NA>                <NA> eb4fbf0e-78eb-4e29-b28d-5bf3e5dbe8f9
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
