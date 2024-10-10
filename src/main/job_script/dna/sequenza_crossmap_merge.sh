sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles/
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath

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

$container_bin exec $samtools_img samtools merge  -f -@ $samtools_cpu ${output_dir}/seqz/${tumor_name}_all.hg19.bam $tumor_bam_files
$container_bin exec $samtools_img samtools sort -@ $samtools_cpu ${output_dir}/seqz/${tumor_name}_all.hg19.bam > ${output_dir}/seqz/${tumor_name}_all.hg19.sorted.bam
$container_bin exec $samtools_img samtools index -@ $samtools_cpu ${output_dir}/seqz/${tumor_name}_all.hg19.sorted.bam
     
