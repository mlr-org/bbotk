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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-06-09 18:24:12
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-06-09 18:24:12
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-06-09 18:24:12
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-06-09 18:24:12
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-06-09 18:24:12
#>   6: finished -10.000000  0.5555556 -146.64198 2026-06-09 18:24:12
#>   7: finished -10.000000  1.6666667 -155.77778 2026-06-09 18:24:12
#>   8: finished -10.000000  2.7777778 -167.38272 2026-06-09 18:24:12
#>   9: finished -10.000000  3.8888889 -181.45679 2026-06-09 18:24:12
#>  10: finished -10.000000  5.0000000 -198.00000 2026-06-09 18:24:12
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-06-09 18:24:12
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-06-09 18:24:12
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-06-09 18:24:12
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-06-09 18:24:12
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-06-09 18:24:12
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-06-09 18:24:12
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-06-09 18:24:12
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-06-09 18:24:12
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-06-09 18:24:12
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-06-09 18:24:12
#>  21:   failed  10.000000  5.0000000         NA 2026-06-09 18:24:12
#>  22:   failed  10.000000  3.8888889         NA 2026-06-09 18:24:12
#>  23:   failed  10.000000  2.7777778         NA 2026-06-09 18:24:12
#>  24:   failed  10.000000  1.6666667         NA 2026-06-09 18:24:12
#>  25:   failed  10.000000  0.5555556         NA 2026-06-09 18:24:12
#>  26:   failed  10.000000 -0.5555556         NA 2026-06-09 18:24:12
#>  27:   failed  10.000000 -1.6666667         NA 2026-06-09 18:24:12
#>  28:   failed  10.000000 -2.7777778         NA 2026-06-09 18:24:12
#>  29:   failed  10.000000 -3.8888889         NA 2026-06-09 18:24:12
#>  30:   failed  10.000000 -5.0000000         NA 2026-06-09 18:24:12
#>  31:   failed   7.777778  5.0000000         NA 2026-06-09 18:24:12
#>  32:   failed   7.777778  3.8888889         NA 2026-06-09 18:24:12
#>  33:   failed   7.777778  2.7777778         NA 2026-06-09 18:24:12
#>  34:   failed   7.777778  1.6666667         NA 2026-06-09 18:24:12
#>  35:   failed   7.777778  0.5555556         NA 2026-06-09 18:24:12
#>  36:   failed   7.777778 -0.5555556         NA 2026-06-09 18:24:12
#>  37:   failed   7.777778 -1.6666667         NA 2026-06-09 18:24:12
#>  38:   failed   7.777778 -2.7777778         NA 2026-06-09 18:24:12
#>  39:   failed   7.777778 -3.8888889         NA 2026-06-09 18:24:12
#>  40:   failed   7.777778 -5.0000000         NA 2026-06-09 18:24:12
#>  41:   failed   5.555556  5.0000000         NA 2026-06-09 18:24:12
#>  42:   failed   5.555556  3.8888889         NA 2026-06-09 18:24:12
#>  43:   failed   5.555556  2.7777778         NA 2026-06-09 18:24:12
#>  44:   failed   5.555556  1.6666667         NA 2026-06-09 18:24:12
#>  45:   failed   5.555556  0.5555556         NA 2026-06-09 18:24:12
#>  46:   failed   5.555556 -0.5555556         NA 2026-06-09 18:24:12
#>  47:   failed   5.555556 -1.6666667         NA 2026-06-09 18:24:12
#>  48:   failed   5.555556 -2.7777778         NA 2026-06-09 18:24:12
#>  49:   failed   5.555556 -3.8888889         NA 2026-06-09 18:24:12
#>  50:   failed   5.555556 -5.0000000         NA 2026-06-09 18:24:12
#>  51:   failed   3.333333  5.0000000         NA 2026-06-09 18:24:12
#>  52:   failed   3.333333  3.8888889         NA 2026-06-09 18:24:12
#>  53:   failed   3.333333  2.7777778         NA 2026-06-09 18:24:12
#>  54:   failed   3.333333  1.6666667         NA 2026-06-09 18:24:12
#>  55:   failed   3.333333  0.5555556         NA 2026-06-09 18:24:12
#>  56:   failed   3.333333 -0.5555556         NA 2026-06-09 18:24:12
#>  57:   failed   3.333333 -1.6666667         NA 2026-06-09 18:24:12
#>  58:   failed   3.333333 -2.7777778         NA 2026-06-09 18:24:12
#>  59:   failed   3.333333 -3.8888889         NA 2026-06-09 18:24:12
#>  60:   failed   3.333333 -5.0000000         NA 2026-06-09 18:24:12
#>  61:   failed   1.111111  5.0000000         NA 2026-06-09 18:24:12
#>  62:   failed   1.111111  3.8888889         NA 2026-06-09 18:24:12
#>  63:   failed   1.111111  2.7777778         NA 2026-06-09 18:24:12
#>  64:   failed   1.111111  1.6666667         NA 2026-06-09 18:24:12
#>  65:   failed   1.111111  0.5555556         NA 2026-06-09 18:24:12
#>  66:   failed   1.111111 -0.5555556         NA 2026-06-09 18:24:12
#>  67:   failed   1.111111 -1.6666667         NA 2026-06-09 18:24:12
#>  68:   failed   1.111111 -2.7777778         NA 2026-06-09 18:24:12
#>  69:   failed   1.111111 -3.8888889         NA 2026-06-09 18:24:12
#>  70:   failed   1.111111 -5.0000000         NA 2026-06-09 18:24:12
#>  71:   failed  -1.111111  5.0000000         NA 2026-06-09 18:24:12
#>  72:   failed  -1.111111  3.8888889         NA 2026-06-09 18:24:12
#>  73:   failed  -1.111111  2.7777778         NA 2026-06-09 18:24:12
#>  74:   failed  -1.111111  1.6666667         NA 2026-06-09 18:24:12
#>  75:   failed  -1.111111  0.5555556         NA 2026-06-09 18:24:12
#>  76:   failed  -1.111111 -0.5555556         NA 2026-06-09 18:24:12
#>  77:   failed  -1.111111 -1.6666667         NA 2026-06-09 18:24:12
#>  78:   failed  -1.111111 -2.7777778         NA 2026-06-09 18:24:12
#>  79:   failed  -1.111111 -3.8888889         NA 2026-06-09 18:24:12
#>  80:   failed  -1.111111 -5.0000000         NA 2026-06-09 18:24:12
#>  81:   failed  -3.333333  5.0000000         NA 2026-06-09 18:24:12
#>  82:   failed  -3.333333  3.8888889         NA 2026-06-09 18:24:12
#>  83:   failed  -3.333333  2.7777778         NA 2026-06-09 18:24:12
#>  84:   failed  -3.333333  1.6666667         NA 2026-06-09 18:24:12
#>  85:   failed  -3.333333  0.5555556         NA 2026-06-09 18:24:12
#>  86:   failed  -3.333333 -0.5555556         NA 2026-06-09 18:24:12
#>  87:   failed  -3.333333 -1.6666667         NA 2026-06-09 18:24:12
#>  88:   failed  -3.333333 -2.7777778         NA 2026-06-09 18:24:12
#>  89:   failed  -3.333333 -3.8888889         NA 2026-06-09 18:24:12
#>  90:   failed  -3.333333 -5.0000000         NA 2026-06-09 18:24:12
#>  91:   failed  -5.555556  5.0000000         NA 2026-06-09 18:24:12
#>  92:   failed  -5.555556  3.8888889         NA 2026-06-09 18:24:12
#>  93:   failed  -5.555556  2.7777778         NA 2026-06-09 18:24:12
#>  94:   failed  -5.555556  1.6666667         NA 2026-06-09 18:24:12
#>  95:   failed  -5.555556  0.5555556         NA 2026-06-09 18:24:12
#>  96:   failed  -5.555556 -0.5555556         NA 2026-06-09 18:24:12
#>  97:   failed  -5.555556 -1.6666667         NA 2026-06-09 18:24:12
#>  98:   failed  -5.555556 -2.7777778         NA 2026-06-09 18:24:12
#>  99:   failed  -5.555556 -3.8888889         NA 2026-06-09 18:24:12
#> 100:   failed  -5.555556 -5.0000000         NA 2026-06-09 18:24:12
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-06-09 18:24:13 37f71e00-cc17-4549-911f-5c99e9c1c886
#>   2: sinking_raccoon 2026-06-09 18:24:13 25a938fe-bf26-4bf5-ab5f-edeed1d85615
#>   3: sinking_raccoon 2026-06-09 18:24:13 6e002b18-3eba-4661-adc0-3f37363f4b7b
#>   4: sinking_raccoon 2026-06-09 18:24:13 dbeab90b-e0b9-4add-9c6c-17bc31e0ef12
#>   5: sinking_raccoon 2026-06-09 18:24:13 1e534e05-8357-405f-919c-30b937422883
#>   6: sinking_raccoon 2026-06-09 18:24:13 22eeb32e-96c2-4e91-b7ed-57d7ae84bfab
#>   7: sinking_raccoon 2026-06-09 18:24:13 92693d08-37a4-4681-ab2d-6a3d9ebc8366
#>   8: sinking_raccoon 2026-06-09 18:24:13 008f2a7a-2f8f-45c8-a9d7-2b235d31b026
#>   9: sinking_raccoon 2026-06-09 18:24:13 877881fa-7119-4414-b210-0b1d4512dde1
#>  10: sinking_raccoon 2026-06-09 18:24:13 4011e434-717e-4cd6-9387-6da09e6f8426
#>  11: sinking_raccoon 2026-06-09 18:24:13 ea647c86-bd18-4099-8a10-49905d1c1d82
#>  12: sinking_raccoon 2026-06-09 18:24:13 57d5fffd-3039-48d0-985c-3c348606b45e
#>  13: sinking_raccoon 2026-06-09 18:24:13 ebab457c-be23-4709-ba70-088991c29bcb
#>  14: sinking_raccoon 2026-06-09 18:24:13 661fabd3-108a-42fc-bcf3-a8291414a406
#>  15: sinking_raccoon 2026-06-09 18:24:13 54d98f2c-925b-4552-81ab-157f04763faa
#>  16: sinking_raccoon 2026-06-09 18:24:13 63764172-6c1d-4159-9ff1-82a43736f00a
#>  17: sinking_raccoon 2026-06-09 18:24:13 40b738c9-3135-4375-a52c-03398b7f88d4
#>  18: sinking_raccoon 2026-06-09 18:24:13 15325b48-2011-4328-a5bf-6d859d3c4262
#>  19: sinking_raccoon 2026-06-09 18:24:13 0819bdef-f3b5-48b7-b09f-822ef0c57a71
#>  20: sinking_raccoon 2026-06-09 18:24:13 ab09e877-6ac6-4855-a162-481b6679eda6
#>  21:            <NA>                <NA> c7912a45-b5d3-40e2-a72a-63b9bb940e5c
#>  22:            <NA>                <NA> 8bda8526-f120-4b2d-b165-b508cb5b8f1d
#>  23:            <NA>                <NA> 3aba8f5d-b2eb-448b-bc7f-9f81aa6bf7f6
#>  24:            <NA>                <NA> 47234c82-a42e-4920-bd2f-6fe02b2ed19e
#>  25:            <NA>                <NA> 5b5c2f77-1582-4dde-9cb7-f4d663dc2dc5
#>  26:            <NA>                <NA> d263a49a-a33f-46b2-bc38-67051bbe7d74
#>  27:            <NA>                <NA> 1d580b86-74bd-4ba7-84b9-6308c95bf960
#>  28:            <NA>                <NA> 9cd333fa-c6f7-49c2-b0f4-6d1a6c1916c1
#>  29:            <NA>                <NA> efa0f9db-a3f7-4387-a87e-3ee4378d5ff1
#>  30:            <NA>                <NA> 8f811fdb-d7ee-4408-9629-595a1ab3fd79
#>  31:            <NA>                <NA> 116af59d-e2e3-441a-8db3-5d227f9df254
#>  32:            <NA>                <NA> 46cbf9a5-c118-4262-bc35-18e8526bc018
#>  33:            <NA>                <NA> dfc86976-1591-4cd9-8a9b-ead176fa6418
#>  34:            <NA>                <NA> 739b9a3b-6954-4c70-8d1d-61e00c9dcab1
#>  35:            <NA>                <NA> 0796f08e-78f8-486d-b84d-0072a859b3c6
#>  36:            <NA>                <NA> 66d86bda-daaf-46b1-8651-af4fe6feb63e
#>  37:            <NA>                <NA> e9f2f934-46fe-4aa7-9b17-52e807bf23f8
#>  38:            <NA>                <NA> fd521ca6-f1d5-4125-ab87-4309e7a792c6
#>  39:            <NA>                <NA> f7fe87bd-8206-4af4-9da7-3b68a7acfe11
#>  40:            <NA>                <NA> 8012bf28-175f-4b13-9b15-d9724b3fdf30
#>  41:            <NA>                <NA> 28a74305-9d37-4b5a-975d-305e5a9b1a47
#>  42:            <NA>                <NA> 382dd3da-ee48-408b-80db-23d6979f4bed
#>  43:            <NA>                <NA> b8bf1768-e820-4265-b98f-9ada926d01d9
#>  44:            <NA>                <NA> 1bddc0f4-3704-408f-9b7a-529ad105ccbd
#>  45:            <NA>                <NA> 63cfde96-3059-401d-98b1-17dd4d115a22
#>  46:            <NA>                <NA> e5c763a5-0513-4aaa-8d57-9b3da268ae99
#>  47:            <NA>                <NA> f5656483-cf80-4733-a4fe-efc847563e2b
#>  48:            <NA>                <NA> a835b245-dae1-49e8-bf51-4a0f90c6b4e9
#>  49:            <NA>                <NA> af1bf67e-a62a-4f4d-8f2f-d81e6ba0db46
#>  50:            <NA>                <NA> ce261147-b0d8-45f7-84c4-eb36b47ab230
#>  51:            <NA>                <NA> 6c2ec7e0-02b4-45a9-8ad5-b7b4c26c4aaf
#>  52:            <NA>                <NA> c0891ea3-946c-49bd-bbae-0176c19af3ad
#>  53:            <NA>                <NA> 6022b474-c287-4e77-be09-730302f3b2f5
#>  54:            <NA>                <NA> a8c147b5-47cb-4c39-9f5e-9b45a3e41e3d
#>  55:            <NA>                <NA> a22823e7-9715-47fc-929e-6c7f6e810566
#>  56:            <NA>                <NA> a2794411-ce07-4c09-aa21-380e060e34cf
#>  57:            <NA>                <NA> def485f6-0833-49cf-ba3a-476153dd3584
#>  58:            <NA>                <NA> 29f4360c-272c-4edc-a9d4-901f2d71e90f
#>  59:            <NA>                <NA> b2992abc-2a5d-45c5-a472-a4ac8193c74d
#>  60:            <NA>                <NA> 12e94333-b070-4d7e-920a-1917c0aa4ac7
#>  61:            <NA>                <NA> ab3a5902-290f-425a-ba14-56eea3ea0e98
#>  62:            <NA>                <NA> 1569d0f1-ca6a-4a53-925e-89d53deb7410
#>  63:            <NA>                <NA> 4b4cad55-b261-46c5-a4e3-ede580d98f99
#>  64:            <NA>                <NA> 69a543f3-4620-4fc1-be3c-74104d11ebe0
#>  65:            <NA>                <NA> 18a5131b-a441-498e-9bab-5b87e0f50da3
#>  66:            <NA>                <NA> 91c3aeaf-6bd7-4fd2-b703-473257f11135
#>  67:            <NA>                <NA> e7d89230-ac5f-4ab9-8a63-1581dcc9a647
#>  68:            <NA>                <NA> bae61824-e4c6-428b-9968-4023088e1b5f
#>  69:            <NA>                <NA> 5ddd18b3-41c4-4f0a-85ce-4f5529f9659a
#>  70:            <NA>                <NA> ae1a3d76-0f9a-4195-ba9a-7bb782d6dbd4
#>  71:            <NA>                <NA> 4cd3eab5-eb39-435b-9d4a-655cf28a8541
#>  72:            <NA>                <NA> b410e75b-ee52-470b-91f4-86cf990e97cb
#>  73:            <NA>                <NA> 1143687f-39fe-4309-aa9d-e5340bdbf5c6
#>  74:            <NA>                <NA> fcc47da8-6dc7-4a17-b86e-248fc440825a
#>  75:            <NA>                <NA> add296f5-148c-4316-9579-417dd8b53fc2
#>  76:            <NA>                <NA> 4419dcfe-6adf-4129-bc63-1d2d6d9ff6a0
#>  77:            <NA>                <NA> f61c71e9-6508-47c5-9ca8-a55c125cf545
#>  78:            <NA>                <NA> 2a58b386-d97a-4a6f-bed6-676dd22d086c
#>  79:            <NA>                <NA> 8c7f3718-e91d-4754-a220-f77f87fac463
#>  80:            <NA>                <NA> 53c9845a-5a91-4054-b7ae-c38e90e68615
#>  81:            <NA>                <NA> 84267e95-f717-4bfe-82ce-ac7bc0b7ab3d
#>  82:            <NA>                <NA> 60d66b61-a745-443c-a48d-5d5d02b8818a
#>  83:            <NA>                <NA> c0aca114-ace4-43b8-9576-73cabc735e94
#>  84:            <NA>                <NA> a410a53d-7f27-4ec0-a857-8c08e6d7cfee
#>  85:            <NA>                <NA> 52cbeb97-aadf-45e4-9e93-64457a86a4dd
#>  86:            <NA>                <NA> 57ed3bd3-c393-40e1-b824-28f935f9f6ee
#>  87:            <NA>                <NA> f31b3186-3f1f-494e-835d-d7405a771136
#>  88:            <NA>                <NA> 6be78f2d-051c-49a8-81aa-2819e53cd29b
#>  89:            <NA>                <NA> f3d4fa71-800a-4960-8eb3-a461dbcf7bb7
#>  90:            <NA>                <NA> 3bae49f7-ef71-462f-a510-6ea22939fd59
#>  91:            <NA>                <NA> 503c8657-21d3-49de-bf8a-1ec2e6bbe2c6
#>  92:            <NA>                <NA> 47784e45-13da-4044-910d-a4290bbabc81
#>  93:            <NA>                <NA> 951485bf-0360-42de-af2f-fcabc78f7c87
#>  94:            <NA>                <NA> 994a5590-c122-48e1-a61e-4ccd24099317
#>  95:            <NA>                <NA> 2ee769d5-ff67-470a-a623-dcb26d8586d6
#>  96:            <NA>                <NA> 7d021463-b7a8-462b-ab49-76eac88bf340
#>  97:            <NA>                <NA> b1e020a8-7d00-4b0e-a8bb-805bdda50cb7
#>  98:            <NA>                <NA> d578188d-d076-4e00-9373-5a1f0169c586
#>  99:            <NA>                <NA> 99769d4c-0aea-45de-a15e-6bb89c5a08a6
#> 100:            <NA>                <NA> 7bbe376e-4b86-4090-84d4-b4fa6e58e8b2
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
