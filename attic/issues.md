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





Whats the issuue? Fix R Under development (unstable) (2025-10-10 r88914) -- "Unsuffered Consequences"
Copyright (C) 2025 The R Foundation for Statistical Computing
Platform: aarch64-apple-darwin25.0.0

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

R is a collaborative project with many contributors.
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.

> if (requireNamespace("testthat", quietly = TRUE)) {
+   library("testthat")
+   library("checkmate")
+   test_check("bbotk")
+ }
Loading required package: bbotk
Loading required package: paradox
local_search.c:333:27: runtime error: inf is outside the range of representable values of type 'int'
    #0 0x00010e89a388 in extract_ss_info_PROTECT local_search.c:333
    #1 0x00010e8a1c34 in c_local_search local_search.c:775
    #2 0x0001064fb268 in R_doDotCall dotcode.c:763
    #3 0x000106598858 in do_dotcall dotcode.c:1437
    #4 0x000106736fb0 in bcEval_loop eval.c:8114
    #5 0x0001066e94e8 in bcEval eval.c:7497
    #6 0x0001066e767c in Rf_eval eval.c:1167
    #7 0x0001066f2174 in R_execClosure eval.c:2389
    #8 0x0001066edad4 in applyClosure_core eval.c:2302
    #9 0x0001066e7fa4 in Rf_eval eval.c:1280
    #10 0x0001066f2174 in R_execClosure eval.c:2389
    #11 0x0001066edad4 in applyClosure_core eval.c:2302
    #12 0x000106741b24 in bcEval_loop eval.c:8085
    #13 0x0001066e94e8 in bcEval eval.c:7497
    #14 0x0001066e767c in Rf_eval eval.c:1167
    #15 0x0001066f2174 in R_execClosure eval.c:2389
    #16 0x0001066edad4 in applyClosure_core eval.c:2302
    #17 0x0001066e7fa4 in Rf_eval eval.c:1280
    #18 0x0001066f2174 in R_execClosure eval.c:2389
    #19 0x0001066edad4 in applyClosure_core eval.c:2302
    #20 0x0001066e7fa4 in Rf_eval eval.c:1280
    #21 0x0001066fc2b8 in do_begin eval.c:2992
    #22 0x0001066e7a70 in Rf_eval eval.c:1232
    #23 0x000106704ecc in do_eval eval.c:3937
    #24 0x000106736fb0 in bcEval_loop eval.c:8114
    #25 0x0001066e94e8 in bcEval eval.c:7497
    #26 0x0001066e767c in Rf_eval eval.c:1167
    #27 0x0001066f2174 in R_execClosure eval.c:2389
    #28 0x0001066edad4 in applyClosure_core eval.c:2302
    #29 0x0001066e7fa4 in Rf_eval eval.c:1280
    #30 0x000106705304 in do_eval eval.c:3955
    #31 0x000106736fb0 in bcEval_loop eval.c:8114
    #32 0x0001066e94e8 in bcEval eval.c:7497
    #33 0x0001066e767c in Rf_eval eval.c:1167
    #34 0x0001066f2174 in R_execClosure eval.c:2389
    #35 0x0001066edad4 in applyClosure_core eval.c:2302
    #36 0x0001066ef544 in R_forceAndCall eval.c:2456
    #37 0x00010631d3c4 in do_lapply apply.c:75
    #38 0x0001068b4b24 in do_internal names.c:1411
    #39 0x000106727558 in bcEval_loop eval.c:8134
    #40 0x0001066e94e8 in bcEval eval.c:7497
    #41 0x0001066e767c in Rf_eval eval.c:1167
    #42 0x0001066f2174 in R_execClosure eval.c:2389
    #43 0x0001066edad4 in applyClosure_core eval.c:2302
    #44 0x0001066e7fa4 in Rf_eval eval.c:1280
    #45 0x0001066fc2b8 in do_begin eval.c:2992
    #46 0x0001066e7a70 in Rf_eval eval.c:1232
    #47 0x0001066e7a70 in Rf_eval eval.c:1232
    #48 0x000106838f68 in Rf_ReplIteration main.c:264
    #49 0x00010683cfcc in R_ReplConsole main.c:317
    #50 0x00010683cdc8 in run_Rmainloop main.c:1235
    #51 0x00010683d0e8 in Rf_mainloop main.c:1242
    #52 0x000104d355ec in main Rmain.c:29
    #53 0x0001810b9d50 in start+0x1c0c (dyld:arm64e+0x3d50)

SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior local_search.c:333:27
[ FAIL 0 | WARN 0 | SKIP 52 | PASS 962 ]

â•â• Skipped tests (52) â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
â€¢ On CRAN (51): 'test_ArchiveAsync.R:2:3', 'test_ArchiveAsync.R:61:3',
  'test_ArchiveAsyncFrozen.R:2:3', 'test_ArchiveBatch.R:3:3',
  'test_CallbackAsync.R:4:3', 'test_CallbackAsync.R:31:3',
  'test_CallbackAsync.R:59:3', 'test_CallbackAsync.R:88:3',
  'test_CallbackAsync.R:118:3', 'test_CallbackAsync.R:154:3',
  'test_CallbackAsync.R:183:3', 'test_CallbackAsync.R:210:3',
  'test_CallbackAsync.R:239:3', 'test_CallbackAsync.R:269:3',
  'test_CallbackAsync.R:297:3', 'test_Objective.R:9:3',
  'test_OptimInstanceAsyncSingleCrit.R:2:3',
  'test_OptimInstanceAsyncSingleCrit.R:26:3',
  'test_OptimInstanceAsyncSingleCrit.R:45:3',
  'test_OptimInstanceAsyncSingleCrit.R:65:3',
  'test_OptimInstanceAsyncSingleCrit.R:82:3',
  'test_OptimInstanceAsyncSingleCrit.R:109:3',
  'test_OptimInstanceBatchMultiCrit.R:3:3',
  'test_OptimInstanceBatchSingleCrit.R:8:3',
  'test_OptimizerAsynDesignPoints.R:2:3', 'test_OptimizerAsynGridSearch.R:2:3',
  'test_OptimizerAsync.R:2:3', 'test_OptimizerAsync.R:26:3',
  'test_OptimizerAsync.R:50:3', 'test_OptimizerAsync.R:73:3',
  'test_OptimizerAsync.R:95:3', 'test_OptimizerAsync.R:124:3',
  'test_OptimizerAsync.R:155:3', 'test_OptimizerAsyncRandomSearch.R:2:3',
  'test_OptimizerBatchCmaes.R:28:3', 'test_OptimizerBatchDesignPoints.R:5:3',
  'test_OptimizerBatchFocusSearch.R:4:3', 'test_OptimizerBatchGenSA.R:6:3',
  'test_OptimizerBatchGridSearch.R:4:3', 'test_OptimizerBatchNLoptr.R:9:3',
  'test_OptimizerBatchRandomSearch.R:4:3', 'test_TerminatorClockTime.R:5:3',
  'test_TerminatorCombo.R:6:3', 'test_TerminatorEvals.R:5:3',
  'test_TerminatorNone.R:5:3', 'test_TerminatorPerfReached.R:4:3',
  'test_TerminatorRunTime.R:2:5', 'test_TerminatorStagnation.R:5:3',
  'test_TerminatorStagnationBatch.R:5:3',
  'test_TerminatorStagnationBatch.R:19:3', 'test_mlr_callbacks.R:58:3'
â€¢ TRUE is TRUE (1): 'test_mlr_callbacks.R:19:3'

[ FAIL 0 | WARN 0 | SKIP 52 | PASS 962 ]
>
> proc.time()
   user  system elapsed
