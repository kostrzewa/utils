#!/bin/sh

if test ${1} = ""; then
  echo "usage:"
  echo "tar_lustre.sh <dirname>"
  echo "   where dirname is the name of the directory to tar"
  exit 1
fi

date
echo "Calling find on ${1}"
find ${1} -type f -fprint ${1}_findlist.txt
echo "Tarring ${1}"
tar -cf ${1}.tar `head -n 1 ${1}_findlist.txt`
tar --delete -f ${1}.tar `head -n 1 ${1}_findlist.txt`
cat ${1}_findlist.txt | xargs tar -r -f ${1}.tar
date
