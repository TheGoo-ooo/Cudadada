class SliceMath{
	public : 
	__device__ static float getSlice(float x){
	    return 1.0 / (1.0 + (x * x));
	}
};
