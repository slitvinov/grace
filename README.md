# Intro

https://developer.nvidia.com/grace-cpu
https://nvidia.github.io/grace-cpu-benchmarking-guide
https://github.com/NVIDIA/grace-cpu-benchmarking-guide

# Configs

There are two nodes, `.ssh/config` snippet:

```
Host rc
     HostName login.rc.fas.harvard.edu
     User slitvinov

Host grace
     HostName holygpu7c1101
     User slitvinov
     ProxyJump rc

Host grace2
     HostName holygpu7c1103
     User slitvinov
     ProxyJump rc
```

Use `ssh-copy-id -i ~/.ssh/id_rsa.pub grace` for password-less login.

# Benchmarks

<https://nvidia.github.io/grace-cpu-benchmarking-guide/foundations/FMA/index.html>

```
$ pwd
/n/holyscratch01/koumoutsakos_lab/slitvinov
git clone https://github.com/NVIDIA/arm-kernels.git
cd arm-kernels
make
./arithmetic/fp64_sve_pred_fmla.x
4( 32(SVE_FMLA_64b) );
Iterations;100000000
Total Inst;12800000000
Total Ops;51200000000
Inst/Iter;128
Ops/Iter;512
Seconds;0.96202
GOps/sec;53.2213
```

```
$ perf
-bash: perf: command not found
```

```
$ wget https://www.cs.virginia.edu/stream/FTP/Code/stream.c
$ STREAM_ARRAY_SIZE="($(nproc)/72*120000000)"
$ gcc -Ofast -march=native -fopenmp -mcmodel=large -fno-PIC \
	-DSTREAM_ARRAY_SIZE=${STREAM_ARRAY_SIZE} -DNTIMES=200 \
	-o stream_openmp.exe stream.c
$ STREAM_ARRAY_SIZE="($(nproc)/72*120000000)"
$ OMP_NUM_THREADS=72 OMP_PROC_BIND=spread ./stream_openmp.exe
...
Function    Best Rate MB/s  Avg time     Min time     Max time
Copy:          355230.0     0.005579     0.005405     0.010008
Scale:         355622.2     0.005568     0.005399     0.006713
Add:           348376.2     0.008766     0.008267     0.009930
Triad:         349303.0     0.008727     0.008245     0.009891
```

```
git clone git@github.com:slitvinov/taubench.git
cd taubench
module purge
module load mpi/openmpi-aarch64
make -B 'CFLAGS = -Ofast -march=native'
$ mpiexec ./taubench -n 100000 -s 100
--------------------------------------------------------------------------
WARNING: No preset parameters were found for the device that Open MPI
detected:

  Local host:            holygpu7c1101
  Device name:           mlx5_0
  Device vendor ID:      0x02c9
  Device vendor part ID: 4129

Default device parameters will be used, which may result in lower
performance.  You can edit any of the files specified by the
btl_openib_device_param_files MCA parameter to set values for your
device.

NOTE: You can turn off this warning by setting the MCA parameter
      btl_openib_warn_no_device_params_found to 0.
--------------------------------------------------------------------------
--------------------------------------------------------------------------
WARNING: There was an error initializing an OpenFabrics device.

  Local host:   holygpu7c1101
  Local device: mlx5_0
--------------------------------------------------------------------------
This is TauBench.
Evaluating kernels - please be patient.
..........[holygpu7c1101:317398] 71 more processes have sent help message help-mpi-btl-openib.txt / no device params found
[holygpu7c1101:317398] Set MCA parameter "orte_base_help_aggregate" to 0 to see all help / error messages
[holygpu7c1101:317398] 71 more processes have sent help message help-mpi-btl-openib.txt / error in device init
..........................................................................................

	- kernel_1_0 :      3.711 secs -   3791.374 mflops
	- kernel_1_1 :      1.516 secs -   1438.184 mflops
	- kernel_2_1 :      2.849 secs -   3485.703 mflops
	- kernel_2_2 :      1.490 secs -   8190.321 mflops
	- kernel_2_3 :      0.607 secs -   4056.084 mflops
	- kernel_2_4 :      1.088 secs -   5094.267 mflops
	- kernel_3_0 :      2.453 secs -  11163.098 mflops

	       total :     13.325 secs - 342060.224 mflops

points     :     100000
steps      :        100
procs      :         72

comp       :     13.054 secs
comm       :      0.271 secs
comm ratio :      0.021
```


```
git clone https://github.com/graph500/graph500.git
cd graph500/src
sed -i '/^CFLAGS/s/$/ -DPROCS_PER_NODE_NOT_POWER_OF_TWO -fcommon/' Makefile
module purge
module load mpi/openmpi-aarch64
make
(unset SKIP_BFS && SKIP_VALIDATION=1 && mpiexec --map-by core graph500_reference_bfs 28 16 )
Running BFS 0
Time for BFS 0 is 4.516987
TEPS for BFS 0 is 9.50838e+08
Validating BFS 0
Validate time for BFS 0 is 21.339114
Running BFS 1
Time for BFS 1 is 4.395484
TEPS for BFS 1 is 9.77121e+08
Validating BFS 1
Validate time for BFS 1 is 21.423941
Running BFS 2
Time for BFS 2 is 4.523906
TEPS for BFS 2 is 9.49383e+08
Validating BFS 2
Validate time for BFS 2 is 21.465117
Running BFS 3
Time for BFS 3 is 4.322967
TEPS for BFS 3 is 9.93512e+08
Validating BFS 3
Validate time for BFS 3 is 21.456094
Running BFS 4
Time for BFS 4 is 4.294191
TEPS for BFS 4 is 1.00017e+09
Validating BFS 4
Validate time for BFS 4 is 21.462591
Running BFS 5
Time for BFS 5 is 4.280513
TEPS for BFS 5 is 1.00337e+09
Validating BFS 5
Validate time for BFS 5 is 21.391781
Running BFS 6
Time for BFS 6 is 4.372592
TEPS for BFS 6 is 9.82237e+08
Validating BFS 6
Validate time for BFS 6 is 21.476225
Running BFS 7
Time for BFS 7 is 4.468946
TEPS for BFS 7 is 9.61059e+08
Validating BFS 7
Validate time for BFS 7 is 21.488726
Running BFS 8
Time for BFS 8 is 4.374211
TEPS for BFS 8 is 9.81873e+08
Validating BFS 8
Validate time for BFS 8 is 21.480797
Running BFS 9
Time for BFS 9 is 4.400043
TEPS for BFS 9 is 9.76109e+08
Validating BFS 9
Validate time for BFS 9 is 21.451928
Running BFS 10
Time for BFS 10 is 4.330889
TEPS for BFS 10 is 9.91695e+08
Validating BFS 10
Validate time for BFS 10 is 21.428554
Running BFS 11
Time for BFS 11 is 4.387103
TEPS for BFS 11 is 9.78988e+08
Validating BFS 11
Validate time for BFS 11 is 21.466677
Running BFS 12
Time for BFS 12 is 4.565616
TEPS for BFS 12 is 9.4071e+08
Validating BFS 12
```
