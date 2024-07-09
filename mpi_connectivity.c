#include <mpi.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
    MPI_Status status;
    int rank, size, peer, i, j;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    for (i = 0; i < size; i++) {
        if (rank == i) {
            for (j = i + 1; j < size; j++) {
	      printf("mpi_connectivity: %d - %d\n", i, j);
                MPI_Send(&rank, 1, MPI_INT, j, rank, MPI_COMM_WORLD);
                MPI_Recv(&peer, 1, MPI_INT, j, j, MPI_COMM_WORLD, &status);
            }
        } else if (rank > i) {
            MPI_Recv(&peer, 1, MPI_INT, i, i, MPI_COMM_WORLD, &status);
            MPI_Send(&rank, 1, MPI_INT, i, rank, MPI_COMM_WORLD);
        }
    }
    MPI_Barrier(MPI_COMM_WORLD);
    if (rank == 0)
        printf("mpi_connectivity: passed on %d\n", size);
    MPI_Finalize();
    return 0;
}
