# Frozen Rush Data Storage

Freezes the Redis data base of an
[ArchiveAsync](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.md)
to a
[`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html).
No further points can be added to the archive but the data can be
accessed and analyzed. Useful when the Redis data base is not
permanently available. Use the callback
[bbotk.async_freeze_archive](https://bbotk.mlr-org.com/dev/reference/bbotk.async_freeze_archive.md)
to freeze the archive after the optimization has finished.

## S3 Methods

- `as.data.table(archive)`  
  [ArchiveAsync](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.md)
  -\>
  [`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)  
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

  ([data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html))  
  Data table with all finished points.

- `queued_data`:

  ([data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html))  
  Data table with all queued points.

- `running_data`:

  ([data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html))  
  Data table with all running points.

- `finished_data`:

  ([data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html))  
  Data table with all finished points.

- `failed_data`:

  ([data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html))  
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
#>  1: finished  0.7355865  4.436809312  -46.9048744 2026-02-18 10:57:27  7723
#>  2: finished -5.2465150  1.685353492  -64.4645163 2026-02-18 10:57:28  7723
#>  3: finished -1.6100269  1.692733854  -25.0540453 2026-02-18 10:57:28  7723
#>  4: finished -9.6485851  2.074896538 -151.4441090 2026-02-18 10:57:28  7723
#>  5: finished  9.1534135  0.636737862  -54.3971877 2026-02-18 10:57:28  7723
#>  6: finished -0.9507994 -4.878603549   -2.2363683 2026-02-18 10:57:28  7723
#>  7: finished  2.7997505 -1.921276769    8.1967553 2026-02-18 10:57:28  7723
#>  8: finished  7.9367603  3.130829856  -62.8321976 2026-02-18 10:57:28  7723
#>  9: finished -5.3535132  0.132857377  -53.8889510 2026-02-18 10:57:28  7723
#> 10: finished -1.1703927  1.581480915  -21.0413571 2026-02-18 10:57:28  7723
#> 11: finished  5.5692991  1.671339287  -24.5613067 2026-02-18 10:57:28  7723
#> 12: finished  9.4659255 -4.325706593  -47.4975413 2026-02-18 10:57:28  7723
#> 13: finished -4.5022012 -3.621611151  -32.6650205 2026-02-18 10:57:28  7723
#> 14: finished  6.4919932  0.400897277  -21.7441056 2026-02-18 10:57:28  7723
#> 15: finished -1.5261497 -0.002130552  -11.4209531 2026-02-18 10:57:28  7723
#> 16: finished  5.2346110 -2.546360991   -0.6684964 2026-02-18 10:57:28  7723
#> 17: finished -8.1469277 -2.532682236  -93.1785285 2026-02-18 10:57:28  7723
#> 18: finished  7.9586287 -3.273955223  -25.5803070 2026-02-18 10:57:28  7723
#> 19: finished  5.3650967 -2.241232399   -1.8996043 2026-02-18 10:57:28  7723
#> 20: finished  4.8743111  3.778382706  -44.2081363 2026-02-18 10:57:28  7723
#>        state         x1           x2            y        timestamp_xs   pid
#>       <char>      <num>        <num>        <num>              <POSc> <int>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>  1: limestone_drever 2026-02-18 10:57:27 a8bc717d-0d56-4def-b6bf-5d042a8e92de
#>  2: limestone_drever 2026-02-18 10:57:28 696ae771-2233-430b-bb1f-8dc5359d7c83
#>  3: limestone_drever 2026-02-18 10:57:28 7a19d07a-41b0-4cc5-be28-de9fd82ff236
#>  4: limestone_drever 2026-02-18 10:57:28 312681a5-2162-4f23-ad72-52f1416a9718
#>  5: limestone_drever 2026-02-18 10:57:28 74914a75-12f9-4f05-bffb-d489fb188f5c
#>  6: limestone_drever 2026-02-18 10:57:28 e2ded024-4ee6-4760-b7e0-e5d0ef5b5647
#>  7: limestone_drever 2026-02-18 10:57:28 a7d7a2b7-6f53-42f2-8d44-ef9e423f5750
#>  8: limestone_drever 2026-02-18 10:57:28 4da4aacd-2c8d-4b32-a763-aec1578b685d
#>  9: limestone_drever 2026-02-18 10:57:28 36a7768e-b4ee-483c-8c49-5286e4bbd179
#> 10: limestone_drever 2026-02-18 10:57:28 50f6a430-b439-4ee6-9b64-554af47a1a6f
#> 11: limestone_drever 2026-02-18 10:57:28 f57df81c-cdf5-4743-85e6-f847bcb11401
#> 12: limestone_drever 2026-02-18 10:57:28 d8e8f5c2-ba64-4435-be0a-b096e8236625
#> 13: limestone_drever 2026-02-18 10:57:28 2cb7277b-9c88-4ef6-9eb6-0cbcf788ff75
#> 14: limestone_drever 2026-02-18 10:57:28 097ca0d0-7f28-40e5-9b08-faf942e38557
#> 15: limestone_drever 2026-02-18 10:57:28 d2b82516-0f69-4053-9495-b89e351b23f7
#> 16: limestone_drever 2026-02-18 10:57:28 4a28e71b-a5c7-4c30-b3f7-ac4252289dba
#> 17: limestone_drever 2026-02-18 10:57:28 038507c9-3138-45ac-ad7f-c7179a961470
#> 18: limestone_drever 2026-02-18 10:57:28 136cd6de-dffc-4d7f-86dd-160ce9490ae8
#> 19: limestone_drever 2026-02-18 10:57:28 25dcb2b8-b1d1-4c2e-9fd9-d541db8afaf0
#> 20: limestone_drever 2026-02-18 10:57:28 d34daf27-8de7-4df9-97f1-305c99e00832
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
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
#>           <num>        <num>
```
