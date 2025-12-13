# Frozen Rush Data Storage

Freezes the Redis data base of an
[ArchiveAsync](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.md)
to a
[`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html).
No further points can be added to the archive but the data can be
accessed and analyzed. Useful when the Redis data base is not
permanently available. Use the callback
[bbotk.async_freeze_archive](https://bbotk.mlr-org.com/dev/reference/bbotk.async_freeze_archive.md)
to freeze the archive after the optimization has finished.

## S3 Methods

- `as.data.table(archive)`  
  [ArchiveAsync](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.md)
  -\>
  [`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)  
  Returns a tabular view of all performed function calls of the
  Objective. The `x_domain` column is unnested to separate columns.

## See also

[ArchiveAsync](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.md)

## Super classes

[`bbotk::Archive`](https://bbotk.mlr-org.com/dev/reference/Archive.md)
-\>
[`bbotk::ArchiveAsync`](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.md)
-\> `ArchiveAsyncFrozen`

## Active bindings

- `data`:

  ([data.table::data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html))  
  Data table with all finished points.

- `queued_data`:

  ([data.table::data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html))  
  Data table with all queued points.

- `running_data`:

  ([data.table::data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html))  
  Data table with all running points.

- `finished_data`:

  ([data.table::data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html))  
  Data table with all finished points.

- `failed_data`:

  ([data.table::data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html))  
  Data table with all failed points.

- `n_queued`:

  (`integer(1)`)  
  Number of queued points.

- `n_running`:

  (`integer(1)`)  
  Number of running points.

- `n_finished`:

  (`integer(1)`)  
  Number of finished points.

- `n_failed`:

  (`integer(1)`)  
  Number of failed points.

- `n_evals`:

  (`integer(1)`)  
  Number of evaluations stored in the archive.

## Methods

### Public methods

- [`ArchiveAsyncFrozen$new()`](#method-ArchiveAsyncFrozen-new)

- [`ArchiveAsyncFrozen$push_points()`](#method-ArchiveAsyncFrozen-push_points)

- [`ArchiveAsyncFrozen$pop_point()`](#method-ArchiveAsyncFrozen-pop_point)

- [`ArchiveAsyncFrozen$push_running_point()`](#method-ArchiveAsyncFrozen-push_running_point)

- [`ArchiveAsyncFrozen$push_result()`](#method-ArchiveAsyncFrozen-push_result)

- [`ArchiveAsyncFrozen$push_failed_point()`](#method-ArchiveAsyncFrozen-push_failed_point)

- [`ArchiveAsyncFrozen$data_with_state()`](#method-ArchiveAsyncFrozen-data_with_state)

- [`ArchiveAsyncFrozen$clear()`](#method-ArchiveAsyncFrozen-clear)

- [`ArchiveAsyncFrozen$clone()`](#method-ArchiveAsyncFrozen-clone)

Inherited methods

- [`bbotk::Archive$format()`](https://bbotk.mlr-org.com/dev/reference/Archive.html#method-format)
- [`bbotk::Archive$help()`](https://bbotk.mlr-org.com/dev/reference/Archive.html#method-help)
- [`bbotk::Archive$print()`](https://bbotk.mlr-org.com/dev/reference/Archive.html#method-print)
- [`bbotk::ArchiveAsync$best()`](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.html#method-best)
- [`bbotk::ArchiveAsync$nds_selection()`](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.html#method-nds_selection)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    ArchiveAsyncFrozen$new(archive)

#### Arguments

- `archive`:

  ([ArchiveAsync](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.md))  
  The archive to freeze.

------------------------------------------------------------------------

### Method `push_points()`

Push queued points to the archive.

#### Usage

    ArchiveAsyncFrozen$push_points(xss)

#### Arguments

- `xss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of point values.

------------------------------------------------------------------------

### Method `pop_point()`

Pop a point from the queue.

#### Usage

    ArchiveAsyncFrozen$pop_point()

------------------------------------------------------------------------

### Method `push_running_point()`

Push running point to the archive.

#### Usage

    ArchiveAsyncFrozen$push_running_point(xs, extra = NULL)

#### Arguments

- `xs`:

  (named `list`)  
  Named list of point values.

- `extra`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  Named list of additional information.

------------------------------------------------------------------------

### Method `push_result()`

Push result to the archive.

#### Usage

    ArchiveAsyncFrozen$push_result(key, ys, x_domain, extra = NULL)

#### Arguments

- `key`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Key of the point.

- `ys`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  Named list of results.

- `x_domain`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  Named list of transformed point values.

- `extra`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  Named list of additional information.

------------------------------------------------------------------------

### Method `push_failed_point()`

Push failed point to the archive.

#### Usage

    ArchiveAsyncFrozen$push_failed_point(key, message)

#### Arguments

- `key`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Key of the point.

- `message`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Error message.

------------------------------------------------------------------------

### Method `data_with_state()`

Fetch points with a specific state.

#### Usage

    ArchiveAsyncFrozen$data_with_state(
      fields = c("xs", "ys", "xs_extra", "worker_extra", "ys_extra", "condition"),
      states = c("queued", "running", "finished", "failed"),
      reset_cache = FALSE
    )

#### Arguments

- `fields`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Fields to fetch. Defaults to
  `c("xs", "ys", "xs_extra", "worker_extra", "ys_extra")`.

- `states`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  States of the tasks to be fetched. Defaults to
  `c("queued", "running", "finished", "failed")`.

- `reset_cache`:

  (`logical(1)`)  
  Whether to reset the cache of the finished points.

------------------------------------------------------------------------

### Method `clear()`

Clear all evaluation results from archive.

#### Usage

    ArchiveAsyncFrozen$clear()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ArchiveAsyncFrozen$clone(deep = FALSE)

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
rush::rush_plan(worker_type = "remote")
mirai::daemons(1)

# initialize instance
instance = oi_async(
  objective = objective,
  terminator = trm("evals", n_evals = 20),
  callback = clbk("bbotk.async_freeze_archive")
)

# load optimizer
optimizer = opt("async_random_search")

# trigger optimization
optimizer$optimize(instance)

# frozen archive
instance$archive

# best performing configuration
instance$archive$best()

# covert to data.table
as.data.table(instance$archive)
}
#>        state         x1           x2            y        timestamp_xs   pid
#>       <char>      <num>        <num>        <num>              <POSc> <int>
#>  1: finished  0.7355865  4.436809312  -46.9048744 2025-12-13 11:47:54  7522
#>  2: finished -5.2465150  1.685353492  -64.4645163 2025-12-13 11:47:54  7522
#>  3: finished -1.6100269  1.692733854  -25.0540453 2025-12-13 11:47:54  7522
#>  4: finished -9.6485851  2.074896538 -151.4441090 2025-12-13 11:47:54  7522
#>  5: finished  9.1534135  0.636737862  -54.3971877 2025-12-13 11:47:54  7522
#>  6: finished -0.9507994 -4.878603549   -2.2363683 2025-12-13 11:47:54  7522
#>  7: finished  2.7997505 -1.921276769    8.1967553 2025-12-13 11:47:54  7522
#>  8: finished  7.9367603  3.130829856  -62.8321976 2025-12-13 11:47:54  7522
#>  9: finished -5.3535132  0.132857377  -53.8889510 2025-12-13 11:47:54  7522
#> 10: finished -1.1703927  1.581480915  -21.0413571 2025-12-13 11:47:54  7522
#> 11: finished  5.5692991  1.671339287  -24.5613067 2025-12-13 11:47:54  7522
#> 12: finished  9.4659255 -4.325706593  -47.4975413 2025-12-13 11:47:55  7522
#> 13: finished -4.5022012 -3.621611151  -32.6650205 2025-12-13 11:47:55  7522
#> 14: finished  6.4919932  0.400897277  -21.7441056 2025-12-13 11:47:55  7522
#> 15: finished -1.5261497 -0.002130552  -11.4209531 2025-12-13 11:47:55  7522
#> 16: finished  5.2346110 -2.546360991   -0.6684964 2025-12-13 11:47:55  7522
#> 17: finished -8.1469277 -2.532682236  -93.1785285 2025-12-13 11:47:55  7522
#> 18: finished  7.9586287 -3.273955223  -25.5803070 2025-12-13 11:47:55  7522
#> 19: finished  5.3650967 -2.241232399   -1.8996043 2025-12-13 11:47:55  7522
#> 20: finished  4.8743111  3.778382706  -44.2081363 2025-12-13 11:47:55  7522
#>        state         x1           x2            y        timestamp_xs   pid
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>  1: limestone_drever 2025-12-13 11:47:54 1aaa031b-ab2e-4e27-9f20-1583896beb69
#>  2: limestone_drever 2025-12-13 11:47:54 1efb7b4e-b5fd-4ad4-8a54-4602213f0052
#>  3: limestone_drever 2025-12-13 11:47:54 1b82e6ac-17b1-48c0-b12d-b301b6fd5bd0
#>  4: limestone_drever 2025-12-13 11:47:54 60d2bcdc-8586-46c4-bd9c-3274bc00c6a3
#>  5: limestone_drever 2025-12-13 11:47:54 bf9deadf-1da2-42ab-8076-dcf4b8056f61
#>  6: limestone_drever 2025-12-13 11:47:54 2c3f9196-d998-44b5-9c5f-24ebe52b7d41
#>  7: limestone_drever 2025-12-13 11:47:54 4d170640-65ff-4734-9db9-92953b5efb81
#>  8: limestone_drever 2025-12-13 11:47:54 016cf049-a00d-4149-be27-9cc3888427d1
#>  9: limestone_drever 2025-12-13 11:47:54 e8cf25eb-6c21-4eb3-8583-7dbacf4dcfbe
#> 10: limestone_drever 2025-12-13 11:47:54 5be46fef-035e-4392-8522-c7baeec7d6c0
#> 11: limestone_drever 2025-12-13 11:47:54 9b8eaab9-ddf4-44d9-b287-44a6e4014dfd
#> 12: limestone_drever 2025-12-13 11:47:55 1c5eb6b0-a04d-40a2-98bb-69e28750c160
#> 13: limestone_drever 2025-12-13 11:47:55 424fbb0c-5a24-4d97-8153-031ce6d9e3ca
#> 14: limestone_drever 2025-12-13 11:47:55 cf0f7116-b74c-455b-8fa3-8ee602e0707d
#> 15: limestone_drever 2025-12-13 11:47:55 b7f88a65-92e2-459f-ac8d-b70578bbb277
#> 16: limestone_drever 2025-12-13 11:47:55 7d3de249-4281-4165-8f06-a09b0a89c862
#> 17: limestone_drever 2025-12-13 11:47:55 2f18f4ec-0c6c-40a2-9e7a-5e91b04149ec
#> 18: limestone_drever 2025-12-13 11:47:55 1e5d3f16-f21b-44bd-b489-2daa214d4532
#> 19: limestone_drever 2025-12-13 11:47:55 f70e6406-7256-4465-b778-9940c776b2e3
#> 20: limestone_drever 2025-12-13 11:47:55 d5351df9-cdc0-4d95-b3f6-7599f2ca29f4
#>            worker_id        timestamp_ys                                 keys
#>     x_domain_x1  x_domain_x2
#>           <num>        <num>
#>  1:   0.7355865  4.436809312
#>  2:  -5.2465150  1.685353492
#>  3:  -1.6100269  1.692733854
#>  4:  -9.6485851  2.074896538
#>  5:   9.1534135  0.636737862
#>  6:  -0.9507994 -4.878603549
#>  7:   2.7997505 -1.921276769
#>  8:   7.9367603  3.130829856
#>  9:  -5.3535132  0.132857377
#> 10:  -1.1703927  1.581480915
#> 11:   5.5692991  1.671339287
#> 12:   9.4659255 -4.325706593
#> 13:  -4.5022012 -3.621611151
#> 14:   6.4919932  0.400897277
#> 15:  -1.5261497 -0.002130552
#> 16:   5.2346110 -2.546360991
#> 17:  -8.1469277 -2.532682236
#> 18:   7.9586287 -3.273955223
#> 19:   5.3650967 -2.241232399
#> 20:   4.8743111  3.778382706
#>     x_domain_x1  x_domain_x2
```
