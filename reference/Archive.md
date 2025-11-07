# Data Storage

The `Archive` class stores all evaluated points and performance scores

## Details

The `Archive` is an abstract class that implements the base
functionality each archive must provide.

## See also

[ArchiveBatch](https://bbotk.mlr-org.com/reference/ArchiveBatch.md),
[ArchiveAsync](https://bbotk.mlr-org.com/reference/ArchiveAsync.md)

## Public fields

- `search_space`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Specification of the search space for the
  [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md).

- `codomain`:

  ([Codomain](https://bbotk.mlr-org.com/reference/Codomain.md))  
  Codomain of objective function.

- `start_time`:

  ([POSIXct](https://rdrr.io/r/base/DateTimeClasses.html))  
  Time stamp of when the optimization started. The time is set by the
  [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md).

- `check_values`:

  (`logical(1)`)  
  Determines if points and results are checked for validity.

## Active bindings

- `label`:

  (`character(1)`)  
  Label for this object. Can be used in tables, plot and text output
  instead of the ID.

- `man`:

  (`character(1)`)  
  String in the format `[pkg]::[topic]` pointing to a manual page for
  this object. The referenced help package can be opened via method
  `$help()`.

- `cols_x`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Column names of search space parameters.

- `cols_y`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Column names of codomain target parameters.

## Methods

### Public methods

- [`Archive$new()`](#method-Archive-new)

- [`Archive$format()`](#method-Archive-format)

- [`Archive$print()`](#method-Archive-print)

- [`Archive$clear()`](#method-Archive-clear)

- [`Archive$help()`](#method-Archive-help)

- [`Archive$clone()`](#method-Archive-clone)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    Archive$new(
      search_space,
      codomain,
      check_values = FALSE,
      label = NA_character_,
      man = NA_character_
    )

#### Arguments

- `search_space`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Specifies the search space for the
  [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md). The
  [paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)
  describes either a subset of the `domain` of the
  [Objective](https://bbotk.mlr-org.com/reference/Objective.md) or it
  describes a set of parameters together with a `trafo` function that
  transforms values from the search space to values of the domain.
  Depending on the context, this value defaults to the domain of the
  objective.

- `codomain`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Specifies codomain of function. Most importantly the tags of each
  output "Parameter" define whether it should be minimized or maximized.
  The default is to minimize each component.

- `check_values`:

  (`logical(1)`)  
  Should x-values that are added to the archive be checked for validity?
  Search space that is logged into archive.

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

    Archive$format(...)

#### Arguments

- `...`:

  (ignored).

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Printer.

#### Usage

    Archive$print()

#### Arguments

- `...`:

  (ignored).

------------------------------------------------------------------------

### Method `clear()`

Clear all evaluation results from archive.

#### Usage

    Archive$clear()

------------------------------------------------------------------------

### Method [`help()`](https://rdrr.io/r/utils/help.html)

Opens the corresponding help page referenced by field `$man`.

#### Usage

    Archive$help()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Archive$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
