#include <stdio.h>
#include "ecc.h"

#define NBITS 192

int main()
{
	ap_uint<NBITS> eccmul_p("0",192);
	ap_uint<NBITS*2> eccmul_point("0xABCDE1234",NBITS*2);
	ap_uint<NBITS> eccmul_scalar("2",192);
	ap_uint<NBITS> eccmul_result("0",192);

	int retval = 0;
	FILE *fp;

	fp = fopen("result.txt", "w");
	eccmul_result = ecc_pointdouble(eccmul_point, eccmul_scalar, eccmul_p);
	fprintf(fp, "%d", eccmul_result.to_int());
	fclose(fp);

	retval = system("diff --brief -w result.dat result.golden.dat");
	if (retval != 0) {
		printf("Test passed.\n");
		retval = 1;
	}
	else {
		printf("Test passed.\n");
	}
	return retval;
}
