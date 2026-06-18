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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-06-18 08:16:01
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-06-18 08:16:01
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-06-18 08:16:01
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-06-18 08:16:01
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-06-18 08:16:01
#>   6: finished -10.000000  0.5555556 -146.64198 2026-06-18 08:16:01
#>   7: finished -10.000000  1.6666667 -155.77778 2026-06-18 08:16:01
#>   8: finished -10.000000  2.7777778 -167.38272 2026-06-18 08:16:01
#>   9: finished -10.000000  3.8888889 -181.45679 2026-06-18 08:16:01
#>  10: finished -10.000000  5.0000000 -198.00000 2026-06-18 08:16:01
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-06-18 08:16:01
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-06-18 08:16:01
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-06-18 08:16:01
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-06-18 08:16:01
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-06-18 08:16:01
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-06-18 08:16:01
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-06-18 08:16:01
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-06-18 08:16:01
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-06-18 08:16:01
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-06-18 08:16:01
#>  21:   failed  10.000000  5.0000000         NA 2026-06-18 08:16:01
#>  22:   failed  10.000000  3.8888889         NA 2026-06-18 08:16:01
#>  23:   failed  10.000000  2.7777778         NA 2026-06-18 08:16:01
#>  24:   failed  10.000000  1.6666667         NA 2026-06-18 08:16:01
#>  25:   failed  10.000000  0.5555556         NA 2026-06-18 08:16:01
#>  26:   failed  10.000000 -0.5555556         NA 2026-06-18 08:16:01
#>  27:   failed  10.000000 -1.6666667         NA 2026-06-18 08:16:01
#>  28:   failed  10.000000 -2.7777778         NA 2026-06-18 08:16:01
#>  29:   failed  10.000000 -3.8888889         NA 2026-06-18 08:16:01
#>  30:   failed  10.000000 -5.0000000         NA 2026-06-18 08:16:01
#>  31:   failed   7.777778  5.0000000         NA 2026-06-18 08:16:01
#>  32:   failed   7.777778  3.8888889         NA 2026-06-18 08:16:01
#>  33:   failed   7.777778  2.7777778         NA 2026-06-18 08:16:01
#>  34:   failed   7.777778  1.6666667         NA 2026-06-18 08:16:01
#>  35:   failed   7.777778  0.5555556         NA 2026-06-18 08:16:01
#>  36:   failed   7.777778 -0.5555556         NA 2026-06-18 08:16:01
#>  37:   failed   7.777778 -1.6666667         NA 2026-06-18 08:16:01
#>  38:   failed   7.777778 -2.7777778         NA 2026-06-18 08:16:01
#>  39:   failed   7.777778 -3.8888889         NA 2026-06-18 08:16:01
#>  40:   failed   7.777778 -5.0000000         NA 2026-06-18 08:16:01
#>  41:   failed   5.555556  5.0000000         NA 2026-06-18 08:16:01
#>  42:   failed   5.555556  3.8888889         NA 2026-06-18 08:16:01
#>  43:   failed   5.555556  2.7777778         NA 2026-06-18 08:16:01
#>  44:   failed   5.555556  1.6666667         NA 2026-06-18 08:16:01
#>  45:   failed   5.555556  0.5555556         NA 2026-06-18 08:16:01
#>  46:   failed   5.555556 -0.5555556         NA 2026-06-18 08:16:01
#>  47:   failed   5.555556 -1.6666667         NA 2026-06-18 08:16:01
#>  48:   failed   5.555556 -2.7777778         NA 2026-06-18 08:16:01
#>  49:   failed   5.555556 -3.8888889         NA 2026-06-18 08:16:01
#>  50:   failed   5.555556 -5.0000000         NA 2026-06-18 08:16:01
#>  51:   failed   3.333333  5.0000000         NA 2026-06-18 08:16:01
#>  52:   failed   3.333333  3.8888889         NA 2026-06-18 08:16:01
#>  53:   failed   3.333333  2.7777778         NA 2026-06-18 08:16:01
#>  54:   failed   3.333333  1.6666667         NA 2026-06-18 08:16:01
#>  55:   failed   3.333333  0.5555556         NA 2026-06-18 08:16:01
#>  56:   failed   3.333333 -0.5555556         NA 2026-06-18 08:16:01
#>  57:   failed   3.333333 -1.6666667         NA 2026-06-18 08:16:01
#>  58:   failed   3.333333 -2.7777778         NA 2026-06-18 08:16:01
#>  59:   failed   3.333333 -3.8888889         NA 2026-06-18 08:16:01
#>  60:   failed   3.333333 -5.0000000         NA 2026-06-18 08:16:01
#>  61:   failed   1.111111  5.0000000         NA 2026-06-18 08:16:01
#>  62:   failed   1.111111  3.8888889         NA 2026-06-18 08:16:01
#>  63:   failed   1.111111  2.7777778         NA 2026-06-18 08:16:01
#>  64:   failed   1.111111  1.6666667         NA 2026-06-18 08:16:01
#>  65:   failed   1.111111  0.5555556         NA 2026-06-18 08:16:01
#>  66:   failed   1.111111 -0.5555556         NA 2026-06-18 08:16:01
#>  67:   failed   1.111111 -1.6666667         NA 2026-06-18 08:16:01
#>  68:   failed   1.111111 -2.7777778         NA 2026-06-18 08:16:01
#>  69:   failed   1.111111 -3.8888889         NA 2026-06-18 08:16:01
#>  70:   failed   1.111111 -5.0000000         NA 2026-06-18 08:16:01
#>  71:   failed  -1.111111  5.0000000         NA 2026-06-18 08:16:01
#>  72:   failed  -1.111111  3.8888889         NA 2026-06-18 08:16:01
#>  73:   failed  -1.111111  2.7777778         NA 2026-06-18 08:16:01
#>  74:   failed  -1.111111  1.6666667         NA 2026-06-18 08:16:01
#>  75:   failed  -1.111111  0.5555556         NA 2026-06-18 08:16:01
#>  76:   failed  -1.111111 -0.5555556         NA 2026-06-18 08:16:01
#>  77:   failed  -1.111111 -1.6666667         NA 2026-06-18 08:16:01
#>  78:   failed  -1.111111 -2.7777778         NA 2026-06-18 08:16:01
#>  79:   failed  -1.111111 -3.8888889         NA 2026-06-18 08:16:01
#>  80:   failed  -1.111111 -5.0000000         NA 2026-06-18 08:16:01
#>  81:   failed  -3.333333  5.0000000         NA 2026-06-18 08:16:01
#>  82:   failed  -3.333333  3.8888889         NA 2026-06-18 08:16:01
#>  83:   failed  -3.333333  2.7777778         NA 2026-06-18 08:16:01
#>  84:   failed  -3.333333  1.6666667         NA 2026-06-18 08:16:01
#>  85:   failed  -3.333333  0.5555556         NA 2026-06-18 08:16:01
#>  86:   failed  -3.333333 -0.5555556         NA 2026-06-18 08:16:01
#>  87:   failed  -3.333333 -1.6666667         NA 2026-06-18 08:16:01
#>  88:   failed  -3.333333 -2.7777778         NA 2026-06-18 08:16:01
#>  89:   failed  -3.333333 -3.8888889         NA 2026-06-18 08:16:01
#>  90:   failed  -3.333333 -5.0000000         NA 2026-06-18 08:16:01
#>  91:   failed  -5.555556  5.0000000         NA 2026-06-18 08:16:01
#>  92:   failed  -5.555556  3.8888889         NA 2026-06-18 08:16:01
#>  93:   failed  -5.555556  2.7777778         NA 2026-06-18 08:16:01
#>  94:   failed  -5.555556  1.6666667         NA 2026-06-18 08:16:01
#>  95:   failed  -5.555556  0.5555556         NA 2026-06-18 08:16:01
#>  96:   failed  -5.555556 -0.5555556         NA 2026-06-18 08:16:01
#>  97:   failed  -5.555556 -1.6666667         NA 2026-06-18 08:16:01
#>  98:   failed  -5.555556 -2.7777778         NA 2026-06-18 08:16:01
#>  99:   failed  -5.555556 -3.8888889         NA 2026-06-18 08:16:01
#> 100:   failed  -5.555556 -5.0000000         NA 2026-06-18 08:16:01
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-06-18 08:16:02 4764a46b-1b62-45d8-96de-f2a2da6218c6
#>   2: sinking_raccoon 2026-06-18 08:16:02 dcc06d49-285e-450f-800d-45824c0476fd
#>   3: sinking_raccoon 2026-06-18 08:16:02 22f7995a-fff1-45dc-bf8b-53ff72a069cd
#>   4: sinking_raccoon 2026-06-18 08:16:02 5005c79e-a8a5-42d4-a01e-c82c21ca37a4
#>   5: sinking_raccoon 2026-06-18 08:16:02 ae1ef11f-45b7-4217-9d1c-07c8b6111766
#>   6: sinking_raccoon 2026-06-18 08:16:02 75757241-cf39-4ad2-b609-ac89198b3a5d
#>   7: sinking_raccoon 2026-06-18 08:16:02 5be18244-95a5-49eb-a64b-2cd2e9e2e621
#>   8: sinking_raccoon 2026-06-18 08:16:02 9f4fc809-e9d0-4f5f-8387-bc09cf70aecd
#>   9: sinking_raccoon 2026-06-18 08:16:02 f8a22f3e-add0-47a5-b255-e72d9ddf333f
#>  10: sinking_raccoon 2026-06-18 08:16:02 bc57dfba-7723-4a5a-9deb-4d492cbfdb99
#>  11: sinking_raccoon 2026-06-18 08:16:02 b4717817-25e2-4a7d-b063-840fe42e4597
#>  12: sinking_raccoon 2026-06-18 08:16:02 34a754bc-2550-418a-a2ad-ab7e3f607ce8
#>  13: sinking_raccoon 2026-06-18 08:16:02 603b45a8-adc1-4f59-8aa6-a1ed1f5f3fdd
#>  14: sinking_raccoon 2026-06-18 08:16:02 cb6c18fb-2138-4f50-90db-8e48a7efc7c3
#>  15: sinking_raccoon 2026-06-18 08:16:02 d45dedba-5022-4987-8267-ae66f25b04ee
#>  16: sinking_raccoon 2026-06-18 08:16:02 8a05e619-10c7-47f9-9d85-54cabcb73150
#>  17: sinking_raccoon 2026-06-18 08:16:02 f4d41d64-60a4-431c-9321-e33c81eb198b
#>  18: sinking_raccoon 2026-06-18 08:16:02 fafbbad3-41ca-47a0-9d80-fb58d2a20862
#>  19: sinking_raccoon 2026-06-18 08:16:02 fd6314d4-28c2-44ad-b55e-d72ba4dccc4d
#>  20: sinking_raccoon 2026-06-18 08:16:02 e2baa37f-40fd-4916-9769-5ad1b9c0145a
#>  21:            <NA>                <NA> 0c61a5da-1a1a-4772-af6d-21abd4813a46
#>  22:            <NA>                <NA> fdbbdc75-ceb0-4179-a405-d5a73635ec30
#>  23:            <NA>                <NA> e749e88b-a47c-4c8c-8687-51b2fcc03847
#>  24:            <NA>                <NA> 1bdd6ac8-8c9f-4b54-aef1-f493e4c19c64
#>  25:            <NA>                <NA> 58eaa5fc-2508-4e1e-b2b4-7f15cceee089
#>  26:            <NA>                <NA> 333446b2-6b58-4bc8-a5c7-27ebfea86053
#>  27:            <NA>                <NA> 8a5e4c5e-42c9-40a1-8f9e-d7a9c427c618
#>  28:            <NA>                <NA> 37974b58-17e0-4367-a942-dfc8f99528ee
#>  29:            <NA>                <NA> 291f3787-cb1c-45b0-8133-9833b6a87ca0
#>  30:            <NA>                <NA> 3a3c563d-185b-4886-adf7-6a3034f33cca
#>  31:            <NA>                <NA> d80dc3a4-a848-4058-a2b1-c9f03bb7f13f
#>  32:            <NA>                <NA> afae10f0-ccb6-48b1-920e-89c8e44c2c58
#>  33:            <NA>                <NA> 2de0e9ba-55c4-43c4-b8d0-f412deb74ed2
#>  34:            <NA>                <NA> 6e07d027-08ec-4ee8-a067-798306961877
#>  35:            <NA>                <NA> 7afe54bd-4318-49e4-8ce9-d464182faaf6
#>  36:            <NA>                <NA> f85c51de-fedf-4b9a-9105-00eeb9391be5
#>  37:            <NA>                <NA> 2e685214-b1bc-4476-9342-fc2f1edb60ea
#>  38:            <NA>                <NA> 66cfaad4-d528-48de-89ef-2d64fca27d7d
#>  39:            <NA>                <NA> 20bd04e5-b2fb-4732-b754-e53d581a474e
#>  40:            <NA>                <NA> d43996f0-a57e-4597-af4a-52591f9c6a98
#>  41:            <NA>                <NA> 73f4058a-5a72-405e-8aae-d892ad63cfdd
#>  42:            <NA>                <NA> 4c1f0e5e-bea2-46df-aee7-350aa713b790
#>  43:            <NA>                <NA> d792c0fc-ad17-4c87-986d-6be3622154d2
#>  44:            <NA>                <NA> e3718ba1-4cb7-4a1d-ac77-bab31060d70b
#>  45:            <NA>                <NA> c02d6024-f39e-403c-a64b-364d69d9d40d
#>  46:            <NA>                <NA> 1d1f1f6a-9feb-41bb-9590-48326e7b42fa
#>  47:            <NA>                <NA> 3abb6386-c2a2-4a8e-8430-7862ed390bdd
#>  48:            <NA>                <NA> 8d4723a2-f893-43cb-be0f-eff4797411c2
#>  49:            <NA>                <NA> 27e83aac-8a0b-4473-9924-378e1dc3aa9f
#>  50:            <NA>                <NA> bd78be88-2119-408c-a841-bb282526d9c8
#>  51:            <NA>                <NA> bb1ab3c1-e6d2-4c3c-8d8f-35f4411d01fd
#>  52:            <NA>                <NA> aa3b4f14-e4db-4f4f-a54c-a81b20213367
#>  53:            <NA>                <NA> 90bb53d4-2a9b-417c-86dc-ee7129041d39
#>  54:            <NA>                <NA> 34fd8918-a421-4200-9aa8-363d98bd5d3f
#>  55:            <NA>                <NA> 3e92982c-6c63-4106-9d08-0e58ac89d8e6
#>  56:            <NA>                <NA> fe138c89-da62-4e61-b8a3-e160a19e7280
#>  57:            <NA>                <NA> cac48335-acb0-4c9f-a6d6-af39beb6e0a8
#>  58:            <NA>                <NA> 31896fc0-9540-4980-84b6-6b6c9d5b575c
#>  59:            <NA>                <NA> 928cd85c-c380-443f-8a73-499d2a1a90bb
#>  60:            <NA>                <NA> 7e7c6e4e-caf3-40c0-bb9a-64c4c1931434
#>  61:            <NA>                <NA> 7a4d3937-0680-45fd-872e-a3502a368a15
#>  62:            <NA>                <NA> bcbd9379-7448-4e12-81ea-c19ac954d70c
#>  63:            <NA>                <NA> da9202a6-f28b-462b-8165-ccc8c0eee5e2
#>  64:            <NA>                <NA> 8ce38482-96f1-4ed8-8400-017a156dab19
#>  65:            <NA>                <NA> 1a732198-3149-41c2-954f-acc425c226f8
#>  66:            <NA>                <NA> 3fed2d71-42c3-4425-824c-700b807d948a
#>  67:            <NA>                <NA> 25873bd9-b67f-4843-85cf-11b17dd10715
#>  68:            <NA>                <NA> a88b01a7-ac12-4bef-89a2-78cfc8483715
#>  69:            <NA>                <NA> 8b7b3bd8-89c7-49f3-9ada-2b9242ac81fc
#>  70:            <NA>                <NA> e5bf2bc4-6fee-4dd0-9e7c-c9ed6977f2e3
#>  71:            <NA>                <NA> 02b7dd0d-ca4a-4e92-8f58-7aa3d776dfc4
#>  72:            <NA>                <NA> 1f6ee38b-13f0-4553-a5c3-8c3ff808e1a5
#>  73:            <NA>                <NA> 8bc00dda-f671-4d29-8a3b-27256dd25b1e
#>  74:            <NA>                <NA> 13d38873-a46b-408e-b77b-6d7242b11859
#>  75:            <NA>                <NA> 0345babc-eb3e-4134-bccb-f0f792a03869
#>  76:            <NA>                <NA> 39960452-a908-4085-b0e8-5d7624f5c5cb
#>  77:            <NA>                <NA> 193ee9c9-9e3b-4db7-a986-3269ca0ecdf3
#>  78:            <NA>                <NA> f426ac12-91e1-4c02-9cda-1d0b9cf0e168
#>  79:            <NA>                <NA> ec63afb5-c1e1-4471-af58-e6a99d907510
#>  80:            <NA>                <NA> 8ce13b38-4d77-4b64-9505-a300e2a0ceaf
#>  81:            <NA>                <NA> 19b4eb62-c067-4139-8125-4a23ec3fdc82
#>  82:            <NA>                <NA> 4920ea65-e4b1-40c8-97e7-0f775f8247f1
#>  83:            <NA>                <NA> e364ed94-52f7-4faa-9c6a-1e8f602248d4
#>  84:            <NA>                <NA> 08e0ce95-3dee-4a04-bc6c-d7c7221ea6db
#>  85:            <NA>                <NA> 91a1d2c4-ad89-422d-b065-eb88c6e8100a
#>  86:            <NA>                <NA> 53107b86-3f94-43ee-ba9a-2857edbc8ad4
#>  87:            <NA>                <NA> 8377204a-7736-4856-b776-0716dbd50737
#>  88:            <NA>                <NA> f973e6fb-726f-48f1-b76a-c12c0019b461
#>  89:            <NA>                <NA> d13b2c0f-7a54-41cd-b586-d606270e6ceb
#>  90:            <NA>                <NA> 11e6936d-0863-4e64-b0cc-5a5d1b8669d7
#>  91:            <NA>                <NA> 44383be2-83ac-4b56-9d81-fd32bfc3d563
#>  92:            <NA>                <NA> 31d761b6-6cbf-4e6c-8b03-80a6c44d1234
#>  93:            <NA>                <NA> b6713a9d-f8a5-4ee4-9e9c-9db2e86474d4
#>  94:            <NA>                <NA> 625c1db4-74f8-4cc1-b26f-2df8bf94e8a4
#>  95:            <NA>                <NA> 4d91066b-32f4-44d5-9fdd-a141e363bee4
#>  96:            <NA>                <NA> 92239391-97b9-403e-9cdf-a09d9e65e8ca
#>  97:            <NA>                <NA> 85e2ad51-4a2c-4a51-b10c-918d5a8b8c42
#>  98:            <NA>                <NA> f403dd6d-4373-4080-ba6a-7feb1b5fa9b3
#>  99:            <NA>                <NA> 151d4d22-359e-4439-bff0-e041fce114b9
#> 100:            <NA>                <NA> 569917e9-0898-46a1-94f0-51061dcabec4
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
