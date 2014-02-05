# This file is part of the "usage" utility for analysing disk usage
# on a per directory level and attributing it to a unix group 

#   Copyright (C) 2012  Bartosz Kostrzewa

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#!/bin/bash

if [[ ${1} = *-help* || -z ${1} ]]; then
  echo "USAGE:"
  echo "  sh usage.sh directory [REFIND_FLAG]"
  echo "  REFIND_FLAG indicates [1] whether find should be run on subdirectories to recreate findlist_*.txt's"
  echo "  all subdirectorie of the specified directory are scanned"
  echo "  if findlist_\$subdirectory.txt cannot be found (where subdirectory is the name of a given subdirectory"
  echo "  inside the directory) find will be called on that subdirectory"
  echo "     Copyright (C) 2012 Bartosz Kostrzewa "
  exit 0
fi

if [[ ${1} = "." ]]; then
  WD=`pwd`
elif [[ ${1} = ".." ]]; then
  WD="`pwd`/.."
else
  WD=${1}
fi

WD_name=`echo ${WD} | sed 's/\//_/g'`

# call kinit to make sure we have an AFS token
kinit -r 604800

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
      find ${WD}/${i} -type f -fprint findlist_${WD_name}_${i}.txt
    fi
    echo "Calling usage for ${i}"
    usage_out=`$HOME/code/utils/usage/usage findlist_${WD_name}_${i}.txt`
    echo ${WD}/${i} ${usage_out} >> usage_${WD_name}.txt
  fi
  # refresh our AFS token
  kinit -R
done

# finally, we also call it on ${WD} itself
# here we limit the depth of find because we don't want recursion!!
if [[ -d ${WD} ]]; then
  if [[ ! -e findlist_${WD_name}.txt || ${2} -eq 1 ]]; then
    echo "Calling ls for ${WD}"
    find ${WD} -maxdepth 1 -type f -fprint findlist_${WD_name}.txt
  fi
  echo "Calling usage for ${WD}"
  usage_out=`$HOME/code/utils/usage/usage findlist_${WD_name}.txt`
  echo ${WD} ${usage_out} >> usage_${WD_name}.txt
fi
