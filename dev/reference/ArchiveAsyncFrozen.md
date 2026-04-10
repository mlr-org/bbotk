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
#>  1: finished  0.79964108  4.44173718  -46.820314 2026-04-10 10:21:39
#>  2: finished  1.97171934  0.98977706   -5.919121 2026-04-10 10:21:39
#>  3: finished -8.74678495  2.85974125 -139.829954 2026-04-10 10:21:39
#>  4: finished -8.86620125 -0.52683197 -114.190890 2026-04-10 10:21:40
#>  5: finished  0.07174052  2.66149936  -25.770760 2026-04-10 10:21:40
#>  6: finished -7.51773958 -3.62287586  -80.975341 2026-04-10 10:21:40
#>  7: finished  5.70333065 -4.08089324   -4.882988 2026-04-10 10:21:40
#>  8: finished -6.10767685  3.07812258  -92.677998 2026-04-10 10:21:40
#>  9: finished  9.84218962  4.26953198 -104.346033 2026-04-10 10:21:40
#> 10: finished -9.43527839  3.90120726 -168.392253 2026-04-10 10:21:40
#> 11: finished  7.50436097 -0.05695712  -28.959491 2026-04-10 10:21:40
#> 12: finished -0.84870267 -1.03129050   -1.990924 2026-04-10 10:21:40
#> 13: finished -0.03656525  0.22023930   -4.517539 2026-04-10 10:21:40
#> 14: finished -8.26350117  0.25491344 -105.933918 2026-04-10 10:21:40
#> 15: finished -2.40412588 -0.01124492  -18.328982 2026-04-10 10:21:40
#> 16: finished  2.25513226  4.70309719  -49.402799 2026-04-10 10:21:40
#> 17: finished -6.33460185 -3.98131188  -60.428561 2026-04-10 10:21:40
#> 18: finished -7.94145157 -0.13848943  -97.020702 2026-04-10 10:21:40
#> 19: finished -9.00099977  2.14240782 -137.466354 2026-04-10 10:21:40
#> 20: finished -5.83602346 -2.01183452  -52.379735 2026-04-10 10:21:40
#>        state          x1          x2           y        timestamp_xs
#>       <char>       <num>       <num>       <num>              <POSc>
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>  1: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:39
#>  2: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:39
#>  3: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:39
#>  4: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:40
#>  5: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:40
#>  6: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:40
#>  7: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:40
#>  8: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:40
#>  9: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:40
#> 10: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:40
#> 11: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:40
#> 12: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:40
#> 13: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:40
#> 14: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:40
#> 15: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:40
#> 16: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:40
#> 17: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:40
#> 18: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:40
#> 19: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:40
#> 20: artsycraftsy_easteuropeanshepherd 2026-04-10 10:21:40
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 53005cd3-d2c3-4136-bb23-4b5b3b12710a  0.79964108  4.44173718
#>  2: ffc9ff79-e62b-4ece-aa96-52583ce99648  1.97171934  0.98977706
#>  3: 67af1b84-39a1-4f26-8953-a75d509b5592 -8.74678495  2.85974125
#>  4: e8fac5ae-f4b8-4259-8142-a3e4da8cd933 -8.86620125 -0.52683197
#>  5: 262e193e-2912-4729-ae43-3954ac77d006  0.07174052  2.66149936
#>  6: f54a91ab-37ec-4ea6-b709-853a5fd46f9c -7.51773958 -3.62287586
#>  7: 93f1c334-a0e6-42ca-abd6-57826ade8a1d  5.70333065 -4.08089324
#>  8: bbdaf420-c042-4a85-b72e-7be11d9892ba -6.10767685  3.07812258
#>  9: 3e7d23c5-ca08-493b-a1d2-13190e053b4a  9.84218962  4.26953198
#> 10: 06c6f2de-5e0b-4742-b6a5-b6e9f94bcd70 -9.43527839  3.90120726
#> 11: b2b75274-8a77-43d3-9778-a04ecee81b40  7.50436097 -0.05695712
#> 12: b2c1a0f8-f2f7-47ed-925b-f0d1c3aefc09 -0.84870267 -1.03129050
#> 13: b4abbbfe-7494-4a82-9860-130599d34b93 -0.03656525  0.22023930
#> 14: efa94960-47af-4570-8c53-72bd9431067e -8.26350117  0.25491344
#> 15: 139f2c61-27fb-4ecd-8703-a626663a56e3 -2.40412588 -0.01124492
#> 16: 83461f03-e8d8-4d6d-82e5-0bda083ae2e1  2.25513226  4.70309719
#> 17: 9949d60c-06e8-42dc-8699-3b6f5e8e04bb -6.33460185 -3.98131188
#> 18: 6da69b0e-52da-46e7-a396-8db4fb94c087 -7.94145157 -0.13848943
#> 19: e6908a9c-541a-4e0f-b742-d08823b9bc37 -9.00099977  2.14240782
#> 20: a580c954-7d8a-4e25-9c55-b940e6a30896 -5.83602346 -2.01183452
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
