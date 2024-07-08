#include <cuda_runtime.h>
#include <errno.h>
#include <stdio.h>
#include <sys/mman.h>

int main(int argc, char **argv) {
  float *host, *device;
  int fd;
  unsigned char c = '\0';
  FILE *file;
  cudaError_t res;

  long size = sizeof(float) << atol(argv[1]);
  if ((file = fopen("file.raw", "w")) == NULL) {
    fprintf(stderr, "memory: fail to create file\n");
    exit(1);
  }
  if (fseek(file, size - 1, SEEK_SET) == -1) {
    fprintf(stderr, "memory: fseek failed\n");
    exit(1);
  }
  if (fwrite(&c, 1, sizeof(c), file) != 1) {
    fprintf(stderr, "memory: fwrite failed\n");
    exit(1);
  }
  if (fclose(file) != 0) {
    fprintf(stderr, "memory: fclose failed\n");
    exit(1);
  }
  if ((file = fopen("file.raw", "r+")) == NULL) {
    fprintf(stderr, "memory: fail reopen\n");
    exit(1);
  }
  if ((fd = fileno(file)) == -1) {
    fprintf(stderr, "memory: fileno failed\n");
    exit(1);
  }
  host = (float *)mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
  if (host == (void *)-1) {
    fprintf(stderr, "memory: mmap failed\n");
    fprintf(stderr, "memory: errno = %d\n", errno);
    exit(1);
  }
  fprintf(stderr, "size: %.2fGB\n",
          (double)size / (double)(1 << (10 + 10 + 10)));
  if ((res = cudaMalloc(&device, size)) != cudaSuccess) {
    fprintf(stderr, "memory: cudaMalloc failed: '%s'\n",
            cudaGetErrorString(res));
    exit(1);
  }
  if ((res = cudaMemcpy(device, host, size, cudaMemcpyHostToDevice)) !=
      cudaSuccess) {
    fprintf(stderr, "memory: cudaMalloc failed: '%s'\n",
            cudaGetErrorString(res));
    exit(1);
  }
  if (fclose(file) != 0) {
    fprintf(stderr, "memory: fclose failed\n");
    exit(1);
  }
  cudaFree(device);
}
