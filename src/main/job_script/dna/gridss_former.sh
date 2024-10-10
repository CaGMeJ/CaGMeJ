sleep $sleep_time
module use /usr/local/package/modulefiles
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath
export JAVA_TOOL_OPTIONS="-XX:+UseSerialGC -Xms32m"
export R_LIBS_USER='-'
 
workdir=`pwd`
set -xv
if [ ! -e $output_dir/gridss/$tumor_name ]; then
  mkdir -p  $output_dir/gridss/$tumor_name 
fi

flag=true
if [ $normal_bam = None ]; then
    normal_bam=""
    flag=false
fi

cd $output_dir/gridss/$tumor_name 


dn1=`dirname $ref_fa`
dn2=`basename $dn1`
bn=`basename $ref_fa`
ref_fa=$output_dir/gridss/$tumor_name/$dn2/$bn

vcf_list=${tumor_name}.gridss.vcf

cmd="
$container_bin exec $gridss_img gridss\
       $gridss_option \
       --reference $ref_fa \
       --output $output_dir/gridss/$tumor_name/${tumor_name}.gridss.vcf \
       --assembly ${tumor_name}.assembly.bam \
       --jar /opt/gridss/gridss-2.12.0-gridss-jar-with-dependencies.jar 
"

if [ ! -e $dn2 ]; then
    mkdir -p $dn2
    ls $dn1 | xargs -L 1 -I {} ln -s "$dn1/{}" "$dn2/{}"
    $cmd -s setupreference $normal_bam $tumor_bam
fi

if $flag ; then
    $cmd -s preprocess $normal_bam
fi
$cmd -s preprocess $tumor_bam
cd $workdir
