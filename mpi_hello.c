#include "mpi.h"
#include <stdio.h>
int main(int argc, char *argv[])
{
    int i, rank, size, len;
    char version[MPI_MAX_LIBRARY_VERSION_STRING];
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Get_library_version(version, &len);
    for (i = 0; i < size; i++) {
      if (i == rank)
	printf("mpi_helo: %d/%d: %s)\n", rank, size, version);
      MPI_Barrier(MPI_COMM_WORLD);
    }
    MPI_Finalize();
}
