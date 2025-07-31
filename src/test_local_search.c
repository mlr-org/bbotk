#include "local_search.h"
#include "rc_helpers.h"
#include <R.h>
#include <Rinternals.h>
#include <Rmath.h>

extern SEXP get_list_el_by_name(SEXP list, const char *name);
extern int random_int(int a, int b);
extern double random_normal(double mean, double sd);
extern SEXP dt_generate_PROTECT(int n, SearchSpace *ss);
extern void dt_set_na(SEXP s_dt, int row_i, int param_j);
extern int dt_is_na(SEXP s_dt, int row_i, int param_j);
extern void dt_set_random(SEXP s_dt, int row_i, int param_j, SearchSpace *ss, double mut_sd);

// sets test result as a bool scalar, so we can later pass it to
// testthat::expect_true
void set_test_result(SEXP s_testres, int i, const char *text, int value) {
  SEXP s_names = getAttrib(s_testres, R_NamesSymbol);
  SET_STRING_ELT(s_names, i, mkChar(text));
  SET_VECTOR_ELT(s_testres, i, ScalarLogical(value));
}

SEXP c_test_get_list_el_by_name(SEXP test_list) {
  SEXP s_testres = RC_named_list_create_PROTECT(3);
  SEXP s_x;
  // simple test to see if we can retrieve elements from a list by name
  s_x = get_list_el_by_name(test_list, "a");
  set_test_result(s_testres, 0, "ok1", asInteger(s_x) == 1);
  s_x = get_list_el_by_name(test_list, "b");
  set_test_result(s_testres, 1, "ok2", strcmp(RC_asString(s_x), "foo") == 0);
  s_x = get_list_el_by_name(test_list, "c");
  set_test_result(s_testres, 2, "ok3", Rf_isNull(s_x));
  UNPROTECT(1); // s_testres
  return s_testres;
}

SEXP c_test_random_int() {
  SEXP s_res = RC_named_list_create_PROTECT(2);
  GetRNGstate();
  int k;
  k = random_int(5, 5);
  set_test_result(s_res, 0, "ok1", k == 5);
  k = random_int(1, 2);
  set_test_result(s_res, 1, "ok2", k >= 1 && k <= 2);
  PutRNGstate();
  UNPROTECT(1); // s_res
  return s_res;
}

SEXP c_test_random_normal() {
  SEXP s_res = RC_named_list_create_PROTECT(1);
  GetRNGstate();
  double val = random_normal(0.0, 1.0);
  // This is a weak test, but it's hard to test a random number generator.
  // We just check that the value is within a reasonable range.
  set_test_result(s_res, 0, "ok1", val > -10.0 && val < 10.0);
  PutRNGstate();
  UNPROTECT(1); // s_res
  return s_res;
}

SEXP c_test_extract_ss_info(SEXP s_ss) {
  SEXP s_res = RC_named_list_create_PROTECT(19);

  SearchSpace ss;
  extract_ss_info(s_ss, &ss);

  set_test_result(s_res, 0, "ok0", ss.n_params == 4);

  set_test_result(s_res, 1, "ok1", strcmp(ss.param_names[0], "x1") == 0);
  set_test_result(s_res, 2, "ok2", strcmp(ss.param_names[1], "x2") == 0);
  set_test_result(s_res, 3, "ok3", strcmp(ss.param_names[2], "x3") == 0);
  set_test_result(s_res, 4, "ok4", strcmp(ss.param_names[3], "x4") == 0);


  set_test_result(s_res, 5, "ok5", ss.param_classes[0] == 0);
  set_test_result(s_res, 6, "ok6", ss.param_classes[1] == 1);
  set_test_result(s_res, 7, "ok7", ss.param_classes[2] == 2);
  set_test_result(s_res, 8, "ok8", ss.param_classes[3] == 3);


  set_test_result(s_res, 9, "ok9", ss.lower[0] == 0.0);
  set_test_result(s_res, 10, "ok10", ss.lower[1] == 0.0);

  set_test_result(s_res, 11, "ok11", ss.upper[0] == 1.0);
  set_test_result(s_res, 12, "ok12", ss.upper[1] == 10.0);


  set_test_result(s_res, 13, "ok13", ss.n_levels[2] == 3);
  set_test_result(s_res, 14, "ok14", strcmp(ss.level_names[2][0], "a") == 0);
  set_test_result(s_res, 15, "ok15", strcmp(ss.level_names[2][1], "b") == 0);
  set_test_result(s_res, 16, "ok16", strcmp(ss.level_names[2][2], "c") == 0);


  int k;
  k = find_param_index("x2", &ss);
  set_test_result(s_res, 17, "ok18", k == 1);
  k = find_param_index("x3", &ss);
  set_test_result(s_res, 18, "ok18", k == 2);

  UNPROTECT(1);
  return s_res;
}

SEXP c_test_dt_utils(SEXP s_ss) {
  SEXP s_res = RC_named_list_create_PROTECT(10);
  SearchSpace ss;
  extract_ss_info(s_ss, &ss);
  GetRNGstate();

  // Test dt_generate
  SEXP s_dt = dt_generate_PROTECT(2, &ss); // dt_generate returns a PROTECTed SEXP
  set_test_result(s_res, 0, "generate_nrows", RC_dt_nrows(s_dt) == 2);
  set_test_result(s_res, 1, "generate_ncols", Rf_length(s_dt) == ss.n_params);

  // Test dt_set_na and dt_is_na
  dt_set_na(s_dt, 0, 0); // ParamDbl
  dt_set_na(s_dt, 0, 1); // ParamInt
  dt_set_na(s_dt, 0, 2); // ParamFct
  dt_set_na(s_dt, 0, 3); // ParamLgl
  set_test_result(s_res, 2, "is_na_dbl", dt_is_na(s_dt, 0, 0) == 1);
  set_test_result(s_res, 3, "is_na_int", dt_is_na(s_dt, 0, 1) == 1);
  set_test_result(s_res, 4, "is_na_fct", dt_is_na(s_dt, 0, 2) == 1);
  set_test_result(s_res, 5, "is_na_lgl", dt_is_na(s_dt, 0, 3) == 1);


  // Test dt_set_random
  dt_set_random(s_dt, 0, 0, &ss, 0.1);
  dt_set_random(s_dt, 0, 1, &ss, 0.1);
  dt_set_random(s_dt, 0, 2, &ss, 0.1);
  dt_set_random(s_dt, 0, 3, &ss, 0.1);
  set_test_result(s_res, 6, "set_random_dbl", dt_is_na(s_dt, 0, 0) == 0);
  set_test_result(s_res, 7, "set_random_int", dt_is_na(s_dt, 0, 1) == 0);
  set_test_result(s_res, 8, "set_random_fct", dt_is_na(s_dt, 0, 2) == 0);
  set_test_result(s_res, 9, "set_random_lgl", dt_is_na(s_dt, 0, 3) == 0);

  PutRNGstate();
  UNPROTECT(2); // s_res, s_dt
  return s_res;
}
