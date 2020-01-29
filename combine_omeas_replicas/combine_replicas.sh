#!/bin/bash

prefix=cB211
suffix=25.32

rep_a=${prefix}a.${suffix}
rep_b=${prefix}b.${suffix}

### FIRST THE GRADIENT FLOW
step=4
files=( $( ls ../${rep_b}/gradflow.?????? | sort --reverse ) $( ls ../${rep_a}/gradflow.?????? ) )
ctr=0
echo "src_file target_idx" > filelist_gradflow.txt
for path in ${files[@]}; do
  echo $path $ctr >> filelist_gradflow.txt
  ctr=$(( ${ctr} + ${step} ))
done
Rscript relabel_gradflow.R filelist_gradflow.txt

### NOW THE ONLINE MEASUREMENTS 
step=1
files=( $( ls ../${rep_b}/onlinemeas.?????? | sort --reverse ) $( ls ../${rep_a}/onlinemeas.?????? ) )
ctr=0
for path in ${files[@]}; do
  cp $path onlinemeas.$(printf %06d $ctr)
  ctr=$(( ${ctr} + ${step} ))
done

### FINALLY TAKE CARE OF OUTPUT.DATA
Rscript combine_output_data.R ${rep_b} ${rep_a}

