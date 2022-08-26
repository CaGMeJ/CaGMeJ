sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles/
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$SINGULARITY_BINDPATH,/home,/share
set -xv

expression_dir=${output_dir}/expression
star_dir=${output_dir}/star/${sample_name}
output_dir=${expression_dir}/htseq/${sample_name}


if [ ! -e ${output_dir} ]; then
 mkdir -p  ${output_dir}
fi

singularity exec $deseq2_img htseq-count -f bam \
            -i gene_name \
            -r pos \
            ${star_dir}/${sample_name}.Aligned.sortedByCoord.out.bam ${gtf_file} \
            > ${output_dir}/${sample_name}.count.txt || exit $?

set +xv 
