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
#>  1: finished  0.79964108  4.44173718  -46.820314 2026-04-20 15:43:09
#>  2: finished  1.97171934  0.98977706   -5.919121 2026-04-20 15:43:09
#>  3: finished -8.74678495  2.85974125 -139.829954 2026-04-20 15:43:09
#>  4: finished -8.86620125 -0.52683197 -114.190890 2026-04-20 15:43:09
#>  5: finished  0.07174052  2.66149936  -25.770760 2026-04-20 15:43:09
#>  6: finished -7.51773958 -3.62287586  -80.975341 2026-04-20 15:43:09
#>  7: finished  5.70333065 -4.08089324   -4.882988 2026-04-20 15:43:09
#>  8: finished -6.10767685  3.07812258  -92.677998 2026-04-20 15:43:09
#>  9: finished  9.84218962  4.26953198 -104.346033 2026-04-20 15:43:09
#> 10: finished -9.43527839  3.90120726 -168.392253 2026-04-20 15:43:09
#> 11: finished  7.50436097 -0.05695712  -28.959491 2026-04-20 15:43:10
#> 12: finished -0.84870267 -1.03129050   -1.990924 2026-04-20 15:43:10
#> 13: finished -0.03656525  0.22023930   -4.517539 2026-04-20 15:43:10
#> 14: finished -8.26350117  0.25491344 -105.933918 2026-04-20 15:43:10
#> 15: finished -2.40412588 -0.01124492  -18.328982 2026-04-20 15:43:10
#> 16: finished  2.25513226  4.70309719  -49.402799 2026-04-20 15:43:10
#> 17: finished -6.33460185 -3.98131188  -60.428561 2026-04-20 15:43:10
#> 18: finished -7.94145157 -0.13848943  -97.020702 2026-04-20 15:43:10
#> 19: finished -9.00099977  2.14240782 -137.466354 2026-04-20 15:43:10
#> 20: finished -5.83602346 -2.01183452  -52.379735 2026-04-20 15:43:10
#>        state          x1          x2           y        timestamp_xs
#>       <char>       <num>       <num>       <num>              <POSc>
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>  1: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:09
#>  2: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:09
#>  3: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:09
#>  4: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:09
#>  5: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:09
#>  6: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:09
#>  7: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:09
#>  8: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:09
#>  9: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:09
#> 10: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:09
#> 11: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:10
#> 12: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:10
#> 13: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:10
#> 14: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:10
#> 15: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:10
#> 16: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:10
#> 17: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:10
#> 18: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:10
#> 19: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:10
#> 20: artsycraftsy_easteuropeanshepherd 2026-04-20 15:43:10
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 6195452e-9cfa-471c-b356-d687947e82c6  0.79964108  4.44173718
#>  2: c06c392f-96bf-4ffe-8a2e-c73e7bc18003  1.97171934  0.98977706
#>  3: 0c795af1-aed8-49b5-92f8-94d0747355c3 -8.74678495  2.85974125
#>  4: a4dd2516-a23a-46cf-bbed-ecb2ffd3a644 -8.86620125 -0.52683197
#>  5: d0331080-74ea-4c1b-8ee8-334730ecc7f4  0.07174052  2.66149936
#>  6: b338b772-5622-46ea-9063-8498db0622e6 -7.51773958 -3.62287586
#>  7: 4d141659-fe4d-45dd-9e2c-5510ea778ff6  5.70333065 -4.08089324
#>  8: cf08b90e-110a-4086-8b98-a3ad2e4cfb68 -6.10767685  3.07812258
#>  9: a5ff83dd-7d12-4eae-83ac-520a4603e550  9.84218962  4.26953198
#> 10: 7d1f240b-d042-4659-9e89-6c27926d04e6 -9.43527839  3.90120726
#> 11: 0878c6e8-ddfc-4caa-928d-cd77ae25c586  7.50436097 -0.05695712
#> 12: fc47a6d5-ca6c-4748-8695-48c047c2f536 -0.84870267 -1.03129050
#> 13: db5f3af6-bab1-4dab-98f0-c19f68447ba9 -0.03656525  0.22023930
#> 14: bcc92157-b74f-4e4b-b3f3-828a5ecd5b3b -8.26350117  0.25491344
#> 15: a771bfe4-d9f5-499d-af3a-99778f66d2f8 -2.40412588 -0.01124492
#> 16: 07a30bfc-d12b-4c42-8490-b8be66906073  2.25513226  4.70309719
#> 17: 19f52174-fb4c-4487-88dd-d1920e753116 -6.33460185 -3.98131188
#> 18: 604e0157-0ba7-46b7-8260-d067e9a56e0a -7.94145157 -0.13848943
#> 19: 80ca5c0d-4185-43d3-a82a-501590a22043 -9.00099977  2.14240782
#> 20: 16555ddd-6cf7-44cd-8f93-67691e84db24 -5.83602346 -2.01183452
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
