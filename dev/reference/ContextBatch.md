# Batch Optimization Context

A
[CallbackBatch](https://bbotk.mlr-org.com/dev/reference/CallbackBatch.md)
accesses and modifies data during the optimization via the
`ContextBatch`. See the section on active bindings for a list of
modifiable objects. See
[`callback_batch()`](https://bbotk.mlr-org.com/dev/reference/callback_batch.md)
for a list of stages which that `ContextBatch`.

## See also

[CallbackBatch](https://bbotk.mlr-org.com/dev/reference/CallbackBatch.md)

## Super class

[`mlr3misc::Context`](https://mlr3misc.mlr-org.com/reference/Context.html)
-\> `ContextBatch`

## Public fields

- `instance`:

  ([OptimInstance](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)).

- `optimizer`:

  ([Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)).

## Active bindings

- `xdt`:

  ([data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html))  
  The points of the latest batch in `instance$eval_batch()`. Contains
  the values in the search space i.e. transformations are not yet
  applied.

- `result_xdt`:

  ([data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html))  
  The xdt passed to `instance$assign_result()`.

- `result_y`:

  (`numeric(1)`)  
  The y passed to `instance$assign_result()`. Only available for single
  criterion optimization.

- `result_ydt`:

  ([data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html))  
  The ydt passed to `instance$assign_result()`. Only available for multi
  criterion optimization.

- `result_extra`:

  ([data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html))  
  Additional information about the result passed to
  `instance$assign_result()`.

- `result`:

  ([data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html))  
  The result of the optimization in `instance$assign_result()`.

## Methods

### Public methods

- [`ContextBatch$new()`](#method-ContextBatch-new)

- [`ContextBatch$clone()`](#method-ContextBatch-clone)

Inherited methods

- [`mlr3misc::Context$format()`](https://mlr3misc.mlr-org.com/reference/Context.html#method-format)
- [`mlr3misc::Context$print()`](https://mlr3misc.mlr-org.com/reference/Context.html#method-print)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    ContextBatch$new(inst, optimizer)

#### Arguments

- `inst`:

  ([OptimInstance](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)).

- `optimizer`:

  ([Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ContextBatch$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
