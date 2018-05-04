#include "Indice2D.h"
#include "cudaTools.h"
#include "Device.h"

#include "NbSpheres.h"
#include "IndiceTools_GPU.h"

#include "../../../04_RayTracing/moo/device/math/RayMath.h"
using namespace gpu;

// Attention : 	Choix du nom est impotant!
//		VagueDevice.cu et non Vague.cu
// 		Dans ce dernier cas, probl�me de linkage, car le nom du .cu est le meme que le nom d'un .cpp (host)
//		On a donc ajouter Device (ou n'importequoi) pour que les noms soient diff�rents!

/*----------------------------------------------------------------------*\
 |*			Declaration 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Imported	 	*|
 \*-------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

__global__ void rayGM(float4* ptrDevPixels, int nbSphere, Sphere* ptrDevTabSphere, uint w, uint h, float t);
__global__ void rayCM(float4* ptrDevPixels, uint w, uint h, float t);
__global__ void raySM(float4* ptrDevPixels, int nbSphere, Sphere* ptrDevTabSphere, uint w, uint h, float t);

__device__ void work(float4* ptrDevPixels, int nbSphere, Sphere* ptrDevTabSphere, uint w, uint h, float t);
__device__ void copyGMtoSM(Sphere* ptrTabSphere, Sphere* ptrTabSphreSM, int n);

__host__ void uploadGPU(Sphere* ptrDevtabValue);

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

/*----------------------------------------------------------------------*\
 |*			Implementation 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

__host__ void uploadGPU(Sphere* ptrDevtabValue)
    {
    size_t size = NB_SPHERE * sizeof(Sphere);
    int offset=0;

    HANDLE_ERROR (cudaMemcpyToSymbol(
	    TAB_CM,ptrDevtabValue,
	    size,
	    offset,
	    cudaMemcpyHostToDevice));
    }

__global__ void rayGM(float4* ptrDevPixels, int nbSphere, Sphere* ptrDevTabSphere, uint w, uint h, float t)
    {
    work(ptrDevPixels, nbSphere, ptrDevTabSphere, w, h, t);
    }

__global__ void rayCM(float4* ptrDevPixels, uint w, uint h, float t)
    {
    work(ptrDevPixels, NB_SPHERE, TAB_CM, w, h, t);
    }

__global__ void raySM(float4* ptrDevPixels, int nbSphere, Sphere* ptrDevTabSphere, uint w, uint h, float t)
    {
    __shared__ extern Sphere tabSM[];
    copyGMtoSM(ptrDevTabSphere, tabSM, nbSphere);
    __syncthreads();
    work(ptrDevPixels, nbSphere, tabSM, w, h, t);
    }

__device__ void copyGMtoSM(Sphere* ptrTabSphere, Sphere* ptrTabSphreSM, int n)
    {
    const int TID_LOCAL = Indice2D::tidLocal();
    const int NB_THREAD_LOCAL = Indice2D::nbThreadLocal();
    int s = TID_LOCAL;
    while (s < n)
	{
	ptrTabSphreSM[s] = ptrTabSphere[s];
	s += NB_THREAD_LOCAL;
	}
    }

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

__device__ void work(float4* ptrDevPixels, int nbSphere, Sphere* ptrDevTabSphere, uint w, uint h, float t)
    {
	RayMath rayMath = RayMath(nbSphere, ptrDevTabSphere);

        const int TID = Indice2D::tid();
        const int NB_THREAD = Indice2D::nbThread();
        const int WH = w * h;

        int i;	// in [0,h[
        int j; 	// in [0,w[

        int s = TID; // in [0,...

        while (s < WH)
    	{
    	IndiceTools::toIJ(s, w, &i, &j); // s[0,W*H[ --> i[0,H[ j[0,W[

    	rayMath.colorIJ(&ptrDevPixels[s], i, j, t); // update ptrTabPixels[s]

    	s += NB_THREAD;
    	}
    }

/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/

