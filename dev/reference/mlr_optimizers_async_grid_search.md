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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-03-19 07:59:19
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-03-19 07:59:19
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-03-19 07:59:19
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-03-19 07:59:19
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-03-19 07:59:19
#>   6: finished -10.000000  0.5555556 -146.64198 2026-03-19 07:59:19
#>   7: finished -10.000000  1.6666667 -155.77778 2026-03-19 07:59:19
#>   8: finished -10.000000  2.7777778 -167.38272 2026-03-19 07:59:19
#>   9: finished -10.000000  3.8888889 -181.45679 2026-03-19 07:59:19
#>  10: finished -10.000000  5.0000000 -198.00000 2026-03-19 07:59:19
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-03-19 07:59:19
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-03-19 07:59:19
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-03-19 07:59:19
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-03-19 07:59:19
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-03-19 07:59:19
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-03-19 07:59:19
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-03-19 07:59:19
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-03-19 07:59:19
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-03-19 07:59:19
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-03-19 07:59:19
#>  21:   failed  10.000000  5.0000000         NA 2026-03-19 07:59:19
#>  22:   failed  10.000000  3.8888889         NA 2026-03-19 07:59:19
#>  23:   failed  10.000000  2.7777778         NA 2026-03-19 07:59:19
#>  24:   failed  10.000000  1.6666667         NA 2026-03-19 07:59:19
#>  25:   failed  10.000000  0.5555556         NA 2026-03-19 07:59:19
#>  26:   failed  10.000000 -0.5555556         NA 2026-03-19 07:59:19
#>  27:   failed  10.000000 -1.6666667         NA 2026-03-19 07:59:19
#>  28:   failed  10.000000 -2.7777778         NA 2026-03-19 07:59:19
#>  29:   failed  10.000000 -3.8888889         NA 2026-03-19 07:59:19
#>  30:   failed  10.000000 -5.0000000         NA 2026-03-19 07:59:19
#>  31:   failed   7.777778  5.0000000         NA 2026-03-19 07:59:19
#>  32:   failed   7.777778  3.8888889         NA 2026-03-19 07:59:19
#>  33:   failed   7.777778  2.7777778         NA 2026-03-19 07:59:19
#>  34:   failed   7.777778  1.6666667         NA 2026-03-19 07:59:19
#>  35:   failed   7.777778  0.5555556         NA 2026-03-19 07:59:19
#>  36:   failed   7.777778 -0.5555556         NA 2026-03-19 07:59:19
#>  37:   failed   7.777778 -1.6666667         NA 2026-03-19 07:59:19
#>  38:   failed   7.777778 -2.7777778         NA 2026-03-19 07:59:19
#>  39:   failed   7.777778 -3.8888889         NA 2026-03-19 07:59:19
#>  40:   failed   7.777778 -5.0000000         NA 2026-03-19 07:59:19
#>  41:   failed   5.555556  5.0000000         NA 2026-03-19 07:59:19
#>  42:   failed   5.555556  3.8888889         NA 2026-03-19 07:59:19
#>  43:   failed   5.555556  2.7777778         NA 2026-03-19 07:59:19
#>  44:   failed   5.555556  1.6666667         NA 2026-03-19 07:59:19
#>  45:   failed   5.555556  0.5555556         NA 2026-03-19 07:59:19
#>  46:   failed   5.555556 -0.5555556         NA 2026-03-19 07:59:19
#>  47:   failed   5.555556 -1.6666667         NA 2026-03-19 07:59:19
#>  48:   failed   5.555556 -2.7777778         NA 2026-03-19 07:59:19
#>  49:   failed   5.555556 -3.8888889         NA 2026-03-19 07:59:19
#>  50:   failed   5.555556 -5.0000000         NA 2026-03-19 07:59:19
#>  51:   failed   3.333333  5.0000000         NA 2026-03-19 07:59:19
#>  52:   failed   3.333333  3.8888889         NA 2026-03-19 07:59:19
#>  53:   failed   3.333333  2.7777778         NA 2026-03-19 07:59:19
#>  54:   failed   3.333333  1.6666667         NA 2026-03-19 07:59:19
#>  55:   failed   3.333333  0.5555556         NA 2026-03-19 07:59:19
#>  56:   failed   3.333333 -0.5555556         NA 2026-03-19 07:59:19
#>  57:   failed   3.333333 -1.6666667         NA 2026-03-19 07:59:19
#>  58:   failed   3.333333 -2.7777778         NA 2026-03-19 07:59:19
#>  59:   failed   3.333333 -3.8888889         NA 2026-03-19 07:59:19
#>  60:   failed   3.333333 -5.0000000         NA 2026-03-19 07:59:19
#>  61:   failed   1.111111  5.0000000         NA 2026-03-19 07:59:19
#>  62:   failed   1.111111  3.8888889         NA 2026-03-19 07:59:19
#>  63:   failed   1.111111  2.7777778         NA 2026-03-19 07:59:19
#>  64:   failed   1.111111  1.6666667         NA 2026-03-19 07:59:19
#>  65:   failed   1.111111  0.5555556         NA 2026-03-19 07:59:19
#>  66:   failed   1.111111 -0.5555556         NA 2026-03-19 07:59:19
#>  67:   failed   1.111111 -1.6666667         NA 2026-03-19 07:59:19
#>  68:   failed   1.111111 -2.7777778         NA 2026-03-19 07:59:19
#>  69:   failed   1.111111 -3.8888889         NA 2026-03-19 07:59:19
#>  70:   failed   1.111111 -5.0000000         NA 2026-03-19 07:59:19
#>  71:   failed  -1.111111  5.0000000         NA 2026-03-19 07:59:19
#>  72:   failed  -1.111111  3.8888889         NA 2026-03-19 07:59:19
#>  73:   failed  -1.111111  2.7777778         NA 2026-03-19 07:59:19
#>  74:   failed  -1.111111  1.6666667         NA 2026-03-19 07:59:19
#>  75:   failed  -1.111111  0.5555556         NA 2026-03-19 07:59:19
#>  76:   failed  -1.111111 -0.5555556         NA 2026-03-19 07:59:19
#>  77:   failed  -1.111111 -1.6666667         NA 2026-03-19 07:59:19
#>  78:   failed  -1.111111 -2.7777778         NA 2026-03-19 07:59:19
#>  79:   failed  -1.111111 -3.8888889         NA 2026-03-19 07:59:19
#>  80:   failed  -1.111111 -5.0000000         NA 2026-03-19 07:59:19
#>  81:   failed  -3.333333  5.0000000         NA 2026-03-19 07:59:19
#>  82:   failed  -3.333333  3.8888889         NA 2026-03-19 07:59:19
#>  83:   failed  -3.333333  2.7777778         NA 2026-03-19 07:59:19
#>  84:   failed  -3.333333  1.6666667         NA 2026-03-19 07:59:19
#>  85:   failed  -3.333333  0.5555556         NA 2026-03-19 07:59:19
#>  86:   failed  -3.333333 -0.5555556         NA 2026-03-19 07:59:19
#>  87:   failed  -3.333333 -1.6666667         NA 2026-03-19 07:59:19
#>  88:   failed  -3.333333 -2.7777778         NA 2026-03-19 07:59:19
#>  89:   failed  -3.333333 -3.8888889         NA 2026-03-19 07:59:19
#>  90:   failed  -3.333333 -5.0000000         NA 2026-03-19 07:59:19
#>  91:   failed  -5.555556  5.0000000         NA 2026-03-19 07:59:19
#>  92:   failed  -5.555556  3.8888889         NA 2026-03-19 07:59:19
#>  93:   failed  -5.555556  2.7777778         NA 2026-03-19 07:59:19
#>  94:   failed  -5.555556  1.6666667         NA 2026-03-19 07:59:19
#>  95:   failed  -5.555556  0.5555556         NA 2026-03-19 07:59:19
#>  96:   failed  -5.555556 -0.5555556         NA 2026-03-19 07:59:19
#>  97:   failed  -5.555556 -1.6666667         NA 2026-03-19 07:59:19
#>  98:   failed  -5.555556 -2.7777778         NA 2026-03-19 07:59:19
#>  99:   failed  -5.555556 -3.8888889         NA 2026-03-19 07:59:19
#> 100:   failed  -5.555556 -5.0000000         NA 2026-03-19 07:59:19
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-03-19 07:59:20 05eb052e-160b-48ad-b32a-46e7311c1e7a
#>   2: sinking_raccoon 2026-03-19 07:59:20 76c8d713-3ded-48fe-a10b-e7ae51d3eb9e
#>   3: sinking_raccoon 2026-03-19 07:59:20 6ae139e9-fa2e-48ae-a760-66a8a6b1fa28
#>   4: sinking_raccoon 2026-03-19 07:59:20 78e60479-6ce3-43c2-b33c-2ab76b0e5fe3
#>   5: sinking_raccoon 2026-03-19 07:59:20 38dfcd57-79b3-49da-a16f-921a6f72f855
#>   6: sinking_raccoon 2026-03-19 07:59:20 32608d37-de41-4388-bd78-122554e5255e
#>   7: sinking_raccoon 2026-03-19 07:59:20 b2558b3b-fa51-452d-acff-85d39e03b9a6
#>   8: sinking_raccoon 2026-03-19 07:59:20 ffce8bf9-58bb-4bf5-9534-b7beb5af192e
#>   9: sinking_raccoon 2026-03-19 07:59:20 9ce7c595-5e7f-4004-90b7-ee3007958432
#>  10: sinking_raccoon 2026-03-19 07:59:20 50ab7df0-259d-4844-94aa-c5eaacc44726
#>  11: sinking_raccoon 2026-03-19 07:59:20 e3dbd1f3-3318-4f86-88ba-67b594d0f6d2
#>  12: sinking_raccoon 2026-03-19 07:59:20 f0dd350e-01cb-4315-8e59-e215c11dd8d5
#>  13: sinking_raccoon 2026-03-19 07:59:20 697e8f2a-f621-4cc1-a1c8-3b372f50df71
#>  14: sinking_raccoon 2026-03-19 07:59:20 9d1df5d7-3f73-4fe0-b713-4e15a7f7310e
#>  15: sinking_raccoon 2026-03-19 07:59:20 800886e0-3574-4518-8051-6378ec228329
#>  16: sinking_raccoon 2026-03-19 07:59:20 1fb9eb95-c8d7-49b6-a3b6-9ea79c3df8d1
#>  17: sinking_raccoon 2026-03-19 07:59:20 ec82e496-6975-46f0-84c6-6bbf36c238a7
#>  18: sinking_raccoon 2026-03-19 07:59:20 14a6e863-5819-4e77-a4b7-531d9b15407d
#>  19: sinking_raccoon 2026-03-19 07:59:20 bdb55ea7-d104-438f-b9b7-3150cca9ac6c
#>  20: sinking_raccoon 2026-03-19 07:59:20 67dfe1c0-7aea-45c9-b271-3a8a8fb56935
#>  21:            <NA>                <NA> 87fd999e-6610-4f09-b592-da9942c19d61
#>  22:            <NA>                <NA> c5507c9a-d1c7-43db-bc0a-aac83c92aff9
#>  23:            <NA>                <NA> b4dc8561-c04b-4147-82e3-9319d0801280
#>  24:            <NA>                <NA> 1e062fd5-4b1b-4600-965b-06f8f1067243
#>  25:            <NA>                <NA> fbcdb891-887c-4a76-b0fa-792910d7a7e0
#>  26:            <NA>                <NA> fca1b01b-5c12-4650-b983-f1c6af9b60dc
#>  27:            <NA>                <NA> a7ee0ec1-7817-4f62-b4eb-d7c1704cfd7e
#>  28:            <NA>                <NA> be2a88cc-f9bc-48dc-b52a-40d023c9416f
#>  29:            <NA>                <NA> db40c616-8a9d-4adf-a981-3ff12be03eaa
#>  30:            <NA>                <NA> 79919437-100f-4e8d-90f9-2b5f1862b32d
#>  31:            <NA>                <NA> 1a74048f-280f-4ca6-92dc-a6f8d1667757
#>  32:            <NA>                <NA> a56c2c56-24d6-4a5a-8db1-c7e4c47f939d
#>  33:            <NA>                <NA> ec1ba693-eefc-4b00-a6e6-128772bac02e
#>  34:            <NA>                <NA> 6f2989fc-1dea-42e3-b342-10016f041e05
#>  35:            <NA>                <NA> 5bbc7652-29ef-4517-aef8-99652d676c91
#>  36:            <NA>                <NA> ffa8f1c8-22d9-4f7a-9cb2-dfcb703a1644
#>  37:            <NA>                <NA> a9ca688f-897e-492f-9a62-985c2a659cd5
#>  38:            <NA>                <NA> 88fe68ef-cd3e-4a07-bb8a-5c99a8341ef7
#>  39:            <NA>                <NA> 9169b3dd-49b2-479b-b6f3-3822b2393eac
#>  40:            <NA>                <NA> 0b89383e-efee-47ed-aede-d031e251d602
#>  41:            <NA>                <NA> 8338f0f6-3d46-42b1-a50b-1b8a81e7ff6d
#>  42:            <NA>                <NA> 3c03a17a-4cd4-4ccb-a2e2-d9675320a2ac
#>  43:            <NA>                <NA> 465cc086-eb08-4d68-b423-d2782d2665b0
#>  44:            <NA>                <NA> 06d18083-e2e1-46f2-9a38-87df6c8156b9
#>  45:            <NA>                <NA> a3e3ba09-cf3f-48a6-baf6-899ef8c74276
#>  46:            <NA>                <NA> 59eb861c-8f47-438b-aa53-e5317c08f1b4
#>  47:            <NA>                <NA> 094197bc-89c3-43ca-9da8-c16333986bdb
#>  48:            <NA>                <NA> 1b1d567f-fc46-4465-98e3-c8bcd3e88776
#>  49:            <NA>                <NA> 95a5fc41-4598-42d2-a0cc-d9ffdf3c0773
#>  50:            <NA>                <NA> 9bf82131-00ee-4bd6-a761-726f8a03f75b
#>  51:            <NA>                <NA> e5e9bb6f-1a1c-4b34-9ea2-444002a06960
#>  52:            <NA>                <NA> 61f43996-2a31-470e-9acf-a5cb0cb573a8
#>  53:            <NA>                <NA> 8c1aa24a-765e-47bb-9ddd-9097b50ffd24
#>  54:            <NA>                <NA> 3b9442a5-2486-4879-932c-3a36824229af
#>  55:            <NA>                <NA> acfb567c-e470-43f4-8539-204d25e6e7e7
#>  56:            <NA>                <NA> f9d768bc-9755-4971-9d8f-e03fd3bc1adf
#>  57:            <NA>                <NA> 5292cbda-afa0-47a0-8a9f-3293a85e09ef
#>  58:            <NA>                <NA> bb9fc3d0-2d41-4ef2-bc7d-141bde136e26
#>  59:            <NA>                <NA> 9500cd43-9aa6-4ca9-8ec6-47b192363f04
#>  60:            <NA>                <NA> 43a53265-564e-4e1a-a5f4-393d371167cc
#>  61:            <NA>                <NA> 5ddba1ce-31fd-48b0-b7c1-365edcde18f1
#>  62:            <NA>                <NA> fc78e86c-4baf-4eaf-a4d2-a82fc459ec08
#>  63:            <NA>                <NA> d004ebd5-46f6-4a97-b561-8c950988a103
#>  64:            <NA>                <NA> 15bb526e-a950-47ad-831a-c20e46bfb89e
#>  65:            <NA>                <NA> 2c809b40-f013-4823-a6af-32790a463b02
#>  66:            <NA>                <NA> 8901b968-4bbf-4099-9795-065be52346e7
#>  67:            <NA>                <NA> 73373adb-28a3-497d-afcc-f9c34ac9a33c
#>  68:            <NA>                <NA> 16b17ce3-f135-463e-9dce-38c76e8f45d8
#>  69:            <NA>                <NA> 7762e969-498c-41a3-9232-0502fe1f22ff
#>  70:            <NA>                <NA> c5570f1e-5fc5-4b19-8c0b-1a69a65d30b6
#>  71:            <NA>                <NA> 43534cfc-f096-443b-ae11-e34a557833ca
#>  72:            <NA>                <NA> 2ae24e45-a155-41b4-b938-dfcc239d43fa
#>  73:            <NA>                <NA> d75b94d3-fc2f-4a28-b70f-2e2ed41c7151
#>  74:            <NA>                <NA> 5e8501f4-f2e9-4446-8121-6a9ef30778f1
#>  75:            <NA>                <NA> e8f02a78-9821-4161-9835-4463c7237b39
#>  76:            <NA>                <NA> e61d4565-f93b-4973-a7f0-374f54fd0c11
#>  77:            <NA>                <NA> ba6092f2-b33c-42e7-98cd-a8b3f097889a
#>  78:            <NA>                <NA> 339c4d7d-f690-4170-bf6d-f8f66c1c9cba
#>  79:            <NA>                <NA> 3b62a742-3aff-4df5-be99-3c6f3bd4c56b
#>  80:            <NA>                <NA> 7558c179-b91b-42b7-8c77-d7d7123926c5
#>  81:            <NA>                <NA> 1a7a4615-1a59-4467-908b-f98a7b07b7df
#>  82:            <NA>                <NA> 1bb8206f-eb24-426e-8b4a-dce7eb4001ed
#>  83:            <NA>                <NA> 34931ad9-f336-47db-86e6-7ef5a175e79e
#>  84:            <NA>                <NA> 0f2fd733-67c6-4610-8f94-7d99dc0cda79
#>  85:            <NA>                <NA> 5e52016e-8761-46ca-b4bd-9f423f2f2d05
#>  86:            <NA>                <NA> c9f975f1-7462-4b82-897f-0db78bf0e6d5
#>  87:            <NA>                <NA> 1ebb5872-5b5f-4af0-81df-b11bf005bea8
#>  88:            <NA>                <NA> 9d938ee9-2c1a-4491-be1a-008cd703592e
#>  89:            <NA>                <NA> 46cf5972-398a-4893-bb8a-3ed2de6ce7a8
#>  90:            <NA>                <NA> 608dbcf7-e330-47be-8a15-62c3cacbfb9d
#>  91:            <NA>                <NA> a54921fc-aa67-4c20-8c94-6163d962fd54
#>  92:            <NA>                <NA> 95889edf-593f-44a7-a5ea-224c787ab3b2
#>  93:            <NA>                <NA> a5f1dc60-1831-4773-80fd-28b32c0e49d6
#>  94:            <NA>                <NA> 856fb6e0-3a54-4ce8-9fc9-5af917506d7d
#>  95:            <NA>                <NA> 40264d20-8e48-4279-92db-d9cf29726b1d
#>  96:            <NA>                <NA> 9d3d938b-2e4a-450d-a7f6-54ee5d2910f6
#>  97:            <NA>                <NA> 97eae7b3-3d12-40b7-8e21-9649b5660c06
#>  98:            <NA>                <NA> 4008e406-4787-48e4-8da6-808b3cb6e67d
#>  99:            <NA>                <NA> 9e7a4d19-b362-4bf0-a834-ab2a80048fe3
#> 100:            <NA>                <NA> cc429f25-749f-4691-b96c-3e1a332334cb
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
