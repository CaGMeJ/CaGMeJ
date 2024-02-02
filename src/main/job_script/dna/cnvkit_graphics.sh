sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$singularity_bindpath
export PYTHONNOUSERSITE=1
set -xv

output_dir=${output_dir}/cnvkit/${tumor_name}

head -n 1  ${output_dir}/${tumor_name}.markdup.cnr > ${output_dir}/${tumor_name}.cnr
head -n 1  ${output_dir}/${tumor_name}.markdup.cns > ${output_dir}/${tumor_name}.cns
grep $grep_option   ${output_dir}/${tumor_name}.markdup.cnr >>  ${output_dir}/${tumor_name}.cnr
grep $grep_option  ${output_dir}/${tumor_name}.markdup.cns >> ${output_dir}/${tumor_name}.cns

singularity exec $cnvkit_img cnvkit.py scatter  -s ${output_dir}/${tumor_name}.cn{s,r} -o ${output_dir}/${tumor_name}-scatter.png
singularity exec $cnvkit_img cnvkit.py diagram  -s ${output_dir}/${tumor_name}.cn{s,r} -o ${output_dir}/${tumor_name}-diagram.pdf  

singularity exec $cnvkit_img cnvkit.py export vcf ${output_dir}/${tumor_name}.markdup.cns ${cnvkit_export_option}  -o ${output_dir}/${tumor_name}.markdup.cns.vcf

rm ${output_dir}/${tumor_name}.cns
rm ${output_dir}/${tumor_name}.cnr

set +xv
