#include <cuda_runtime.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
  float *host, *device;
  cudaError_t res;

  long size = sizeof(float) << atol(argv[1]);
  if ((host = (float*)malloc(size)) == NULL) {
    fprintf(stderr, "memory: fail to allocate host memory\n");
    exit(1);
  }
  fprintf(stderr, "size: %.2fGB\n",
          (double)size / (double)(1 << (10 + 10 + 10)));
  if ((res = cudaMallocHost(&device, size)) != cudaSuccess) {
    fprintf(stderr, "memory: cudaMalloc failed: '%s'\n",
            cudaGetErrorString(res));
    exit(1);
  }
  if ((res = cudaMalloc(&device, size)) != cudaSuccess) {
    fprintf(stderr, "memory: cudaMalloc failed: '%s'\n",
            cudaGetErrorString(res));
    exit(1);
  }
  fprintf(stderr, "memory: start cudaMemcpy\n");
  if ((res = cudaMemcpy(device, host, size, cudaMemcpyHostToDevice)) !=
      cudaSuccess) {
    fprintf(stderr, "memory: cudaMalloc failed: '%s'\n",
            cudaGetErrorString(res));
    exit(1);
  }
  fprintf(stderr, "memory: end cudaMemcpy\n");
  cudaFreeHost(host);
  cudaFree(device);
}
