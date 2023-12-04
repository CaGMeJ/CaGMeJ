sleep $sleep_time
export PATH=/usr/local/package/python/3.6.5/bin:$PATH
source /etc/profile.d/modules.sh
module use $modulefiles
module load $parabricks_version
export SINGULARITY_BINDPATH=/cshare1,/home,/share
set -xv

declare -A sample_csv
fastq_max=0
for item in `echo $dict | sed -e "s/^\[//g" -e "s/\]$//g" -e "s/,//g"`
do
    tmp=( `echo $item | sed '1,/\:/s/\:/ /'` )
    key=${tmp[0]}
    value=${tmp[1]}
    sample_csv["$key"]="$value"
    if [ "`echo $key | grep fastq`" ]; then
        fastq_max=$(( $fastq_max + 1 ))
    fi
done
fastq_max=$(( $fastq_max / 2))
set -xv
sample_name=${sample_csv["sample_name"]}
output_dir=${output_dir}/bam/${sample_name}


if [ ! -e $output_dir ]; then
 mkdir -p  $output_dir
fi

R1=${sample_csv["fastq1"]}
R2=${sample_csv["fastq$(( 1 + $fastq_max ))"]}
RG=${sample_csv["RG1_$(( 1 + $fastq_max ))"]}
input_files="--in-fq $R1 $R2 $RG"
for i in `seq 2 $fastq_max`
do   
    R1="${sample_csv["fastq$i"]}"
    R2="${sample_csv["fastq$(( $i + $fastq_max ))"]}"
    RG="${sample_csv["RG${i}_$(( $i + $fastq_max ))"]}"
    if [ $R1 = None ]; then
        continue
    fi
    input_files="${input_files} --in-fq $R1 $R2 $RG"
done

set +e
metrics=
flag=`echo "${fq2bam_option}" | grep "\-\-no\-markdups" `
set -e
if [ ! "$flag" ];then
    metrics="--out-duplicate-metrics ${output_dir}/${sample_name}.metrics" 
fi

set +e
recal=
flag=`echo "${fq2bam_option}" | grep "\-\-knownSites" `
set -e
if [  "$flag" ];then
    recal="--out-recal-file ${output_dir}/${sample_name}.recal"
fi

if $monitoring_enable ; then
    pbrun fq2bam --tmp-dir /work \
                 $input_files \
                 --ref ${ref_fa} \
                 ${fq2bam_option} \
                 $metrics \
                 $recal \
                 --out-bam ${output_dir}/${sample_name}.markdup.bam \
                 --bwa-options "${bwa_options}"  &
    source $monitoring_script/monitoring.sh
else
   pbrun fq2bam  --tmp-dir /work \
                 $input_files \
                 --ref ${ref_fa} \
                 ${fq2bam_option} \
                 $metrics \
                 $recal \
                 --out-bam ${output_dir}/${sample_name}.markdup.bam \
                 --bwa-options "${bwa_options}" 
fi

 
