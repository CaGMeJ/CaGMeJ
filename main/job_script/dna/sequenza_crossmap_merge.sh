sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles/
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$SINGULARITY_BINDPATH,/home,/share

set -xv
chr_list=`echo "$chr_list" | sed -e 's/\,\|\[\|]//g'`
output_dir=${output_dir}/sequenza/${tumor_name}

if [ ! -e $output_dir/seqz ]; then
 mkdir -p  $output_dir/seqz
fi

tumor_bam_files=

for chr in $chr_list
do
   tumor_bam_files="$tumor_bam_files ${output_dir}/seqz/${tumor_name}_${chr}.hg19.sorted.bam" 
done

singularity exec $samtools_img samtools merge  -f -@ $samtools_cpu ${output_dir}/seqz/${tumor_name}_all.hg19.bam $tumor_bam_files
singularity exec $samtools_img samtools sort -@ $samtools_cpu ${output_dir}/seqz/${tumor_name}_all.hg19.bam > ${output_dir}/seqz/${tumor_name}_all.hg19.sorted.bam
singularity exec $samtools_img samtools index -@ $samtools_cpu ${output_dir}/seqz/${tumor_name}_all.hg19.sorted.bam
     
