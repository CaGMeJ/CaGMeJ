sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles/
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath
set -xv

expression_dir=${output_dir}/expression
star_dir=${output_dir}/star/${sample_name}
output_dir=${expression_dir}/htseq/${sample_name}


if [ ! -e ${output_dir} ]; then
 mkdir -p  ${output_dir}
fi

$container_bin exec $deseq2_img htseq-count -f bam \
            -i gene_name \
            -r pos \
            $bam_file ${gtf_file} \
	    $htseq_option \
            > ${output_dir}/${sample_name}.count.txt || exit $?

set +xv 
