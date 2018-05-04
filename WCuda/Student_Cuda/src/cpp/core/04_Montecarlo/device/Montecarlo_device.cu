#include "Indice2D.h"
#include "Indice1D.h"
#include "cudaTools.h"
#include <curand_kernel.h>
#include "reductionADD.h"
#include <stdio.h>


__global__ void montecarlo(uint* p_ary_gm, curandState* ptr_ary_gen_gm, uint n);

__device__ float f(float x);

__device__ void useGenerator(curandState* ptr_ary_gen_gm, uint n, uint tabSM[]);

__device__ float f(float x){
    return 1. / (1 + x * x);
    }

__global__ void montecarlo(uint* p_ary_gm, curandState* ptr_ary_gen_gm, uint n){
    extern __shared__ uint tabSM[];
    useGenerator(ptr_ary_gen_gm, n, tabSM);
    __syncthreads();
    reductionADD<uint>(tabSM, p_ary_gm);
    }

__global__ void createGenerator(curandState* ptr_ary_gen_gm, int deviceId)
    {
    const int TID = Indice1D::tid();
    int deltaSeed = deviceId * INT_MAX / 10000;
    int deltaSequence = deviceId * 100;
    int deltaOffset = deviceId * 100;
    int seed = 1337 + deltaSeed;
    int sequenceNumber = TID + deltaSequence;
    int offset = deltaOffset;

    curand_init(seed, sequenceNumber, offset, &ptr_ary_gen_gm[TID]);
    }

__device__ void useGenerator(curandState* ptr_ary_gen_gm, uint n, uint tabSM[])
    {
    const int TID = Indice1D::tid();
    const int TID_LOCAL = Indice1D::tidLocal();

    curandState localGenerator = ptr_ary_gen_gm[TID];
    float xAlea;
    float yAlea;

    uint nx = 0;
    for (long i = 1; i <= n; i++)
	{
	xAlea = curand_uniform(&localGenerator);
	yAlea = curand_uniform(&localGenerator);

	if (yAlea <= f(xAlea)){
	    nx++;
	    }
	}

    tabSM[TID_LOCAL] = nx;
    ptr_ary_gen_gm[TID] = localGenerator;
    }

