#include "rc_helpers.h"

// Creates a named list (VECSXP) of size n.
// The list and its names attribute are allocated.
// The returned SEXP is PROTECTed and must be unprotected by the caller.
SEXP RC_named_list_create_PROTECT(int n) {
  SEXP list = PROTECT(allocVector(VECSXP, n));
  SEXP names = PROTECT(allocVector(STRSXP, n));
  for (int i = 0; i < n; i++) { // initialize names to empty strings
    SET_STRING_ELT(names, i, mkChar(""));
  }
  setAttrib(list, R_NamesSymbol, names);
  UNPROTECT(1); // names are now protected by list
  return list;
}

const char *RC_asString(SEXP s_x) { return CHAR(STRING_ELT(s_x, 0)); }