#include <R.h>
#include <Rinternals.h>
#include <Rmath.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/* 
//FIXME:
    * R_alloc automatically handles memory cleanup
    * have to be careful if there are trafos or other weird thing in the search space??
    * terminator exception is not handled
    * we need to be sure that levels in R always are without gaps (ie no NA)
    * is the LS somehow elitist?
    * we have to check that we have at least some mutable parameters
    * we really need unit tests
        numeric, mixed case, hierachical, with trafos
    * check that we use obj_mult correctly
*/

// Debug printer system - can be switched on/off
#define DEBUG_ENABLED 0  // Set to 1 to enable debug output

#if DEBUG_ENABLED
#define DEBUG_PRINT(fmt, ...) Rprintf(fmt, ##__VA_ARGS__)
#else
#define DEBUG_PRINT(fmt, ...) do {} while(0)
#endif

// Data structures for search space information
typedef struct {
    int n_params;
    int* param_classes;  // 0=ParamDbl, 1=ParamInt, 2=ParamFct, 3=ParamLgl
    double* lower;
    double* upper;
    int* n_levels;
    char*** level_names;  // Array of arrays of level names for factors, only used for factors (not logicals)
    char** param_names;  // Parameter names for data.table columns
    int* mutable_params;  // 1 if parameter can be mutated, 0 if not (due to dependencies)
    // for efficient random selection
    int n_mutable_params;
    int* mutable_indices;
} SearchSpace;



SEXP get_list_el_by_name(SEXP list, const char *name) {
    SEXP elmt = R_NilValue, names = getAttrib(list, R_NamesSymbol);
    int i;
    for (i = 0; i < length(list); i++) {
        if(strcmp(CHAR(STRING_ELT(names, i)), name) == 0) {
            elmt = VECTOR_ELT(list, i);
            break;
        }
    }
    return elmt;
}

SEXP get_dt_col_by_name(SEXP dt, const char *name) {
    SEXP col_names = getAttrib(dt, R_NamesSymbol);
    for (int i = 0; i < length(dt); i++) {
        if (strcmp(CHAR(STRING_ELT(col_names, i)), name) == 0) {
            return VECTOR_ELT(dt, i);
        }
    }
    return R_NilValue; // Column not found
}

SEXP get_r6_el_by_name(SEXP r6, const char *str) {
    return Rf_findVar(Rf_install(str), r6);
}

void extract_ss_info(SEXP s_ss, SearchSpace* ss) {

    ss->n_params = asInteger(get_r6_el_by_name(s_ss, "length"));
    SEXP s_data = get_r6_el_by_name(s_ss, "data");

    // copy lower and upper bounds
    ss->lower = (double*) R_alloc(ss->n_params, sizeof(double));
    ss->upper = (double*) R_alloc(ss->n_params, sizeof(double));
    double* lower = REAL(get_dt_col_by_name(s_data, "lower"));
    double* upper = REAL(get_dt_col_by_name(s_data, "upper"));
    for (int i = 0; i < ss->n_params; i++) {
        ss->lower[i] = lower[i];
        ss->upper[i] = upper[i];
    }

    // copy nlevels
    // FIXME: it is weird that this is a double in paradox not an int
    ss->n_levels = (int*) R_alloc(ss->n_params, sizeof(int));
    double* nlevels = REAL(get_dt_col_by_name(s_data, "nlevels"));
    for (int i = 0; i < ss->n_params; i++) {
        ss->n_levels[i] = (int)nlevels[i];
    }

    // copy param_classes
    ss->param_classes = (int*) R_alloc(ss->n_params, sizeof(int));
    SEXP s_classes = get_dt_col_by_name(s_data, "class");
    for (int i = 0; i < ss->n_params; i++) {
        const char* class_name = CHAR(STRING_ELT(s_classes, i));
        if (strcmp(class_name, "ParamDbl") == 0) {
            ss->param_classes[i] = 0;
        } else if (strcmp(class_name, "ParamInt") == 0) {
            ss->param_classes[i] = 1;
        } else if (strcmp(class_name, "ParamFct") == 0) {
            ss->param_classes[i] = 2;
        } else if (strcmp(class_name, "ParamLgl") == 0) {
            ss->param_classes[i] = 3;
        }
    }

    // copy param_names
    ss->param_names = (char**) R_alloc(ss->n_params, sizeof(char*));
    SEXP s_ids = get_dt_col_by_name(s_data, "id");
    for (int i = 0; i < ss->n_params; i++) {
        const char* param_name = CHAR(STRING_ELT(s_ids, i));
        int len = strlen(param_name);
        ss->param_names[i] = (char*) R_alloc(len + 1, sizeof(char));
        strcpy(ss->param_names[i], param_name);
    }

    // copy level_names
    ss->level_names = (char***) R_alloc(ss->n_params, sizeof(char**));
    SEXP s_ps_levels = get_dt_col_by_name(s_data, "levels");
    for (int i = 0; i < ss->n_params; i++) {
        if (ss->param_classes[i] == 2 ) { // ParamFct 
            SEXP s_p_levels = VECTOR_ELT(s_ps_levels, i);
            int n_levels = ss->n_levels[i];
            ss->level_names[i] = (char**) R_alloc(n_levels, sizeof(char*));
            for (int k = 0; k < n_levels; k++) {
                const char* level_name = CHAR(STRING_ELT(s_p_levels, k));
                int len = strlen(level_name);
                ss->level_names[i][k] = (char*) R_alloc(len + 1, sizeof(char));
                strcpy(ss->level_names[i][k], level_name);
            }
        } else {
            ss->level_names[i] = NULL;
        }
    }

    // extract dependency information and determine which parameters can be mutated
    // Initialize all parameters as mutable
    ss->mutable_params = (int*) R_alloc(ss->n_params, sizeof(int));
    for (int i = 0; i < ss->n_params; i++) ss->mutable_params[i] = 1;
    SEXP s_deps = get_r6_el_by_name(s_ss, "deps");
    SEXP s_deps_on = get_dt_col_by_name(s_deps, "on");
    int n_deps_on = length(s_deps_on);
    for (int i = 0; i < n_deps_on; i++) {
        const char* parent_name = CHAR(STRING_ELT(s_deps_on, i));
        for (int j = 0; j < ss->n_params; j++) {
            if (strcmp(ss->param_names[j], parent_name) == 0) {
                ss->mutable_params[j] = 0;
                break;
            }
        }
    }
    // Count mutable parameters and create index array
    ss->n_mutable_params = 0;
    for (int i = 0; i < ss->n_params; i++) {
        if (ss->mutable_params[i]) ss->n_mutable_params++;
    }
    ss->mutable_indices = (int*) R_alloc(ss->n_mutable_params, sizeof(int));
    int idx = 0;
    for (int i = 0; i < ss->n_params; i++) {
        if (ss->mutable_params[i]) ss->mutable_indices[idx++] = i;
    }
    if (ss->n_mutable_params == 0) {
        error("No mutable parameters found in search space");
    }
}

// Print search space information in a readable format
void print_search_space(SearchSpace* ss) {
    Rprintf("=== Search Space Information ===\n");
    Rprintf("Number of parameters: %d\n", ss->n_params);
    Rprintf("\nParameter details:\n");
    Rprintf("%-15s %-10s %-12s %-12s %-15s %-10s\n", "Name", "Type", "Lower", "Upper", "Levels", "Mutable");
    Rprintf("----------------------------------------------------------------\n");
    
    for (int i = 0; i < ss->n_params; i++) {
        const char* type_name;
        switch (ss->param_classes[i]) {
            case 0: type_name = "ParamDbl"; break;
            case 1: type_name = "ParamInt"; break;
            case 2: type_name = "ParamFct"; break;
            case 3: type_name = "ParamLgl"; break;
            default: type_name = "Unknown"; break;
        }
        
        const char* mutable_status = ss->mutable_params[i] ? "Yes" : "No";
        
        if (ss->param_classes[i] == 2 || ss->param_classes[i] == 3) {
            // Factor or Logical - show levels
            Rprintf("%-15s %-10s %-12s %-12s ", 
                       ss->param_names[i], type_name, "N/A", "N/A");
            if (ss->level_names[i] != NULL) {
                for (int k = 0; k < ss->n_levels[i]; k++) {
                    if (k > 0) Rprintf(",");
                    Rprintf("%s", ss->level_names[i][k]);
                }
            }
            Rprintf(" %-10s\n", mutable_status);
        } else {
            // Numeric - show bounds
            Rprintf("%-15s %-10s %-12.4f %-12.4f %-15s %-10s\n", 
                       ss->param_names[i], type_name, 
                       ss->lower[i], ss->upper[i], "N/A", mutable_status);
        }
    }
    Rprintf("================================================================\n");
}

// Helper function to check if a value is NA
int is_na_value(SEXP col, int idx) {
    switch (TYPEOF(col)) {
        case REALSXP:
            return ISNA(REAL(col)[idx]);
        case INTSXP:  // covers factors too
            return ISNA(INTEGER(col)[idx]);
        case LGLSXP:
            return ISNA(LOGICAL(col)[idx]);
        default:
            return 0; // Should not happen for our use case
    }
}

// Helper function to get random number from R, they respect the RNG state and the seed
// Helper function to get random integer between a and b (inclusive)
int random_int(int a, int b) {
    // Use proper integer arithmetic to avoid bias
    return a + (int)(unif_rand() * (b - a + 1));
}

// Helper function to get random double between min and max
double random_unif(double min, double max) {
    return min + unif_rand() * (max - min);
}

// Helper function to get random normal distribution
double random_normal(double mean, double sd) {
    return rnorm(mean, sd);
}

// Helper function to create an uninitialized data.table with correct column types and attributes
SEXP generate_dt(int n, SearchSpace* ss) {
    SEXP dt = PROTECT(allocVector(VECSXP, ss->n_params));
    for (int j = 0; j < ss->n_params; j++) {
        int param_class = ss->param_classes[j];
        SEXP col;
        if (param_class == 0) { // ParamDbl
            col = PROTECT(allocVector(REALSXP, n));
        } else if (param_class == 1) { // ParamInt
            col = PROTECT(allocVector(INTSXP, n));
        } else if (param_class == 2) { // ParamFct
            col = PROTECT(allocVector(INTSXP, n));
            // Set levels attribute
            SEXP levels = PROTECT(allocVector(STRSXP, ss->n_levels[j]));
            for (int k = 0; k < ss->n_levels[j]; k++) {
                SET_STRING_ELT(levels, k, mkChar(ss->level_names[j][k]));
            }
            setAttrib(col, R_LevelsSymbol, levels);
            // Set class attribute
            SEXP class = PROTECT(allocVector(STRSXP, 1));
            SET_STRING_ELT(class, 0, mkChar("factor"));
            setAttrib(col, R_ClassSymbol, class);
            UNPROTECT(2); // levels, class
        } else { // ParamLgl
            col = PROTECT(allocVector(LGLSXP, n));
        }
        SET_VECTOR_ELT(dt, j, col);
        UNPROTECT(1); // col
    }
    // Set column names
    SEXP col_names = PROTECT(allocVector(STRSXP, ss->n_params));
    for (int j = 0; j < ss->n_params; j++) {
        SET_STRING_ELT(col_names, j, mkChar(ss->param_names[j]));
    }
    setAttrib(dt, R_NamesSymbol, col_names);
    // Set class to data.table
    SEXP class_attr = PROTECT(allocVector(STRSXP, 2));
    SET_STRING_ELT(class_attr, 0, mkChar("data.table"));
    SET_STRING_ELT(class_attr, 1, mkChar("data.frame"));
    setAttrib(dt, R_ClassSymbol, class_attr);
    
    // Set .internal.selfref attribute for data.table
    SEXP selfref = PROTECT(allocVector(INTSXP, 1));
    INTEGER(selfref)[0] = NA_INTEGER;
    setAttrib(dt, Rf_install(".internal.selfref"), selfref);
    
    UNPROTECT(3); // col_names, class_attr, selfref
    // Note: dt remains protected and will be unprotected by the caller
    return dt;
}

// Helper function to print a data.table (for debugging)
void print_dt(SEXP dt, int nrows_max) {
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
                case INTSXP: {
                    SEXP class_attr = getAttrib(col, R_ClassSymbol);
                    if (!isNull(class_attr) && strcmp(CHAR(STRING_ELT(class_attr, 0)), "factor") == 0) {
                        // Factor: print level name
                        SEXP levels = getAttrib(col, R_LevelsSymbol);
                        int idx = INTEGER(col)[i] - 1;
                        if (idx >= 0 && idx < length(levels)) {
                            Rprintf("%10s ", CHAR(STRING_ELT(levels, idx)));
                        } else {
                            Rprintf("%10s ", "NA");
                        }
                    } else {
                        Rprintf("%10d ", INTEGER(col)[i]);
                    }
                    break;
                }
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
}

// Generate neighbors for all current points in an existing data.table
void generate_neighs(int n_searches, int n_neighs, SEXP s_pop_x, SEXP s_neighs_x, SearchSpace* ss, double mut_sd) {
    DEBUG_PRINT("generate_s_neighs_x\n");
    
    // Copy current points to neighbors -- we replicate each candidate n_neighs times
    // we iterate over the parameters / cols first
    for (int j = 0; j < ss->n_params; j++) {
        int param_class = ss->param_classes[j];
        SEXP s_pop_col = VECTOR_ELT(s_pop_x, j);
        SEXP s_neigh_col = VECTOR_ELT(s_neighs_x, j);
        if (param_class == 0) { // ParamDbl
            double* pop_col = REAL(s_pop_col);
            double* neigh_col = REAL(s_neigh_col);
            for (int i_pop = 0; i_pop < n_searches; i_pop++) {
                for (int k = 0; k < n_neighs; k++) {
                    int i_neigh = i_pop * n_neighs + k;
                    neigh_col[i_neigh] = pop_col[i_pop];
                }
            }
        } else if (param_class == 1) { // ParamInt
            int* pop_col = INTEGER(s_pop_col);
            int* neigh_col = INTEGER(s_neigh_col);
            for (int i_pop = 0; i_pop < n_searches; i_pop++) {
                for (int k = 0; k < n_neighs; k++) {
                    int i_neigh = i_pop * n_neighs + k;
                    neigh_col[i_neigh] = pop_col[i_pop];
                }
            }
        } else if (param_class == 2) { // ParamFct
            int* pop_col = INTEGER(s_pop_col);
            int* neigh_col = INTEGER(s_neigh_col);
            for (int i_pop = 0; i_pop < n_searches; i_pop++) {
                for (int k = 0; k < n_neighs; k++) {
                    int i_neigh = i_pop * n_neighs + k;
                    neigh_col[i_neigh] = pop_col[i_pop];
                }
            }
        } else { // ParamLgl
            int* pop_col = LOGICAL(s_pop_col);
            int* neigh_col = LOGICAL(s_neigh_col);
            for (int i_pop = 0; i_pop < n_searches; i_pop++) {
                for (int k = 0; k < n_neighs; k++) {
                    int i_neigh = i_pop * n_neighs + k;
                    neigh_col[i_neigh] = pop_col[i_pop];
                }
            }
        }
    }
    
    // Now mutate one parameter for each neighbor 
    for (int i_neigh = 0; i_neigh < n_searches * n_neighs; i_neigh++) {
        // Find valid mutable parameters for this neighbor (non-NA values)
        int* valid_mutable_indices = (int*)R_alloc(ss->n_mutable_params, sizeof(int));
        int n_valid_mutable = 0;
        
        for (int k = 0; k < ss->n_mutable_params; k++) {
            int j = ss->mutable_indices[k];
            SEXP s_neigh_col = VECTOR_ELT(s_neighs_x, j);
            if (!is_na_value(s_neigh_col, i_neigh)) {
                valid_mutable_indices[n_valid_mutable++] = j;
            }
        }
        
        // Only proceed if we have valid mutable parameters
        if (n_valid_mutable > 0) {
            // Select a random valid mutable parameter
            int j = valid_mutable_indices[random_int(0, n_valid_mutable - 1)];
            
            DEBUG_PRINT("Neighbor %d: selected parameter %d (%s) for mutation from %d valid options\n", 
                i_neigh, j, ss->param_names[j], n_valid_mutable);
            
            int param_class = ss->param_classes[j];
            SEXP s_neigh_col = VECTOR_ELT(s_neighs_x, j);
            if (param_class == 0) { // ParamDbl
                // normalize to [0,1], add noise, rescale to [lower, upper], clip to [lower, upper]
                double *neigh_col = REAL(s_neigh_col);
                double value = neigh_col[i_neigh];
                double lower = ss->lower[j];
                double upper = ss->upper[j];
                double range = upper - lower;
                if (range > 1e-8) { // avoid division by zero, be safe
                  value = (value - lower) / range;
                  value += random_normal(0.0, mut_sd);
                  value = value * range + lower;
                  if (value < lower) value = lower;
                  if (value > upper) value = upper;
                  neigh_col[i_neigh] = value;
                }
            } else if (param_class == 1) { // ParamInt
                // same as ParamDbl but round and cast to int
                int *neigh_col = INTEGER(s_neigh_col);
                double value = (double) neigh_col[i_neigh];
                double lower = ss->lower[j];
                double upper = ss->upper[j];
                double range = upper - lower;
                if (range > 1e-8) { // avoid division by zero, be safe
                    value = (value - lower) / range;
                    value += random_normal(0.0, mut_sd);
                    value = (int) round(value * range + lower);
                    if (value < lower) value = (int)lower;
                    if (value > upper) value = (int)upper;
                    neigh_col[i_neigh] = value;
                }
            } else if (param_class == 2) {    // ParamFct
                // sample uniformly from the other levels
                int *neigh_col = INTEGER(s_neigh_col);
                int current_level = neigh_col[i_neigh]; // 1-based
                int n_levels = ss->n_levels[j];
                if (n_levels > 1) {
                  // use shift trick to sample uniformly from the other levels
                  int new_level = random_int(1, n_levels - 1); // 1-based, excluding current
                  if (new_level >= current_level) new_level++; // Shift up to skip current level
                  neigh_col[i_neigh] = new_level;
                }
            } else { // ParamLgl
                // flip the value
                int *neigh_col = LOGICAL(s_neigh_col);
                int value = neigh_col[i_neigh];
                value = value ^ 1;
                neigh_col[i_neigh] = value;
            }
        } else {
            DEBUG_PRINT("Neighbor %d: no valid mutable parameters found (all are NA)\n", i_neigh);
        }
    }
    DEBUG_PRINT("generate_s_neighs_x done\n");
}

// Copy the best neighbor from each block into the population
void copy_best_neighs_to_pop(int n_searches, int n_neighs, SEXP s_neighs_x, double* neighs_y, SEXP s_pop_x, SearchSpace* ss, double obj_mult) {
    DEBUG_PRINT("copy_best_neighs_to_pop\n");
    
    for (int pop_i = 0; pop_i < n_searches; pop_i++) {
        // Find the best neighbor in this block
        int best_i = -1; 
        double best_y = INFINITY;
        
        for (int k = 0; k < n_neighs; k++) {
            int neigh_i = pop_i * n_neighs + k;
            double current_y = neighs_y[neigh_i] * obj_mult;
            
            if (current_y < best_y) {
                best_y = current_y;
                best_i = neigh_i;
            }
        }
        
        DEBUG_PRINT("Best neighbor for search %d is at index %d with value %f\n", i, best_idx, best_y);
   
        // Copy the best neighbor to the population
        for (int j = 0; j < ss->n_params; j++) {
            int param_class = ss->param_classes[j];
            SEXP s_neigh_col = VECTOR_ELT(s_neighs_x, j);
            SEXP s_pop_col = VECTOR_ELT(s_pop_x, j);
            
            if (param_class == 0) { // ParamDbl
                double* neigh_col = REAL(s_neigh_col);
                double* pop_col = REAL(s_pop_col);
                pop_col[pop_i] = neigh_col[best_i];
            } else if (param_class == 1) { // ParamInt
                int* neigh_col = INTEGER(s_neigh_col);
                int* pop_col = INTEGER(s_pop_col);
                pop_col[pop_i] = neigh_col[best_i];
            } else if (param_class == 2) { // ParamFct
                int* neigh_col = INTEGER(s_neigh_col);
                int* pop_col = INTEGER(s_pop_col);
                pop_col[pop_i] = neigh_col[best_i];
            } else { // ParamLgl
                int* neigh_col = LOGICAL(s_neigh_col);
                int* pop_col = LOGICAL(s_pop_col);
                pop_col[pop_i] = neigh_col[best_i];
            }
        }
    }
    
    DEBUG_PRINT("copy_best_neighs_to_pop done\n");
}

// R wrapper function - complete local search implementation
SEXP c_local_search(SEXP s_ss, SEXP s_ctrl, SEXP s_inst, SEXP s_initial_x) {
    
    int n_searches = asInteger(get_list_el_by_name(s_ctrl, "n_searches"));
    int n_neighs = asInteger(get_list_el_by_name(s_ctrl, "n_neighbors"));
    double mut_sd = asReal(get_list_el_by_name(s_ctrl, "mut_sd"));
    double obj_mult = asReal(get_list_el_by_name(s_ctrl, "obj_mult"));
    int n_steps = asInteger(get_list_el_by_name(s_ctrl, "n_steps"));

    SearchSpace ss;
    extract_ss_info(s_ss, &ss);
    // print_search_space(&ss);

    // Use duplicate to copy initial points
    SEXP s_pop_x = PROTECT(duplicate(s_initial_x));
    SEXP s_neighs_x = generate_dt(n_searches * n_neighs, &ss);
    SEXP s_eval_batch = get_r6_el_by_name(s_inst, "eval_batch");

    // Main local search loop
    for (int step = 0; step < n_steps; step++) {
        DEBUG_PRINT("step=%i\n", step);
        // Generate neighbors for all current points in pre-allocated data.table
        generate_neighs(n_searches, n_neighs, s_pop_x, s_neighs_x, &ss, mut_sd);
        // print_dt(s_neighs_x, 10);

        // Create the function call
        SEXP call = PROTECT(Rf_lang2(s_eval_batch, s_neighs_x));
        
        SEXP s_neighs_y = PROTECT(Rf_eval(call, s_inst));
        double* neighs_y = REAL(VECTOR_ELT(s_neighs_y, 0));
        copy_best_neighs_to_pop(n_searches, n_neighs, s_neighs_x, neighs_y, s_pop_x, &ss, obj_mult);
        UNPROTECT(2); // s_neighs_y, call
    }

    UNPROTECT(2); // s_pop_x, s_neighs_x
    DEBUG_PRINT("c_local_search done\n");
    return R_NilValue;
}
