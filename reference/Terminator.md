# Abstract Terminator Class

Abstract `Terminator` class that implements the base functionality each
terminator must provide. A terminator is an object that determines when
to stop the optimization.

Termination of optimization works as follows:

- Evaluations in a instance are performed in batches.

- Before each batch evaluation, the Terminator is checked, and if it is
  positive, we stop.

- The optimization algorithm itself might decide not to produce any more
  points, or even might decide to do a smaller batch in its last
  evaluation.

Therefore the following note seems in order: While it is definitely
possible to execute a fine-grained control for termination, and for many
optimization algorithms we can specify exactly when to stop, it might
happen that too few or even too many evaluations are performed,
especially if multiple points are evaluated in a single batch (c.f.
batch size parameter of many optimization algorithms). So it is advised
to check the size of the returned archive, in particular if you are
benchmarking multiple optimization algorithms.

## Technical details

`Terminator` subclasses can overwrite `.status()` to support progress
bars via the package
[progressr](https://CRAN.R-project.org/package=progressr). The method
must return the maximum number of steps (`max_steps`) and the currently
achieved number of steps (`current_steps`) as a named integer vector.

## See also

Other Terminator:
[`mlr_terminators`](https://bbotk.mlr-org.com/reference/mlr_terminators.md),
[`mlr_terminators_clock_time`](https://bbotk.mlr-org.com/reference/mlr_terminators_clock_time.md),
[`mlr_terminators_combo`](https://bbotk.mlr-org.com/reference/mlr_terminators_combo.md),
[`mlr_terminators_evals`](https://bbotk.mlr-org.com/reference/mlr_terminators_evals.md),
[`mlr_terminators_none`](https://bbotk.mlr-org.com/reference/mlr_terminators_none.md),
[`mlr_terminators_perf_reached`](https://bbotk.mlr-org.com/reference/mlr_terminators_perf_reached.md),
[`mlr_terminators_run_time`](https://bbotk.mlr-org.com/reference/mlr_terminators_run_time.md),
[`mlr_terminators_stagnation`](https://bbotk.mlr-org.com/reference/mlr_terminators_stagnation.md),
[`mlr_terminators_stagnation_batch`](https://bbotk.mlr-org.com/reference/mlr_terminators_stagnation_batch.md),
[`mlr_terminators_stagnation_hypervolume`](https://bbotk.mlr-org.com/reference/mlr_terminators_stagnation_hypervolume.md)

## Public fields

- `id`:

  (`character(1)`)  
  Identifier of the object. Used in tables, plot and text output.

## Active bindings

- `param_set`:

  [paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)  
  Set of control parameters.

- `label`:

  (`character(1)`)  
  Label for this object. Can be used in tables, plot and text output
  instead of the ID.

- `man`:

  (`character(1)`)  
  String in the format `[pkg]::[topic]` pointing to a manual page for
  this object. The referenced help package can be opened via method
  `$help()`.

- `properties`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Set of properties of the terminator. Must be a subset of
  [`bbotk_reflections$terminator_properties`](https://bbotk.mlr-org.com/reference/bbotk_reflections.md).

- `unit`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Unit of steps.

## Methods

### Public methods

- [`Terminator$new()`](#method-Terminator-new)

- [`Terminator$format()`](#method-Terminator-format)

- [`Terminator$print()`](#method-Terminator-print)

- [`Terminator$status()`](#method-Terminator-status)

- [`Terminator$remaining_time()`](#method-Terminator-remaining_time)

- [`Terminator$clone()`](#method-Terminator-clone)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    Terminator$new(
      id,
      param_set = ps(),
      properties = character(),
      unit = "percent",
      label = NA_character_,
      man = NA_character_
    )

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier for the new instance.

- `param_set`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Set of control parameters.

- `properties`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Set of properties of the terminator. Must be a subset of
  [`bbotk_reflections$terminator_properties`](https://bbotk.mlr-org.com/reference/bbotk_reflections.md).

- `unit`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Unit of steps.

- `label`:

  (`character(1)`)  
  Label for this object. Can be used in tables, plot and text output
  instead of the ID.

- `man`:

  (`character(1)`)  
  String in the format `[pkg]::[topic]` pointing to a manual page for
  this object. The referenced help package can be opened via method
  `$help()`.

------------------------------------------------------------------------

### Method [`format()`](https://rdrr.io/r/base/format.html)

Helper for print outputs.

#### Usage

    Terminator$format(with_params = FALSE, ...)

#### Arguments

- `with_params`:

  (`logical(1)`)  
  Add parameter values to format string.

- `...`:

  (ignored).

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Printer.

#### Usage

    Terminator$print(...)

#### Arguments

- `...`:

  (ignored).

------------------------------------------------------------------------

### Method `status()`

Returns how many progression steps are made (`current_steps`) and the
amount steps needed for termination (`max_steps`).

#### Usage

    Terminator$status(archive)

#### Arguments

- `archive`:

  ([Archive](https://bbotk.mlr-org.com/reference/Archive.md)).

#### Returns

named `integer(2)`.

------------------------------------------------------------------------

### Method `remaining_time()`

Returns remaining runtime in seconds. If the terminator is not
time-based, the reaming runtime is `Inf`.

#### Usage

    Terminator$remaining_time(archive)

#### Arguments

- `archive`:

  ([Archive](https://bbotk.mlr-org.com/reference/Archive.md)).

#### Returns

`integer(1)`.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Terminator$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
