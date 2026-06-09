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
rush::rush_plan(worker_type = "mirai")
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
#>        state          x1         x2           y        timestamp_xs
#>       <char>       <num>      <num>       <num>              <POSc>
#>  1: finished -6.21358293  0.2769503  -68.201348 2026-06-09 16:19:48
#>  2: finished -2.62264757  4.2779729  -64.337761 2026-06-09 16:19:48
#>  3: finished  6.84682656  3.2309502  -52.316468 2026-06-09 16:19:48
#>  4: finished -1.96786549 -3.4438612   -5.940969 2026-06-09 16:19:48
#>  5: finished -9.86571338  2.5243351 -161.313432 2026-06-09 16:19:48
#>  6: finished  0.01208465  3.1304511  -31.534238 2026-06-09 16:19:48
#>  7: finished -4.77998488  1.4299587  -55.592729 2026-06-09 16:19:48
#>  8: finished  7.57503606  1.3830058  -40.291767 2026-06-09 16:19:48
#>  9: finished  8.01326577 -2.8537699  -26.180748 2026-06-09 16:19:48
#> 10: finished  5.39871055  2.9134685  -36.520343 2026-06-09 16:19:48
#> 11: finished  4.82894640 -0.2106949   -5.783161 2026-06-09 16:19:48
#> 12: finished  2.92831418 -0.4491262    2.631276 2026-06-09 16:19:48
#> 13: finished -2.48881904  1.6091926  -31.394153 2026-06-09 16:19:48
#> 14: finished  2.11332211  1.0427817   -6.356925 2026-06-09 16:19:48
#> 15: finished  0.87403046  4.3072392  -44.663553 2026-06-09 16:19:48
#> 16: finished -5.88500581 -0.9916228  -56.206896 2026-06-09 16:19:48
#> 17: finished  4.08136954  3.9785972  -43.032918 2026-06-09 16:19:48
#> 18: finished -7.80489880 -3.6260806  -86.528017 2026-06-09 16:19:48
#> 19: finished -9.37102033 -3.4632716 -119.514724 2026-06-09 16:19:49
#> 20: finished  5.22167868  0.7561287  -14.487716 2026-06-09 16:19:49
#>        state          x1         x2           y        timestamp_xs
#>       <char>       <num>      <num>       <num>              <POSc>
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>  1: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:48
#>  2: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:48
#>  3: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:48
#>  4: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:48
#>  5: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:48
#>  6: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:48
#>  7: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:48
#>  8: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:48
#>  9: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:48
#> 10: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:48
#> 11: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:48
#> 12: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:48
#> 13: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:48
#> 14: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:48
#> 15: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:48
#> 16: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:48
#> 17: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:48
#> 18: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:48
#> 19: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:49
#> 20: artsycraftsy_easteuropeanshepherd 2026-06-09 16:19:49
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: eea503d1-f922-419a-ac11-f1bfd6ec755b -6.21358293   0.2769503
#>  2: 7f3894c9-8a95-44aa-8754-72c0bccf65c2 -2.62264757   4.2779729
#>  3: de7d6b8e-b7ce-42b9-852b-8d98afce1811  6.84682656   3.2309502
#>  4: f23b6c3f-f88a-4a11-8e49-cf5919574813 -1.96786549  -3.4438612
#>  5: b4cb0962-1208-40cf-83a6-052c226185fb -9.86571338   2.5243351
#>  6: 9ce66c55-5e50-45c7-9777-0ced85083f97  0.01208465   3.1304511
#>  7: f492b188-bc12-4135-9b20-b2be798f0f3e -4.77998488   1.4299587
#>  8: 97db0bdc-669d-4724-88cd-7f066c1054a8  7.57503606   1.3830058
#>  9: 7c09ed64-0bd4-4d71-a8bd-c79ffec0ffd2  8.01326577  -2.8537699
#> 10: b93583cf-a99f-4c20-8464-959cc2565bcb  5.39871055   2.9134685
#> 11: 3b5a8740-74ba-4b1d-98b4-22ce841606d5  4.82894640  -0.2106949
#> 12: 80913ed1-f882-423b-bcce-b20788aa3c7d  2.92831418  -0.4491262
#> 13: 043be875-7d37-40a6-83ad-cc7104fb7c87 -2.48881904   1.6091926
#> 14: b22e5e98-03f4-485b-9c34-3bf8d94c73a6  2.11332211   1.0427817
#> 15: 6baf961c-53fc-4cb0-9a21-626048e8c63f  0.87403046   4.3072392
#> 16: 5efdc95f-3e2e-4004-9e49-00e5d0fe26d9 -5.88500581  -0.9916228
#> 17: 5fa84c6d-6912-456f-8736-d4ba54d3ed76  4.08136954   3.9785972
#> 18: 404cc11f-f464-4250-a535-20df34b02ede -7.80489880  -3.6260806
#> 19: ada47657-af58-4c63-b243-7b21f9e5118e -9.37102033  -3.4632716
#> 20: 3437c564-502f-4337-9271-7574b6fe361d  5.22167868   0.7561287
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
