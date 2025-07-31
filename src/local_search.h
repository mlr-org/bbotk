#ifndef LOCAL_SEARCH_H
#define LOCAL_SEARCH_H

#include <R.h>
#include <Rinternals.h>


/*
Local Search

Implements a local search very similar to what is used in SMAC for acquisition function optimization
of mixed type search spaces with hierarchical dependencies.
https://github.com/automl/SMAC3/blob/main/smac/acquisition/maximizer/local_search.py

We run "n_searches" in parallel. Each search runs "n_steps" iterations.
For each search in every iteration we generate "n_neighs" neighbors.
A neighbor is the current point, but with exactly one parameter mutated.

-------------------------------------------------------

Mutation works like this:
For num params: we scale to 0,1, add Gaussian noise with sd "mut_sd", and scale back.
We then clip to the lower and upper bounds.
For int params: We do the same as for numeric parameters, but round at the end.
For factor params: We sample a new level from the unused levels of the parameter.
For logical params: We flip the bit.

-------------------------------------------------------

After the neighbors are generated, we evaluate them.
We go to the best neighbor, or stay at the current point if the best neighbor is worse.

-------------------------------------------------------

The function always minimizes. If the objective is to be maximized, we handle it
by multiplying with "obj_mult" (which will be -1).

*/

/*
//FIXME:
    * LS must be elitist
    * we need to also mutate parent params
*/

// Debug printer system - can be switched on/off
#define DEBUG_ENABLED 1  // Set to 1 to enable debug output

#if DEBUG_ENABLED
#define DEBUG_PRINT(fmt, ...) Rprintf(fmt, ##__VA_ARGS__)
#else
#define DEBUG_PRINT(fmt, ...) do {} while(0)
#endif





// Condition struct for parameter dependencies
typedef struct {
  int param_index;  // Index of the parameter that has the dependency
  int parent_index; // Index of the parent parameter
  int type;         // 0=CondEqual, 1=CondAnyOf (or similar)
  SEXP s_rhs;       // SEXP containing the RHS values (preserves original types)
} Cond;

// Data structures for search space information
typedef struct {
  int n_params;
  int *param_classes; // 0=ParamDbl, 1=ParamInt, 2=ParamFct, 3=ParamLgl
  double *lower;
  double *upper;
  int *n_levels;
  const char ***level_names; // Array of arrays of level names for factors, only
                             // used for factors (not logicals)
  const char **param_names;  // Parameter names for data.table columns

  // Array of condition objects
  Cond *conds;
  int n_conds;

  // Topologically sorted parameter indices (parameters that depend on others
  // come after them)
  int *sorted_param_indices;
} SearchSpace;

void extract_ss_info(SEXP s_ss, SearchSpace *ss);
int find_param_index(const char *param_name, SearchSpace *ss);

#endif // LOCAL_SEARCH_H