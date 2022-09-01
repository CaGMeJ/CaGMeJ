sleep $sleep_time

export PATH=/usr/local/package/python/3.6.5/bin:$PATH
source /etc/profile.d/modules.sh
module use /opt/parabricks/modulefiles/
module load parabricks_pipeline/$parabricks_version

set -xv
output_dir=${output_dir}/qc/bammetrics/${sample_name}
if [ ! -e  ${output_dir} ]; then
 mkdir -p   ${output_dir}
fi


if $monitoring_enable ; then
     pbrun bammetrics  --tmp-dir  /work/ \
                  --ref  ${ref_fa} \
                  --bam  ${bam_file} \
                  --out-metrics-file ${output_dir}/${sample_name}.tmp.txt &
     source $monitoring_script/monitoring.sh
else
     pbrun bammetrics  --tmp-dir  /work/ \
                  --ref  ${ref_fa} \
                  --bam  ${bam_file} \
                  --out-metrics-file ${output_dir}/${sample_name}.tmp.txt
fi

echo "# CollectWgsMetrics INPUT=${bam_file} " > ${output_dir}/${sample_name}.metrics.txt
cat ${output_dir}/${sample_name}.tmp.txt >> ${output_dir}/${sample_name}.metrics.txt
rm ${output_dir}/${sample_name}.tmp.txt 
