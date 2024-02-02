sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$singularity_bindpath
if [ -d /work ]; then
  export SINGULARITY_BINDPATH=$SINGULARITY_BINDPATH,/work
fi

set -xv
if [ -d `dirname $gridss_work_dir` ]; then
    gridss_option="$gridss_option --workingdir $gridss_work_dir/$tumor_name"
fi
set +xv
echo "gridss waiting..."
date
gridss_work_dir_count=0
if [ -d  $gridss_work_dir ]; then
    gridss_work_dir_count=`ls $gridss_work_dir | wc -l`
fi
while [  $gridss_work_dir_count -gt $gridss_work_dir_count_limit ]
do
    sleep $gridss_wait_time
    gridss_work_dir_count=`ls $gridss_work_dir | wc -l`
done
echo "gridss start!"
date
export JAVA_TOOL_OPTIONS="-XX:+UseSerialGC -Xms32m"
export R_LIBS_USER='-'
 
workdir=`pwd`
set -xv
if [ -e $output_dir/gridss/$tumor_name ]; then
  rm -r  $output_dir/gridss/$tumor_name 
fi
mkdir -p  $output_dir/gridss/$tumor_name

flag=true
if [ $normal_bam = None ]; then
    normal_bam=""
    flag=false
fi

cd $output_dir/gridss/$tumor_name 


dn1=`dirname $ref_fa`
dn2=`basename $dn1`
if [ ! -e $dn2 ]; then
    mkdir -p $dn2
    ls $dn1 | xargs -L 1 -I {} ln -s "$dn1/{}" "$dn2/{}"
fi
bn=`basename $ref_fa`
ref_fa=$output_dir/gridss/$tumor_name/$dn2/$bn

vcf_list=${tumor_name}.gridss.vcf

singularity exec $gridss_img gridss \
       $gridss_option \
       --reference $ref_fa \
       --output $output_dir/gridss/$tumor_name/${tumor_name}.gridss.vcf \
       --assembly ${tumor_name}.assembly.bam \
       --jar /opt/gridss/gridss-2.12.0-gridss-jar-with-dependencies.jar \
       $normal_bam \
       $tumor_bam

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
if [ -d $gridss_work_dir/$tumor_name ]; then
    rm -r $gridss_work_dir/$tumor_name
fi
cd $workdir
