#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* .Call calls */
extern SEXP c_is_dominated(SEXP);
extern SEXP c_local_search(SEXP, SEXP, SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
    {"c_is_dominated", (DL_FUNC) &c_is_dominated, 1},
    {"c_local_search", (DL_FUNC) &c_local_search, 4},
    {NULL, NULL, 0}
};

void R_init_bbotk(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
