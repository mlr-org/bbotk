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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-06-22 13:44:39
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-06-22 13:44:39
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-06-22 13:44:39
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-06-22 13:44:39
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-06-22 13:44:39
#>   6: finished -10.000000  0.5555556 -146.64198 2026-06-22 13:44:39
#>   7: finished -10.000000  1.6666667 -155.77778 2026-06-22 13:44:39
#>   8: finished -10.000000  2.7777778 -167.38272 2026-06-22 13:44:39
#>   9: finished -10.000000  3.8888889 -181.45679 2026-06-22 13:44:39
#>  10: finished -10.000000  5.0000000 -198.00000 2026-06-22 13:44:39
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-06-22 13:44:39
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-06-22 13:44:39
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-06-22 13:44:39
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-06-22 13:44:39
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-06-22 13:44:39
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-06-22 13:44:39
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-06-22 13:44:39
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-06-22 13:44:39
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-06-22 13:44:39
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-06-22 13:44:39
#>  21:   failed  10.000000  5.0000000         NA 2026-06-22 13:44:39
#>  22:   failed  10.000000  3.8888889         NA 2026-06-22 13:44:39
#>  23:   failed  10.000000  2.7777778         NA 2026-06-22 13:44:39
#>  24:   failed  10.000000  1.6666667         NA 2026-06-22 13:44:39
#>  25:   failed  10.000000  0.5555556         NA 2026-06-22 13:44:39
#>  26:   failed  10.000000 -0.5555556         NA 2026-06-22 13:44:39
#>  27:   failed  10.000000 -1.6666667         NA 2026-06-22 13:44:39
#>  28:   failed  10.000000 -2.7777778         NA 2026-06-22 13:44:39
#>  29:   failed  10.000000 -3.8888889         NA 2026-06-22 13:44:39
#>  30:   failed  10.000000 -5.0000000         NA 2026-06-22 13:44:39
#>  31:   failed   7.777778  5.0000000         NA 2026-06-22 13:44:39
#>  32:   failed   7.777778  3.8888889         NA 2026-06-22 13:44:39
#>  33:   failed   7.777778  2.7777778         NA 2026-06-22 13:44:39
#>  34:   failed   7.777778  1.6666667         NA 2026-06-22 13:44:39
#>  35:   failed   7.777778  0.5555556         NA 2026-06-22 13:44:39
#>  36:   failed   7.777778 -0.5555556         NA 2026-06-22 13:44:39
#>  37:   failed   7.777778 -1.6666667         NA 2026-06-22 13:44:39
#>  38:   failed   7.777778 -2.7777778         NA 2026-06-22 13:44:39
#>  39:   failed   7.777778 -3.8888889         NA 2026-06-22 13:44:39
#>  40:   failed   7.777778 -5.0000000         NA 2026-06-22 13:44:39
#>  41:   failed   5.555556  5.0000000         NA 2026-06-22 13:44:39
#>  42:   failed   5.555556  3.8888889         NA 2026-06-22 13:44:39
#>  43:   failed   5.555556  2.7777778         NA 2026-06-22 13:44:39
#>  44:   failed   5.555556  1.6666667         NA 2026-06-22 13:44:39
#>  45:   failed   5.555556  0.5555556         NA 2026-06-22 13:44:39
#>  46:   failed   5.555556 -0.5555556         NA 2026-06-22 13:44:39
#>  47:   failed   5.555556 -1.6666667         NA 2026-06-22 13:44:39
#>  48:   failed   5.555556 -2.7777778         NA 2026-06-22 13:44:39
#>  49:   failed   5.555556 -3.8888889         NA 2026-06-22 13:44:39
#>  50:   failed   5.555556 -5.0000000         NA 2026-06-22 13:44:39
#>  51:   failed   3.333333  5.0000000         NA 2026-06-22 13:44:39
#>  52:   failed   3.333333  3.8888889         NA 2026-06-22 13:44:39
#>  53:   failed   3.333333  2.7777778         NA 2026-06-22 13:44:39
#>  54:   failed   3.333333  1.6666667         NA 2026-06-22 13:44:39
#>  55:   failed   3.333333  0.5555556         NA 2026-06-22 13:44:39
#>  56:   failed   3.333333 -0.5555556         NA 2026-06-22 13:44:39
#>  57:   failed   3.333333 -1.6666667         NA 2026-06-22 13:44:39
#>  58:   failed   3.333333 -2.7777778         NA 2026-06-22 13:44:39
#>  59:   failed   3.333333 -3.8888889         NA 2026-06-22 13:44:39
#>  60:   failed   3.333333 -5.0000000         NA 2026-06-22 13:44:39
#>  61:   failed   1.111111  5.0000000         NA 2026-06-22 13:44:39
#>  62:   failed   1.111111  3.8888889         NA 2026-06-22 13:44:39
#>  63:   failed   1.111111  2.7777778         NA 2026-06-22 13:44:39
#>  64:   failed   1.111111  1.6666667         NA 2026-06-22 13:44:39
#>  65:   failed   1.111111  0.5555556         NA 2026-06-22 13:44:39
#>  66:   failed   1.111111 -0.5555556         NA 2026-06-22 13:44:39
#>  67:   failed   1.111111 -1.6666667         NA 2026-06-22 13:44:39
#>  68:   failed   1.111111 -2.7777778         NA 2026-06-22 13:44:39
#>  69:   failed   1.111111 -3.8888889         NA 2026-06-22 13:44:39
#>  70:   failed   1.111111 -5.0000000         NA 2026-06-22 13:44:39
#>  71:   failed  -1.111111  5.0000000         NA 2026-06-22 13:44:39
#>  72:   failed  -1.111111  3.8888889         NA 2026-06-22 13:44:39
#>  73:   failed  -1.111111  2.7777778         NA 2026-06-22 13:44:39
#>  74:   failed  -1.111111  1.6666667         NA 2026-06-22 13:44:39
#>  75:   failed  -1.111111  0.5555556         NA 2026-06-22 13:44:39
#>  76:   failed  -1.111111 -0.5555556         NA 2026-06-22 13:44:39
#>  77:   failed  -1.111111 -1.6666667         NA 2026-06-22 13:44:39
#>  78:   failed  -1.111111 -2.7777778         NA 2026-06-22 13:44:39
#>  79:   failed  -1.111111 -3.8888889         NA 2026-06-22 13:44:39
#>  80:   failed  -1.111111 -5.0000000         NA 2026-06-22 13:44:39
#>  81:   failed  -3.333333  5.0000000         NA 2026-06-22 13:44:39
#>  82:   failed  -3.333333  3.8888889         NA 2026-06-22 13:44:39
#>  83:   failed  -3.333333  2.7777778         NA 2026-06-22 13:44:39
#>  84:   failed  -3.333333  1.6666667         NA 2026-06-22 13:44:39
#>  85:   failed  -3.333333  0.5555556         NA 2026-06-22 13:44:39
#>  86:   failed  -3.333333 -0.5555556         NA 2026-06-22 13:44:39
#>  87:   failed  -3.333333 -1.6666667         NA 2026-06-22 13:44:39
#>  88:   failed  -3.333333 -2.7777778         NA 2026-06-22 13:44:39
#>  89:   failed  -3.333333 -3.8888889         NA 2026-06-22 13:44:39
#>  90:   failed  -3.333333 -5.0000000         NA 2026-06-22 13:44:39
#>  91:   failed  -5.555556  5.0000000         NA 2026-06-22 13:44:39
#>  92:   failed  -5.555556  3.8888889         NA 2026-06-22 13:44:39
#>  93:   failed  -5.555556  2.7777778         NA 2026-06-22 13:44:39
#>  94:   failed  -5.555556  1.6666667         NA 2026-06-22 13:44:39
#>  95:   failed  -5.555556  0.5555556         NA 2026-06-22 13:44:39
#>  96:   failed  -5.555556 -0.5555556         NA 2026-06-22 13:44:39
#>  97:   failed  -5.555556 -1.6666667         NA 2026-06-22 13:44:39
#>  98:   failed  -5.555556 -2.7777778         NA 2026-06-22 13:44:39
#>  99:   failed  -5.555556 -3.8888889         NA 2026-06-22 13:44:39
#> 100:   failed  -5.555556 -5.0000000         NA 2026-06-22 13:44:39
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-06-22 13:44:40 9522ad5f-0975-468f-9cc2-6d6905511071
#>   2: sinking_raccoon 2026-06-22 13:44:40 8cede3d7-9956-438e-b6db-230940854b6e
#>   3: sinking_raccoon 2026-06-22 13:44:40 0bb002c2-904d-49e9-9a83-db1aeaebbfb5
#>   4: sinking_raccoon 2026-06-22 13:44:40 eb247ea2-ac84-4411-8863-e1b5c0bea41c
#>   5: sinking_raccoon 2026-06-22 13:44:40 32003ddd-6aa6-442a-88e3-ff094198e34e
#>   6: sinking_raccoon 2026-06-22 13:44:40 8fe6cc97-27af-40de-96cb-0f1b61c221b0
#>   7: sinking_raccoon 2026-06-22 13:44:40 2aa28eb3-6503-43ec-ab28-8866f479705f
#>   8: sinking_raccoon 2026-06-22 13:44:40 38bdd5dd-74a2-48be-b93e-470d423af8f0
#>   9: sinking_raccoon 2026-06-22 13:44:40 ffeed8df-c213-40c1-a570-892b4c7ce1fe
#>  10: sinking_raccoon 2026-06-22 13:44:40 2e23b54a-d046-402c-b016-f1f42e4ebe0b
#>  11: sinking_raccoon 2026-06-22 13:44:40 50a800b7-8154-464a-9678-6504a5936d13
#>  12: sinking_raccoon 2026-06-22 13:44:40 fb351051-6967-46a8-80a3-8980c18388ac
#>  13: sinking_raccoon 2026-06-22 13:44:40 d79bd588-ee18-4e62-bafa-9e904f6bab2c
#>  14: sinking_raccoon 2026-06-22 13:44:40 96ca18d8-c625-4c8d-8705-62354d566713
#>  15: sinking_raccoon 2026-06-22 13:44:40 7a907fc2-9370-466b-980b-3d1cf27cd655
#>  16: sinking_raccoon 2026-06-22 13:44:40 31228811-95b8-4690-86e8-5627ce01bc62
#>  17: sinking_raccoon 2026-06-22 13:44:40 082de2ce-dded-44ea-b863-6711c0c5e80b
#>  18: sinking_raccoon 2026-06-22 13:44:40 e9b459e1-2d56-440a-b5a6-439ca287ac94
#>  19: sinking_raccoon 2026-06-22 13:44:40 11e5a5c2-0cb4-4af1-bf7b-416d4137fcf9
#>  20: sinking_raccoon 2026-06-22 13:44:40 00924dad-7c1d-472a-9157-deda1b8c6ec6
#>  21:            <NA>                <NA> 9b4bb71e-9953-442b-8fa0-c5533276162d
#>  22:            <NA>                <NA> 5553a344-5c70-45f8-9256-d5bcc93eca7c
#>  23:            <NA>                <NA> ecc7ae28-b6a0-4094-9e0a-bee2c1ed4d8a
#>  24:            <NA>                <NA> 575ab757-20e4-46f9-b797-b9b4fa249e3f
#>  25:            <NA>                <NA> 0cd809a2-95c7-46d1-b570-c11bb8c9d67e
#>  26:            <NA>                <NA> 5bd1ab1b-9e2f-4e72-91af-1b2d73619546
#>  27:            <NA>                <NA> e45d801e-ca8d-4dc2-a892-89ec6a54e107
#>  28:            <NA>                <NA> 36239257-6aba-4251-aa9c-00e8bbaf1732
#>  29:            <NA>                <NA> a14d87c0-797d-4ee7-b422-7701caf7d158
#>  30:            <NA>                <NA> d0ccad69-cb26-42e6-9477-ebbc3f4f26de
#>  31:            <NA>                <NA> 11853eb5-597b-4a95-93da-64511e7858b0
#>  32:            <NA>                <NA> ca0134ba-3c40-4e54-8fe1-f67b1bbdba7c
#>  33:            <NA>                <NA> b9294ccc-8e75-42ea-865c-0f0702d9dbc0
#>  34:            <NA>                <NA> 0f33d09b-02d7-4b9f-851b-f04831c043f7
#>  35:            <NA>                <NA> aa748bc4-2100-42a8-b19f-11218351f035
#>  36:            <NA>                <NA> 0d7a7cde-624c-4985-9694-78563f1ab599
#>  37:            <NA>                <NA> 4552b7cb-df8b-415e-bb46-b96e29ce4e34
#>  38:            <NA>                <NA> ef790d82-45e6-459e-9ade-0279b9b726ca
#>  39:            <NA>                <NA> 860d702c-70ec-46e3-935c-8406adc37df4
#>  40:            <NA>                <NA> 175e19bd-2744-4a05-a858-460101fbcba5
#>  41:            <NA>                <NA> 47c54406-ee37-4ea7-b127-485e33b21d3f
#>  42:            <NA>                <NA> 5011e3b1-863d-4f62-a8e7-77a9f5b0678a
#>  43:            <NA>                <NA> e651c5d8-adf4-49f4-948e-b3992526673c
#>  44:            <NA>                <NA> bac3ca79-7769-4921-afc7-60ad89f6204a
#>  45:            <NA>                <NA> 4f02f570-f524-4fd0-a5e0-edbc2210f2f7
#>  46:            <NA>                <NA> b264a33d-a5c6-4db6-894c-3fb6397398a6
#>  47:            <NA>                <NA> a0d687f6-e469-44c4-bd9c-9cd67e41d312
#>  48:            <NA>                <NA> eb324cf5-7704-4442-8577-e90eef30d581
#>  49:            <NA>                <NA> 1cd39d53-4ee8-41ce-ae53-0a663ed71368
#>  50:            <NA>                <NA> f38a7b6d-093a-42b1-b014-703d6952b3f4
#>  51:            <NA>                <NA> fd769718-692f-4cdb-b33c-83a23c7a8d72
#>  52:            <NA>                <NA> 571a62ff-f85b-428e-9f58-8a0bed7692dc
#>  53:            <NA>                <NA> 0ba6ab7f-1d09-4d84-bab5-789864d50a9a
#>  54:            <NA>                <NA> 8469c108-10d7-4761-b7f7-a70d84901f0d
#>  55:            <NA>                <NA> 8cb3c932-cb08-4080-8d5e-f18d6b3ddb1d
#>  56:            <NA>                <NA> fe4b769b-a8e1-4f09-b270-b4f654b3f50f
#>  57:            <NA>                <NA> 4f1ee532-d092-470e-9bde-b4314a5b3306
#>  58:            <NA>                <NA> 81988e4d-e1f2-4a2a-9eb3-cabfe3ff59df
#>  59:            <NA>                <NA> 3de1383e-3958-4de1-b342-6fee6abff470
#>  60:            <NA>                <NA> 98ff0263-70e4-4780-b7a5-78812ba67c21
#>  61:            <NA>                <NA> 7b75f799-b303-4d38-9f29-7f453930f1f2
#>  62:            <NA>                <NA> 61863c0b-335f-4816-96c4-a3328268d2cf
#>  63:            <NA>                <NA> b8a43c1d-ec76-42da-8e24-b193c9453371
#>  64:            <NA>                <NA> 22e82b5f-9c92-4dd6-80d3-dac9da0c46b4
#>  65:            <NA>                <NA> 9c72dcdd-50ce-46e7-ab56-a92ab73af783
#>  66:            <NA>                <NA> f0b1ad85-d26a-42e1-91ca-d6f55278e1a3
#>  67:            <NA>                <NA> e2e045fb-5d87-444d-bf86-286168bd100b
#>  68:            <NA>                <NA> 1a9a5049-19d0-443e-9c19-5f1f53fd7662
#>  69:            <NA>                <NA> bb661946-0ab1-4df2-87af-aaa230a165af
#>  70:            <NA>                <NA> d2f62b42-4867-4a5d-88d9-819ff977f229
#>  71:            <NA>                <NA> 4ca98bfc-ef45-461b-81f0-d618667fae4c
#>  72:            <NA>                <NA> 19edf8b8-3d4b-49f2-9a5d-46534635ea72
#>  73:            <NA>                <NA> 4fbf8c63-c218-453c-8657-69ecd048e02e
#>  74:            <NA>                <NA> f59340dc-70f0-4067-8b56-b29fba32508d
#>  75:            <NA>                <NA> 63e50c01-6075-4506-86e5-a8e9540b7282
#>  76:            <NA>                <NA> 9560b4e1-cd83-47da-9380-6e1571e69111
#>  77:            <NA>                <NA> dab111e7-3a42-4cfe-8f3f-4fd84cb5d6b2
#>  78:            <NA>                <NA> 52b35de9-45fe-4b57-a55e-1ba30abe929d
#>  79:            <NA>                <NA> fa9b1e1c-9b86-46a3-bbf2-d59429c9e474
#>  80:            <NA>                <NA> e92a655f-48ab-4c99-9aae-46127ae52018
#>  81:            <NA>                <NA> 81c9a445-f04d-4b0d-a379-1f15b4f9c14e
#>  82:            <NA>                <NA> edf39b05-010e-4cdc-a250-e8b06205ca6b
#>  83:            <NA>                <NA> af0b068b-e4f6-463e-b3fb-b16ee9e5da83
#>  84:            <NA>                <NA> b53a61b8-eb75-467d-8e87-b8e578613fe9
#>  85:            <NA>                <NA> 286b4bed-3b7f-442a-b6f3-f2f064b571a9
#>  86:            <NA>                <NA> 3d169075-27cc-44c3-acac-57640f8a2215
#>  87:            <NA>                <NA> 202e41f5-4c17-40bd-aa79-b59dd3bd8655
#>  88:            <NA>                <NA> 673201d8-0ce5-4f9d-944b-c448959cf6e6
#>  89:            <NA>                <NA> 25b245ba-65d5-4bc9-b51a-2f08f394bbae
#>  90:            <NA>                <NA> c3522fde-abed-415f-ab9c-a56761b7fbe2
#>  91:            <NA>                <NA> 80b8493b-438d-40bd-bb1e-e1f14ae5f7bf
#>  92:            <NA>                <NA> 2f8bc0e5-65c2-41c4-8e2f-84f48ab7977a
#>  93:            <NA>                <NA> f29b885f-3175-4e90-939c-4dc3c8eb1fa5
#>  94:            <NA>                <NA> d9e54bc5-9730-4da6-85c7-bcdf4f4157ee
#>  95:            <NA>                <NA> 8aedc2c2-342a-455f-a727-107356b3fbf7
#>  96:            <NA>                <NA> bd18dbbc-1470-44ec-a920-37ecccb3a662
#>  97:            <NA>                <NA> dfaf42b1-1dbf-4fc0-a31f-49a0489d4dd2
#>  98:            <NA>                <NA> 56a34c25-bc6c-4956-9d5a-a7699d7683f0
#>  99:            <NA>                <NA> 26fe818b-5ba3-4198-996c-761da43bf69e
#> 100:            <NA>                <NA> bf46db49-0959-4dcc-8fd9-becff8bd1326
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
