#!/bin/bash

if [[ ${1} = *-help* || -z ${1} ]]; then
  echo "USAGE:"
  echo "  sh usage.sh directory [REFIND_FLAG]"
  echo "  REFIND_FLAG indicates [1] whether find should be run on subdirectories to recreate findlist_*.txt's"
  echo "  usage.sh will descend into all subdirectories of the present working directory if no directory is specified"
  echo "  otherwise all subdirectorie of the specified directory are scanned"
  echo "  if findlist_\$subdirectory.txt cannot be found (where subdirectory is the name of a given subdirectory"
  echo "  inside the directory, find will be called on that subdirectory"
  exit 0
fi

if [[ ${1} = "." ]]; then
  WD=`pwd`
elif [[ ${1} = ".." ]]; then
  echo "  usage.sh cannot be called with "${1}" as an argument!"
  exit 1
else
  WD=${1}
fi

WD_name=`echo ${WD} | sed 's/\//_/g'`

# write a header
echo " dirname etmc(TB) nic(TB) other(TB) etmc(files) nic(files) other(files)" > usage_${WD_name}.txt

# the usage binary reads through a list of files produced by find
# for each *regular file* it checks the gid and file size and attributes
# it accordingly

# we call it on each subdirectory of ${WD}

# if the list of files does not exist, we call find to create it
for i in `ls -1 ${WD}`; do
  fullpath=${WD}/${i}
  if [[ -d ${fullpath} ]]; then 
    if [[ ! -e findlist_${WD_name}_${i}.txt || ${2} -eq 1 ]]; then
      echo "Calling find for ${i}"
      find ${WD}/${i} > findlist_${WD_name}_${i}.txt
    fi
    echo "Calling usage for ${i}"
    usage_out=`$HOME/code/utils/usage/usage findlist_${WD_name}_${i}.txt`
    echo ${WD}/${i} ${usage_out} >> usage_${WD_name}.txt
  fi
done

# finally, we also call it on ${WD} itself
# here we limit the depth of find because we don't want recursion!!
if [[ -d ${WD} ]]; then
  if [[ ! -e findlist_${WD_name}.txt || ${2} -eq 1 ]]; then
    echo "Calling ls for ${WD}"
    find ${WD} -maxdepth 1 > findlist_${WD_name}.txt
  fi
  echo "Calling usage for ${WD}"
  usage_out=`$HOME/code/utils/usage/usage findlist_${WD_name}.txt`
  echo ${WD} ${usage_out} >> usage_${WD_name}.txt
fi
