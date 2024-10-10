sleep $sleep_time
module use /usr/local/package/modulefiles
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath
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

$container_bin exec $msisensor_img msisensor-pro scan\
        -d $ref_fa \
        -o $output_dir/msisensor/$tumor_name/${bn}.list

#tumor vs normal
if $flag ; then
    $container_bin exec $msisensor_img msisensor-pro msi\
        -d $output_dir/msisensor/$tumor_name/${bn}.list \
        -t $tumor_bam \
        -n $normal_bam \
        -o $output_dir/msisensor/$tumor_name/tumor_normal

    if [ "`tail -n 2 $output_dir/msisensor/$tumor_name/tumor_normal_dis | awk -F ' ' '{s= s $1}END{print s}'`" != "N:T:" ]; then
        exit 1
    fi
    if [ "`tail -n 2 $output_dir/msisensor/$tumor_name/tumor_normal_dis | awk -F ' ' '{s= s" "NF}END{print s}'`" != " 101 101" ]; then
        exit 1
    fi 
    if [ ! -s $output_dir/msisensor/$tumor_name/tumor_normal_germline ]; then
        exit 1
    fi
    if [ ! -s $output_dir/msisensor/$tumor_name/tumor_normal_somatic ]; then
        exit 1
    fi
#tumor only
else
    $container_bin exec $msisensor_img msisensor-pro baseline\
        -i $baseline_configure \
        -d $output_dir/msisensor/$tumor_name/${bn}.list \
        -o $output_dir/msisensor/$tumor_name/baseline

    $container_bin exec $msisensor_img msisensor-pro pro\
        -d $output_dir/msisensor/$tumor_name/baseline/${bn}.list_baseline \
        -t $tumor_bam \
        -o $output_dir/msisensor/$tumor_name/tumor_only
fi
