#include <R.h>
#include <Rinternals.h>
#include <Rmath.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/* 
//FIXME:
need to use rng from R
make sure we free all malloced memory
can we get rid of level_names?
*/


// Data structures for search space information
typedef struct {
    int n_params;
    int n_searches;
    int n_neighs;
    double mutation_sd;
    int* param_classes;  // 0=ParamDbl, 1=ParamInt, 2=ParamFct, 3=ParamLgl
    double* lower_bounds;
    double* upper_bounds;
    int* n_levels;
    char** level_names;
} SearchSpace;

typedef struct {
    double* x_values;
    double y_value;
    int point_id;
} Point;



// Helper function to get list element by name
SEXP get_list_el_by_name(SEXP list, const char *str) {
    SEXP elmt = R_NilValue, names = getAttrib(list, R_NamesSymbol);
    int i;
    for (i = 0; i < length(list); i++) {
        if(strcmp(CHAR(STRING_ELT(names, i)), str) == 0) {
            elmt = VECTOR_ELT(list, i);
            break;
        }
    }
    return elmt;
}

// Extract parameter information from paramset object
void extract_paramset_info(SEXP paramset, SearchSpace* ss) {
    // Get the parameters list
    SEXP params = get_list_el_by_name(paramset, "params");
    int n_params = length(params);
    ss->n_params = n_params;
    
    // Allocate arrays
    ss->param_classes = (int*)malloc(n_params * sizeof(int));
    ss->lower_bounds = (double*)malloc(n_params * sizeof(double));
    ss->upper_bounds = (double*)malloc(n_params * sizeof(double));
    ss->n_levels = (int*)malloc(n_params * sizeof(int));
    ss->level_names = (char**)malloc(n_params * 100 * sizeof(char*)); // Simplified
    
    // Extract info for each parameter
    for (int i = 0; i < n_params; i++) {
        SEXP param = VECTOR_ELT(params, i);
        SEXP param_class = get_list_el_by_name(param, "class");
        SEXP param_lower = get_list_el_by_name(param, "lower");
        SEXP param_upper = get_list_el_by_name(param, "upper");
        SEXP param_levels = get_list_el_by_name(param, "levels");
        
        // Get parameter class
        const char* class_name = CHAR(STRING_ELT(param_class, 0));
        if (strcmp(class_name, "ParamDbl") == 0) {
            ss->param_classes[i] = 0;
        } else if (strcmp(class_name, "ParamInt") == 0) {
            ss->param_classes[i] = 1;
        } else if (strcmp(class_name, "ParamFct") == 0) {
            ss->param_classes[i] = 2;
        } else if (strcmp(class_name, "ParamLgl") == 0) {
            ss->param_classes[i] = 3;
        }
        
        // Get bounds
        ss->lower_bounds[i] = REAL(param_lower)[0];
        ss->upper_bounds[i] = REAL(param_upper)[0];
        
        // Get number of levels (for categorical parameters)
        if (param_levels != R_NilValue) {
            ss->n_levels[i] = length(param_levels);
        } else {
            ss->n_levels[i] = 1;
        }
    }
}



// Helper function to get random integer between 0 and max-1
int random_int(int a, int b) {
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

// Generate random initial points
void generate_random_points(Point* points, int n_points, SearchSpace* ss) {
    for (int i = 0; i < n_points; i++) {
        points[i].point_id = i + 1;
        
        for (int j = 0; j < ss->n_params; j++) {
            int param_class = ss->param_classes[j];
            
            if (param_class == 0 || param_class == 1) { // ParamDbl or ParamInt
                // Generate random value within bounds
                double value = random_unif(ss->lower_bounds[j], ss->upper_bounds[j]);
                if (param_class == 1) { // ParamInt
                    value = round(value);
                }
                points[i].x_values[j] = value;
            } else { // ParamFct or ParamLgl
                // Generate random categorical value
                int n_levels = ss->n_levels[j];
                int random_level = random_int(0, n_levels - 1);
                points[i].x_values[j] = (double)random_level;
            }
        }
    }
}

// Generate a neighbor point by mutating one parameter
void generate_neighbor(Point* original, Point* neighbor, SearchSpace* ss) {
    // Copy x_values array first (since it's a pointer)
    memcpy(neighbor->x_values, original->x_values, ss->n_params * sizeof(double));
    // Copy the rest of the struct (y_value and point_id)
    neighbor->y_value = original->y_value;
    neighbor->point_id = original->point_id;
    
    // Select a random parameter to mutate
    int param_idx = random_int(0, ss->n_params - 1);
    int param_class = ss->param_classes[param_idx];
    
    // Mutate the selected parameter
    double value = original->x_values[param_idx];
    double lower = ss->lower_bounds[param_idx];
    double upper = ss->upper_bounds[param_idx];
    int n_levels = ss->n_levels[param_idx];
    
    if (param_class == 0 || param_class == 1) { // ParamDbl or ParamInt
        // Standardize to [0,1]
        double value_norm = (value - lower) / (upper - lower);
        // Add Gaussian noise
        value_norm = value_norm + random_normal(0.0, ss->mutation_sd);
        // Clamp to [0,1]
        if (value_norm < 0.0) value_norm = 0.0;
        if (value_norm > 1.0) value_norm = 1.0;
        // Transform back
        double result = value_norm * (upper - lower) + lower;
        // Round for integers
        if (param_class == 1) {
            result = round(result);
        }
        // Ensure bounds FIXME: remove?
        if (result < lower) result = lower;
        if (result > upper) result = upper;
        neighbor->x_values[param_idx] = result;
    } else { // ParamFct or ParamLgl
        // For categorical, randomly select a different level
        int current_level = (int)value;
        int new_level;
        // FIXME: smarter without loop?  
        // FIXME: i guess we dont want nlevels to be 1???
        do {
            new_level = random_int(0, n_levels - 1);
        } while (new_level == current_level && n_levels > 1);
        neighbor->x_values[param_idx] = (double)new_level;
    }
}

// Find the best point among neighbors for a given point_id
int find_best_neighbor(Point* neighs, int n_neighs, int point_id, double objective_multiplier) {
    double best_value = INFINITY;
    int best_idx = -1;
    
    for (int i = 0; i < n_neighs; i++) {
        if (neighs[i].point_id == point_id) {
            double value = neighs[i].y_value * objective_multiplier;
            if (value < best_value) {
                best_value = value;
                best_idx = i;
            }
        }
    }
    
    return best_idx;
}

// R wrapper function - complete local search implementation
SEXP c_local_search(SEXP paramset, SEXP control) {
    // Extract control settings
    int n_searches = asInteger(get_list_el_by_name(control, "n_searches"));
    int n_neighs = asInteger(get_list_el_by_name(control, "neighbors_per_point"));
    double mut_sd = asReal(get_list_el_by_name(control, "mutation_sd"));
    double obj_mult = asReal(get_list_el_by_name(control, "objective_multiplier"));
    int max_iter = asInteger(get_list_el_by_name(control, "max_iterations"));

    // Allocate search space structure
    SearchSpace ss;
    ss.n_searches = n_searches;
    ss.n_neighs = n_neighs;
    ss.mutation_sd = mut_sd;

    // Extract parameter information from paramset
    extract_paramset_info(paramset, &ss);

    // Track best point seen so far
    Point best;
    best.x_values = (double*)malloc(ss.n_params * sizeof(double));
    best.y_value = INFINITY;
    best.point_id = -1;
    
    // Allocate neighs
    Point* neighs = (Point*)malloc(n_searches * n_neighs * sizeof(Point));
    for (int i = 0; i < n_searches * n_neighs; i++) {
        neighs[i].x_values = (double*)malloc(ss.n_params * sizeof(double));
    }
    
    // Allocate points
    Point* points = (Point*)malloc(n_searches * sizeof(Point));
    for (int i = 0; i < n_searches; i++) {
        points[i].x_values = (double*)malloc(ss.n_params * sizeof(double));
    }
    
    // Generate random initial points
    generate_random_points(points, n_searches, &ss);
    
    // Initialize best point with first point
    memcpy(best.x_values, points[0].x_values, ss.n_params * sizeof(double));
    best.y_value = points[0].y_value;
    best.point_id = points[0].point_id;
    
    // Main local search loop
    for (int iteration = 0; iteration < max_iter; iteration++) {
        // Generate neighbors for each current point
        for (int i = 0; i < n_searches; i++) {
            for (int j = 0; j < n_neighs; j++) {
                int neighbor_idx = i * n_neighs + j;
                generate_neighbor(&points[i], &neighs[neighbor_idx], &ss);
            }
        }
        
        // Here we would normally evaluate the neighbors
        // For now, we'll just simulate by setting random y_values
        for (int i = 0; i < n_searches * n_neighs; i++) {
            neighs[i].y_value = random_unif(0.0, 10.0); // Simulated evaluation
        }
        
        // Update current points if better neighbors found
        for (int i = 0; i < n_searches; i++) {
            int best_neighbor_idx = find_best_neighbor(neighs, 
                                                     n_searches * n_neighs, 
                                                     i + 1, obj_mult);
            
            if (best_neighbor_idx >= 0) {
                double current_value = points[i].y_value * obj_mult;
                double neigh_value = neighs[best_neighbor_idx].y_value * obj_mult;
                
                if (neigh_value < current_value) {
                    // Update current point with better neighbor
                    memcpy(points[i].x_values, neighs[best_neighbor_idx].x_values, 
                           ss.n_params * sizeof(double));
                    points[i].y_value = neighs[best_neighbor_idx].y_value;
                }
            }
        }
        
        // Update best point if any current point is better
        for (int i = 0; i < n_searches; i++) {
            if (points[i].y_value < best.y_value) {
                memcpy(best.x_values, points[i].x_values, ss.n_params * sizeof(double));
                best.y_value = points[i].y_value;
                best.point_id = points[i].point_id;
            }
        }
    }
    
    // Create result matrix with single best point
    SEXP result = PROTECT(allocMatrix(REALSXP, 1, ss.n_params + 1));
    double* result_ptr = REAL(result);

    // Copy results back to R
    // Copy x values
    for (int j = 0; j < ss.n_params; j++) {
        result_ptr[j] = best.x_values[j];
    }
    // Copy y value
    result_ptr[ss.n_params] = best.y_value;

    // Cleanup
    free(best.x_values);
    
    for (int i = 0; i < n_searches * n_neighs; i++) {
        free(neighs[i].x_values);
    }
    free(neighs);
    
    for (int i = 0; i < n_searches; i++) {
        free(points[i].x_values);
    }
    free(points);
    
    free(ss.param_classes);
    free(ss.lower_bounds);
    free(ss.upper_bounds);
    free(ss.n_levels);
    free(ss.level_names);

    UNPROTECT(1);
    return result;
}
