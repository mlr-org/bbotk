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

    ArchiveAsyncFrozen$push_points(xss, xss_extra = NULL, extra = NULL)

#### Arguments

- `xss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of point values.

- `xss_extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  List of named lists of additional information.

- `extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  Deprecated argument for additional information. Use `xss_extra`
  instead.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$push_point()`

Push a single queued point to the archive.

#### Usage

    ArchiveAsyncFrozen$push_point(xs, xs_extra = NULL, extra = NULL)

#### Arguments

- `xs`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named list of point values.

- `xs_extra`:

  (named [`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  Named list of additional information.

- `extra`:

  (named [`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  Deprecated argument for additional information. Use `xs_extra`
  instead.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$push_running_points()`

Push running points to the archive.

#### Usage

    ArchiveAsyncFrozen$push_running_points(xss, xss_extra = NULL, extra = NULL)

#### Arguments

- `xss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of point values.

- `xss_extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  List of named lists of additional information.

- `extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  Deprecated argument for additional information. Use `xss_extra`
  instead.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$push_running_point()`

Push running point to the archive.

#### Usage

    ArchiveAsyncFrozen$push_running_point(xs, xs_extra = NULL, extra = NULL)

#### Arguments

- `xs`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named list of point values.

- `xs_extra`:

  (named [`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  Named list of additional information.

- `extra`:

  (named [`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  Deprecated argument for additional information. Use `xs_extra`
  instead.

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

    ArchiveAsyncFrozen$finish_points(
      keys,
      yss,
      x_domains,
      yss_extra = NULL,
      extra = NULL
    )

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

- `extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  Deprecated argument for additional information. Use `yss_extra`
  instead.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$finish_point()`

Save the results of a running point and move it to the finished points.

#### Usage

    ArchiveAsyncFrozen$finish_point(
      key,
      ys,
      x_domain,
      ys_extra = NULL,
      extra = NULL
    )

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

- `extra`:

  (named [`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  Deprecated argument for additional information. Use `ys_extra`
  instead.

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
#>  1: finished -6.21358293  0.2769503  -68.201348 2026-06-26 10:10:40
#>  2: finished -2.62264757  4.2779729  -64.337761 2026-06-26 10:10:40
#>  3: finished  6.84682656  3.2309502  -52.316468 2026-06-26 10:10:40
#>  4: finished -1.96786549 -3.4438612   -5.940969 2026-06-26 10:10:41
#>  5: finished -9.86571338  2.5243351 -161.313432 2026-06-26 10:10:41
#>  6: finished  0.01208465  3.1304511  -31.534238 2026-06-26 10:10:41
#>  7: finished -4.77998488  1.4299587  -55.592729 2026-06-26 10:10:41
#>  8: finished  7.57503606  1.3830058  -40.291767 2026-06-26 10:10:41
#>  9: finished  8.01326577 -2.8537699  -26.180748 2026-06-26 10:10:41
#> 10: finished  5.39871055  2.9134685  -36.520343 2026-06-26 10:10:41
#> 11: finished  4.82894640 -0.2106949   -5.783161 2026-06-26 10:10:41
#> 12: finished  2.92831418 -0.4491262    2.631276 2026-06-26 10:10:41
#> 13: finished -2.48881904  1.6091926  -31.394153 2026-06-26 10:10:41
#> 14: finished  2.11332211  1.0427817   -6.356925 2026-06-26 10:10:41
#> 15: finished  0.87403046  4.3072392  -44.663553 2026-06-26 10:10:41
#> 16: finished -5.88500581 -0.9916228  -56.206896 2026-06-26 10:10:41
#> 17: finished  4.08136954  3.9785972  -43.032918 2026-06-26 10:10:41
#> 18: finished -7.80489880 -3.6260806  -86.528017 2026-06-26 10:10:41
#> 19: finished -9.37102033 -3.4632716 -119.514724 2026-06-26 10:10:41
#> 20: finished  5.22167868  0.7561287  -14.487716 2026-06-26 10:10:41
#>        state          x1         x2           y        timestamp_xs
#>       <char>       <num>      <num>       <num>              <POSc>
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>  1: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:40
#>  2: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:40
#>  3: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:41
#>  4: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:41
#>  5: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:41
#>  6: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:41
#>  7: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:41
#>  8: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:41
#>  9: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:41
#> 10: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:41
#> 11: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:41
#> 12: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:41
#> 13: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:41
#> 14: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:41
#> 15: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:41
#> 16: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:41
#> 17: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:41
#> 18: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:41
#> 19: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:41
#> 20: artsycraftsy_easteuropeanshepherd 2026-06-26 10:10:41
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 09158883-71aa-4a98-92c7-f7108771a4c6 -6.21358293   0.2769503
#>  2: cc09b53d-7a29-40bf-bce5-bdcdd158f1d1 -2.62264757   4.2779729
#>  3: 7b2c4957-2be8-415b-bd7f-8fccdd8184d9  6.84682656   3.2309502
#>  4: bbd168bf-a532-4b60-8ed6-2953e8f13a4f -1.96786549  -3.4438612
#>  5: 72cd2a2c-e2d5-4965-bbe2-220fb516dbee -9.86571338   2.5243351
#>  6: 17ed363c-4c36-4a07-9997-705dd0e77afb  0.01208465   3.1304511
#>  7: 1f56dd02-4e16-417a-8e63-04ac6ffb4521 -4.77998488   1.4299587
#>  8: 0ddf2291-d113-4fc5-b374-3c9d2409b22d  7.57503606   1.3830058
#>  9: bfda744d-8ff9-444c-9b89-9c213e226b76  8.01326577  -2.8537699
#> 10: 686e8905-e302-4d34-8b40-5c6812573797  5.39871055   2.9134685
#> 11: c0d7ca47-fc55-45bb-b58a-e1e60873c252  4.82894640  -0.2106949
#> 12: 3452d960-d9a9-48a7-b515-d6f645643dc6  2.92831418  -0.4491262
#> 13: 860f5a8b-1ec4-4a1a-865b-adb48c1d61c9 -2.48881904   1.6091926
#> 14: bb07b740-2432-41ab-a3df-bb53a6cfcc5c  2.11332211   1.0427817
#> 15: 963314e8-b2fe-40b8-aeec-3be98b668953  0.87403046   4.3072392
#> 16: 14e03706-c37b-43da-9919-524e9b3b263d -5.88500581  -0.9916228
#> 17: c5b68a50-3603-4e88-a2f0-889980d0fb62  4.08136954   3.9785972
#> 18: aaed550b-6735-40a4-bb4d-8974f1e3627c -7.80489880  -3.6260806
#> 19: 8ac18a36-c14c-4e9a-a77e-0b42242df765 -9.37102033  -3.4632716
#> 20: 5b1e719d-02ec-4279-81c8-344a008d7ade  5.22167868   0.7561287
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
