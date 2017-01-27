#!/bin/bash

if [ -z $1 ]; then
  echo "usage: ./extract_timings.sh <stdout.log>"
  exit 1
fi

outfile=$1

# acceptance step
echo "monomial time" > accept_time.dat
grep Time $outfile | grep acc | awk '{print $4 " " $8}' >> accept_time.dat 

# heatbath step
echo "monomial time" > heatbath_time.dat
grep Time $outfile | grep heatbath | awk '{print $4 " " $7}' >> heatbath_time.dat 

# derivatives
echo "monomial time" > derivative_time.dat
grep Time $outfile | grep derivative | awk '{print $4 " " $7}' >> derivative_time.dat 

# eigenvalues
echo "monomial time" > eigenvalues_time.dat
grep eigenvalue $outfile | grep computation | awk '{print $2 " " $7}' | sed "s/://g" >> eigenvalues_time.dat

# ddalphamg setup
echo "monomial time" > ddalphaamg_setup_time.dat
grep "setup ran" $outfile | awk '{print $1 " " $5}' >> ddalphaamg_setup_time.dat
grep "next coarser" $outfile | awk '{print "DDalphaAMG " $11}' >> ddalphaamg_setup_time.dat

