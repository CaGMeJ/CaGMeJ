sleep $sleep_time
export PATH=/usr/local/package/python/3.6.5/bin:$PATH
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles/
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath
export JAVA_TOOL_OPTIONS="-XX:+UseSerialGC -Xmx16g -Xms32m -XX:ConcGCThreads=8"

export SINGULARITY_BINDPATH=$SINGULARITY_BINDPATH,/home,/share

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
output_dir=${output_dir}/star/${sample_name}

if [ ! -e $output_dir ]; then
 mkdir -p  $output_dir
fi

R1=${sample_csv["fastq1"]}
R2=${sample_csv["fastq$(( 1 + $fastq_max ))"]}
RG=${sample_csv["RG1_$(( 1 + $fastq_max ))"]}
for i in `seq 2 $fastq_max`
do  
    if [ ${sample_csv["fastq$i"]} = None ] ; then
        continue
    fi
    R1="${R1},${sample_csv["fastq$i"]}"
    R2="${R2},${sample_csv["fastq$(( $i + $fastq_max ))"]}"
    RG="${RG}\t,\t${sample_csv["RG${i}_$(( $i + $fastq_max ))"]}"
done

$container_bin exec $STAR_img STAR --genomeDir ${genome_lib_dir} \
     $star_option \
     --readFilesIn $R1 $R2 \
     --outSAMattrRGline `echo -e $RG` \
     --outFileNamePrefix $output_dir/${sample_name}. 
$container_bin exec $STAR_img samtools sort -@ 8 $output_dir/${sample_name}.Aligned.out.bam \
  -O bam > $output_dir/${sample_name}.Aligned.sortedByCoord.out.bam
$container_bin exec $STAR_img samtools index $output_dir/${sample_name}.Aligned.sortedByCoord.out.bam

$container_bin exec $picard_img java -jar /picard.jar MarkDuplicates \
      I=$output_dir/${sample_name}.Aligned.sortedByCoord.out.bam \
      O=$output_dir/${sample_name}.markdup.bam \
      M=$output_dir/${sample_name}.metrics 

$container_bin exec $STAR_img samtools index $output_dir/${sample_name}.markdup.bam

rm $output_dir/${sample_name}.Aligned.out.bam
set +xv
