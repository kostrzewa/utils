#!/bin/bash
# script to parse the output files from runs of the tmLQCD benchmark
# TODO: add support for benchmarks without comms (parse Mflops only)

# input parameters
Ls="32 48"
pars="hyb hyb_ov mpi"
N_nds="32 64 96 128"
N_threads="48 24 12 6 4 3 2 1"


indir="."
if [ -n "$1" ]; then
  indir="$1"
fi

outfile="scaling_benchmark.dat"
if [ -n "$2" ]; then
  outfile=$2
fi

echo "L par nds np nthr nt nx ny nz comm mflops" > $outfile

for par in $pars; do
  for nds in $N_nds; do

    threads=$N_threads
    if [ "$par" == "mpi" ]; then
      threads=1
    fi
  
    for L in $Ls; do
      if [ $nds -eq 96 -a $L -eq 32 ]; then
        continue
      fi

      nrxprocs=4
      if [ $nds -eq 128 ]; then
        nrxprocs=8
      elif [ $nds -eq 96 ]; then
        nrxprocs=6
      fi

      for nt in $threads; do
        nryprocs=2
        ppn=$(( 48 / nt ))
        if [ $L -eq 32 -a $(( nt % 3 )) -ne 0 ]; then
          ppn=$(( 32 / nt ))
        fi
        np=$(( nds * ppn ))
        nrzprocs=$(( ppn / 2 ))

        if [ $nt -eq 48 ]; then
          nrzprocs=1
          nryprocs=1
        fi

        nrtprocs=$(( np / ( nrzprocs * nryprocs * nrxprocs ) ))

        infile=${indir}/L${L}_nds$(printf %03d $nds)_np$(printf %04d $np)_nthr$(printf %02d $nt)_ppn$(printf %02d $ppn)_nx$(printf %02d $nrxprocs)_ny$(printf %02d $nryprocs)_nz$(printf %02d $nrzprocs)_par${par}.out

        for comm in 1 0; do
          cmstext="switched on"
          if [ $comm -eq 0 ]; then
            cmstext="switched off"
          fi
          mflops=$(grep -A2 "$cmstext" $infile | grep Mflops | awk '{print $1}')
          echo ${L} ${par} ${nds} ${np} ${nt} ${nrtprocs} ${nrxprocs} ${nryprocs} ${nrzprocs} ${comm} ${mflops} >> $outfile
        done
         
      done
    done
  done
done

echo >> $outfile




