#include <cuda_runtime.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
  float *host, *device;
  cudaError_t res;

  long size = sizeof(float) << atol(argv[1]);
  if ((host = (float *)malloc(size)) == NULL) {
    fprintf(stderr, "cpu2gpu fail to allocate host memory\n");
    exit(1);
  }
  fprintf(stderr, "size: %.2fGB\n",
          (double)size / (double)(1 << (10 + 10 + 10)));
  if ((res = cudaMallocHost(&device, size)) != cudaSuccess) {
    fprintf(stderr, "cpu2gpu cudaMalloc failed: '%s'\n",
            cudaGetErrorString(res));
    exit(1);
  }
  if ((res = cudaMalloc(&device, size)) != cudaSuccess) {
    fprintf(stderr, "cpu2gpu cudaMalloc failed: '%s'\n",
            cudaGetErrorString(res));
    exit(1);
  }
  fprintf(stderr, "cpu2gpu start cudaMemcpy\n");
  if ((res = cudaMemcpy(device, host, size, cudaMemcpyHostToDevice)) !=
      cudaSuccess) {
    fprintf(stderr, "cpu2gpu cudaMalloc failed: '%s'\n",
            cudaGetErrorString(res));
    exit(1);
  }
  fprintf(stderr, "cpu2gpu end cudaMemcpy\n");
  cudaFreeHost(host);
  cudaFree(device);
}
