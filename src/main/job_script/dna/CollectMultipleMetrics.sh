sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles
module load $container_module_file 
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath
export JAVA_TOOL_OPTIONS="-XX:+UseSerialGC -Xmx5g -Xms32m" 
set -xv
set -e
if [ ! -e $output_dir/qc/CollectMultipleMetrics/$sample_name ]; then
    mkdir -p  $output_dir/qc/CollectMultipleMetrics/$sample_name
fi

$container_bin exec $picard_img java -jar /picard.jar CollectMultipleMetrics \
      I=$bam_file \
      O=$output_dir/qc/CollectMultipleMetrics/$sample_name/${sample_name}.multiple_metrics \
      R=$ref_fa

for  suffix in alignment_summary_metrics base_distribution_by_cycle_metrics insert_size_metrics quality_by_cycle_metrics quality_distribution_metrics
do
    if [ ! -s $output_dir/qc/CollectMultipleMetrics/$sample_name/${sample_name}.multiple_metrics.${suffix} ]; then
        exit 1
    fi
done 
