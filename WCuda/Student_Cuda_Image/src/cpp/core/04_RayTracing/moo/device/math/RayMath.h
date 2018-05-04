#pragma once

#include <math.h>
#include "cudaTools.h"
#include "MathTools.h"

#include "ColorTools_GPU.h"

#include "../../../../04_RayTracing/moo/device/math/Sphere.h"
using namespace gpu;

/*----------------------------------------------------------------------*\
 |*			Declaration 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

__constant__ Sphere TAB_CM[NB_SPHERE];

class RayMath
    {
	/*--------------------------------------*\
	|*		Constructeur		*|
	 \*-------------------------------------*/

    public:
	__device__
	RayMath(int nbSphere, Sphere* ptrDevTabSphere)
	    {
	    this->nbSphere = nbSphere;
	    this->ptrDevTabSphere = ptrDevTabSphere;
	    }

	__device__
	virtual ~RayMath(void)
	    {
	    }

	/*--------------------------------------*\
	|*		Methode			*|
	 \*-------------------------------------*/

    public:
	__device__
	void colorIJ(float4* ptrColorIJ, int i, int j, float t)
	    {
	    float brightness;
	    float hue = 0;

	    f(j, i, t, &hue, &brightness);

	    ptrColorIJ->x = hue;
	    ptrColorIJ->y = 1.f;
	    ptrColorIJ->z = brightness;

	    ptrColorIJ->w = 1.f; //opaque
	    }

	__host__ void uploadGPU(float* tabValue)
	    {
	    size_t size= NB_SPHERE * sizeof(Sphere);
	    int offset=0;
	    HANDLE_ERROR (cudaMemcpyToSymbol(
		    TAB_CM,
		    tabValue,
		    size,
		    offset,
		    cudaMemcpyHostToDevice));
	    }

    private:
	__device__
	void f(int i, int j, float t, float* hueReturn, float* brightnessReturn )
	    {
	    Sphere* spheres = ptrDevTabSphere;
	    float closestSphere = -1.f;
	    float tempDz;
	    int tempIndex;

	    for(int k=0; k<nbSphere; k++)
		{
		float2 xysol = make_float2(j,i);
		float hCarre = spheres[k].hCarre(xysol);
		if(!spheres[k].isEnDessous(hCarre))
		    continue;

		float dz = spheres[k].dz(hCarre);
		float distance = spheres[k].distance(dz);
		if(closestSphere < 0.f)
		    {
		    closestSphere = distance;
		    tempDz = dz;
		    tempIndex = k;
		    }
		else if(distance < closestSphere)
		    {
		    closestSphere = distance;
		    tempDz = dz;
		    tempIndex = k;
		    }
		}

	    if(closestSphere != -1.f)
		{
		*hueReturn = spheres[tempIndex].hue(t);
		*brightnessReturn = spheres[tempIndex].brightness(tempDz);
		}
	    else
		{
		*brightnessReturn = 0.f;
		}
	    }

	/*--------------------------------------*\
	|*		Attribut		*|
	\*--------------------------------------*/

    private:

	// Tools
	int nbSphere;
	Sphere* ptrDevTabSphere;

    };

/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/
