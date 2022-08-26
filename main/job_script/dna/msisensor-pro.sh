sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$SINGULARITY_BINDPATH,/home,/share
set -e
set -xv

if [ ! -e $output_dir/msisensor/$tumor_name ]; then
 mkdir -p  $output_dir/msisensor/$tumor_name
fi


flag=true
if [ $normal_bam = None ]; then
    normal_bam=""
    flag=false
fi

bn=`basename $ref_fa`
bn=${bn%.*}

singularity exec $msisensor_img msisensor-pro scan\
        -d $ref_fa \
        -o $output_dir/msisensor/$tumor_name/${bn}.list

#tumor vs normal
if $flag ; then
    singularity exec $msisensor_img msisensor-pro msi\
        -d $output_dir/msisensor/$tumor_name/${bn}.list \
        -t $tumor_bam \
        -n $normal_bam \
        -o $output_dir/msisensor/$tumor_name/tumor_normal
#tumor only
else
    singularity exec $msisensor_img msisensor-pro baseline\
        -i $baseline_configure \
        -d $output_dir/msisensor/$tumor_name/${bn}.list \
        -o $output_dir/msisensor/$tumor_name/baseline

    singularity exec $msisensor_img msisensor-pro pro\
        -d $output_dir/msisensor/$tumor_name/baseline/${bn}.list_baseline \
        -t $tumor_bam \
        -o $output_dir/msisensor/$tumor_name/tumor_only
fi
