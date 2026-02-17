# Asynchronous Optimization Context

A
[CallbackAsync](https://bbotk.mlr-org.com/dev/reference/CallbackAsync.md)
accesses and modifies data during the optimization via the
`ContextAsync`. See the section on active bindings for a list of
modifiable objects. See
[`callback_async()`](https://bbotk.mlr-org.com/dev/reference/callback_async.md)
for a list of stages which access `ContextAsync`.

## Details

Changes to `$instance` and `$optimizer` in the stages executed on the
workers are not reflected in the main process.

## See also

[CallbackAsync](https://bbotk.mlr-org.com/dev/reference/CallbackAsync.md)

## Super class

[`mlr3misc::Context`](https://mlr3misc.mlr-org.com/reference/Context.html)
-\> `ContextAsync`

## Public fields

- `instance`:

  ([OptimInstance](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)).

- `optimizer`:

  ([Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)).

## Active bindings

- `xs`:

  (list())  
  The point to be evaluated in `instance$.eval_point()`.

- `xs_trafoed`:

  (list())  
  The transformed point to be evaluated in `instance$.eval_point()`.

- `extra`:

  (list())  
  Additional information of the point to be evaluated in
  `instance$.eval_point()`.

- `ys`:

  (list())  
  The result of the evaluation in `instance$.eval_point()`.

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

- [`ContextAsync$new()`](#method-ContextAsync-new)

- [`ContextAsync$clone()`](#method-ContextAsync-clone)

Inherited methods

- [`mlr3misc::Context$format()`](https://mlr3misc.mlr-org.com/reference/Context.html#method-format)
- [`mlr3misc::Context$print()`](https://mlr3misc.mlr-org.com/reference/Context.html#method-print)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    ContextAsync$new(inst, optimizer)

#### Arguments

- `inst`:

  ([OptimInstance](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)).

- `optimizer`:

  ([Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ContextAsync$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
