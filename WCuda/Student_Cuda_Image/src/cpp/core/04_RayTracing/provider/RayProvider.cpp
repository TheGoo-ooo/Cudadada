#include "../../04_RayTracing/provider/RayProvider.h"

#include "MathTools.h"
#include "Grid.h"

#include "NbSpheres.h"

#include "../../04_RayTracing/moo/host/Ray.h"



/*----------------------------------------------------------------------*\
 |*			Declaration 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Imported	 	*|
 \*-------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

/*----------------------------------------------------------------------*\
 |*			Implementation 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

/**
 * Override
 */
// Why float? because Lucy in the Sky with Diamonds! :D
Animable_I<float4>* RayProvider::createAnimable()
    {
    // Animation;
    float dt = 0.001;

    // NbSphere
    int nbSphere = NB_SPHERE;

    // Dimension
    int w = 16 * 60;
    int h = w;

    // Grid Cuda
    int mp = Device::getMPCount();
    int coreMP = Device::getCoreCountMP();

    mp = 24;
    coreMP = 128;

    dim3 dg = dim3(mp, 2, 1);
    dim3 db = dim3(coreMP, 2, 1);
    Grid grid(dg, db);


    return new Ray(grid, nbSphere, w, h, dt);
    }

/**
 * Override
 */
Image_I* RayProvider::createImageGL(void)
    {
    ColorRGB_01 colorTexte(0, 1, 0); // Green
    //return new ImageAnimable_HUE_float(createAnimable(), colorTexte);
    return new ImageAnimable_HSBA_float4(createAnimable(), colorTexte);
    }



/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/