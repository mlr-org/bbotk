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
#>        state          x1          x2           y        timestamp_xs
#>       <char>       <num>       <num>       <num>              <POSc>
#>  1: finished  0.79964108  4.44173718  -46.820314 2026-04-08 06:05:36
#>  2: finished  1.97171934  0.98977706   -5.919121 2026-04-08 06:05:36
#>  3: finished -8.74678495  2.85974125 -139.829954 2026-04-08 06:05:36
#>  4: finished -8.86620125 -0.52683197 -114.190890 2026-04-08 06:05:36
#>  5: finished  0.07174052  2.66149936  -25.770760 2026-04-08 06:05:36
#>  6: finished -7.51773958 -3.62287586  -80.975341 2026-04-08 06:05:36
#>  7: finished  5.70333065 -4.08089324   -4.882988 2026-04-08 06:05:36
#>  8: finished -6.10767685  3.07812258  -92.677998 2026-04-08 06:05:37
#>  9: finished  9.84218962  4.26953198 -104.346033 2026-04-08 06:05:37
#> 10: finished -9.43527839  3.90120726 -168.392253 2026-04-08 06:05:37
#> 11: finished  7.50436097 -0.05695712  -28.959491 2026-04-08 06:05:37
#> 12: finished -0.84870267 -1.03129050   -1.990924 2026-04-08 06:05:37
#> 13: finished -0.03656525  0.22023930   -4.517539 2026-04-08 06:05:37
#> 14: finished -8.26350117  0.25491344 -105.933918 2026-04-08 06:05:37
#> 15: finished -2.40412588 -0.01124492  -18.328982 2026-04-08 06:05:37
#> 16: finished  2.25513226  4.70309719  -49.402799 2026-04-08 06:05:37
#> 17: finished -6.33460185 -3.98131188  -60.428561 2026-04-08 06:05:37
#> 18: finished -7.94145157 -0.13848943  -97.020702 2026-04-08 06:05:37
#> 19: finished -9.00099977  2.14240782 -137.466354 2026-04-08 06:05:37
#> 20: finished -5.83602346 -2.01183452  -52.379735 2026-04-08 06:05:37
#>        state          x1          x2           y        timestamp_xs
#>       <char>       <num>       <num>       <num>              <POSc>
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>  1: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:36
#>  2: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:36
#>  3: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:36
#>  4: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:36
#>  5: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:36
#>  6: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:36
#>  7: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:36
#>  8: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:37
#>  9: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:37
#> 10: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:37
#> 11: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:37
#> 12: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:37
#> 13: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:37
#> 14: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:37
#> 15: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:37
#> 16: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:37
#> 17: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:37
#> 18: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:37
#> 19: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:37
#> 20: artsycraftsy_easteuropeanshepherd 2026-04-08 06:05:37
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 46e12f69-b26f-4946-9143-6c8b7a74dd0a  0.79964108  4.44173718
#>  2: d7062e60-45fa-4e94-9249-ed4d1e70fd57  1.97171934  0.98977706
#>  3: f7f5cf2f-65a1-4de4-be5a-bf458b2e1ad6 -8.74678495  2.85974125
#>  4: 285059ed-83d6-4989-a5b7-ae6da0614242 -8.86620125 -0.52683197
#>  5: 8dba7c03-85f6-48ae-9760-bc60831d6807  0.07174052  2.66149936
#>  6: 37857489-fcda-4110-a0d1-79a9056faf0c -7.51773958 -3.62287586
#>  7: 887ed3de-accd-43c4-b94b-e909c7839af9  5.70333065 -4.08089324
#>  8: 2ff3e289-2192-4242-8c68-ee8c63cce46c -6.10767685  3.07812258
#>  9: 1666a429-d68a-421f-99db-e95a1dabf8a0  9.84218962  4.26953198
#> 10: 6f5d99e7-e9e6-4fa4-bfaa-79e656a990ed -9.43527839  3.90120726
#> 11: 244537f7-371e-49f6-8c85-35a336a2f897  7.50436097 -0.05695712
#> 12: 1d0a0a73-a7b8-44d2-9507-c92ad343893f -0.84870267 -1.03129050
#> 13: c1fddcaa-1ac4-4eab-8328-9df08df8e89c -0.03656525  0.22023930
#> 14: 042fb86a-f13f-4563-b963-c751767f77eb -8.26350117  0.25491344
#> 15: c7de4ce2-f886-4fb8-b33e-defa9bf47d3e -2.40412588 -0.01124492
#> 16: 18131202-3927-44be-9493-b3b7afac31fb  2.25513226  4.70309719
#> 17: 381991b8-3873-4e71-9121-6cbd1de56f97 -6.33460185 -3.98131188
#> 18: 04e3f402-cd64-4b4f-8def-7c5b90423d46 -7.94145157 -0.13848943
#> 19: ae0b97b9-fac1-49b6-9589-5529fa02f8c8 -9.00099977  2.14240782
#> 20: 704e6187-28b6-46cd-a840-3607b7aff3ef -5.83602346 -2.01183452
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
