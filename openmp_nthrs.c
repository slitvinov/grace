#include <omp.h>
#include <stdio.h>

int main() {
  int i, n;
#pragma omp parallel private(i, n)
  {
    i = omp_get_thread_num();
    n = omp_get_num_threads();
#pragma omp critical
    printf("omp_nthrs: %d/%d\n", i, n);
  }
}
