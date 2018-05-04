#pragma once

#include "MandelbrotMath.h"

#include "cudaType_CPU.h"
#include "Variateur_CPU.h"
#include "Animable_I_CPU.h"

using namespace cpu;

/*----------------------------------------------------------------------*\
 |*			Declaration 					*|
 \*---------------------------------------------------------------------*/

class Mandelbrot : public Animable_I<uchar4>
{
	/*--------------------------------------*\
	|*		Constructor		*|
	\*--------------------------------------*/
    public:

	Mandelbrot(uint w, uint h, float dt, uint n, const DomaineMath& domaineMath);

	/*-------------------------------------*\
	|*		Destructor		*|
	\*-------------------------------------*/

	virtual ~Mandelbrot(void);

	/*--------------------------------------*\
	|*		Methode			*|
	\*-------------------------------------*/

	public:
	    /*-------------------------*\
	    |*   Override Animable_I   *|
	    \*-------------------------*/

	    /**
	     * Call periodicly by the api
	     */
	    virtual void processEntrelacementOMP(uchar4* ptrTabPixels, uint w, uint h, const DomaineMath& domaineMath);

	    /**
	     * Call periodicly by the api
	     */
	    virtual void processForAutoOMP(uchar4* ptrTabPixels, uint w, uint h, const DomaineMath& domaineMath);

	    /**
	     * Call periodicly by the api
	     */
	    virtual void animationStep();

	private:

	     /**
	     * i in [0,h[
	     * j in [0,w[
	     *
	     * code commun a:
	     * 	- entrelacementOMP
	     * 	- forAutoOMP
	     */
	    void workPixel(uchar4* ptrColorIJ, int i, int j, const DomaineMath& domaineMath, MandelbrotMath* ptrMandelbrotMath);


	/*--------------------------------------*\
	|*		Attribut		*|
	\*-------------------------------------*/

	private:

	    // Inputs
	    uint n;

	    // Tools
	    Variateur<float> variateurAnimation;

};
