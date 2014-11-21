#!/bin/sh

versions="4D_MPI_hs 3D_MPI_hs 2D_MPI_hs 1D_MPI_hs 4D_hybrid_hs 3D_hybrid_hs 2D_hybrid_hs 1D_hybrid_hs openmp serial"
ADDON="icc_openmpi_lemon"

# gcc, icc
COMP="icc"
# openmpi, mvapich2
MPI="openmpi"

# where the sources are located
SDIR="${HOME}/code/tmLQCD.kost"
# where the build directories will be
BDIR="/lustre/fs17/group/etmc/kostrzew/build/pax/tmLQCD"
# the executables will be copied here after they are compiled
EDIR="/lustre/fs17/group/etmc/kostrzew/execs/pax/tmLQCD"
# these sub-directories will contain the various executables for hmc, inverter and benchmark
HMCDIR="${EDIR}/hmc_tm_${ADDON}"
INVDIR="${EDIR}/invert_${ADDON}"
BENCHDIR="${EDIR}/benchmark_${ADDON}"

# this will be modified further below
LEMONDIR="--with-lemondir=/afs/ifh.de/user/k/kostrzew/local64_pax/lemon"


commonflags="--enable-gaugecopy --disable-p4 --enable-alignment=32 --without-gprof --with-limedir=/afs/ifh.de/user/k/kostrzew/local64_pax/lime_icc"
mpiflags=""
openmpflags=""
hsflag=""
sseflags=""
cflags=""
ldflags=""
cc=""
ccpath=""
f77=""

if [[ ! -d ${HMCDIR} ]]; then
  mkdir -p ${HMCDIR}
fi

if [[ ! -d ${BENCHDIR} ]]; then
  mkdir -p ${BENCHDIR}
fi

if [[ ! -d ${INVDIR} ]]; then
  mkdir -p ${INVDIR}
fi

# make sure configure is up to date
(cd ${SDIR} && autoconf)

# configure compiler paths and flags
if [[ $COMP == "icc" ]]; then
  echo "using the Intel compiler 2013"
  sseflags="--disable-sse2 --disable-sse3"
  f77=ifort
  eval `modulecmd sh add intel.2013`
  if [[ $MPI == "mvapich2" ]]; then
    echo "linking against mvapich2"
    eval `modulecmd sh add mvapich2-x86_64-intel`
    ccpath="/usr/lib64/mvapich2-intel/bin/"
    LEMONDIR="${LEMONDIR}_icc_mvapich2"
  elif [[ $MPI == "openmpi" ]]; then
    echo "linking against openmpi"
    eval `modulecmd sh add openmpi-x86_64-intel`
    ccpath="/usr/lib64/openmpi-intel/bin/"
    LEMONDIR="${LEMONDIR}_icc_openmpi"
  else 
    echo "no MPI library specified in MPI variable, exiting (openmpi/mvapich2)"
    exit 1
  fi
  . /opt/intel/2013/bin/iccvars.sh intel64
elif [[ $COMP = "gcc" ]]; then
  echo "using the GCC compiler"
  intel=0
  f77=g77
  sseflags="--enable-sse2 --enable-sse3"
  if [[ $MPI == "mvapich2" ]]; then
    echo "linking against mvapich2"
    eval `modulecmd sh add mvapich2-x86_64`
    ccpath="/usr/lib64/mvapich2/bin/"
    LEMONDIR="${LEMONDIR}_gcc_mvapich2"
  elif [[ $MPI == "openmpi" ]]; then
    echo "linking against openmpi"
    eval `modulecmd sh add openmpi-x86_64`
    ccpath="/usr/lib64/openmpi/bin/"
    LEMONDIR="${LEMONDIR}_gcc_openmpi"
  else
    echo "no MPI library specified in MPI variable, exiting (openmpi/mvapich2)"
  fi
else
  echo "no compiler specified in COMP, exiting! (gcc/icc)"
  exit 2
fi

# do the compilations for the different versions
for i in ${versions}; do
  cc=""
  ldflags=""
  if [[ $COMP = "icc" ]]; then
    cflags="-std=c99 -march=corei7 -O3 -mkl"
  else
    cflags="-std=c99 -O3 -mtune=core2"
  fi

  mpiflags=""
  openmpflags=""
  hsflag=""

  builddir="${BDIR}/${ADDON}/${i}"

  if [[ ! -d ${builddir} ]]; then
    mkdir -p ${builddir}
  fi

  echo
  echo "build directory is ${builddir}"
  cd ${builddir}

  # to clean out, drop out of the loop
  if [[ ${1} = "clean" ]]; then
    make -j6 clean
    continue
  fi
 
  if [[ ${i} = *hs ]]; then
    hsflag="--enable-halfspinor"
  else
    hsflag="--disable-halfspinor"
  fi
 
  if [[ ${i} = *MPI* || ${i} = *hybrid* ]]; then
    mpiflags="${mpiflags} ${LEMONDIR} --enable-mpi --with-mpidimension="
    cc="${ccpath}mpicc"
  else
    mpiflags="${mpiflags} --disable-mpi"
    cc="$COMP"
  fi

  if [[ ${i} = *hybrid* || ${i} = *openmp* ]]; then
    openmpflags="${openmpflags} --enable-omp"
    if [[ $COMP = "icc" ]]; then
      cflags="${cflags}"
      ldflags="${ldflags}"
      # MKL static threaded
      #commonflags="${commonflags} --with-lapack='-Wl, --start-group /opt/intel/2013/mkl/lib/intel64/libmkl_blas95_lp64.a /opt/intel/2013/mkl/lib/intel64/libmkl_intel_lp64.a /opt/intel/2013/mkl/lib/intel64/libmkl_core.a /opt/intel/2013/mkl/lib/intel64/libmkl_intel_thread.a -Wl, --end-group'"
      # MKL runtime 
      #commonflags="${commonflags} --with-lapack='-L/opt/intel/2013/mkl/lib/intel64 -lmkl_rt'"
      # MKL dynamic threaded
      commonflags="${commonflags} --with-lapack='-L/opt/intel/2013/composer_xe_2013_sp1.3.174/mkl/lib/intel64 -lmkl_intel_lp64 -lmkl_core -lmkl_intel_thread'"
    else
      cflags="${cflags} -fopenmp"
      ldflags="${ldflags} -fopenmp"
    fi
  else
    openmpflags="${openmpflags} --disable-omp"
    # MKL static, sequential
    #commonflags="${commonflags} --with-lapack='-Wl, --begin-group /opt/intel/2013/mkl/lib/intel64/libmkl_blas95_lp64.a /opt/intel/2013/mkl/lib/intel64/libmkl_intel_lp64.a /opt/intel/2013/mkl/lib/intel64/libmkl_core.a /opt/intel/2013/mkl/lib/intel64/libmkl_sequential.a -Wl, --end-group '"
    # MKL run-time selection
    #commonflags="${commonflags} --with-lapack='-L/opt/intel/2013/mkl/lib/intel64 -lmkl_rt'"
    # MKL dynamic, sequential
    commonflags="${commonflags} --with-lapack='-L/opt/intel/2013/composer_xe_2013_sp1.3.174/mkl/lib/intel64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential'"
  fi

  case ${i} in
    4D*)
      mpiflags="${mpiflags}4"
    ;;
    3D*)
      mpiflags="${mpiflags}3"
    ;;
    2D*)
      mpiflags="${mpiflags}2"
    ;;
    1D*)
      mpiflags="${mpiflags}1"
    ;;
  esac
  
  echo "executing configure for $i"
  configurecommand="CFLAGS=\"${cflags}\" LDFLAGS=\"${ldflags}\" CC=${cc} F77=${f77} ${SDIR}/configure ${commonflags} ${mpiflags} ${openmpflags} ${hsflag} ${sseflags}"
  echo ${configurecommand}
  eval ${configurecommand}

  CONF_ESTAT=$?

  echo "beginning compilation for $i"
  make -j9

  COMP_ESTAT=$?

  cp hmc_tm ${HMCDIR}/${i} &&
  cp benchmark ${BENCHDIR}/${i} &&
  cp invert ${INVDIR}/${i}

  CP_ESTAT=$?

  if [ $CP_ESTAT -ne 0 -o $COMP_ESTAT -ne 0 -o $CONF_ESTAT -ne 0  ]; then
    echo "non-zero exit status somewhere while compiling ${i}, exiting!"
    echo -e " CONF_ESTAT = $CONF_ESTAT \n COMP_ESTAT = $COMP_ESTAT \n CP_ESTAT = $CP_ESTAT"
    exit 129
  fi
done
