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

[`Archive`](https://bbotk.mlr-org.com/dev/reference/Archive.md) -\>
[`ArchiveAsync`](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.md)
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

- [`ArchiveAsyncFrozen$new()`](#method-ArchiveAsyncFrozen-initialize)

- [`ArchiveAsyncFrozen$push_points()`](#method-ArchiveAsyncFrozen-push_points)

- [`ArchiveAsyncFrozen$pop_point()`](#method-ArchiveAsyncFrozen-pop_point)

- [`ArchiveAsyncFrozen$push_running_point()`](#method-ArchiveAsyncFrozen-push_running_point)

- [`ArchiveAsyncFrozen$push_result()`](#method-ArchiveAsyncFrozen-push_result)

- [`ArchiveAsyncFrozen$push_failed_point()`](#method-ArchiveAsyncFrozen-push_failed_point)

- [`ArchiveAsyncFrozen$data_with_state()`](#method-ArchiveAsyncFrozen-data_with_state)

- [`ArchiveAsyncFrozen$clear()`](#method-ArchiveAsyncFrozen-clear)

- [`ArchiveAsyncFrozen$clone()`](#method-ArchiveAsyncFrozen-clone)

Inherited methods

- [`Archive$format()`](https://bbotk.mlr-org.com/dev/reference/Archive.html#method-format)
- [`Archive$help()`](https://bbotk.mlr-org.com/dev/reference/Archive.html#method-help)
- [`Archive$print()`](https://bbotk.mlr-org.com/dev/reference/Archive.html#method-print)
- [`ArchiveAsync$best()`](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.html#method-best)
- [`ArchiveAsync$nds_selection()`](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.html#method-nds_selection)

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    ArchiveAsyncFrozen$new(archive)

#### Arguments

- `archive`:

  ([ArchiveAsync](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.md))  
  The archive to freeze.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$push_points()`

Push queued points to the archive.

#### Usage

    ArchiveAsyncFrozen$push_points(xss)

#### Arguments

- `xss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of point values.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$pop_point()`

Pop a point from the queue.

#### Usage

    ArchiveAsyncFrozen$pop_point()

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$push_running_point()`

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

### `ArchiveAsyncFrozen$push_result()`

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

### `ArchiveAsyncFrozen$push_failed_point()`

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

### `ArchiveAsyncFrozen$data_with_state()`

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

### `ArchiveAsyncFrozen$clear()`

Clear all evaluation results from archive.

#### Usage

    ArchiveAsyncFrozen$clear()

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$clone()`

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
#>  1: finished -6.21358293  0.2769503  -68.201348 2026-06-10 12:39:14
#>  2: finished -2.62264757  4.2779729  -64.337761 2026-06-10 12:39:14
#>  3: finished  6.84682656  3.2309502  -52.316468 2026-06-10 12:39:15
#>  4: finished -1.96786549 -3.4438612   -5.940969 2026-06-10 12:39:15
#>  5: finished -9.86571338  2.5243351 -161.313432 2026-06-10 12:39:15
#>  6: finished  0.01208465  3.1304511  -31.534238 2026-06-10 12:39:15
#>  7: finished -4.77998488  1.4299587  -55.592729 2026-06-10 12:39:15
#>  8: finished  7.57503606  1.3830058  -40.291767 2026-06-10 12:39:15
#>  9: finished  8.01326577 -2.8537699  -26.180748 2026-06-10 12:39:15
#> 10: finished  5.39871055  2.9134685  -36.520343 2026-06-10 12:39:15
#> 11: finished  4.82894640 -0.2106949   -5.783161 2026-06-10 12:39:15
#> 12: finished  2.92831418 -0.4491262    2.631276 2026-06-10 12:39:15
#> 13: finished -2.48881904  1.6091926  -31.394153 2026-06-10 12:39:15
#> 14: finished  2.11332211  1.0427817   -6.356925 2026-06-10 12:39:15
#> 15: finished  0.87403046  4.3072392  -44.663553 2026-06-10 12:39:15
#> 16: finished -5.88500581 -0.9916228  -56.206896 2026-06-10 12:39:15
#> 17: finished  4.08136954  3.9785972  -43.032918 2026-06-10 12:39:15
#> 18: finished -7.80489880 -3.6260806  -86.528017 2026-06-10 12:39:15
#> 19: finished -9.37102033 -3.4632716 -119.514724 2026-06-10 12:39:15
#> 20: finished  5.22167868  0.7561287  -14.487716 2026-06-10 12:39:15
#>        state          x1         x2           y        timestamp_xs
#>       <char>       <num>      <num>       <num>              <POSc>
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>  1: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:14
#>  2: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:14
#>  3: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:15
#>  4: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:15
#>  5: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:15
#>  6: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:15
#>  7: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:15
#>  8: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:15
#>  9: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:15
#> 10: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:15
#> 11: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:15
#> 12: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:15
#> 13: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:15
#> 14: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:15
#> 15: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:15
#> 16: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:15
#> 17: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:15
#> 18: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:15
#> 19: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:15
#> 20: artsycraftsy_easteuropeanshepherd 2026-06-10 12:39:15
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: d4eb34ac-4082-4d28-bc43-95e6350e110b -6.21358293   0.2769503
#>  2: 4d9fa661-c636-478b-932c-4cf983a1b2a8 -2.62264757   4.2779729
#>  3: bf5bd6e2-8d0d-4186-bd7c-544aebe90231  6.84682656   3.2309502
#>  4: 0c733d22-c29a-42c1-bc32-0a9147192703 -1.96786549  -3.4438612
#>  5: 5e9b74c0-3a2d-40f6-8d62-4b0a566474ea -9.86571338   2.5243351
#>  6: 3d1a8734-6d27-4c49-b72a-d4019b1c109a  0.01208465   3.1304511
#>  7: 4cef2ee9-7d55-43f3-8ef1-05a1c639b6e0 -4.77998488   1.4299587
#>  8: 73ebfa15-4edf-4d51-a66f-49dd1be3bb82  7.57503606   1.3830058
#>  9: 01115be8-6af5-469c-bbd0-6042a0184244  8.01326577  -2.8537699
#> 10: 2627fde9-6ff9-4293-a5e1-06226e0a14a5  5.39871055   2.9134685
#> 11: 1a57f7b0-894a-4c1c-bd51-7e41143255aa  4.82894640  -0.2106949
#> 12: 17b27641-ed6f-41b5-a841-da87320e16fd  2.92831418  -0.4491262
#> 13: c0a40e04-6424-4145-ac12-be18e0424508 -2.48881904   1.6091926
#> 14: 3e0a66de-d8e6-4429-a4d1-7fea821884fe  2.11332211   1.0427817
#> 15: 56068950-7eae-4c5c-b99a-c674186c8d84  0.87403046   4.3072392
#> 16: d4e75bc3-1e39-490c-9d7c-ffccb55e8868 -5.88500581  -0.9916228
#> 17: 2dfddfa0-2dfe-4177-8dce-b9772b47aad0  4.08136954   3.9785972
#> 18: 44170aa9-4731-435a-9e52-0582f558d33b -7.80489880  -3.6260806
#> 19: 1e689d87-4c83-4b84-b4ca-69b395a749a5 -9.37102033  -3.4632716
#> 20: 28ecff0d-423f-49e1-a3fb-5dab8efac019  5.22167868   0.7561287
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
