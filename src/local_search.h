#ifndef LOCAL_SEARCH_H
#define LOCAL_SEARCH_H

#include <R.h>
#include <Rinternals.h>

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