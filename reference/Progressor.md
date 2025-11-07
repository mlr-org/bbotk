# Progressor

Wraps
[`progressr::progressor()`](https://progressr.futureverse.org/reference/progressor.html)
function and stores current progress.

## See also

[OptimInstance](https://bbotk.mlr-org.com/reference/OptimInstance.md)

## Public fields

- `progressor`:

  ([`progressr::progressor()`](https://progressr.futureverse.org/reference/progressor.html)).

- `max_steps`:

  (`integer(1)`).

- `current_steps`:

  (`integer(1)`).

- `unit`:

  (`character(1)`).

## Methods

### Public methods

- [`Progressor$new()`](#method-Progressor-new)

- [`Progressor$update()`](#method-Progressor-update)

- [`Progressor$clone()`](#method-Progressor-clone)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    Progressor$new(progressor, unit)

#### Arguments

- `progressor`:

  ([`progressr::progressor()`](https://progressr.futureverse.org/reference/progressor.html))  
  Progressor function.

- `unit`:

  (`character(1)`)  
  Unit of progress.

------------------------------------------------------------------------

### Method [`update()`](https://rdrr.io/r/stats/update.html)

Updates
[`progressr::progressor()`](https://progressr.futureverse.org/reference/progressor.html)
with current steps.

#### Usage

    Progressor$update(terminator, archive)

#### Arguments

- `terminator`:

  ([Terminator](https://bbotk.mlr-org.com/reference/Terminator.md)).

- `archive`:

  ([Archive](https://bbotk.mlr-org.com/reference/Archive.md)).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Progressor$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
