nodes=(16)
levels=(2 3)
iters=(3 4 5)
mucoarse=(1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 7.0 8.0 9.0 10.0 11.0 12.0)
nvecs=(8 12 16 20 24 28 32)
conf=/lustre/fs17/group/etmc/kostrzew/runs/nf211/iwa_b1.726-L24T48-csw1.74-k0.1400645-mul0.004-musigma0.1408-mudelta0.1521/conf.0054

jfile=$(pwd)/job.DDalphaAMG.scan.sh

cp job.DDalphaAMG.scan.header.template ${jfile}

for nds in ${nodes[@]}; do
  mgbt=3
  for iter in ${iters[@]}; do
    for lvl in ${levels[@]}; do
      for nvec in ${nvecs[@]}; do
        for muc in ${mucoarse[@]}; do
          wdir=$(pwd)/results/nds${nds}_iters${iter}_nlevel${lvl}_nvec${nvec}_mucoarse${muc}
          if [ ! -d ${wdir} ]; then
            mkdir -p ${wdir}
            mkdir -p ${wdir}/outputs
          fi
          ln -s ${conf} ${wdir}
        
          ifile=${wdir}/invert.input
          cp invert.input.template ${ifile}
          sed -i "s/MUCOARSE/${muc}/g" ${ifile}
          sed -i "s/NVEC/${nvec}/g" ${ifile}
          sed -i "s/NLEVEL/${lvl}/g" ${ifile}
          sed -i "s/ITERS/${iter}/g" ${ifile}
          sed -i "s/MGBT/${mgbt}/g" ${ifile}
        
          jtemp=${wdir}/job.nds${nds}_iters${iter}_nlevel${lvl}_nvec${nvec}_mucoarse${muc}.sh
          cp job.DDalphaAMG.scan.template ${jtemp}
          sed -i "s@WDIR@${wdir}@g" ${jtemp}
          sed -i "s/MUCOARSE/${muc}/g" ${jtemp}
          sed -i "s/NVEC/${nvec}/g" ${jtemp}
          sed -i "s/NLEVEL/${lvl}/g" ${jtemp}
          sed -i "s/ITERS/${iter}/g" ${jtemp}
          sed -i "s/NODES/${nds}/g" ${jtemp}
          cat ${jtemp} >> ${jfile}
        done
      done
    done
  done
done
