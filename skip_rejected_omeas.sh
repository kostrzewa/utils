#!/bin/bash

filename=acc.txt

awk '{print $1 " " $(NF-2)}' output.data > acc.txt

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
