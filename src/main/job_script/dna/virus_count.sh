sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles
module load $container_module_file 
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath
set -xv
set -e
if [ ! -e $output_dir/virus_count/$sample_name ]; then
    mkdir -p  $output_dir/virus_count/$sample_name
fi
cwd=`pwd`
cd $output_dir/virus_count/$sample_name
$container_bin exec $virus_count_img python3  $python_dir/virus_count/bam_filter_single.py --input_bam $bam_file
bn=`basename $bam_file`
bn=${bn%.bam}
fastq=${bn}.fq
sam=${bn}.sam
$container_bin exec $virus_count_img bowtie2 \
                -x ${bowtie_ref} \
                -U ${fastq} \
                -S $sam

grep -v ^@ $sam | cut -f 3 | sort | uniq -c  > ${bn}.virus_count.txt
rm $fastq
cd $cwd 
