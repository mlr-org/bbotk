#include "rc_helpers.h"

const char *RC_asString(SEXP s_x) { return CHAR(STRING_ELT(s_x, 0)); }

SEXP RC_named_list_create_emptynames(int n) {
  SEXP s_res = PROTECT(allocVector(VECSXP, n));
  SEXP s_names = PROTECT(allocVector(STRSXP, n));
  for (int i = 0; i < n; i++) { // initialize names to empty strings
    SET_STRING_ELT(s_names, i, mkChar(""));
  }
  setAttrib(s_res, R_NamesSymbol, s_names);
  UNPROTECT(2); // s_res s_names
  return s_res;
}

SEXP RC_named_list_create(int n, const char *names[]) {
  SEXP s_res = PROTECT(allocVector(VECSXP, n));
  SEXP s_names = PROTECT(allocVector(STRSXP, n));
  for (int i = 0; i < n; i++) { // initialize names to empty strings
    SET_STRING_ELT(s_names, i, mkChar(names[i]));
  }
  setAttrib(s_res, R_NamesSymbol, s_names);
  UNPROTECT(2); // s_res s_names
  return s_res;
}


SEXP RC_get_list_el_by_name(SEXP s_list, const char *name) {
  SEXP elmt = R_NilValue, names = getAttrib(s_list, R_NamesSymbol);
  int i;
  for (i = 0; i < length(s_list); i++) {
      if(strncmp(CHAR(STRING_ELT(names, i)), name, strlen(name)) == 0) {
          elmt = VECTOR_ELT(s_list, i);
          break;
      }
  }
  return elmt;
}

R_xlen_t RC_dt_nrows(SEXP s_dt) {
  if (XLENGTH(s_dt) == 0) {
    return 0;
  } else {
    return XLENGTH(VECTOR_ELT(s_dt, 0));
  }
}

SEXP RC_get_dt_col_by_name(SEXP s_dt, const char *name) {
  SEXP col_names = getAttrib(s_dt, R_NamesSymbol);
  for (int i = 0; i < length(s_dt); i++) {
      if (strncmp(CHAR(STRING_ELT(col_names, i)), name, strlen(name)) == 0) {
          return VECTOR_ELT(s_dt, i);
      }
  }
  return R_NilValue; // Column not found
}

SEXP RC_get_r6_el_by_name(SEXP s_r6, const char *str) {
  return Rf_findVar(Rf_install(str), s_r6);
}

