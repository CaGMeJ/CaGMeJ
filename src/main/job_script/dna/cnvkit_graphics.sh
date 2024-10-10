sleep $sleep_time
module use /usr/local/package/modulefiles
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath
export PYTHONNOUSERSITE=1
set -xv
tumor_name=`dirname $tumor_bam`
tumor_name=`basename $tumor_name`
output_dir=${output_dir}/cnvkit/${tumor_name}
prefix=`basename $tumor_bam`
prefix=${prefix%.bam}
head -n 1  ${output_dir}/${prefix}.cnr > ${output_dir}/${tumor_name}.cnr
head -n 1  ${output_dir}/${prefix}.cns > ${output_dir}/${tumor_name}.cns
grep $grep_option   ${output_dir}/${prefix}.cnr >>  ${output_dir}/${tumor_name}.cnr
grep $grep_option  ${output_dir}/${prefix}.cns >> ${output_dir}/${tumor_name}.cns

$container_bin exec $cnvkit_img cnvkit.py scatter  -s ${output_dir}/${tumor_name}.cn{s,r} -o ${output_dir}/${tumor_name}-scatter.png
$container_bin exec $cnvkit_img cnvkit.py diagram  -s ${output_dir}/${tumor_name}.cn{s,r} -o ${output_dir}/${tumor_name}-diagram.pdf  

$container_bin exec $cnvkit_img cnvkit.py export vcf ${output_dir}/${prefix}.cns ${cnvkit_export_option}  -o ${output_dir}/${prefix}.cns.vcf

rm ${output_dir}/${tumor_name}.cns
rm ${output_dir}/${tumor_name}.cnr

set +xv
