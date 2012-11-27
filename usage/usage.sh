#!/bin/bash

if [[ -z ${1} || -z ${2} ]]; then
  echo "USAGE:"
  echo "  sh usage.sh DIRECTORY REFIND_FLAG"
  echo "  REFIND_FLAG indicates [0,1] whether find should be run on subdirectories to (re)create findlist_*.txt's"
  exit 0
fi

touch usage.txt

PWD=`pwd`

for i in `ls -1 ${PWD}`; do
  if [[ -d ${i} && ! ${i} = *..* && ! ${i} = *.* ]]; then
    if [[ ${2} -eq 1 ]]; then
      echo "Calling find for ${i}"
      find `pwd`/${i} -print > findlist_${i}.txt
    fi
    echo "Calling usage for ${i}"
    usage_out=`$HOME/code/utils/usage/usage findlist_${i}.txt`
    echo ${i} ${usage_out} >> usage.txt
  fi
done

