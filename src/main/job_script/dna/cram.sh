sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles
module load singularity/3.7.0 
export SINGULARITY_BINDPATH=/cshare1,/home,/share

set -xv
set -e

singularity exec $samtools_img samtools view ${cram_view_option} -C -T ${ref_fa} ${bam_file} > ${output_dir}/bam/${sample_name}/${sample_name}.markdup.cram
singularity exec $samtools_img samtools index ${cram_index_option}  ${output_dir}/bam/${sample_name}/${sample_name}.markdup.cram

cwd=`pwd`
cd ${output_dir}/bam/${sample_name}
md5sum  ${sample_name}.markdup.cram >  ${output_dir}/bam/${sample_name}/${sample_name}.markdup.cram.md5
md5sum  ${sample_name}.markdup.cram.crai >  ${output_dir}/bam/${sample_name}/${sample_name}.markdup.cram.crai.md5
cd $cwd
if [ ! -s ${output_dir}/bam/${sample_name}/${sample_name}.markdup.cram.md5 ]; then
  exit 1
fi

if [ ! -s ${output_dir}/bam/${sample_name}/${sample_name}.markdup.cram.crai.md5 ]; then
  exit 1
fi
