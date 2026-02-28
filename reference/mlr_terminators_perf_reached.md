# Performance Level Terminator

Class to terminate the optimization after a performance level has been
hit.

## Dictionary

This [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md) can
be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_terminators](https://bbotk.mlr-org.com/reference/mlr_terminators.md)
or with the associated sugar function
[`trm()`](https://bbotk.mlr-org.com/reference/trm.md):

    mlr_terminators$get("perf_reached")
    trm("perf_reached")

## Parameters

- `level`:

  `numeric(1)`  
  Performance level that needs to be reached. Default is 0. Terminates
  if the performance exceeds (respective measure has to be maximized) or
  falls below (respective measure has to be minimized) this value.

## See also

Other Terminator:
[`Terminator`](https://bbotk.mlr-org.com/reference/Terminator.md),
[`mlr_terminators`](https://bbotk.mlr-org.com/reference/mlr_terminators.md),
[`mlr_terminators_clock_time`](https://bbotk.mlr-org.com/reference/mlr_terminators_clock_time.md),
[`mlr_terminators_combo`](https://bbotk.mlr-org.com/reference/mlr_terminators_combo.md),
[`mlr_terminators_evals`](https://bbotk.mlr-org.com/reference/mlr_terminators_evals.md),
[`mlr_terminators_none`](https://bbotk.mlr-org.com/reference/mlr_terminators_none.md),
[`mlr_terminators_run_time`](https://bbotk.mlr-org.com/reference/mlr_terminators_run_time.md),
[`mlr_terminators_stagnation`](https://bbotk.mlr-org.com/reference/mlr_terminators_stagnation.md),
[`mlr_terminators_stagnation_batch`](https://bbotk.mlr-org.com/reference/mlr_terminators_stagnation_batch.md),
[`mlr_terminators_stagnation_hypervolume`](https://bbotk.mlr-org.com/reference/mlr_terminators_stagnation_hypervolume.md)

## Super class

[`bbotk::Terminator`](https://bbotk.mlr-org.com/reference/Terminator.md)
-\> `TerminatorPerfReached`

## Methods

### Public methods

- [`TerminatorPerfReached$new()`](#method-TerminatorPerfReached-new)

- [`TerminatorPerfReached$is_terminated()`](#method-TerminatorPerfReached-is_terminated)

- [`TerminatorPerfReached$clone()`](#method-TerminatorPerfReached-clone)

Inherited methods

- [`bbotk::Terminator$format()`](https://bbotk.mlr-org.com/reference/Terminator.html#method-format)
- [`bbotk::Terminator$print()`](https://bbotk.mlr-org.com/reference/Terminator.html#method-print)
- [`bbotk::Terminator$remaining_time()`](https://bbotk.mlr-org.com/reference/Terminator.html#method-remaining_time)
- [`bbotk::Terminator$status()`](https://bbotk.mlr-org.com/reference/Terminator.html#method-status)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    TerminatorPerfReached$new()

------------------------------------------------------------------------

### Method `is_terminated()`

Is `TRUE` iff the termination criterion is positive, and `FALSE`
otherwise.

#### Usage

    TerminatorPerfReached$is_terminated(archive)

#### Arguments

- `archive`:

  ([Archive](https://bbotk.mlr-org.com/reference/Archive.md)).

#### Returns

`logical(1)`.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    TerminatorPerfReached$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
TerminatorPerfReached$new()
#> 
#> ── <TerminatorPerfReached> - Performance Level ─────────────────────────────────
#> • Parameters: level=0.1
trm("perf_reached")
#> 
#> ── <TerminatorPerfReached> - Performance Level ─────────────────────────────────
#> • Parameters: level=0.1
```
