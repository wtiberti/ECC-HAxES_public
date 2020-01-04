#include "arith.h"
#include "ecc.h"

ap_uint<NBITS> ecc_slope(ap_uint<NBITS*2> P, ap_uint<NBITS*2> Q, ap_uint<NBITS> p)
{
	ap_uint<NBITS> dx;
	ap_uint<NBITS> dy;
	ap_uint<NBITS> invdy;
	dx = bignum_sub_mod_n(P(NBITS*2-1,NBITS), Q(NBITS*2-1,NBITS), p);
	dy = bignum_sub_mod_n(P(NBITS-1,0), Q(NBITS-1,0), p);
	invdy = bignum_inv_mod_n(dy, p);
	return bignum_mul_mod_n(dx, invdy, p);
}

ap_uint<NBITS> ecc_doubleslope(ap_uint<NBITS*2> P, ap_uint<NBITS> a, ap_uint<NBITS> p)
{
	ap_uint<NBITS> x2;
	ap_uint<NBITS> x2_2;
	ap_uint<NBITS> a_x2;
	ap_uint<NBITS> num;
	ap_uint<NBITS> y_2;
	ap_uint<NBITS> inv_den;
	x2 = bignum_mul_mod_n(P(NBITS*2-1,NBITS), P(NBITS*2-1,NBITS), p);
	x2_2 = bignum_sum_mod_n(x2, x2, p);
	a_x2 = bignum_sum_mod_n(x2, a, p);
	num = bignum_sum_mod_n(x2_2, a_x2, p);
	y_2 = bignum_sum_mod_n(P(NBITS-1,0), P(NBITS-1,0), p);
	inv_den = bignum_inv_mod_n(y_2, p);
	return bignum_mul_mod_n(num, inv_den, p);
}

ap_uint<NBITS*2> ecc_pointadd(ap_uint<NBITS*2> P, ap_uint<NBITS*2> Q, ap_uint<NBITS> p)
{
	ap_uint<NBITS> slope;
	slope = ecc_slope(P, Q, p);
	return ecc_add(P, Q, slope, p);
}


ap_uint<NBITS*2> ecc_pointdouble(ap_uint<NBITS*2> P, ap_uint<NBITS> a, ap_uint<NBITS> p)
{
	ap_uint<NBITS> slope;
	ap_uint<NBITS*2> result;
	slope = ecc_doubleslope(P, a, p);
	result = ecc_add(P, P, slope, p);
	return result;
}

ap_uint<NBITS*2> ecc_add(ap_uint<NBITS*2> P, ap_uint<NBITS*2> Q, ap_uint<NBITS> s, ap_uint<NBITS> p)
{
	ap_uint<NBITS> s2;
	ap_uint<NBITS> aux1;
	ap_uint<NBITS> aux2;
	ap_uint<NBITS> Rx;
	s2 = bignum_mul_mod_n(s, s, p);
	aux1 = bignum_sub_mod_n(s2, P(2*NBITS-1,NBITS), p);
	Rx = bignum_sub_mod_n( aux1, Q(2*NBITS-1,NBITS), p);
	aux1 = bignum_sub_mod_n(P(2*NBITS-1,NBITS), Rx, p);
	aux2 = bignum_mul_mod_n(s, aux1, p);
	aux1 = bignum_sub_mod_n(aux2, P(NBITS-1,0), p);
	return (Rx,aux1);
}

ap_uint<NBITS*2> ecc_pointmul(ap_uint<NBITS*2> P, ap_uint<NBITS> k, ap_uint<NBITS> a, ap_uint<NBITS> p)
{
	ap_uint<NBITS*2> doubleP = P;
	ap_uint<NBITS*2> result;

	do {
		result = doubleP;
		doubleP = ecc_pointdouble(doubleP, a, p);
		k >>= 1;
	} while (k[0] == ap_uint<1>(0));

	while (k.or_reduce() == false) {
		if (k[0] == ap_uint<1>(1)) {
			result = ecc_pointadd(doubleP, result, p);
		}
		doubleP = ecc_pointdouble(doubleP, a, p);
		k >>= 1;
	}
	return result;
}
