* using log directory ‘/data/gannet/ripley/R/packages/tests-gcc-SAN/bbotk.Rcheck’
* using R Under development (unstable) (2025-10-10 r88914)
* using platform: x86_64-pc-linux-gnu
* R was compiled by
    gcc (GCC) 15.1.1 20250521 (Red Hat 15.1.1-2)
    GNU Fortran (GCC) 15.1.1 20250521 (Red Hat 15.1.1-2)
* running under: Fedora Linux 42 (Workstation Edition)
* using session charset: UTF-8
* using option ‘--no-stop-on-test-error’
* checking for file ‘bbotk/DESCRIPTION’ ... OK
* this is package ‘bbotk’ version ‘1.7.0’
* package encoding: UTF-8
* checking package dependencies ... OK
* checking if this is a source package ... OK
* checking if there is a namespace ... OK
* checking for hidden files and directories ... OK
* checking for portable file names ... OK
* checking whether package ‘bbotk’ can be installed ... [161s/519s] WARNING
Found the following significant warnings:
  test_local_search.h:8:6: warning: type of ‘c_test_toposort_params’ does not match original declaration [-Wlto-type-mismatch]
See ‘/data/gannet/ripley/R/packages/tests-gcc-SAN/bbotk.Rcheck/00install.out’ for details.
* used C compiler: ‘gcc (GCC) 15.1.1 20250521 (Red Hat 15.1.1-2)’
* checking package directory ... OK
* checking whether the package can be loaded ... [5s/15s] OK
* checking whether the package can be loaded with stated dependencies ... [4s/10s] OK
* checking whether the package can be unloaded cleanly ... [4s/14s] OK
* checking whether the namespace can be loaded with stated dependencies ... [4s/16s] OK
* checking whether the namespace can be unloaded cleanly ... [5s/18s] OK
* checking loading without being on the library search path ... [4s/16s] OK
* checking compiled code ... OK
* checking examples ... [87s/273s] OK
* checking tests ... [26m/32m] OK
  Running ‘testthat.R’ [26m/32m]
* DONE
Status: 1 WARNING


* installing *source* package ‘bbotk’ ...
** this is package ‘bbotk’ version ‘1.7.0’
** package ‘bbotk’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
using C compiler: ‘gcc (GCC) 15.1.1 20250521 (Red Hat 15.1.1-2)’
make[2]: Entering directory '/data/gannet/ripley/R/packages/tests-LTO/bbotk/src'
gcc -I"/data/gannet/ripley/R/R-devel/include" -DNDEBUG   -I/usr/local/include    -fpic  -g -O2 -Wall -pedantic -mtune=native -Wp,-D_FORTIFY_SOURCE=3 -fexceptions -fstack-protector-strong -fstack-clash-protection -fcf-protection -Werror=implicit-function-declaration -Wstrict-prototypes -flto=10 -c init.c -o init.o
gcc -I"/data/gannet/ripley/R/R-devel/include" -DNDEBUG   -I/usr/local/include    -fpic  -g -O2 -Wall -pedantic -mtune=native -Wp,-D_FORTIFY_SOURCE=3 -fexceptions -fstack-protector-strong -fstack-clash-protection -fcf-protection -Werror=implicit-function-declaration -Wstrict-prototypes -flto=10 -c is_dominated.c -o is_dominated.o
gcc -I"/data/gannet/ripley/R/R-devel/include" -DNDEBUG   -I/usr/local/include    -fpic  -g -O2 -Wall -pedantic -mtune=native -Wp,-D_FORTIFY_SOURCE=3 -fexceptions -fstack-protector-strong -fstack-clash-protection -fcf-protection -Werror=implicit-function-declaration -Wstrict-prototypes -flto=10 -c local_search.c -o local_search.o
gcc -I"/data/gannet/ripley/R/R-devel/include" -DNDEBUG   -I/usr/local/include    -fpic  -g -O2 -Wall -pedantic -mtune=native -Wp,-D_FORTIFY_SOURCE=3 -fexceptions -fstack-protector-strong -fstack-clash-protection -fcf-protection -Werror=implicit-function-declaration -Wstrict-prototypes -flto=10 -c rc_helpers.c -o rc_helpers.o
gcc -I"/data/gannet/ripley/R/R-devel/include" -DNDEBUG   -I/usr/local/include    -fpic  -g -O2 -Wall -pedantic -mtune=native -Wp,-D_FORTIFY_SOURCE=3 -fexceptions -fstack-protector-strong -fstack-clash-protection -fcf-protection -Werror=implicit-function-declaration -Wstrict-prototypes -flto=10 -c test_local_search.c -o test_local_search.o
gcc -shared -g -O2 -Wall -pedantic -mtune=native -Wp,-D_FORTIFY_SOURCE=3 -fexceptions -fstack-protector-strong -fstack-clash-protection -fcf-protection -Werror=implicit-function-declaration -Wstrict-prototypes -flto=10 -fpic -L/usr/local/lib64 -o bbotk.so init.o is_dominated.o local_search.o rc_helpers.o test_local_search.o
test_local_search.h:8:6: warning: type of ‘c_test_toposort_params’ does not match original declaration [-Wlto-type-mismatch]
    8 | SEXP c_test_toposort_params(SEXP s_ss, SEXP s_ctrl);
      |      ^
test_local_search.c:170:6: note: type mismatch in parameter 3
  170 | SEXP c_test_toposort_params(SEXP s_ss, SEXP s_expected_param_sort, SEXP s_expected_cond_sort) {
      |      ^
test_local_search.c:170:6: note: type ‘struct SEXPREC *’ should match type ‘void’
test_local_search.c:170:6: note: ‘c_test_toposort_params’ was previously declared here
make[2]: Leaving directory '/data/gannet/ripley/R/packages/tests-LTO/bbotk/src'
installing to /data/gannet/ripley/R/packages/tests-LTO/Libs/bbotk-lib/00LOCK-bbotk/00new/bbotk/libs
** R
** inst
** byte-compile and prepare package for lazy loading
** help
*** installing help indices
** building package indices
** testing if installed package can be loaded from temporary location
** checking absolute paths in shared objects and dynamic libraries
** testing if installed package can be loaded from final location
** testing if installed package keeps a record of temporary installation path
* DONE (bbotk)
Time 1:09.29, 35.17 + 1.23

Package bbotk version 1.7.0
Package built using 88914/R 4.6.0; x86_64-pc-linux-gnu; 2025-10-12 18:49:48 UTC; unix
Checked with rchk version 35618ebbccf3cd0b45a3530e6303970a22a9056b LLVM version 14.0.6
More information at https://github.com/kalibera/cran-checks/blob/master/rchk/PROTECT.md
For rchk in docker image see https://github.com/kalibera/rchk/blob/master/doc/DOCKER.md

Function RC_named_list_create_PROTECT
  [PB] has possible protection stack imbalance bbotk/src/rc_helpers.c:24

Function RC_named_list_create_emptynames_PROTECT
  [PB] has possible protection stack imbalance bbotk/src/rc_helpers.c:13

Function catch_condition
  [UP] calling allocating function Rf_eval with a fresh pointer (stop_call <arg 1>) bbotk/src/local_search.c:287

Function dt_generate_PROTECT
  [PB] has possible protection stack imbalance bbotk/src/local_search.c:187
