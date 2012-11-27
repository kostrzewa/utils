#!/bin/bash

if [[ -z ${1} ]]; then
  echo "USAGE:"
  echo "  sh usage.sh REFIND_FLAG"
  echo "  REFIND_FLAG indicates [0,1] whether find should be run on subdirectories to (re)create findlist_*.txt's"
  echo "  usage.sh will descend into all subdirectories of the present working directory"
  exit 0
fi

if [[ -e usage.txt ]]; then
  rm usage.txt
fi

# write a header
echo " dirname etmc(TB) nic(TB) other(TB) etmc(files) nic(files) other(files)" > usage.txt

PWD=`pwd`

for i in `ls -1 ${PWD}`; do
  if [[ -d ${i} && ! ${i} = *..* && ! ${i} = *.* ]]; then
    if [[ ${1} -eq 1 ]]; then
      echo "Calling find for ${i}"
      find ${PWD}/${i} -print > findlist_${i}.txt
    fi
    echo "Calling usage for ${i}"
    usage_out=`$HOME/code/utils/usage/usage findlist_${i}.txt`
    echo ${i} ${usage_out} >> usage.txt
  fi
done

