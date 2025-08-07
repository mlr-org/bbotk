#include "local_search.h"

SEXP c_test_random_int();
SEXP c_test_random_normal();
SEXP c_test_get_list_el_by_name(SEXP);
SEXP c_test_extract_ss_info(SEXP s_ss, SEXP s_ctrl);
SEXP c_test_dt_utils(SEXP s_ss, SEXP s_ctrl);
SEXP c_test_toposort_params(SEXP s_ss, SEXP s_ctrl);
SEXP c_test_is_condition_satisfied(SEXP s_ss, SEXP s_ctrl, SEXP s_dt, SEXP s_cond);
SEXP c_test_generate_neighs(SEXP s_ss, SEXP s_ctrl, SEXP s_pop_x);
SEXP c_test_copy_best_neighs_to_pop(SEXP s_ss, SEXP s_ctrl, SEXP s_pop_x, SEXP s_pop_y, 
  SEXP s_neighs_x, SEXP s_neighs_y);
SEXP c_test_get_best_pop_element(SEXP s_ss, SEXP s_ctrl, SEXP s_pop_x, SEXP s_pop_y);
SEXP c_test_dt_repair_row(SEXP s_ss, SEXP s_dt);
SEXP c_test_restart_stagnated_searches(SEXP s_ss, SEXP s_ctrl, SEXP s_pop_x, SEXP s_stagnate_count);
SEXP c_test_dt_set_random_row(SEXP s_ss, SEXP s_dt);