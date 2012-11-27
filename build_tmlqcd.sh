versions="3D_hybrid_hs 1D_MPI_hs 2D_MPI_hs 3D_MPI_hs 4D_MPI_hs 1D_hybrid_hs 2D_hybrid_hs 4D_hybrid_hs openmp serial"
commonflags="--enable-gaugecopy --disable-p4 --with-alignment=16 --without-gprof --with-lapack=-llapack --with-limedir=/afs/ifh.de/user/k/kostrzew/local64"
mpiflags=""
openmpflags=""
hsflag=""
sseflags="--disable-sse2 --disable-ss3"

cflags="-std=c99 -axSSE4.2 -O3 -c99"
ldflags=""
cc="icc"

ADDON="RAN"

SDIR="${HOME}/code/tmLQCD.kost"
BDIR="/lustre/fs4/group/etmc/kostrzew/tmLQCD_builds/auto"
EDIR="${HOME}/tmLQCD/execs/"
HMCDIR="${EDIR}/hmc_tm_${ADDON}"
INVDIR="${EDIR}/invert_${ADDON}"
BENCHDIR="${EDIR}/benchmark_${ADDON}"

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

eval "`/etc/site/ini.pl -b ic110 openmpi_intel`"

for i in ${versions}; do
  cc=""
  ldflags=""
  cflags="-std=c99 -axSSE4.2 -O3"
  mpiflags=""
  openmpflags=""
  hsflag=""

  builddir=${BDIR}"/${i}"

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
    mpiflags="${mpiflags} --enable-mpi --with-mpidimension="
    cc="mpicc"
  else
    mpiflags="${mpiflags} --disable-mpi"
    cc="icc"
  fi

  if [[ ${i} = *hybrid* || ${i} = *openmp* ]]; then
    openmpflags="${openmpflags} --enable-omp"
    cflags="${cflags} -openmp"
    ldflags="${ldflags} -openmp"
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

  CFLAGS="${cflags}" LDFLAGS="${ldflags}" CC="${cc}" ${SDIR}/configure ${commonflags} ${mpiflags} ${openmpflags} ${hsflag} ${sseflags} &&
  make -j12 &&
  cp hmc_tm ${HMCDIR}/${i} &&
  cp benchmark ${BENCHDIR}/${i} &&
  cp invert ${INVDIR}/${i}
done
