# Local Search Control

Control parameters for local search optimizer, see
[`local_search()`](https://bbotk.mlr-org.com/reference/local_search.md)
for details.

## Usage

``` r
local_search_control(
  minimize = TRUE,
  n_searches = 10L,
  n_steps = 5L,
  n_neighs = 10L,
  mut_sd = 0.1,
  stagnate_max = 10L
)
```

## Arguments

- minimize:

  (`logical(1)`)  
  Whether to minimize the objective.

- n_searches:

  (`integer(1)`)  
  Number of local searches.

- n_steps:

  (`integer(1)`)  
  Number of steps per local search.

- n_neighs:

  (`integer(1)`)  
  Number of neighbors per local search.

- mut_sd:

  (`numeric(1)`)  
  Standard deviation of the mutation.

- stagnate_max:

  (`integer(1)`)  
  Maximum number of no-improvement steps for a local search before it is
  randomly restarted.

## Value

(`local_search_control`)  
List with control params as S3 object.
