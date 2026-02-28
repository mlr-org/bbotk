# Evaluation Instance Base Class

Abstract base class for instances that evaluate an objective function.
This class provides common functionality shared between optimization
([OptimInstance](https://bbotk.mlr-org.com/reference/OptimInstance.md))
and other evaluation patterns (e.g., active learning).

## Details

`EvalInstance` contains the core components needed for any objective
evaluation loop:

- An [Objective](https://bbotk.mlr-org.com/reference/Objective.md) to
  evaluate

- A search space defining valid inputs

- An [Archive](https://bbotk.mlr-org.com/reference/Archive.md) storing
  evaluation history

- A [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md)
  defining stopping conditions

Subclasses add specific functionality:

- [OptimInstance](https://bbotk.mlr-org.com/reference/OptimInstance.md):
  Result tracking, optimization-specific methods

- External packages may define their own subclasses

## Public fields

- `objective`:

  ([Objective](https://bbotk.mlr-org.com/reference/Objective.md))  
  Objective function of the instance.

- `search_space`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Specification of the search space for the
  [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md).

- `terminator`:

  [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md)  
  Termination criterion of the optimization.

- `archive`:

  ([Archive](https://bbotk.mlr-org.com/reference/Archive.md))  
  Contains all performed function calls of the Objective.

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

- `is_terminated`:

  (`logical(1)`)  
  Whether the terminator says we should stop.

- `n_evals`:

  (`integer(1)`)  
  Number of evaluations performed.

## Methods

### Public methods

- [`EvalInstance$new()`](#method-EvalInstance-new)

- [`EvalInstance$format()`](#method-EvalInstance-format)

- [`EvalInstance$print()`](#method-EvalInstance-print)

- [`EvalInstance$clear()`](#method-EvalInstance-clear)

- [`EvalInstance$clone()`](#method-EvalInstance-clone)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    EvalInstance$new(
      objective,
      search_space,
      terminator,
      archive,
      label = NA_character_,
      man = NA_character_
    )

#### Arguments

- `objective`:

  ([Objective](https://bbotk.mlr-org.com/reference/Objective.md))  
  Objective function.

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

- `terminator`:

  [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md)  
  Termination criterion.

- `archive`:

  ([Archive](https://bbotk.mlr-org.com/reference/Archive.md)).

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

    EvalInstance$format(...)

#### Arguments

- `...`:

  (ignored).

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Printer.

#### Usage

    EvalInstance$print(...)

#### Arguments

- `...`:

  (ignored).

------------------------------------------------------------------------

### Method `clear()`

Clear all evaluation results from archive.

#### Usage

    EvalInstance$clear()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    EvalInstance$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
