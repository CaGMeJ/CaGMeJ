sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$singularity_bindpath
set -xv
set -e

singularity exec $vep_img vep -i ${output_dir}/mutect/${tumor_name}/${tumor_name}.mutect.vcf.gz \
                              -o ${output_dir}/mutect/${tumor_name}/${tumor_name}.mutect.vcf.gz.vep.vcf \
                              -offline --force_overwrite --dir_cache $vep_cache_dir \
                              --fasta $ref_fa \
                              $vep_param
