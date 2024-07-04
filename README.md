# Intro

<https://developer.nvidia.com/grace-cpu>
<https://nvidia.github.io/grace-cpu-benchmarking-guide>
<git@github.com:NVIDIA/grace-cpu-benchmarking-guide>

# Config

`.ssh/config` snippet

```
Host rc
     HostName login.rc.fas.harvard.edu
     User slitvinov

Host grace
     HostName holygpu7c1101
     User slitvinov
     ProxyJump rc
```

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
