#include "arith.h"

ap_uint<NBITS> bignum_sum_mod_n(ap_uint<NBITS> a, ap_uint<NBITS> b, ap_uint<NBITS> n)
{
	return (a + b) % n;
}

ap_uint<NBITS> bignum_sub_mod_n(ap_uint<NBITS> a, ap_uint<NBITS> b, ap_uint<NBITS> n)
{
	return (a - b) % n;
}

ap_uint<NBITS> bignum_mul_mod_n(ap_uint<NBITS> a, ap_uint<NBITS> b, ap_uint<NBITS> n)
{
	return (a * b) % n;
}

ap_uint<NBITS> bignum_inv_mod_n(ap_uint<NBITS> a, ap_uint<NBITS> n)
{
	ap_uint<NBITS> old_s = 0;
	ap_uint<NBITS> s = 1;
	ap_uint<NBITS> old_r = a;
	ap_uint<NBITS> r = n;
	ap_uint<NBITS> q;
	ap_uint<NBITS> aux;
	ap_uint<NBITS> prod;
	while (1) {
		if (r == ap_uint<NBITS>(1))
			break;
		if (r == ap_uint<NBITS>(0))
			return 0;
		q = old_r / r;	
		old_r = r;
		r = aux;
		aux = old_s;
		old_s = s;
		prod = bignum_mul_mod_n(s, q, n);
		s = bignum_sub_mod_n(aux, prod, n);
	}
	return s;
}
