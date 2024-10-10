sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles/
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath

set -xv


tumor_file=$tumor_bam

if [ ! -e ${output_dir}/sequenza/${tumor_name}/seqz ]; then
 mkdir -p  ${output_dir}/sequenza/${tumor_name}/seqz
fi

tumor_bam_hg19=${output_dir}/sequenza/${tumor_name}/seqz/${tumor_name}_${chr}.hg19

$container_bin exec $samtools_img  samtools view -b $tumor_file $chr > ${output_dir}/sequenza/${tumor_name}/seqz/${tumor_name}_${chr}.bam
$container_bin exec $samtools_img  samtools index ${output_dir}/sequenza/${tumor_name}/seqz/${tumor_name}_${chr}.bam
$container_bin exec $sequenza_utils_img CrossMap.py bam $chain_file  ${output_dir}/sequenza/${tumor_name}/seqz/${tumor_name}_${chr}.bam  $tumor_bam_hg19 $crossmap_option

   
rm ${output_dir}/sequenza/${tumor_name}/seqz/${tumor_name}_${chr}.bam
rm ${output_dir}/sequenza/${tumor_name}/seqz/${tumor_name}_${chr}.bam.bai
 
