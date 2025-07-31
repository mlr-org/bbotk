#ifndef RC_HELPERS_H
#define RC_HELPERS_H

#include <R.h>
#include <Rinternals.h>

SEXP RC_named_list_create_PROTECT(int n);
void RC_set_test_result(SEXP s_testres, int i, const char *text, int value);
const char *RC_asString(SEXP s_x);
R_xlen_t RC_dt_nrows(SEXP s_dt);

#endif // RC_HELPERS_H