```
$ cd /scratch/slitvinov
$ git clone -q git@github.com:slitvinov/taubench
$ cd taubench
$ module load mpi/openmpi-aarch64
$ make 'CFLAGS = -O3 -mtune=native -march=native'
$ module load mpi/openmpi-aarch64
make 'CFLAGS = -O3 -mtune=native -march=native -flto'
mpicc -O3 -mtune=native -march=native -flto flux.c -c
mpicc -O3 -mtune=native -march=native -flto main.c -c
mpicc -O3 -mtune=native -march=native -flto lim.c -c
mpicc -O3 -mtune=native -march=native -flto smooth.c -c
mpicc flux.o main.o lim.o smooth.o   -lm -o taubench
```

```
$ hostname
holygpu7c1101
$ mpiexec --mca btl vader ./taubench -n 1000000 -s 10
This is TauBench.
Evaluating kernels - please be patient.
..........

        - kernel_1_0 :      3.548 secs -   3965.913 mflops
        - kernel_1_1 :      1.447 secs -   1506.699 mflops
        - kernel_2_1 :      3.150 secs -   3152.610 mflops
        - kernel_2_2 :      1.630 secs -   7484.994 mflops
        - kernel_2_3 :      0.644 secs -   3822.254 mflops
        - kernel_2_4 :      1.077 secs -   5148.049 mflops
        - kernel_3_0 :      2.855 secs -   9594.140 mflops

               total :     14.882 secs - 306283.178 mflops

points     :    1000000
steps      :         10
procs      :         72

comp       :     13.691 secs
comm       :      1.190 secs
comm ratio :      0.087
$ for i in 1 2 3 4 5 6 7 8 9 10; do mpiexec --mca btl vader ./taubench -n 1000000 -s 10 | grep 'comp       :'; done
comp       :     13.842 secs
comp       :     13.721 secs
comp       :     13.846 secs
comp       :     13.973 secs
comp       :     13.375 secs
comp       :     13.770 secs
comp       :     13.828 secs
comp       :     13.846 secs
comp       :     13.506 secs
comp       :     14.267 secs
```

```
$ hostname
holygpu7c1103
$ mpiexec --mca btl vader ./taubench -n 1000000 -s 10
This is TauBench.
Evaluating kernels - please be patient.
..........

        - kernel_1_0 :      3.734 secs -   3768.314 mflops
        - kernel_1_1 :      1.498 secs -   1455.967 mflops
        - kernel_2_1 :      3.048 secs -   3257.931 mflops
        - kernel_2_2 :      1.735 secs -   7031.035 mflops
        - kernel_2_3 :      0.653 secs -   3772.566 mflops
        - kernel_2_4 :      1.136 secs -   4880.693 mflops
        - kernel_3_0 :      2.792 secs -   9808.433 mflops

               total :     14.688 secs - 310319.271 mflops

points     :    1000000
steps      :         10
procs      :         72

comp       :     13.896 secs
comm       :      0.792 secs
comm ratio :      0.057
$ for i in 1 2 3 4 5 6 7 8 9 10; do mpiexec --mca btl vader ./taubench -n 1000000 -s 10 | grep 'comp       :'; done
comp       :     13.936 secs
comp       :     13.880 secs
comp       :     13.791 secs
comp       :     14.249 secs
comp       :     13.987 secs
comp       :     13.494 secs
comp       :     13.518 secs
comp       :     13.918 secs
comp       :     14.187 secs
comp       :     13.497 secs
```
