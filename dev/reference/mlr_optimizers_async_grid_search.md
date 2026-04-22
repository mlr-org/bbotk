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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-04-22 10:04:32
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-04-22 10:04:32
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-04-22 10:04:32
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-04-22 10:04:32
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-04-22 10:04:32
#>   6: finished -10.000000  0.5555556 -146.64198 2026-04-22 10:04:32
#>   7: finished -10.000000  1.6666667 -155.77778 2026-04-22 10:04:32
#>   8: finished -10.000000  2.7777778 -167.38272 2026-04-22 10:04:32
#>   9: finished -10.000000  3.8888889 -181.45679 2026-04-22 10:04:32
#>  10: finished -10.000000  5.0000000 -198.00000 2026-04-22 10:04:32
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-04-22 10:04:32
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-04-22 10:04:32
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-04-22 10:04:32
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-04-22 10:04:32
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-04-22 10:04:32
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-04-22 10:04:32
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-04-22 10:04:32
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-04-22 10:04:32
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-04-22 10:04:32
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-04-22 10:04:32
#>  21:   failed  10.000000  5.0000000         NA 2026-04-22 10:04:32
#>  22:   failed  10.000000  3.8888889         NA 2026-04-22 10:04:32
#>  23:   failed  10.000000  2.7777778         NA 2026-04-22 10:04:32
#>  24:   failed  10.000000  1.6666667         NA 2026-04-22 10:04:32
#>  25:   failed  10.000000  0.5555556         NA 2026-04-22 10:04:32
#>  26:   failed  10.000000 -0.5555556         NA 2026-04-22 10:04:32
#>  27:   failed  10.000000 -1.6666667         NA 2026-04-22 10:04:32
#>  28:   failed  10.000000 -2.7777778         NA 2026-04-22 10:04:32
#>  29:   failed  10.000000 -3.8888889         NA 2026-04-22 10:04:32
#>  30:   failed  10.000000 -5.0000000         NA 2026-04-22 10:04:32
#>  31:   failed   7.777778  5.0000000         NA 2026-04-22 10:04:32
#>  32:   failed   7.777778  3.8888889         NA 2026-04-22 10:04:32
#>  33:   failed   7.777778  2.7777778         NA 2026-04-22 10:04:32
#>  34:   failed   7.777778  1.6666667         NA 2026-04-22 10:04:32
#>  35:   failed   7.777778  0.5555556         NA 2026-04-22 10:04:32
#>  36:   failed   7.777778 -0.5555556         NA 2026-04-22 10:04:32
#>  37:   failed   7.777778 -1.6666667         NA 2026-04-22 10:04:32
#>  38:   failed   7.777778 -2.7777778         NA 2026-04-22 10:04:32
#>  39:   failed   7.777778 -3.8888889         NA 2026-04-22 10:04:32
#>  40:   failed   7.777778 -5.0000000         NA 2026-04-22 10:04:32
#>  41:   failed   5.555556  5.0000000         NA 2026-04-22 10:04:32
#>  42:   failed   5.555556  3.8888889         NA 2026-04-22 10:04:32
#>  43:   failed   5.555556  2.7777778         NA 2026-04-22 10:04:32
#>  44:   failed   5.555556  1.6666667         NA 2026-04-22 10:04:32
#>  45:   failed   5.555556  0.5555556         NA 2026-04-22 10:04:32
#>  46:   failed   5.555556 -0.5555556         NA 2026-04-22 10:04:32
#>  47:   failed   5.555556 -1.6666667         NA 2026-04-22 10:04:32
#>  48:   failed   5.555556 -2.7777778         NA 2026-04-22 10:04:32
#>  49:   failed   5.555556 -3.8888889         NA 2026-04-22 10:04:32
#>  50:   failed   5.555556 -5.0000000         NA 2026-04-22 10:04:32
#>  51:   failed   3.333333  5.0000000         NA 2026-04-22 10:04:32
#>  52:   failed   3.333333  3.8888889         NA 2026-04-22 10:04:32
#>  53:   failed   3.333333  2.7777778         NA 2026-04-22 10:04:32
#>  54:   failed   3.333333  1.6666667         NA 2026-04-22 10:04:32
#>  55:   failed   3.333333  0.5555556         NA 2026-04-22 10:04:32
#>  56:   failed   3.333333 -0.5555556         NA 2026-04-22 10:04:32
#>  57:   failed   3.333333 -1.6666667         NA 2026-04-22 10:04:32
#>  58:   failed   3.333333 -2.7777778         NA 2026-04-22 10:04:32
#>  59:   failed   3.333333 -3.8888889         NA 2026-04-22 10:04:32
#>  60:   failed   3.333333 -5.0000000         NA 2026-04-22 10:04:32
#>  61:   failed   1.111111  5.0000000         NA 2026-04-22 10:04:32
#>  62:   failed   1.111111  3.8888889         NA 2026-04-22 10:04:32
#>  63:   failed   1.111111  2.7777778         NA 2026-04-22 10:04:32
#>  64:   failed   1.111111  1.6666667         NA 2026-04-22 10:04:32
#>  65:   failed   1.111111  0.5555556         NA 2026-04-22 10:04:32
#>  66:   failed   1.111111 -0.5555556         NA 2026-04-22 10:04:32
#>  67:   failed   1.111111 -1.6666667         NA 2026-04-22 10:04:32
#>  68:   failed   1.111111 -2.7777778         NA 2026-04-22 10:04:32
#>  69:   failed   1.111111 -3.8888889         NA 2026-04-22 10:04:32
#>  70:   failed   1.111111 -5.0000000         NA 2026-04-22 10:04:32
#>  71:   failed  -1.111111  5.0000000         NA 2026-04-22 10:04:32
#>  72:   failed  -1.111111  3.8888889         NA 2026-04-22 10:04:32
#>  73:   failed  -1.111111  2.7777778         NA 2026-04-22 10:04:32
#>  74:   failed  -1.111111  1.6666667         NA 2026-04-22 10:04:32
#>  75:   failed  -1.111111  0.5555556         NA 2026-04-22 10:04:32
#>  76:   failed  -1.111111 -0.5555556         NA 2026-04-22 10:04:32
#>  77:   failed  -1.111111 -1.6666667         NA 2026-04-22 10:04:32
#>  78:   failed  -1.111111 -2.7777778         NA 2026-04-22 10:04:32
#>  79:   failed  -1.111111 -3.8888889         NA 2026-04-22 10:04:32
#>  80:   failed  -1.111111 -5.0000000         NA 2026-04-22 10:04:32
#>  81:   failed  -3.333333  5.0000000         NA 2026-04-22 10:04:32
#>  82:   failed  -3.333333  3.8888889         NA 2026-04-22 10:04:32
#>  83:   failed  -3.333333  2.7777778         NA 2026-04-22 10:04:32
#>  84:   failed  -3.333333  1.6666667         NA 2026-04-22 10:04:32
#>  85:   failed  -3.333333  0.5555556         NA 2026-04-22 10:04:32
#>  86:   failed  -3.333333 -0.5555556         NA 2026-04-22 10:04:32
#>  87:   failed  -3.333333 -1.6666667         NA 2026-04-22 10:04:32
#>  88:   failed  -3.333333 -2.7777778         NA 2026-04-22 10:04:32
#>  89:   failed  -3.333333 -3.8888889         NA 2026-04-22 10:04:32
#>  90:   failed  -3.333333 -5.0000000         NA 2026-04-22 10:04:32
#>  91:   failed  -5.555556  5.0000000         NA 2026-04-22 10:04:32
#>  92:   failed  -5.555556  3.8888889         NA 2026-04-22 10:04:32
#>  93:   failed  -5.555556  2.7777778         NA 2026-04-22 10:04:32
#>  94:   failed  -5.555556  1.6666667         NA 2026-04-22 10:04:32
#>  95:   failed  -5.555556  0.5555556         NA 2026-04-22 10:04:32
#>  96:   failed  -5.555556 -0.5555556         NA 2026-04-22 10:04:32
#>  97:   failed  -5.555556 -1.6666667         NA 2026-04-22 10:04:32
#>  98:   failed  -5.555556 -2.7777778         NA 2026-04-22 10:04:32
#>  99:   failed  -5.555556 -3.8888889         NA 2026-04-22 10:04:32
#> 100:   failed  -5.555556 -5.0000000         NA 2026-04-22 10:04:32
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-04-22 10:04:33 2daaf777-d85c-4a09-9fb3-0d584ddd5436
#>   2: sinking_raccoon 2026-04-22 10:04:33 1fbcf9af-b04d-48d9-8a04-83d764c9420d
#>   3: sinking_raccoon 2026-04-22 10:04:33 85741531-1827-415a-8300-28988c7176f3
#>   4: sinking_raccoon 2026-04-22 10:04:33 54d3a352-be7c-4b20-b4f3-d7dcf998f776
#>   5: sinking_raccoon 2026-04-22 10:04:33 8543048d-2b10-4bf7-a627-55a44d8af80c
#>   6: sinking_raccoon 2026-04-22 10:04:33 d367f908-bc9a-4274-b024-73fadd56a324
#>   7: sinking_raccoon 2026-04-22 10:04:33 243f75dd-b543-4de3-b98e-17a672c0f16a
#>   8: sinking_raccoon 2026-04-22 10:04:33 1cf99d91-0a98-4070-a077-9118dc4a1eaf
#>   9: sinking_raccoon 2026-04-22 10:04:33 c71277aa-cf8b-48ad-9103-c5d574a78bf2
#>  10: sinking_raccoon 2026-04-22 10:04:33 90287750-4db2-4867-8211-8788dd1c24c4
#>  11: sinking_raccoon 2026-04-22 10:04:33 2abd423f-9f56-4b61-b75a-d8e8b6e92b02
#>  12: sinking_raccoon 2026-04-22 10:04:33 c0b7fa60-0127-44cb-b2cf-56257cc3df9d
#>  13: sinking_raccoon 2026-04-22 10:04:33 e851b42f-8697-4531-9c26-673326e7f13b
#>  14: sinking_raccoon 2026-04-22 10:04:33 3a6dbcf7-ef75-4429-97aa-882fcb85c302
#>  15: sinking_raccoon 2026-04-22 10:04:33 8c9ae048-f509-4d1e-a5bf-61557af157f5
#>  16: sinking_raccoon 2026-04-22 10:04:33 a6447aa5-2f14-40b0-8aea-2d51978bd4bb
#>  17: sinking_raccoon 2026-04-22 10:04:33 da7f3fcf-1b0a-4862-bce6-85020e80f80b
#>  18: sinking_raccoon 2026-04-22 10:04:33 18771475-237a-48c4-9d41-45281a661a2c
#>  19: sinking_raccoon 2026-04-22 10:04:33 b0f5049d-c2b4-429c-a440-c893943860fa
#>  20: sinking_raccoon 2026-04-22 10:04:33 81881dce-5442-4cbc-833a-5182ce5593d2
#>  21:            <NA>                <NA> 86836458-a231-411f-ba61-644d39250d7e
#>  22:            <NA>                <NA> 40b02615-b4bb-4b37-908d-ea6b254356b8
#>  23:            <NA>                <NA> 84a2c851-6e5c-40c9-87a0-d6bd59b5f1cd
#>  24:            <NA>                <NA> 2945a8e1-0434-4cef-a3eb-b4fbbb29d624
#>  25:            <NA>                <NA> 6ae84965-c392-47d3-a783-a82d9726c12a
#>  26:            <NA>                <NA> 7c2cd119-5edc-48d3-95c4-cf6e3abe8985
#>  27:            <NA>                <NA> 4bf3862f-8da6-4df4-b485-61505dd52b6c
#>  28:            <NA>                <NA> 08c2c380-a9f5-42ba-9ea8-2eb07f1769bb
#>  29:            <NA>                <NA> 72d6c3eb-e825-44ba-93d6-8127dc0d85b7
#>  30:            <NA>                <NA> c86e0883-61a7-45ec-800e-8b50bcc34e88
#>  31:            <NA>                <NA> b0384d16-fb9e-497b-a04d-19970e161b5f
#>  32:            <NA>                <NA> d3665f43-f1d9-49f4-8243-31db294f5c38
#>  33:            <NA>                <NA> 150fabef-e1ec-43ea-8f19-e13cbf09b3ec
#>  34:            <NA>                <NA> a9f3abde-4f0e-49eb-803f-6284d9ec7dd4
#>  35:            <NA>                <NA> 227c63c9-38a8-433c-b078-7a0ec39ac917
#>  36:            <NA>                <NA> 54230833-408c-47e4-8302-381fc4c38c87
#>  37:            <NA>                <NA> b0a69468-ec86-40f0-9804-bba134c2b5a4
#>  38:            <NA>                <NA> cfa6b01a-f577-41db-899e-02121d66ffe4
#>  39:            <NA>                <NA> 125647b2-1906-4864-af05-7c174478c4d6
#>  40:            <NA>                <NA> 12fbf630-a420-4a80-9e2e-3ac53eea211a
#>  41:            <NA>                <NA> 61753473-957a-4bf3-86e7-50f229546f84
#>  42:            <NA>                <NA> 6075031a-1c03-4f61-beb7-7713ffc66c51
#>  43:            <NA>                <NA> 95239411-4804-4d26-b70e-c14e96be3073
#>  44:            <NA>                <NA> c95db1b5-bda9-49e0-a711-b4a2261e29b7
#>  45:            <NA>                <NA> e013afa0-8841-427f-a685-ea003ebbc1f3
#>  46:            <NA>                <NA> a63f886a-c8f4-4a42-9c92-4278596fbe56
#>  47:            <NA>                <NA> 31ea754e-5d48-4f37-a393-fa9d4a3403f5
#>  48:            <NA>                <NA> 158d5585-6b7f-44af-a313-cb629b091cb2
#>  49:            <NA>                <NA> 2a023bd7-b5ac-4aab-bc3f-15c4355de0f1
#>  50:            <NA>                <NA> 9f4755c1-6286-463c-8ec3-2a7712332a1e
#>  51:            <NA>                <NA> de19da6a-c1ae-481f-b22f-2fae68703c2a
#>  52:            <NA>                <NA> fad18dd4-458e-4ef3-8ff6-d84ced6f571f
#>  53:            <NA>                <NA> da0d0b18-3889-4e00-a07b-2ba1bc22a73a
#>  54:            <NA>                <NA> 1510ef49-e96b-49d5-bdaf-6bc389241c70
#>  55:            <NA>                <NA> a8c6f88c-1539-4335-b4e1-ad1c4011234c
#>  56:            <NA>                <NA> 287af51e-22a1-4a8f-a491-3a222659bfd0
#>  57:            <NA>                <NA> 8229addb-5210-4c35-8f82-26bfb5d401e8
#>  58:            <NA>                <NA> 16c47f43-f8b2-4aa0-9496-ca4b6287bce4
#>  59:            <NA>                <NA> 50fc33ad-7026-40d0-8b8f-10a0eb922895
#>  60:            <NA>                <NA> 82d64966-7056-4c1f-9854-a042494ea6b8
#>  61:            <NA>                <NA> d37b155a-d783-48b4-a84c-f9e5c79733ce
#>  62:            <NA>                <NA> 3a1e4ba7-4250-4c7c-91eb-8d841d22078b
#>  63:            <NA>                <NA> e604d949-1524-427e-9725-0c55de27f159
#>  64:            <NA>                <NA> 632e21ad-909c-4dde-9d48-2dc93caa80d0
#>  65:            <NA>                <NA> 8420a8a7-f6b4-430f-91b6-fcc7c7975e07
#>  66:            <NA>                <NA> 4b3b8b75-c27a-40bf-8b57-636240db230a
#>  67:            <NA>                <NA> d40cea87-e085-4b2e-8e94-c975ec55c55a
#>  68:            <NA>                <NA> 550154e6-bd18-499a-9cf2-d3d1abe8aa8d
#>  69:            <NA>                <NA> 5afd5d8b-d7aa-47e6-81c1-d682c9a471e1
#>  70:            <NA>                <NA> 1e449d56-72ac-4691-921a-b30f29976013
#>  71:            <NA>                <NA> 87e0c536-5498-4021-acd5-a9e6b794a67b
#>  72:            <NA>                <NA> 5ffd17fe-cdf9-4c0a-8178-a7e1994f72a2
#>  73:            <NA>                <NA> de30b1ae-25e5-426b-8fe9-cf2a254594dd
#>  74:            <NA>                <NA> 1a7291a6-3152-432f-bf4d-1ba20821dd8f
#>  75:            <NA>                <NA> 1b73e413-82ad-4d86-b4dd-b7a4ae5513c6
#>  76:            <NA>                <NA> 49dffdef-6c0c-4cf8-bb45-7028dee06576
#>  77:            <NA>                <NA> 5f94154f-ce79-4f07-a9f5-149cfc7bced1
#>  78:            <NA>                <NA> a4f94cd9-827b-4900-81ae-9b13fbcd9796
#>  79:            <NA>                <NA> 239a2162-f6d3-4c46-abd7-742abaea93ac
#>  80:            <NA>                <NA> 19ac8ddc-a1b4-4d93-b3f4-732fe2674247
#>  81:            <NA>                <NA> a2e76b84-4de1-45a5-8fd7-03291d99423f
#>  82:            <NA>                <NA> d1fce6ff-52b0-487b-ac3a-fd1e9be511c2
#>  83:            <NA>                <NA> f6bf1a80-43ab-47d6-b3ed-50933e9630a5
#>  84:            <NA>                <NA> 2585ec93-5ad1-4b80-9da3-81a084d8d694
#>  85:            <NA>                <NA> 38b19355-8048-4b89-bf82-1e61fbf396f3
#>  86:            <NA>                <NA> cc09414f-44de-4ade-beff-a08c7c11fcdc
#>  87:            <NA>                <NA> 40a7eb49-e11a-4691-9c11-4f7f21e016f4
#>  88:            <NA>                <NA> 480d6689-a685-4de3-ac85-ee3f9b3fba03
#>  89:            <NA>                <NA> 85949759-c57f-4b19-9fee-eeb9bdffaeee
#>  90:            <NA>                <NA> 2a7cefdb-ed4f-4454-b8b8-e6d685c43e33
#>  91:            <NA>                <NA> d3efd979-f7eb-46ee-bf60-f65a824028f1
#>  92:            <NA>                <NA> 1d466275-e09c-455c-bfb9-457f017cbb1c
#>  93:            <NA>                <NA> 22feca90-4d65-43cf-a5b5-58e7f3dc1428
#>  94:            <NA>                <NA> 8167d735-4a7b-4eec-9406-a1549b1f7d11
#>  95:            <NA>                <NA> 66f6adfb-5c68-4a48-b682-628476a45aee
#>  96:            <NA>                <NA> d7398ced-27f1-4377-8af9-c85c566df496
#>  97:            <NA>                <NA> 94defb20-a7bb-454f-a5bd-172a8cded298
#>  98:            <NA>                <NA> 77daf44b-b34f-4433-bd1b-bc67791c5924
#>  99:            <NA>                <NA> 5a1e2aa4-6606-4fef-bc63-2641f6ad27a8
#> 100:            <NA>                <NA> f6c6b4e6-9155-42d1-9b6f-26c43e10cd05
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
