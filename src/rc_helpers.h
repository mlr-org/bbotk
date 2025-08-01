#ifndef RC_HELPERS_H
#define RC_HELPERS_H

#include <R.h>
#include <Rinternals.h>

// convert a charvec(1) to string
const char *RC_asString(SEXP s_x);

// create named list, returned SEXP must be unprotected by the caller.
SEXP RC_named_list_create_PROTECT(int n);
// extract list element by name, returns R_NilValue if not found
SEXP RC_get_list_el_by_name(SEXP s_list, const char *name);

// get number of rows in DT
R_xlen_t RC_dt_nrows(SEXP s_dt);
  // extract DT column by name, returns R_NilValue if not found
SEXP RC_get_dt_col_by_name(SEXP s_dt, const char *name);

// extract R6 member by name, member not found might be undefined behavior
SEXP RC_get_r6_el_by_name(SEXP s_r6, const char *str);


#endif // RC_HELPERS_H