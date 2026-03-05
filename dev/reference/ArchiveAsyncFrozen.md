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
#>  1: finished  0.7355865  4.436809312  -46.9048744 2026-03-05 09:11:47  7854
#>  2: finished -5.2465150  1.685353492  -64.4645163 2026-03-05 09:11:47  7854
#>  3: finished -1.6100269  1.692733854  -25.0540453 2026-03-05 09:11:47  7854
#>  4: finished -9.6485851  2.074896538 -151.4441090 2026-03-05 09:11:47  7854
#>  5: finished  9.1534135  0.636737862  -54.3971877 2026-03-05 09:11:47  7854
#>  6: finished -0.9507994 -4.878603549   -2.2363683 2026-03-05 09:11:47  7854
#>  7: finished  2.7997505 -1.921276769    8.1967553 2026-03-05 09:11:47  7854
#>  8: finished  7.9367603  3.130829856  -62.8321976 2026-03-05 09:11:47  7854
#>  9: finished -5.3535132  0.132857377  -53.8889510 2026-03-05 09:11:47  7854
#> 10: finished -1.1703927  1.581480915  -21.0413571 2026-03-05 09:11:47  7854
#> 11: finished  5.5692991  1.671339287  -24.5613067 2026-03-05 09:11:48  7854
#> 12: finished  9.4659255 -4.325706593  -47.4975413 2026-03-05 09:11:48  7854
#> 13: finished -4.5022012 -3.621611151  -32.6650205 2026-03-05 09:11:48  7854
#> 14: finished  6.4919932  0.400897277  -21.7441056 2026-03-05 09:11:48  7854
#> 15: finished -1.5261497 -0.002130552  -11.4209531 2026-03-05 09:11:48  7854
#> 16: finished  5.2346110 -2.546360991   -0.6684964 2026-03-05 09:11:48  7854
#> 17: finished -8.1469277 -2.532682236  -93.1785285 2026-03-05 09:11:48  7854
#> 18: finished  7.9586287 -3.273955223  -25.5803070 2026-03-05 09:11:48  7854
#> 19: finished  5.3650967 -2.241232399   -1.8996043 2026-03-05 09:11:48  7854
#> 20: finished  4.8743111  3.778382706  -44.2081363 2026-03-05 09:11:48  7854
#>        state         x1           x2            y        timestamp_xs   pid
#>       <char>      <num>        <num>        <num>              <POSc> <int>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>  1: limestone_drever 2026-03-05 09:11:47 8e650ed0-0324-4e5d-986b-c909c6d11f00
#>  2: limestone_drever 2026-03-05 09:11:47 d88c9875-0428-4da4-8911-51400278b08f
#>  3: limestone_drever 2026-03-05 09:11:47 6b1a48db-99d7-4d52-b677-af4b09f2bfd6
#>  4: limestone_drever 2026-03-05 09:11:47 ac3273b8-33bc-485e-9563-ccedbf9e085c
#>  5: limestone_drever 2026-03-05 09:11:47 aa7a8f9b-a7b4-4777-98dd-12a687d7d526
#>  6: limestone_drever 2026-03-05 09:11:47 78c387f7-1e53-4f95-bed5-6c5fbaec2605
#>  7: limestone_drever 2026-03-05 09:11:47 19bcf47b-5e1a-4170-9756-dc69d6b9dfcb
#>  8: limestone_drever 2026-03-05 09:11:47 bc67f8a9-490a-4b29-8470-6920c79a3afc
#>  9: limestone_drever 2026-03-05 09:11:47 bc67a1d5-8d0f-4a50-b8d0-432c0fad0658
#> 10: limestone_drever 2026-03-05 09:11:47 125dcb38-87d6-4bf3-aaef-5c1a47f5db29
#> 11: limestone_drever 2026-03-05 09:11:48 dad5e5c5-22a1-4945-a9bf-618851236e6b
#> 12: limestone_drever 2026-03-05 09:11:48 62f79e60-894c-4dac-bfaa-b0223a2f956c
#> 13: limestone_drever 2026-03-05 09:11:48 b299c4b7-7905-4a62-883b-a870c55a1a96
#> 14: limestone_drever 2026-03-05 09:11:48 54924e08-39ef-42c7-b81e-31803e79cf74
#> 15: limestone_drever 2026-03-05 09:11:48 f4a54dd5-f4ff-47b7-881f-ceaaa54fb36c
#> 16: limestone_drever 2026-03-05 09:11:48 dd9b5ce6-7366-4c4b-b9f3-5efe6f79ebb9
#> 17: limestone_drever 2026-03-05 09:11:48 64c8329c-c396-4e09-a0b8-44d5ac579e6f
#> 18: limestone_drever 2026-03-05 09:11:48 06278176-a3ae-4e80-8ca9-5c31a690b464
#> 19: limestone_drever 2026-03-05 09:11:48 4f213294-c868-4a4f-a9f5-4909eeef8acb
#> 20: limestone_drever 2026-03-05 09:11:48 b395bf63-49e2-4df9-9ed6-635230d5a738
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
