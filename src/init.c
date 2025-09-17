#include <R.h>
#include <R_ext/Rdynload.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL

#include "local_search.h"
#include "test_localsearch.h"

/* .Call calls */
extern SEXP c_is_dominated(SEXP);

static const R_CallMethodDef CallEntries[] = {
    {"c_is_dominated", (DL_FUNC)&c_is_dominated, 1},
    {"c_local_search", (DL_FUNC)&c_local_search, 4},

    {"c_test_random_int", (DL_FUNC)&c_test_random_int, 0},
    {"c_test_get_list_el_by_name", (DL_FUNC)&c_test_get_list_el_by_name, 1},
    {"c_test_random_normal", (DL_FUNC)&c_test_random_normal, 0},
    {"c_test_extract_ss_info", (DL_FUNC)&c_test_extract_ss_info, 1},
    {"c_test_dt_utils", (DL_FUNC)&c_test_dt_utils, 2},
    {"c_test_toposort_params", (DL_FUNC)&c_test_toposort_params, 3},
    {"c_test_is_condition_satisfied", (DL_FUNC)&c_test_is_condition_satisfied, 4},
    {"c_test_generate_neighs", (DL_FUNC)&c_test_generate_neighs, 3},
    {"c_test_copy_best_neighs_to_pop", (DL_FUNC)&c_test_copy_best_neighs_to_pop, 6},
    {"c_test_get_best_pop_element", (DL_FUNC)&c_test_get_best_pop_element, 4},
    {"c_test_dt_repair_row", (DL_FUNC)&c_test_dt_repair_row, 2},
    {"c_test_restart_stagnated_searches", (DL_FUNC)&c_test_restart_stagnated_searches, 4},
    {"c_test_dt_set_random_row", (DL_FUNC)&c_test_dt_set_random_row, 2},
    {NULL, NULL, 0}};

void R_init_bbotk(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
