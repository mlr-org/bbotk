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
    * sd=0.1 might not work for ints? 
    * we need to implement the stopping crit from python
    * read the python code and compare
    * check docs of all exposed R functions
    * allow to set initial points in LS R function
    * if we stagnate for a single LS, we could restart it?
    * properly document the function interface. maybe we need to have an "internal" check one?
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


// control info for local search
typedef struct {
  int minimize;
  double obj_mult;
  int n_searches;
  int n_steps;
  int n_neighs;
  double mut_sd;
  int stagnate_max;
} Control;


int random_int(int a, int b);
double random_normal(double mean, double sd);

SEXP dt_generate_PROTECT(int n, SearchSpace *ss);
void dt_set_na(SEXP s_dt, int row_i, int param_j);
int dt_is_na(SEXP s_dt, int row_i, int param_j);
void dt_set_random(SEXP s_dt, int row_i, int param_j, const SearchSpace *ss);
void dt_set_random_row(SEXP s_dt, int row_i, const SearchSpace *ss);
void dt_mutate_element(SEXP s_dt, int row_i, int param_j, const SearchSpace *ss, const Control* ctrl);
void dt_repair_row(SEXP s_dt, int row_i, const SearchSpace *ss);
void restart_stagnated_searches(SEXP s_pop_x, int *stagnate_count, const SearchSpace* ss, const Control* ctrl);
void check_and_fix_param_value(SEXP s_dt, int row_i, int param_j, int all_conds_satisfied, const SearchSpace *ss);

void extract_ss_info_PROTECT(SEXP s_ss, SearchSpace *ss);
int find_param_index(const char *param_name, const SearchSpace *ss);
void extract_ctrl_info(SEXP s_ctrl, Control* ctrl);
void toposort_params(SearchSpace *ss);
void reorder_conds_by_toposort(SearchSpace *ss);
int is_condition_satisfied(SEXP s_neighs_x, int i, const Cond *cond, const SearchSpace* ss);


void generate_neighs(SEXP s_pop_x, SEXP s_neighs_x, const SearchSpace* ss, const Control* ctrl);
void copy_best_neighs_to_pop(SEXP s_neighs_x, double* neighs_y, SEXP s_pop_x, double *pop_y, 
  int* stagnate_count, const SearchSpace* ss, const Control* ctrl);
SEXP c_local_search(SEXP s_obj, SEXP s_ss, SEXP s_ctrl, SEXP s_initial_x);
SEXP get_best_pop_element_PROTECT(SEXP s_pop_x, const double* pop_y, const SearchSpace* ss, const Control* ctrl);

#endif // LOCAL_SEARCH_H