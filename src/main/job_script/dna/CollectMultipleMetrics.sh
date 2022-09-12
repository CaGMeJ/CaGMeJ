sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles
module load singularity/3.7.0 
export SINGULARITY_BINDPATH=/cshare1,/home,/share
export JAVA_TOOL_OPTIONS="-XX:+UseSerialGC -Xmx5g -Xms32m" 

if [ ! -e $output_dir/qc/CollectMultipleMetrics/$sample_name ]; then
    mkdir -p  $output_dir/qc/CollectMultipleMetrics/$sample_name
fi

singularity exec $picard_img java -jar /picard.jar CollectMultipleMetrics \
      I=$bam_file \
      O=$output_dir/qc/CollectMultipleMetrics/$sample_name/${sample_name}.multiple_metrics \
      R=$ref_fa 
