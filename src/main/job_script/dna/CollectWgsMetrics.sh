sleep $sleep_time

export PATH=/usr/local/package/python/3.6.5/bin:$PATH
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$singularity_bindpath
export JAVA_TOOL_OPTIONS="-XX:+UseSerialGC -Xmx2g -Xms32m"

set -xv
output_dir=${output_dir}/qc/CollectWgsMetrics/${sample_name}
if [ ! -e  ${output_dir} ]; then
 mkdir -p   ${output_dir}
fi

singularity exec $gatk_img /gatk-4.1.0.0/gatk CollectWgsMetrics \
       --I ${bam_file}  \
       --O ${output_dir}/${sample_name}.collect_wgs_metrics.txt \
       --R ${ref_fa}
