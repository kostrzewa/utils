#!/bin/sh

if [[ ${1} = "" || ${2} = "" ]]; then
  echo "usage:"
  echo "archive.sh source desitination"
  exit 1
fi

echo -n "Starting transfer of ${1} on "
date
dccp -C 3600 ${1} ${2}
RETVAL=$?
if test $RETVAL -ne 0; then
  echo "File transfer or checksum computation of ${1} failed!"
fi
exit ${RETVAL}
