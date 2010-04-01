
#include <stdio.h>
#include <stdlib.h>
#include <Matrix.h>


void mmult
	( Matrix* matDest
	, Matrix* matSrc1
	, Matrix* matSrc2)
{
	int dim1	= matSrc1->width;
	int dim2	= matSrc2->height;
	int dim3	= matDest->width;

	for (int i = 0; i < dim1; i++)
	{
		for (int j = 0; j < dim3; j++)
			matDest->data[i][j] = 0.;

		for (int k = 0; k < dim2; k++)
			for (int j = 0; j < dim3; j++)
				matDest->data[i][j] 
					+= matSrc1->data[i][k] 
					*  matSrc2->data[k][j];
	}	
}




// Main -------------------------------------------------------------------------------------------
int main(int argc, char** argv)
{
	// Argument parsing
	if (argc != 6) {
		printf("Usage: mmult <width1> <height1> <width2> <height2> <output.mat>\n");
		printf("  width, height  :: Int       The width and height of the matrices\n");
		printf("  output.mat     :: FileName  File to write the result matrix to\n");
		exit(0);
	}
	int width1	= 0;
	int height1	= 0;
	int width2	= 0;
	int height2	= 0;
	
	if(sscanf(argv[1], "%d", &width1) != 1) {
		printf("laplace: can't parse matrix width\n");
		exit(1);
	}

	if(sscanf(argv[2], "%d", &height1) != 1) {
		printf("laplace: can't parse matrix height\n");
		exit(1);
	}

	if(sscanf(argv[3], "%d", &width2) != 1) {
		printf("laplace: can't parse matrix width\n");
		exit(1);
	}

	if(sscanf(argv[4], "%d", &height2) != 1) {
		printf("laplace: can't parse matrix height\n");
		exit(1);
	}

	char* fileName	= argv[5];


	Matrix* mat1	= newRandomMatrix (width1, height1);
	Matrix* mat2	= newRandomMatrix (width2, height2);
	Matrix* matDest	= newZeroMatrix   (width2, height1);
	
	mmult(matDest, mat1, mat2);
}