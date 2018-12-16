#!/bin/bash

if [ -z "${1}" -o -z "${2}" ]; then
  echo "usage: ./arsubmit.sh <job_script> <no> [<initial dependency>]"
  exit 1
fi

dependency=${3}
if [ -z "${dependency}" ]; then
  echo "Submitting array job ${1} with ${2} steps"
  dependency=$(sbatch --array=1-${2}%1 ${1} | awk '{print $4}')
else
  echo "Submitting array job ${1} with ${2} tasks, depending on ${dependency}"
  dependency=$(sbatch --array=1-${2}%1 --dependency=afterany:${dependency} ${1} | awk '{print $4}')
fi
echo ${dependency} > Z_last_job_id
