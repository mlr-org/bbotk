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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-06-10 12:39:39
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-06-10 12:39:39
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-06-10 12:39:39
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-06-10 12:39:39
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-06-10 12:39:39
#>   6: finished -10.000000  0.5555556 -146.64198 2026-06-10 12:39:39
#>   7: finished -10.000000  1.6666667 -155.77778 2026-06-10 12:39:39
#>   8: finished -10.000000  2.7777778 -167.38272 2026-06-10 12:39:39
#>   9: finished -10.000000  3.8888889 -181.45679 2026-06-10 12:39:39
#>  10: finished -10.000000  5.0000000 -198.00000 2026-06-10 12:39:39
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-06-10 12:39:39
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-06-10 12:39:39
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-06-10 12:39:39
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-06-10 12:39:39
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-06-10 12:39:39
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-06-10 12:39:39
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-06-10 12:39:39
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-06-10 12:39:39
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-06-10 12:39:39
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-06-10 12:39:39
#>  21:   failed  10.000000  5.0000000         NA 2026-06-10 12:39:39
#>  22:   failed  10.000000  3.8888889         NA 2026-06-10 12:39:39
#>  23:   failed  10.000000  2.7777778         NA 2026-06-10 12:39:39
#>  24:   failed  10.000000  1.6666667         NA 2026-06-10 12:39:39
#>  25:   failed  10.000000  0.5555556         NA 2026-06-10 12:39:39
#>  26:   failed  10.000000 -0.5555556         NA 2026-06-10 12:39:39
#>  27:   failed  10.000000 -1.6666667         NA 2026-06-10 12:39:39
#>  28:   failed  10.000000 -2.7777778         NA 2026-06-10 12:39:39
#>  29:   failed  10.000000 -3.8888889         NA 2026-06-10 12:39:39
#>  30:   failed  10.000000 -5.0000000         NA 2026-06-10 12:39:39
#>  31:   failed   7.777778  5.0000000         NA 2026-06-10 12:39:39
#>  32:   failed   7.777778  3.8888889         NA 2026-06-10 12:39:39
#>  33:   failed   7.777778  2.7777778         NA 2026-06-10 12:39:39
#>  34:   failed   7.777778  1.6666667         NA 2026-06-10 12:39:39
#>  35:   failed   7.777778  0.5555556         NA 2026-06-10 12:39:39
#>  36:   failed   7.777778 -0.5555556         NA 2026-06-10 12:39:39
#>  37:   failed   7.777778 -1.6666667         NA 2026-06-10 12:39:39
#>  38:   failed   7.777778 -2.7777778         NA 2026-06-10 12:39:39
#>  39:   failed   7.777778 -3.8888889         NA 2026-06-10 12:39:39
#>  40:   failed   7.777778 -5.0000000         NA 2026-06-10 12:39:39
#>  41:   failed   5.555556  5.0000000         NA 2026-06-10 12:39:39
#>  42:   failed   5.555556  3.8888889         NA 2026-06-10 12:39:39
#>  43:   failed   5.555556  2.7777778         NA 2026-06-10 12:39:39
#>  44:   failed   5.555556  1.6666667         NA 2026-06-10 12:39:39
#>  45:   failed   5.555556  0.5555556         NA 2026-06-10 12:39:39
#>  46:   failed   5.555556 -0.5555556         NA 2026-06-10 12:39:39
#>  47:   failed   5.555556 -1.6666667         NA 2026-06-10 12:39:39
#>  48:   failed   5.555556 -2.7777778         NA 2026-06-10 12:39:39
#>  49:   failed   5.555556 -3.8888889         NA 2026-06-10 12:39:39
#>  50:   failed   5.555556 -5.0000000         NA 2026-06-10 12:39:39
#>  51:   failed   3.333333  5.0000000         NA 2026-06-10 12:39:39
#>  52:   failed   3.333333  3.8888889         NA 2026-06-10 12:39:39
#>  53:   failed   3.333333  2.7777778         NA 2026-06-10 12:39:39
#>  54:   failed   3.333333  1.6666667         NA 2026-06-10 12:39:39
#>  55:   failed   3.333333  0.5555556         NA 2026-06-10 12:39:39
#>  56:   failed   3.333333 -0.5555556         NA 2026-06-10 12:39:39
#>  57:   failed   3.333333 -1.6666667         NA 2026-06-10 12:39:39
#>  58:   failed   3.333333 -2.7777778         NA 2026-06-10 12:39:39
#>  59:   failed   3.333333 -3.8888889         NA 2026-06-10 12:39:39
#>  60:   failed   3.333333 -5.0000000         NA 2026-06-10 12:39:39
#>  61:   failed   1.111111  5.0000000         NA 2026-06-10 12:39:39
#>  62:   failed   1.111111  3.8888889         NA 2026-06-10 12:39:39
#>  63:   failed   1.111111  2.7777778         NA 2026-06-10 12:39:39
#>  64:   failed   1.111111  1.6666667         NA 2026-06-10 12:39:39
#>  65:   failed   1.111111  0.5555556         NA 2026-06-10 12:39:39
#>  66:   failed   1.111111 -0.5555556         NA 2026-06-10 12:39:39
#>  67:   failed   1.111111 -1.6666667         NA 2026-06-10 12:39:39
#>  68:   failed   1.111111 -2.7777778         NA 2026-06-10 12:39:39
#>  69:   failed   1.111111 -3.8888889         NA 2026-06-10 12:39:39
#>  70:   failed   1.111111 -5.0000000         NA 2026-06-10 12:39:39
#>  71:   failed  -1.111111  5.0000000         NA 2026-06-10 12:39:39
#>  72:   failed  -1.111111  3.8888889         NA 2026-06-10 12:39:39
#>  73:   failed  -1.111111  2.7777778         NA 2026-06-10 12:39:39
#>  74:   failed  -1.111111  1.6666667         NA 2026-06-10 12:39:39
#>  75:   failed  -1.111111  0.5555556         NA 2026-06-10 12:39:39
#>  76:   failed  -1.111111 -0.5555556         NA 2026-06-10 12:39:39
#>  77:   failed  -1.111111 -1.6666667         NA 2026-06-10 12:39:39
#>  78:   failed  -1.111111 -2.7777778         NA 2026-06-10 12:39:39
#>  79:   failed  -1.111111 -3.8888889         NA 2026-06-10 12:39:39
#>  80:   failed  -1.111111 -5.0000000         NA 2026-06-10 12:39:39
#>  81:   failed  -3.333333  5.0000000         NA 2026-06-10 12:39:39
#>  82:   failed  -3.333333  3.8888889         NA 2026-06-10 12:39:39
#>  83:   failed  -3.333333  2.7777778         NA 2026-06-10 12:39:39
#>  84:   failed  -3.333333  1.6666667         NA 2026-06-10 12:39:39
#>  85:   failed  -3.333333  0.5555556         NA 2026-06-10 12:39:39
#>  86:   failed  -3.333333 -0.5555556         NA 2026-06-10 12:39:39
#>  87:   failed  -3.333333 -1.6666667         NA 2026-06-10 12:39:39
#>  88:   failed  -3.333333 -2.7777778         NA 2026-06-10 12:39:39
#>  89:   failed  -3.333333 -3.8888889         NA 2026-06-10 12:39:39
#>  90:   failed  -3.333333 -5.0000000         NA 2026-06-10 12:39:39
#>  91:   failed  -5.555556  5.0000000         NA 2026-06-10 12:39:39
#>  92:   failed  -5.555556  3.8888889         NA 2026-06-10 12:39:39
#>  93:   failed  -5.555556  2.7777778         NA 2026-06-10 12:39:39
#>  94:   failed  -5.555556  1.6666667         NA 2026-06-10 12:39:39
#>  95:   failed  -5.555556  0.5555556         NA 2026-06-10 12:39:39
#>  96:   failed  -5.555556 -0.5555556         NA 2026-06-10 12:39:39
#>  97:   failed  -5.555556 -1.6666667         NA 2026-06-10 12:39:39
#>  98:   failed  -5.555556 -2.7777778         NA 2026-06-10 12:39:39
#>  99:   failed  -5.555556 -3.8888889         NA 2026-06-10 12:39:39
#> 100:   failed  -5.555556 -5.0000000         NA 2026-06-10 12:39:39
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-06-10 12:39:41 2920d10f-7ae6-4cd7-b294-06c6f43bfe29
#>   2: sinking_raccoon 2026-06-10 12:39:41 de4ea943-08e9-4ec9-991c-6b71d392f2bd
#>   3: sinking_raccoon 2026-06-10 12:39:41 8734ced5-05a2-4d04-9981-b2ff4ac1993f
#>   4: sinking_raccoon 2026-06-10 12:39:41 4f806768-02fc-4280-a89d-18a845d4b74c
#>   5: sinking_raccoon 2026-06-10 12:39:41 d15f9aac-0fca-4f02-9fec-c98689f5d736
#>   6: sinking_raccoon 2026-06-10 12:39:41 97a4ee4f-46b0-4f6d-a8ac-ac9dd3254e10
#>   7: sinking_raccoon 2026-06-10 12:39:41 0351d991-f4a4-4d45-8c10-42929d0d7d26
#>   8: sinking_raccoon 2026-06-10 12:39:41 e4b82351-77d1-4a2d-a2b0-a8e6748d0c1e
#>   9: sinking_raccoon 2026-06-10 12:39:41 a3e6afe2-2741-4d47-8a74-2942011c4553
#>  10: sinking_raccoon 2026-06-10 12:39:41 34724028-5d73-4fde-9c56-f436edff3a13
#>  11: sinking_raccoon 2026-06-10 12:39:41 a46144a7-c856-4b4b-82bb-8859e27612f4
#>  12: sinking_raccoon 2026-06-10 12:39:41 56bf956d-f1e3-40fa-ab98-a28af0521edc
#>  13: sinking_raccoon 2026-06-10 12:39:41 981620e5-cf21-444b-aa4d-bda0400dd73a
#>  14: sinking_raccoon 2026-06-10 12:39:41 4483f658-596d-492c-af57-02d5a67a2c5f
#>  15: sinking_raccoon 2026-06-10 12:39:41 40a23648-e784-4f21-a7b6-516a8d86738b
#>  16: sinking_raccoon 2026-06-10 12:39:41 dc25925c-6053-49c4-ae29-6fe1cff6a177
#>  17: sinking_raccoon 2026-06-10 12:39:41 42e47493-9c7c-418b-8c8d-15475d49773a
#>  18: sinking_raccoon 2026-06-10 12:39:41 713eeddd-1035-403b-88f6-c4860680af48
#>  19: sinking_raccoon 2026-06-10 12:39:41 96df5341-2409-4560-bea4-71a823bca5a1
#>  20: sinking_raccoon 2026-06-10 12:39:41 37088413-887d-44fb-8dd0-7e9fe8452b50
#>  21:            <NA>                <NA> 17f7e000-b69f-4e05-b7c5-2a8dacf6c651
#>  22:            <NA>                <NA> b412aa82-eca2-4c54-b239-3fc1e5a05155
#>  23:            <NA>                <NA> 87b90c39-99a0-4085-a587-30b85fd63541
#>  24:            <NA>                <NA> c5a04777-4421-4516-866a-7d30f66edfa9
#>  25:            <NA>                <NA> 1adc6b92-5801-46f9-ab24-0aeaaaa0c6cb
#>  26:            <NA>                <NA> 435829af-0b1b-4201-aa58-5ff18ab5ea39
#>  27:            <NA>                <NA> a1b556b1-bf85-4f0b-a95c-bcfdf710f2a2
#>  28:            <NA>                <NA> dfdeff7b-9124-4d2d-ad9f-4780918ce18c
#>  29:            <NA>                <NA> d22969ba-7615-4bc5-a55e-e6e30e519c0b
#>  30:            <NA>                <NA> edb5052c-6847-4061-818c-839d791b934b
#>  31:            <NA>                <NA> 994afb83-596c-45fc-a932-e1d5613d5d2f
#>  32:            <NA>                <NA> f3de0fe3-5e64-4737-81e5-2f369efd8587
#>  33:            <NA>                <NA> d1f3e9c3-f180-441f-8a4d-09debd27c9b4
#>  34:            <NA>                <NA> c7c37a46-624e-4932-95c1-61199bdfcd76
#>  35:            <NA>                <NA> f21cc891-43ff-46fb-9d6a-9deca2392099
#>  36:            <NA>                <NA> 5c427346-4e92-4a2e-b9b2-8a2ecf0c03aa
#>  37:            <NA>                <NA> 604d7316-f6c8-4703-8b5c-478c698dc13d
#>  38:            <NA>                <NA> 5f69b606-f0dd-40b4-b929-0197244c4a99
#>  39:            <NA>                <NA> b86fc479-34d8-4f92-bd01-bd6aae7f616c
#>  40:            <NA>                <NA> 9e994a71-f4d8-4a15-91d3-2099bb518b6c
#>  41:            <NA>                <NA> 033d26b2-3624-4e1f-9ab9-6eb1033fb53d
#>  42:            <NA>                <NA> c22a074b-4784-4dff-ab6e-aab7a399092a
#>  43:            <NA>                <NA> 87239fe4-0a43-4279-b30b-e5044cbbfe27
#>  44:            <NA>                <NA> 29b25039-85b3-4ce7-8158-c6850e6b708b
#>  45:            <NA>                <NA> c90c8527-cf82-4a22-9c38-1723efc8c65f
#>  46:            <NA>                <NA> c2df52f6-1a6c-496d-9181-b5474045c12a
#>  47:            <NA>                <NA> 2286d6a4-db17-4832-af14-a54cc277f591
#>  48:            <NA>                <NA> 4913e14d-4c36-45b3-b9b7-cb11b8d54091
#>  49:            <NA>                <NA> 6c56e355-c3cc-4ab7-bf0a-1d78e7b210c9
#>  50:            <NA>                <NA> 7371b28e-3bd2-406b-920a-168b2bda82dc
#>  51:            <NA>                <NA> 9a239edb-7439-46a5-9287-d28be584b8f9
#>  52:            <NA>                <NA> 964ad12a-af29-45c6-b512-cfd79d7025dd
#>  53:            <NA>                <NA> 01957fff-9497-4070-9092-b79fb613c46d
#>  54:            <NA>                <NA> 9dfa8236-eace-4985-8475-61796588cce1
#>  55:            <NA>                <NA> 9eecaa2b-9507-4a21-86a6-9624066c39b6
#>  56:            <NA>                <NA> aa2c443f-1866-47f8-994d-76b12bea3629
#>  57:            <NA>                <NA> 1cf01f61-7da4-46ee-9477-e8a39c71ee23
#>  58:            <NA>                <NA> 4f395213-ecbe-493a-893d-a994dcac4924
#>  59:            <NA>                <NA> 5683c630-6c20-406a-bc4a-3e0114212ec1
#>  60:            <NA>                <NA> 8999c480-4753-4fc9-9513-5d90f1671cdb
#>  61:            <NA>                <NA> 4bb0a657-49aa-4879-ad0b-925cf233d7cf
#>  62:            <NA>                <NA> fc49f0ef-1496-4675-90c8-fc60c74c0d69
#>  63:            <NA>                <NA> 46f50291-de22-4796-ba69-34a91979b65e
#>  64:            <NA>                <NA> 12445e50-5f4c-4337-bdd8-bf388053ad3c
#>  65:            <NA>                <NA> 7cff2225-d42d-4fca-b67a-3a8a196d05c0
#>  66:            <NA>                <NA> 71eedaff-d917-40fa-ac4f-1103fd1984aa
#>  67:            <NA>                <NA> b888f290-5c4f-4d03-a92c-409937627d5a
#>  68:            <NA>                <NA> e623f6f8-9b59-4ed7-840f-149382b19fe1
#>  69:            <NA>                <NA> 5332c610-7df1-4115-978a-c8f0d447b028
#>  70:            <NA>                <NA> 0f6f8b7b-4079-4178-bfe5-b02454d5334f
#>  71:            <NA>                <NA> 1d7fda15-642c-4f6f-8069-2d982fb1f4c2
#>  72:            <NA>                <NA> 7b7d0b7d-ecd7-42f5-9bca-fdb6214ec42b
#>  73:            <NA>                <NA> e76ed177-d42d-431b-8402-7f0cc1bc876f
#>  74:            <NA>                <NA> c83ea3ae-857d-46aa-b822-3a5d00e444c6
#>  75:            <NA>                <NA> 38482fb8-d2ba-4e7a-8c96-0d689c850bf5
#>  76:            <NA>                <NA> 76604e13-ef8b-4c5d-8d51-0d3036e6432c
#>  77:            <NA>                <NA> 29b71a0a-b698-4bf0-ad17-55856ed440fc
#>  78:            <NA>                <NA> 90e05d4f-ece2-4304-94bf-058fec2e532e
#>  79:            <NA>                <NA> 033642fd-e5c2-4447-b5a6-5e2618b20b54
#>  80:            <NA>                <NA> 41207f75-1403-4040-8ecb-f212d88b533b
#>  81:            <NA>                <NA> 554920b6-3d5e-45f7-8caa-cd043c18983d
#>  82:            <NA>                <NA> c25dd40d-1a4b-49d8-b89e-677750c15e56
#>  83:            <NA>                <NA> d450903b-65a6-4c59-a3fd-333830a52e14
#>  84:            <NA>                <NA> 490ab8a8-5f43-40fa-aee6-0100efa8528f
#>  85:            <NA>                <NA> caf0f12d-f85d-48fc-9afa-51448b592d4d
#>  86:            <NA>                <NA> b48d8454-fb2f-4b15-9e4c-c84d5a09be92
#>  87:            <NA>                <NA> 240ea5aa-cbb7-4fb4-ada7-d34be62e5176
#>  88:            <NA>                <NA> 5c9f7688-fb2c-407e-abe7-dbf522f346df
#>  89:            <NA>                <NA> 1f9b73fb-55fc-4776-9541-68fa27ee1d63
#>  90:            <NA>                <NA> d24d8254-ff43-4239-953b-b80cd592cca3
#>  91:            <NA>                <NA> 76cbb99b-59e7-4fa7-80d2-445da9ffa986
#>  92:            <NA>                <NA> ef68a0b5-6e95-4a30-b1ed-a9d10d69bde1
#>  93:            <NA>                <NA> db5f4dd7-4e20-4153-a634-d212b213f93a
#>  94:            <NA>                <NA> 53deeb4d-6b31-431e-bbed-e5309fd44a6c
#>  95:            <NA>                <NA> 051d0a0a-f4aa-4f1e-beed-c5465162d174
#>  96:            <NA>                <NA> fd987eb4-f1bc-4d52-b438-c452647e1c9b
#>  97:            <NA>                <NA> 0fa1ec24-1918-4371-8edf-c4c28b5718db
#>  98:            <NA>                <NA> c121930b-89e8-408d-aa5c-249cb9b3176f
#>  99:            <NA>                <NA> 6debc5d1-c04f-4991-9ebf-2503652a3e87
#> 100:            <NA>                <NA> 29d06f2f-2710-42ec-8250-e932fd4fa5c3
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
