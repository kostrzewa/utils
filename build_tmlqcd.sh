#!/bin/sh

versions="4D_MPI_hs 3D_MPI_hs 2D_MPI_hs 1D_MPI_hs 4D_hybrid_hs 3D_hybrid_hs 2D_hybrid_hs 1D_hybrid_hs openmp serial"
ADDON="openmpi_oldlemon_gcc_5.2.0"

SDIR="${HOME}/code/tmLQCD.kost"
BDIR="/lustre/fs4/group/etmc/kostrzew/tmLQCD_builds/auto"
EDIR="${HOME}/tmLQCD/execs/"
HMCDIR="${EDIR}/hmc_tm_${ADDON}"
INVDIR="${EDIR}/invert_${ADDON}"
BENCHDIR="${EDIR}/benchmark_${ADDON}"

commonflags="--enable-gaugecopy --disable-p4 --enable-alignment=32 --without-gprof --with-lapack=-llapack --with-limedir=/afs/ifh.de/user/k/kostrzew/local64"
mpiflags=""
openmpflags=""
hsflag=""
sseflags=""
cflags=""
ldflags=""
cc=""
ccpath=""
intel=1

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

if [[ $ADDON == *icc* ]]; then
  echo "using the Intel compiler 2013"
  intel=1
  sseflags="--disable-sse2 --disable-sse3"
  eval `modulecmd sh add intel.2013`
  if [[ $ADDON == *mvapich* ]]; then
    echo "linking against mvapich2"
    eval `modulecmd sh add mvapich2-x86_64-intel`
    ccpath="/usr/lib64/mvapich2-intel/bin/"
    LEMONDIR="--with-lemondir=/afs/ifh.de/user/k/kostrzew/code/lemon/install_icc_mvapich2"
  elif [[ $ADDON == *openmpi* ]]; then
    echo "linking against openmpi"
    eval `modulecmd sh add openmpi-x86_64-intel`
    ccpath="/usr/lib64/openmpi-intel/bin/"
    LEMONDIR="--with-lemondir=/afs/ifh.de/user/k/kostrzew/code/lemon/install_icc_openmpi"
  else 
    echo "no MPI library specified in ADDON, exiting (openmpi/mvapich2)"
    exit 1
  fi
  source /usr/local/bin/intel-setup2013.sh intel64
elif [[ $ADDON = *gcc* ]]; then
  echo "using the GCC compiler"
  intel=0
  sseflags="--enable-sse2 --enable-sse3"
  if [[ $ADDON == *mvapich* ]]; then
    echo "linking against mvapich2"
    eval `modulecmd sh add mvapich2-x86_64`
    ccpath="/usr/lib64/mvapich2/bin/"
    LEMONDIR="--with-lemondir=/afs/ifh.de/user/k/kostrzew/code/lemon/install_gcc_mvapich2"
  elif [[ $ADDON == *openmpi* ]]; then
    echo "linking against openmpi"
    eval `modulecmd sh add openmpi-x86_64`
    ccpath="/usr/lib64/openmpi/bin/"
    LEMONDIR="--with-lemondir=/afs/ifh.de/user/k/kostrzew/code/lemon/install_gcc_openmpi"
  else
    echo "no MPI library specified in ADDON, exiting (openmpi/mvapich2)"
  fi
else
  echo "no compiler specified in ADDON, exiting! (gcc/icc)"
  exit 2
fi

for i in ${versions}; do
  cc=""
  ldflags=""
  if [ $intel -eq 1 ]; then
    cflags="-std=c99 -axSSE4.2 -O3"
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
    if [ $intel -eq 1 ]; then
      cc="icc"
    else
      cc="gcc"
    fi
  fi

  if [[ ${i} = *hybrid* || ${i} = *openmp* ]]; then
    openmpflags="${openmpflags} --enable-omp"
    if [ $intel -eq 1 ]; then
      cflags="${cflags} -openmp"
      ldflags="${ldflags} -openmp"
    else
      cflags="${cflags} -fopenmp"
      ldflags="${ldflags} -fopenmp"
    fi
  else
    openmpflags="${openmpflags} --disable-omp"
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
  
  echo
  echo "executing configure for $i" &&
  CFLAGS="${cflags}" LDFLAGS="${ldflags}" CC="${cc}" ${SDIR}/configure ${commonflags} ${mpiflags} ${openmpflags} ${hsflag} ${sseflags} &&
  echo "beginning compilation for $i" &&
  make -j9 &&
  cp hmc_tm ${HMCDIR}/${i} &&
  cp benchmark ${BENCHDIR}/${i} &&
  cp invert ${INVDIR}/${i}

  if [ $? -ne 0 ]; then
    echo "non-zero exit status somewhere, exiting!"
    exit $?
  fi
done
