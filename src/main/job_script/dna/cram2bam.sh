sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles
module load $container_module_file 
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath

set -xv
set -e

if [ ! -d ${output_dir}/bam/${sample_name} ]; then
    mkdir -p ${output_dir}/bam/${sample_name}
fi

$container_bin exec $samtools_img samtools view ${cram_view_option} -b -T ${ref_fa} ${cram_file} > ${output_dir}/bam/${sample_name}/${sample_name}.markdup.decoded.bam
$container_bin exec $samtools_img samtools index ${cram_index_option}  ${output_dir}/bam/${sample_name}/${sample_name}.markdup.decoded.bam

cwd=`pwd`
cd ${output_dir}/bam/${sample_name}
md5sum  ${sample_name}.markdup.decoded.bam >  ${output_dir}/bam/${sample_name}/${sample_name}.markdup.decoded.bam.md5
md5sum  ${sample_name}.markdup.decoded.bam.bai >  ${output_dir}/bam/${sample_name}/${sample_name}.markdup.decoded.bam.bai.md5
cd $cwd
if [ ! -s ${output_dir}/bam/${sample_name}/${sample_name}.markdup.decoded.bam.md5 ]; then
  exit 1
fi

if [ ! -s ${output_dir}/bam/${sample_name}/${sample_name}.markdup.decoded.bam.bai.md5 ]; then
  exit 1
fi
