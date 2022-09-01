inputfile=${pmsignature_output_dir}/mutation.cut.txt
set +e
singularity exec $genomon_r_img bash -c "R --vanilla --slave --args ${inputfile}\
          ${pmsignature_output_dir}/${pmsignature_type}.${sig_num}.Rdata \
          $sig_num \
          ${trdirflag} \
          ${trialnum} \
          ${bgflag} \
          ${bs_genome} \
          ${txdb_transcript}\
          < /genomon_Rscripts-0.1.3/pmsignature/run_pmsignature_${pmsignature_type}.R" 

if [ $? -ne 0 ]; then
        echo pmsignature terminated abnormally.
        if [ $pmsignature_type = ind ]; then
            echo '{{"id":[],"ref":[],"alt":[],"strand":[],"mutation":[]}}' \
            > ${pmsignature_output_dir}/pmsignature.ind.result.${sig_num}.json
        fi
        if [ $pmsignature_type = full ]; then
            echo '{{"id":[],"signature":[],"mutation":[]}}' \
            > ${pmsignature_output_dir}/pmsignature.full.result.${sig_num}.json
        fi
        continue
fi

singularity exec $genomon_r_img bash -c "R --vanilla --slave --args\
          ${pmsignature_output_dir}/${pmsignature_type}.${sig_num}.Rdata \
          ${pmsignature_output_dir}/pmsignature.${pmsignature_type}.result.${sig_num}.json \
          < /genomon_Rscripts-0.1.3/pmsignature/convert_toJson_${pmsignature_type}.R"
set -e
