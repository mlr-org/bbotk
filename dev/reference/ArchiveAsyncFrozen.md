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

    ArchiveAsyncFrozen$push_points(xss, xss_extra = NULL)

#### Arguments

- `xss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of point values.

- `xss_extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  List of named lists of additional information.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$push_point()`

Push a single queued point to the archive.

#### Usage

    ArchiveAsyncFrozen$push_point(xs, xs_extra = NULL)

#### Arguments

- `xs`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named list of point values.

- `xs_extra`:

  (named [`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  Named list of additional information.

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
#>  1: finished -6.21358293  0.2769503  -68.201348 2026-07-24 14:14:00
#>  2: finished -2.62264757  4.2779729  -64.337761 2026-07-24 14:14:01
#>  3: finished  6.84682656  3.2309502  -52.316468 2026-07-24 14:14:01
#>  4: finished -1.96786549 -3.4438612   -5.940969 2026-07-24 14:14:01
#>  5: finished -9.86571338  2.5243351 -161.313432 2026-07-24 14:14:01
#>  6: finished  0.01208465  3.1304511  -31.534238 2026-07-24 14:14:01
#>  7: finished -4.77998488  1.4299587  -55.592729 2026-07-24 14:14:01
#>  8: finished  7.57503606  1.3830058  -40.291767 2026-07-24 14:14:01
#>  9: finished  8.01326577 -2.8537699  -26.180748 2026-07-24 14:14:01
#> 10: finished  5.39871055  2.9134685  -36.520343 2026-07-24 14:14:01
#> 11: finished  4.82894640 -0.2106949   -5.783161 2026-07-24 14:14:01
#> 12: finished  2.92831418 -0.4491262    2.631276 2026-07-24 14:14:01
#> 13: finished -2.48881904  1.6091926  -31.394153 2026-07-24 14:14:01
#> 14: finished  2.11332211  1.0427817   -6.356925 2026-07-24 14:14:01
#> 15: finished  0.87403046  4.3072392  -44.663553 2026-07-24 14:14:01
#> 16: finished -5.88500581 -0.9916228  -56.206896 2026-07-24 14:14:01
#> 17: finished  4.08136954  3.9785972  -43.032918 2026-07-24 14:14:01
#> 18: finished -7.80489880 -3.6260806  -86.528017 2026-07-24 14:14:01
#> 19: finished -9.37102033 -3.4632716 -119.514724 2026-07-24 14:14:01
#> 20: finished  5.22167868  0.7561287  -14.487716 2026-07-24 14:14:01
#>        state          x1         x2           y        timestamp_xs
#>       <char>       <num>      <num>       <num>              <POSc>
#>                                      worker_id        timestamp_ys
#>                                         <char>              <POSc>
#>  1: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:00
#>  2: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#>  3: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#>  4: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#>  5: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#>  6: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#>  7: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#>  8: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#>  9: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#> 10: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#> 11: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#> 12: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#> 13: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#> 14: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#> 15: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#> 16: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#> 17: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#> 18: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#> 19: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#> 20: artsycraftsy_easteuropeanshepherd_a8e0ba31 2026-07-24 14:14:01
#>                                      worker_id        timestamp_ys
#>                                         <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: cd21360b-1256-4a9d-aa03-0edb0204f2c9 -6.21358293   0.2769503
#>  2: abf3cbd3-5446-401b-bff7-002434e31692 -2.62264757   4.2779729
#>  3: b8ce4023-d1bd-4777-9dca-f26484f013c2  6.84682656   3.2309502
#>  4: 931d29c8-51a0-4ba0-9525-72c50a3808e0 -1.96786549  -3.4438612
#>  5: 94e077bc-7823-42bb-a8c8-ef4cea9b17c2 -9.86571338   2.5243351
#>  6: 53aebb2d-6fe1-4faf-bdbb-2f447e072cda  0.01208465   3.1304511
#>  7: 9cfdf394-1158-4787-bc68-ffb08023a4ea -4.77998488   1.4299587
#>  8: 15afdaa9-1e43-497e-93ee-514817a4b606  7.57503606   1.3830058
#>  9: e52340db-02b7-4eba-b804-e47383f75ca2  8.01326577  -2.8537699
#> 10: 3903e500-2c58-4294-84c3-814217dbe55b  5.39871055   2.9134685
#> 11: 9d4007b6-3384-4747-b556-2e7060549e92  4.82894640  -0.2106949
#> 12: 5bf9a5cd-f051-45f3-80fa-12987cc68e86  2.92831418  -0.4491262
#> 13: c1ee080f-ddab-4f29-aa53-299242c05995 -2.48881904   1.6091926
#> 14: 239b9940-db38-4dc2-84b2-7ccca8c5e945  2.11332211   1.0427817
#> 15: a7b6324c-0f5f-4b6c-b875-3705ee8956be  0.87403046   4.3072392
#> 16: 41c26256-74cb-4d80-853f-370bf44bd2a6 -5.88500581  -0.9916228
#> 17: 6c47fc8a-460e-48ab-9315-384586b9d475  4.08136954   3.9785972
#> 18: 36e2e810-c390-4b32-9f3f-ee90a4b71a1f -7.80489880  -3.6260806
#> 19: c6c87255-fb5b-4d6a-8709-a402abb938c6 -9.37102033  -3.4632716
#> 20: e7034fd0-81a0-4d6e-ac65-49f4af3895e1  5.22167868   0.7561287
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
