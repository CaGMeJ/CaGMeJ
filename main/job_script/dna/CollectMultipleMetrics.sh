sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles
module load picard/2.25.0
module load java/8
export JAVA_TOOL_OPTIONS="-XX:+UseSerialGC -Xmx5g -Xms32m" 

if [ ! -e $output_dir/qc/CollectMultipleMetrics/$sample_name ]; then
    mkdir -p  $output_dir/qc/CollectMultipleMetrics/$sample_name
fi

java -jar /usr/local/package/picard/2.25.0/picard.jar CollectMultipleMetrics \
      I=$bam_file \
      O=$output_dir/qc/CollectMultipleMetrics/$sample_name/${sample_name}.multiple_metrics \
      R=$ref_fa 


