# Intro

- https://developer.nvidia.com/grace-cpu
- https://nvidia.github.io/grace-cpu-benchmarking-guide
- https://github.com/NVIDIA/grace-cpu-benchmarking-guide

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

# System

```
$ lscpu
Architecture:           aarch64
  CPU op-mode(s):       64-bit
  Byte Order:           Little Endian
CPU(s):                 72
  On-line CPU(s) list:  0-71
Vendor ID:              ARM
  Model name:           Neoverse-V2
    Model:              0
    Thread(s) per core: 1
    Core(s) per socket: 72
    Socket(s):          1
    Stepping:           r0p0
    Frequency boost:    disabled
    CPU max MHz:        3438.0000
    CPU min MHz:        81.0000
    BogoMIPS:           2000.00
    Flags:              fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid asimdrdm js
			cvt fcma lrcpc dcpop sha3 sm3 sm4 asimddp sha512 sve asimdfhm dit uscat ilrcpc fl
			agm ssbs sb dcpodp sve2 sveaes svepmull svebitperm svesha3 svesm4 flagm2 frint sv
			ei8mm svebf16 i8mm bf16 dgh
Caches (sum of all):
  L1d:                  4.5 MiB (72 instances)
  L1i:                  4.5 MiB (72 instances)
  L2:                   72 MiB (72 instances)
  L3:                   114 MiB (1 instance)
NUMA:
  NUMA node(s):         8
  NUMA node0 CPU(s):    0-71
  NUMA node2 CPU(s):
  NUMA node3 CPU(s):
  NUMA node4 CPU(s):
  NUMA node5 CPU(s):
  NUMA node6 CPU(s):
  NUMA node7 CPU(s):
  NUMA node8 CPU(s):
Vulnerabilities:
  Gather data sampling: Not affected
  Itlb multihit:        Not affected
  L1tf:                 Not affected
  Mds:                  Not affected
  Meltdown:             Not affected
  Mmio stale data:      Not affected
  Retbleed:             Not affected
  Spec rstack overflow: Not affected
  Spec store bypass:    Mitigation; Speculative Store Bypass disabled via prctl
  Spectre v1:           Mitigation; __user pointer sanitization
  Spectre v2:           Not affected
  Srbds:                Not affected
  Tsx async abort:      Not affected
$ nvidia-smi
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 535.154.05             Driver Version: 535.154.05   CUDA Version: 12.2     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA GH200 480GB             Off | 00000009:01:00.0 Off |                    0 |
| N/A   38C    P0             106W / 900W |      1MiB / 97871MiB |      2%      Default |
|                                         |                      |             Disabled |
+-----------------------------------------+----------------------+----------------------+

+---------------------------------------------------------------------------------------+
| Processes:                                                                            |
|  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
|        ID   ID                                                             Usage      |
|=======================================================================================|
|  No running processes found                                                           |
+---------------------------------------------------------------------------------------+
```

# Build tool-chain from the source

[GCC](https://docs.nvidia.com/grace-performance-tuning-guide.pdf)

```
wget -q https://ftp.gnu.org/gnu/gcc/gcc-14.1.0/gcc-14.1.0.tar.gz
tar -xzf gcc-14.1.0.tar.gz
cd gcc-14.1.0
./contrib/download_prerequisites
./configure --enable-silent-rules --disable-multilib --with-static-standard-libraries --enable-languages=c,c++,fortran --prefix=$HOME/.grace
MAKEFLAGS=-j`nproc` make V=0
make install
```

Needs [binutils](https://www.gnu.org/software/binutils)
```
wget -q https://ftp.gnu.org/gnu/binutils/binutils-2.42.tar.gz
tar zxf binutils-2.42.tar.gz
cd binutils-2.42
./configure --enable-silent-rules --prefix=$HOME/.grace
MAKEFLAGS=-j`nproc` make V=0
make install
```

[OpenMPI](https://nvidia.github.io/grace-cpu-benchmarking-guide/benchmarks/Graph500/index.html),
needs [libevent](https://libevent.org) and
[prrte](https://docs.prrte.org)

```
wget -q https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
tar -xzf libevent-2.1.12-stable.tar.gz
cd libevent-2.1.12-stable
PATH=$HOME/.grace/bin:$PATH ./configure --enable-silent-rules --prefix=$HOME/.grace
MAKEFLAGS=-j`nproc` make V=0
make install
```


```
wget -q https://github.com/openpmix/prrte/releases/download/v3.0.5/prrte-3.0.5.tar.gz
tar zxf prrte-3.0.5.tar.gz
cd prrte-3.0.5
PKG_CONFIG_PATH=$HOME/.grace/lib/pkgconfig:$PKG_CONFIG_PATH PATH=$HOME/.grace/bin:$PATH ./configure --prefix=$HOME/.grace --enable-silent-rules
MAKEFLAGS=-j`nproc` make
make install
```

```
wget -q https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.1.tar.gz
tar -xzf openmpi-5.0.1.tar.gz
cd openmpi-5.0.1
PKG_CONFIG_PATH=$HOME/.grace/lib/pkgconfig:$PKG_CONFIG_PATH PATH=$HOME/.grace/bin:$PATH ./configure --prefix=$HOME/.grace --enable-silent-rules
MAKEFLAGS=-j`nproc` make V=0
make install
```


# Benchmarks

<https://nvidia.github.io/grace-cpu-benchmarking-guide/foundations/FMA/index.html>

```
git clone https://github.com/NVIDIA/arm-kernels.git
cd arm-kernels
PATH=$HOME/.grace/bin:$PATH MAKEFLAGS=-j`nproc` make 'CXXFLAGS = -Ofast -mcpu=native -Wl,-R$(HOME)/.grace/lib64'
./arithmetic/fp64_sve_pred_fmla.x
4( 32(SVE_FMLA_64b) );
Iterations;100000000
Total Inst;12800000000
Total Ops;51200000000
Inst/Iter;128
Ops/Iter;512
Seconds;0.984067
GOps/sec;52.029
```

```
$ perf
-bash: perf: command not found
```

```
$ wget https://www.cs.virginia.edu/stream/FTP/Code/stream.c
$ STREAM_ARRAY_SIZE="($(nproc)/72*120000000)"
$ PATH=$HOME/.grace/bin:$PATH gcc -Ofast -march=native -fopenmp -mcmodel=large -fno-PIC \
	-DSTREAM_ARRAY_SIZE=${STREAM_ARRAY_SIZE} -DNTIMES=200 \
	-o stream_openmp.exe stream.c
$ OMP_NUM_THREADS=72 OMP_PROC_BIND=spread ./stream_openmp.exe
...
Function    Best Rate MB/s  Avg time     Min time     Max time
Copy:          352817.7     0.005577     0.005442     0.006919
Scale:         351769.7     0.005622     0.005458     0.006604
Add:           332872.1     0.009189     0.008652     0.013968
Triad:         332295.2     0.009136     0.008667     0.010838
```

```
git clone git@github.com:slitvinov/taubench.git
cd taubench
PATH=$HOME/.grace/bin:$PATH make -B 'CFLAGS = -Ofast -march=native'
PATH=$HOME/.grace/bin:$PATH LD_LIBRARY_PATH=$HOME/.grace/lib mpiexec ./taubench -n 100000 -s 100
PATH=$HOME/.grace/bin:$PATH LD_LIBRARY_PATH=$HOME/.grace/lib:$HOME/.grace/lib64 mpiexec -- ./taubench -n 100000 -s 100
	- kernel_1_0 :      3.813 secs -   3690.154 mflops
	- kernel_1_1 :      1.641 secs -   1329.123 mflops
	- kernel_2_1 :      2.952 secs -   3364.155 mflops
	- kernel_2_2 :      1.539 secs -   7929.241 mflops
	- kernel_2_3 :      0.629 secs -   3917.348 mflops
	- kernel_2_4 :      1.132 secs -   4896.792 mflops
	- kernel_3_0 :      2.435 secs -  11247.824 mflops

	       total :     13.575 secs - 335756.619 mflops

points     :     100000
steps      :        100
procs      :         72

comp       :     13.294 secs
comm       :      0.281 secs
comm ratio :      0.021
```


```
git clone https://github.com/graph500/graph500.git
cd graph500/src
sed -i '/^CFLAGS/s/$/ -DPROCS_PER_NODE_NOT_POWER_OF_TWO -fcommon/' Makefile
PATH=$HOME/.grace/bin:$PATH make
SKIP_VALIDATION=1 PATH=$HOME/.grace/bin:$PATH LD_LIBRARY_PATH=$HOME/.grace/lib:$HOME/.grace/lib64 mpiexec --map-by core -- graph500_reference_bfs 28 16
graph_generation:               37.564225 s
construction_time:              19.833230 s
Running BFS 0
Time for BFS 0 is 3.015591
TEPS for BFS 0 is 1.42424e+09
Running BFS 1
Time for BFS 1 is 2.901872
TEPS for BFS 1 is 1.48005e+09
Running BFS 2
Time for BFS 2 is 3.025457
TEPS for BFS 2 is 1.41959e+09
Running BFS 3
Time for BFS 3 is 2.805943
TEPS for BFS 3 is 1.53065e+09
Running BFS 4
Time for BFS 4 is 2.776585
TEPS for BFS 4 is 1.54684e+09
Running BFS 5
Time for BFS 5 is 2.759387
TEPS for BFS 5 is 1.55648e+09
Running BFS 6
Time for BFS 6 is 2.864005
TEPS for BFS 6 is 1.49962e+09
Running BFS 7
Time for BFS 7 is 2.867877
TEPS for BFS 7 is 1.4976e+09
Running BFS 8
Time for BFS 8 is 2.863208
TEPS for BFS 8 is 1.50004e+09
Running BFS 9
Time for BFS 9 is 2.858456
TEPS for BFS 9 is 1.50253e+09
Running BFS 10
Time for BFS 10 is 2.801623
TEPS for BFS 10 is 1.53301e+09
Running BFS 11
Time for BFS 11 is 2.845061
TEPS for BFS 11 is 1.50961e+09
Running BFS 12
Time for BFS 12 is 3.056471
TEPS for BFS 12 is 1.40519e+09
Running BFS 13
Time for BFS 13 is 3.062045
TEPS for BFS 13 is 1.40263e+09
Running BFS 14
Time for BFS 14 is 3.007415
TEPS for BFS 14 is 1.42811e+09
Running BFS 15
Time for BFS 15 is 2.852837
TEPS for BFS 15 is 1.50549e+09
Running BFS 16
Time for BFS 16 is 2.880989
TEPS for BFS 16 is 1.49078e+09
Running BFS 17
Time for BFS 17 is 2.902134
TEPS for BFS 17 is 1.47992e+09
Running BFS 18
Time for BFS 18 is 2.787615
TEPS for BFS 18 is 1.54072e+09
Running BFS 19
Time for BFS 19 is 2.854993
TEPS for BFS 19 is 1.50435e+09
Running BFS 20
Time for BFS 20 is 3.054192
TEPS for BFS 20 is 1.40624e+09
Running BFS 21
Time for BFS 21 is 2.820233
TEPS for BFS 21 is 1.5229e+09
Running BFS 22
Time for BFS 22 is 2.866649
TEPS for BFS 22 is 1.49824e+09
Running BFS 23
Time for BFS 23 is 2.859108
TEPS for BFS 23 is 1.50219e+09
Running BFS 24
Time for BFS 24 is 2.836399
TEPS for BFS 24 is 1.51422e+09
Running BFS 25
Time for BFS 25 is 2.901598
TEPS for BFS 25 is 1.48019e+09
Running BFS 26
Time for BFS 26 is 2.914673
TEPS for BFS 26 is 1.47355e+09
Running BFS 27
Time for BFS 27 is 3.047967
TEPS for BFS 27 is 1.40911e+09
Running BFS 28
Time for BFS 28 is 2.820724
TEPS for BFS 28 is 1.52263e+09
Running BFS 29
Time for BFS 29 is 2.946909
TEPS for BFS 29 is 1.45743e+09
Running BFS 30
Time for BFS 30 is 3.091726
TEPS for BFS 30 is 1.38917e+09
Running BFS 31
Time for BFS 31 is 2.924968
TEPS for BFS 31 is 1.46837e+09
Running BFS 32
Time for BFS 32 is 3.028530
TEPS for BFS 32 is 1.41815e+09
Running BFS 33
Time for BFS 33 is 2.810529
TEPS for BFS 33 is 1.52815e+09
Running BFS 34
Time for BFS 34 is 3.089520
TEPS for BFS 34 is 1.39016e+09
Running BFS 35
Time for BFS 35 is 2.823198
TEPS for BFS 35 is 1.5213e+09
Running BFS 36
Time for BFS 36 is 2.822866
TEPS for BFS 36 is 1.52148e+09
Running BFS 37
Time for BFS 37 is 3.119964
TEPS for BFS 37 is 1.37659e+09
Running BFS 38
Time for BFS 38 is 2.852594
TEPS for BFS 38 is 1.50562e+09
Running BFS 39
Time for BFS 39 is 2.851753
TEPS for BFS 39 is 1.50606e+09
Running BFS 40
Time for BFS 40 is 2.856126
TEPS for BFS 40 is 1.50376e+09
Running BFS 41
Time for BFS 41 is 2.855642
TEPS for BFS 41 is 1.50401e+09
Running BFS 42
Time for BFS 42 is 3.110001
TEPS for BFS 42 is 1.381e+09
Running BFS 43
Time for BFS 43 is 2.816489
TEPS for BFS 43 is 1.52492e+09
Running BFS 44
Time for BFS 44 is 2.826057
TEPS for BFS 44 is 1.51976e+09
Running BFS 45
Time for BFS 45 is 3.105557
TEPS for BFS 45 is 1.38298e+09
Running BFS 46
Time for BFS 46 is 2.854154
TEPS for BFS 46 is 1.5048e+09
Running BFS 47
Time for BFS 47 is 3.099844
TEPS for BFS 47 is 1.38553e+09
Running BFS 48
Time for BFS 48 is 3.118248
TEPS for BFS 48 is 1.37735e+09
Running BFS 49
Time for BFS 49 is 2.980731
TEPS for BFS 49 is 1.4409e+09
Running BFS 50
Time for BFS 50 is 3.003850
TEPS for BFS 50 is 1.42981e+09
Running BFS 51
Time for BFS 51 is 2.835379
TEPS for BFS 51 is 1.51476e+09
Running BFS 52
Time for BFS 52 is 2.878193
TEPS for BFS 52 is 1.49223e+09
Running BFS 53
Time for BFS 53 is 2.858907
TEPS for BFS 53 is 1.50229e+09
Running BFS 54
Time for BFS 54 is 3.116181
TEPS for BFS 54 is 1.37826e+09
Running BFS 55
Time for BFS 55 is 2.932990
TEPS for BFS 55 is 1.46435e+09
Running BFS 56
Time for BFS 56 is 3.017648
TEPS for BFS 56 is 1.42327e+09
Running BFS 57
Time for BFS 57 is 2.849837
TEPS for BFS 57 is 1.50708e+09
Running BFS 58
Time for BFS 58 is 2.960214
TEPS for BFS 58 is 1.45088e+09
Running BFS 59
Time for BFS 59 is 2.936938
TEPS for BFS 59 is 1.46238e+09
Running BFS 60
Time for BFS 60 is 2.822888
TEPS for BFS 60 is 1.52146e+09
Running BFS 61
Time for BFS 61 is 2.935457
TEPS for BFS 61 is 1.46312e+09
Running BFS 62
Time for BFS 62 is 3.011069
TEPS for BFS 62 is 1.42638e+09
Running BFS 63
Time for BFS 63 is 2.875311
TEPS for BFS 63 is 1.49372e+09
SCALE:                          28
edgefactor:                     16
NBFS:                           64
graph_generation:               37.5642
num_mpi_processes:              72
construction_time:              19.8332
bfs  min_time:                  2.75939
bfs  firstquartile_time:        2.84745
bfs  median_time:               2.87675
bfs  thirdquartile_time:        3.01333
bfs  max_time:                  3.11996
bfs  mean_time:                 2.9208
bfs  stddev_time:               0.103771
min_nedge:                      4294921166
firstquartile_nedge:            4294921166
median_nedge:                   4294921166
thirdquartile_nedge:            4294921166
max_nedge:                      4294921166
mean_nedge:                     4294921166
stddev_nedge:                   0
bfs  min_TEPS:                  1.37659e+09
bfs  firstquartile_TEPS:        1.42531e+09
bfs  median_TEPS:               1.49298e+09
bfs  thirdquartile_TEPS:        1.50834e+09
bfs  max_TEPS:                  1.55648e+09
bfs  harmonic_mean_TEPS:     !  1.47046e+09
bfs  harmonic_stddev_TEPS:      6.58196e+06
bfs  min_validate:              -1
bfs  firstquartile_validate:    -1
bfs  median_validate:           -1
bfs  thirdquartile_validate:    -1
bfs  max_validate:              -1
bfs  mean_validate:             -1
bfs  stddev_validate:           0
```

[aphros](https://github.com/cselab/aphros)
```
git clone https://github.com/cselab/aphros.git
cd aphros/deploy
./install_setenv $HOME/.local/bin
. ap.setenv
mkdir build
cd build
PATH=$HOME/.grace/bin:$PATH cmake ..
PATH=$HOME/.grace/bin:$PATH MAKEFLAGS=-j`nproc` make
PATH=$HOME/.grace/bin:$PATH MAKEFLAGS=-j`nproc` make install
cd ../../src
mkdir build
cd build
cmake .. -DUSE_HYPRE=0 -DFIND_HDF=0 -DUSE_TESTS=0 -DUSE_BACKEND_CUBISM=0 -DUSE_BACKEND_LOCAL=1 -DUSE_BACKEND_NATIVE=1 -DUSE_HDF=0 -DUSE_AVX=0 -DUSE_OPENMP=0 -DMPI_CXX_COMPILER=$HOME/.grace/bin/mpicxx -DMPI_C_COMPILER=$HOME/.grace/bin/mpicc
make -j 72 'VERBOSE = 1'
```
