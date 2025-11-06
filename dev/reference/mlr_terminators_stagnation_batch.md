# Terminator that stops when optimization does not improve

Class to terminate the optimization after the performance stagnates,
i.e. does not improve more than `threshold` over the last `n` batches.

## Dictionary

This [Terminator](https://bbotk.mlr-org.com/dev/reference/Terminator.md)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_terminators](https://bbotk.mlr-org.com/dev/reference/mlr_terminators.md)
or with the associated sugar function
[`trm()`](https://bbotk.mlr-org.com/dev/reference/trm.md):

    mlr_terminators$get("stagnation_batch")
    trm("stagnation_batch")

## Parameters

- `n`:

  `integer(1)`  
  Number of batches to evaluate the performance improvement on, default
  is 1.

- `threshold`:

  `numeric(1)`  
  If the improvement is less than `threshold`, optimization is stopped,
  default is `0`.

## See also

Other Terminator:
[`Terminator`](https://bbotk.mlr-org.com/dev/reference/Terminator.md),
[`mlr_terminators`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators.md),
[`mlr_terminators_clock_time`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_clock_time.md),
[`mlr_terminators_combo`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_combo.md),
[`mlr_terminators_evals`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_evals.md),
[`mlr_terminators_none`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_none.md),
[`mlr_terminators_perf_reached`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_perf_reached.md),
[`mlr_terminators_run_time`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_run_time.md),
[`mlr_terminators_stagnation`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation.md),
[`mlr_terminators_stagnation_hypervolume`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation_hypervolume.md)

## Super class

[`bbotk::Terminator`](https://bbotk.mlr-org.com/dev/reference/Terminator.md)
-\> `TerminatorStagnationBatch`

## Methods

### Public methods

- [`TerminatorStagnationBatch$new()`](#method-TerminatorStagnationBatch-new)

- [`TerminatorStagnationBatch$is_terminated()`](#method-TerminatorStagnationBatch-is_terminated)

- [`TerminatorStagnationBatch$clone()`](#method-TerminatorStagnationBatch-clone)

Inherited methods

- [`bbotk::Terminator$format()`](https://bbotk.mlr-org.com/dev/reference/Terminator.html#method-format)
- [`bbotk::Terminator$print()`](https://bbotk.mlr-org.com/dev/reference/Terminator.html#method-print)
- [`bbotk::Terminator$remaining_time()`](https://bbotk.mlr-org.com/dev/reference/Terminator.html#method-remaining_time)
- [`bbotk::Terminator$status()`](https://bbotk.mlr-org.com/dev/reference/Terminator.html#method-status)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    TerminatorStagnationBatch$new()

------------------------------------------------------------------------

### Method `is_terminated()`

Is `TRUE` iff the termination criterion is positive, and `FALSE`
otherwise.

#### Usage

    TerminatorStagnationBatch$is_terminated(archive)

#### Arguments

- `archive`:

  ([Archive](https://bbotk.mlr-org.com/dev/reference/Archive.md)).

#### Returns

`logical(1)`.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    TerminatorStagnationBatch$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
TerminatorStagnationBatch$new()
#> 
#> ── <TerminatorStagnationBatch> - Stagnation Batch ──────────────────────────────
#> • Parameters: n=1, threshold=0
#> • Terminators:
trm("stagnation_batch", n = 1, threshold = 1e-5)
#> 
#> ── <TerminatorStagnationBatch> - Stagnation Batch ──────────────────────────────
#> • Parameters: n=1, threshold=1e-05
#> • Terminators:
```
