
sleep $sleep_time
module use /usr/local/package/modulefiles
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath

set -xv
set -o pipefail

if [ ! -e  ${output_dir}/ngscheckmate ]; then
    mkdir -p    ${output_dir}/ngscheckmate
fi

$container_bin exec $ngscheckmate_img  samtools mpileup $NCM_mpileup_option  -uf $ref_fa  -l $NCM_bed $bam_file | \
$container_bin exec $ngscheckmate_img bcftools call -c -  >  ${output_dir}/ngscheckmate/${sample_name}.vcf

if [ `grep -v ^# ${output_dir}/ngscheckmate/${sample_name}.vcf  | wc -l` -eq 0  ];then
    exit 1
fi
