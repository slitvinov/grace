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

$ cat /etc/os-release
NAME="Red Hat Enterprise Linux"
VERSION="9.3 (Plow)"
ID="rhel"
ID_LIKE="fedora"
VERSION_ID="9.3"
PLATFORM_ID="platform:el9"
PRETTY_NAME="Red Hat Enterprise Linux 9.3 (Plow)"
ANSI_COLOR="0;31"
LOGO="fedora-logo-icon"
CPE_NAME="cpe:/o:redhat:enterprise_linux:9::baseos"
HOME_URL="https://www.redhat.com/"
DOCUMENTATION_URL="https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9"
BUG_REPORT_URL="https://bugzilla.redhat.com/"

REDHAT_BUGZILLA_PRODUCT="Red Hat Enterprise Linux 9"
REDHAT_BUGZILLA_PRODUCT_VERSION=9.3
REDHAT_SUPPORT_PRODUCT="Red Hat Enterprise Linux"
REDHAT_SUPPORT_PRODUCT_VERSION="9.3"
```

# Software stack

[NVIDIA HPC SDK](https://developer.nvidia.com/hpc-sdk-downloads)

```
wget -q https://developer.download.nvidia.com/hpc-sdk/24.5/nvhpc_2024_245_Linux_aarch64_cuda_12.4.tar.gz
tar zxf nvhpc_2024_245_Linux_aarch64_cuda_12.4.tar.gz
printf '
1
/scratch/slitvinov/.grace
' | nvhpc_2024_245_Linux_aarch64_cuda_12.4/install
...
Installing NVIDIA HPC SDK version 24.5 into /scratch/slitvinov/.grace
Making symbolic link in /scratch/slitvinov/.grace/Linux_aarch64

generating environment modules for NV HPC SDK 24.5 ... done.
Installation complete.
HPC SDK successfully installed into /scratch/slitvinov/.grace

If you use the Environment Modules package, that is, the module load
command, the NVIDIA HPC SDK includes a script to set up the
appropriate module files.
...
% module load /scratch/slitvinov/.grace/modulefiles/nvhpc/24.5
...
```

[Clang for NVIDIA Grace](https://developer.nvidia.com/grace/clang)
```
wget -q https://developer.nvidia.com/downloads/assets/grace/clang/18.24.05/clang-grace-toolchain-18.24.05.tgz
tar zxf clang-grace-toolchain-18.24.05.tgz
```

[Arm Compiler for Linux](https://developer.arm.com/Tools%20and%20Software/Arm%20Compiler%20for%20Linux#Software-Download)
```
bash <(curl -L https://developer.arm.com/-/media/Files/downloads/hpc/arm-compiler-for-linux/install.sh)
```

[HDF5](https://www.hdfgroup.org/solutions/hdf5)

```
wget -q https://github.com/HDFGroup/hdf5/releases/download/hdf5_1.14.4.3/hdf5-1.14.4-3.tar.gz
tar zxf hdf5-1.14.4-3.tar.gz
cd hdf5-1.14.4-3
MODULEPATH=/scratch/`whoami`/.grace/modulefiles:$MODULEPATH module load nvhpc/24.5
./configure --enable-parallel --prefix=/scratch/`whoami`/.grace --enable-fortran CC=mpicc FC=mpif90
make -j `nproc -all`
make install -j `nproc -all`
```

[OpenMPI](https://nvidia.github.io/grace-cpu-benchmarking-guide/benchmarks/Graph500/index.html),
needs [libevent](https://libevent.org) and
[prrte](https://docs.prrte.org)

```
wget -q https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
tar -xzf libevent-2.1.12-stable.tar.gz
cd libevent-2.1.12-stable
PATH=/scratch/.grace/bin:$PATH ./configure --enable-silent-rules --prefix=/scratch/`whoami`/.grace/
MAKEFLAGS=-j`nproc --all` make V=0
make install
```

```
wget -q https://github.com/openpmix/prrte/releases/download/v3.0.5/prrte-3.0.5.tar.gz
tar zxf prrte-3.0.5.tar.gz
cd prrte-3.0.5
PKG_CONFIG_PATH=/scratch/.grace/lib/pkgconfig:$PKG_CONFIG_PATH PATH=/scratch/.grace/bin:$PATH ./configure --prefix=/scratch/`whoami`/.grace/ --enable-silent-rules
MAKEFLAGS=-j`nproc --all` make
make install
```

```
wget -q https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.1.tar.gz
tar -xzf openmpi-5.0.1.tar.gz
cd openmpi-5.0.1
PKG_CONFIG_PATH=/scratch/.grace/lib/pkgconfig:$PKG_CONFIG_PATH PATH=/scratch/.grace/bin:$PATH ./configure --prefix=/scratch/`whoami`/.grace/ --enable-silent-rules
MAKEFLAGS=-j`nproc --all` make V=0
make install
```

# Benchmarks

<https://nvidia.github.io/grace-cpu-benchmarking-guide/foundations/FMA/index.html>

[arm-kernels](https://github.com/NVIDIA/arm-kernels.git)

```
git clone https://github.com/NVIDIA/arm-kernels.git
cd arm-kernels
PATH=/scratch/.grace/bin:$PATH MAKEFLAGS=-j`nproc --all` make 'CXXFLAGS = -Ofast -mcpu=native -Wl,-R$(HOME)/.grace/lib64'
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
$ STREAM_ARRAY_SIZE="($(nproc --all)/72*120000000)"
$ PATH=/scratch/.grace/bin:$PATH gcc -Ofast -march=native -fopenmp -mcmodel=large -fno-PIC \
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

[taubench](https://github.com/slitvinov/taubench)

```
git clone git@github.com:slitvinov/taubench.git
cd taubench
module purge
MODULEPATH=/scratch/`whoami`/.grace/modulefiles:$MODULEPATH module load nvhpc/24.5
make -B 'CFLAGS = -Ofast -march=native'
mpiexec ./taubench -n 100000 -s 100
mpiexec -- ./taubench -n 100000 -s 100
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

[grace500](https://github.com/graph500/graph500)

```
git clone https://github.com/graph500/graph500.git
cd graph500/src
make
SKIP_VALIDATION=1 mpiexec --map-by core -- graph500_reference_bfs 28 16
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
PATH=/scratch/.grace/bin:$PATH cmake ..
cmake --build . --parallel `nproc -all` -v
cmake --install .
cd ../../src
mkdir build
cd build
cmake .. -DUSE_HYPRE=0 -DFIND_HDF=0 -DUSE_TESTS=0 -DUSE_BACKEND_CUBISM=0 -DUSE_BACKEND_LOCAL=1 -DUSE_BACKEND_NATIVE=1 -DUSE_HDF=0 -DUSE_AVX=0 -DUSE_OPENMP=0 -DMPI_CXX_COMPILER=/scratch/.grace/bin/mpicxx -DMPI_C_COMPILER=/scratch/.grace/bin/mpicc -DCMAKE_CXX_FLAGS='-Ofast -mcpu=native'  -DCMAKE_C_FLAGS='-Ofast -mcpu=native'
cmake --build . --parallel `nproc -all` --verbose
cmake --install .
cd ../../examples/202_coalescence
PATH=/scratch/.grace/bin:$PATH LD_LIBRARY_PATH=/scratch/.grace/lib:/scratch/.grace/lib64:$LD_LIBRARY_PATH make run
STEP=0 t=0.00000000 dt=0.00000100 wt=0.96850208
.....iter=1, diff=0.0000000000000000e+00
.....adv: t=0.00000100 dt=0.00000100
Dump n=0 t=0.00000100 target=0.00000000
dump t=0.00000100 to sm_0000.vtk
STEP=1 t=0.00000100 dt=0.00313228 wt=4.54155872
.....iter=1, diff=2.2754853953374785e+00
.....adv: t=0.00313328 dt=0.00313228
STEP=2 t=0.00313328 dt=0.00313228 wt=12.86724547
.....iter=1, diff=1.6319286789951573e+00
.....adv: t=0.00626556 dt=0.00313228
STEP=3 t=0.00626556 dt=0.00313228 wt=21.50631258
.....iter=1, diff=2.2872029003816743e+00
.....adv: t=0.00939784 dt=0.00313228
Dump n=1 t=0.00939784 target=0.01000000
dump t=0.00939784 to sm_0001.vtk
STEP=4 t=0.00939784 dt=0.00313228 wt=30.20132483
.....iter=1, diff=2.9735554721233570e+00
.....adv: t=0.01253013 dt=0.00313228
STEP=5 t=0.01253013 dt=0.00313228 wt=38.86789264
.....iter=1, diff=3.8778945340578663e+00
.....adv: t=0.01566241 dt=0.00313228
```

On Hal Step=5 was done in 36 seconds (64 cores for both).

[lammps](https://github.com/lammps/lammps)
```
git clone --depth 1 https://github.com/lammps/lammps
cd lammps/src
make yes-DPD-BASIC
PATH=/scratch/.grace/bin:$PATH make mpi -j `nproc --all` 'LMP_INC = -DLAMMPS_BIGBIG' 'CCFLAGS = -Ofast -mcpu=native'
cp lmp_mpi ~/.grace/bin/
$ cat in.run
variable        number_density equal 10
processors      * * * grid twolevel ${tasks_per_node} * * *
region region   block 0 ${Lx} 0 ${Ly} 0 ${Lz} units box
create_box 1    region

variable        Np equal ${number_density}*${Lx}*${Ly}*${Lz}
create_atoms    1 random ${Np} 123456 region
mass            1 1

neighbor        0.0 bin
neigh_modify    delay 0 every 1 check no binsize 1
comm_modify     vel yes

pair_style	dpd 0.5 1 928948
pair_coeff	1 1    4 30 1
fix		nve  all  nve
timestep        0.001
timer           ${timer}
thermo          10
thermo_modify   flush yes
run             100
PATH=/scratch/.grace/bin:$PATH LD_LIBRARY_PATH=/scratch/.grace/lib:/scratch/.grace/lib64:$LD_LIBRARY_PATH mpiexec -- lmp_mpi -in in.run -var tasks_per_node `nproc --all` -var Lx 166 -var Ly 166 -var Lz 290 -var timer 'full' -log run.log
LAMMPS (27 Jun 2024)
Created orthogonal box = (0 0 0) to (166 166 290)
  3 by 4 by 6 MPI processor grid
  3 by 4 by 6 core grid within node
Created 79912400 atoms
  using lattice units in orthogonal box = (0 0 0) to (166 166 290)
  create_atoms CPU = 1.611 seconds
New timer settings: style=full  mode=nosync  timeout=off
Generated 0 of 0 mixed pair_coeff terms from geometric mixing rule
Neighbor list info ...
  update: every = 1 steps, delay = 0 steps, check = no
  max neighbors/atom: 2000, page size: 100000
  master list distance cutoff = 1
  ghost atom cutoff = 1
  binsize = 1, bins = 166 166 290
  1 neighbor lists, perpetual/occasional/extra = 1 0 0
  (1) pair dpd, perpetual
      attributes: half, newton on
      pair build: half/bin/atomonly/newton
      stencil: half/bin/3d
      bin: standard
Setting up Verlet run ...
  Unit style    : lj
  Current step  : 0
  Time step     : 0.001
Per MPI rank memory allocation (min/avg/max) = 276 | 276.5 | 277.2 Mbytes
   Step          Temp          E_pair         E_mol          TotEng         Press
	 0   0              4.1760963      0              4.1760963      41.220053
	10   0.25060498     4.1734303      0              4.5493377      41.262391
	20   0.35628255     4.1670473      0              4.7014711      40.70425
	30   0.40822428     4.1583481      0              4.7706845      40.265617
	40   0.43791491     4.148107       0              4.8049793      39.74277
	50   0.45690198     4.1368284      0              4.8221814      39.379216
	60   0.46967931     4.1248675      0              4.8293865      39.28291
	70   0.47888779     4.1124709      0              4.8308026      39.245741
	80   0.48582839     4.0998128      0              4.8285554      39.112367
	90   0.49111743     4.087013       0              4.8236892      39.209795
       100   0.49536566     4.0741807      0              4.8172292      39.194191
Loop time of 154.212 on 72 procs for 100 steps with 79912400 atoms

Performance: 56.027 tau/day, 0.648 timesteps/s, 51.820 Matom-step/s
99.7% CPU use with 72 MPI tasks x no OpenMP threads

MPI task timing breakdown:
Section |  min time  |  avg time  |  max time  |%varavg|  %CPU | %total
-----------------------------------------------------------------------
Pair    | 62.578     | 63.469     | 65.311     |   7.6 | 100.0 | 41.16
Neigh   | 69.892     | 70.989     | 72.966     |   6.7 | 100.0 | 46.03
Comm    | 9.297      | 13.65      | 18.385     |  50.2 |  96.7 |  8.85
Output  | 0.11503    | 0.17717    | 0.46183    |  30.2 | 100.0 |  0.11
Modify  | 1.8642     | 5.1576     | 5.9345     |  64.2 |  99.8 |  3.34
Other   |            | 0.7694     |            |       |       |  0.50

Nlocal:    1.10989e+06 ave 1.11201e+06 max 1.10757e+06 min
Histogram: 3 0 8 10 14 9 12 8 7 1
Nghost:         145451 ave      146492 max      144703 min
Histogram: 5 7 5 12 18 12 10 2 0 1
Neighs:    2.32513e+07 ave  2.3398e+07 max  2.3088e+07 min
Histogram: 3 2 9 6 13 14 6 9 5 5

Total # of neighbors = 1.6740963e+09
Ave neighs/atom = 20.949143
Neighbor list builds = 100
Dangerous builds not checked
Total wall time: 0:02:38
```

On [Intel Sapphire Rapids](https://en.wikipedia.org/wiki/Sapphire_Rapids) is is `0:01:40`.

[smarties](git@github.com:slitvinov/smarties)
```
git clone git@github.com:slitvinov/smarties
cd smarties
module load mpi/openmpi-aarch64
make -j `nproc --all`
make install
(cd apps/cart_pole_cpp && make)
(cd apps/cart_pole_f90 && make)
apps/cart_pole_cpp/cart_pole
apps/cart_pole_f90/main
```

[korali](https://github.com/slitvinov/dcomex-framework)
```
wget -q https://mirror.ibcp.fr/pub/gnu/gsl/gsl-latest.tar.gz
tar zxf gsl-latest.tar.gz
cd gsl-*/
./configure --prefix /scratch/slitvinov/.grace
make -j `nproc -all`
make install

wget -q https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz
tar zxf eigen-3.4.0.tar.gz
cd eigen-3.4.0
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/scratch/slitvinov/.grace
make install

python3 -m pip install pybind11
python3 -m pip install mpi4py
git clone git@github.com:slitvinov/dcomex-framework
cd dcomex-framework
MAKEFLAGS=-j`nproc --all` PKG_CONFIG_PATH=/scratch/slitvinov/.grace/lib/pkgconfig:/scratch/slitvinov/.grace/share/pkgconfig:$PKG_CONFIG_PATH make USER=1 'CXXFLAGS_PYBIND11 =-I$(HOME)/.local/lib/python3.9/site-packages/pybind11/include' lib lkorali
for i in src/follow.py src/graph.py src/kahan.py; do LD_LIBRARY_PATH=/scratch/slitvinov/.grace/lib python3 -m doctest $i ; done
```

[CUP3D](https://github.com/slitvinov/CUP3D.git)
```
git clone -q https://github.com/slitvinov/CUP3D.git
cd CUP3D
module load mpi/openmpi-aarch64
PKG_CONFIG_PATH=/scratch/slitvinov/.grace/lib/pkgconfig:/scratch/slitvinov/.grace/share/pkgconfig:$PKG_CONFIG_PATH make -j `nproc --all` MPICXX=mpicxx 'LDFLAGS = -lhdf5'
```

[cuda samples](https://github.com/NVIDIA/cuda-samples)

```
$ git clone https://github.com/NVIDIA/cuda-samples.git
$ cd cuda-samples/Samples/0_Introduction/vectorAdd
$ module purge
$ MODULEPATH=/scratch/`whoami`/.grace/modulefiles:$MODULEPATH module load nvhpc/24.5
$ nvcc -I../../../Common -arch=native vectorAdd.cu
$ ./a.out
[Vector addition of 50000 elements]
Copy input data from the host memory to the CUDA device
CUDA kernel launch with 196 blocks of 256 threads
Copy output data from the CUDA device to the host memory
Test PASSED
Done
$ cd ../../1_Utilities/deviceQuery
$ nvcc -I../../../Common -arch=native deviceQuery.cpp
$ ./a.out
./a.out Starting...

 CUDA Device Query (Runtime API) version (CUDART static linking)

Detected 1 CUDA Capable device(s)

Device 0: "NVIDIA GH200 480GB"
  CUDA Driver Version / Runtime Version          12.2 / 12.4
  CUDA Capability Major/Minor version number:    9.0
  Total amount of global memory:                 97280 MBytes (102005473280 bytes)
  (132) Multiprocessors, (128) CUDA Cores/MP:    16896 CUDA Cores
  GPU Max Clock rate:                            1980 MHz (1.98 GHz)
  Memory Clock rate:                             2619 Mhz
  Memory Bus Width:                              6144-bit
  L2 Cache Size:                                 62914560 bytes
  Maximum Texture Dimension Size (x,y,z)         1D=(131072), 2D=(131072, 65536), 3D=(16384, 16384, 16384)
  Maximum Layered 1D Texture Size, (num) layers  1D=(32768), 2048 layers
  Maximum Layered 2D Texture Size, (num) layers  2D=(32768, 32768), 2048 layers
  Total amount of constant memory:               65536 bytes
  Total amount of shared memory per block:       49152 bytes
  Total shared memory per multiprocessor:        233472 bytes
  Total number of registers available per block: 65536
  Warp size:                                     32
  Maximum number of threads per multiprocessor:  2048
  Maximum number of threads per block:           1024
  Max dimension size of a thread block (x,y,z): (1024, 1024, 64)
  Max dimension size of a grid size    (x,y,z): (2147483647, 65535, 65535)
  Maximum memory pitch:                          2147483647 bytes
  Texture alignment:                             512 bytes
  Concurrent copy and kernel execution:          Yes with 2 copy engine(s)
  Run time limit on kernels:                     No
  Integrated GPU sharing Host Memory:            No
  Support host page-locked memory mapping:       Yes
  Alignment requirement for Surfaces:            Yes
  Device has ECC support:                        Enabled
  Device supports Unified Addressing (UVA):      Yes
  Device supports Managed Memory:                Yes
  Device supports Compute Preemption:            Yes
  Supports Cooperative Kernel Launch:            Yes
  Supports MultiDevice Co-op Kernel Launch:      Yes
  Device PCI Domain ID / Bus ID / location ID:   9 / 1 / 0
  Compute Mode:
     < Default (multiple host threads can use ::cudaSetDevice() with device simultaneously) >

deviceQuery, CUDA Driver = CUDART, CUDA Driver Version = 12.2, CUDA Runtime Version = 12.4, NumDevs = 1
Result = PASS
$ nvcc -ICommon -arch=native bandwidthTest.cu
$ ./a.out
[CUDA Bandwidth Test] - Starting...
Running on...

 Device 0: NVIDIA GH200 480GB
 Quick Mode

 Host to Device Bandwidth, 1 Device(s)
 PINNED Memory Transfers
   Transfer Size (Bytes)	Bandwidth(GB/s)
   32000000			335.3

 Device to Host Bandwidth, 1 Device(s)
 PINNED Memory Transfers
   Transfer Size (Bytes)	Bandwidth(GB/s)
   32000000			291.6

 Device to Device Bandwidth, 1 Device(s)
 PINNED Memory Transfers
   Transfer Size (Bytes)	Bandwidth(GB/s)
   32000000			2313.7

Result = PASS

NOTE: The CUDA Samples are not meant for performance measurements. Results may vary when GPU Boost is enabled.
```

copy from the disc to GPU memory
```
$ cat memory.cu
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
  fprintf(stderr, "memory: start cudaMemcpy\n");
  if ((res = cudaMemcpy(device, host, size, cudaMemcpyHostToDevice)) !=
      cudaSuccess) {
    fprintf(stderr, "memory: cudaMalloc failed: '%s'\n",
	    cudaGetErrorString(res));
    exit(1);
  }
  fprintf(stderr, "memory: end cudaMemcpy\n");
  if (fclose(file) != 0) {
    fprintf(stderr, "memory: fclose failed\n");
    exit(1);
  }
  cudaFree(device);
}
$ module purge
$ MODULEPATH=/scratch/`whoami`/.grace/modulefiles:$MODULEPATH module load nvhpc/24.5
$ nvcc disc2gpu.cu -arch=native -Xcompiler -mcpu=native
$ for i in `seq 25 35`; do ./a.out $i 2>&1 | sh ./ts; echo; done
     0: size: 0.12GB
     3: memory: start cudaMemcpy
     3: memory: end cudaMemcpy

     0: size: 0.25GB
     3: memory: start cudaMemcpy
     3: memory: end cudaMemcpy

     0: size: 0.50GB
     3: memory: start cudaMemcpy
     3: memory: end cudaMemcpy

     0: size: 1.00GB
     3: memory: start cudaMemcpy
     3: memory: end cudaMemcpy

     0: size: 2.00GB
     3: memory: start cudaMemcpy
     3: memory: end cudaMemcpy

     0: size: 4.00GB
     2: memory: start cudaMemcpy
     3: memory: end cudaMemcpy

     0: size: 8.00GB
     3: memory: start cudaMemcpy
     4: memory: end cudaMemcpy

     0: size: 16.00GB
     3: memory: start cudaMemcpy
     5: memory: end cudaMemcpy

     0: size: 32.00GB
     3: memory: start cudaMemcpy
     8: memory: end cudaMemcpy

     0: size: 64.00GB
     3: memory: start cudaMemcpy
    12: memory: end cudaMemcpy

     0: size: 128.00GB
     3: memory: cudaMalloc failed: 'out of memory'
```

Builds libffi
```
https://github.com/libffi/libffi/releases/download/v3.4.5/libffi-3.4.5.tar.gz
tar zxf libffi-3.4.5.tar.gz
cd libffi-3.4.5
PATH=/scratch/.grace/bin:$PATH ./configure --prefix=/scratch/`whoami`/.grace/
PATH=/scratch/.grace/bin:$PATH make -j `nproc --all`
make install
```

Build python
```
wget -q https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tgz
tar zxf Python-3.11.9.tgz
cd Python-3.11.9
module purge
PATH=/scratch/.grace/bin:$PATH ./configure --enable-optimizations --prefix=/scratch/`whoami`/.grace/
PATH=/scratch/.grace/bin:$PATH make -j `nproc --all`
make install
```

Install jax
```
/scratch/.grace/bin/python3 -m pip install -U 'jax[cuda12]'
/scratch/.grace/bin/python3 -c 'import jax; print(jax.default_backend())'
gpu
```

Install pytorch
```
/scratch/.grace/bin/python3 -m pip install --pre torch --index-url https://download.pytorch.org/whl/nightly
/scratch/.grace/bin/python3 -c 'import torch; print(torch.cuda.is_available())'
True
```

Install tensorflow
```
MODULEPATH=/scratch/`whoami`/.grace/modulefiles:$MODULEPATH module load nvhpc/24.5
python3 -m pip install tf-nightly
python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
```

MPI
```
cat mpi_init.c
#include <mpi.h>
#include <stdio.h>
int main(int argc, char **argv) {
  MPI_Init(&argc, &argv);
  MPI_Finalize();
}
module purge
MODULEPATH=/scratch/`whoami`/.grace/modulefiles:$MODULEPATH module load nvhpc/24.5
mpicc mpi_init.c
mpiexec ./a.out
```


# Advanced SIMD (Neon)

```
$ cat neon.c
#include <stdio.h>
#include "arm_neon.h"
int main() {
  int i;
  uint8_t output[16], input[16] = { 0, 1, 2, 3, 4, 5, 6, 7,
				    8, 9, 10, 11, 12, 13, 14, 15};
  uint8x16_t data, three;
  data = vld1q_u8(input);
  three = vmovq_n_u8(3);
  data = vaddq_u8(data, three);
  vst1q_u8(output, data);
  for (i = 0; i < 16; i++)
    printf("%02d %02d\n", input[i], output[i]);
}
$ ~/.grace/bin/g++ -mcpu=native main.c
$ ./a.out
00 03
01 04
...
```

# Strange

```
Message from syslogd@holygpu7c1101 at Jul  9 10:18:37 ...
kernel:watchdog: BUG: soft lockup - CPU#39 stuck for 38s! [a.out:27493]
```
