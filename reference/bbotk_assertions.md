# Assertion for bbotk objects

Most assertion functions ensure the right class attribute, and
optionally additional properties. Additionally, the following compound
assertions are implemented:

- `assert_terminable(terminator, instance)`  
  ([Terminator](https://bbotk.mlr-org.com/reference/Terminator.md),
  [OptimInstance](https://bbotk.mlr-org.com/reference/OptimInstance.md))
  -\> `NULL`  
  Checks if the terminator is applicable to the optimization.

- `assert_instance_properties(optimizer, instance)`  
  ([Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md),
  [OptimInstance](https://bbotk.mlr-org.com/reference/OptimInstance.md))
  -\> `NULL`  
  Checks if the instance is applicable to the optimizer.

If an assertion fails, an exception is raised. Otherwise, the input
object is returned invisibly.

## Usage

``` r
assert_terminator(terminator, instance = NULL, null_ok = FALSE)

assert_terminators(terminators)

assert_terminable(terminator, instance)

assert_set(x, empty = TRUE, .var.name = vname(x))

assert_optimizer(optimizer, null_ok = FALSE)

assert_optimizer_async(optimizer, null_ok = FALSE)

assert_optimizer_batch(optimizer, null_ok = FALSE)

assert_instance(inst, null_ok = FALSE)

assert_instance_batch(inst, null_ok = FALSE)

assert_instance_async(inst, null_ok = FALSE)

assert_instance_properties(optimizer, inst)

assert_archive(archive, null_ok = FALSE)

assert_archive_async(archive, null_ok = FALSE)

assert_archive_batch(archive, null_ok = FALSE)
```

## Arguments

- terminator:

  ([Terminator](https://bbotk.mlr-org.com/reference/Terminator.md)).

- instance:

  ([OptimInstance](https://bbotk.mlr-org.com/reference/OptimInstance.md)).

- null_ok:

  (`logical(1)`)  
  Is `NULL` a valid value?

- terminators:

  (list of
  [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md)).

- x:

  (any)

- empty:

  (`logical(1)`)

- .var.name:

  (`character(1)`)

- optimizer:

  ([Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md)).

- inst:

  ([OptimInstanceAsync](https://bbotk.mlr-org.com/reference/OptimInstanceAsync.md))

- archive:

  ([ArchiveBatch](https://bbotk.mlr-org.com/reference/ArchiveBatch.md)).

## See also

[Terminator](https://bbotk.mlr-org.com/reference/Terminator.md),
[OptimInstance](https://bbotk.mlr-org.com/reference/OptimInstance.md),
[Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md),
[Archive](https://bbotk.mlr-org.com/reference/Archive.md)
