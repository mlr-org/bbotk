#include <R.h>
#include <Rinternals.h>

/*
 * Adapted from https://github.com/olafmersmann/emoa/blob/master/src/dominance.c
 * written by Olaf Mersmann (OME) <olafm@statistik.tu-dortmund.de>.
 */

static R_INLINE int dominates(const double * x, const double * y, const R_len_t d) {
    Rboolean x_flag = 0, y_flag = 0;

    for (R_len_t k = 0; k < d; k++) {
        if (x[k] < y[k]) {
            y_flag = 1; // y cannot dominate x
        } else if (y[k] < x[k]) {
            x_flag = 1; // x cannot dominate y
        }

        // Note that we could break as soon as both x_flag and y_flag are true.
        // However, we assume that the number of dimensions d is usually small
        // so it is probably faster to just walk over all components
    }

    return y_flag - x_flag;
}

SEXP c_is_dominated(SEXP p_) {
    // accessors for input matrix p_
    const R_len_t n = ncols(p_);
    const R_len_t d = nrows(p_);
    const double * p = REAL(p_);

    // accessors for output vector res_
    SEXP res_ = PROTECT(allocVector(LGLSXP, n));
    int * res = LOGICAL(res_);
    for (R_len_t i = 0; i < n; i++) res[i] = FALSE;

    // iterate over all columns of input
    for (R_len_t i = 0; i < n; i++) {
        if (res[i]) {
            // current column was marked as dominated in a
            // previous iteration; skip
            continue;
        }

        // find a non-dominated column to compare with
        for (R_len_t j = i + 1; j < n; j++) {
            if (res[j]) {
                continue;
            }

            // compare vector p[, i] with vector p[, j]
            int dom = dominates(p + (i * d), p + (j * d), d);

            if (dom > 0) {
                // i dominates j
                res[j] = TRUE;
            } else if (dom < 0) {
                // j dominates i
                res[i] = TRUE;
            }
        }
    }

    UNPROTECT(1);
    return res_;
}
