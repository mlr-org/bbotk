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
#>  1: finished -6.21358293  0.2769503  -68.201348 2026-06-09 13:56:31
#>  2: finished -2.62264757  4.2779729  -64.337761 2026-06-09 13:56:31
#>  3: finished  6.84682656  3.2309502  -52.316468 2026-06-09 13:56:31
#>  4: finished -1.96786549 -3.4438612   -5.940969 2026-06-09 13:56:31
#>  5: finished -9.86571338  2.5243351 -161.313432 2026-06-09 13:56:31
#>  6: finished  0.01208465  3.1304511  -31.534238 2026-06-09 13:56:31
#>  7: finished -4.77998488  1.4299587  -55.592729 2026-06-09 13:56:31
#>  8: finished  7.57503606  1.3830058  -40.291767 2026-06-09 13:56:31
#>  9: finished  8.01326577 -2.8537699  -26.180748 2026-06-09 13:56:31
#> 10: finished  5.39871055  2.9134685  -36.520343 2026-06-09 13:56:31
#> 11: finished  4.82894640 -0.2106949   -5.783161 2026-06-09 13:56:31
#> 12: finished  2.92831418 -0.4491262    2.631276 2026-06-09 13:56:31
#> 13: finished -2.48881904  1.6091926  -31.394153 2026-06-09 13:56:31
#> 14: finished  2.11332211  1.0427817   -6.356925 2026-06-09 13:56:31
#> 15: finished  0.87403046  4.3072392  -44.663553 2026-06-09 13:56:31
#> 16: finished -5.88500581 -0.9916228  -56.206896 2026-06-09 13:56:31
#> 17: finished  4.08136954  3.9785972  -43.032918 2026-06-09 13:56:31
#> 18: finished -7.80489880 -3.6260806  -86.528017 2026-06-09 13:56:31
#> 19: finished -9.37102033 -3.4632716 -119.514724 2026-06-09 13:56:31
#> 20: finished  5.22167868  0.7561287  -14.487716 2026-06-09 13:56:31
#>        state          x1         x2           y        timestamp_xs
#>       <char>       <num>      <num>       <num>              <POSc>
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>  1: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#>  2: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#>  3: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#>  4: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#>  5: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#>  6: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#>  7: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#>  8: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#>  9: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#> 10: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#> 11: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#> 12: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#> 13: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#> 14: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#> 15: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#> 16: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#> 17: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#> 18: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#> 19: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#> 20: artsycraftsy_easteuropeanshepherd 2026-06-09 13:56:31
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: b64fd01f-3ee8-49e1-9fb7-5792f6c75c8c -6.21358293   0.2769503
#>  2: 191f6849-5c51-4980-9497-4d426a89029d -2.62264757   4.2779729
#>  3: 4b75b2ed-d93d-40e6-9d55-24b2a4d691fc  6.84682656   3.2309502
#>  4: e981729f-cf88-4b32-93fc-535956edf15f -1.96786549  -3.4438612
#>  5: 61ab748e-f44a-43ca-ae81-1f9802609fe7 -9.86571338   2.5243351
#>  6: 4035c4a9-d8b4-4356-a8b4-370eec599037  0.01208465   3.1304511
#>  7: a9eb89f9-b4b6-494d-8618-eb139dcdb3e8 -4.77998488   1.4299587
#>  8: bfa041b7-8565-465e-a22b-131da0fff46a  7.57503606   1.3830058
#>  9: e9641b18-d262-48c0-a20a-4b9a496db268  8.01326577  -2.8537699
#> 10: 5b3214de-4728-42e7-9938-6037c6da5f9b  5.39871055   2.9134685
#> 11: 2b55f4e7-a1c4-4e33-9076-398e60797794  4.82894640  -0.2106949
#> 12: 7ceaeb2f-3706-4f2e-9517-6e2da6cae8b5  2.92831418  -0.4491262
#> 13: edf274e7-ca90-4bdd-b8ab-13cbda9b963f -2.48881904   1.6091926
#> 14: 1c3a6938-34fa-4d9c-a3ac-7646dccb7c18  2.11332211   1.0427817
#> 15: 234a35f0-ec31-4742-a88e-74a2c232977d  0.87403046   4.3072392
#> 16: 04ac814c-f059-4549-9590-3020ad30d210 -5.88500581  -0.9916228
#> 17: 0235113c-fece-4113-b9e4-e159ee2135ff  4.08136954   3.9785972
#> 18: 942e710b-4e7b-4d7c-ad05-0fec224ed9ee -7.80489880  -3.6260806
#> 19: 9f6a0a3a-8322-4e07-9433-3370615dd6f6 -9.37102033  -3.4632716
#> 20: ae20db34-6247-4f10-8ec0-dadad973180b  5.22167868   0.7561287
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
