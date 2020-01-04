#ifndef ECC_ARITH_H
#define ECC_ARITH_H

#include "ap_int.h"
#include "math.h"

#define NBITS 192L
ap_uint<NBITS> bignum_sum_mod_n(ap_uint<NBITS> a, ap_uint<NBITS> b, ap_uint<NBITS> n);
ap_uint<NBITS> bignum_sub_mod_n(ap_uint<NBITS> a, ap_uint<NBITS> b, ap_uint<NBITS> n);
ap_uint<NBITS> bignum_mul_mod_n(ap_uint<NBITS> a, ap_uint<NBITS> b, ap_uint<NBITS> n);
ap_uint<NBITS> bignum_inv_mod_n(ap_uint<NBITS> a, ap_uint<NBITS> n);

#endif // ECC_ARITH_H
