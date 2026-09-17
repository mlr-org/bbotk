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

- [`ArchiveAsyncFrozen$push_point()`](#method-ArchiveAsyncFrozen-push_point)

- [`ArchiveAsyncFrozen$push_running_points()`](#method-ArchiveAsyncFrozen-push_running_points)

- [`ArchiveAsyncFrozen$push_running_point()`](#method-ArchiveAsyncFrozen-push_running_point)

- [`ArchiveAsyncFrozen$push_finished_points()`](#method-ArchiveAsyncFrozen-push_finished_points)

- [`ArchiveAsyncFrozen$push_finished_point()`](#method-ArchiveAsyncFrozen-push_finished_point)

- [`ArchiveAsyncFrozen$push_failed_points()`](#method-ArchiveAsyncFrozen-push_failed_points)

- [`ArchiveAsyncFrozen$push_failed_point()`](#method-ArchiveAsyncFrozen-push_failed_point)

- [`ArchiveAsyncFrozen$pop_point()`](#method-ArchiveAsyncFrozen-pop_point)

- [`ArchiveAsyncFrozen$finish_points()`](#method-ArchiveAsyncFrozen-finish_points)

- [`ArchiveAsyncFrozen$finish_point()`](#method-ArchiveAsyncFrozen-finish_point)

- [`ArchiveAsyncFrozen$fail_points()`](#method-ArchiveAsyncFrozen-fail_points)

- [`ArchiveAsyncFrozen$fail_point()`](#method-ArchiveAsyncFrozen-fail_point)

- [`ArchiveAsyncFrozen$push_result()`](#method-ArchiveAsyncFrozen-push_result)

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

    ArchiveAsyncFrozen$push_points(xss, xss_extra = NULL, profile = NULL)

#### Arguments

- `xss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of point values.

- `xss_extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  List of named lists of additional information.

- `profile`:

  (`character(1)` \| `NULL`)  
  Name of the [mirai](https://CRAN.R-project.org/package=mirai) compute
  profile the points are queued for.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$push_point()`

Push a single queued point to the archive.

#### Usage

    ArchiveAsyncFrozen$push_point(xs, xs_extra = NULL, profile = NULL)

#### Arguments

- `xs`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named list of point values.

- `xs_extra`:

  (named [`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  Named list of additional information.

- `profile`:

  (`character(1)` \| `NULL`)  
  Name of the [mirai](https://CRAN.R-project.org/package=mirai) compute
  profile the point is queued for.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$push_running_points()`

Push running points to the archive.

#### Usage

    ArchiveAsyncFrozen$push_running_points(xss, xss_extra = NULL)

#### Arguments

- `xss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of point values.

- `xss_extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  List of named lists of additional information.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$push_running_point()`

Push running point to the archive.

#### Usage

    ArchiveAsyncFrozen$push_running_point(xs, xs_extra = NULL)

#### Arguments

- `xs`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named list of point values.

- `xs_extra`:

  (named [`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  Named list of additional information.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$push_finished_points()`

Push finished points to the archive.

#### Usage

    ArchiveAsyncFrozen$push_finished_points(
      xss,
      yss,
      xss_extra = NULL,
      yss_extra = NULL
    )

#### Arguments

- `xss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of point values.

- `yss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of results.

- `xss_extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  List of named lists of additional information.

- `yss_extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  List of named lists of additional information.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$push_finished_point()`

Push a single finished point to the archive.

#### Usage

    ArchiveAsyncFrozen$push_finished_point(
      xs,
      ys,
      xs_extra = NULL,
      ys_extra = NULL
    )

#### Arguments

- `xs`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named list of point values.

- `ys`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named list of results.

- `xs_extra`:

  (`named list()` \| `NULL`)  
  Named list of additional information.

- `ys_extra`:

  (`named list()` \| `NULL`)  
  Named list of additional information.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$push_failed_points()`

Push failed points to the archive.

#### Usage

    ArchiveAsyncFrozen$push_failed_points(xss, xss_extra = NULL, conditions = NULL)

#### Arguments

- `xss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of point values.

- `xss_extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  List of named lists of additional information.

- `conditions`:

  (`list` \| `NULL`)  
  List of conditions for each failed point. If `NULL`, a generic error
  message is used.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$push_failed_point()`

Push a single failed point to the archive.

#### Usage

    ArchiveAsyncFrozen$push_failed_point(xs, xs_extra = NULL, condition = NULL)

#### Arguments

- `xs`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named list of point values.

- `xs_extra`:

  (`named list()` \| `NULL`)  
  Named list of additional information.

- `condition`:

  (`any` \| `NULL`)  
  Condition of the failed point. If `NULL`, a generic error message is
  used.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$pop_point()`

Pop a point from the queue.

#### Usage

    ArchiveAsyncFrozen$pop_point()

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$finish_points()`

Save the results of multiple running points and move them to the
finished points.

#### Usage

    ArchiveAsyncFrozen$finish_points(keys, yss, x_domains, yss_extra = NULL)

#### Arguments

- `keys`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Keys of the points.

- `yss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of results.

- `x_domains`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of transformed point values.

- `yss_extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  List of named lists of additional information.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$finish_point()`

Save the results of a running point and move it to the finished points.

#### Usage

    ArchiveAsyncFrozen$finish_point(key, ys, x_domain, ys_extra = NULL)

#### Arguments

- `key`:

  (`character(1)`)  
  Key of the point.

- `ys`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named list of results.

- `x_domain`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named list of transformed point values.

- `ys_extra`:

  (named [`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  Named list of additional information.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$fail_points()`

Move multiple running points to the failed points.

#### Usage

    ArchiveAsyncFrozen$fail_points(keys, conditions = NULL)

#### Arguments

- `keys`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Keys of the points.

- `conditions`:

  ([`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  Conditions of the failed points.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$fail_point()`

Move a running point to the failed points.

#### Usage

    ArchiveAsyncFrozen$fail_point(key, condition = NULL)

#### Arguments

- `key`:

  (`character(1)`)  
  Key of the point.

- `condition`:

  (`any` \| `NULL`)  
  Condition of the failed point.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$push_result()`

Deprecated. Use `$finish_point()` instead.

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
#>  1: finished -6.21358293  0.2769503  -68.201348 2026-09-17 08:17:48
#>  2: finished -2.62264757  4.2779729  -64.337761 2026-09-17 08:17:48
#>  3: finished  6.84682656  3.2309502  -52.316468 2026-09-17 08:17:48
#>  4: finished -1.96786549 -3.4438612   -5.940969 2026-09-17 08:17:48
#>  5: finished -9.86571338  2.5243351 -161.313432 2026-09-17 08:17:48
#>  6: finished  0.01208465  3.1304511  -31.534238 2026-09-17 08:17:48
#>  7: finished -4.77998488  1.4299587  -55.592729 2026-09-17 08:17:48
#>  8: finished  7.57503606  1.3830058  -40.291767 2026-09-17 08:17:48
#>  9: finished  8.01326577 -2.8537699  -26.180748 2026-09-17 08:17:48
#> 10: finished  5.39871055  2.9134685  -36.520343 2026-09-17 08:17:48
#> 11: finished  4.82894640 -0.2106949   -5.783161 2026-09-17 08:17:48
#> 12: finished  2.92831418 -0.4491262    2.631276 2026-09-17 08:17:48
#> 13: finished -2.48881904  1.6091926  -31.394153 2026-09-17 08:17:48
#> 14: finished  2.11332211  1.0427817   -6.356925 2026-09-17 08:17:48
#> 15: finished  0.87403046  4.3072392  -44.663553 2026-09-17 08:17:48
#> 16: finished -5.88500581 -0.9916228  -56.206896 2026-09-17 08:17:48
#> 17: finished  4.08136954  3.9785972  -43.032918 2026-09-17 08:17:48
#> 18: finished -7.80489880 -3.6260806  -86.528017 2026-09-17 08:17:48
#> 19: finished -9.37102033 -3.4632716 -119.514724 2026-09-17 08:17:48
#> 20: finished  5.22167868  0.7561287  -14.487716 2026-09-17 08:17:48
#>        state          x1         x2           y        timestamp_xs
#>       <char>       <num>      <num>       <num>              <POSc>
#>                                      worker_id        timestamp_ys
#>                                         <char>              <POSc>
#>  1: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#>  2: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#>  3: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#>  4: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#>  5: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#>  6: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#>  7: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#>  8: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#>  9: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#> 10: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#> 11: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#> 12: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#> 13: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#> 14: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#> 15: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#> 16: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#> 17: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#> 18: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#> 19: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#> 20: artsycraftsy_easteuropeanshepherd_26c6df57 2026-09-17 08:17:48
#>                                      worker_id        timestamp_ys
#>                                         <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: ba2a7e2f-0b3d-4c9d-a2e9-156f47cf2bb7 -6.21358293   0.2769503
#>  2: c75fb20f-0f0a-4103-a1a9-3ca310a08fdd -2.62264757   4.2779729
#>  3: 682a139a-83c4-4e89-9131-ffb16af75588  6.84682656   3.2309502
#>  4: c3252553-39ca-455e-91cd-c245f90ca15d -1.96786549  -3.4438612
#>  5: d3dbabab-83cd-4243-806e-8231e5aba2f8 -9.86571338   2.5243351
#>  6: 8f7cf6b8-71a3-461a-81e8-63524413bea9  0.01208465   3.1304511
#>  7: 312cc275-d8b2-4c88-b434-a20736ca65ef -4.77998488   1.4299587
#>  8: ddd20642-5ce8-461a-9233-5e6ebcd06f00  7.57503606   1.3830058
#>  9: 2d8f4a12-9803-477f-90be-01bff85a1a68  8.01326577  -2.8537699
#> 10: 96a618eb-d2fe-4c7d-b806-c6aa5df445a4  5.39871055   2.9134685
#> 11: aaa4fb47-614f-4540-b313-50e90e672b8b  4.82894640  -0.2106949
#> 12: a8c1b604-ff76-4caf-ab59-8f4088b8a153  2.92831418  -0.4491262
#> 13: 196bf541-8940-477e-b559-f2749e9ff2d8 -2.48881904   1.6091926
#> 14: 1036c396-44bc-44dd-9d46-34f2873da768  2.11332211   1.0427817
#> 15: 30165cd4-3ee7-4ecb-9faf-5bba13e3eb26  0.87403046   4.3072392
#> 16: 9dd81234-cc98-4e14-8fbc-03e76490b9d0 -5.88500581  -0.9916228
#> 17: 3ae0285f-5fa8-4778-9caa-a0e0e3e27bfe  4.08136954   3.9785972
#> 18: 9eafb4e8-fc3b-4f4a-9f99-14ededce732c -7.80489880  -3.6260806
#> 19: 589fe5fe-669a-4244-90a2-b43e049880f9 -9.37102033  -3.4632716
#> 20: 2a290edb-c592-4a98-99cc-d34ea91cec30  5.22167868   0.7561287
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
