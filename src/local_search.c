#include "local_search.h"
#include "rc_helpers.h"

#include <Rmath.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <assert.h>

// print a data.table row (for debugging)
void dt_print_row(SEXP dt, int row) {
#if DEBUG_ENABLED
    int ncol = length(dt);
    if (ncol == 0) {
        Rprintf("<empty data.table>\n");
        return;
    }
    SEXP s_col_names = getAttrib(dt, R_NamesSymbol);
    // Print column names
    for (int j = 0; j < ncol; j++) {
        Rprintf("%10s ", CHAR(STRING_ELT(s_col_names, j)));
    }
    Rprintf("\n");
    for (int j = 0; j < ncol; j++) {
        SEXP col = VECTOR_ELT(dt, j);
        switch(TYPEOF(col)) {
            case REALSXP:
                Rprintf("%10.4f ", REAL(col)[row]);
                break;
            case INTSXP:
                Rprintf("%10d ", INTEGER(col)[row]);
                break;
            case LGLSXP:
                Rprintf("%10s ", LOGICAL(col)[row] ? "TRUE" : "FALSE");
                break;
            case STRSXP:
                Rprintf("%10s ", CHAR(STRING_ELT(col, row)));
                break;
            default:
                Rprintf("%10s ", "?");
        }
    }
    Rprintf("\n");
#endif
}
// print a data.table (for debugging)
void dt_print(SEXP dt, int nrows_max) {
#if DEBUG_ENABLED
    int ncol = length(dt);
    if (ncol == 0) {
        Rprintf("<empty data.table>\n");
        return;
    }
    SEXP s_col_names = getAttrib(dt, R_NamesSymbol);
    int nrow = length(VECTOR_ELT(dt, 0));
    if (nrow == 0) {
        Rprintf("<data.table with 0 rows>\n");
        return;
    }
    int nrows = nrow < nrows_max ? nrow : nrows_max;
    // Print column names
    for (int j = 0; j < ncol; j++) {
        Rprintf("%10s ", CHAR(STRING_ELT(s_col_names, j)));
    }
    Rprintf("\n");
    // Print rows
    for (int i = 0; i < nrows; i++) {
        for (int j = 0; j < ncol; j++) {
            SEXP col = VECTOR_ELT(dt, j);
            switch(TYPEOF(col)) {
                case REALSXP:
                    Rprintf("%10.4f ", REAL(col)[i]);
                    break;
                case INTSXP:
                    Rprintf("%10d ", INTEGER(col)[i]);
                    break;
                case LGLSXP:
                    Rprintf("%10s ", LOGICAL(col)[i] ? "TRUE" : "FALSE");
                    break;
                case STRSXP:
                    Rprintf("%10s ", CHAR(STRING_ELT(col, i)));
                    break;
                default:
                    Rprintf("%10s ", "?");
            }
        }
        Rprintf("\n");
    }
    if (nrow > nrows) {
        Rprintf("... (%d more rows)\n", nrow - nrows);
    }
#endif
}


// Helper function to get random number from R, they respect the RNG state and the seed
// Helper function to get random integer between a and b (inclusive)
int random_int(int a, int b) {
    // Use proper integer arithmetic to avoid bias
    return a + (int)(unif_rand() * (b - a + 1));
}

// Helper function to get random normal distribution
double random_normal(double mean, double sd) {
    return rnorm(mean, sd);
}

/************ DT functions ********** */

// Check if a DT element is NA
int dt_is_na(SEXP s_dt, int row_i, int param_j) {
    SEXP s_col = VECTOR_ELT(s_dt, param_j);
    switch(TYPEOF(s_col)) {
        case REALSXP:
            return ISNA(REAL(s_col)[row_i]);
        case INTSXP:
            return INTEGER(s_col)[row_i] == NA_INTEGER;
        case LGLSXP:
            return LOGICAL(s_col)[row_i] == NA_LOGICAL;
        case STRSXP:
            return STRING_ELT(s_col, row_i) == NA_STRING;
    }
    // this should never happen...
    assert(0);
    return 0;
}

// Set a DT element to NA
void dt_set_na(SEXP s_dt, int row_i, int param_j) {
    SEXP s_col = VECTOR_ELT(s_dt, param_j);
    switch (TYPEOF(s_col)) {
        case REALSXP:
            REAL(s_col)[row_i] = NA_REAL; break;
        case INTSXP:
            INTEGER(s_col)[row_i] = NA_INTEGER; break;
        case STRSXP:
            SET_STRING_ELT(s_col, row_i, NA_STRING); break;
        case LGLSXP:
            LOGICAL(s_col)[row_i] = NA_LOGICAL; break;
    }
}

// Create an uninitialized data.table with col types from SearchSpace
// Return DT is PROTECTed and must be unprotected by the caller
SEXP dt_generate_PROTECT(int n, SearchSpace* ss) {
    SEXP s_dt = PROTECT(allocVector(VECSXP, ss->n_params));
    for (int j = 0; j < ss->n_params; j++) {
        int param_class = ss->param_classes[j];
        SEXP col;
        if (param_class == 0) { // ParamDbl
            col = PROTECT(allocVector(REALSXP, n));
        } else if (param_class == 1) { // ParamInt
            col = PROTECT(allocVector(INTSXP, n));
        } else if (param_class == 2) { // ParamFct
            col = PROTECT(allocVector(STRSXP, n));
        } else { // ParamLgl
            col = PROTECT(allocVector(LGLSXP, n));
        }
        SET_VECTOR_ELT(s_dt, j, col);
        UNPROTECT(1); // col
    }
    // Set column names
    SEXP s_colnames = PROTECT(allocVector(STRSXP, ss->n_params));
    for (int j  = 0; j < ss->n_params; j++) {
        SET_STRING_ELT(s_colnames, j, mkChar(ss->param_names[j]));
    }
    setAttrib(s_dt, R_NamesSymbol, s_colnames);
    // Set class to data.table
    SEXP class_attr = PROTECT(allocVector(STRSXP, 2));
    SET_STRING_ELT(class_attr, 0, mkChar("data.table"));
    SET_STRING_ELT(class_attr, 1, mkChar("data.frame"));
    setAttrib(s_dt, R_ClassSymbol, class_attr);

    // set row names
    SEXP s_rownames = PROTECT(allocVector(INTSXP, n));
    for (int i = 0; i < n; i++) {
      INTEGER(s_rownames)[i] = i + 1;
    }
    setAttrib(s_dt, R_RowNamesSymbol, s_rownames);

    // Set .internal.selfref attribute for data.table
    SEXP selfref = PROTECT(allocVector(INTSXP, 1));
    INTEGER(selfref)[0] = NA_INTEGER;
    setAttrib(s_dt, Rf_install(".internal.selfref"), selfref);

    UNPROTECT(4); // colnames, rownames, class_attr, selfref
    return s_dt;
}

// Helper function mutate a single element of a config (in a DT)
void dt_mutate_element(SEXP s_dt, int row_i, int param_j, const SearchSpace* ss, const Control* ctrl) {
    // we only mutate elements that are not NA
    assert(!dt_is_na(s_dt, row_i, param_j));
    int param_class = ss->param_classes[param_j];
    SEXP s_neigh_col = VECTOR_ELT(s_dt, param_j);
    if (param_class == 0) { // ParamDbl
        // normalize to [0,1], add noise, rescale to [lower, upper], clip to [lower, upper]
        double *neigh_col = REAL(s_neigh_col);
        double value = neigh_col[row_i];
        double lower = ss->lower[param_j];
        double upper = ss->upper[param_j];
        double range = upper - lower;
        if (range > 1e-8) { // avoid division by zero, be safe
          value = (value - lower) / range;
          value += random_normal(0.0, ctrl->mut_sd);
          value = value * range + lower;
          if (value < lower) value = lower;
          if (value > upper) value = upper;
          neigh_col[row_i] = value;
        }
    } else if (param_class == 1) { // ParamInt
        // same as ParamDbl but round and cast to int
        int *neigh_col = INTEGER(s_neigh_col);
        double value = (double) neigh_col[row_i];
        double lower = ss->lower[param_j];
        double upper = ss->upper[param_j];
        double range = upper - lower;
        if (range > 1e-8) { // avoid division by zero, be safe
            value = (value - lower) / range;
            value += random_normal(0.0, ctrl->mut_sd);
            value = (int) round(value * range + lower);
            if (value < lower) value = (int) lower;
            if (value > upper) value = (int) upper;
            neigh_col[row_i] = value;
        }
    } else if (param_class == 2) {    // ParamFct
        // sample uniformly from the other levels
        int n_levels = ss->n_levels[param_j];
        if (n_levels > 1) {
            // Find current level index
            const char* current_level = CHAR(STRING_ELT(s_neigh_col, row_i));
            int current_idx = 0;
            while (current_idx < n_levels &&
              strncmp(current_level, ss->level_names[param_j][current_idx], strlen(current_level)) != 0)
            {
                current_idx++;
            }
            // Sample from other levels using shift trick
            int new_idx = random_int(0, n_levels - 2);
            if (new_idx >= current_idx) new_idx++;
            SET_STRING_ELT(s_neigh_col, row_i, mkChar(ss->level_names[param_j][new_idx]));
        }
    } else if (param_class == 3) { // ParamLgl
        // flip the value
        LOGICAL(s_neigh_col)[row_i] ^= 1;
    }
}

// Set a single element of a config (in a DT) to a random value
void dt_set_random(SEXP s_dt, int row_i, int param_j, const SearchSpace* ss) {
  int param_class = ss->param_classes[param_j];
  SEXP s_col = VECTOR_ELT(s_dt, param_j);
  if (param_class == 0) { // ParamDbl
    REAL(s_col)[row_i] = runif(ss->lower[param_j], ss->upper[param_j]);
  } else if (param_class == 1) { // ParamInt
    INTEGER(s_col)[row_i] = random_int(ss->lower[param_j], ss->upper[param_j]);
  } else if (param_class == 2) {    // ParamFct
      int lev = random_int(0, ss->n_levels[param_j] - 1);
      SET_STRING_ELT(s_col, row_i, mkChar(ss->level_names[param_j][lev]));
  } else if (param_class == 3) { // ParamLgl
      LOGICAL(s_col)[row_i] = random_int(0, 1);
  }
}





/************ General functions for R data types *********** */



/************ try-eval-catch *********** */

// internal function to evaluate an expression in the global environment
SEXP try_eval(void *data) {
    return Rf_eval((SEXP) data, R_GlobalEnv);
}

// internal function to handle what happens in the catch block
// if the terminator triggers, we return NIL, otherwise we raise error back to R
SEXP catch_condition(SEXP s_condition, void *data) {
    DEBUG_PRINT("Caught R condition of class: %s\n",
        CHAR(STRING_ELT(Rf_getAttrib(s_condition, R_ClassSymbol), 0)));
    if (!Rf_inherits(s_condition, "terminator_exception")) {
        SEXP stop_call = Rf_lang2(Rf_install("stop"), s_condition);
        Rf_eval(stop_call, R_GlobalEnv);
    }
    return R_NilValue;
}

// main function so we can eval expression with try-catch
// FIXME: we could set objective function call a bit more directly here?
SEXP safe_eval(SEXP expr) {
    return R_tryCatchError(try_eval, expr, catch_condition, NULL);
}



/************ SearchSpace functions ********** */
// Find parameter index by name, -1 if not found (should not happen)
int find_param_index(const char* param_name, const SearchSpace* ss) {
    for (int j = 0; j < ss->n_params; j++) {
        if (strncmp(ss->param_names[j], param_name, strlen(param_name)) == 0) {
            return j;
        }
    }
    return -1; // Parameter not found
}

// convert paradox SearchSpace to C SearchSpace
// the function proectes the rhs parts of the conditions, caller must unprotect them (ss->conds times)
void extract_ss_info_PROTECT(SEXP s_ss, SearchSpace* ss) {
    ss->n_params = asInteger(RC_get_r6_el_by_name(s_ss, "length"));
    SEXP s_data = RC_get_r6_el_by_name(s_ss, "data");

    // copy lower and upper bounds
    ss->lower = (double*) R_alloc(ss->n_params, sizeof(double));
    ss->upper = (double*) R_alloc(ss->n_params, sizeof(double));
    const double* lower = REAL(RC_get_dt_col_by_name(s_data, "lower"));
    const double* upper = REAL(RC_get_dt_col_by_name(s_data, "upper"));
    for (int i = 0; i < ss->n_params; i++) {
        ss->lower[i] = lower[i];
        ss->upper[i] = upper[i];
    }

    // copy nlevels
    // paradox stores nlevels as double because for ParamDbl nlevels is Inf
    // The code below only works because we never access the nlevels of ParamDbl
    ss->n_levels = (int*) R_alloc(ss->n_params, sizeof(int));
    double* nlevels = REAL(RC_get_dt_col_by_name(s_data, "nlevels"));
    for (int i = 0; i < ss->n_params; i++) {
        ss->n_levels[i] = (int)nlevels[i];
    }

    // copy param_classes
    ss->param_classes = (int*) R_alloc(ss->n_params, sizeof(int));
    SEXP s_classes = RC_get_dt_col_by_name(s_data, "class");
    for (int i = 0; i < ss->n_params; i++) {
        const char* class_name = CHAR(STRING_ELT(s_classes, i));
        if (strncmp(class_name, "ParamDbl", 8) == 0) {
            ss->param_classes[i] = 0;
        } else if (strncmp(class_name, "ParamInt", 8) == 0) {
            ss->param_classes[i] = 1;
        } else if (strncmp(class_name, "ParamFct", 8) == 0) {
            ss->param_classes[i] = 2;
        } else if (strncmp(class_name, "ParamLgl", 8) == 0) {
            ss->param_classes[i] = 3;
        }
    }

    // copy param_names (just store pointers to R's string pool)
    ss->param_names = (const char**) R_alloc(ss->n_params, sizeof(char*));
    SEXP s_ids = RC_get_dt_col_by_name(s_data, "id");
    for (int i = 0; i < ss->n_params; i++) {
        ss->param_names[i] = CHAR(STRING_ELT(s_ids, i));
    }

    // copy level_names (just store pointers to R's string pool)
    ss->level_names = (const char***) R_alloc(ss->n_params, sizeof(char**));
    SEXP s_ps_levels = RC_get_dt_col_by_name(s_data, "levels");
    for (int i = 0; i < ss->n_params; i++) {
        if (ss->param_classes[i] == 2 ) { // ParamFct
            SEXP s_p_levels = VECTOR_ELT(s_ps_levels, i);
            int n_levels = ss->n_levels[i];
            ss->level_names[i] = (const char**) R_alloc(n_levels, sizeof(char*));
            for (int k = 0; k < n_levels; k++) {
                ss->level_names[i][k] = CHAR(STRING_ELT(s_p_levels, k));
            }
        } else {
            ss->level_names[i] = NULL;
        }
    }

    DEBUG_PRINT("extracting conditions\n");
    SEXP s_deps = RC_get_r6_el_by_name(s_ss, "deps");
    SEXP s_deps_on = RC_get_dt_col_by_name(s_deps, "on");
    SEXP s_deps_id = RC_get_dt_col_by_name(s_deps, "id");
    DEBUG_PRINT("s_deps_id type: %d\n", TYPEOF(s_deps_id));
    SEXP s_deps_cond = RC_get_dt_col_by_name(s_deps, "cond");
    ss->n_conds = length(s_deps_on);
    Cond *conds = NULL;
    if (ss->n_conds != 0) {
      conds = (Cond*) R_alloc(ss->n_conds, sizeof(Cond));
      for (int i = 0; i < ss->n_conds; i++) {
        const char *param_name = CHAR(STRING_ELT(s_deps_id, i));
        conds[i].param_index = find_param_index(param_name, ss);
        const char *parent_name = CHAR(STRING_ELT(s_deps_on, i));
        conds[i].parent_index = find_param_index(parent_name, ss);
        // Extract condition information
        SEXP s_cond = VECTOR_ELT(s_deps_cond, i);
        conds[i].type = Rf_inherits(s_cond, "CondEqual") ? 0 : 1; // 0=CondEqual, 1=CondAnyOf
        // store RHS SEXP so we dont have to type-convert, but protect it from gc
        conds[i].s_rhs = PROTECT(RC_get_list_el_by_name(s_cond, "rhs"));
        DEBUG_PRINT("cond %d: param_index %d, parent_index %d, type %d, rhs type %d\n",
            i, conds[i].param_index, conds[i].parent_index, conds[i].type, TYPEOF(conds[i].s_rhs));
      }
    }
    ss->conds = conds;
}

void extract_ctrl_info(SEXP s_ctrl, Control* ctrl) {
    ctrl->minimize = asInteger(RC_get_list_el_by_name(s_ctrl, "minimize"));
    ctrl->obj_mult = ctrl->minimize ? 1 : -1;
    ctrl->n_searches = asInteger(RC_get_list_el_by_name(s_ctrl, "n_searches"));
    ctrl->n_steps = asInteger(RC_get_list_el_by_name(s_ctrl, "n_steps"));
    ctrl->n_neighs = asInteger(RC_get_list_el_by_name(s_ctrl, "n_neighs"));
    ctrl->mut_sd = asReal(RC_get_list_el_by_name(s_ctrl, "mut_sd"));
    ctrl->stagnate_max = asInteger(RC_get_list_el_by_name(s_ctrl, "stagnate_max"));
    assert(ctrl->n_searches > 0);
    assert(ctrl->n_steps >= 0);
    assert(ctrl->n_neighs > 0);
    assert(ctrl->mut_sd > 0);
}


/************ Condition functions ********** */

// topological sort of parameters based on dependencies
// if param B depends on param A, then B comes after A in the sort
void toposort_params(SearchSpace* ss) {
    int* sorted = (int*) R_alloc(ss->n_params, sizeof(int));
    int* deps = (int*) R_alloc(ss->n_params, sizeof(int));
    memset(deps, 0, ss->n_params * sizeof(int));
    int count = 0;
    // Count dependencies for each parameter
    for (int i = 0; i < ss->n_conds; i++) {
        deps[ss->conds[i].param_index]++;
    }
    // Add parameters with no dependencies first
    for (int i = 0; i < ss->n_params; i++) {
        if (deps[i] == 0) sorted[count++] = i;
    }
    // For each param in the sorted list, we decrement the deps of all params that depend on it
    // the add all params to the sorted list that have no deps left, then iterate again
    for (int i = 0; i < count; i++) {
        for (int j = 0; j < ss->n_conds; j++) {
            if (ss->conds[j].parent_index == sorted[i]) {
                int dep = ss->conds[j].param_index;
                if (--deps[dep] == 0) sorted[count++] = dep;
            }
        }
    }
    assert(count == ss->n_params);
    ss->sorted_param_indices = sorted;
}

// Reorder conditions based on topological sort
// Conditions come in "blocks", so all conds for param A are next to each other
void reorder_conds_by_toposort(SearchSpace* ss) {
    if (ss->n_conds <= 1) return;
    Cond* reordered_conds = (Cond*) R_alloc(ss->n_conds, sizeof(Cond));
    int reordered_count = 0;
    // go thru params in topological order, collect all conds for current param
    for (int i = 0; i < ss->n_params; i++) {
        int param_index = ss->sorted_param_indices[i];
        // Find all conditions for this parameter
        for (int j = 0; j < ss->n_conds; j++) {
            if (ss->conds[j].param_index == param_index) {
                reordered_conds[reordered_count++] = ss->conds[j];
            }
        }
    }
    assert(reordered_count == ss->n_conds);
    // copy back to original array
    for (int i = 0; i < ss->n_conds; i++) {
        ss->conds[i] = reordered_conds[i];
    }
}


// Check if a condition is satisfied for a given row
// whether a confition is satisfied ONLY depends on the value of the parent parameter,
// not the condition-param itself
// if the parent parameter is NA the condition is not satisfied, as the parent is non-active
// (i dont think we want to allow that a subordinate is only active when the super parameter is non-active)
int is_condition_satisfied(SEXP s_neighs_x, int i, const Cond *cond, const SearchSpace* ss) {
    SEXP s_parent_col = VECTOR_ELT(s_neighs_x, cond->parent_index);
    int parent_class = ss->param_classes[cond->parent_index];
    SEXP s_rhs = cond->s_rhs;
    int is_satisfied = 0;
    DEBUG_PRINT("is_condition_satisfied: row %d, param %s, parent %s, parent_class %d, cond-type %d\n",
        i, ss->param_names[cond->param_index], ss->param_names[cond->parent_index], parent_class, cond->type);
    // if the parent parameter is NA and hence non-active, the condition is not satisfied
    if (dt_is_na(s_neighs_x, i, cond->parent_index)) {
        return 0;
    }

    if (cond->type == 0) { // CondEqual, check if parent value equals the RHS value
        if (parent_class == 0) { // ParamDbl
            is_satisfied = fabs(REAL(s_parent_col)[i] - REAL(s_rhs)[0]) < 1e-8;
        } else if (parent_class == 1) { // ParamInt
            is_satisfied = INTEGER(s_parent_col)[i] == INTEGER(s_rhs)[0];
        } else if (parent_class == 2) { // ParamFct
            is_satisfied = strcmp(CHAR(STRING_ELT(s_parent_col, i)), CHAR(STRING_ELT(s_rhs, 0))) == 0;
        } else { // ParamLgl
            is_satisfied = LOGICAL(s_parent_col)[i] == LOGICAL(s_rhs)[0];
        }
    } else { // CondAnyOf, check if parent value is in the RHS values
        int n_rhs = length(s_rhs);
        for (int k = 0; k < n_rhs; k++) {
            if (parent_class == 0) { // ParamDbl
                is_satisfied = (fabs(REAL(s_parent_col)[i] - REAL(s_rhs)[k]) < 1e-8);
            } else if (parent_class == 1) { // ParamInt
                is_satisfied = (INTEGER(s_parent_col)[i] == INTEGER(s_rhs)[k]);
            } else if (parent_class == 2) { // ParamFct
                is_satisfied = (strcmp(CHAR(STRING_ELT(s_parent_col, i)), CHAR(STRING_ELT(s_rhs, k))) == 0);
            } else { // ParamLgl
                is_satisfied = (LOGICAL(s_parent_col)[i] == LOGICAL(s_rhs)[k]);
            }
        }
    }
    return is_satisfied;
}



/************ Local search functions ********** */

// Generate neighbors for all current points in an existing data.table
void generate_neighs(SEXP s_pop_x, SEXP s_neighs_x, const SearchSpace* ss, const Control* ctrl) {
    DEBUG_PRINT("generate_neighs\n");

    // Copy current points to neighbors -- we replicate each candidate n_neighs times
    // we iterate over the parameters / cols first
    for (int j = 0; j < ss->n_params; j++) {
        int param_class = ss->param_classes[j];
        SEXP s_pop_col = VECTOR_ELT(s_pop_x, j);
        SEXP s_neigh_col = VECTOR_ELT(s_neighs_x, j);
        for (int i_pop = 0; i_pop < ctrl->n_searches; i_pop++) {
            for (int k = 0; k < ctrl->n_neighs; k++) {
                int i_neigh = i_pop * ctrl->n_neighs + k;
                if (param_class == 0) { // ParamDbl
                    REAL(s_neigh_col)[i_neigh] = REAL(s_pop_col)[i_pop];
                } else if (param_class == 1) { // ParamInt
                    INTEGER(s_neigh_col)[i_neigh] = INTEGER(s_pop_col)[i_pop];
                } else if (param_class == 2) {    // ParamFct
                    SET_STRING_ELT(s_neigh_col, i_neigh, STRING_ELT(s_pop_col, i_pop));
                } else { // ParamLgl
                    LOGICAL(s_neigh_col)[i_neigh] = LOGICAL(s_pop_col)[i_pop];
                }
            }
        }
    }
    DEBUG_PRINT("copied %d points to %d neighbors\n", ctrl->n_searches, ctrl->n_searches * ctrl->n_neighs);
    dt_print(s_neighs_x, 10);

    // Now mutate one parameter for each neighbor
    for (int i_neigh = 0; i_neigh < ctrl->n_searches * ctrl->n_neighs; i_neigh++) {
        // Find valid mutable parameters for this neighbor (non-NA values)
        int* valid_mutable_indices = (int*) R_alloc(ss->n_params, sizeof(int));
        int n_valid_mutable = 0;

        for (int j = 0; j < ss->n_params; j++) {
            if (!dt_is_na(s_neighs_x, i_neigh, j)) {
                valid_mutable_indices[n_valid_mutable++] = j;
            }
        }

        // Only proceed if we have valid mutable parameters
        if (n_valid_mutable > 0) {
            // Select a random valid mutable parameter
            int j = valid_mutable_indices[random_int(0, n_valid_mutable - 1)];

            DEBUG_PRINT("Neighbor %d: selected parameter %d (%s) for mutation from %d valid options\n",
                i_neigh, j, ss->param_names[j], n_valid_mutable);
            dt_mutate_element(s_neighs_x, i_neigh, j, ss, ctrl);
            DEBUG_PRINT("before checks:\n");
            dt_print_row(s_neighs_x, i_neigh);
            dt_repair_row(s_neighs_x, i_neigh, ss);
        } else {
            DEBUG_PRINT("Neighbor %d: no valid mutable parameters found (all are NA)\n", i_neigh);
        }
    }
    DEBUG_PRINT("generate_s_neighs_x done\n");
}

// Copy the best neighbor from each block into the population
// Also update global best-so-far when an improvement is found
void copy_best_neighs_to_pop(SEXP s_neighs_x, double* neighs_y,
  SEXP s_pop_x, double *pop_y, int* stagnate_count,
  double *global_best_y, SEXP s_global_best_x,
  const SearchSpace* ss, const Control* ctrl) {

    DEBUG_PRINT("copy_best_neighs_to_pop\n");

    for (int pop_i = 0; pop_i < ctrl->n_searches; pop_i++) {
        // Find the best neighbor in this block
        int best_i = -1;
        double best_y = pop_y[pop_i];

        for (int k = 0; k < ctrl->n_neighs; k++) {
            int neigh_i = pop_i * ctrl->n_neighs + k;
            double current_y = neighs_y[neigh_i];

            if (current_y < best_y) {
                best_y = current_y;
                best_i = neigh_i;
            }
        }

        if (best_i == -1) {
            DEBUG_PRINT("No better neighbor found, keep current point: %d\n", pop_i);
            stagnate_count[pop_i]++;
            continue;
        } else {
            // Copy the best neighbor to the population
            DEBUG_PRINT("Best neighbor for search %d is at index %d with value %f\n", pop_i, best_i, best_y);
            for (int j = 0; j < ss->n_params; j++) {
                int param_class = ss->param_classes[j];
                SEXP s_neigh_col = VECTOR_ELT(s_neighs_x, j);
                SEXP s_pop_col = VECTOR_ELT(s_pop_x, j);

                if (param_class == 0) { // ParamDbl
                    REAL(s_pop_col)[pop_i] = REAL(s_neigh_col)[best_i];
                } else if (param_class == 1) { // ParamInt
                    INTEGER(s_pop_col)[pop_i] = INTEGER(s_neigh_col)[best_i];
                } else if (param_class == 2) { // ParamFct
                    SET_STRING_ELT(s_pop_col, pop_i, STRING_ELT(s_neigh_col, best_i));
                } else { // ParamLgl
                    LOGICAL(s_pop_col)[pop_i] = LOGICAL(s_neigh_col)[best_i];
                }
                stagnate_count[pop_i] = 0;
            }
            pop_y[pop_i] = best_y;
            // Update global best if improved
            if (best_y < *global_best_y) {
                *global_best_y = best_y;
                for (int j = 0; j < ss->n_params; j++) {
                    int param_class = ss->param_classes[j];
                    SEXP s_pop_col = VECTOR_ELT(s_pop_x, j);
                    if (param_class == 0) { // ParamDbl
                        SET_VECTOR_ELT(s_global_best_x, j, ScalarReal(REAL(s_pop_col)[pop_i]));
                    } else if (param_class == 1) { // ParamInt
                        SET_VECTOR_ELT(s_global_best_x, j, ScalarInteger(INTEGER(s_pop_col)[pop_i]));
                    } else if (param_class == 2) { // ParamFct
                        SET_VECTOR_ELT(s_global_best_x, j, ScalarString(STRING_ELT(s_pop_col, pop_i)));
                    } else { // ParamLgl
                        SET_VECTOR_ELT(s_global_best_x, j, ScalarLogical(LOGICAL(s_pop_col)[pop_i]));
                    }
                }
            }
        }
    }

    DEBUG_PRINT("copy_best_neighs_to_pop done\n");
}


int eval_obj(int n, SEXP s_x, SEXP s_obj, double* y, const Control* ctrl) {
    SEXP s_call = PROTECT(Rf_lang2(s_obj, s_x));
    SEXP s_y = PROTECT(safe_eval(s_call));
    int eval_ok = 0;
    if (s_y != R_NilValue) {
        memcpy(y, REAL(s_y), n * sizeof(double));
        // multiply by obj_mult to handle maximization
        for (int i = 0; i < n; i++) {
            y[i] *= ctrl->obj_mult;
        }
        eval_ok = 1;
    }
    UNPROTECT(2); // s_call, s_y
    return eval_ok;
}


SEXP get_best_pop_element_PROTECT(SEXP s_pop_x, const double* pop_y, const SearchSpace* ss, const Control* ctrl) {
    // find the best point in the population
    double best_y = pop_y[0];
    int best_i = 0;
    for (int i = 0; i < ctrl->n_searches; i++) {
        if (pop_y[i] < best_y) {
            best_y = pop_y[i];
            best_i = i;
        }
    }
    best_y *= ctrl->obj_mult; // convert to original scale
    SEXP s_res = RC_named_list_create_PROTECT(2, (const char*[]){"x", "y"});
    SEXP s_res_x = RC_named_list_create_PROTECT(ss->n_params, ss->param_names);


    for (int j = 0; j < ss->n_params; j++) {
      int param_class = ss->param_classes[j];
      SEXP s_pop_col = VECTOR_ELT(s_pop_x, j);

      if (param_class == 0) { // ParamDbl
          SET_VECTOR_ELT(s_res_x, j, ScalarReal(REAL(s_pop_col)[best_i]));
      } else if (param_class == 1) { // ParamInt
          SET_VECTOR_ELT(s_res_x, j, ScalarInteger(INTEGER(s_pop_col)[best_i]));
      } else if (param_class == 2) { // ParamFct
          SET_VECTOR_ELT(s_res_x, j, ScalarString(STRING_ELT(s_pop_col, best_i)));
      } else { // ParamLgl
          SET_VECTOR_ELT(s_res_x, j, ScalarLogical(LOGICAL(s_pop_col)[best_i]));
      }
    }
    SET_VECTOR_ELT(s_res, 0, s_res_x);
    SET_VECTOR_ELT(s_res, 1, ScalarReal(best_y));
    UNPROTECT(1); // s_res_x
    return s_res;
}

void restart_stagnated_searches(SEXP s_pop_x, double *pop_y, int *stagnate_count, const SearchSpace* ss, const Control* ctrl) {
  for (int i = 0; i < ctrl->n_searches; i++) {
    if (stagnate_count[i] >= ctrl->stagnate_max) { // restart if stagnated for too long
      DEBUG_PRINT("restarted search %d, stagnate_count: %d, stagnate_max: %d\n", i, stagnate_count[i], ctrl->stagnate_max);
      dt_set_random_row(s_pop_x, i, ss);
      dt_repair_row(s_pop_x, i, ss);
      // Force acceptance of a neighbor by setting current objective to +Inf
      pop_y[i] = R_PosInf;
      stagnate_count[i] = 0;
    }
  }
}

void dt_set_random_row(SEXP s_dt, int row_i, const SearchSpace* ss) {
  for (int j = 0; j < ss->n_params; j++) {
    dt_set_random(s_dt, row_i, j, ss);
  }
}

// fix a parameter value which is in conflict with its condition value´
// case 1: if any condition is not satisfied, set the parameter to NA
// case 2: if all conditions are satisfied, but the parameter is NA, set it to a random value
void check_and_fix_param_value(SEXP s_neighs_x, int neigh_i, int param_j, int all_conds_satisfied, const SearchSpace* ss) {
  if(!all_conds_satisfied) {
    DEBUG_PRINT("Setting parameter %s to NA.\n", ss->param_names[param_j]);
    dt_set_na(s_neighs_x, neigh_i, param_j);
  } else if (dt_is_na(s_neighs_x, neigh_i, param_j)) {
    DEBUG_PRINT("Setting parameter %s to random value.\n", ss->param_names[param_j]);
    dt_set_random(s_neighs_x, neigh_i, param_j, ss);
  }
}


void dt_repair_row(SEXP s_dt, int row_i, const SearchSpace* ss) {
  // Iterate through topologically sorted conditions
  int param_index_current = -1;
  int all_conds_satisfied = 1;
  for (int c = 0; c < ss->n_conds; c++) {
      Cond* cond = &ss->conds[c];
      if (param_index_current != cond->param_index) {
          // finished processing all conditions for a particular parameter
          // now see and fix if its value is in conflict with its conditions
          if (param_index_current > -1) {
              check_and_fix_param_value(s_dt, row_i, param_index_current, all_conds_satisfied, ss);
          }
          // reset values for next parameter
          all_conds_satisfied = 1;
          param_index_current = cond->param_index;
      }
      if (!is_condition_satisfied(s_dt, row_i, cond, ss)) {
          all_conds_satisfied = 0;
          DEBUG_PRINT("not satisfied:\n");
          dt_print_row(s_dt, row_i);
      } else {
          DEBUG_PRINT("satisfied:\n");
          dt_print_row(s_dt, row_i);
      }
  }
  // explicit check for the last condition
  if (ss->n_conds > 0) {
      check_and_fix_param_value(s_dt, row_i, param_index_current, all_conds_satisfied, ss);
  }

  DEBUG_PRINT("after repair:\n");
  dt_print_row(s_dt, row_i);
}


// R wrapper function - complete local search implementation
SEXP c_local_search(SEXP s_obj, SEXP s_ss, SEXP s_ctrl, SEXP s_initial_x) {
    GetRNGstate();

    SearchSpace ss;
    extract_ss_info_PROTECT(s_ss, &ss);
    toposort_params(&ss);
    reorder_conds_by_toposort(&ss);
    Control ctrl;
    extract_ctrl_info(s_ctrl, &ctrl);

    //print_search_space(&ss);

    // Use duplicate to copy initial points
    SEXP s_pop_x = PROTECT(duplicate(s_initial_x));
    dt_print(s_pop_x, 10);

    SEXP s_neighs_x = dt_generate_PROTECT(ctrl.n_searches * ctrl.n_neighs, &ss);

    // y-values for pop. we wil later write into this array
    double *pop_y = (double*) R_alloc(ctrl.n_searches, sizeof(double));
    double *neighs_y = (double*) R_alloc(ctrl.n_searches*ctrl.n_neighs, sizeof(double));
    int *stagnate_count = (int*) R_alloc(ctrl.n_searches, sizeof(int));
    memset(stagnate_count, 0, ctrl.n_searches * sizeof(int));
    int eval_ok;
    eval_ok = eval_obj(ctrl.n_searches, s_pop_x, s_obj, pop_y, &ctrl);

    // Initialize global best from current population
    double global_best_y = R_PosInf;
    int global_best_i = -1;
    if (eval_ok) {
        for (int i = 0; i < ctrl.n_searches; i++) {
            if (pop_y[i] < global_best_y) {
                global_best_y = pop_y[i];
                global_best_i = i;
            }
        }
    }
    SEXP s_global_best_x = RC_named_list_create_PROTECT(ss.n_params, ss.param_names);
    if (global_best_i >= 0) {
        for (int j = 0; j < ss.n_params; j++) {
            int param_class = ss.param_classes[j];
            SEXP s_pop_col = VECTOR_ELT(s_pop_x, j);
            if (param_class == 0) {
                SET_VECTOR_ELT(s_global_best_x, j, ScalarReal(REAL(s_pop_col)[global_best_i]));
            } else if (param_class == 1) {
                SET_VECTOR_ELT(s_global_best_x, j, ScalarInteger(INTEGER(s_pop_col)[global_best_i]));
            } else if (param_class == 2) {
                SET_VECTOR_ELT(s_global_best_x, j, ScalarString(STRING_ELT(s_pop_col, global_best_i)));
            } else {
                SET_VECTOR_ELT(s_global_best_x, j, ScalarLogical(LOGICAL(s_pop_col)[global_best_i]));
            }
        }
    }

    // we failed the terminator in the initial points, skip main loop
    if (eval_ok) {
        // Main local search loop
        for (int step = 0; step < ctrl.n_steps;  step++) {
            DEBUG_PRINT("step=%i\n", step);
            dt_print(s_pop_x, 10);

            restart_stagnated_searches(s_pop_x, pop_y, stagnate_count, &ss, &ctrl);
            generate_neighs(s_pop_x, s_neighs_x, &ss, &ctrl);
            // print_dt(s_neighs_x, 10);
            eval_ok = eval_obj(ctrl.n_searches*ctrl.n_neighs, s_neighs_x, s_obj, neighs_y, &ctrl);

            // copy if we have a valid result, otherwise we stop the loop
            if (eval_ok) {
                copy_best_neighs_to_pop(s_neighs_x, neighs_y, s_pop_x, pop_y, stagnate_count, &global_best_y, s_global_best_x, &ss, &ctrl);
            } else {
                break;
            }
        }
    }

    PutRNGstate();
    // Build result from global best (convert y back to original scale)
    double best_y_out = global_best_y * ctrl.obj_mult;
    SEXP s_res = RC_named_list_create_PROTECT(2, (const char*[]){"x", "y"});
    SET_VECTOR_ELT(s_res, 0, s_global_best_x);
    SET_VECTOR_ELT(s_res, 1, ScalarReal(best_y_out));
    UNPROTECT(4 + ss.n_conds); // s_pop_x, s_neighs_x, s_global_best_x, s_res, and cond rhs
    return s_res;
}
