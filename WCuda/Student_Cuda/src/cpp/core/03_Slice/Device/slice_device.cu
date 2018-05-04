#include <iostream>
#include "cudaTools.h"
#include "Device.h"
#include "Indice1D.h"
#include "SliceMath.h"
#include "reductionADD.h"


static __device__ void intra_thread_reduction(float* shared_memory_ary, int n);

__device__ void slice_run(int n, float* d_ary) {
    const int TID = Indice1D::tid();
    const int NB_THREAD = Indice1D::nbThread();

    int s = TID;
    float dx = 1./(float)n;
    float x = 0.0;

    while(s < n){
	x = s * dx;
	d_ary[s]= SliceMath::getSlice(x);
	s += NB_THREAD;
	}
    }

__device__ void slice_run_advanced(int n, float* d_ary){
    extern __shared__ float shared_memory_ary[];
    intra_thread_reduction(shared_memory_ary, n);
    __syncthreads();
    reductionADD<float>(shared_memory_ary, d_ary);
    /*
     * Ne marche pas ..
     * /opt/api/cbi/tools/bilat_tools_cuda/303_006/INC/cudatools/header/device/reduction/reductionADD.h(147): error: no instance of overloaded function "atomicAdd" matches the argument list
     *       argument types are: (float *, float)
     *     detected during:
     *       instantiation of "void reductionInterblock(T *, T *) [with T=float]"
     *  (53): here
     * instantiation of "void reductionADD(T *, T *) [with T=float]"
     * src/cpp/core/03_Slice/Device/slice_device.cu(30): here
     */
}

__device__ void intra_thread_reduction(float* shared_memory_ary, int n){
    const int TID = Indice1D::tid();
    const int NB_THREAD = Indice1D::nbThread();
    const int LOCAL_TID = Indice1D::tidLocal();
    const float dx = 1.0f/ (float) n;

    int s = TID;
    float xs;
    float sum = 0;

    while (s < n){
	xs = s * dx;
	sum = SliceMath::getSlice(xs);
	s+= NB_THREAD;
    }
    shared_memory_ary[LOCAL_TID] = 4 * sum * dx;
}


__global__ void kernel(int n, float* d_ary) {
       slice_run(n, d_ary);
}

__global__ void kernel_a(int n, float* d_ary){
    slice_run_advanced(n, d_ary);
}
