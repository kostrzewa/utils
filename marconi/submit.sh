#!/bin/bash

if [ -z "${1}" -o -z "${2}" ]; then
  echo "usage: ./submit.sh <job_script> <no> [<initial dependency>]"
  exit 1
fi

dependency=${3}
for i in $(seq 1 ${2} ); do
  if [ -z "${dependency}" ]; then
    echo "Submitting job ${i} out of ${2}"
    dependency=$(sbatch ${1} | awk '{print $4}')
  else
    echo "Submitting job ${i} out of ${2}, depending on ${dependency}"
    dependency=$(sbatch --dependency=afterany:${dependency} ${1} | awk '{print $4}')
  fi
  echo ${dependency} > Z_last_job_id
done
