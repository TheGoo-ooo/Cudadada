#include <iostream>
#include "Device.h"

#include "Montecarlo.h"
using std::cout;
using std::endl;

extern __global__ void montecarlo(uint* p_ary_gm, curandState* ptr_ary_gen_gm, uint n);
extern __global__ void createGenerator(curandState* ary_gen_gm, int deviceId);

Montecarlo::Montecarlo(const Grid& grid, float m, uint n) : n(n) {

    this->res = 0;
    this->pi = 0;
    this->n0 = 0;
    this->m = m;

    this->nbThread = grid.threadCounts();
    this->nbThread = this->n / grid.threadCounts();

    size_t sizeOGenGM = grid.threadCounts() * sizeof(curandState);

    this->sizeOSM = grid.db.x * sizeof(uint);
    this->sizeOGM = sizeof(uint);

    Device::malloc(&p_dev_gm, sizeOGM); //ptrDevTabGM
    Device::memclear(&p_dev_gm, sizeOGM);
    Device::malloc(&p_ary_gen_gm, sizeOGenGM);

    this->dg = grid.dg;
    this->db = grid.db;
    }

Montecarlo::~Montecarlo(void){
	Device::free(p_dev_gm);
	Device::free(p_ary_gen_gm);
    }

float Montecarlo::get_pi()
    {
    return pi;
    }

uint Montecarlo::get_n0()
    {
    return n0;
}

void Montecarlo::run()
    {
    createGenerator<<<dg,db>>>(p_ary_gen_gm, Device::getDeviceId()); // assynchrone
    montecarlo<<<dg,db, this->sizeOSM>>>(p_dev_gm,p_ary_gen_gm , this->nbThread);// assynchrone
    Device::memcpyDToH(&n0, p_dev_gm, sizeOGM); // barriere synchronisation implicite
    pi = 4.f * n0 / n;
}
