#include <iostream>
#include <fstream>
using namespace std;

#include "ecc.h"

int main()
{
	ap_uint<NBITS> eccmul_p("0xfffffffffffffffffffffffffffffffffffffffeffffee37",NBITS);
	ap_uint<NBITS*2> eccmul_point("0xdb4ff10ec057e9ae26b07d0280b7f4341da5d1b1eae06c7d9b2f2f6d9c5628a7844163d015be86344082aa88d95e2f9d",NBITS*2);
	ap_uint<NBITS> eccmul_scalar("0x000000000000000000000000000000000000000000000002",NBITS);
	ap_uint<NBITS> eccmul_result("0x000000000000000000000000000000000000000000000000",NBITS);

	int retval = 0;
	fstream fp("result.txt", ios::out | ios::trunc);
	eccmul_result = ecc_pointdouble(eccmul_point, eccmul_scalar, eccmul_p);
	fp << eccmul_result.to_string();
	fp.flush();
	fp.close();
	return retval;
}
