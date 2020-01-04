#ifndef ECC_C_ECC_H
#define ECC_C_ECC_H

#include "arith.h"

ap_uint<NBITS> ecc_slope(ap_uint<NBITS*2> P, ap_uint<NBITS*2> Q, ap_uint<NBITS> p);
ap_uint<NBITS> ecc_doubleslope(ap_uint<NBITS*2> P, ap_uint<NBITS> a, ap_uint<NBITS> p);
ap_uint<NBITS*2> ecc_pointadd(ap_uint<NBITS*2> P, ap_uint<NBITS> p);
static ap_uint<NBITS*2> ecc_add(ap_uint<NBITS*2> P, ap_uint<NBITS*2> Q, ap_uint<NBITS> s, ap_uint<NBITS> p);
ap_uint<NBITS*2> ecc_pointdouble(ap_uint<NBITS*2> P, ap_uint<NBITS> a, ap_uint<NBITS> p);
ap_uint<NBITS*2> ecc_pointmul(ap_uint<NBITS*2> P, ap_uint<NBITS> k, ap_uint<NBITS> a, ap_uint<NBITS> p);
#endif // ECC_C_ECC_H
