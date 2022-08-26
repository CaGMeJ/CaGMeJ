
sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$SINGULARITY_BINDPATH,/home,/share

set -xv

if [ ! -e  ${output_dir}/ngscheckmate ]; then
    mkdir -p    ${output_dir}/ngscheckmate
fi

singularity exec $ngscheckmate_img  samtools mpileup $NCM_mpileup_option  -uf $ref_fa  -l $NCM_bed $bam_file | \
singularity exec $ngscheckmate_img bcftools call -c -  >  ${output_dir}/ngscheckmate/${sample_name}.vcf
