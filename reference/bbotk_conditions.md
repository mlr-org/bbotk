# Condition Classes for bbotk

Condition classes for bbotk.

## Usage

``` r
error_bbotk(msg, ..., class = NULL, signal = TRUE, parent = NULL)

error_bbotk_terminated(msg, ..., class = NULL, signal = TRUE, parent = NULL)
```

## Arguments

- msg:

  (`character(1)`)  
  Error message.

- ...:

  (any)  
  Passed to [`sprintf()`](https://rdrr.io/r/base/sprintf.html).

- class:

  (`character`)  
  Additional class(es).

- signal:

  (`logical(1)`)  
  If `FALSE`, the condition object is returned instead of being
  signaled.

- parent:

  (`condition`)  
  Parent condition.

## Errors

- `error_bbotk()` for the `Mlr3ErrorBbotk` class, signalling a general
  bbotk error.

- `error_bbotk_terminated()` for the `Mlr3ErrorBbotkTerminated` class,
  signalling a termination error.
