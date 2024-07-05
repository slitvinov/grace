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

aphros