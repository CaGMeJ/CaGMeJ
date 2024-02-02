sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles/
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$singularity_bindpath

set -xv


tumor_file=$tumor_bam

if [ ! -e ${output_dir}/sequenza/${tumor_name}/seqz ]; then
 mkdir -p  ${output_dir}/sequenza/${tumor_name}/seqz
fi

tumor_bam_hg19=${output_dir}/sequenza/${tumor_name}/seqz/${tumor_name}_${chr}.hg19

singularity exec $samtools_img  samtools view -b $tumor_file $chr > ${output_dir}/sequenza/${tumor_name}/seqz/${tumor_name}_${chr}.bam
singularity exec $samtools_img  samtools index ${output_dir}/sequenza/${tumor_name}/seqz/${tumor_name}_${chr}.bam
singularity exec $sequenza_utils_img CrossMap.py bam $chain_file  ${output_dir}/sequenza/${tumor_name}/seqz/${tumor_name}_${chr}.bam  $tumor_bam_hg19 $crossmap_option

   
rm ${output_dir}/sequenza/${tumor_name}/seqz/${tumor_name}_${chr}.bam
rm ${output_dir}/sequenza/${tumor_name}/seqz/${tumor_name}_${chr}.bam.bai
 
