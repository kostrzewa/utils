ens="cA211a.30.32
cA211b.30.32
cA211a.40.24
cA211b.40.24
cA211a.53.24
cA211b.53.24"

targetstat=150
bunchsize=30
debug="true"

remotepath=/qbig2work/bartek/gauges/nf211
remotemachine=qbig2
temppath=$WORK/qbig_staging

for i in $ens; do
  temppathens=${temppath}/${i}
  mkdir -p ${temppathens}
  remotepathens=${remotepath}/${i}
  #ssh qbig2 "mkdir -p ${remotepathens}"

  path=$ARCH/runs/nf211/iwa_b1.726_csw1.74/${i}
  ls -1 ${path} | grep -E "conf.[0-9]+" > ${i}.confs.txt
  lc=$(wc ${i}.confs.txt | awk '{print $1}')
  step=$(( $lc / $targetstat ))
  if [ ! -z "${debug}" ]; then
    echo lc=$lc
    echo step=$step
  fi

  sparselist=( $(awk "(NR-1) % ${step} == 0" ${i}.confs.txt) )

  # for the second replica, we have to skip the first line to get the correct Markov chain
  idx_start=0
  if [ ! -z "$(echo $i | grep 'b')" ]; then
    idx_start=1
  fi
  idx_end=$idx_start

  # split transfers into bunches to limit number of rsync 
  while [ $idx_end -lt $(( ${#sparselist[@]}-1 )) ]; do
    idx_end=$(( $idx_end + $bunchsize ))
    if [ $idx_end -gt $(( ${#sparselist[@]}-1 )) ]; then
      idx_end=$(( ${#sparselist[@]}-1 ))
    fi
    echo idx_end=$idx_end

    localfiles=""
    for i in $(seq $idx_start $idx_end ); do
      localfiles="${localfiles} ${path}/${sparselist[${i}]}" || break
      #rsync -av --progress ${path}/${sparselist[${i}]} ${temppathens}
      #rsync -av --progress ${temppathens}/${sparselist[${i}]} ${remotemachine}:${remotepathens} || break
    done || break
    echo localfiles=$localfiles
    echo target=$temppathens
    rsync -av --progress ${localfiles} ${temppathens} || break
    idx_start=$(( $idx_end + 1 ))
    echo idx_start=$idx_start
  done || break
done

