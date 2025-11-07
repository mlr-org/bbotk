# Convert to a Terminator

Convert object to a
[Terminator](https://bbotk.mlr-org.com/reference/Terminator.md) or a
list of [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md).

## Usage

``` r
as_terminator(x, ...)

# S3 method for class 'Terminator'
as_terminator(x, clone = FALSE, ...)

as_terminators(x, ...)

# Default S3 method
as_terminators(x, ...)

# S3 method for class 'list'
as_terminators(x, ...)
```

## Arguments

- x:

  (any)  
  Object to convert.

- ...:

  (any)  
  Additional arguments.

- clone:

  (`logical(1)`)  
  If `TRUE`, ensures that the returned object is not the same as the
  input `x`.

## See also

[Terminator](https://bbotk.mlr-org.com/reference/Terminator.md)
