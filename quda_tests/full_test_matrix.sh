mkdir -p results
for tune in 1 0; do
  mu=""
  csw=""
  for dslash in twisted-clover twisted-mass wilson clover; do
    if [ "${dslash}" = "twisted-mass" -o "${dslash}" = "twisted-clover" ]; then
      mu="--mu 0.001"
    fi
    if [ "${dslash}" = "clover" -o "${dslash}" = "twisted-clover" ]; then
      csw="--clover-coeff 1.0"
    fi
    for sloppy in half single double; do
      for recon in 8 12 18; do
        for L in 16 24 32 48 64; do
          for np in 1 2 4 8; do
            # 64c128 does not fit on one or two cards
            if [ ${L} -eq 64 -a \( ${np} -eq 2 -o ${np} -eq 1 \) ]; then
               continue
            fi 
            for p2p in 0 1; do
              for bindflag in 0 1; do
                echo p2p=${p2p} tune=$tune L=$L np=$np bind=$bindflag sloppy=${sloppy} recon=${recon} dslash=${dslash}
                bindarg="--bind-to-socket"
                if [ $bindflag -eq 0 ]; then
                  bindarg=""
                fi
                output=/dev/null
                if [ $tune -eq 0 ]; then
                  output="results/L${L}_np${np}_dslash-${dslash}_recon${recon}_sloppy-${sloppy}_p2p${p2p}_bind${bindflag}.log"
                fi
                QUDA_ENABLE_P2P=${p2p} QUDA_RESOURCE_PATH=$HOME/quda_tune mpirun ${bindarg} -np ${np} ./invert_test --Lsdim 1 --prec double --prec-sloppy ${sloppy} --gridsize 1 1 1 ${np} --dim $L $L $L $(( 2 * ${L} / ${np} )) --dslash-type ${dslash} --recon ${recon} --recon-sloppy ${recon} --recon-precondition ${recon} ${mu} ${csw} --mass -0.5 | tee ${output}
              done
            done
          done
        done
      done
    done
  done 
done 
