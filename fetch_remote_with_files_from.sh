#!/bin/bash
REMOTE=qbig
RPATH=/hiskp4/bartek/tests/hmc_integration/sandybridge/hmc-tmcloverdetratio

ssh ${REMOTE} find ${RPATH} -name "[o,h,m,r]*[0-9,a]" -printf '%f\\n' > omeas_files.txt

rsync -av --progress --files-from=omeas_files.txt ${REMOTE}:${RPATH} .
rsync -av --progress "${REMOTE}:${RPATH}/gradflow*[0-9]" .
rsync -av --progress "${REMOTE}:${RPATH}/*.input" .

