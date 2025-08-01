#include <R.h>
#include <R_ext/Rdynload.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL

/* .Call calls */
extern SEXP c_is_dominated(SEXP);
extern SEXP c_local_search(SEXP, SEXP, SEXP, SEXP);

extern SEXP c_test_random_int();
extern SEXP c_test_get_list_el_by_name(SEXP);
extern SEXP c_test_random_normal();
extern SEXP c_test_extract_ss_info(SEXP);
extern SEXP c_test_dt_utils(SEXP);
extern SEXP c_test_toposort_params(SEXP, SEXP, SEXP);
extern SEXP c_test_is_condition_satisfied(SEXP, SEXP, SEXP, SEXP);
extern SEXP c_test_generate_neighs(SEXP, SEXP, SEXP, SEXP);
extern SEXP c_test_copy_best_neighs_to_pop(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
    {"c_is_dominated", (DL_FUNC)&c_is_dominated, 1},
    {"c_local_search", (DL_FUNC)&c_local_search, 4},

    {"c_test_random_int", (DL_FUNC)&c_test_random_int, 0},
    {"c_test_get_list_el_by_name", (DL_FUNC)&c_test_get_list_el_by_name, 1},
    {"c_test_random_normal", (DL_FUNC)&c_test_random_normal, 0},
    {"c_test_extract_ss_info", (DL_FUNC)&c_test_extract_ss_info, 1},
    {"c_test_dt_utils", (DL_FUNC)&c_test_dt_utils, 1},
    {"c_test_toposort_params", (DL_FUNC)&c_test_toposort_params, 3},
    {"c_test_is_condition_satisfied", (DL_FUNC)&c_test_is_condition_satisfied, 4},
    {"c_test_generate_neighs", (DL_FUNC)&c_test_generate_neighs, 4},
    {"c_test_copy_best_neighs_to_pop", (DL_FUNC)&c_test_copy_best_neighs_to_pop, 8},
    {NULL, NULL, 0}};

void R_init_bbotk(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
