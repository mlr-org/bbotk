# Optimizer

The `Optimizer` implements the optimization algorithm.

## Details

`Optimizer` is an abstract base class that implements the base
functionality each optimizer must provide. A `Optimizer` object
describes the optimization strategy. A `Optimizer` object must write its
result to the `$assign_result()` method of the
[OptimInstance](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)
at the end in order to store the best point and its estimated
performance vector.

## Progress Bars

`$optimize()` supports progress bars via the package
[progressr](https://CRAN.R-project.org/package=progressr) combined with
a [Terminator](https://bbotk.mlr-org.com/dev/reference/Terminator.md).
Simply wrap the function in
[`progressr::with_progress()`](https://progressr.futureverse.org/reference/with_progress.html)
to enable them. We recommend to use package
[progress](https://CRAN.R-project.org/package=progress) as backend;
enable with `progressr::handlers("progress")`.

## See also

[OptimizerAsync](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md),
[OptimizerBatch](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.md)

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

- `param_classes`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Supported parameter classes that the optimizer can optimize, as given
  in the
  [`paradox::ParamSet`](https://paradox.mlr-org.com/reference/ParamSet.html)
  `$class` field.

- `properties`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Set of properties of the optimizer. Must be a subset of
  [`bbotk_reflections$optimizer_properties`](https://bbotk.mlr-org.com/dev/reference/bbotk_reflections.md).

- `packages`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Set of required packages. A warning is signaled by the constructor if
  at least one of the packages is not installed, but loaded (not
  attached) later on-demand via
  [`requireNamespace()`](https://rdrr.io/r/base/ns-load.html).

## Methods

### Public methods

- [`Optimizer$new()`](#method-Optimizer-new)

- [`Optimizer$format()`](#method-Optimizer-format)

- [`Optimizer$print()`](#method-Optimizer-print)

- [`Optimizer$help()`](#method-Optimizer-help)

- [`Optimizer$clone()`](#method-Optimizer-clone)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    Optimizer$new(
      id = "optimizer",
      param_set,
      param_classes,
      properties,
      packages = character(),
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

- `param_classes`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Supported parameter classes that the optimizer can optimize, as given
  in the
  [`paradox::ParamSet`](https://paradox.mlr-org.com/reference/ParamSet.html)
  `$class` field.

- `properties`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Set of properties of the optimizer. Must be a subset of
  [`bbotk_reflections$optimizer_properties`](https://bbotk.mlr-org.com/dev/reference/bbotk_reflections.md).

- `packages`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Set of required packages. A warning is signaled by the constructor if
  at least one of the packages is not installed, but loaded (not
  attached) later on-demand via
  [`requireNamespace()`](https://rdrr.io/r/base/ns-load.html).

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

    Optimizer$format(...)

#### Arguments

- `...`:

  (ignored).

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print method.

#### Usage

    Optimizer$print()

#### Returns

([`character()`](https://rdrr.io/r/base/character.html)).

------------------------------------------------------------------------

### Method [`help()`](https://rdrr.io/r/utils/help.html)

Opens the corresponding help page referenced by field `$man`.

#### Usage

    Optimizer$help()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Optimizer$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
