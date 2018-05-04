#include <iostream>
#include <stdlib.h>

#include "MandelbrotProvider.h"
#include "RipplingProvider.h"
#include "Animateur_GPU.h"
#include "Settings_GPU.h"

#include "04_RayTracing/provider/RayProvider.h"
using namespace gpu;

using std::cout;
using std::endl;

/*----------------------------------------------------------------------*\
 |*			Declaration 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Imported	 	*|
 \*-------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

int mainAnimable(Settings& settings);

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

static void mandelbrot();
static void rippling();
static void rayTracing();

// Tools
template<typename T>
static void animer(Provider_I<T>* ptrProvider, int nbIteration);

/*----------------------------------------------------------------------*\
 |*			Implementation 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

int mainAnimable(Settings& settings)
    {
    cout << "\n[Animable] mode" << endl;

    // Attention : pas tous a la fois

    mandelbrot();
    //rayTracing();
    //rippling();

    cout << "\n[Animable] end" << endl;

    return EXIT_SUCCESS;
    }

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

void mandelbrot()
    {
    const int NB_ITERATION = 50000;

    MandelbrotProvider provider;
    animer<uchar4>(&provider, NB_ITERATION);
    }

void rayTracing()
    {
    const int NB_ITERATION = 50000;

    RayProvider provider;
    // animer<float>(&provider, NB_ITERATION);
    //animer<uchar4>(&provider, NB_ITERATION);
    animer<float4>(&provider, NB_ITERATION);
    }

void rippling()
    {
    const int NB_ITERATION = 50000;

    RipplingProvider provider;
    animer<uchar4>(&provider,NB_ITERATION);
    }

/*-----------------------------------*\
 |*		Tools	        	*|
 \*-----------------------------------*/

template<typename T>
void animer(Provider_I<T>* ptrProvider, int nbIteration)
    {
    Animateur<T> animateur(ptrProvider, nbIteration);
    animateur.run();
    }

/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/

