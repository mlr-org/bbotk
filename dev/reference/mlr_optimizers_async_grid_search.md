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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-04-07 07:08:01
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-04-07 07:08:01
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-04-07 07:08:01
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-04-07 07:08:01
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-04-07 07:08:01
#>   6: finished -10.000000  0.5555556 -146.64198 2026-04-07 07:08:01
#>   7: finished -10.000000  1.6666667 -155.77778 2026-04-07 07:08:01
#>   8: finished -10.000000  2.7777778 -167.38272 2026-04-07 07:08:01
#>   9: finished -10.000000  3.8888889 -181.45679 2026-04-07 07:08:01
#>  10: finished -10.000000  5.0000000 -198.00000 2026-04-07 07:08:01
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-04-07 07:08:01
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-04-07 07:08:01
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-04-07 07:08:01
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-04-07 07:08:01
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-04-07 07:08:01
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-04-07 07:08:01
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-04-07 07:08:01
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-04-07 07:08:01
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-04-07 07:08:01
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-04-07 07:08:01
#>  21:   failed  10.000000  5.0000000         NA 2026-04-07 07:08:01
#>  22:   failed  10.000000  3.8888889         NA 2026-04-07 07:08:01
#>  23:   failed  10.000000  2.7777778         NA 2026-04-07 07:08:01
#>  24:   failed  10.000000  1.6666667         NA 2026-04-07 07:08:01
#>  25:   failed  10.000000  0.5555556         NA 2026-04-07 07:08:01
#>  26:   failed  10.000000 -0.5555556         NA 2026-04-07 07:08:01
#>  27:   failed  10.000000 -1.6666667         NA 2026-04-07 07:08:01
#>  28:   failed  10.000000 -2.7777778         NA 2026-04-07 07:08:01
#>  29:   failed  10.000000 -3.8888889         NA 2026-04-07 07:08:01
#>  30:   failed  10.000000 -5.0000000         NA 2026-04-07 07:08:01
#>  31:   failed   7.777778  5.0000000         NA 2026-04-07 07:08:01
#>  32:   failed   7.777778  3.8888889         NA 2026-04-07 07:08:01
#>  33:   failed   7.777778  2.7777778         NA 2026-04-07 07:08:01
#>  34:   failed   7.777778  1.6666667         NA 2026-04-07 07:08:01
#>  35:   failed   7.777778  0.5555556         NA 2026-04-07 07:08:01
#>  36:   failed   7.777778 -0.5555556         NA 2026-04-07 07:08:01
#>  37:   failed   7.777778 -1.6666667         NA 2026-04-07 07:08:01
#>  38:   failed   7.777778 -2.7777778         NA 2026-04-07 07:08:01
#>  39:   failed   7.777778 -3.8888889         NA 2026-04-07 07:08:01
#>  40:   failed   7.777778 -5.0000000         NA 2026-04-07 07:08:01
#>  41:   failed   5.555556  5.0000000         NA 2026-04-07 07:08:01
#>  42:   failed   5.555556  3.8888889         NA 2026-04-07 07:08:01
#>  43:   failed   5.555556  2.7777778         NA 2026-04-07 07:08:01
#>  44:   failed   5.555556  1.6666667         NA 2026-04-07 07:08:01
#>  45:   failed   5.555556  0.5555556         NA 2026-04-07 07:08:01
#>  46:   failed   5.555556 -0.5555556         NA 2026-04-07 07:08:01
#>  47:   failed   5.555556 -1.6666667         NA 2026-04-07 07:08:01
#>  48:   failed   5.555556 -2.7777778         NA 2026-04-07 07:08:01
#>  49:   failed   5.555556 -3.8888889         NA 2026-04-07 07:08:01
#>  50:   failed   5.555556 -5.0000000         NA 2026-04-07 07:08:01
#>  51:   failed   3.333333  5.0000000         NA 2026-04-07 07:08:01
#>  52:   failed   3.333333  3.8888889         NA 2026-04-07 07:08:01
#>  53:   failed   3.333333  2.7777778         NA 2026-04-07 07:08:01
#>  54:   failed   3.333333  1.6666667         NA 2026-04-07 07:08:01
#>  55:   failed   3.333333  0.5555556         NA 2026-04-07 07:08:01
#>  56:   failed   3.333333 -0.5555556         NA 2026-04-07 07:08:01
#>  57:   failed   3.333333 -1.6666667         NA 2026-04-07 07:08:01
#>  58:   failed   3.333333 -2.7777778         NA 2026-04-07 07:08:01
#>  59:   failed   3.333333 -3.8888889         NA 2026-04-07 07:08:01
#>  60:   failed   3.333333 -5.0000000         NA 2026-04-07 07:08:01
#>  61:   failed   1.111111  5.0000000         NA 2026-04-07 07:08:01
#>  62:   failed   1.111111  3.8888889         NA 2026-04-07 07:08:01
#>  63:   failed   1.111111  2.7777778         NA 2026-04-07 07:08:01
#>  64:   failed   1.111111  1.6666667         NA 2026-04-07 07:08:01
#>  65:   failed   1.111111  0.5555556         NA 2026-04-07 07:08:01
#>  66:   failed   1.111111 -0.5555556         NA 2026-04-07 07:08:01
#>  67:   failed   1.111111 -1.6666667         NA 2026-04-07 07:08:01
#>  68:   failed   1.111111 -2.7777778         NA 2026-04-07 07:08:01
#>  69:   failed   1.111111 -3.8888889         NA 2026-04-07 07:08:01
#>  70:   failed   1.111111 -5.0000000         NA 2026-04-07 07:08:01
#>  71:   failed  -1.111111  5.0000000         NA 2026-04-07 07:08:01
#>  72:   failed  -1.111111  3.8888889         NA 2026-04-07 07:08:01
#>  73:   failed  -1.111111  2.7777778         NA 2026-04-07 07:08:01
#>  74:   failed  -1.111111  1.6666667         NA 2026-04-07 07:08:01
#>  75:   failed  -1.111111  0.5555556         NA 2026-04-07 07:08:01
#>  76:   failed  -1.111111 -0.5555556         NA 2026-04-07 07:08:01
#>  77:   failed  -1.111111 -1.6666667         NA 2026-04-07 07:08:01
#>  78:   failed  -1.111111 -2.7777778         NA 2026-04-07 07:08:01
#>  79:   failed  -1.111111 -3.8888889         NA 2026-04-07 07:08:01
#>  80:   failed  -1.111111 -5.0000000         NA 2026-04-07 07:08:01
#>  81:   failed  -3.333333  5.0000000         NA 2026-04-07 07:08:01
#>  82:   failed  -3.333333  3.8888889         NA 2026-04-07 07:08:01
#>  83:   failed  -3.333333  2.7777778         NA 2026-04-07 07:08:01
#>  84:   failed  -3.333333  1.6666667         NA 2026-04-07 07:08:01
#>  85:   failed  -3.333333  0.5555556         NA 2026-04-07 07:08:01
#>  86:   failed  -3.333333 -0.5555556         NA 2026-04-07 07:08:01
#>  87:   failed  -3.333333 -1.6666667         NA 2026-04-07 07:08:01
#>  88:   failed  -3.333333 -2.7777778         NA 2026-04-07 07:08:01
#>  89:   failed  -3.333333 -3.8888889         NA 2026-04-07 07:08:01
#>  90:   failed  -3.333333 -5.0000000         NA 2026-04-07 07:08:01
#>  91:   failed  -5.555556  5.0000000         NA 2026-04-07 07:08:01
#>  92:   failed  -5.555556  3.8888889         NA 2026-04-07 07:08:01
#>  93:   failed  -5.555556  2.7777778         NA 2026-04-07 07:08:01
#>  94:   failed  -5.555556  1.6666667         NA 2026-04-07 07:08:01
#>  95:   failed  -5.555556  0.5555556         NA 2026-04-07 07:08:01
#>  96:   failed  -5.555556 -0.5555556         NA 2026-04-07 07:08:01
#>  97:   failed  -5.555556 -1.6666667         NA 2026-04-07 07:08:01
#>  98:   failed  -5.555556 -2.7777778         NA 2026-04-07 07:08:01
#>  99:   failed  -5.555556 -3.8888889         NA 2026-04-07 07:08:01
#> 100:   failed  -5.555556 -5.0000000         NA 2026-04-07 07:08:01
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-04-07 07:08:02 c037da1d-9f37-48a9-a258-c97e2582ec30
#>   2: sinking_raccoon 2026-04-07 07:08:02 81f1ed6b-3be0-475e-95ff-915face48a4b
#>   3: sinking_raccoon 2026-04-07 07:08:02 3c50d500-a4b6-47a6-b59f-fd75d48ac913
#>   4: sinking_raccoon 2026-04-07 07:08:02 f74ba0ec-86ca-4b3a-9d9d-91bc9382fd3d
#>   5: sinking_raccoon 2026-04-07 07:08:02 edd302b0-9a96-4b38-a6e1-e7890ec65979
#>   6: sinking_raccoon 2026-04-07 07:08:02 5257a830-d7bc-4723-90bb-5df8b92d806f
#>   7: sinking_raccoon 2026-04-07 07:08:02 24d124c3-264a-4509-9379-3e09e88303f7
#>   8: sinking_raccoon 2026-04-07 07:08:02 b43463a6-7ca2-41e5-a856-700f3242aa76
#>   9: sinking_raccoon 2026-04-07 07:08:02 d5a8279d-f11b-46ae-8850-5584f02326c7
#>  10: sinking_raccoon 2026-04-07 07:08:02 51ee8701-758e-4406-8e97-0a0d791d1a78
#>  11: sinking_raccoon 2026-04-07 07:08:02 06db672a-5ce9-44a1-a5e9-bcfb4dde1517
#>  12: sinking_raccoon 2026-04-07 07:08:02 30dff924-7885-4260-95e3-2152de52088b
#>  13: sinking_raccoon 2026-04-07 07:08:02 ae35591c-2a28-416d-82f8-1fb7de3dc83f
#>  14: sinking_raccoon 2026-04-07 07:08:02 a9753178-5906-40b4-9363-60e26ed4bb7f
#>  15: sinking_raccoon 2026-04-07 07:08:02 002ba52a-9cb0-45b1-9286-3e6e6249a7f5
#>  16: sinking_raccoon 2026-04-07 07:08:02 7fdce191-4f4d-48e0-8b7d-df1b80a9dfc4
#>  17: sinking_raccoon 2026-04-07 07:08:02 dad730b4-7135-4e3d-865a-bec8b2beca1d
#>  18: sinking_raccoon 2026-04-07 07:08:02 7eadd21d-7070-4a76-a9fd-f780ebe078d1
#>  19: sinking_raccoon 2026-04-07 07:08:02 490b5f34-b930-4676-bfd7-8a3335110cf3
#>  20: sinking_raccoon 2026-04-07 07:08:02 4f8245fc-55a1-4930-9c1a-3aca787f3ebf
#>  21:            <NA>                <NA> b646807d-035e-4875-8734-456e1d66909d
#>  22:            <NA>                <NA> 712505a0-3735-40e7-b555-8afca8d8df1d
#>  23:            <NA>                <NA> ed91eec1-4275-4626-8013-935d9f1df018
#>  24:            <NA>                <NA> 9594a860-f1fa-434f-b12d-28e3be9a2789
#>  25:            <NA>                <NA> d9e38f48-af0f-4b3e-b634-10910eeda632
#>  26:            <NA>                <NA> 7f861efb-f740-477c-8042-bad6229e339b
#>  27:            <NA>                <NA> 32870190-cbc4-46f1-b462-fd581cb485dd
#>  28:            <NA>                <NA> 82462f6e-902b-43c5-8275-a1df91e250ba
#>  29:            <NA>                <NA> f779976f-d22b-4589-b666-155968b4b312
#>  30:            <NA>                <NA> d7193c1d-77da-4e7c-b81c-fd5b5b56e0e2
#>  31:            <NA>                <NA> 3a8dee3a-7685-4780-8ca1-df8b1eeb7a0c
#>  32:            <NA>                <NA> a9a72ca9-80ac-4f1f-9f5b-bb02d877727d
#>  33:            <NA>                <NA> 449737f9-73ec-453c-9a57-9280b9a772b0
#>  34:            <NA>                <NA> e5f0287e-487c-4917-9ef2-ab9a66e628e8
#>  35:            <NA>                <NA> 79ec62a5-88b4-48da-be01-aaf4dd20bd96
#>  36:            <NA>                <NA> 427d2e37-647a-467a-998d-bbc600d01087
#>  37:            <NA>                <NA> 380390d2-9783-407c-b5b3-04cd4894dd1d
#>  38:            <NA>                <NA> fa0ed76f-a495-4294-83da-fb9822c56d58
#>  39:            <NA>                <NA> f5cd2d4a-564c-46b3-a374-81f6f6ac3393
#>  40:            <NA>                <NA> e3b2c2c3-dfea-49a0-9398-74ff81b777d9
#>  41:            <NA>                <NA> eaccec5f-02eb-4149-bade-ea73bf6f4087
#>  42:            <NA>                <NA> dec8ad7d-aaa3-47fa-a873-95177dff87ac
#>  43:            <NA>                <NA> 4624c5cf-df83-449d-a1f1-4306d816c6b1
#>  44:            <NA>                <NA> d6f8f802-1529-457a-9483-e80368b0f2bf
#>  45:            <NA>                <NA> 6379ddc7-f7ee-4345-b174-2197aeb9fd5a
#>  46:            <NA>                <NA> f352b06d-c08d-4544-a646-3f4f887a60bb
#>  47:            <NA>                <NA> 69776b9e-46f8-4ca2-ab1f-5a1198463442
#>  48:            <NA>                <NA> c410d9fc-195f-4c2c-9bd5-9c515ff8f1bb
#>  49:            <NA>                <NA> 590e5b48-1620-46a6-b40c-1260a9bb9edf
#>  50:            <NA>                <NA> e351c267-42a5-4f6b-92e9-7d50875d5fbf
#>  51:            <NA>                <NA> eaaa9fef-7c99-4de9-b58d-35fdbd481404
#>  52:            <NA>                <NA> 7bba2203-4a58-4f06-8661-ba9b636283fd
#>  53:            <NA>                <NA> 42bd6fd3-bbef-4beb-9165-15102ec3ca2e
#>  54:            <NA>                <NA> 512ed9e7-2de1-441f-a0c7-e4b45140f538
#>  55:            <NA>                <NA> 336b2ba7-5fd4-4908-a30c-8466a479865d
#>  56:            <NA>                <NA> a5297302-2399-48de-a6b5-1106f5375990
#>  57:            <NA>                <NA> d9968da9-8375-4c11-afc2-77410e8b3d6b
#>  58:            <NA>                <NA> 1c0b61d4-32e3-410c-afbc-43bca2b640c7
#>  59:            <NA>                <NA> 9ddef111-a47d-4852-a47a-1cdf4e3369e7
#>  60:            <NA>                <NA> dfa93cee-3ebc-4c93-8139-f4dbdd6acedd
#>  61:            <NA>                <NA> 45bb4a99-e132-4308-8b63-9d4a4e8013e0
#>  62:            <NA>                <NA> 4f3a9e0e-7cd1-44eb-8334-70e48dd20338
#>  63:            <NA>                <NA> 21a582b1-4768-45fc-a069-521bae46f958
#>  64:            <NA>                <NA> 7c748c10-6a46-45b2-a5cf-c9ccef803da5
#>  65:            <NA>                <NA> 976c1b26-2d01-4f4c-af27-6bd2fd1a924b
#>  66:            <NA>                <NA> 48af5918-6023-4acd-a702-a1f038f84b10
#>  67:            <NA>                <NA> 53f36fc5-e737-4aae-8a0f-ed22c51c2084
#>  68:            <NA>                <NA> 844c17c9-2a2a-4544-92e6-b66eb023d9e6
#>  69:            <NA>                <NA> 35aaf778-5911-44af-b0c0-6fbd15d37add
#>  70:            <NA>                <NA> da212edd-0162-484f-b6a4-9cb4d026f5a8
#>  71:            <NA>                <NA> 93e09d69-76f1-47b7-97e8-b6dda54c7e99
#>  72:            <NA>                <NA> dc5456ff-3c1e-4854-8698-a5d3e2cd4d58
#>  73:            <NA>                <NA> 6029e0d3-4ce6-48e5-bc58-effdd924d9a5
#>  74:            <NA>                <NA> 646f3516-af3d-431f-b19f-bb58e5366069
#>  75:            <NA>                <NA> 0a2a2492-c498-4064-b023-e725742e3021
#>  76:            <NA>                <NA> 30582945-2542-493f-aa4b-f173b879dfc6
#>  77:            <NA>                <NA> 9cd9a458-6da3-4636-a1c6-2a58b03c3d5c
#>  78:            <NA>                <NA> 33bfd8d3-28e5-4d37-85dd-56d0061dafdd
#>  79:            <NA>                <NA> 69e789e3-3cc1-4ef2-8e51-b31b7e332d89
#>  80:            <NA>                <NA> 79628b84-4e03-4dc2-b4a9-2b3851ab7a72
#>  81:            <NA>                <NA> eb4f06e4-c7e6-43c8-b70b-7d8e76f2a50e
#>  82:            <NA>                <NA> 494b094b-50c8-4807-b1ca-bce283df9fca
#>  83:            <NA>                <NA> 18094083-464e-45d1-9492-cd2669262b8f
#>  84:            <NA>                <NA> 6c994576-0354-491c-ad66-b639648071f8
#>  85:            <NA>                <NA> 09637041-017e-4bd1-857a-637a1d32baa6
#>  86:            <NA>                <NA> 54b943d7-85da-400c-97d6-b76fda4ea9fc
#>  87:            <NA>                <NA> 2fda4f5e-5d93-499f-8afb-7882f214d263
#>  88:            <NA>                <NA> 68032cf1-2f1f-49f4-838f-78c24b95705e
#>  89:            <NA>                <NA> b388fff8-3e26-4dc0-b650-10328b44afdd
#>  90:            <NA>                <NA> 4cf28d38-9c32-4732-82f9-dd5e4081fd98
#>  91:            <NA>                <NA> 262eb41d-2abb-40b0-adb9-6bb5a37d9ed5
#>  92:            <NA>                <NA> ae1cd71d-e9c4-448b-8617-b27c6a8386ae
#>  93:            <NA>                <NA> 51c645f7-a84b-4418-9a77-2cf4c658b17f
#>  94:            <NA>                <NA> 6624e816-ca1d-425b-aa3b-cb5db06976fc
#>  95:            <NA>                <NA> b6003e66-38c4-45f0-a08b-fad551c2768c
#>  96:            <NA>                <NA> 3f22c97b-1cff-4120-9e0e-4b8f81f6d214
#>  97:            <NA>                <NA> df2eb28f-002a-498e-85b6-129869ffcf8c
#>  98:            <NA>                <NA> 79e30b92-d344-40fd-9935-dd1610aef401
#>  99:            <NA>                <NA> 150785ae-8fd2-440b-8b5c-e09cfcc706bf
#> 100:            <NA>                <NA> 372b56d0-410c-4bb8-99a7-408891e612ab
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
