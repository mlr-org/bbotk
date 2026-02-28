# Combine Terminators

This class takes multiple
[Terminator](https://bbotk.mlr-org.com/reference/Terminator.md)s and
terminates as soon as one or all of the included terminators are
positive.

## Dictionary

This [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md) can
be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_terminators](https://bbotk.mlr-org.com/reference/mlr_terminators.md)
or with the associated sugar function
[`trm()`](https://bbotk.mlr-org.com/reference/trm.md):

    mlr_terminators$get("combo")
    trm("combo")

## Parameters

- `any`:

  `logical(1)`  
  Terminate iff any included terminator is positive? (not all). Default
  is `TRUE`.

## See also

Other Terminator:
[`Terminator`](https://bbotk.mlr-org.com/reference/Terminator.md),
[`mlr_terminators`](https://bbotk.mlr-org.com/reference/mlr_terminators.md),
[`mlr_terminators_clock_time`](https://bbotk.mlr-org.com/reference/mlr_terminators_clock_time.md),
[`mlr_terminators_evals`](https://bbotk.mlr-org.com/reference/mlr_terminators_evals.md),
[`mlr_terminators_none`](https://bbotk.mlr-org.com/reference/mlr_terminators_none.md),
[`mlr_terminators_perf_reached`](https://bbotk.mlr-org.com/reference/mlr_terminators_perf_reached.md),
[`mlr_terminators_run_time`](https://bbotk.mlr-org.com/reference/mlr_terminators_run_time.md),
[`mlr_terminators_stagnation`](https://bbotk.mlr-org.com/reference/mlr_terminators_stagnation.md),
[`mlr_terminators_stagnation_batch`](https://bbotk.mlr-org.com/reference/mlr_terminators_stagnation_batch.md),
[`mlr_terminators_stagnation_hypervolume`](https://bbotk.mlr-org.com/reference/mlr_terminators_stagnation_hypervolume.md)

## Super class

[`bbotk::Terminator`](https://bbotk.mlr-org.com/reference/Terminator.md)
-\> `TerminatorCombo`

## Public fields

- `terminators`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  List of objects of class
  [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md).

## Methods

### Public methods

- [`TerminatorCombo$new()`](#method-TerminatorCombo-new)

- [`TerminatorCombo$is_terminated()`](#method-TerminatorCombo-is_terminated)

- [`TerminatorCombo$print()`](#method-TerminatorCombo-print)

- [`TerminatorCombo$remaining_time()`](#method-TerminatorCombo-remaining_time)

- [`TerminatorCombo$status_long()`](#method-TerminatorCombo-status_long)

- [`TerminatorCombo$clone()`](#method-TerminatorCombo-clone)

Inherited methods

- [`bbotk::Terminator$format()`](https://bbotk.mlr-org.com/reference/Terminator.html#method-format)
- [`bbotk::Terminator$status()`](https://bbotk.mlr-org.com/reference/Terminator.html#method-status)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    TerminatorCombo$new(terminators = list(TerminatorNone$new()))

#### Arguments

- `terminators`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  List of objects of class
  [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md).

------------------------------------------------------------------------

### Method `is_terminated()`

Is `TRUE` iff the termination criterion is positive, and `FALSE`
otherwise.

#### Usage

    TerminatorCombo$is_terminated(archive)

#### Arguments

- `archive`:

  ([Archive](https://bbotk.mlr-org.com/reference/Archive.md)).

#### Returns

`logical(1)`.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Printer.

#### Usage

    TerminatorCombo$print(...)

#### Arguments

- `...`:

  (ignored).

------------------------------------------------------------------------

### Method `remaining_time()`

Returns the remaining runtime in seconds. If `any = TRUE`, the remaining
runtime is determined by the time-based terminator with the shortest
time remaining. If non-time-based terminators are used and
`any = FALSE`, the the remaining runtime is always `Inf`.

#### Usage

    TerminatorCombo$remaining_time(archive)

#### Arguments

- `archive`:

  ([Archive](https://bbotk.mlr-org.com/reference/Archive.md)).

#### Returns

`integer(1)`.

------------------------------------------------------------------------

### Method `status_long()`

Returns `max_steps` and `current_steps` for each terminator.

#### Usage

    TerminatorCombo$status_long(archive)

#### Arguments

- `archive`:

  ([Archive](https://bbotk.mlr-org.com/reference/Archive.md)).

#### Returns

[data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    TerminatorCombo$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
trm("combo",
  list(trm("clock_time", stop_time = Sys.time() + 60),
    trm("evals", n_evals = 10)), any = FALSE
)
#> 
#> ── <TerminatorCombo> - Combination ─────────────────────────────────────────────
#> • Parameters: any=FALSE
#> • Terminators: <TerminatorClockTime> and <TerminatorEvals>
```
