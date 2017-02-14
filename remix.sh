#!/bin/bash

if [ -z $1 ]; then
  echo "usage: ./remix.sh <acc.txt>"
  exit 1
fi

filename=$1
while read -r -a line; do 
  acc=${line[1]}
  # remove leading zeroes
  num=$(( 10#${line[0]} ))
  echo $num
  if [ $acc -eq 0 ]; then
    from=$(( $num - 1 ))
    echo "Copying omeas $from to $num"
    cp onlinemeas.$( printf %06d $from ) onlinemeas.$( printf %06d $num )
  fi
done < $filename
