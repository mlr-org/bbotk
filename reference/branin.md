# Branin Function

Classic 2-D Branin function with noise `branin(x1, x2, noise)` and
Branin function with fidelity parameter `branin_wu(x1, x2, fidelity)`.

## Usage

``` r
branin(x1, x2, noise = 0)

branin_wu(x1, x2, fidelity)
```

## Source

Wu J, Toscano-Palmerin S, Frazier PI, Wilson AG (2019). “Practical
Multi-fidelity Bayesian Optimization for Hyperparameter Tuning.”
1903.04703.

## Arguments

- x1:

  ([`numeric()`](https://rdrr.io/r/base/numeric.html)).

- x2:

  ([`numeric()`](https://rdrr.io/r/base/numeric.html)).

- noise:

  ([`numeric()`](https://rdrr.io/r/base/numeric.html)).

- fidelity:

  ([`numeric()`](https://rdrr.io/r/base/numeric.html)).

## Value

[`numeric()`](https://rdrr.io/r/base/numeric.html)

## Examples

``` r
branin(x1 = 12, x2 = 2, noise = 0.05)
#> [1] 30.38063
branin_wu(x1 = 12, x2 = 2, fidelity = 1)
#> [1] 30.38063
```
