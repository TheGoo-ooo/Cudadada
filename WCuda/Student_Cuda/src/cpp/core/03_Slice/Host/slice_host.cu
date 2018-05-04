#include <iostream>
#include "cudaTools.h"
#include "Device.h"
#include "Indice2D.h"

extern __global__ void kernel(int n, float* d_ary);
extern __global__ void kernel_a(int n, float* d_ary);

float reduction_simple(float* ary, int size){
    float sum = 0.0;
    for (int i = 0; i < size; i++){
	sum += ary[i];
    }
    return sum;
}

__host__ bool slice(void)
    {
    dim3 dg = dim3(64, 1, 1);
    dim3 db = dim3(64, 1, 1);

    int size = 1000000;

    float ary[size];

    for (int i = 0; i < size; i++){
	ary[i] = 0.0;
    }

    float* d_ary;
    cudaMalloc((void**)&d_ary, size*sizeof(float));
    cudaMemcpy(d_ary, ary, size * sizeof(float), cudaMemcpyHostToDevice);

    Device::lastCudaError("slice_host (before)"); // temp debug
    kernel<<<dg,db>>>(size, d_ary);
    Device::lastCudaError("slice_host (after)"); // temp debug

    cudaMemcpy(ary, d_ary, size * sizeof(float), cudaMemcpyDeviceToHost);
    std::cout << "sum :" << (4.0 * reduction_simple(ary, size)) / size << std::endl;

    return true;
    }

__host__ bool slice_advanced(void)
    {
    dim3 dg = dim3(64, 1, 1);
    dim3 db = dim3(64, 1, 1);

    int size = 10000000;

    float ary[size];

    for (int i = 0; i < size; i++){
	ary[i] = 0.0;
    }

    float* d_ary;
    cudaMalloc((void**)&d_ary, size*sizeof(float));
    cudaMemcpy(d_ary, ary, size * sizeof(float), cudaMemcpyHostToDevice);

    Device::lastCudaError("slice_host (before)"); // temp debug

    size_t sizeOGM = sizeof(float)*db.x;

    kernel_a<<<dg,db,sizeOGM>>>(size, d_ary);
    Device::lastCudaError("slice_host (after)"); // temp debug

    cudaMemcpy(ary, d_ary, size * sizeof(float), cudaMemcpyDeviceToHost);
    std::cout << "sum :" << (4.0 * reduction_simple(ary, size)) / size << std::endl;

    return true;
    }