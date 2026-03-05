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
#>  1: finished  0.7355865  4.436809312  -46.9048744 2026-03-05 08:52:03  7825
#>  2: finished -5.2465150  1.685353492  -64.4645163 2026-03-05 08:52:03  7825
#>  3: finished -1.6100269  1.692733854  -25.0540453 2026-03-05 08:52:03  7825
#>  4: finished -9.6485851  2.074896538 -151.4441090 2026-03-05 08:52:03  7825
#>  5: finished  9.1534135  0.636737862  -54.3971877 2026-03-05 08:52:03  7825
#>  6: finished -0.9507994 -4.878603549   -2.2363683 2026-03-05 08:52:03  7825
#>  7: finished  2.7997505 -1.921276769    8.1967553 2026-03-05 08:52:03  7825
#>  8: finished  7.9367603  3.130829856  -62.8321976 2026-03-05 08:52:03  7825
#>  9: finished -5.3535132  0.132857377  -53.8889510 2026-03-05 08:52:03  7825
#> 10: finished -1.1703927  1.581480915  -21.0413571 2026-03-05 08:52:03  7825
#> 11: finished  5.5692991  1.671339287  -24.5613067 2026-03-05 08:52:03  7825
#> 12: finished  9.4659255 -4.325706593  -47.4975413 2026-03-05 08:52:04  7825
#> 13: finished -4.5022012 -3.621611151  -32.6650205 2026-03-05 08:52:04  7825
#> 14: finished  6.4919932  0.400897277  -21.7441056 2026-03-05 08:52:04  7825
#> 15: finished -1.5261497 -0.002130552  -11.4209531 2026-03-05 08:52:04  7825
#> 16: finished  5.2346110 -2.546360991   -0.6684964 2026-03-05 08:52:04  7825
#> 17: finished -8.1469277 -2.532682236  -93.1785285 2026-03-05 08:52:04  7825
#> 18: finished  7.9586287 -3.273955223  -25.5803070 2026-03-05 08:52:04  7825
#> 19: finished  5.3650967 -2.241232399   -1.8996043 2026-03-05 08:52:04  7825
#> 20: finished  4.8743111  3.778382706  -44.2081363 2026-03-05 08:52:04  7825
#>        state         x1           x2            y        timestamp_xs   pid
#>       <char>      <num>        <num>        <num>              <POSc> <int>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>  1: limestone_drever 2026-03-05 08:52:03 95d596b5-4366-480b-8b02-42206ac1ba1f
#>  2: limestone_drever 2026-03-05 08:52:03 7dfd5a5d-c38b-4737-b7ff-51b2b771df6c
#>  3: limestone_drever 2026-03-05 08:52:03 4bfd04cd-624d-493a-8d70-f87f982b93b7
#>  4: limestone_drever 2026-03-05 08:52:03 f9569be6-7103-4eea-96cc-838555278313
#>  5: limestone_drever 2026-03-05 08:52:03 469d3409-4835-49de-94f0-edc76e402a6c
#>  6: limestone_drever 2026-03-05 08:52:03 3c0c6241-ed56-4cb2-b8a5-b4844d28b9bf
#>  7: limestone_drever 2026-03-05 08:52:03 0b956b5b-42cf-4eca-b91c-2acc5bce2192
#>  8: limestone_drever 2026-03-05 08:52:03 842d52c1-b755-4488-9d67-d034db9b9aba
#>  9: limestone_drever 2026-03-05 08:52:03 9af38a47-8f8a-4830-814c-cb70851341e4
#> 10: limestone_drever 2026-03-05 08:52:03 7a2b5cf3-697b-402b-847d-decd5ccc00dc
#> 11: limestone_drever 2026-03-05 08:52:03 7d489287-be8a-4aff-a382-3d03d9ae2fcf
#> 12: limestone_drever 2026-03-05 08:52:04 533ec45e-acd8-4066-aef9-630202b327d9
#> 13: limestone_drever 2026-03-05 08:52:04 613f54cc-4e38-4f82-892d-6ddf60dd0cfa
#> 14: limestone_drever 2026-03-05 08:52:04 410df28b-3671-45e8-b4c0-3b4e0b981789
#> 15: limestone_drever 2026-03-05 08:52:04 ad00813f-e7dc-4f9d-8a64-0b13fd1d2549
#> 16: limestone_drever 2026-03-05 08:52:04 92644bb0-9c64-44ab-a750-eeb12b93dbfc
#> 17: limestone_drever 2026-03-05 08:52:04 5419dbfa-7b90-4e03-a654-d0505f87cf7a
#> 18: limestone_drever 2026-03-05 08:52:04 634a4610-8c20-4f2d-9397-cd252b4f0d68
#> 19: limestone_drever 2026-03-05 08:52:04 6cd4ff1d-9ceb-4f02-8bd6-465adef6a43b
#> 20: limestone_drever 2026-03-05 08:52:04 6cee21e3-62f1-429a-8e62-71d6fea48c55
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
