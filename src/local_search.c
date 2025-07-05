#include <R.h>
#include <Rinternals.h>
#include <Rmath.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/* 
//FIXME:
    * need to use rng from R
    * we sure that random_int is really uniform
    * make sure we free all malloced memory
    * have to be careful if there are trafos or other weird thing in the search space??
    * terminator exception is not handled
    * we need to be sure that levels in R always are without gaps (ie no NA)
    * is the LS somehow elitist?
*/

// Debug printer system - can be switched on/off
#define DEBUG_ENABLED 1  // Set to 0 to disable all debug output

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
    char*** level_names;  // Array of arrays of level names for factors/logicals
    char** param_names;  // Parameter names for data.table columns
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
    
    ss->lower = (double*) malloc(ss->n_params * sizeof(double));
    ss->upper = (double*) malloc(ss->n_params * sizeof(double));
    double* lower = REAL(get_dt_col_by_name(s_data, "lower"));
    double* upper = REAL(get_dt_col_by_name(s_data, "upper"));
    for (int i = 0; i < ss->n_params; i++) {
        ss->lower[i] = lower[i];
        ss->upper[i] = upper[i];
    }
   
    // FIXME: why is this a dbl in paradox?
    ss->n_levels = (int*)malloc(ss->n_params * sizeof(int));
    double* nlevels = REAL(get_dt_col_by_name(s_data, "nlevels"));  
    for (int i = 0; i < ss->n_params; i++) {    
        ss->n_levels[i] = (int)nlevels[i];
    }

    ss->param_classes = (int*)malloc(ss->n_params * sizeof(int));
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
    
    // Extract parameter names
    ss->param_names = (char**)malloc(ss->n_params * sizeof(char*));
    SEXP s_ids = get_dt_col_by_name(s_data, "id");
    for (int i = 0; i < ss->n_params; i++) {
        const char* param_name = CHAR(STRING_ELT(s_ids, i));
        ss->param_names[i] = strdup(param_name);  // Copy the string
    }
    
    // Extract level names for factors and logicals
    ss->level_names = (char***)malloc(ss->n_params * sizeof(char**));
    SEXP s_levels = get_dt_col_by_name(s_data, "levels");
    for (int i = 0; i < ss->n_params; i++) {
        if (ss->param_classes[i] == 2 || ss->param_classes[i] == 3) { // ParamFct or ParamLgl
            SEXP param_levels = VECTOR_ELT(s_levels, i);
            int n_levels = ss->n_levels[i];
            ss->level_names[i] = (char**)malloc(n_levels * sizeof(char*));
            for (int k = 0; k < n_levels; k++) {
                const char* level_name = CHAR(STRING_ELT(param_levels, k));
                ss->level_names[i][k] = strdup(level_name);
            }
        } else {
            ss->level_names[i] = NULL;
        }
    }
}

// Print search space information in a readable format
void print_search_space(SearchSpace* ss) {
    Rprintf("=== Search Space Information ===\n");
    Rprintf("Number of parameters: %d\n", ss->n_params);
    Rprintf("\nParameter details:\n");
    Rprintf("%-15s %-10s %-12s %-12s %-15s\n", "Name", "Type", "Lower", "Upper", "Levels");
    Rprintf("------------------------------------------------------------\n");
    
    for (int i = 0; i < ss->n_params; i++) {
        const char* type_name;
        switch (ss->param_classes[i]) {
            case 0: type_name = "ParamDbl"; break;
            case 1: type_name = "ParamInt"; break;
            case 2: type_name = "ParamFct"; break;
            case 3: type_name = "ParamLgl"; break;
            default: type_name = "Unknown"; break;
        }
        
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
            Rprintf("\n");
        } else {
            // Numeric - show bounds
            Rprintf("%-15s %-10s %-12.4f %-12.4f %-15s\n", 
                       ss->param_names[i], type_name, 
                       ss->lower[i], ss->upper[i], "N/A");
        }
    }
    Rprintf("================================\n");
}

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


// Generate random initial points directly into a data.table
void generate_random_points(int n_points, SEXP s_pop_x, SearchSpace* ss) {
    for (int j = 0; j < ss->n_params; j++) {
        int param_class = ss->param_classes[j];
        SEXP s_col = VECTOR_ELT(s_pop_x, j);
        if (param_class == 0) { // ParamDbl
            double* col = REAL(s_col);
            for (int i = 0; i < n_points; i++) {
                col[i] = random_unif(ss->lower[j], ss->upper[j]);
            }
        } else if (param_class == 1) { // ParamInt
            int* col = INTEGER(s_col);
            for (int i = 0; i < n_points; i++) {
                col[i] = random_int(ss->lower[j], ss->upper[j]);
            }
        } else if (param_class == 2) { // ParamFct
            int* col = INTEGER(s_col);
            for (int i = 0; i < n_points; i++) {
                // FIXME: we need to be sure that levels in R always are without gaps
                col[i] = random_int(1, ss->n_levels[j]); // R factors are 1-based
            }
        } else { // ParamLgl
            int* col = LOGICAL(s_col);
            for (int i = 0; i < n_points; i++) {
                col[i] = random_int(0, 1);
            }
        }
    }
}

// Generate neighbors for all current points in an existing data.table
void generate_neighs(int n_searches, int n_neighs, SEXP s_pop_x, SEXP s_neighs_x, SearchSpace* ss, double mut_sd) {
    DEBUG_PRINT("generate_s_neighs_x\n");
    
    // Copy current points to neighbors (first neighbor of each point is a copy)
    for (int j = 0; j < ss->n_params; j++) {
        int param_class = ss->param_classes[j];
        SEXP s_pop_col = VECTOR_ELT(s_pop_x, j);
        SEXP s_neigh_col = VECTOR_ELT(s_neighs_x, j);
        if (param_class == 0) { // ParamDbl
            double* pop_col = REAL(s_pop_col);
            double* neigh_col = REAL(s_neigh_col);
            for (int i = 0; i < n_searches; i++) {
                for (int k = 0; k < n_neighs; k++) {
                    int neighbor_idx = i * n_neighs + k;
                    neigh_col[neighbor_idx] = pop_col[i];
                }
            }
        } else if (param_class == 1) { // ParamInt
            int* pop_col = INTEGER(s_pop_col);
            int* neigh_col = INTEGER(s_neigh_col);
            for (int i = 0; i < n_searches; i++) {
                for (int k = 0; k < n_neighs; k++) {
                    int neighbor_idx = i * n_neighs + k;
                    neigh_col[neighbor_idx] = pop_col[i];
                }
            }
        } else if (param_class == 2) { // ParamFct
            int* pop_col = INTEGER(s_pop_col);
            int* neigh_col = INTEGER(s_neigh_col);
            for (int i = 0; i < n_searches; i++) {
                for (int k = 0; k < n_neighs; k++) {
                    int neighbor_idx = i * n_neighs + k;
                    neigh_col[neighbor_idx] = pop_col[i];
                }
            }
        } else { // ParamLgl
            int* pop_col = LOGICAL(s_pop_col);
            int* neigh_col = LOGICAL(s_neigh_col);
            for (int i = 0; i < n_searches; i++) {
                for (int k = 0; k < n_neighs; k++) {
                    int neighbor_idx = i * n_neighs + k;
                    neigh_col[neighbor_idx] = pop_col[i];
                }
            }
        }
    }
    
    // Now mutate one parameter for each neighbor 
    for (int i = 0; i < n_searches * n_neighs; i++) {
      int j = random_int(0, ss->n_params - 1);
      int param_class = ss->param_classes[j];
      SEXP s_neigh_col = VECTOR_ELT(s_neighs_x, j);
      if (param_class == 0) { // ParamDbl
        double *neigh_col = REAL(s_neigh_col);
        double value = neigh_col[i];
        double lower = ss->lower[j];
        double upper = ss->upper[j];
        double range = upper - lower;
        DEBUG_PRINT("mutating neighbor %d, param %d, range: %f\n", i, j, range);
        if (range > 1e-8) {
          value = (value - lower) / range;
          value += random_normal(0.0, mut_sd);
          value = value * range + lower;
          if (value < lower) value = lower;
          if (value > upper) value = upper;
          neigh_col[i] = value;
        }
      } else if (param_class == 1) { // ParamInt
        int *neigh_col = INTEGER(s_neigh_col);
        double value = (double) neigh_col[i];
        double lower = ss->lower[j];
        double upper = ss->upper[j];
        double range = upper - lower;
        value = (value - lower) / range;
        value += random_normal(0.0, mut_sd);
        value = (int) round(value * range + lower);
        if (value < lower) value = (int)lower;
        if (value > upper) value = (int)upper;
        neigh_col[i] = value;
      } else if (param_class == 2) {    // ParamFct
        int *neigh_col = INTEGER(s_neigh_col);
        int current_level = neigh_col[i]; // 1-based
        int new_level;
        // FIXME: do this smarter
        do {
          new_level = random_int(1, ss->n_levels[j]); // 1-based
        } while (new_level == current_level && ss->n_levels[j] > 1);
        neigh_col[i] = new_level;
      } else { // ParamLgl
        int *neigh_col = LOGICAL(s_neigh_col);
        int value = neigh_col[i];
        value = value ^ 1;
        neigh_col[i] = value;
      }
    }
    DEBUG_PRINT("generate_s_neighs_x done\n");
}

// Copy the best neighbor from each block into the population
void copy_best_neighs_to_pop(int n_searches, int n_neighs, SEXP s_neighs_x, double* neighs_y, SEXP s_pop_x, SearchSpace* ss, double obj_mult) {
    DEBUG_PRINT("copy_best_neighs_to_pop\n");
    
    for (int i = 0; i < n_searches; i++) {
        // Find the best neighbor in this block
        int best_idx = -1; 
        double best_y = INFINITY;
        
        for (int k = 0; k < n_neighs; k++) {
            int neighbor_idx = i * n_neighs + k;
            double current_y = neighs_y[neighbor_idx] * obj_mult;
            
            if (current_y < best_y) {
                best_y = current_y;
                best_idx = neighbor_idx;
            }
        }
        
        DEBUG_PRINT("Best neighbor for search %d is at index %d with value %f\n", i, best_idx, best_y);
        
        // Safety check
        if (best_idx < 0 || best_idx >= n_searches * n_neighs) {
            DEBUG_PRINT("ERROR: Invalid best_idx %d for search %d\n", best_idx, i);
            continue;
        }
        
        // Copy the best neighbor to the population
        for (int j = 0; j < ss->n_params; j++) {
            int param_class = ss->param_classes[j];
            SEXP s_neigh_col = VECTOR_ELT(s_neighs_x, j);
            SEXP s_pop_col = VECTOR_ELT(s_pop_x, j);
            
            if (param_class == 0) { // ParamDbl
                double* neigh_col = REAL(s_neigh_col);
                double* pop_col = REAL(s_pop_col);
                pop_col[i] = neigh_col[best_idx];
            } else if (param_class == 1) { // ParamInt
                int* neigh_col = INTEGER(s_neigh_col);
                int* pop_col = INTEGER(s_pop_col);
                pop_col[i] = neigh_col[best_idx];
            } else if (param_class == 2) { // ParamFct
                int* neigh_col = INTEGER(s_neigh_col);
                int* pop_col = INTEGER(s_pop_col);
                pop_col[i] = neigh_col[best_idx];
            } else { // ParamLgl
                int* neigh_col = LOGICAL(s_neigh_col);
                int* pop_col = LOGICAL(s_pop_col);
                pop_col[i] = neigh_col[best_idx];
            }
        }
    }
    
    DEBUG_PRINT("copy_best_neighs_to_pop done\n");
}

// R wrapper function - complete local search implementation
SEXP c_local_search(SEXP s_ss, SEXP s_ctrl, SEXP s_inst) {
    
    int n_searches = asInteger(get_list_el_by_name(s_ctrl, "n_searches"));
    int n_neighs = asInteger(get_list_el_by_name(s_ctrl, "n_neighbors"));
    double mut_sd = asReal(get_list_el_by_name(s_ctrl, "mut_sd"));
    double obj_mult = asReal(get_list_el_by_name(s_ctrl, "obj_mult"));
    int n_steps = asInteger(get_list_el_by_name(s_ctrl, "n_steps"));

    SearchSpace ss;
    extract_ss_info(s_ss, &ss);
    print_search_space(&ss);

    // Generate data.table for population and neighbors
    // they are pre-allocated and will be reused in each iteration
    // they are not protected and will be unprotected by the caller
    SEXP s_pop_x = generate_dt(n_searches, &ss);
    SEXP s_neighs_x = generate_dt(n_searches * n_neighs, &ss);
    SEXP s_eval_batch = get_r6_el_by_name(s_inst, "eval_batch");

    generate_random_points(n_searches, s_pop_x, &ss);
      
    // Main local search loop
    for (int step = 0; step < n_steps; step++) {
        DEBUG_PRINT("step=%i\n", step);
        // Generate neighbors for all current points in pre-allocated data.table
        print_search_space(&ss);
        generate_neighs(n_searches, n_neighs, s_pop_x, s_neighs_x, &ss, mut_sd);
        print_search_space(&ss);

        print_dt(s_neighs_x, 10);

        // Create the function call
        SEXP call = PROTECT(Rf_lang2(s_eval_batch, s_neighs_x));
        
        SEXP s_neighs_y = PROTECT(Rf_eval(call, s_inst));
        double* neighs_y = REAL(VECTOR_ELT(s_neighs_y, 0));
        print_search_space(&ss);
        copy_best_neighs_to_pop(n_searches, n_neighs, s_neighs_x, neighs_y, s_pop_x, &ss, obj_mult);
        print_search_space(&ss);
        UNPROTECT(2); // s_neighs_y, call
    }

    // Cleanup
    free(ss.param_classes);
    free(ss.n_levels);
    free(ss.lower);
    free(ss.upper);
    
    // Free parameter names and level names
    for (int i = 0; i < ss.n_params; i++) {
        free(ss.param_names[i]);
        if (ss.level_names[i] != NULL) {
            for (int k = 0; k < ss.n_levels[i]; k++) {
                free(ss.level_names[i][k]);
            }
            free(ss.level_names[i]);
        }
    }
    free(ss.param_names);
    free(ss.level_names);

    UNPROTECT(2); // s_pop_x, s_neighs_x
    DEBUG_PRINT("c_local_search done\n");
    return R_NilValue;
}
