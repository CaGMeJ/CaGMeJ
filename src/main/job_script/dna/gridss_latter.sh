sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$singularity_bindpath
export JAVA_TOOL_OPTIONS="-XX:+UseSerialGC -Xms32m"
export R_LIBS_USER='-'
workdir=`pwd`
set -xv
cd $output_dir/gridss/$tumor_name
dn1=`dirname $ref_fa`
dn2=`basename $dn1`
bn=`basename $ref_fa`
ref_fa=$output_dir/gridss/$tumor_name/$dn2/$bn

flag=true
if [ $normal_bam = None ]; then
    normal_bam=""
    flag=false
fi

vcf_list=${tumor_name}.gridss.vcf
cmd="
singularity exec $gridss_img gridss \
       $gridss_option \
       --reference $ref_fa \
       --output $output_dir/gridss/$tumor_name/${tumor_name}.gridss.vcf \
       --assembly ${tumor_name}.assembly.bam \
       --jar /opt/gridss/gridss-2.12.0-gridss-jar-with-dependencies.jar 
"
$cmd -s assemble  $normal_bam $tumor_bam
$cmd -s call  $normal_bam $tumor_bam
if $flag ;then
    vcf_list="${tumor_name}.high_confidence_somatic.gridss.vcf.bgz ${tumor_name}.high_and_low_confidence_somatic.gridss.vcf.bgz"
    set -xv
    if [ $pondir = NA ]; then
        pondir_option=
    else
        pondir_option="--pondir  $pondir"
    fi
    singularity exec -B /run  $gridss_img Rscript /opt/gridss/gridss_somatic_filter \
       --input $output_dir/gridss/$tumor_name/${tumor_name}.gridss.vcf \
       --output ${tumor_name}.high_confidence_somatic.gridss.vcf \
       $pondir_option \
       --fulloutput ${tumor_name}.high_and_low_confidence_somatic.gridss.vcf \
       --scriptdir /opt/gridss/  \
       -n 1 \
       -t 2
fi


set -xv
for vcf in $vcf_list
do
    prefix=${vcf%.gridss.vcf*}
    timeout 10m tail -n 1 $output_dir/gridss/$tumor_name/$vcf
    if [ $? -gt 0 ]; then
        exit 1
    fi
    singularity exec  $gridss_img  R --vanilla --args  $output_dir/gridss/$tumor_name/$vcf \
                    $ref_type \
                    $output_dir/gridss/$tumor_name/${prefix}.gridss.annotated.vcf \
                    $output_dir/gridss/$tumor_name/${prefix}.gridss.simple.bed \
                    < ${R_script}/simpleSV-annotated.R
done
rm -r $output_dir/gridss/$tumor_name/$dn2/
cd $workdir
