#ifndef SRC_CPP_CORE_04_MONTECARLO_HOST_MONTECARLO_H_
#define SRC_CPP_CORE_04_MONTECARLO_HOST_MONTECARLO_H_


#pragma once

#include "cudaTools.h"
#include "Grid.h"

#include <curand_kernel.h>

class Montecarlo
    {
    public:
	Montecarlo(const Grid& grid, float m,  uint n);
	virtual ~Montecarlo(void);
    public:
	float get_pi();
	void run();
	uint get_n0();
    private:
	float m, pi, res;

	dim3 dg;
	dim3 db;
	uint n;

	uint n0, nbThread;
	uint* p_dev_gm;

	curandState* p_ary_gen_gm;

	size_t sizeOGM;
	size_t sizeOSM;

    };
#endif 

