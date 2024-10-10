sleep $sleep_time
module use /usr/local/package/modulefiles
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath
set -xv
set -e

$container_bin exec $vep_img vep -i ${output_dir}/deepvariant/${sample_name}/${sample_name}.deepvariant.vcf.gz \
                              -o ${output_dir}/deepvariant/${sample_name}/${sample_name}.deepvariant.vcf.gz.vep.vcf \
                              -offline --force_overwrite --dir_cache $vep_cache_dir \
                              --fasta $ref_fa \
                              $vep_param
