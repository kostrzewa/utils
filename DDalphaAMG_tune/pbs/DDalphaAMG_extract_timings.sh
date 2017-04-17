if [ -z "$1" -o -z "$2" ]; then
  echo "usage: ./DDalphaAMG_extract_timings.sh <directory> <nmeas>"
  exit 1
fi

nds=(16)
lvls=(2 3)
iters=(3 4 5)
mucoarse=(1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 7.0 8.0 9.0 10.0 11.0 12.0)
nvecs=(8 12 16 20 24 28 32)

# set to one to terminate after the first iteration
test_run=0

base_ofile=timings.dat
base_mfile=missing.dat

dt=$(date)

directory=$1
nmeas=$2

for nd in ${nds[@]}; do
  ofile=nds${nd}_${base_ofile}
  mfile=nds${nd}_${base_mfile}
  echo "# $dt" > $ofile
  echo "nds setupiter lvl nvec mucoarse setuptime setupcgrid solvetime solvecgrid solvefiter solveciter" >> $ofile
  echo "# $dt" > $mfile
  
  for iter in ${iters[@]}; do
    for lvl in ${lvls[@]}; do
      for nvec in ${nvecs[@]}; do
        for muc in ${mucoarse[@]}; do
          job=nds${nd}_iters${iter}_nlevel${lvl}_nvec${nvec}_mucoarse${muc}
          wdir=$(pwd)/${directory}/${job}
          sfile=$wdir/outputs/${job}.out
          if [ ! -f $sfile ]; then
            echo skipping $wdir
            echo $wdir >> $mfile
            continue
          else
            echo Processing $sfile
          fi
          
          setuptime=( $(grep "setup ran" $sfile | awk '{print $5}') )
          if [ -z "${setuptime}" ]; then
            echo skipping $wdir
            echo $wdir >> $mfile
            continue
          fi
          echo setuptime=${setuptime}

          setupcgrid=( $(grep "setup ran" $sfile | awk '{print $7}' | sed 's/(//g') )
          if [ -z "${setupcgrid}" ]; then
            echo skipping $wdir
            echo $wdir >> $mfile
            continue
          fi
          echo setupcgrid=${setupcgrid}
          
          temp=( $(grep "Solving time" $sfile | awk '{print $3}') )
          if [ -z "${temp}" ]; then
            echo skipping $wdir
            echo $wdir >> $mfile
            continue
          fi
          echo solvetime: temp=\( ${temp[@]} \)
          solvetime=0
          for num in ${temp[@]}; do
            solvetime=$( echo "scale=2; $solvetime + $num" | bc -l )
          done
          solvetime=$( echo "scale=2; $solvetime / $nmeas" | bc -l )
          echo solvetime=${solvetime}
  
          temp=( $(grep "Solving time" $sfile | awk '{print $5}' | sed 's/(//g') )
          if [ -z "${temp}" ]; then
            echo skipping $wdir
            echo $wdir >> $mfile
            continue
          fi
          echo solvecgrid: temp=\( ${temp[@]} \)
          solvecgrid=0
          for num in ${temp[@]}; do
            solvecgrid=$( echo "scale=2; $solvecgrid + $num" | bc -l )
          done
          solvecgrid=$( echo "scale=2; $solvecgrid / $nmeas" | bc -l )
          echo solvecgrid=${solvecgrid}

          temp=( $(grep "Total iterations on fine grid" $sfile | awk '{print $6}') )
          if [ -z "${temp}" ]; then
            echo skipping $wdir
            echo $wdir >> $mfile
            continue
          fi
          echo solvefiter: temp=\( ${temp[@]} \)
          solvefiter=0
          for num in ${temp[@]}; do
            solvefiter=$( echo "scale=2; $solvefiter + $num" | bc -l )
          done
          solvefiter=$( echo "scale=2; $solvefiter / $nmeas" | bc -l )
          echo solvefiter=${solvefiter}
          
          temp=( $(grep "Total iterations on coarse grids" $sfile | awk '{print $6}') )
          if [ -z "${temp}" ]; then
            echo skipping $wdir
            echo $wdir >> $mfile
            continue
          fi
          echo solveciter: temp=\( ${temp[@]} \)
          solveciter=0
          for num in ${temp[@]}; do
            solveciter=$( echo "scale=2; $solveciter + $num" | bc -l )
          done
          solveciter=$( echo "scale=2; $solveciter / $nmeas" | bc -l )
          echo solveciter=${solveciter}
          
          output=$( echo "$nd $iter $lvl $nvec $muc $setuptime $setupcgrid $solvetime $solvecgrid $solvefiter $solveciter" )
          echo $output
          echo $output >> $ofile
  
          if [ $test_run -eq 1 ]; then
            exit 0
          fi
        done
      done
    done
  done
done
